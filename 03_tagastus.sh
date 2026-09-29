#!/bin/bash

# Väärtuse tagastamine väljundi kaudu
liida() {
    local a="$1"
    local b="$2"
    
    if [ $# -ne 2 ]; then
        echo "Viga: Funktsioon vajab täpselt kahte arvu!" >&2
        return 1
    fi

    echo "$((a + b))"
}

# Olekukoodi tagastamine (return 0 / 1)
fail_olemas() {
    local fail="$1"
    [ -f "$fail" ]
}

# --- SKRIPTI TÄITMINE ---

echo "=== 1. Funktsiooni väljundi salvestamine muutujasse ==="
summa=$(liida 15 25)
echo "Arvutuse tulemus: $summa"

echo -e "\n=== 2. Vigase sisendi kontroll ==="
liida 10

echo -e "\n=== 3. Funktsiooni kasutamine IF tingimuses ==="
test_fail="/etc/passwd"

if fail_olemas "$test_fail"; then
    echo "Fail $test_fail on süsteemis olemas."
else
    echo "Faili $test_fail ei leitud."
fi
