#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/sbin
export LANG="zh_CN.GB18030"
function inst-epel-release(){
  yum install -y inst-epel-release
}
function start(){
  #echo "hello"
  rpm -qa |grep epel-release

  if [ $? -ne 0  ]
  then 
    inst-epel-release
  fi

  rpm -qa |grep python-pip

  if [  $? -ne  0 ]
  then
    yum isntall -y python-pip
    pip install shadowsocks
  fi
  rpm -qa |grep privoxy
  if [ $? -ne 0 ]
  then
    yum install -y privoxy
  fi
  if [ ! -d "/etc/shadowsocks" ]
  then
    echo "文不存在，开始创建文件"
    mkdir -p /etc/shadowsocks
    cat /dev/null >/etc/shadowsocks/shadowsocks.json
    touch /etc/shadowsocks/shadowsocks.json
    cat >>/etc/shadowsocks/shadowsocks.json<<EOF
{
    "server":"你的服务器IP",
    "server_port":服务器端口,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"你的密码",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}
EOF
  fi
  
  if [ ! -f "/etc/systemd/system/shadowsocks.service" ]
  then
    echo " 文件不存在"
    touch /etc/systemd/system/shadowsocks.service
    cat >> /etc/systemd/system/shadowsocks.service <<EOF
[Unit]
Description=Shadowsocks
[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/sslocal -c /etc/shadowsocks/shadowsocks.json
[Install]
WantedBy=multi-user.target
EOF
  fi
  
systemctl enable shadowsocks.service
sleep 2
systemctl start shadowsocks.service
sleep 2
systemctl status shadowsocks.service
sleep 1

curl --socks5 127.0.0.1:1080 http://httpbin.org/ip
if [ $? -eq 0 ]
then
    echo "yes start"
else
    echo "no start"
fi

sleep 2
systemctl enable privoxy
sleep 2
systemctl start privoxy
sleee 2
systemctl status privoxy
cat /etc/privoxy/config |grep "forward-socks5t / 127.0.0.1:1080 ."
if [ $? -ne 0 ]
then
  echo "forward-socks5t / 127.0.0.1:1080 .">>/etc/privoxy/config
fi
cat /etc/profile |grep "PROXY_HOST=127.0.0.1"
if [ $? -eq 0  ]
then
    echo "Already exist"
else
    echo "no exist"
cat >> /etc/profile << EOF
PROXY_HOST=127.0.0.1
export all_proxy=http://\$PROXY_HOST:8118
export ftp_proxy=http://\$PROXY_HOST:8118
export http_proxy=http://\$PROXY_HOST:8118
export https_proxy=http://\$PROXY_HOST:8118
export no_proxy=localhost,172.16.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16
EOF
fi
source /etc/profile
echo $?
#curl www.google.com >/etc/null
curl www.google.com >/dev/null 2>&1
if [ $? -eq 0 ]
then
  #action "/etc/security/limits.conf" /bin/true
  echo "可以上网"
else
  #action "/etc/security/limits.conf" /bin/false
  echo "不能上网"
fi
}
function stop(){
  while read var;do
  unset $var
  done < <(env | grep -i proxy | awk -F= '{print $1}')
}
function restart(){
  systemctl enable shadowsocks.service
  sleep 2
  systemctl restart shadowsocks.service
  sleep 2
  systemctl status shadowsocks.service
  sleep 2
  if [ $? -eq 0 ]
  then
    action "/etc/security/limits.conf" /bin/true
    echo "重启成功！开始浪吧"
  else
    echo "重启失败，尝试start！"
    action "/etc/security/limits.conf" /bin/false
  fi
}
case "$1" in
  start)
    start
    echo $?
    ;;
  stop)
    stop
    echo $?
    ;;
  restart)
    restart
    echo $?
    ;;
esac
