#!/bin/bash
# gas-gate.sh — ogni .gs tracciato deve compilare, e anche il JS dentro i .html
# (portato dal campo Budget Vendite 2026-09-19: il gate esisteva li' e non
# nell'hub — E-028 imparata per Python e mai generalizzata a GAS, su un hub
# con una skill gas-sviluppo)
# della web app: e' codice che gira in produzione come il resto, ma nessun gate lo
# guardava (la dashboard e' 215 righe, quasi tutte JavaScript).
# `node --check` rifiuta l'estensione .gs (ERR_UNKNOWN_FILE_EXTENSION) e non sa
# leggere l'HTML: si estrae in .js in una temp e si controlla lì.
# Esiti: 0 tutti compilano · 1 almeno uno no (il verdetto è sull'ultima riga).
# Uso: gas-gate.sh [dir]   (default: la repo che lo contiene — nelle destinazioni
# GAS gira da dentro; come tool dell'hub accetta la dir da giudicare, come py-gate)
set -uo pipefail
DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
[ -d "$DIR" ] || { echo "⛔ gas-gate: dir inesistente: $DIR" >&2; exit 2; }
cd "$DIR"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
N=0; KO=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  N=$((N+1))
  cp "$f" "$TMP/g.js"
  if node --check "$TMP/g.js" 2>"$TMP/err"; then
    echo "OK   $f"
  else
    echo "KO   $f"; sed 's/^/     /' "$TMP/err"; KO=$((KO+1))
  fi
done < <(git ls-files '*.gs')
while IFS= read -r f; do
  [ -n "$f" ] || continue
  sed -n '/<script>/,/<\/script>/p' "$f" | sed '1d;$d' > "$TMP/h.js"
  [ -s "$TMP/h.js" ] || continue
  N=$((N+1))
  if node --check "$TMP/h.js" 2>"$TMP/err"; then
    echo "OK   $f (script inline)"
  else
    echo "KO   $f (script inline)"; sed 's/^/     /' "$TMP/err"; KO=$((KO+1))
  fi
done < <(git ls-files '*.html')

# (report Budget Vendite + lezione BusinessPlan): zero file non e' verde — e' un
# perimetro non giudicabile. Un gate che non ha niente da guardare lo DICE.
[ "$N" -eq 0 ] && { echo "gas-gate: nessun .gs né .html tracciato — perimetro non giudicabile (exit 2)"; exit 2; }
[ "$KO" -gt 0 ] && { echo "⛔ $KO file su $N non compilano"; exit 1; }
echo "✓ $N file compilano (.gs + script inline dei .html)"
