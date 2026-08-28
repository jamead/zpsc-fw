/*************************************************************************\
* Copyright (c) 2014 Brookhaven Science Assoc. as operator of
      Brookhaven National Laboratory.
* EPICS BASE is distributed subject to a Software License Agreement found
* in file LICENSE that is included with this distribution.
\*************************************************************************/

#include <lwip/init.h>
#include <lwip/sockets.h>
#include <lwip/sys.h>
#include <lwip/mem.h>

#include "pscmsg.h"
#include "local.h"

struct psc_header {
    uint8_t P;
    uint8_t S;
    uint16_t mid;
    uint32_t mlen;
};

union psc_header_buf {
    struct psc_header M;
    char B[sizeof(struct psc_header)];
};

int psc_sendall(int sock,
                const void *buf,
                size_t buflen,
                int flags)
{
    while(buflen) {
        ssize_t ret = send(sock, buf, buflen, flags);
        if(ret<0) {
            return errno;
        } else if(ret==0) {
            return ENOTCONN;
        }
        buf += ret;
        buflen -= ret;
    }
    return 0;
}

int psc_recvall(int sock,
                void *buf,
                size_t buflen,
                int flags)
{
    while(buflen) {
        ssize_t ret = recv(sock, buf, buflen, flags);
        if(ret<0) {
            return errno;
        } else if(ret==0) {
            return ENOTCONN;
        }
        buf += ret;
        buflen -= ret;
    }
    return 0;
}

int psc_recvskip(int sock,
                size_t len,
                int flags)
{
    int ret;
    char buf[128];
    while(len>128 && !(ret=psc_recvall(sock, buf, 128, flags)))
        len -= 128;
    return psc_recvall(sock, buf, len, flags);
}

int psc_sendhead(int sock,
                 uint16_t msgid,
                 uint32_t msglen,
                 int flags)
{
    union psc_header_buf buf;
    buf.M.P = 'P';
    buf.M.S = 'S';
    buf.M.mid = htons(msgid);
    buf.M.mlen = htonl(msglen);

    return psc_sendall(sock, buf.B, sizeof(buf.B), flags);
}

int psc_sendmsg(int sock,
                uint16_t msgid,
                const void *buf,
                uint32_t msglen,
                int flags)
{
    int ret;

    ret = psc_sendhead(sock, msgid, msglen, flags);
    if(ret)
        return ret;

    return psc_sendall(sock, buf, msglen, flags);
}

int psc_sendmsgsingle(int sock,
                      uint16_t msgid,
                      uint32_t regid,
                      const void *buf,
                      uint32_t msglen,
                      int flags)
{
    int ret;

    ret = psc_sendhead(sock, msgid, msglen+4, 0);
    if(ret)
        return ret;

    regid = htonl(regid);

    ret = psc_sendall(sock, (void*)&regid, 4, 0);
    if(ret)
        return ret;

    return psc_sendall(sock, buf, msglen, 0);
}

int psc_recvhead(int sock,
                 uint16_t *msgid,
                 uint32_t *msglen,
                 int flags)
{
    int ret;
    union psc_header_buf buf;

    ret = psc_recvall(sock, buf.B, sizeof(buf.B), flags);
    if(ret)
        return ret;

    if(buf.M.P!='P' || buf.M.S!='S')
        return EIO;

    *msgid = ntohs(buf.M.mid);
    *msglen= ntohl(buf.M.mlen);
    return 0;
}

int psc_recvmsg(int sock,
                uint16_t *msgid,
                void *buf,
                uint32_t *msglen,
                int flags)
{
    int ret;
    uint16_t mid;
    uint32_t mlen, maxlen = *msglen;
    size_t rlen;

    ret = psc_recvhead(sock, &mid, &mlen, flags);
    if(ret)
        goto done;

    /*
     * A bad/corrupt length must not make us sit here draining an arbitrary
     * amount of data.  Drop the TCP connection and let the IOC reconnect.
     */
    if(mlen > maxlen) {
        *msgid = mid;
        *msglen = mlen;
        return EMSGSIZE;
    }

    rlen = mlen;
    ret = psc_recvall(sock, buf, rlen, flags);
    if(ret)
        goto done;

    *msgid = mid;
    *msglen = rlen;
done:
    return ret;
}

void psc_error(psc_key *key, int code, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    psc_verror(key, code, fmt, args);
    va_end(args);
}

void psc_verror(psc_key *key, int code, const char *fmt, va_list args)
{
    char msg[THREAD_STACKSIZE / 32u]; // size relative to total stack

    vsnprintf(msg, sizeof(msg), fmt, args);
    msg[sizeof(msg)-1] = '\0';

    psc_send(key, code, sizeof(msg), msg);
}
