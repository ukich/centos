#!/bin/bash
#Настройка сети через псевдографику
#yum -y install NetworkManager-tui
nmtui &&
#Ставим ssh
yum -y install openssh && yum -y install openssh-server &&
#Отключаем firewallld и включаем iptables
systemctl stop firewalld &&
systemctl disable firewalld &&
yum update &&
yum -y install iptables-services &&
systemctl enable iptables &&
systemctl start iptables &&

#Разрешаем FORWARD
sysctl -w net.ipv4.ip_forward="1"

#Подключаем репозитарии
yum -y install epel-release &&
#Ставим mc
yum -y install mc &&

#Ставим и включаем fail2ban
yum install fail2ban &&
systemctl enable fail2ban &&
#Копируем файл настроек fail2ban
cp -iv jail.local /etc/fail2ban/jail.local

#Установим top'ы для мониторинга 
yum -y install iftop &&
yum -y install htop &&
yum -y install atop

