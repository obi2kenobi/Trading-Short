#!/bin/bash
# test-errori.sh — la lente del registro degli errori (100 giri sui fallimenti,
# 2026-08-28). L'errore a regime ha sette campi obbligatori, una famiglia
# canonica R1-R6, e una GUARDIA che deve esistere davvero: una voce con la
# guardia inesistente è una promessa fossile — il parente dell'header fossile
# (E-012). Il registro non si svuota mai: la lente misura che ogni promessa
# fatta dall'errore sia ancora in piedi.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
REG="$HERE/docs/errori/REGISTRO.md"
PASS=0; FAIL=0
ok() { PASS=$((PASS+1)); echo "OK   $1"; }
ko() { FAIL=$((FAIL+1)); echo "FAIL $1"; }

[ -f "$REG" ] && ok "il registro esiste" || { ko "registro assente"; echo "0 0"; exit 1; }
[ -f "$HERE/.claude/skills/post-mortem/SKILL.md" ] && ok "la skill del protocollo esiste" || ko "skill post-mortem assente"

N_VOCI=$(grep -c "^## E-" "$REG")
[ "$N_VOCI" -ge 1 ] && ok "voci a regime: $N_VOCI" || ko "registro vuoto"

CAMPI=("Data / sessione:" "Famiglia:" "Sintomo:" "Causa prossima:" \
       "Causa del ragionamento:" "Perché non ci ha fermati:" "Guardia:" \
       "Verifica guardia:" "Aggiramento:")
while IFS= read -r voce; do
  ID=$(echo "$voce" | awk '{print $2}')
  BLOCCO=$(awk -v ini="$voce" 'index($0, ini)==1 {p=1; next} p && /^## E-/ {exit} p {print}' "$REG")
  MANCA=""
  for c in "${CAMPI[@]}"; do
    echo "$BLOCCO" | grep -q "^- $c" || MANCA="$MANCA $c"
  done
  [ -z "$MANCA" ] && ok "$ID: sette campi + famiglia completi" || ko "$ID: mancanti:$MANCA"
  # (2026-09-09, report REPO-V): dalle voci dal 24 in poi, il campo «Chi l'ha trovato:»
  # e' obbligatorio — e' il dato che mostra l'asimmetria (lenti=i meccanici, dominio=i giudizi).
  # Le voci storiche restano come sono: il passato non si riscrive per la regola nuova.
  N=$(echo "$ID" | grep -oE '[0-9]+')
  if [ "$N" -ge 24 ] 2>/dev/null; then
    echo "$BLOCCO" | grep -q "^- Chi l'ha trovato:" \
      && ok "$ID: chi l'ha trovato dichiarato" \
      || ko "$ID: manca «Chi l'ha trovato:» (lente / vivo / padrone del dominio — obbligatorio da E-024)"
  fi
  FAM=$(echo "$BLOCCO" | grep "^- Famiglia:" | grep -coE "R[1-6]")
  [ "${FAM:-0}" -ge 1 ] && ok "$ID: famiglia canonica" || ko "$ID: famiglia fuori canone R1-R6"
  # la guardia citata esiste davvero (il file che nomina deve stare nel repo)
  GUARDIA=$(echo "$BLOCCO" | grep "^- Guardia:" | grep -oE '(tests/[a-z0-9-]+\.sh|tools/[a-z0-9-]+\.(sh|py)|patterns/[a-z0-9-]+\.md|night-shift/[a-z0-9-]+\.sh)' | head -1)
  if [ -n "$GUARDIA" ]; then
    [ -e "$HERE/$GUARDIA" ] && ok "$ID: guardia esiste ($GUARDIA)" || ko "$ID: guardia inesistente: $GUARDIA (promessa fossile)"
  else
    ko "$ID: nessun file di guardia citato"
  fi
done < <(grep "^## E-" "$REG")

# il registro è nella mappa dei documenti vivi (non orfano) e la skill pure
grep -q "docs/errori/REGISTRO.md" "$HERE/README.md" "$HERE/CLAUDE.md" "$HERE/.claude/skills/post-mortem/SKILL.md" 2>/dev/null \
  && ok "il registro è raggiungibile da qualche porta" || ko "registro orfano: nessuno lo linka"

echo ""
echo "$PASS OK, $FAIL FAIL"
[ $FAIL -eq 0 ]
