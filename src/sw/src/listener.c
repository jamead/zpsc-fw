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
 * Single-client, single-network-thread PSC server.
 *
 * psc_run() owns the listening socket and the one IOC socket.  It is the only
 * thread which accepts, receives, sends, and closes the IOC connection.
 *
 * The periodic PSC data functions are also called from this same thread, so
 * there is no socket mutex and no cross-thread socket shutdown/close logic.
 */

#define PSC_SELECT_MS 20u
#define PSC_RX_TIMEOUT_MS 5000u
#define PSC_TX_TIMEOUT_MS 1000u
#define PSC_HEARTBEAT_TIMEOUT_MS 5000u

struct psc_client {
    psc_key *PSC;
};

struct psc_key {
    const psc_config *conf;
    int listen_sock;
    int client_sock;
    struct sockaddr_in peeraddr;
    TickType_t last_rx_tick;
    struct psc_client client;
    char rxbuf[PSC_MAX_RX_MSG_LEN];
};

static unsigned long net_uptime_ms(void)
{
    return (unsigned long)(((uint64_t)xTaskGetTickCount() * 1000ULL) /
                           (uint64_t)configTICK_RATE_HZ);
}

#define NETLOG(fmt, ...) \
    printf("[%10lu ms] " fmt "\r\n", net_uptime_ms(), ##__VA_ARGS__)

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

static void configure_client_socket(int sock)
{
    int val = 1;

    if (setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &val, sizeof(val)) == -1)
        NETLOG("TCP_NODELAY failed sock=%d errno=%d", sock, errno);

#if LWIP_SO_SNDTIMEO
#  if LWIP_SO_SNDRCVTIMEO_NONSTANDARD
    val = PSC_TX_TIMEOUT_MS;
    if (setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &val, sizeof(val)) == -1)
        NETLOG("SO_SNDTIMEO failed sock=%d errno=%d", sock, errno);
#  else
    {
        struct timeval tv = {
            PSC_TX_TIMEOUT_MS / 1000u,
            (PSC_TX_TIMEOUT_MS % 1000u) * 1000u
        };
        if (setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv)) == -1)
            NETLOG("SO_SNDTIMEO failed sock=%d errno=%d", sock, errno);
    }
#  endif
#endif

#if LWIP_SO_RCVTIMEO
#  if LWIP_SO_SNDRCVTIMEO_NONSTANDARD
    val = PSC_RX_TIMEOUT_MS;
    if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &val, sizeof(val)) == -1)
        NETLOG("SO_RCVTIMEO failed sock=%d errno=%d", sock, errno);
#  else
    {
        struct timeval tv = {
            PSC_RX_TIMEOUT_MS / 1000u,
            (PSC_RX_TIMEOUT_MS % 1000u) * 1000u
        };
        if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) == -1)
            NETLOG("SO_RCVTIMEO failed sock=%d errno=%d", sock, errno);
    }
#  endif
#endif
}

static void disconnect_client(psc_key *PSC, const char *reason)
{
    int sock;

    if (!PSC || PSC->client_sock < 0)
        return;

    sock = PSC->client_sock;

    NETLOG("DISCONNECT sock=%d peer=%s:%d reason=%s",
           sock,
           inet_ntoa(PSC->peeraddr.sin_addr.s_addr),
           ntohs(PSC->peeraddr.sin_port),
           reason ? reason : "unknown");

    /* Mark disconnected before the callback so a callback cannot send on it. */
    PSC->client_sock = -1;

    (void)shutdown(sock, SHUT_RDWR);
    (void)close(sock);

    if (PSC->conf->conn)
        (*PSC->conf->conn)(PSC->conf->pvt, PSC_DIS, &PSC->client);
}

