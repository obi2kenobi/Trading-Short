#!/bin/bash
# skill-reminder-hook.sh — hook PreToolUse (Edit|Write): quando l'agente TOCCA il terreno di una
# skill, gliela ricorda (decisione di Luca, D3 2026-09-23: «a» — il promemoria guarda cio' che
# l'agente fa, non le parole della richiesta). Nato dal debito del 2026-08-24: nella sessione
# sulla dashboard GAS `verifica-visiva` e `dev-critic` non si sono attivate da sole, con la
# description che calzava alla lettera — l'attivazione per sola description non basta.
#
# Regole (nessuna lista scritta qui: i criteri si leggono da fonti che esistono gia'):
#   .html in un progetto GAS (appsscript.json risalendo le cartelle) → verifica-visiva
#   .gs/.js in un progetto GAS                                         → gas-sviluppo
#   un .py citato dall'agente contabilita-analitica (il registro degli oracoli) → controllo-gestione
# La description del promemoria e' quella della SKILL.md. Una volta per skill per sessione
# (stato in /tmp per session_id); una skill assente dalla repo non si suggerisce. Mai un blocco.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
INPUT="$(cat)"
FILE="$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null)"
SESS="$(jq -r '.session_id // "senza-sessione"' <<<"$INPUT" 2>/dev/null)"
[ -z "$FILE" ] && exit 0
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

# progetto GAS: appsscript.json nella cartella del file o in una sopra, fino alla radice
gas_progetto() {
  local d; d="$(dirname "$1")"
  while :; do
    [ -f "$d/appsscript.json" ] && return 0
    [ "$d" = "$ROOT" ] || [ "$d" = "/" ] || [ "$d" = "." ] && return 1
    d="$(dirname "$d")"
  done
}

SKILL=""
case "$FILE" in
  *.html)   gas_progetto "$FILE" && SKILL="verifica-visiva" ;;
  *.gs|*.js) gas_progetto "$FILE" && SKILL="gas-sviluppo" ;;
  *.py)     REL="${FILE#"$ROOT"/}"
            grep -qF "$REL" "$ROOT/.claude/agents/contabilita-analitica.md" 2>/dev/null && SKILL="controllo-gestione" ;;
esac
[ -n "$SKILL" ] || exit 0
MD="$ROOT/.claude/skills/$SKILL/SKILL.md"
[ -f "$MD" ] || exit 0

# una volta per skill per sessione
STATO="/tmp/ai-programmer-skill-reminder.${SESS//[^A-Za-z0-9_-]/_}"   # session_id ripulito: diventa un nome di file
grep -qx "$SKILL" "$STATO" 2>/dev/null && exit 0
echo "$SKILL" >> "$STATO" 2>/dev/null

DESC="$(sed -n 's/^description: //p' "$MD" | head -1 | cut -c1-300)"
CTX="Stai toccando $FILE: e' il terreno della skill \`$SKILL\` — invocala con lo strumento Skill prima di procedere, se non l'hai gia' fatto (promemoria, non un blocco; D3 2026-09-23).
$SKILL: ${DESC}…"
jq -n --arg ctx "$CTX" '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$ctx}}'
