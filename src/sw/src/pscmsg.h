/*************************************************************************\
* Copyright (c) 2014 Brookhaven Science Assoc. as operator of
      Brookhaven National Laboratory.
* EPICS BASE is distributed subject to a Software License Agreement found
* in file LICENSE that is included with this distribution.
\*************************************************************************/
#ifndef PSCMSG_H
#define PSCMSG_H

#include <stdlib.h>
#include <inttypes.h>

/** Send exactly *buflen* bytes or fail.
 *
 * On failure some byte may already be sent.
 *
 * @returns 0 on success
 */
int psc_sendall(int sock,
                const void *buf,
                size_t buflen,
                int flags);

/** Receive exactly *buflen* bytes or fail.
 *
 * On failure some bytes may have been received,
 * and are now lost.
 *
 * @returns 0 on success
 */
int psc_recvall(int sock,
                void *buf,
                size_t buflen,
                int flags);

/** Receive and discard *len* bytes.
 *
 * @returns 0 on success
 */
int psc_recvskip(int sock,
                size_t len,
                int flags);

/** Send a PSC block header
 *
 * @returns 0 on success
 */
int psc_sendhead(int sock,
                 uint16_t msgid,
                 uint32_t msglen,
                 int flags);

/** Send a PSC message, header and body
 *
 * @returns 0 on success
 */
int psc_sendmsg(int sock,
                uint16_t msgid,
                const void *buf,
                uint32_t msglen,
                int flags);

/** Send a PSC message with a single-register
 * sub-header and the given body
 *
 * @returns 0 on success
 */
int psc_sendmsgsingle(int sock,
                      uint16_t msgid,
                      uint32_t regid,
                      const void *buf,
                      uint32_t msglen,
                      int flags);

/** Receive a PSC message header
 *
 * @returns 0 on success
 */
int psc_recvhead(int sock,
                 uint16_t *msgid,
                 uint32_t *msglen,
                 int flags);

/** Receive a PSC message header and body
 *
 * *msglen* should be initialized with the maximum buffer
 * size.  On success it will set with the actual message
 * length.
 *
 * If the actual message length exceeds the buffer size, psc_recvmsg()
 * returns EMSGSIZE.  The caller should close the connection and reconnect;
 * the oversized payload is intentionally not drained.
 *
 * @returns 0 on success
 */
int psc_recvmsg(int sock,
                uint16_t *msgid,
                void *buf,
                uint32_t *msglen,
                int flags);

#endif // PSCMSG_H
