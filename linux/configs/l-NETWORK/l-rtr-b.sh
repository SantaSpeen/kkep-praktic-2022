HS="/etc/hostname"
rm $HS; touch $HS
echo "L-RTR-B" >> $HS
H="/etc/hosts"; rm $H; touch $H
echo -e "# ${H} file.\n# Configured by Maxim\n\n" >> $H
echo -e "# Default values\n127.0.0.1\tlocalhost\n::1\tip6-localhots ip6-loopback\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters\n" >> $H
echo -e "# Work values\n172.16.20.10\tl-srv l-srv.skill39.wsr\n10.10.10.1\tl-fw l-fw.skill39.wsr\n172.16.50.2\tl-rtr-a l-rtr-a.skill39.wsr\n172.16.55.2\tl-rtr-b l-rtr-b.skill39.wsr\n172.16.200.61\tl-cli-b l-cli-b.skill39.wsr\n20.20.20.5\tout-cli out-cli.skill39.wsr\n20.20.20.100\tr-fw r-fw.skill39.wsr\n192.168.20.10\tr-srv r-srv.skill39.wsr\n192.168.10.2\tr-rtr r-rtr.skill39.wsr\n192.168.100.100\tr-cli r-cli.skill39.wsr">> $H 
echo -e "10.10.10.10\tisp" >> $H
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
iptables -F 
apt-cdrom add

apt install frr tcpdump ssh nfs-common network-manager curl lynx net-tools vim bind9utils cifs-utils -y

sed -ie "s/^hosts:\t*/hosts:\t\tdns files [NOTFOUND=return] # old:/" /etc/nsswitch.conf
SSHC="/etc/ssh/sshd_config"
cp $SSHC $SSHC.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSHC

systemctl start NetworkManager
nmcli con add con-name ens192 ifname ens192 autoconnect yes type ethernet ip4 172.16.55.2/30 gw4 172.16.55.1
nmcli con mod ens192 +ipv4.dns 172.16.20.10 +ipv4.dns 192.168.20.10 +ipv4.dns-search "skill39.wsr"
nmcli con up ens192 ifname ens192
nmcli con add con-name ens224 ifname ens224 autoconnect yes type ethernet ip4 172.16.200.1/24 
nmcli con mod ens224 +ipv4.dns 172.16.20.10 +ipv4.dns 192.168.20.10 +ipv4.dns-search "skill39.wsr"
nmcli con up ens224 ifname ens224

systemctl stop frr; systemctl disable frr;
sed -ie 's/ospfd=no/ospfd=yes/' /etc/frr/daemons; 
sed -ie 's/zebra=no/zebra=yes/' /etc/frr/daemons; 
systemctl start frr; systemctl enable frr;

vtysh
conf t
	router ospf    
		network 172.16.55.0/30 area 0    
		network 172.16.200.0/24 area 0
		passive-interface ens224
		exit
	exit
write
exit

apt install isc-dhcp-relay -y

# 172.16.50.2
# ens192 ens224

systemctl disable chronyd ; systemctl stop chronyd
shutdown -r 0

