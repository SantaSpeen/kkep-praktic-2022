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
echo -e "10.10.10.10\tisp" >> $HOSTS

cat $HOSTS


# APT config

apt-cdrom add
apt install tcpdump bind9 ssh nfs-common network-manager curl lynx net-tools vim bind9utils cifs-utils -y
apt install zsh git -y

# SSH config

SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG $SSH_CONFIG.old
sed -ie 's/#PermitRoot.*/PermitRootLogin yes/' $SSH_CONFIG
systemctl restart ssh.service

