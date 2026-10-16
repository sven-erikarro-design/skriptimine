#!/usr/bin/env bash
set -euo pipefail
demo="$(mktemp -d)"
cd "$demo"
printf 'hello\n' > demo.txt
sha256sum demo.txt > demo.txt.sha256
echo "Algne fail: peab tulema OK"
sha256sum -c demo.txt.sha256
printf 'x\n' >> demo.txt
echo "Muudetud fail: peab tulema FAILED"
if sha256sum -c demo.txt.sha256; then
  echo "Viga: muudatust ei avastatud."
  exit 1
else
  echo "Katse õnnestus: muudatus avastati."
fi
printf 'Näidisfailid: %s\n' "$demo"
