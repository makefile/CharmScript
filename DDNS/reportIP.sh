#!/bin/bash
# __author__ = fyk
# get global ipv6 & ipv4 address,
# note that both ipv6 & ipv4 addr may have more than 1.

# grep -v to exclude temporary ipv6 privacy addr.
ip6s=$(ip -6 addr |grep 'global'|grep -v 'tmpaddr'|awk '{print $2}'|sed 's/\/.*//' | uniq)
ip4s_local=$(ip -4 a | grep global |awk '{print $2}' | uniq) # local v4 ips ,public or prive ips that behind NAT
ips_pub=$(curl -s ifconfig.me) # there are lots of websites supplying IP echo services
ip_data=$ips_pub' '${ip6s}' '${ip4s_local}
#echo $ip_data
IP_FILE='/dev/shm/lastip97451' # or in /tmp .etc
ip_data_old=$(cat $IP_FILE 2> /dev/null) # for non-exist file,content is null
if [ "$ip_data" != "$ip_data_old" ];then
        echo 'IP changed,push to remote.'
        #echo $ip_data > $IP_FILE # update the file
        params='k=fyk'
        cnt=0
        for ip in $ip_data;do
                echo $ip
                params=$params"&ip$cnt=$ip" # shell will handle & specially,so we first trans & to %26
                ((cnt=cnt+1))
        done
        params="n=$cnt&$params"
        sever_addr="http://x.makefile.tk/"
        #echo ${sever_addr}
        curl -G -d "$params" "$sever_addr"

else echo 'IP unchanged.'
fi
# TODO:增加断网重连