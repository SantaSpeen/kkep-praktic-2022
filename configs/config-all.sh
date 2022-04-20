# !!!!! 
# VMWare не может вставить русские буквы, так что исключайте их при копировании
# !!!!!

# План работы
# hostnames -> hosts -> apt/yum -> ip -> gre -> frr -> dhcp -> dhcp-relay ->
# -> primary DNS -> DDNS -> secondary DNS  

# File version: 2.0
CONFIG_FILE_VERSION="2.0"

HOSTS="/etc/hosts"; rm $HOSTS; touch $HOSTS
echo -e "# ${HOSTS} file.\n# Configured by Maxim; v${CONFIG_FILE_VERSION}\n\n" >> $HOSTS
echo -e "# Default values\n127.0.0.1\tlocalhost\n::1\tip6-localhots ip6-loopback\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters\n" >> $HOSTS
echo -e "# Work values\n172.16.20.10\tl-srv l-srv.skill39.wsr\n10.10.10.1\tl-fw l-fw.skill39.wsr\n172.16.50.2\tl-rtr-a l-rtr-a.skill39.wsr\n172.16.55.2\tl-rtr-b l-rtr-b.skill39.wsr\n172.16.200.61\tl-cli-b l-cli-b.skill39.wsr\n20.20.20.5\tout-cli out-cli.skill39.wsr\n20.20.20.100\tr-fw r-fw.skill39.wsr\n192.168.20.10\tr-srv r-srv.skill39.wsr\n192.168.10.2\tr-rtr r-rtr.skill39.wsr\n192.168.100.100\tr-cli r-cli.skill39.wsr">> $HOSTS 

cat $HOSTS

# echo -e "20.20.20.10\tisp" >> $HOSTS	# Organisation RIGHT
# echo -e "10.10.10.10\tisp" >> $HOSTS	# Organisation LEFT

# Для смены порядка чтения "DNS"

sed -ie "s/^hosts:\t*/hosts:\t\tdns files [NOTFOUND=return] # old:/" /etc/nsswitch.conf

SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG $SSH_CONFIG.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSH_CONFIG
systemctl restart ssh.service

# Эта настройка для FW и RTR 

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf; shutdown -r 0

# Настройка debian 

apt-cdrom add
apt-get install tcpdump bind9 ssh nfs-common network-manager curl lynx net-tools vim bind9utils cifs-utils -y

# CentOS yum repo Config

cd /media/
sh -c "rm -rf *"
mkdir CentOS
mkdir cdrom

cd /etc/

mkdir yum.repos.d-default/
mv ./yum.repos.d/CentOS* ./yum.repos.d-default/

cd yum.repos.d/
sh -c "rm -rf *"
REPO_FILE="/etc/yum.repos.d/CentOS-Media.repo"
touch $REPO_FILE

echo -e "# ${REPO_FILE} file.\n# Configured by Maxim; v${CONFIG_FILE_VERSION}\n" >> $REPO_FILE
echo "[c7-media]"  >> $REPO_FILE
echo -e "name=CentOS-$releasever - Media"  >> $REPO_FILE
echo "baseurl=file:///media/CentOS/"  >> $REPO_FILE
echo -e "\t\tfile:///media/cdrom/"  >> $REPO_FILE
echo "gpgcheck=1"  >> $REPO_FILE
echo "enabled=1"  >> $REPO_FILE
echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"  >> $REPO_FILE

cat $REPO_FILE

# Проверить устройства можно командой blkid
# Имя образа будет указано в lable="<ISO-NAME>"

# /dev/sr0 Это [datastore1] _ISO/Additional.iso
# /dev/sr1 Это [datastore1] _ISO/CentOS-7-x86_64-DVD-1810.iso

mount -L "CDROM" /media/cdrom
mount -L "CentOS 7 x86_64" /media/CentOS

yum install lynx vim net-tools dhclient bash-completion tcpdump curl nfs-utils cifs-utils sshpass bind-utils libcares* -y

# firewall вырубить на всех, кроме R-FW

systemctl stop firewalld && systemctl disable firewalld
# systemctl start firewalld && systemctl enable firewalld

# R-FW

firewall-cmd --permanent --zone=external --add-service=gre
firewall-cmd --permanent --zone=external --add-interface=ens160
firewall-cmd --permanent --zone=trusted --add-interface=ens192
firewall-cmd --permanent --zone=trusted --add-interface=ens224
firewall-cmd --permanent --zone=trusted --add-interface=gre1

firewall-cmd --reload

# firewall-cmd --permanent --zone=external --add-masquerade
# firewall-cmd --permanent --zone=trusted --add-interface=tunnel
# firewall-cmd --permanent --zone=external --add-forward-port=port=80:proto=tcp:toport=80:toaddr=192.168.20.10
# firewall-cmd --permanent --zone=external --add-service=http
# firewall-cmd --permanent --zone=external --add-service=https
# firewall-cmd --permanent --zone=external --add-service=ssh

# L-FW

# iptables методичка
# -A - добавить правило в цепочку;
# -С - проверить все правила;
# -D - удалить правило;
# -I - вставить правило с нужным номером;
# -L - вывести все правила в текущей цепочке;
# -S - вывести все правила;
# -F - очистить все правила;
# -N - создать цепочку;
# -X - удалить цепочку;
# -P - установить действие по умолчанию.
# -s - указать ip адрес устройства-отправителя пакета;
# -d - указать ip адрес получателя;
# -i - входной сетевой интерфейс;
# -o - исходящий сетевой интерфейс;
# -j - выбрать действие, если правило подошло.

