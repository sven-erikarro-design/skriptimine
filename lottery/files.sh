#!/bin/bash

# Loob või tühjendab mängija ja loositud numbrite failid.
clear_files() {
    : > "$1" || return 1
    : > "$2" || return 1
}

# Lisab ühe mängu andmed ajaloo lõppu; olemasolevaid tulemusi ei kustuta.
save_result() {
    local history_file="$1"
    local player_name="$2"
    local player_file="$3"
    local lottery_file="$4"
    local matches="$5"
    local result="$6"

    {
        echo "========================================"
        echo "Date: $(date)"
        echo "Player: $player_name"
        echo "Player numbers:"
        cat "$player_file"
        echo "Lottery numbers:"
        cat "$lottery_file"
        echo "Matches: $matches"
        echo "Result: $result"
        echo
    } >> "$history_file" || return 1
}
