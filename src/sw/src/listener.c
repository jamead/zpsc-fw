#include <stdio.h>
#include <inttypes.h>
#include <errno.h>
#include <string.h>

#include <FreeRTOS.h>
#include <task.h>

#include <lwip/init.h>
#include <lwip/sockets.h>
#include <lwip/tcpip.h>
#include <lwip/mem.h>
#include <lwip/sys.h>

#include "pscopts.h"
#include "pscserver.h"
#include "pscmsg.h"
#include "local.h"

/*
 * This server intentionally supports exactly one IOC connection.
 *
 * Important ownership rule:
 *     handle_client() is the ONLY code that close()s an established
 *     client socket.
 *
 * A reconnect or TX error may call shutdown() from another task.  shutdown()
 * is used only to wake a handle_client() task which may be blocked inside
 * recv()/psc_recvmsg().  The handle_client() task still owns the one and only
 * close() of the established socket.
 */

#define NET_SLOW_MS 1000u

/*
 * Diagnostic state for the one handle_client task.
 *
 * If the connection ever gets stuck again, the reconnect log tells us
 * exactly where the old client task was when the IOC tried to reconnect.
 */
enum client_state {
    CLIENT_STATE_INACTIVE = 0,
    CLIENT_STATE_STARTING,
    CLIENT_STATE_IN_RECV,
    CLIENT_STATE_IN_CALLBACK,
    CLIENT_STATE_CLEANUP,
    CLIENT_STATE_WAIT_SENDGUARD,
    CLIENT_STATE_CLOSING
};

static const char *client_state_name(unsigned state)
{
    switch (state) {
    case CLIENT_STATE_INACTIVE:       return "INACTIVE";
    case CLIENT_STATE_STARTING:       return "STARTING";
    case CLIENT_STATE_IN_RECV:        return "IN_RECV";
    case CLIENT_STATE_IN_CALLBACK:    return "IN_CALLBACK";
    case CLIENT_STATE_CLEANUP:        return "CLEANUP";
    case CLIENT_STATE_WAIT_SENDGUARD: return "WAIT_SENDGUARD";
    case CLIENT_STATE_CLOSING:        return "CLOSING";
    default:                          return "UNKNOWN";
    }
}

static unsigned long net_uptime_ms(void)
{
    return (unsigned long)(((uint64_t)xTaskGetTickCount() * 1000ULL) /
                           (uint64_t)configTICK_RATE_HZ);
}

