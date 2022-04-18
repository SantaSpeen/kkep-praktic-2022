SSH_CONFIG="/etc/ssh/sshd_config"

echo "Port 22" >> $SSH_CONFIG
echo "ListenAddress 0.0.0.0" >> $SSH_CONFIG
echo "PasswordAuthentication yes" >> $SSH_CONFIG
echo "PermitEmptyPasswords no" >> $SSH_CONFIG
echo "ChallengeResponseAuthentication no" >> $SSH_CONFIG
echo "UsePAM yes" >> $SSH_CONFIG
echo "X11Forwarding no" >> $SSH_CONFIG
echo "PrintMotd no" >> $SSH_CONFIG
echo "AcceptEnv LANG LC_*" >> $SSH_CONFIG
echo -e "Subsystem\tsftp\t/usr/lib/openssh/sftp-server" >> $SSH_CONFIG
