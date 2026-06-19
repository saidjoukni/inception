#!/bin/bash
set -e

read_secret() {
    if [ ! -f "$1" ]; then
        echo "Missing secret file: $1" >&2
        exit 1
    fi
    tr -d '\r\n' < "$1"
}

FTP_PASSWORD="$(read_secret "${FTP_PASSWORD_FILE:-/run/secrets/ftp_password}")"

# 1. Create the user ONLY if it doesn't exist (Identity Management)
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating FTP user..."
    useradd -o -u 33 -g 33 -d /var/www/html "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
chown -R "$FTP_USER:www-data" /var/www/html

# 2. ALWAYS generate the userlist file on every boot (Volatile Config)
echo "$FTP_USER" > /etc/vsftpd.userlist

# 3. ALWAYS configure vsftpd configuration on every boot
cat << EOF > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
EOF

# 4. ALWAYS create the runtime secure directory
mkdir -p /var/run/vsftpd/empty

# 5. Start the FTP server (PID 1)
exec /usr/sbin/vsftpd /etc/vsftpd.conf
