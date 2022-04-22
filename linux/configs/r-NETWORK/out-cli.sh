HS="/etc/hostname"
sh -c "rm $HS"; touch $HS
echo "OUT-CLI" >> $HS
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
mount -L "CentOS 7 x86_64" /media/CentOS; mount -L "CDROM" /media/cdrom

yum install lynx vim net-tools dhclient bash-completion tcpdump curl nfs-utils cifs-utils sshpass bind-utils -y

sed -ie "s/^hosts:\t*/hosts:\t\tdns files [NOTFOUND=return] # old:/" /etc/nsswitch.conf
SSHC="/etc/ssh/sshd_config"
cp $SSHC $SSHC.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSHC
nmcli con del id ens32
nmcli con add con-name ens32 ifname ens32 autoconnect yes type ethernet ip4 "20.20.20.5/24" gw4 20.20.20.5
nmcli con mod ens32 +ipv4.dns 10.10.10.1 +ipv4.dns 20.20.20.100 +ipv4.dns-search "skill39.wsr"
nmcli con up ens32 ifname ens32

systemctl disable chronyd ; systemctl stop chronyd
shutdown -r 0

