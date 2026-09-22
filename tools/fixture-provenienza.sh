#!/bin/bash
# fixture-provenienza.sh — una fixture senza la riga che dichiara COME e' nata e' un'ipotesi
# travestita da misura (REPO-V 2026-09-07: tre fixture bugiarde in un giorno, banco verde,
# vivo rotto). La regola e' del canone; QUESTO e' il dente. 0 LLM.
#
# Convenzione: la prima riga utile di ogni file di fixture (o del suo .provenienza fratello)
# contiene "prodotto da:" seguito dal comando che l'ha generato. I file dichiarati in
# .fixture-esclusioni (uno per riga, col perché sopra) restano fuori col motivo scritto.
# Uso: fixture-provenienza.sh [radice]   (default: la repo corrente)
set -uo pipefail
ROOT="${1:-.}"
cd "$ROOT" || exit 2
ESC=".fixture-esclusioni"
TROVATE=0; SENZA=0; FUORI=0
while IFS= read -r f; do
  TROVATE=$((TROVATE+1))
  base=$(basename "$f")
  if [ -f "$ESC" ] && grep -qxF "$base" "$ESC"; then continue; fi
  if [ -f "$f.provenienza" ] || head -5 "$f" | grep -qi "prodotto da:"; then
    continue
  fi
  echo "  fixture senza provenienza: $f"
  SENZA=$((SENZA+1))
done < <(find . -type f \( -path '*/fixtures/*' -o -path '*/fixture/*' -o -name '*.fixture.*' -o -name 'fixture-*' \) -not -path './.git/*' -not -name 'fixture-provenienza.sh' 2>/dev/null)
# (report REPO-F, difetto 3): '-name fixture-*' catturava QUESTO tool — ogni repo
# che adotta lo standard stampava «1 fixture su 1 senza provenienza» senza avere
# una sola fixture. Il tool non e' una fixture: escluso per nome.
[ "$TROVATE" -eq 0 ] && { echo "nessuna fixture trovata sotto $ROOT (se ce ne sono, la convenzione di naming non le vede: dichiara)"; exit 0; }
if [ "$SENZA" -gt 0 ]; then
  echo "⛔ $SENZA fixture su $TROVATE non dichiarano il comando che le ha prodotte (banco verde su dati inventati)"
  exit 1
fi
echo "✓ $TROVATE fixture, tutte con la provenienza dichiarata"
