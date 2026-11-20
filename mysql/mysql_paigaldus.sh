#!/bin/bash
# MySQL 8.0 server paigaldus (Debian 12, Oracle APT repositoorium)

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "VIGA: käivita skript root õigustes (sudo)."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

APT_DEB="mysql-apt-config_0.8.40-1_all.deb"
URL="https://dev.mysql.com/get/$APT_DEB"
ROOT_PASS="qwerty"

echo "=== MySQL paigaldus ==="

if dpkg -l mysql-community-server 2>/dev/null | grep -q '^ii'; then
    echo "MySQL on juba paigaldatud: $(mysql --version)"
else
    if dpkg -l | grep -qE '^ii\s+mariadb-server'; then
        echo "VIGA: MariaDB on paigaldatud ja on MySQL-iga vastuolus. Eemalda see enne (apt purge 'mariadb-*')."
        exit 1
    fi

    echo "MySQL puudub, paigaldan..."
    apt-get update -qq
    apt-get install -y gnupg ca-certificates debconf-utils wget

    # Vastused mysql-apt-config paketi küsimustele
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
    echo "mysql-apt-config mysql-apt-config/select-tools select Disabled"   | debconf-set-selections
    echo "mysql-apt-config mysql-apt-config/select-product select Ok"       | debconf-set-selections

    # Vastused mysql-community-server paigaldusele
    echo "mysql-community-server mysql-community-server/root-pass password $ROOT_PASS"    | debconf-set-selections
    echo "mysql-community-server mysql-community-server/re-root-pass password $ROOT_PASS" | debconf-set-selections
    echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections

    # Oracle APT repo
    wget -q -O "/tmp/$APT_DEB" "$URL"
    dpkg -i "/tmp/$APT_DEB"
    apt-get update -qq
    apt-get install -y mysql-server

    systemctl enable --now mysql
fi

# .my.cnf paroolivaba ligipääsuks
cat > "$HOME/.my.cnf" <<'EOF'
[client]
host=localhost
user=root
password=qwerty
EOF
chmod 600 "$HOME/.my.cnf"

# Kontroll
if systemctl is-active --quiet mysql && mysql -e "SELECT 1" >/dev/null 2>&1; then
    echo "TULEMUS: $(mysql --version) on paigaldatud ja töötab."
else
    echo "VIGA: MySQL ei tööta või ühendus ebaõnnestus."
    exit 1
fi

echo "Paigaldatud paketid:"
dpkg -l | grep -E "^ii\s+mysql" | awk '{print $2, $3}'
