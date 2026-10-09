#!/bin/bash

# Kuvab mängu alguse.
show_header() {
    echo "=============================="
    echo "          LOTOMÄNG"
    echo "Vali 5 erinevat numbrit 1-50"
    echo "=============================="
}

# Kuvab failis olevad mängija numbrid.
show_player_numbers() {
    echo
    echo "Sinu numbrid:"
    cat "$1"
}

# Loosib viis erinevat numbrit ja salvestab need faili.
generate_lottery_numbers() {
    local numbers_file="$1"
    local number drawn_number duplicate
    local -a numbers=()

    : > "$numbers_file" || return 1

    while ((${#numbers[@]} < 5)); do
        number=$((RANDOM % 50 + 1))
        duplicate=0

        for drawn_number in "${numbers[@]}"; do
            if [[ "$number" == "$drawn_number" ]]; then
                duplicate=1
                break
            fi
        done

        if ((duplicate == 0)); then
            numbers+=("$number")
            echo "$number" >> "$numbers_file" || return 1
        fi
    done
}

# Kuvab loositud numbrid.
show_lottery_numbers() {
    echo
    echo "Loositud numbrid:"
    cat "$1"
}
