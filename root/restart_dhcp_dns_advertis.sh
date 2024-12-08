#!/bin/sh

local_dns="10.1.1.2"
google_dns="8.8.8.8"
config="/etc/config/dhcp"

count=$(cat ${config} | grep dhcp_option | grep -c 6,${local_dns})
ping -c 1 -W 1 ${local_dns} > /dev/null 2>&1
if  [ $? -ne 0 ]; then
    logger -p err -t dns_server "local dns server ${local_dns} not working"
    if [ "${count}" -eq 1 ]; then
        uci del_list dhcp.lan.dhcp_option_force="6,${local_dns},${local_dns}" && \
        uci add_list dhcp.lan.dhcp_option_force="6,${google_dns},${google_dns}" && \
        uci commit dhcp && \
        /etc/init.d/network restart && \
        logger -p notice -t dns_server "set dns server to ${google_dns}"
    fi
else
    logger -p notice -t dns_server "local dns server ${local_dns} is working"
    if [ "${count}" -eq 0 ]; then
        uci del_list dhcp.lan.dhcp_option_force="6,${google_dns},${google_dns}" && \
        uci add_list dhcp.lan.dhcp_option_force="6,${local_dns},${local_dns}" && \
        uci commit dhcp && \
        /etc/init.d/network restart && \
        logger -p notice -t dns_server "set dns server to ${local_dns}"
    fi
fi
