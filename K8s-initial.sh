#!/bin/bash
timedatectl set-timezone Asia/Shanghai
touch /etc/yum.repos.d/kubernetes.repo

cat << EOF >/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes Repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
enabled=1
EOF

cat /etc/hosts |grep 192

if [ $? -ne 0 ]
then 
cat << EOF >>/etc/hosts
192.168.205.10	master.com   master
192.168.205.20  node1.com    node1
192.168.205.30  node2.com    node2
192.168.205.40  node3.com    node3
EOF
fi

wget -P /etc/yum.repos.d/ https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

wget -P /etc/yum.repos.d/ https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg

rpm --import /etc/yum.repos.d/yum-key.gpg

yum install -y docker-ce kubelet kubeadm kubectl

sed -i '8i\Environment="HTTPS_PROXY=http://www.ik8s.io:10080"' /usr/lib/systemd/system/docker.service

systemctl daemon-reload

systemctl start docker
systemctl start kubelet

echo KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\" >/etc/sysconfig/kubelet

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward

systemctl enable docker kubelet
