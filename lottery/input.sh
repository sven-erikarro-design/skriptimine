#!/bin/bash

# Küsib mängija nime ja salvestab selle antud muutujasse.
read_player() {
    local name

    read -r -p "Sisesta mängija nimi: " name || return 1
    name=${name:-Unknown}
    printf -v "$1" '%s' "$name"
}

# Küsib viis erinevat täisarvu ja salvestab need faili.
read_player_numbers() {
    local numbers_file="$1"
    local number chosen duplicate count=0

    while ((count < 5)); do
        read -r -p "Sisesta number 1-50: " number || {
            echo "Sisend lõppes enne viie numbri sisestamist."
            return 1
        }

        if [[ -z "$number" ]]; then
            echo "Viga: sisesta number."
            continue
        fi

        if [[ ! "$number" =~ ^[0-9]+$ ]]; then
            echo "Viga: number peab olema täisarv."
            continue
        fi

        # Eemaldab algusnullid, näiteks 07 muutub numbriks 7.
        while [[ ${#number} -gt 1 && "$number" == 0* ]]; do
            number=${number#0}
        done

        if [[ ${#number} -gt 2 ]] || ((number < 1 || number > 50)); then
            echo "Viga: number peab olema vahemikus 1-50."
            continue
        fi

        duplicate=0
        while IFS= read -r chosen; do
            if [[ "$chosen" == "$number" ]]; then
                duplicate=1
                break
            fi
        done < "$numbers_file"

        if ((duplicate == 1)); then
            echo "Viga: oled selle numbri juba valinud."
            continue
        fi

        echo "$number" >> "$numbers_file" || return 1
        count=$((count + 1))
    done
}
