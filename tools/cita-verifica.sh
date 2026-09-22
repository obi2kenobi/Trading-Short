#!/bin/bash
# cita-verifica.sh — una citazione file:riga che non esiste e' un'istruzione che rompe in
# silenzio (REPO-V 7/9: tre citazioni :riga sbagliate in un design doc, scritte senza
# verificarle). Il dente: ogni `file:NNN` citato nei .md staged deve puntare a un file vero
# con almeno NNN righe. La verifica del CONTENUTO resta umana; l'esistenza della riga no.
# Uso (dal pre-commit, sui .md staged): cita-verifica.sh <file...>
set -uo pipefail
# (report REPO-F 2026-09-19, difetto 4): senza argomenti usciva 0 in silenzio —
# «successo su risultato vuoto» dentro una lente del canone. Niente input,
# niente verdetto.
[ $# -eq 0 ] && { echo "cita-verifica: manca il documento (uso: cita-verifica.sh <file.md>)" >&2; exit 2; }
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
ROSSI=0
TARGET=$(grep -vE '^#|^$' "$HERE/tools/.file-del-target" 2>/dev/null || true)
for f in "$@"; do
  [ -f "$f" ] || continue
  # estrae i riferimenti file:NUMERO (backtick o nudi), esclude URL e orari HH:MM
  while IFS=: read -r cit line; do
    [ -n "$cit" ] || continue
    case "$cit" in *.md|*.sh|*.py|*.js|*.gs|*.json|*.html) ;; *) continue;; esac
    # i file delle repo di campo (dichiarati in .file-del-target) si citano ma non
    # vivono qui: la loro verifica spetta alla repo che li ospita
    echo "$TARGET" | grep -qxF "$cit" && continue
    [ -f "$cit" ] || { echo "  $f cita '$cit:$line': file inesistente"; ROSSI=$((ROSSI+1)); continue; }
    N=$(wc -l < "$cit" | tr -d ' ')
    if ! [ "$line" -le "$N" ] 2>/dev/null; then
      echo "  $f cita '$cit:$line': il file ha solo $N righe"
      ROSSI=$((ROSSI+1))
    fi
  done < <(grep -oE '`?[A-Za-z0-9_./-]+\.(md|sh|py|js|gs|json|html):[0-9]+`?' "$f" | tr -d '`' | grep -vE ':[0-9]{2}:[0-9]{2}$' || true)
done
[ "$ROSSI" -gt 0 ] && { echo "⛔ $ROSSI citazioni file:riga rotte (istruzioni che rompono in silenzio)"; exit 1; }
[ "$#" -gt 0 ] && echo "citazioni file:riga verificate: OK"
exit 0
