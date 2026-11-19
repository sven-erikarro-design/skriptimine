#!/bin/bash
# Skript: apache_paigaldamine.sh
# Eesmärk: kontrollida, kas apache2 on paigaldatud; kui ei, siis paigaldada.
# Käivitamine: sudo ./apache_paigaldamine.sh

TEENUS="apache2"

# Paigaldamiseks on vaja root õigusi
if [ "$(id -u)" -ne 0 ]; then
    echo "Viga: käivita skript root õigustes (sudo)."
    exit 1
fi

# dpkg-query annab "install ok installed", kui pakett on paigaldatud.
# grep -c loendab sobivad read: 1 = paigaldatud, 0 = ei ole.
# 2>/dev/null peidab veateate, kui paketti ei leita.
KONTROLL=$(dpkg-query -W -f='${Status}' "$TEENUS" 2>/dev/null | grep -c "ok installed")

if [ "$KONTROLL" -eq 0 ]; then
    echo "$TEENUS ei ole paigaldatud. Alustan paigaldamist..."
    apt update -y
    if apt install -y "$TEENUS"; then
        echo "$TEENUS paigaldati edukalt."
        systemctl enable --now "$TEENUS"
    else
        echo "Viga: $TEENUS paigaldamine ebaõnnestus."
        exit 1
    fi
else
    echo "$TEENUS on juba paigaldatud."
fi

# Teenuse staatus
echo "---------- $TEENUS staatus ----------"
systemctl status "$TEENUS" --no-pager -l
