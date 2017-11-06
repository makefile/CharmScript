#!/bin/bash
# put this script in /etc/NetworkManager/dispatcher.d

IF=$1
STATUS=$2

case "$STATUS" in
        down)
        #logger -s "NM Script down $IF triggered"
        ;;
        dhcp6-change|up)
                #if [ $IP6_NUM_ADDRESSES > 0 ];then
                #       echo $IP6_ADDRESS_0 //0,1,2,...
                #fi
				# msg logged to /va/log/syslog
                logger "IP6_ADDRESS_0 = $IP6_ADDRESS_0"
                /home/s05/fyk/ip/ipv6-dns.sh /home/s05/fyk/ip/dns.conf 2>&1  > /dev/null
        *)
        ;;
esac
