# R-SRV

apt install bind9

NAMED_CONF="/etc/bind/named.conf.options"
rm $NAMED_CONF; touch $NAMED_CONF; chown -R bind:bind $NAMED_CONF
echo -e "\n// /etc/bind/named.conf.options file;\n// Configured by Maxim;\n\noptions {\n\tdirectory \"/var/cache/bind\";\n\tforwarders { 10.10.10.10; };\n\tdnssec-validation no;\n\tlisten-on-v6 { none; };\n};" >> $NAMED_CONF

nano /etc/apparmor.d/usr.sbin.named
# /opt/dns/** rw,

DEFAULT_ZONES="/etc/bind/named.conf.default-zones"

echo -e "\nzone \"skill39.wsr\" {\n\ttype master;\n\tallow-transfer { any; };\n\tfile \"/opt/dns/skill39.db\";\n};\n" >> $DEFAULT_ZONES
echo -e "zone \"16.172.in-addr.arpa\" {\n\ttype master;\n\tallow-transfer { any; };\n\tfile \"/opt/dns/db.172\";\n};\n" >> $DEFAULT_ZONES
echo -e "zone \"168.192.in-addr.arpa\" {\n\ttype master; \n\tallow-transfer { any; };\n\tfile \"/opt/dns/db.192\";\n};\n" >> $DEFAULT_ZONES

mkdir /opt/dns
chown -R bind:bind /opt/dns

SKILLDB="/opt/dns/skill39.db"
rm $SKILLDB; touch $SKILLDB; chown -R bind:bind $SKILLDB
echo -e "" >> %SKILLDB

DB172="/opt/dns/db.172"
rm $DB172; touch $DB172; chown -R bind:bind $DB172
echo -e "" >> %DB172

DB192="/opt/dns/db.192"
rm $DB192; touch $DB192; chown -R bind:bind $DB192
echo -e "" >> %DB192

systemctl restart apparmor.service
systemctl restart bind9
