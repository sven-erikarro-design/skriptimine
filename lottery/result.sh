#!/bin/bash

# Võrdleb mängija ja loositud numbreid. Tabamuste arvu kirjutab antud muutujasse.
check_matches() {
    local player_file="$1"
    local lottery_file="$2"
    local player_number lottery_number hit match_count=0

    while IFS= read -r player_number; do
        echo
        echo "Kontrollin numbrit $player_number..."
        hit=0

        while IFS= read -r lottery_number; do
            if [[ "$player_number" == "$lottery_number" ]]; then
                hit=1
                break
            fi
        done < "$lottery_file"

        if ((hit == 1)); then
            echo "TABAMUS!"
            match_count=$((match_count + 1))
        else
            echo "Ei tabanud."
        fi
    done < "$player_file"

    printf -v "$3" '%d' "$match_count"
}

# Näitab tulemust ja salvestab tulemuse kirjelduse antud muutujasse.
show_result() {
    local player_name="$1"
    local matches="$2"
    local message

    case "$matches" in
        5) message="JACKPOT!" ;;
        4) message="Väga hea tulemus!" ;;
        3) message="Hea tulemus." ;;
        2) message="Kaks tabamust." ;;
        1) message="Üks tabamus." ;;
        0) message="Seekord tabamusi ei olnud." ;;
    esac

    printf -v "$3" '%s' "$message"
    echo
    echo "Mängija: $player_name"
    echo "Tabamusi: $matches / 5"
    echo "$message"
}
