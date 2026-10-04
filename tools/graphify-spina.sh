#!/bin/bash
# graphify-spina.sh — tiene vivo il GRAFO della repo: la spina dorsale per trovare i dati
# (decisione di Luca, D1 2026-09-23: «il graphify deve essere il teletrasporto per trovare tutti
# i dati, e quando installi ai_programmer in un repo deve essere la spina dorsale anche del nuovo
# repo» — grafo VERSIONATO col merge-driver di graphify; la semantica la fa la notte con Ollama,
# tools/grafo-semantico.sh).
#
# Uso:
#   tools/graphify-spina.sh [dir]            aggiorna il grafo AST (hook SessionStart)
#   tools/graphify-spina.sh [dir] --stage    idem, e mette in stage graph.json (pre-commit)
#
# Cosa fa, in ordine (ogni passo nel log graphify-out/.spina.log, una riga di sintesi a video):
#   1. graphify assente → DEGRADATO dichiarato, esce 0: il grafo aiuta, non blocca mai
#   2. le regole del grafo vivono NELLA SUA CARTELLA (graphify-out/.gitignore e .gitattributes):
#      nessun file della repo ospite viene toccato; versionato solo graph.json
#   3. il merge-driver di graphify nella config LOCALE della repo (la config non viaggia con git:
#      ogni clone lo registra qui, alla prima sessione) — due rami che cambiano il grafo si UNISCONO
#   4. `graphify update` — solo AST, niente LLM, incrementale; i nodi semantici della notte restano
#      (graphify/watch.py li preserva). PYTHONHASHSEED=0: stesse sorgenti, stesso grafo (lo dice
#      l'hook ufficiale di graphify: il clustering altrimenti cambia a ogni processo)
#   5. --stage: git add del grafo — la copia versionata segue il commit
# Hook: SessionStart in .claude/settings.json → copia-hook --elenco lo porta in ogni repo installata.
set -uo pipefail
DIR="${CLAUDE_PROJECT_DIR:-$PWD}"; STAGE=0
for a in "$@"; do case "$a" in --stage) STAGE=1 ;; *) DIR="$a" ;; esac; done
OUT="$DIR/graphify-out"

if ! command -v graphify >/dev/null 2>&1; then
  echo "graphify-spina: graphify ASSENTE — grafo DEGRADATO, navigazione a grep (installa: pipx install --python python3.12 graphifyy==0.9.66)"
  exit 0
fi
git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1 || { echo "graphify-spina: $DIR non e' una repo git — salto"; exit 0; }
mkdir -p "$OUT"
LOG="$OUT/.spina.log"
log() { echo "[$(date '+%F %T')] $*" >> "$LOG"; }
log "inizio: dir=$DIR stage=$STAGE"

# 2. le regole del grafo, nella sua cartella (riscritte solo se diverse: idempotente)
REGOLE_IGN=$'*\n!.gitignore\n!.gitattributes\n!graph.json'
REGOLE_ATT='graph.json merge=graphify linguist-generated=true'
[ "$(cat "$OUT/.gitignore" 2>/dev/null)" = "$REGOLE_IGN" ] || { printf '%s\n' "$REGOLE_IGN" > "$OUT/.gitignore"; log "scritto graphify-out/.gitignore (versionato solo graph.json)"; }
[ "$(cat "$OUT/.gitattributes" 2>/dev/null)" = "$REGOLE_ATT" ] || { printf '%s\n' "$REGOLE_ATT" > "$OUT/.gitattributes"; log "scritto graphify-out/.gitattributes (merge=graphify)"; }
if git -C "$DIR" check-ignore -q graphify-out/graph.json; then
  log "ATTENZIONE: un .gitignore della repo esclude graphify-out/ — il grafo resta LOCALE, non versionato"
  AVVISO=" (⚠ graph.json escluso da un .gitignore della repo: non versionato)"
fi

# 3. il merge-driver (config locale: ogni clone lo registra alla prima sessione)
DRIVER="\"$(command -v graphify)\" merge-driver %O %A %B"
if [ "$(git -C "$DIR" config --get merge.graphify.driver)" != "$DRIVER" ]; then
  git -C "$DIR" config merge.graphify.name "graphify graph.json union merge"
  git -C "$DIR" config merge.graphify.driver "$DRIVER"
  log "registrato il merge-driver di graphify nella config locale"
fi

# 4. il grafo AST (incrementale). Il rifiuto per «meno nodi» di graphify si DICHIARA, non si forza:
#    una cancellazione voluta si conferma a mano con GRAPHIFY_FORCE=1. (D41, 2026-09-25): la 0.9.66 non lo fa — la
#    versione fissata non rifiuta mai, e questo avviso non scatta; resta per una versione che lo faccia.
T0=$(date +%s)
UPD=$(cd "$DIR" && PYTHONHASHSEED=0 graphify update . 2>&1); RC=$?
printf '%s\n' "$UPD" >> "$LOG"
if [ $RC -ne 0 ] || grep -q "Refusing to overwrite" <<<"$UPD"; then
  log "update NON riuscito (rc=$RC)"
  echo "graphify-spina: ⚠ grafo NON aggiornato (rc=$RC) — dettagli in graphify-out/.spina.log$(grep -q 'Refusing' <<<"$UPD" && echo '; meno nodi di prima: se la cancellazione e voluta, GRAPHIFY_FORCE=1 graphify update .')"
  exit 0
fi
RIASSUNTO=$(grep -oE 'Rebuilt: [0-9]+ nodes, [0-9]+ edges' <<<"$UPD" | tail -1)
log "update riuscito in $(( $(date +%s) - T0 ))s: ${RIASSUNTO:-nessuna modifica al codice}"

# 5. in stage per il commit
if [ "$STAGE" -eq 1 ]; then
  git -C "$DIR" add graphify-out/.gitignore graphify-out/.gitattributes graphify-out/graph.json 2>>"$LOG" \
    && log "grafo in stage" || log "git add del grafo fallito (vedi sopra)"
fi
# (2026-09-24, Q4): la riga che ogni sessione vede dice anche il limite misurato — i chiamanti dentro "$(f)",
# <(f) e trap sono invisibili, e «chi usa X» si chiede ad affected, confermato con grep
echo "graphify-spina: grafo aggiornato${RIASSUNTO:+ ($RIASSUNTO)}${AVVISO:-} — dove vive: graphify query \"<termini del codice>\"; chi usa X: graphify affected \"X\" + grep -rn (le chiamate in \"\$(…)\", <(…) e trap non sono nel grafo)"
exit 0
