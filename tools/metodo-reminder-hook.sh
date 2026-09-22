#!/bin/bash
# metodo-reminder-hook.sh — 2026-08-26, il problema di Luca: «invoco AI_Programmer
# all'inizio e spesso viene dimenticato o usato in parte». Finché il metodo dipende
# dall'invocazione iniziale, dipende dalla memoria della sessione — e il SAL lo
# dice da tempo: l'unico correttivo che rompe quello schema è l'hook. Questo hook
# rende il metodo STRUTTURALE, non mentale: due eventi, zero invocazioni.
#
#   UserPromptSubmit — a OGNI prompt dell'utente (non solo al primo): un digest
#     compatto del metodo + l'aggancio dinamico se il prompt parla di calcoli.
#   SessionStart     — all'apertura: la porta d'ingresso (dove sta il metodo).
#
# Costo: 3-6 righe di contesto per prompt. Non blocca mai (non può: questi
# eventi non hanno permissionDecision — possono solo aggiungere contesto).
set -uo pipefail
# fallback jq: se assente, gli hook degradano al silenzio senza rompere la sessione
if ! command -v jq >/dev/null 2>&1; then exit 0; fi
HERE="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="$(cat)"
EVENT="$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)"
PROMPT="$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)"

if [ "$EVENT" = "Stop" ]; then
  # fine sessione: il report dal campo va scritto (o dichiarato "nessuna proposta")
  OGGI=$(date +%F)
  ST="$PWD/.campo-rem"; ULT=$(cat "$ST" 2>/dev/null || echo 0); ORA=$(date +%s)
  if [ $((ORA - ULT)) -lt 3600 ]; then exit 0; fi
  if ! ls "$PWD"/docs/campo/"${OGGI}"-*.md >/dev/null 2>&1; then echo "$ORA" > "$ST" 2>/dev/null
    jq -n --arg ctx "Chiudi la sessione col report dal campo: docs/campo/${OGGI}-<slug>.md (formato in docs/campo/README.md — tre righe bastano, 'nessuna proposta' dichiarata conta). È il segnale che migliora il sistema a ogni uso: senza, il giro non insegna niente a chi viene dopo." \
      '{hookSpecificOutput:{hookEventName:"Stop",additionalContext:$ctx}}'
  fi
  exit 0
fi

if [ "$EVENT" = "SessionStart" ]; then
  rm -f /tmp/ai-programmer-sal-counter.* 2>/dev/null
  # (settimo patto, 2026-09-09) IL DEBITO SI BRUCIA ALLA RIAPERTURA: se la repo ha
  # DEBITI.md, il riepilogo entra nel contesto dell'apertura — i debiti di dominio come
  # domande singole, i risolvibili da fare prima di procedere. Mai taciti.
  DEBITI_CTX=""
  if [ -f "$PWD/DEBITI.md" ] && [ -f "$HERE/tools/debiti-riapertura.sh" ]; then
    DEBITI_RIEPILOGO=$(bash "$HERE/tools/debiti-riapertura.sh" "$PWD" 2>/dev/null | sed -n '2p' | head -c 300)
    # (report BusinessPlan 2026-09-19): era `DEBITI_CTX "` — un refuso di UN
    # carattere eseguiva DEBITI_CTX come comando (not found), ometteva il settimo
    # patto dal contesto e usciva 0. In silenzio, in ogni repo onboardata.
    [ -n "$DEBITI_RIEPILOGO" ] && DEBITI_CTX="
7) RIAPERTURA: $DEBITI_RIEPILOGO — domande di dominio UNA alla volta, risolvibili prima di procedere (bash tools/debiti-riapertura.sh per l'elenco)."
  fi
  jq -n --arg ctx "STANDARD DI SVILUPPO ATTIVO (AI_Programmer — non serve invocarlo, vale da sé):
1) Esegui, non dedurre: ogni ipotesi meccanica si prova eseguendo, col comando riportato.
2) Prima di una formula di business: oracolo in tools/*.py o formula minata file:riga — MAI indovinata (docs/mappa-dominio-gas-src.md).
3) Prima di correggere: il banco (PARITÀ+CORREZIONE), riga-verdetto 'attese eseguite: N/M · fallite: K' (verifica con tools/verifica_banco.py).
4) Scarto mai silenzioso, assente≠zero, clasp MAI, segreti mai (nemmeno citati).
5) Task da una sessione: si fa e basta col metodo; territorio grande: METHOD.md dice la strada.
6) Il codice parla: semplice, spiegato, OGNI PASSO LOGGATO — il silenzio non è pulizia, è invisibilità.${DEBITI_CTX}
Il metodo in una pagina: METHOD.md. Le famiglie misurate: .claude/skills/gas-sviluppo/references/famiglie-difetti.md." \
    '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
  exit 0
fi

# UserPromptSubmit (default): digest minimo + aggancio se il prompt tocca calcoli/dati
HINT=""
if echo "$PROMPT" | grep -qiE 'calcol|formula|fattur|magazzin|margine|scostament|cespit|scadenz|leasing|rating|bilanci|valorizz'; then
  HINT=" · questo prompt tocca un calcolo: prima gli oracoli in tools/*.py (docs/mappa-dominio-gas-src.md), la formula non si indovina"
fi
if echo "$PROMPT" | grep -qiE '\bBC\b|business central|endpoint|campi|dati di'; then
  HINT="$HINT · la forma dei dati BC è già censita: docs/bc/endpoints/ (indice: python3 tools/bc_index.py) — non si presume, si legge"
fi
if echo "$PROMPT" | grep -qiE 'corregg|sistem|fix|bug'; then
  HINT="$HINT · prima di correggere: il banco, e la domanda di dominio in cima"
fi
jq -n --arg ctx " metodo attivo: esegui-non-dedurre · oracolo prima della formula · banco prima della correzione · SAL prima del passo successivo${HINT}" \
  '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}'
