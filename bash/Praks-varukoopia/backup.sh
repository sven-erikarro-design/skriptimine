#!/usr/bin/env bash
set -u
set -o pipefail

backup_dir=/var/backups/home_bcp
backup_date=$(date +%d.%m.%Y)
status=0

# Varukoopiaid saab lugeda ainult root.
umask 077
install -d -m 700 -- "$backup_dir" || exit 1
work_dir=$(mktemp -d -- "$backup_dir/.backup.XXXXXXXX") || exit 1
trap 'rm -rf -- "$work_dir"' EXIT

accounts=$(getent passwd) || exit 1
while IFS=: read -r username _ _ _ _ home _; do
    [[ "$home" == /home/* && -d "$home" ]] || continue

    archive="$username.$backup_date.tar.gz"
    temp_archive="$work_dir/$archive"

    # Kontrolli uut arhiivi enne lõplikku sihtkohta tõstmist.
    if tar -czf "$temp_archive" -C "$(dirname -- "$home")" "$(basename -- "$home")" &&
        tar -tzf "$temp_archive" >/dev/null &&
        mv -fT -- "$temp_archive" "$backup_dir/$archive"; then
        printf 'Varundatud ja kontrollitud: %s\n' "$archive"
    else
        printf 'Varundamine ebaõnnestus: %s\n' "$username" >&2
        status=1
    fi
done <<< "$accounts"

exit "$status"
