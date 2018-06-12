#!/bin/bash
# __author__ = fyk
# script for updating the cloudflare DNS record of a host which has dynamic public IP.
# Add this script to cron job or system network event dispatcher(such as script in /etc/NetworkManager/dispatcher.d) . 

# get global ipv6 & ipv4 address,
# note that both ipv6 & ipv4 addr may have more than 1.

# get variables in dns.conf which includes cloudflare info
# source dns.conf
if [ -z "$1" ] ;then
        echo 'please specify conf file'
        exit 0
else
        source $1
fi

# grep -v to exclude temporary ipv6 privacy addr.
# ip6s=$(ip -6 addr |grep 'global'|grep -v 'tmpaddr'|awk '{print $2}'|sed 's/\/.*//')
ip6s=$(ip -6 addr |grep 'global'|awk '{print $2}'|sed 's/\/.*//')
#for my own needs,i only use ipv6
#ip4s=$(ip -4 a | grep global |awk '{print $2}')
if [ -z "$ip6s" ] ;then
        echo 'no ipv6 addr'
		exit 0
fi
for ip in $ip6s;do
        ip_data=$ip
        break # only use first one
done
#ip_data=${ip6s}' '${ip4s}
#echo $ip_data

API_URL="https://api.cloudflare.com/client/v4"
CURL="curl -s \
  -H Content-Type:application/json \
  -H X-Auth-Key:$AUTH_KEY \
  -H X-Auth-Email:$AUTH_EMAIL "

update_dns(){
UPDATE_DATA=$(cat << EOF
{ "type": "AAAA",
  "name": "$DOMAIN_NAME",
  "content": "$2",
  "proxied": false }
EOF
)
        #"ttl": 1, # let it be Automatic
        echo "update dns: $DOMAIN_NAME -> $2"
        $CURL -X PUT "$API_URL/zones/$ZONE_ID/dns_records/$1" -d "$UPDATE_DATA" > /dev/null # > /tmp/cloudflare-ddns.json
}
# get current IP
get_dns_ip(){
        RECS=$($CURL "$API_URL/zones/$ZONE_ID/dns_records?name=$DOMAIN_NAME")
        IP=$(echo "$RECS" | sed -e 's/[{}]/\n/g' | sed -e 's/,/\n/g' | grep '"content":"' | cut -d'"' -f4)
        echo $IP
}

IP_FILE='/dev/shm/lastip9745' # or in /tmp .etc
ip_data_old=$(cat $IP_FILE 2> /dev/null) # for non-exist file,content is null
if [ "$ip_data" == "$ip_data_old" ];then
        echo 'IP unchanged.'
        exit 0
fi
echo 'IP changed,push to remote.'
if [ -z "$REC_ID" ] ; then
        RECS=$($CURL "$API_URL/zones/$ZONE_ID/dns_records?name=$DOMAIN_NAME")
        echo $RECS
        REC_ID=$(echo "$RECS" | sed -e 's/[{}]/\n/g' | sed -e 's/,/\n/g' | grep '"id":"' | cut -d'"' -f4)
        echo "write to conf: REC_ID=$REC_ID"
        echo "REC_ID=$REC_ID" >> $1
fi
update_dns "$REC_ID" "$ip_data"
cur_ip=$(get_dns_ip)
if [ "$cur_ip"=="$ip_data" ];then
        echo $ip_data > $IP_FILE # update the file
else
        echo 'update dns failed.'
fi
