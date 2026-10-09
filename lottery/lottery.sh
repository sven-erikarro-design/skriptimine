#!/bin/bash

# Leia abifailid, kus on programmi funktsioonid.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || exit 1
source "$SCRIPT_DIR/input.sh" || exit 1
source "$SCRIPT_DIR/lottery_functions.sh" || exit 1
source "$SCRIPT_DIR/result.sh" || exit 1
source "$SCRIPT_DIR/files.sh" || exit 1

# Kõik mängu failid asuvad lottery.sh failiga samas kaustas.
PLAYER_FILE="$SCRIPT_DIR/player_numbers.txt"
LOTTERY_FILE="$SCRIPT_DIR/lottery_numbers.txt"
RESULT_FILE="$SCRIPT_DIR/results.txt"

main() {
    local player_name=""
    local matches=0
    local result=""

    show_header
    clear_files "$PLAYER_FILE" "$LOTTERY_FILE" || return 1
    read_player player_name || return 1
    read_player_numbers "$PLAYER_FILE" || return 1
    show_player_numbers "$PLAYER_FILE"
    generate_lottery_numbers "$LOTTERY_FILE" || return 1
    show_lottery_numbers "$LOTTERY_FILE"
    check_matches "$PLAYER_FILE" "$LOTTERY_FILE" matches
    show_result "$player_name" "$matches" result
    save_result "$RESULT_FILE" "$player_name" "$PLAYER_FILE" "$LOTTERY_FILE" "$matches" "$result"
}

main "$@"
