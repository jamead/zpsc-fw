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

#if PSC_MAX_CLIENTS > 32
#  error PSC_MAX_CLIENTS too large
#endif

/*
 * Only report unusually long waits/sends.  This keeps the normal
 * periodic traffic from flooding the console.
 */
#define NET_SLOW_MS 1000u

static unsigned long net_uptime_ms(void)
{
    return (unsigned long)(((uint64_t)xTaskGetTickCount() * 1000ULL) /
                           (uint64_t)configTICK_RATE_HZ);
}

#define NETLOG(fmt, ...) \
    printf("[%10lu ms] " fmt "\r\n", net_uptime_ms(), ##__VA_ARGS__)


struct psc_client {
    unsigned index;              /* index in psc_key::clients */

    int sock;                    /* -1 means do not transmit */
    struct sockaddr_in peeraddr;

    psc_key *PSC;

    char rxbuf[8 + PSC_MAX_RX_MSG_LEN];
};


struct psc_key {
    /*
     * Serializes TCP transmit operations and final socket close.
     * This mutex may be held while psc_sendmsg()/send() blocks.
     *
     * IMPORTANT: the listener/client allocator does NOT use this mutex.
     */
    sys_mutex_t sendguard;

    /*
     * Protects clients_used and the mutable fields in clients[].
     *
     * NEVER hold clientguard while calling a potentially blocking
     * lwIP function such as send(), recv(), shutdown(), close(),
     * accept(), etc.
     */
    sys_mutex_t clientguard;

    const psc_config *conf;

    int listen_sock;

    uint32_t clients_used;
    struct psc_client clients[PSC_MAX_CLIENTS];
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
 * Return a diagnostic snapshot of clients_used.
 * clientguard is held only for the short memory access.
 */
static uint32_t psc_clients_used_snapshot(struct psc_key *key)
{
    uint32_t used;

    sys_mutex_lock(&key->clientguard);
    used = key->clients_used;
    sys_mutex_unlock(&key->clientguard);

    return used;
}


/*
 * Allocate and fully initialize a client slot.
 *
 * This function intentionally uses clientguard, NOT sendguard.
 * Therefore a blocked TCP send cannot prevent the listener from
 * allocating a newly accepted connection and returning to accept().
 */
static struct psc_client *psc_client_alloc(struct psc_key *key,
                                           int sock,
                                           const struct sockaddr_in *peeraddr)
{
    psc_client *ret = NULL;

    sys_mutex_lock(&key->clientguard);

    for (unsigned i = 0; i < PSC_MAX_CLIENTS; i++) {

        if (key->clients_used & (1u << i))
            continue;

        ret = &key->clients[i];
        memset(ret, 0, sizeof(*ret));

        ret->index = i;
        ret->sock = sock;
        ret->peeraddr = *peeraddr;
        ret->PSC = key;

        /*
         * Mark the slot used LAST, after the structure is completely
         * initialized.  A sender can never observe a half-built client.
         */
        key->clients_used |= (1u << i);

        break;
    }

    sys_mutex_unlock(&key->clientguard);

    return ret;
}


static void psc_client_free(struct psc_client *cli)
{
    struct psc_key *key;
    unsigned index;
    uint32_t used;

    if (!cli || !cli->PSC)
        return;

    key = cli->PSC;
    index = cli->index;

    sys_mutex_lock(&key->clientguard);

    key->clients_used &= ~(1u << index);

    /*
     * Spoil the structure so a stale psc_client pointer cannot
     * accidentally look like an active client.
     */
    memset(cli, 0, sizeof(*cli));
    cli->sock = -1;
    cli->PSC = NULL;

    used = key->clients_used;

    sys_mutex_unlock(&key->clientguard);

    NETLOG("CLIENT FREE slot=%u clients=0x%x",
           index,
           (unsigned)used);
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

    PERROR(sys_mutex_new(&PSC->sendguard) != ERR_OK, "sendguard");
    PERROR(sys_mutex_new(&PSC->clientguard) != ERR_OK, "clientguard");

    PSC->listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    PERROR(PSC->listen_sock == -1, "socket()");

    PERROR(bind(PSC->listen_sock,
                (void *)&laddr,
                sizeof(laddr)) == -1,
           "bind to port %d",
           config->port);

    PERROR(listen(PSC->listen_sock, 2) == -1, "listen");

    if (key)
        *key = PSC;

    if (config->start)
        (*config->start)(config->pvt, PSC);

    NETLOG("SERVER READY port=%d listen_sock=%d",
           config->port,
           PSC->listen_sock);

    while (1) {

        psc_client *C = NULL;
        struct sockaddr_in caddr;
        socklen_t clen = sizeof(caddr);
        int client;

        client = accept(PSC->listen_sock,
                        (void *)&caddr,
                        &clen);

        /*
         * Check accept() before using the returned descriptor.
         */
        if (client == -1) {
            int saved_errno = errno;

            NETLOG("ACCEPT ERROR errno=%d port=%d clients=0x%x",
                   saved_errno,
                   config->port,
                   (unsigned)psc_clients_used_snapshot(PSC));

            sys_msleep(1000);
            continue;
        }

        NETLOG("ACCEPT sock=%d peer=%s:%d clients=0x%x",
               client,
               inet_ntoa(caddr.sin_addr.s_addr),
               ntohs(caddr.sin_port),
               (unsigned)psc_clients_used_snapshot(PSC));

        /*
         * Disable Nagle.  These messages are small and latency matters
         * more than aggregation.
         */
        {
            int val = 1;

            if (setsockopt(client,
                           IPPROTO_TCP,
                           TCP_NODELAY,
                           &val,
                           sizeof(val)) == -1) {
                NETLOG("SETSOCKOPT TCP_NODELAY ERROR sock=%d errno=%d",
                       client,
                       errno);
            }
        }

#if LWIP_SO_SNDTIMEO && LWIP_SO_RCVTIMEO

        /*
         * Time with the TCP TX path unable to accept more data before
         * send() returns an error.
         */
        {
#  if LWIP_SO_SNDRCVTIMEO_NONSTANDARD
            int val = 1000;              /* milliseconds */
#  else
            struct timeval val = {5, 0}; /* seconds, microseconds */
#  endif

            if (setsockopt(client,
                           SOL_SOCKET,
                           SO_SNDTIMEO,
                           &val,
                           sizeof(val)) == -1) {
                NETLOG("SETSOCKOPT SO_SNDTIMEO ERROR sock=%d errno=%d",
                       client,
                       errno);
            }
        }

        /*
         * The IOC sends a 1 Hz keep-alive.  Five seconds with no RX
         * traffic is therefore treated as a dead connection.
         */
        {
#  if LWIP_SO_SNDRCVTIMEO_NONSTANDARD
            int val = 5000;              /* milliseconds */
#  else
            struct timeval val = {5, 0}; /* seconds, microseconds */
#  endif

            if (setsockopt(client,
                           SOL_SOCKET,
                           SO_RCVTIMEO,
                           &val,
                           sizeof(val)) == -1) {
                NETLOG("SETSOCKOPT SO_RCVTIMEO ERROR sock=%d errno=%d",
                       client,
                       errno);
            }
        }

#else

        {
            static uint8_t done;

            if (!done) {
                done = 1;
                NETLOG("INFO: SO_SNDTIMEO/SO_RCVTIMEO not supported");
            }
        }

#endif

        /*
         * IMPORTANT:
         * psc_client_alloc() uses clientguard only.  It can never be
         * blocked by a task that is stuck in send() holding sendguard.
         */
        C = psc_client_alloc(PSC, client, &caddr);

        if (!C) {
            NETLOG("*** CLIENT ALLOC FAILED *** "
                   "sock=%d peer=%s:%d clients=0x%x",
                   client,
                   inet_ntoa(caddr.sin_addr.s_addr),
                   ntohs(caddr.sin_port),
                   (unsigned)psc_clients_used_snapshot(PSC));

            /*
             * This socket was never handed to handle_client(), so the
             * listener owns this close().
             */
            close(client);
            continue;
        }

        NETLOG("CLIENT ALLOC slot=%u sock=%d peer=%s:%d clients=0x%x",
               C->index,
               client,
               inet_ntoa(caddr.sin_addr.s_addr),
               ntohs(caddr.sin_port),
               (unsigned)psc_clients_used_snapshot(PSC));

        /*
         * lwIP does not allow thread creation to fail.
         */
        sys_thread_new("handle client",
                       handle_client,
                       C,
                       THREAD_STACKSIZE,
                       DEFAULT_THREAD_PRIO);

        /*
         * Immediately return to accept().  No sendguard is acquired
         * anywhere in the listener path.
         */
    }

    /*
     * psc_run() normally never exits.
     */
    if (key)
        *key = NULL;
}


static void handle_client(void *raw)
{
    psc_client *C = raw;
    struct psc_key *PSC = C->PSC;
    int sock = C->sock;

    NETLOG("HANDLE START slot=%u sock=%d peer=%s:%d clients=0x%x",
           C->index,
           sock,
           inet_ntoa(C->peeraddr.sin_addr.s_addr),
           ntohs(C->peeraddr.sin_port),
           (unsigned)psc_clients_used_snapshot(PSC));

    /*
     * Notify the application that the client connected.
     */
    if (PSC->conf->conn)
        (*PSC->conf->conn)(PSC->conf->pvt, PSC_CONN, C);

    /*
     * Receive messages from the IOC.
     */
    while (1) {

        uint16_t msgid;
        uint32_t msglen = sizeof(C->rxbuf);
        int ret;

        ret = psc_recvmsg(sock,
                          &msgid,
                          C->rxbuf,
                          &msglen,
                          0);

        if (ret) {
            int saved_errno = errno;
            int current_sock;
            uint32_t used;

            sys_mutex_lock(&PSC->clientguard);
            current_sock = C->sock;
            used = PSC->clients_used;
            sys_mutex_unlock(&PSC->clientguard);

            /*
             * current_sock == -1 means a TX task already detected an
             * error and called shutdown(), which woke this recv().
             */
            NETLOG("RX ERROR slot=%u sock=%d C->sock=%d "
                   "ret=%d errno=%d clients=0x%x",
                   C->index,
                   sock,
                   current_sock,
                   ret,
                   saved_errno,
                   (unsigned)used);

            break;
        }

        /*
         * Pass the received message to the application.
         */
        (*PSC->conf->recv)(PSC->conf->pvt,
                           C,
                           msgid,
                           msglen,
                           C->rxbuf);
    }

    /*
     * Notify the application that the client disconnected.
     */
    if (PSC->conf->conn)
        (*PSC->conf->conn)(PSC->conf->pvt, PSC_DIS, C);

    {
        int current_sock;
        uint32_t used;

        sys_mutex_lock(&PSC->clientguard);
        current_sock = C->sock;
        used = PSC->clients_used;
        sys_mutex_unlock(&PSC->clientguard);

        NETLOG("DISCONNECT slot=%u sock=%d C->sock=%d "
               "peer=%s:%d clients=0x%x",
               C->index,
               sock,
               current_sock,
               inet_ntoa(C->peeraddr.sin_addr.s_addr),
               ntohs(C->peeraddr.sin_port),
               (unsigned)used);
    }

    /*
     * Synchronize with any task currently transmitting.
     *
     * This is allowed to wait.  The important change is that the
     * listener/client allocator does NOT wait for sendguard anymore.
     */
    NETLOG("CLEANUP WAIT SENDGUARD slot=%u sock=%d",
           C->index,
           sock);

    sys_mutex_lock(&PSC->sendguard);

    NETLOG("CLEANUP GOT SENDGUARD slot=%u sock=%d",
           C->index,
           sock);

    /*
     * Update client state while holding clientguard only briefly.
     * Lock order, when both are needed, is always:
     *
     *     sendguard -> clientguard
     */
    sys_mutex_lock(&PSC->clientguard);

    if (C->sock == sock)
        C->sock = -1;

    sys_mutex_unlock(&PSC->clientguard);

    /*
     * handle_client() is the ONLY task that closes an established
     * client socket.
     */
    NETLOG("CLOSE BEGIN slot=%u sock=%d clients=0x%x",
           C->index,
           sock,
           (unsigned)psc_clients_used_snapshot(PSC));

    {
        int ret = close(sock);

        if (ret == -1) {
            int saved_errno = errno;

            NETLOG("CLOSE ERROR slot=%u sock=%d errno=%d",
                   C->index,
                   sock,
                   saved_errno);
        } else {
            NETLOG("CLOSE DONE slot=%u sock=%d",
                   C->index,
                   sock);
        }
    }

    sys_mutex_unlock(&PSC->sendguard);

    /*
     * Keep this call.
     *
     * It clears the client's bit in clients_used.  Do this only
     * after the old socket has been completely closed.
     */
    {
        unsigned slot = C->index;

        psc_client_free(C);

        NETLOG("HANDLE DELETE slot=%u sock=%d clients=0x%x",
               slot,
               sock,
               (unsigned)psc_clients_used_snapshot(PSC));
    }

    vTaskDelete(NULL);
}


void psc_send(psc_key *PSC,
              uint16_t msgid,
              uint32_t msglen,
              const void *msg)
{
    TickType_t wait_start;
    TickType_t wait_elapsed;

    if (!PSC)
        return;

    /*
     * All transmitters share sendguard.  Measure how long we wait
     * for it so a blocked sender can be identified postmortem.
     *
     * A blocked sender can delay other transmitters and client cleanup,
     * but it can no longer block the listener from accepting clients.
     */
    wait_start = xTaskGetTickCount();

    sys_mutex_lock(&PSC->sendguard);

    wait_elapsed = xTaskGetTickCount() - wait_start;

    if (wait_elapsed > pdMS_TO_TICKS(NET_SLOW_MS)) {
        NETLOG("SLOW SENDGUARD WAIT msgid=%u time=%lu ms clients=0x%x",
               (unsigned)msgid,
               (unsigned long)(((uint64_t)wait_elapsed * 1000ULL) /
                               (uint64_t)configTICK_RATE_HZ),
               (unsigned)psc_clients_used_snapshot(PSC));
    }

    for (unsigned idx = 0; idx < PSC_MAX_CLIENTS; idx++) {

        psc_client *C = &PSC->clients[idx];
        int sock = -1;
        unsigned slot = idx;
        int active = 0;
        int ret;
        int saved_errno;
        TickType_t send_start;
        TickType_t send_elapsed;

        /*
         * Snapshot client state under clientguard, then release it
         * BEFORE calling the potentially blocking psc_sendmsg().
         */
        sys_mutex_lock(&PSC->clientguard);

        if (PSC->clients_used & (1u << idx)) {
            active = 1;
            sock = C->sock;
            slot = C->index;
        }

        sys_mutex_unlock(&PSC->clientguard);

        if (!active || sock < 0)
            continue;

        send_start = xTaskGetTickCount();

        ret = psc_sendmsg(sock,
                          msgid,
                          msg,
                          msglen,
                          0);

        saved_errno = errno;
        send_elapsed = xTaskGetTickCount() - send_start;

        /*
         * Do not log normal sends.  Only log unusually slow calls.
         */
        if (send_elapsed > pdMS_TO_TICKS(NET_SLOW_MS)) {
            NETLOG("SLOW SEND slot=%u sock=%d msgid=%u "
                   "time=%lu ms ret=%d errno=%d",
                   slot,
                   sock,
                   (unsigned)msgid,
                   (unsigned long)(((uint64_t)send_elapsed * 1000ULL) /
                                   (uint64_t)configTICK_RATE_HZ),
                   ret,
                   saved_errno);
        }

        if (ret) {
            int do_shutdown = 0;

            NETLOG("TX ERROR slot=%u sock=%d msgid=%u "
                   "ret=%d errno=%d clients=0x%x",
                   slot,
                   sock,
                   (unsigned)msgid,
                   ret,
                   saved_errno,
                   (unsigned)psc_clients_used_snapshot(PSC));

            /*
             * Invalidate the client only if this slot still refers to
             * the same socket on which the error occurred.
             */
            sys_mutex_lock(&PSC->clientguard);

            if ((PSC->clients_used & (1u << idx)) &&
                C->sock == sock) {
                C->sock = -1;
                do_shutdown = 1;
            }

            sys_mutex_unlock(&PSC->clientguard);

            if (do_shutdown) {
                int shutdown_ret;
                int shutdown_errno;

                /*
                 * Wake handle_client() out of recv().
                 *
                 * DO NOT close() here.  handle_client() owns the
                 * one and only close() for an established connection.
                 */
                shutdown_ret = shutdown(sock, SHUT_RDWR);
                shutdown_errno = errno;

                if (shutdown_ret == -1) {
                    NETLOG("SHUTDOWN ERROR slot=%u sock=%d errno=%d",
                           slot,
                           sock,
                           shutdown_errno);
                } else {
                    NETLOG("SHUTDOWN slot=%u sock=%d",
                           slot,
                           sock);
                }
            }
        }
    }

    sys_mutex_unlock(&PSC->sendguard);
}


void psc_send_one(psc_client *C,
                  uint16_t msgid,
                  uint32_t msglen,
                  const void *msg)
{
    struct psc_key *PSC;
    TickType_t wait_start;
    TickType_t wait_elapsed;
    int sock = -1;
    unsigned slot = 0;
    int active = 0;

    if (!C || !C->PSC)
        return;

    PSC = C->PSC;

    wait_start = xTaskGetTickCount();

    sys_mutex_lock(&PSC->sendguard);

    wait_elapsed = xTaskGetTickCount() - wait_start;

    if (wait_elapsed > pdMS_TO_TICKS(NET_SLOW_MS)) {
        NETLOG("SLOW SEND_ONE SENDGUARD WAIT msgid=%u "
               "time=%lu ms clients=0x%x",
               (unsigned)msgid,
               (unsigned long)(((uint64_t)wait_elapsed * 1000ULL) /
                               (uint64_t)configTICK_RATE_HZ),
               (unsigned)psc_clients_used_snapshot(PSC));
    }

    /*
     * Re-check the client under clientguard after acquiring sendguard.
     * The connection state may have changed while this task waited.
     */
    sys_mutex_lock(&PSC->clientguard);

    if (C->PSC == PSC &&
        C->index < PSC_MAX_CLIENTS &&
        (PSC->clients_used & (1u << C->index))) {
        active = 1;
        slot = C->index;
        sock = C->sock;
    }

    sys_mutex_unlock(&PSC->clientguard);

    if (active && sock >= 0) {

        int ret;
        int saved_errno;
        TickType_t send_start;
        TickType_t send_elapsed;

        send_start = xTaskGetTickCount();

        ret = psc_sendmsg(sock,
                          msgid,
                          msg,
                          msglen,
                          0);

        saved_errno = errno;
        send_elapsed = xTaskGetTickCount() - send_start;

        if (send_elapsed > pdMS_TO_TICKS(NET_SLOW_MS)) {
            NETLOG("SLOW SEND_ONE slot=%u sock=%d msgid=%u "
                   "time=%lu ms ret=%d errno=%d",
                   slot,
                   sock,
                   (unsigned)msgid,
                   (unsigned long)(((uint64_t)send_elapsed * 1000ULL) /
                                   (uint64_t)configTICK_RATE_HZ),
                   ret,
                   saved_errno);
        }

        if (ret) {
            int do_shutdown = 0;

            NETLOG("TX ONE ERROR slot=%u sock=%d msgid=%u "
                   "ret=%d errno=%d clients=0x%x",
                   slot,
                   sock,
                   (unsigned)msgid,
                   ret,
                   saved_errno,
                   (unsigned)psc_clients_used_snapshot(PSC));

            sys_mutex_lock(&PSC->clientguard);

            if (C->PSC == PSC &&
                C->index == slot &&
                (PSC->clients_used & (1u << slot)) &&
                C->sock == sock) {
                C->sock = -1;
                do_shutdown = 1;
            }

            sys_mutex_unlock(&PSC->clientguard);

            if (do_shutdown) {
                int shutdown_ret;
                int shutdown_errno;

                /*
                 * Wake handle_client().  It will do the actual close().
                 */
                shutdown_ret = shutdown(sock, SHUT_RDWR);
                shutdown_errno = errno;

                if (shutdown_ret == -1) {
                    NETLOG("SHUTDOWN ONE ERROR slot=%u sock=%d errno=%d",
                           slot,
                           sock,
                           shutdown_errno);
                } else {
                    NETLOG("SHUTDOWN ONE slot=%u sock=%d",
                           slot,
                           sock);
                }
            }
        }
    }

    sys_mutex_unlock(&PSC->sendguard);
}
