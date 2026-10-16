#!/usr/bin/env bash
set -euo pipefail
cd "${BACKUP_DIR:-$HOME/praks2/backup}"
case "${1:-}" in
  loo)
    shopt -s nullglob
    files=()
    for file in src_*.tar.*; do
      [[ -f "$file" ]] || continue
      [[ "$file" == *.sha256 ]] && continue
      files+=("$file")
    done
    if (( ${#files[@]} == 0 )); then
      echo "Arhiive ei leitud." >&2
      exit 1
    fi
    sha256sum -- "${files[@]}" > checksums.txt
    sha256sum -c checksums.txt
    ;;
  kontrolli) sha256sum -c checksums.txt ;;
  *) echo "Kasutamine: bash $0 {loo|kontrolli}"; exit 2 ;;
esac
