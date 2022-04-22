HS="/etc/hostname"
sh -c "rm $HS"; touch $HS
echo "R-FW" >> $HS
H="/etc/hosts"; rm $H; touch $H
echo -e "# ${H} file.\n# Configured by Maxim\n\n" >> $H
echo -e "# Default values\n127.0.0.1\tlocalhost\n::1\tip6-localhots ip6-loopback\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters\n" >> $H
echo -e "# Work values\n172.16.20.10\tl-srv l-srv.skill39.wsr\n10.10.10.1\tl-fw l-fw.skill39.wsr\n172.16.50.2\tl-rtr-a l-rtr-a.skill39.wsr\n172.16.55.2\tl-rtr-b l-rtr-b.skill39.wsr\n172.16.200.61\tl-cli-b l-cli-b.skill39.wsr\n20.20.20.5\tout-cli out-cli.skill39.wsr\n20.20.20.100\tr-fw r-fw.skill39.wsr\n192.168.20.10\tr-srv r-srv.skill39.wsr\n192.168.10.2\tr-rtr r-rtr.skill39.wsr\n192.168.100.100\tr-cli r-cli.skill39.wsr">> $H 
echo -e "20.20.20.10\tisp" >> $H
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
setenforce 0
sed -ie 's/SELINUX=enforcing /SELINUX=permissive/' /etc/selinux/config; 
systemctl stop firewalld && systemctl disable firewalld

cd /media/; rm -rf *
mkdir CentOS; mkdir cdrom
cd /etc/
mv yum.repos.d/ yum.repos.d-default/; mkdir yum.repos.d
REPF="/etc/yum.repos.d/CentOS-Media.repo"
touch $REPF
echo -e "# ${REPF} file.\n# Configured by Maxim\n\n[c7-media]\nname=CentOS-$releasever - Media\nbaseurl=file:///media/CentOS/\n\t\tfile:///media/cdrom/\ngpgcheck=1\nenabled=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"  >> $REPF
mount -L "CentOS 7 x86_64" /media/CentOS
mount -L "CDROM" /media/cdrom

yum install lynx vim net-tools dhclient bash-completion tcpdump curl nfs-utils cifs-utils sshpass bind-utils -y

sed -ie "s/^hosts:\t*/hosts:\t\tdns files [NOTFOUND=return] # old:/" /etc/nsswitch.conf
SSHC="/etc/ssh/sshd_config"
cp $SSHC $SSHC.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSHC

nmcli con del id ens192
nmcli con del id ens224
nmcli con del id ens160
nmcli con del id gre1

nmcli con add con-name ens192 ifname ens192 autoconnect yes type ethernet ip4 "192.168.10.1/30"
nmcli con mod ens192 +ipv4.dns 172.16.20.10 +ipv4.dns 192.168.20.10 +ipv4.dns-search "skill39.wsr"
nmcli con add con-name ens224 ifname ens224 autoconnect yes type ethernet ip4 "192.168.20.1/24"
nmcli con mod ens224 +ipv4.dns 172.16.20.10 +ipv4.dns 192.168.20.10 +ipv4.dns-search "skill39.wsr"
nmcli con add con-name ens160 ifname ens160 autoconnect yes type ethernet ip4 "20.20.20.100/24" gw4 20.20.20.10
nmcli con mod ens160 +ipv4.dns 172.16.20.10 +ipv4.dns 192.168.20.10 +ipv4.dns-search "skill39.wsr"
nmcli con add type ip-tunnel ip-tunnel.mode gre con-name gre1 ifname gre1 autoconnect yes remote 10.10.10.1 local 20.20.20.100
nmcli con mod gre1 ipv4.method manual +ipv4.addresses "10.5.5.2/30" 
nmcli con mod gre1 ip-tunnel.ttl 64

nmcli con up ens192 ifname ens192
nmcli con up ens224 ifname ens224
nmcli con up ens160 ifname ens160
nmcli con up gre1 ifname gre1

yum install /media/cdrom/lib* /media/cdrom/frr* -y

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh
conf t
	ip forw
	router ospf
		network 192.168.10.0/30 area 0
		network 192.168.20.0/24 area 0 
		network 10.5.5.0/30 area 0
		network 5.5.5.0/27 area 0
		passive-interface ens160
		passive-interface ens224
		exit
	exit
write
exit
systemctl disable chronyd ; systemctl stop chronyd
shutdown -r 0

