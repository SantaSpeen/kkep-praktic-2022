# !!!!! 
# VMWare не может вставить русские буквы, так что исключайте их при копировании
# !!!!!

# Для смены порядка чтения "DNS"

nano /etc/nsswitch.conf

# Ответы DNS сервера должны иметь более высокий приоритет.
# В строке, которая начинается с "hosts: ", меняем местами слова files и dns.

CONFIG_FILE_VERSION="1.1"

# HOSTS config

HOSTS="/etc/hosts"; rm $HOSTS; touch $HOSTS
echo -e "# ${HOSTS} file.\n# Configured by Maxim; v${CONFIG_FILE_VERSION}\n\n" >> $HOSTS
echo -e "# Default values\n127.0.0.1\tlocalhost\n::1\tip6-localhots ip6-loopback\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters\n" >> $HOSTS
echo -e "# Work values\n172.16.20.10\tl-srv l-srv.skill39.wsr\n10.10.10.1\tl-fw l-fw.skill39.wsr\n172.16.50.2\tl-rtr-a l-rtr-a.skill39.wsr\n172.16.55.2\tl-rtr-b l-rtr-b.skill39.wsr\n172.16.200.61\tl-cli-b l-cli-b.skill39.wsr\n20.20.20.5\tout-cli out-cli.skill39.wsr\n20.20.20.100\tr-fw r-fw.skill39.wsr\n192.168.20.10\tr-srv r-srv.skill39.wsr\n192.168.10.2\tr-rtr r-rtr.skill39.wsr\n192.168.100.100\tr-cli r-cli.skill39.wsr">> $HOSTS 
echo -e "20.20.20.10\tisp" >> $HOSTS

cat $HOSTS

# YUM config

cd /media/
sh -c "rm -rf *"
mkdir CentOS; mkdir cdrom
cd /etc/
mkdir yum.repos.d-default/
mv ./yum.repos.d/CentOS* ./yum.repos.d-default/
cd yum.repos.d/
sh -c "rm -rf *"
REPO_FILE="/etc/yum.repos.d/CentOS-Media.repo"
touch $REPO_FILE
echo -e "# ${REPO_FILE} file.\n# Configured by Maxim; v${CONFIG_FILE_VERSION}\n" >> $REPO_FILE
echo -e "[c7-media]\nname=CentOS-$releasever - Media\nbaseurl=file:///media/CentOS/\n\t\tfile:///media/cdrom/\ngpgcheck=1\nenabled=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"  >> $REPO_FILE

cat $REPO_FILE

# /dev/sr0 CentOS-7-x86_64-DVD-1810.iso
# /dev/sr1 Additional.iso

mount /dev/sr0 /media/CentOS
mount /dev/sr1 /media/cdrom

yum install lynx vim net-tools dhclient bash-completion tcpdump curl nfs-utils cifs-utils sshpass bind-utils -y
yum install zsh git -y

# SSH config

SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG $SSH_CONFIG.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSH_CONFIG
systemctl restart sshd.service
