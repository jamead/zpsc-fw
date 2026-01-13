
#include <string.h>

#include <FreeRTOS.h>
#include <lwip/init.h>
#include <lwip/sockets.h>
#include <lwip/sys.h>
#include <lwip/dhcp.h>
#include <netif/xadapter.h>
#include <xparameters.h>
//#include <lwipopts.h>

#include "local.h"




static struct netif server_netif;

static
void show_ip_info(const char *prefix)
{
    // LwIP inet_ntoa() uses a static char[] , so one call at a time
    printf("%s: %s", prefix, inet_ntoa(server_netif.ip_addr.addr));
    printf("/%s", inet_ntoa(server_netif.netmask.addr));
    printf(" gw: %s\n", inet_ntoa(server_netif.gw.addr));
}

static
void dhcp_client(void *arg)
{
    ip_addr_t prev = IPADDR4_INIT(0);
    int mscnt = 0;
    (void)arg;

    printf("DHCP client running...\n");

    while (1) {
      vTaskDelay(DHCP_FINE_TIMER_MSECS / portTICK_PERIOD_MS);
      dhcp_fine_tmr();
      mscnt += DHCP_FINE_TIMER_MSECS;
      if (mscnt >= DHCP_COARSE_TIMER_SECS * 1000) {
        dhcp_coarse_tmr();
        mscnt = 0;
      }

      if(server_netif.ip_addr.addr != prev.addr) {
          show_ip_info("DHCP address assigned");
          prev = server_netif.ip_addr;
      }
    }
}

void net_setup(net_config *conf)
{
    lwip_init();

    printf("MAC: %02X:%02X:%02X:%02X:%02X:%02X\n",
           conf->hwaddr[0], conf->hwaddr[1], conf->hwaddr[2], conf->hwaddr[3], conf->hwaddr[4], conf->hwaddr[5]);

    if (!xemac_add(&server_netif, &conf->addr, & conf->mask, & conf->gw, conf->hwaddr, XPAR_XEMACPS_0_BASEADDR)) {
      printf("Error adding N/W interface\r\n");
      return;
    }

    netif_set_default(&server_netif);
    netif_set_up(&server_netif);

    if(conf->use_static) {
        show_ip_info("Static address assigned");
    }

    // launch NIC service thread
    sys_thread_new("NIC",
                   (void( * )(void * )) xemacif_input_thread, &server_netif,
                   THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

    if(!conf->use_static) {
        if(!dhcp_start(&server_netif)) {
            sys_thread_new("dhcpcd", dhcp_client, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
        } else {
            fprintf(stderr, "INFO: Unable to initialize DHCP client. Use Static address instead \n");
            IP4_ADDR(&server_netif.ip_addr, 192, 168, 1, 10);
            IP4_ADDR(&server_netif.netmask, 255, 255, 255, 0);
            IP4_ADDR(&server_netif.gw, 192, 168, 1, 1);
            netif_set_up(&server_netif);
            show_ip_info("Static address assigned");
        }
    }
}