# P:
# INPUT - Входящие паекты
# OUTPUT - Исходящие пакеты
# FORWARD - Паокеты пересылки

# j:
# ACCEPT - разрешить прохождение пакета дальше по цепочке правил;
# DROP - удалить пакет;
# REJECT - отклонить пакет, отправителю будет отправлено сообщение, что пакет был отклонен;
# LOG - сделать запись о пакете в лог файл;
# QUEUE - отправить пакет пользовательскому приложению.
# REDIRECT - Перенаправлять на ...
# ...

# t:
# raw - предназначена для работы с сырыми пакетами, пока они еще не прошли обработку;
# mangle - предназначена для модификации пакетов;
# nat - обеспечивает работу nat, если вы хотите использовать компьютер в качестве маршрутизатора;
# filter - основная таблица для фильтрации пакетов, используется по умолчанию.

apt install iptables-persistent -y 

# Reset rules
iptables -F 
iptables -t nat -F
iptables -t mangle -F
iptables -t filter -F

# Default rules
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# iptables -t nat -A PREROUTING -i ens256 -p udp --dport 53 -j DNAT --to-destination 172.16.20.10
iptables -t nat -A POSTROUTING -o ens256 -j MASQUERADE
iptables -t nat -A PREROUTING -i ens256 -j DNAT --to-destination 172.16.20.10


echo "AllowUsers ssh_p root ssh_c" >> /etc/ssh/sshd_config

adduser ssh_p
# p_hss

adduser ssh_c
# c_hss

apt install frr -y

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh

# frr config
conf t 
	ip forw
	router ospf    
		network 172.16.20.0/24 area 0    
		network 172.16.50.0/30 area 0    
		network 172.16.55.0/30 area 0    
		network 10.5.5.0/30 area 0    
		network 5.5.5.0/27 area 0    
		passive-interface ens160
		passive-interface ens256
		exit
	exit
write
exit


# L-RTR-A

apt install frr

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh

# frr config
conf t 
	ip forw
	router ospf    
		network 172.16.50.0/30 area 0
		network 172.16.100.0/24 area 0
		passive-interface esn224
		exit
	exit
write
exit

apt install isc-dhcp-server -y

# Пишем интерфейсы
nano /etc/default/isc-dhcp-server

nano /etc/dhcp/dhcpd.conf
# ( Файл находится в этой директории )

# Включаем isc-dhcp-server и переагружаем
systemctl start isc-dhcp-server && systemctl enable isc-dhcp-server; shutdown -r 0

# L-RTR-B

apt install frr

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh

# frr config
conf t 
	ip forw
	router ospf    
		network 172.16.55.0/30 area 0    
		network 172.16.200.0/24 area 0
		passive-interface ens224
		exit
	exit
write
exit

apt install isc-dhcp-relay

# R-FW

yum install /media/cdrom/lib* /media/cdrom/frr* -y

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh

# frr config
conf t
	ip forwarding
	router ospf
		network 192.168.20.0/24 area 0    
		network 192.168.10.0/30 area 0    
		network 10.5.5.0/30 area 0    
		network 5.5.5.0/27 area 0
		passive-interface ens160
		passive-interface ens224
		exit
	exit
write
exit

# R-RTR

yum install /media/cdrom/lib* /media/cdrom/frr* -y

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh

# frr config
conf t
	ip forwarding
	router ospf
		network 192.168.10.0/30 area 0
		network 192.168.100.0/24 area 0
		passive-interface ens192
		exit
	exit
write
exit

# L-SRV

apt install bind9
nano /etc/bind/named.conf.options

# // /etc/bind/named.conf.options file
# options {
# 	directory "/var/cache/bind";   
# 	forwarders { 10.10.10.10; };   
# 	dnssec-validation no;
# 	listen-on-v6 { none; };
# 	recursion yes;
# };

mkdir /opt/dns
cp /etc/bind/db.local /opt/dns/skill39.db
cp /etc/bind/db.127 /opt/dns/db.172
cp /etc/bind/db.127 /opt/dns/db.192
chown -R bind:bind /opt/dns

nano /etc/apparmor.d/usr.sbin.named

# /opt/dns/** rw,

systemctl restart apparmor.service

nano /etc/bind/named.conf.default-zones

# zone "skill39.wsr" {
# 	type master;
# 	allow-transfer { any; };
# 	allow-update { 172.16.50.2; };
# 	recursion yes;
# 	file "/opt/dns/skill39.db";
# };
# zone "16.172.in-addr.arpa" { 
# 	type master; 
# 	allow-transfer { any; };
# 	allow-update { 172.16.50.2; };
# 	file "/opt/dns/db.172";
# };
# zone "168.192.in-addr.arpa" { 
# 	type master; 
# 	allow-transfer { any; }; 
# 	file "/opt/dns/db.192";
# };

nano /opt/dns/skill39.db
# ( Файл находится в этой директории )

nano /opt/dns/db.172
# ( Файл находится в этой директории )

nano /opt/dns/db.192
# ( Файл находится в этой директории )

systemctl restart bind9

# R-SRV

# Disable SELinux
setenforce 0
sed -ie 's/SELINUX=enforcing /SELINUX=permissive/' /etc/selinux/config; 
getenforce

yum install bind

mkdir /opt/dns
chown named:named /opt/dns
