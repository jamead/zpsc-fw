#include <stdio.h>
#include <string.h>

#include <ff.h>
#include <lwip/tcpip.h>
#include <lwip/udp.h>

#include "tftp_server.h"
#include "local.h"

/* HACK: SDCARD access happens on the tcpip_thread, which will stall all
 *       network communication.
 */

static
void* tftp_sdcard_open(const char* fname, const char* mode, u8_t write)
{
    static FIL fd;
    if(strcmp(mode, "octet")!=0)
        return NULL;

    FRESULT res = f_open(&fd, fname, write ? FA_OPEN_ALWAYS|FA_WRITE : FA_OPEN_EXISTING|FA_READ);
    if(res!=FR_OK) {
        fprintf(stderr, "TFTP open %s error %d : %s\n", write ? "write":"read", res, fname);
    } else {
        printf("TFTP opened: %s\n", fname);
    }

    return res==FR_OK ? &fd : NULL;
}

static
void tftp_sdcard_close(void* handle)
{
    printf("TFTP close\n");
    FRESULT res = f_close((FIL*)handle);
    if(res!=FR_OK) {
        fprintf(stderr, "TFTP close error %d\n", res);
    }
}

static
int tftp_sdcard_read(void* handle, void* buf, int bytes)
{
    UINT n = 0;
    FRESULT res = f_read((FIL*)handle, buf, bytes, &n);
    if(res!=FR_OK) {
        fprintf(stderr, "TFTP read error %d\n", res);
        return -1;
    }
    //printf("TFTP read %d -> %u\n", bytes, n);
    return n;
}

static
int tftp_sdcard_write(void* handle, struct pbuf* p)
{
    for(; p && p->tot_len; p = p->next) {
        if(!p->len)
            continue;
        UINT n = 0;
        FRESULT res = f_write((FIL*)handle, p->payload, p->len, &n);
        if(res!=FR_OK) {
            fprintf(stderr, "TFTP write error %d\n", res);
            return -1;
        } else if(n!=p->len) {
            fprintf(stderr, "TFTP incomplete write error %u !+ %u\n", n, p->len);
            return -1;
        }
    }
    return 0;
}

static const struct tftp_context ctxt = {
    .open = tftp_sdcard_open,
    .close = tftp_sdcard_close,
    .read = tftp_sdcard_read,
    .write = tftp_sdcard_write,
};

static
void tftp_prepare(void *unused)
{
    (void)unused;

    tftp_init(&ctxt);
}

void tftp_setup(void)
{
    err_t err = tcpip_callback(tftp_prepare, NULL);
    if(err!=ERR_OK)
        fprintf(stderr, "Error %d: unable to setup TFTP\n", err);
}
