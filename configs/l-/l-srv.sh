HS="/etc/hostname"
rm $HS; touch $HS
echo "L-SRV" >> $HS
H="/etc/hosts"; rm $H; touch $H
echo -e "# ${H} file.\n# Configured by Maxim\n\n" >> $H
echo -e "# Default values\n127.0.0.1\tlocalhost\n::1\tip6-localhots ip6-loopback\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters\n" >> $H
echo -e "# Work values\n172.16.20.10\tl-srv l-srv.skill39.wsr\n10.10.10.1\tl-fw l-fw.skill39.wsr\n172.16.50.2\tl-rtr-a l-rtr-a.skill39.wsr\n172.16.55.2\tl-rtr-b l-rtr-b.skill39.wsr\n172.16.200.61\tl-cli-b l-cli-b.skill39.wsr\n20.20.20.5\tout-cli out-cli.skill39.wsr\n20.20.20.100\tr-fw r-fw.skill39.wsr\n192.168.20.10\tr-srv r-srv.skill39.wsr\n192.168.10.2\tr-rtr r-rtr.skill39.wsr\n192.168.100.100\tr-cli r-cli.skill39.wsr">> $H 
echo -e "10.10.10.10\tisp" >> $H
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
iptables -F 
apt-cdrom add

apt-get install tcpdump bind9 ssh nfs-common network-manager curl lynx net-tools vim bind9utils cifs-utils -y

sed -ie "s/^hosts:\t*/hosts:\t\tdns files [NOTFOUND=return] # old:/" /etc/nsswitch.conf
SSHC="/etc/ssh/sshd_config"
cp $SSHC $SSHC.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSHC

nmcli con del id ens192
nmcli con add con-name ens192 ifname ens192 autoconnect yes type ethernet ip4 172.16.20.10/24 gw4 172.16.20.1
nmcli con mod ens192 +ipv4.dns 172.16.20.10 +ipv4.dns 192.168.20.10 +ipv4.dns-search "skill39.wsr"
nmcli con up ens192 ifname ens192

systemctl disable chronyd ; systemctl stop chronyd
shutdown -r 0

