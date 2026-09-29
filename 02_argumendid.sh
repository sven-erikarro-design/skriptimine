#!/bin/bash

# Argumendid ja lokaalsed muutujad
kasutaja_info() {
    local nimi="$1"
    local vanus="$2"

    echo "Nimi: $nimi"
    echo "Vanus: $vanus"
}

# Töö kõigi argumentidega
naita_koik() {
    echo "Kokku anti $# argumenti."
    echo "Argumendid ühekaupa:"
    
    for arg in "$@"; do
        echo " - $arg"
    done
}

# --- SKRIPTI TÄITMINE ---

echo "=== 1. Lokaalsed muutujad ja argumendid ==="
kasutaja_info "Mari" 25

echo -e "\n=== 2. Dünamilline argumentide loend ($@ ja $#) ==="
naita_koik "Oun" "Pirn" "Banaan" "Ploom"