#define NETLOG(fmt, ...) \
    printf("[%10lu ms] " fmt "\r\n", net_uptime_ms(), ##__VA_ARGS__)


struct psc_client {
    int sock;                    /* valid while client_active != 0 */
    struct sockaddr_in peeraddr;
    psc_key *PSC;

    char rxbuf[8 + PSC_MAX_RX_MSG_LEN];
};


struct psc_key {
    /*
     * Serializes all TCP transmissions with final client socket close.
     * Never use this mutex in the accept path.
     */
    sys_mutex_t sendguard;

    /*
     * Protects client_active, disconnect_requested, client.sock, and
     * client.peeraddr.  Never hold this mutex across a blocking lwIP call.
     */
    sys_mutex_t clientguard;

    const psc_config *conf;
    int listen_sock;

    int client_active;
    int disconnect_requested;

    /* Written by handle_client(), read by listener/TX paths for diagnostics. */
    volatile unsigned client_state;

    struct psc_client client;
};


static void handle_client(void *raw);


#define ERROR(BAD, fmt, ...) \
    do { \
        if (BAD) { \
            printf("Error: %s:%d %s " #BAD ": " fmt "\n", \
                   __FILE__, __LINE__, __FUNCTION__, ##__VA_ARGS__); \
            return; \
        } \
    } while (0)


#define PERROR(BAD, fmt, ...) \
    do { \
        if (BAD) { \
            printf("Error: %s:%d %s (errno=%d): " fmt "\n", \
                   __FILE__, __LINE__, __FUNCTION__, errno, ##__VA_ARGS__); \
            return; \
        } \
    } while (0)


/*
 * Snapshot the current client state for logging or short decisions.
 */
static void psc_client_snapshot(struct psc_key *PSC,
                                int *active,
                                int *sock,
                                int *disconnect_requested)
{
    sys_mutex_lock(&PSC->clientguard);

    if (active)
        *active = PSC->client_active;

    if (sock)
        *sock = PSC->client.sock;

    if (disconnect_requested)
        *disconnect_requested = PSC->disconnect_requested;

    sys_mutex_unlock(&PSC->clientguard);
}


/*
 * Request cleanup of the currently active socket.
 *
 * Setting disconnect_requested alone is not sufficient: handle_client() may
 * be blocked inside psc_recvmsg()/recv() and therefore never get back to the
 * top of its loop to notice the flag.
 *
 * shutdown(SHUT_RDWR) wakes the blocked receive.  We intentionally do NOT
 * close() the socket here.  handle_client() remains the sole owner of close().
 */
static void psc_request_disconnect(struct psc_key *PSC, int expected_sock)
{
    int do_shutdown = 0;
    unsigned state;

    sys_mutex_lock(&PSC->clientguard);

    if (PSC->client_active &&
        PSC->client.sock == expected_sock) {
        PSC->disconnect_requested = 1;
        do_shutdown = 1;
    }

    state = PSC->client_state;

    sys_mutex_unlock(&PSC->clientguard);

    if (do_shutdown) {
        int ret;
        int saved_errno;

        NETLOG("FORCING SHUTDOWN sock=%d state=%u(%s)",
               expected_sock,
               state,
               client_state_name(state));

        ret = shutdown(expected_sock, SHUT_RDWR);
        saved_errno = errno;

        if (ret == -1) {
            NETLOG("SHUTDOWN ERROR sock=%d errno=%d state=%u(%s)",
                   expected_sock,
                   saved_errno,
                   state,
                   client_state_name(state));
        } else {
            NETLOG("SHUTDOWN DONE sock=%d state=%u(%s)",
                   expected_sock,
                   state,
                   client_state_name(state));
        }
    }
}


static void psc_configure_client_socket(int sock)
{
    int val;

    /* Small control/status messages benefit from disabling Nagle. */
    val = 1;
    if (setsockopt(sock,
                   IPPROTO_TCP,
                   TCP_NODELAY,
                   &val,
                   sizeof(val)) == -1) {
        NETLOG("SETSOCKOPT TCP_NODELAY ERROR sock=%d errno=%d",
               sock,
               errno);
    }

#if LWIP_SO_SNDTIMEO
    /*
     * Do not let a stalled IOC hold sendguard forever.
     */
#  if LWIP_SO_SNDRCVTIMEO_NONSTANDARD
    val = 1000;                  /* milliseconds */
    if (setsockopt(sock,
                   SOL_SOCKET,
                   SO_SNDTIMEO,
                   &val,
                   sizeof(val)) == -1) {
#  else
    {
        struct timeval tv = {1, 0}; /* seconds, microseconds */
        if (setsockopt(sock,
                       SOL_SOCKET,
                       SO_SNDTIMEO,
                       &tv,
                       sizeof(tv)) == -1) {
#  endif
            NETLOG("SETSOCKOPT SO_SNDTIMEO ERROR sock=%d errno=%d",
                   sock,
                   errno);
        }
#  if !LWIP_SO_SNDRCVTIMEO_NONSTANDARD
    }
#  endif
#else
    NETLOG("WARNING: LWIP_SO_SNDTIMEO is disabled");
#endif

#if LWIP_SO_RCVTIMEO
    /*
     * The IOC sends a 1 Hz keep-alive.  Five seconds with no receive traffic
     * is treated as a dead connection.  shutdown() is used for immediate
     * reconnect/TX-error wakeup; this timeout remains a second line of defense.
     */
#  if LWIP_SO_SNDRCVTIMEO_NONSTANDARD
    val = 5000;                  /* milliseconds */
    if (setsockopt(sock,
                   SOL_SOCKET,
                   SO_RCVTIMEO,
                   &val,
                   sizeof(val)) == -1) {
#  else
    {
        struct timeval tv = {5, 0}; /* seconds, microseconds */
        if (setsockopt(sock,
                       SOL_SOCKET,
                       SO_RCVTIMEO,
                       &tv,
                       sizeof(tv)) == -1) {
#  endif
            NETLOG("SETSOCKOPT SO_RCVTIMEO ERROR sock=%d errno=%d",
                   sock,
                   errno);
        }
#  if !LWIP_SO_SNDRCVTIMEO_NONSTANDARD
    }
#  endif
#else
    NETLOG("WARNING: LWIP_SO_RCVTIMEO is disabled; heartbeat timeout unavailable");
#endif
}


void psc_run(psc_key **key, const psc_config *config)
{
    struct sockaddr_in laddr;
    psc_key *PSC;

    memset(&laddr, 0, sizeof(laddr));

    laddr.sin_family = AF_INET;
    laddr.sin_addr.s_addr = htonl(INADDR_ANY);
    laddr.sin_port = htons(config->port);

    ERROR(key && *key, "key already set");

    PSC = mem_calloc(1, sizeof(*PSC));
    ERROR(!PSC, "Unable to allocate %zu bytes for PSC", sizeof(*PSC));

    PSC->conf = config;
    PSC->listen_sock = -1;
    PSC->client.sock = -1;
    PSC->client.PSC = PSC;
    PSC->client_active = 0;
    PSC->disconnect_requested = 0;
    PSC->client_state = CLIENT_STATE_INACTIVE;

    PERROR(sys_mutex_new(&PSC->sendguard) != ERR_OK, "sendguard");
    PERROR(sys_mutex_new(&PSC->clientguard) != ERR_OK, "clientguard");

    PSC->listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    PERROR(PSC->listen_sock == -1, "socket()");

    PERROR(bind(PSC->listen_sock,
                (void *)&laddr,
                sizeof(laddr)) == -1,
           "bind to port %d",
           config->port);

    PERROR(listen(PSC->listen_sock, 1) == -1, "listen");

    if (key)
        *key = PSC;

    if (config->start)
        (*config->start)(config->pvt, PSC);

    NETLOG("SERVER READY port=%d listen_sock=%d single-client",
           config->port,
           PSC->listen_sock);

    while (1) {
        struct sockaddr_in caddr;
        socklen_t clen = sizeof(caddr);
        int client;
        int active;
        int oldsock;

        client = accept(PSC->listen_sock,
                        (void *)&caddr,
                        &clen);

        if (client == -1) {
            int saved_errno = errno;

            psc_client_snapshot(PSC, &active, &oldsock, NULL);

            NETLOG("ACCEPT ERROR errno=%d port=%d active=%d sock=%d",
                   saved_errno,
                   config->port,
                   active,
                   oldsock);

            sys_msleep(1000);
            continue;
        }

        psc_client_snapshot(PSC, &active, &oldsock, NULL);

        NETLOG("ACCEPT sock=%d peer=%s:%d active=%d current_sock=%d",
               client,
               inet_ntoa(caddr.sin_addr.s_addr),
               ntohs(caddr.sin_port),
               active,
               oldsock);

        /*
         * Only one IOC is supported.
         *
         * A new connection while the old one is still active is interpreted
         * as a reconnect attempt.  Ask the old handler to exit, close this
         * newly accepted socket, and let the IOC retry.  The old handler will
         * normally exit on the next 1 Hz keep-alive, or within five seconds
         * because of SO_RCVTIMEO.
         *
         * Most importantly, there is no client-slot allocation to leak.
         */
        if (active) {
            unsigned state = PSC->client_state;

            NETLOG("RECONNECT REQUEST peer=%s:%d old_sock=%d "
                   "state=%u(%s); forcing old cleanup and rejecting sock=%d",
                   inet_ntoa(caddr.sin_addr.s_addr),
                   ntohs(caddr.sin_port),
                   oldsock,
                   state,
                   client_state_name(state),
                   client);

            psc_request_disconnect(PSC, oldsock);

            /*
             * Keep the single-client ownership simple.  This newly accepted
             * socket is not handed to the application.  The IOC will retry
             * after the old handler has finished closing its socket.
             */
            close(client);
            continue;
        }

        psc_configure_client_socket(client);

        /*
         * Publish the new client atomically before starting its handler.
         */
        sys_mutex_lock(&PSC->clientguard);

        PSC->client.sock = client;
        PSC->client.peeraddr = caddr;
        PSC->client.PSC = PSC;
        PSC->disconnect_requested = 0;
        PSC->client_state = CLIENT_STATE_STARTING;
        PSC->client_active = 1;

        sys_mutex_unlock(&PSC->clientguard);

        NETLOG("CLIENT CONNECT sock=%d peer=%s:%d",
               client,
               inet_ntoa(caddr.sin_addr.s_addr),
               ntohs(caddr.sin_port));

        sys_thread_new("handle client",
                       handle_client,
                       &PSC->client,
                       THREAD_STACKSIZE,
                       config->client_prio ? config->client_prio
                                           : DEFAULT_THREAD_PRIO);
    }

    /* psc_run() normally never exits. */
    if (key)
        *key = NULL;
}


static void handle_client(void *raw)
{
    psc_client *C = raw;
    struct psc_key *PSC = C->PSC;
    struct sockaddr_in peeraddr;
    int sock;

    /*
     * Snapshot immutable-for-this-connection fields.  The listener does not
     * reuse the single client object until client_active has been cleared.
     */
    sys_mutex_lock(&PSC->clientguard);
    sock = C->sock;
    peeraddr = C->peeraddr;
    sys_mutex_unlock(&PSC->clientguard);

    PSC->client_state = CLIENT_STATE_STARTING;

    NETLOG("HANDLE START sock=%d peer=%s:%d state=%u(%s)",
           sock,
           inet_ntoa(peeraddr.sin_addr.s_addr),
           ntohs(peeraddr.sin_port),
           PSC->client_state,
           client_state_name(PSC->client_state));

    if (PSC->conf->conn) {
        PSC->client_state = CLIENT_STATE_IN_CALLBACK;
        (*PSC->conf->conn)(PSC->conf->pvt, PSC_CONN, C);
    }

    while (1) {
        uint16_t msgid;
        uint32_t msglen = sizeof(C->rxbuf);
        int disconnect_requested;
        int current_sock;
        int active;
        int ret;

        psc_client_snapshot(PSC,
                            &active,
                            &current_sock,
                            &disconnect_requested);

        if (!active || current_sock != sock || disconnect_requested) {
            NETLOG("HANDLE EXIT REQUEST sock=%d active=%d current_sock=%d request=%d",
                   sock,
                   active,
                   current_sock,
                   disconnect_requested);
            break;
        }

        PSC->client_state = CLIENT_STATE_IN_RECV;

        ret = psc_recvmsg(sock,
                          &msgid,
                          C->rxbuf,
                          &msglen,
                          0);

        if (ret) {
            int saved_errno = errno;

            NETLOG("RX ERROR sock=%d ret=%d errno=%d peer=%s:%d state=%u(%s)",
                   sock,
                   ret,
                   saved_errno,
                   inet_ntoa(peeraddr.sin_addr.s_addr),
                   ntohs(peeraddr.sin_port),
                   PSC->client_state,
                   client_state_name(PSC->client_state));

            break;
        }

        /*
         * A reconnect or TX error may have requested disconnect while recv()
         * was completing.  Do not dispatch another application message after
         * that request.
         */
        psc_client_snapshot(PSC,
                            &active,
                            &current_sock,
                            &disconnect_requested);

        if (!active || current_sock != sock || disconnect_requested)
            break;

        PSC->client_state = CLIENT_STATE_IN_CALLBACK;

        (*PSC->conf->recv)(PSC->conf->pvt,
                           C,
                           msgid,
                           msglen,
                           C->rxbuf);
    }

    /*
     * Tell the application while C still describes this connection.
     */
    PSC->client_state = CLIENT_STATE_CLEANUP;

    if (PSC->conf->conn) {
        PSC->client_state = CLIENT_STATE_IN_CALLBACK;
        (*PSC->conf->conn)(PSC->conf->pvt, PSC_DIS, C);
        PSC->client_state = CLIENT_STATE_CLEANUP;
    }

    /*
     * Wait until any in-progress psc_send()/psc_send_one() finishes.  The
     * socket send timeout should bound this wait even if the IOC stops reading.
     */
    PSC->client_state = CLIENT_STATE_WAIT_SENDGUARD;

    NETLOG("CLEANUP WAIT SENDGUARD sock=%d state=%u(%s)",
           sock,
           PSC->client_state,
           client_state_name(PSC->client_state));

    sys_mutex_lock(&PSC->sendguard);

    PSC->client_state = CLIENT_STATE_CLOSING;

    NETLOG("CLEANUP GOT SENDGUARD sock=%d state=%u(%s)",
           sock,
           PSC->client_state,
           client_state_name(PSC->client_state));

    /*
     * handle_client() is the one and only owner of close() for an established
     * client connection.
     */
    {
        int ret = close(sock);

        if (ret == -1) {
            NETLOG("CLOSE ERROR sock=%d errno=%d",
                   sock,
                   errno);
        } else {
            NETLOG("CLOSE DONE sock=%d", sock);
        }
    }

    /*
     * Make the server available for the next IOC connection only after the old
     * descriptor is fully closed.
     */
    sys_mutex_lock(&PSC->clientguard);

    if (PSC->client_active && PSC->client.sock == sock) {
        PSC->client.sock = -1;
        PSC->client_active = 0;
        PSC->disconnect_requested = 0;
        PSC->client_state = CLIENT_STATE_INACTIVE;
    }

    sys_mutex_unlock(&PSC->clientguard);

    sys_mutex_unlock(&PSC->sendguard);

    NETLOG("HANDLE DELETE sock=%d", sock);

    vTaskDelete(NULL);
}


void psc_send(psc_key *PSC,
              uint16_t msgid,
              uint32_t msglen,
              const void *msg)
{
    TickType_t wait_start;
    TickType_t wait_elapsed;
    int active;
    int disconnect_requested;
    int sock;
    int ret;
    int saved_errno;
    TickType_t send_start;
    TickType_t send_elapsed;

    if (!PSC)
        return;

    wait_start = xTaskGetTickCount();

    sys_mutex_lock(&PSC->sendguard);

    wait_elapsed = xTaskGetTickCount() - wait_start;

    if (wait_elapsed > pdMS_TO_TICKS(NET_SLOW_MS)) {
        NETLOG("SLOW SENDGUARD WAIT msgid=%u time=%lu ms",
               (unsigned)msgid,
               (unsigned long)(((uint64_t)wait_elapsed * 1000ULL) /
                               (uint64_t)configTICK_RATE_HZ));
    }

    psc_client_snapshot(PSC,
                        &active,
                        &sock,
                        &disconnect_requested);

    if (!active || sock < 0 || disconnect_requested) {
        sys_mutex_unlock(&PSC->sendguard);
        return;
    }

    send_start = xTaskGetTickCount();

    ret = psc_sendmsg(sock,
                      msgid,
                      msg,
                      msglen,
                      0);

    saved_errno = errno;
    send_elapsed = xTaskGetTickCount() - send_start;

    if (send_elapsed > pdMS_TO_TICKS(NET_SLOW_MS)) {
        NETLOG("SLOW SEND sock=%d msgid=%u time=%lu ms ret=%d errno=%d",
               sock,
               (unsigned)msgid,
               (unsigned long)(((uint64_t)send_elapsed * 1000ULL) /
                               (uint64_t)configTICK_RATE_HZ),
               ret,
               saved_errno);
    }

    if (ret) {
        NETLOG("TX ERROR sock=%d msgid=%u ret=%d errno=%d; requesting disconnect",
               sock,
               (unsigned)msgid,
               ret,
               saved_errno);

        /*
         * Request shutdown to wake a possibly blocked receive.  This TX task
         * still does not close() the socket; handle_client() owns close().
         */
        psc_request_disconnect(PSC, sock);
    }

    sys_mutex_unlock(&PSC->sendguard);
}


void psc_send_one(psc_client *C,
                  uint16_t msgid,
                  uint32_t msglen,
                  const void *msg)
{
    /*
     * There is exactly one client, so "send one" and "send all" are the same
     * operation.  Keeping this wrapper preserves the existing public API.
     */
    if (!C || !C->PSC)
        return;

    psc_send(C->PSC, msgid, msglen, msg);
}
