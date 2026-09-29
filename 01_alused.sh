#!/bin/bash

# 1. Lihtne funktsioon
tervita() {
    echo "Tere!"
    echo "Tänane kuupäev on: $(date +%Y-%m-%d)"
}

# 6. Funktsioonid, mis kutsuvad teisi funktsioone
show_user() {
    echo "Kasutaja: $(whoami)"
}

show_host() {
    echo "Arvuti: $(hostname)"
}

show_system() {
    show_user
    show_host
}

# --- SKRIPTI TÄITMINE ---

echo "=== 1. Lihtne väljakutse ==="
tervita

echo -e "\n=== 2. Korduv kutsumine tsüklis ==="
for i in {1..3}; do
    echo "Samm $i:"
    tervita
done

echo -e "\n=== 3. Alamfunktsioonide kutsumine ==="
show_system