static void accept_client(psc_key *PSC)
{
    struct sockaddr_in caddr;
    socklen_t clen = sizeof(caddr);
    int sock;

    sock = accept(PSC->listen_sock, (void *)&caddr, &clen);
    if (sock < 0) {
        NETLOG("ACCEPT ERROR errno=%d", errno);
        return;
    }

    NETLOG("ACCEPT sock=%d peer=%s:%d",
           sock,
           inet_ntoa(caddr.sin_addr.s_addr),
           ntohs(caddr.sin_port));

    /* A fresh IOC connection always supersedes any old connection. */
    if (PSC->client_sock >= 0)
        disconnect_client(PSC, "new IOC connection");

    configure_client_socket(sock);

    PSC->client_sock = sock;
    PSC->peeraddr = caddr;
    PSC->last_rx_tick = xTaskGetTickCount();

    if (PSC->conf->conn)
        (*PSC->conf->conn)(PSC->conf->pvt, PSC_CONN, &PSC->client);
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
    PSC->client_sock = -1;
    PSC->client.PSC = PSC;

    PSC->listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    PERROR(PSC->listen_sock < 0, "socket()");

    PERROR(bind(PSC->listen_sock, (void *)&laddr, sizeof(laddr)) < 0,
           "bind to port %d", config->port);

    PERROR(listen(PSC->listen_sock, 1) < 0, "listen()");

    if (key)
        *key = PSC;

    if (config->start)
        (*config->start)(config->pvt, PSC);

    NETLOG("SERVER READY port=%d listen_sock=%d", config->port, PSC->listen_sock);

    for (;;) {
        fd_set rfds;
        struct timeval tv;
        int selected_client;
        int maxfd;
        int ret;

        FD_ZERO(&rfds);
        FD_SET(PSC->listen_sock, &rfds);
        maxfd = PSC->listen_sock;

        /* Remember which client descriptor was placed in this select set. */
        selected_client = PSC->client_sock;
        if (selected_client >= 0) {
            FD_SET(selected_client, &rfds);
            if (selected_client > maxfd)
                maxfd = selected_client;
        }

        tv.tv_sec = 0;
        tv.tv_usec = PSC_SELECT_MS * 1000u;

        ret = select(maxfd + 1, &rfds, NULL, NULL, &tv);

        if (ret < 0) {
            if (errno != EINTR)
                NETLOG("SELECT ERROR errno=%d", errno);
            sys_msleep(PSC_SELECT_MS);
        } else {
            /* Handle a reconnect first.  A new IOC always wins. */
            if (FD_ISSET(PSC->listen_sock, &rfds))
                accept_client(PSC);

            /* Only read the descriptor that was actually in this select(). */
            if (selected_client >= 0 &&
                PSC->client_sock == selected_client &&
                FD_ISSET(selected_client, &rfds)) {
                uint16_t msgid;
                uint32_t msglen = sizeof(PSC->rxbuf);

                ret = psc_recvmsg(selected_client,
                                  &msgid,
                                  PSC->rxbuf,
                                  &msglen,
                                  0);

                if (ret) {
                    NETLOG("RX ERROR sock=%d ret=%d errno=%d",
                           selected_client, ret, errno);
                    disconnect_client(PSC, "receive error");
                } else {
                    PSC->last_rx_tick = xTaskGetTickCount();

                    if (PSC->conf->recv)
                        (*PSC->conf->recv)(PSC->conf->pvt,
                                       &PSC->client,
                                       msgid,
                                           msglen,
                                           PSC->rxbuf);
                }
            }
        }

        /* The IOC sends a 1 Hz application heartbeat. */
        if (PSC->client_sock >= 0 &&
            (TickType_t)(xTaskGetTickCount() - PSC->last_rx_tick) >=
                pdMS_TO_TICKS(PSC_HEARTBEAT_TIMEOUT_MS)) {
            disconnect_client(PSC, "IOC heartbeat timeout");
        }

        /*
         * Runs SA, snapshot, statistics, and BPC work in THIS SAME THREAD.
         * Therefore every normal psc_send() is serialized by construction.
         */
        pscdata_poll(PSC);
    }
}

void psc_send(psc_key *PSC,
              uint16_t msgid,
              uint32_t msglen,
              const void *msg)
{
    int sock;
    int ret;

    if (!PSC || PSC->client_sock < 0)
        return;

    sock = PSC->client_sock;
    ret = psc_sendmsg(sock, msgid, msg, msglen, 0);

    if (ret) {
        NETLOG("TX ERROR sock=%d msgid=%u len=%" PRIu32 " ret=%d errno=%d",
               sock,
               (unsigned)msgid,
               msglen,
               ret,
               errno);

        if (PSC->client_sock == sock)
            disconnect_client(PSC, "send error");
    }
}

void psc_send_one(psc_client *C,
                  uint16_t msgid,
                  uint32_t msglen,
                  const void *msg)
{
    if (C && C->PSC)
        psc_send(C->PSC, msgid, msglen, msg);
}
