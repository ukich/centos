#!/bin/bash/
#
#Объявляем переменные
#EXPORT IPT = "ipatbles"

#Обозначаем интерфейсы
export WAN=enp5s6
export WAN_ADDR=213.79.112.99
export LAN=enp4s0

#Очищаем цепочки
iptables -F
iptables -F -t nat
iptables -F -t mangle
iptables -X 
iptables -t nat -X
iptables -t mangle -X

#разрешаем локальный трафик в рамках сервера
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Разрешаем исходящий трафик для сервера
iptables -A OUTPUT -o $WAN -j ACCEPT

#Осталяем уже существующие соединения и дочернии от них
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Разрешаем форвардинг уже существующих соединений
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#Включаем фрагментацию пакетов
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

#обрубаем направильные пакеты
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

#Делаем защиту от Dos атак
#Защита от SYN-flood
iptables -A INPUT -p tcp --syn -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

#Защита от сканеров портов
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j DROP

#Защита от Ping of death
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

#Открываем нужные порты
#SSH
iptables -A INPUT -p tcp -i $LAN --dport 22 -j ACCEPT
#DNS
iptables -A INPUT -p udp --dport 53 -j ACCEPT
#ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
#ИЛИ
#iptables -A INPUT -i $WAN -p icmp -m icmp --icmp-type 3 -j ACCEPT
#iptables -A INPUT -i $WAN -p icmp -m icmp --icmp-type 11 -j ACCEPT
#iptables -A INPUT -i $WAN -p icmp -m icmp --icmp-type 12 -j ACCEPT

#Закрываем порты в NAT'e
#iptables -A FORWARD -p tcp --dport 25 -s 192.168.0.6 -o $WAN -j DROP

#NAT
#Открываем только порты 22,53,80,110,443,
iptables -A FORWARD -i $LAN -o $WAN -p tcp -m multiport --dport 22,80,53,110,443 -s 192.168.0.0/24 -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -p udp --dport 53 -s 192.168.0.0/24 -j ACCEPT
iptables -A FORWARD -i $WAN -o $LAN -d 192.168.0.0/24 -j ACCEPT 
iptables -A POSTROUTING -t nat -s 192.168.0.0/24 -o $WAN -j SNAT --to-source $WAN_ADDR





#создаем правила по умолчанию
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP