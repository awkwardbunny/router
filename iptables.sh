#!/bin/bash

# Don't drop any connections when clearing table below
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

# Clear all
iptables -F
iptables -F -t nat

############################ PUBLIC RULES ############################
# Allow SSH
iptables -A INPUT -i eth0 -p tcp -m state --state NEW --dport 22 -j ACCEPT

# Allow returning traffic
iptables -A INPUT -i eth0 -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Set default policies
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow ICMP ping
iptables -A INPUT -p icmp -m state --state NEW --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow OpenVPN on 1194/UDP
#iptables -A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED,RELATED --dport 1194 -j ACCEPT

############################ VPN RULES ############################
# Route TUN to the Internet
#iptables -A FORWARD -i thom0 -o eth0 -j ACCEPT
#iptables -A POSTROUTING -t nat -s 10.1.1.0/24 -o eth0 -j MASQUERADE

# Allow returning traffic
iptables -A FORWARD -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS return (UDP)
iptables -A FORWARD -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

# Allow ICMP ping return
iptables -A FORWARD -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow NTP return
iptables -A FORWARD -p udp --sport 123 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept all internal traffic
iptables -A INPUT -i thom0 -j ACCEPT
iptables -A FORWARD -i thom0 -o tun+ -j ACCEPT

# Allow forwarded SSH
#iptables -A FORWARD -i eth0 -o tun+ -p tcp --dport 22 -m state --state NEW -j ACCEPT

# Nyquist SSH Forwarding
#iptables -t nat -A PREROUTING -p tcp --dport 5250 -j DNAT --to 10.8.0.2:22

# Totem SSH Forwarding
#iptables -t nat -A PREROUTING -p tcp --dport 5251 -j DNAT --to 10.8.0.4:22

# Allow forwarded HTTP/S
iptables -A FORWARD -i eth0 -o thom0 -p tcp --dport 80 -m state --state NEW -j ACCEPT
iptables -A FORWARD -i eth0 -o thom0 -p tcp --dport 443 -m state --state NEW -j ACCEPT
iptables -A FORWARD -i eth0 -o thom0 -p tcp --dport 8080 -m state --state NEW -j ACCEPT

# Totem HTTP Forwarding
#iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to 10.8.0.3:8080

# Dave HTTP/S Forwarding
#iptables -t nat -A PREROUTING  -i eth0 -p tcp --dport 80 -j DNAT --to 10.8.0.4:80
#iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to 10.8.0.4:443

# Pete RTMP Forwarding
#iptables -t nat -A PREROUTING  -i eth0 -p tcp --dport 1935 -j DNAT --to 10.8.0.5:1935
#iptables -A FORWARD -i eth0 -o tun+ -p tcp --dport 1935 -m state --state NEW -j ACCEPT

################################# ETC ##################################

# Allow loopback and reject anything from not lo
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A OUTPUT -o lo -j ACCEPT
#iptables -A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT

# Drop external packets to lo
#iptables -A INPUT -i eth0 -s 127.0.0.0/8 -j DROP
#iptables -A FORWARD -i eth0 -s 127.0.0.0/8 -j DROP
#iptables -A INPUT -i eth0 -d 127.0.0.0/8 -j DROP
#iptables -A FORWARD -i eth0 -d 127.0.0.0/8 -j DROP
#
## Anything coming from the Internet should have a real Internet address
#iptables -A FORWARD -i eth0 -s 192.168.0.0/16 -j DROP
#iptables -A FORWARD -i eth0 -s 172.16.0.0/16 -j DROP
#iptables -A FORWARD -i eth0 -s 10.0.0.0/8 -j DROP
#iptables -A INPUT -i eth0 -s 192.168.0.0/16 -j DROP
#iptables -A INPUT -i eth0 -s 172.16.0.0/16 -j DROP
#iptables -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP

# Allow HTTP/HTTPS
#iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED,RELATED --dport 80 -j ACCEPT
#iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED,RELATED --dport 443 -j ACCEPT

# Allow TUN interface
#iptables -A INPUT -i tun+ -j ACCEPT
#iptables -A FORWARD -i tun+ -j ACCEPT
#iptables -A OUTPUT -o tun+ -j ACCEPT
#iptables -A FORWARD -o tun+ -j ACCEPT

# Log any packets that don't match above
iptables -A INPUT -m limit --limit 60/min -j LOG --log-prefix "iptbls_IN_denied: " --log-level 4
iptables -A FORWARD -m limit --limit 60/min -j LOG --log-prefix "iptbls_FWD_denied: " --log-level 4

# Save
iptables-save > /etc/iptables/rules.v4
