#!/bin/bash
# Skript: apache_paigaldamine_v2.sh
# Eesmärk: küsib ühe korra, kas paigaldada apache2 või nginx, ja teeb ära.
# Käivitamine: sudo ./apache_paigaldamine_v2.sh

# Paigaldamiseks on vaja root õigusi
if [ "$(id -u)" -ne 0 ]; then
    echo "Viga: käivita skript root õigustes (sudo)."
    exit 1
fi

# Ainus küsimus
printf "Vali veebiserver (1 = apache2, 2 = nginx): "
read VALIK

case "$VALIK" in
    1) TEENUS="apache2"; TEINE="nginx" ;;
    2) TEENUS="nginx";   TEINE="apache2" ;;
    *) echo "Viga: vigane valik '$VALIK'."; exit 1 ;;
esac

# Kontroll: 1 = paigaldatud, 0 = ei ole
KONTROLL=$(dpkg-query -W -f='${Status}' "$TEENUS" 2>/dev/null | grep -c "ok installed")

if [ "$KONTROLL" -eq 0 ]; then
    echo "$TEENUS ei ole paigaldatud. Alustan paigaldamist..."
    apt update -y
    if apt install -y "$TEENUS"; then
        echo "$TEENUS paigaldati edukalt."
    else
        echo "Viga: $TEENUS paigaldamine ebaõnnestus."
        exit 1
    fi
else
    echo "$TEENUS on juba paigaldatud."
fi

# Port 80 konflikt: peata teine veebiserver automaatselt
if systemctl is-active --quiet "$TEINE"; then
    echo "$TEINE töötab ja kasutab porti 80. Peatan."
    systemctl stop "$TEINE"
    systemctl disable "$TEINE"
fi

# Käivita ja luba valitud teenus
systemctl enable --now "$TEENUS"
systemctl restart "$TEENUS"

# Staatus
echo "---------- $TEENUS staatus ----------"
systemctl status "$TEENUS" --no-pager -l
