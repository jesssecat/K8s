#!/bin/bash
systemctl status firewalld
if [ $? -eq 0  ]
then
    systemctl stop firewalld
    systemctl disable firewalld
fi
cat /etc/selinux/config |grep SELINUX=enforcing
if [ $? -eq 0 ]
then
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
fi
cat /etc/selinux/config |grep SELINUX=
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -L -n
