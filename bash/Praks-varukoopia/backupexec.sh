#!/usr/bin/env bash
set -euo pipefail
umask 077

base="$HOME/praks2"
dest="$base/backup"
log="$base/logs/backup.log"
ignore="$base/src/.backupignore"
extension=zst
compressor=(-I 'zstd -19 -T0')
dry_run=false

for option in "$@"; do
    case "$option" in
        --dry-run) dry_run=true ;;
        --zstd) extension=zst; compressor=(-I 'zstd -19 -T0') ;;
        --gzip) extension=gz; compressor=(-z) ;;
        --xz) extension=xz; compressor=(-J) ;;
        *) printf 'Tundmatu valik: %s\n' "$option" >&2; exit 2 ;;
    esac
done

# Kasuta samu välistusi kuivas jooksus ja päris varundamisel.
exclusions=()
if [[ -f "$ignore" ]]; then
    exclusions+=(--exclude-from="$ignore")
fi

if "$dry_run"; then
    tar "${exclusions[@]}" -cf - -C "$base" src | tar -tvf -
    exit
fi

mkdir -p -- "$dest" "$base/logs"

log_event() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a -- "$log"
}

# Väldi samaaegset varundamist ja vanade koopiate kustutamist.
exec 9>"$dest/.backupexec.lock"
flock -n 9 || { log_event 'BACKUP ERROR: varundamine juba käib'; exit 1; }

work_dir=''
cleanup() {
    local result=$?
    if [[ -n "$work_dir" ]]; then
        rm -rf -- "$work_dir"
    fi
    if (( result != 0 )); then
        log_event "BACKUP ERROR (väljumiskood $result)" >&2
    fi
}
trap cleanup EXIT

archive="backupexec_$(date +%Y-%m-%d_%H-%M-%S).tar.$extension"
log_event "BACKUP START $archive"

if [[ -e "$dest/$archive" || -e "$dest/$archive.sha256" ]]; then
    log_event "Arhiiv on juba olemas: $archive"
    exit 1
fi

# Jäta lähtekausta mahule lisaks ruumi arhiivi päiste jaoks.
needed=$(du -sb -- "$base/src" | cut -f1)
available=$(df -B1 --output=avail -- "$dest" | awk 'NR == 2 {print $1}')
if (( available < needed + 1048576 )); then
    log_event "Vaba ruumi on liiga vähe: $available B"
    exit 1
fi

# Avalda arhiiv alles pärast sisu ja kontrollsumma kontrollimist.
work_dir=$(mktemp -d -- "$dest/.backupexec.XXXXXXXX")
(
    cd -- "$work_dir"
    tar "${compressor[@]}" "${exclusions[@]}" -cf "$archive" -C "$base" src
    tar -tf "$archive" > contents.txt
    grep -qE '^src/[^/]+/$' contents.txt
    sha256sum -- "$archive" > "$archive.sha256"
    sha256sum -c -- "$archive.sha256"
    du -h -- "$archive"
)
mv -T -- "$work_dir/$archive" "$dest/$archive"
mv -T -- "$work_dir/$archive.sha256" "$dest/$archive.sha256"

# Ajatempliga nimed järjestuvad vanimast uusimani.
export LC_ALL=C
shopt -s nullglob
copies=("$dest"/backupexec_*.tar.{zst,gz,xz})
mapfile -t copies < <(printf '%s\n' "${copies[@]}" | sort)
for ((i = 0; i < ${#copies[@]} - 3; i++)); do
    rm -- "${copies[i]}" "${copies[i]}.sha256"
done

log_event "BACKUP OK $archive"
