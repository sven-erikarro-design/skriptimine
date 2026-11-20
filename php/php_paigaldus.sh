#!/bin/bash
# PHP paigaldus Apache veebiserverile (Debian)

if [ "$(id -u)" -ne 0 ]; then
    echo "VIGA: käivita skript root õigustes (sudo)."
    exit 1
fi

PAKETID="php libapache2-mod-php php-mysql"

echo "=== PHP paigaldus ==="

if command -v php >/dev/null 2>&1; then
    echo "PHP on juba paigaldatud: $(php -r 'echo PHP_VERSION;')"
else
    echo "PHP puudub, paigaldan..."
    apt-get update -qq
    if ! DEBIAN_FRONTEND=noninteractive apt-get install -y $PAKETID; then
        echo "VIGA: PHP paigaldamine ebaõnnestus."
        exit 1
    fi
fi

# Konfiguratsioon (Apache mod_php)
PHPINI=$(ls /etc/php/*/apache2/php.ini 2>/dev/null | head -n1)
if [ -n "$PHPINI" ]; then
    sed -i 's/^expose_php = .*/expose_php = Off/' "$PHPINI"
    sed -i 's/^display_errors = .*/display_errors = Off/' "$PHPINI"
    echo "Konfiguratsioon uuendatud: $PHPINI"
fi

# index.php eelistus
if [ -f /etc/apache2/mods-enabled/dir.conf ]; then
    sed -i 's/DirectoryIndex .*/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf
fi

# Moodul sisse + restart
a2enmod "php$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')" >/dev/null 2>&1
systemctl restart apache2

# Test
echo "<?php echo 'PHP töötab: ' . PHP_VERSION . PHP_EOL;" > /var/www/html/test.php
if curl -s http://localhost/test.php | grep -q "PHP töötab"; then
    echo "TULEMUS: PHP $(php -r 'echo PHP_VERSION;') on paigaldatud ja töötab Apache all."
else
    echo "VIGA: PHP test ebaõnnestus."
fi
rm -f /var/www/html/test.php

echo "Paigaldatud paketid:"
dpkg -l | grep -E "^ii\s+(php|libapache2-mod-php)" | awk '{print $2, $3}'
