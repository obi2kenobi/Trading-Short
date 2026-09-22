#!/bin/bash
# clasp-block-hook.sh — il DENTE della regola «clasp push MAI» (giri avversari
# 2026-08-28, attacco B8/F1: la regola viveva solo nei promemoria — nessun
# blocco tecnico, un agente confuso poteva deployare in produzione).
# PreToolUse su Bash: `clasp push` e `clasp deploy` vengono NEGATI davvero
# (permissionDecision: deny). I comandi che toccano credenziali ricevono un
# CONTESTO di avviso (advisory: leggere le proprie credenziali a volte è
# legittimo — dipende da cosa se ne fa). Tutto il resto: silenzio.
#
# Il deploy è dell'umano: questa è l'unica regola del sistema che da oggi
# non dipende dalla memoria dell'agente.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat)"
CMD="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$CMD" ] && exit 0
TOOL="$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$TOOL" = "Bash" ] || exit 0

# Che cos'è un'INVOCAZIONE di clasp (una definizione, usata da entrambi i rami sotto:
# prima viveva copiata in due grep che potevano divergere).
#   SEP  — a inizio comando o dopo un separatore shell. Dal campo REPO-E 2026-09-01:
#          il grep libero negava un `git commit` il cui MESSAGGIO citava la forma
#          vietata (falso positivo 2 volte in una sessione). L'ancora resta.
#   RUN  — un runner noto davanti al comando, con le sue opzioni. Dal campo (REPO-V,
#          progetto GAS nuovo, 2026-09-03): l'ancora da sola lasciava passare
#          `npx clasp push`, perché `npx ` è uno spazio e non un separatore — ed è LA
#          forma normale di invocare clasp dove non è installato globalmente. Il
#          cancello passava tutte le sue attese ed era comunque scavalcabile.
#   BIN  — percorso al binario (./node_modules/.bin/clasp) e scope del pacchetto
#          (@google/clasp).
# NON coperti, per scelta dichiarata: prefissi di ambiente (`env FOO=1 clasp push`),
# `sudo`, alias di shell. Riconoscerli vorrebbe dire accettare un comando arbitrario
# davanti a clasp, e riaprirebbe il falso positivo appena difeso. Questo è un cancello
# contro l'errore, non contro un aggressore (attese e limiti: tests/test-clasp-block-hook.sh).
SEP='(^|[;&|][[:space:]]*)'
RUN='((npx|bunx|npm[[:space:]]+exec|pnpm[[:space:]]+dlx|yarn[[:space:]]+dlx)[[:space:]]+(-{1,2}[A-Za-z0-9-]+[[:space:]]+)*)?'
BIN='([A-Za-z0-9_./-]*/)?(@google/)?'
INVOCAZIONE="${SEP}${RUN}${BIN}clasp[[:space:]]+(push|deploy)"

# (report REPO-I 2026-09-19, H7 — due buchi misurati eseguendo):
#   a) `npm run push` non contiene la stringa clasp e PASSAVA — ed e' la via che
#      i documenti del progetto insegnano. Ora il cancello risolve gli script di
#      package.json: se il comando risolto contiene l'invocazione, nega.
#   b) due grep in SOLA LETTURA erano negati perche' la STRINGA DI RICERCA
#      conteneva 'npx clasp push' — il runner dentro le virgolette combaciava con
#      RUN. Le stringa quotate sono DATI, non invocazioni: si spogliano prima del
#      match. (Dichiarato non coperto: `bash scripts/deploy.sh` richiederebbe
#      leggere script arbitrari — la via lunga sta nella P6 del report.)
# (D27, test del sistema completo 2026-09-20): anche i BACKTICK sono dati — il comando che
# scriveva il report di campo (heredoc con `npx clasp push` citato come forma vietata)
# e' stato NEGATO. Stesso falso positivo di REPO-E in una forma nuova.
CMD_STRIPPED=$(printf '%s' "$CMD" | sed "s/'[^']*'//g; s/\"[^\"]*\"//g; s/\`[^\`]*\`//g")

# NEGATO davvero: scrittura in produzione senza staging e senza rollback
if printf '%s' "$CMD_STRIPPED" | grep -qE "$INVOCAZIONE"; then
  jq -n --arg r "NEGATO (clasp-block-hook): clasp push/deploy scrive in PRODUZIONE senza staging né rollback. La regola è del metodo AI_Programmer: il deploy è dell'umano, che prima confronta col vivo (clasp clone + diff). Se il push è davvero giusto, lo fa Luca a mano." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
fi

# H7a: la via documentata — npm run push / npm run deploy — risolta da package.json
if [ -f "$PWD/package.json" ] && printf '%s' "$CMD_STRIPPED" | grep -qE '(npm|yarn|pnpm|bun)[[:space:]]+(run|run-script)[[:space:]]+[A-Za-z0-9_.:-]+'; then
  for SCR in $(printf '%s' "$CMD_STRIPPED" | grep -oE '(npm|yarn|pnpm|bun)[[:space:]]+(run|run-script)[[:space:]]+[A-Za-z0-9_.:-]+' | awk '{print $NF}' | sort -u); do
    RISOLTO=$(jq -r --arg s "$SCR" '.scripts[$s] // empty' "$PWD/package.json" 2>/dev/null)
    [ -z "$RISOLTO" ] && continue
    if printf '%s' "$RISOLTO" | grep -qE "$INVOCAZIONE"; then
      jq -n --arg r "NEGATO (clasp-block-hook): npm run $SCR risolve in \`$RISOLTO\` — clasp push/deploy scrive in PRODUZIONE senza staging né rollback. Il deploy è dell'umano (report REPO-I, H7: la via documentata era proprio quella non presidiata)." \
        '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
      exit 0
    fi
  done
fi

# (dal campo REPO-Q 2026-09-02: l'agente ha GENERATO un loop di clasp push
# che includeva directory dichiarate clone-di-sola-lettura nel CLAUDE.md del
# repo — Luca l'ha eseguito e ha sovrascritto 2 progetti sviluppati altrove.
# La guardia ora verifica anche il caso GENERAZIONE)
if echo "$CMD" | grep -qE "$INVOCAZIONE"; then
  MB="$PWD/.mirror-boundaries"
  if [ -f "$MB" ]; then
    jq -n --arg c "ATTENZIONE: questa directory ha .mirror-boundaries (cloni di sola lettura). Un clasp push qui sovrascriverebbe progetti sviluppati altrove. Verifica PRIMA di eseguire." \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$c}}'
    exit 0
  fi
fi

# ADVISORY: comandi che leggono/passano credenziali — possibili e a volte
# legittimi, ma chi li lancia deve sapere cosa sta toccando
if echo "$CMD" | grep -qE 'clasp\.json|credenziali|\.env|printenv|secret|token[_ =]|refresh_token'; then
  jq -n --arg c "Questo comando tocca credenziali: mai nel diff, mai nei log, mai in chat (pattern segreto-come-impronta). Se stai solo LEGGENDO per verificare un'impronta, ok — ma l'output resta locale." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$c}}'
  exit 0
fi

exit 0
