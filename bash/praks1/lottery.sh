#!/bin/bash

# Failid asuvad skriptiga samas kaustas.
cd "$(dirname "$0")" || exit 1

show_header() {
    echo "=============================="
    echo "       LOTOMÄNG"
    echo "Vali 5 erinevat numbrit 1-50"
    echo "=============================="
}

clear_files() {
    > player_numbers.txt
    > lottery_numbers.txt
}

read_player() {
    read -r -p "Sisesta mängija nimi: " player_name
    if [[ -z "$player_name" ]]; then
        player_name="Unknown"
    fi
}

read_player_numbers() {
    player_numbers=()

    while ((${#player_numbers[@]} < 5)); do
        read -r -p "Sisesta number 1-50: " number || return 1

        if [[ -z "$number" ]]; then
            echo "Viga: sisesta number."
            continue
        fi

        if [[ ! "$number" =~ ^[0-9]+$ ]]; then
            echo "Viga: number peab olema täisarv."
            continue
        fi

        # Eemalda algusest nullid, et näiteks 07 ja 7 oleks sama number.
        while [[ ${#number} -gt 1 && "$number" == 0* ]]; do
            number=${number#0}
        done

        if [[ ${#number} -gt 2 ]] || ((number < 1 || number > 50)); then
            echo "Viga: number peab olema vahemikus 1-50."
            continue
        fi

        duplicate=0
        for chosen in "${player_numbers[@]}"; do
            if [[ "$number" == "$chosen" ]]; then
                duplicate=1
            fi
        done

        if [[ $duplicate -eq 1 ]]; then
            echo "Viga: oled selle numbri juba valinud."
            continue
        fi

        player_numbers+=("$number")
        echo "$number" >> player_numbers.txt
    done
}

show_player_numbers() {
    echo
    echo "Sinu numbrid:"
    cat player_numbers.txt
}

generate_lottery_numbers() {
    lottery_numbers=()

    while ((${#lottery_numbers[@]} < 5)); do
        number=$((RANDOM % 50 + 1))
        duplicate=0

        for drawn in "${lottery_numbers[@]}"; do
            if [[ "$number" == "$drawn" ]]; then
                duplicate=1
            fi
        done

        if [[ $duplicate -eq 0 ]]; then
            lottery_numbers+=("$number")
            echo "$number" >> lottery_numbers.txt
        fi
    done
}

show_lottery_numbers() {
    echo
    echo "Loositud numbrid:"
    cat lottery_numbers.txt
}

check_matches() {
    matches=0

    while IFS= read -r player_number; do
        echo
        echo "Kontrollin numbrit $player_number..."
        hit=0

        while IFS= read -r lottery_number; do
            if [[ "$player_number" == "$lottery_number" ]]; then
                hit=1
                break
            fi
        done < lottery_numbers.txt

        if [[ $hit -eq 1 ]]; then
            echo "TABAMUS!"
            matches=$((matches + 1))
        else
            echo "Ei tabanud."
        fi
    done < player_numbers.txt
}

show_result() {
    echo
    echo "Mängija: $player_name"
    echo "Tabamusi: $matches / 5"

    case $matches in
        5) result="JACKPOT!" ;;
        4) result="Väga hea tulemus!" ;;
        3) result="Hea tulemus." ;;
        2) result="Kaks tabamust." ;;
        1) result="Üks tabamus." ;;
        0) result="Seekord tabamusi ei olnud." ;;
    esac

    echo "$result"
}

save_result() {
    {
        echo "========================================"
        echo "Date: $(date)"
        echo "Player: $player_name"
        echo "Player numbers:"
        cat player_numbers.txt
        echo "Lottery numbers:"
        cat lottery_numbers.txt
        echo "Matches: $matches"
        echo "Result: $result"
        echo
    } >> results.txt
}

# Programmi põhiosa: tegevused on siin nende järjekorras naha.
show_header
clear_files
read_player
read_player_numbers || exit 1
show_player_numbers
generate_lottery_numbers
show_lottery_numbers
check_matches
show_result
save_result
