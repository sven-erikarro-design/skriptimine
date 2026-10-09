#!/bin/bash

# Hoia tekstifailid skriptiga samas kaustas.
cd "$(dirname "$0")" || exit 1

# Tühjenda mängija ja loositud numbrite failid.
> player_numbers.txt
> lottery_numbers.txt

read -r -p "Sisesta mängija nimi: " player_name
if [[ -z "$player_name" ]]; then
    player_name="Unknown"
fi

# Küsi mängijalt viis erinevat numbrit.
player_numbers=()
while ((${#player_numbers[@]} < 5)); do
    read -r -p "Sisesta number 1-50: " number

    if [[ -z "$number" ]]; then
        echo "Viga: sisesta number."
        continue
    fi

    if [[ ! "$number" =~ ^[0-9]+$ ]]; then
        echo "Viga: number peab olema täisarv."
        continue
    fi

    # Eemalda algusest nullid (näiteks 007 muutub 7-ks).
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

echo
echo "Sinu numbrid:"
cat player_numbers.txt

# Loosi viis erinevat numbrit.
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

echo
echo "Loositud numbrid:"
cat lottery_numbers.txt

# Võrdle failides olevaid numbreid.
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

# Määra tulemuse tekst.
case $matches in
    5) result="JACKPOT!" ;;
    4) result="Väga hea tulemus!" ;;
    3) result="Hea tulemus." ;;
    2) result="Kaks tabamust." ;;
    1) result="Üks tabamus." ;;
    0) result="Seekord tabamusi ei olnud." ;;
esac

echo
echo "Mängija: $player_name"
echo "Tabamusi: $matches / 5"
echo "$result"

# Lisa tulemus ajaloo faili. Seda faili ei tühjendata.
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
