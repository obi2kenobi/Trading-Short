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
# dove <percorso>: il percorso, e se nella repo non c'e' (un satellite) la nota che vive nell'hub
# (2026-09-24, notte dei giri, T1#4: nei satelliti i promemoria mandavano l'agente a file assenti)
dove() {   # con un * si guarda se il glob trova qualcosa, senza si guarda il percorso
  case "$1" in *\**) compgen -G "$PWD/$1" >/dev/null 2>&1 ;; *) [ -e "$PWD/$1" ] ;; esac \
    && printf '%s' "$1" || printf "%s (nell'hub AI_Programmer)" "$1"
}
# prudente_nega <input grezzo>: rc 0 = da negare. Il modo prudente (jq assente, o il gancio morto) non sa spogliare il
# comando: nega le forme dirette di clasp push/deploy e deploy-ora. (2026-09-25, settimo ventaglio, V4 R1): e anche un
# runner di script (npm, yarn, pnpm, bun) quando un package.json qui o in una cartella sopra, o nel progetto, ha uno
# script che fa clasp push/deploy. Il ramo completo che lo nega era proprio quello che moriva sul Mac, e il prudente
# lasciava passare `npm run pubblica`. Una sola funzione per i due rami: prima il grep viveva copiato in tutti e due.
prudente_nega() {
  grep -qE 'clasp[^"]*[^a-z](push|deploy|create-deployment|update-deployment|undeploy|delete-deployment|run-function)([^a-z]|$)|deploy-ora' <<<"$1" && return 0
  grep -qE '(^|[^a-z])(npm|yarn|pnpm|bun)([^a-z]|$)' <<<"$1" || return 1
  local d="$PWD"
  while :; do
    grep -qsE '"[^"]*"[[:space:]]*:[[:space:]]*"[^"]*clasp[^"]*[^a-z](push|deploy)' "$d/package.json" && return 0
    [ "$d" = / ] && break
    d="${d%/*}"; [ -n "$d" ] || d=/
  done
  [ -n "${CLAUDE_PROJECT_DIR:-}" ] && grep -qsE '"[^"]*"[[:space:]]*:[[:space:]]*"[^"]*clasp[^"]*[^a-z](push|deploy)' "$CLAUDE_PROJECT_DIR/package.json" && return 0
  return 1
}
# (2026-09-23, giro A1 della notte): senza jq il cancello era APERTO (`|| exit 0`), e senza JSON
# solo `exit 2` blocca (documentazione degli hook di Claude Code). Senza jq: MODO PRUDENTE — un
# grep sull'input grezzo nega push/deploy/deploy-ora con exit 2; tutto il resto passa. Puo'
# negare a torto una citazione (niente spoglio senza jq): meglio un falso rosso che un cancello aperto.
if ! command -v jq >/dev/null 2>&1; then
  GREZZO="$(cat)"
  if prudente_nega "$GREZZO"; then
    echo "NEGATO (clasp-block-hook, jq ASSENTE: modo prudente): clasp push/deploy e deploy-ora sono dell'umano. Installa jq per il cancello completo." >&2
    exit 2
  fi
  exit 0
fi

INPUT="$(cat)"
# (2026-09-24, quarto ventaglio, Q5): un errore interno del gancio (una variabile non inizializzata sotto
# set -u, scritta da me lo stesso giorno) usciva 1 senza decisione — per Claude Code un errore NON
# bloccante: il comando passava, clasp push compreso. Se il gancio muore, decide il modo prudente di
# «jq assente»: push/deploy/deploy-ora negati con exit 2, il resto passa.
prudente() {
  local rc=$?; [ "$rc" -eq 0 ] && return 0
  if prudente_nega "$INPUT"; then
    echo "NEGATO (clasp-block-hook, errore interno rc=$rc: modo prudente): clasp push/deploy e deploy-ora sono dell'umano." >&2
    exit 2
  fi
  exit 0
}
trap prudente EXIT
CMD="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$CMD" ] && exit 0
TOOL="$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)"
# (2026-09-24, quarto ventaglio, Q5 R4): anche Monitor esegue un comando di shell (tool_input.command) —
# il gancio lo ignorava, e settings.json non lo registrava
case "$TOOL" in Bash|Monitor) ;; *) exit 0 ;; esac

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
# (2026-09-24, quarto ventaglio, Q5 R4/R6) Fuori anche, per nome: gli interpreti non shell (`python3 -c
# "subprocess.run(['clasp','push'])"`, `node -e "execSync(…)"`), il backslash (`pu\sh`, `\clasp`), le
# graffe (`clasp {push,}`), le variabili e le sostituzioni (`c=clasp; $c push`), `$'push'`, e su macOS le
# maiuscole (`Clasp push` su un disco che non le distingue). Sono forme da aggressore, non da errore.
# (revisione 10 giri, 2026-09-23): SEP accettava solo inizio riga e ; & | — undici forme
# comuni della shell passavano: il LOOP generato (`for …; do clasp push; done`, la forma
# dell'incidente REPO-Q), `(…)`, `{ …; }`, `if …; then …`, e i prefissi che eseguono il
# comando che segue (time, nohup, exec, xargs). Ora SEP riconosce anche ( { e le parole della
# shell che aprono un comando. I prefissi ARBITRARI (env, sudo) restano fuori, per la ragione
# detta sotto.
# (2026-09-23, giro A1 della notte): 17 forme comuni passavano ancora, provate eseguendo — le parole
# che ESEGUONO il comando che segue (if, !, while, until, timeout N, command, nice, watch, xargs con
# opzioni, find -execdir, parallel), le opzioni di clasp PRIMA del sottocomando (`clasp -A f push`),
# e `deploy` combaciava con `deployments`, che elenca soltanto. Tre pezzi: PREF, OPT, FINE.
PREF='(do|then|else|elif|if|while|until|!|time|nohup|exec|eval|source|command|watch([[:space:]]+-[^[:space:]]+)*|nice([[:space:]]+-n[[:space:]]*-?[0-9]+|[[:space:]]+-[0-9]+)?|timeout([[:space:]]+-[^[:space:]]+([[:space:]]+[0-9.]+[smhd]?)?)*[[:space:]]+[0-9.]+[smhd]?|xargs([[:space:]]+-[^[:space:]]+([[:space:]]+[0-9]+)?)*|-exec(dir)?|parallel([[:space:]]+-[^[:space:]]+)*)'
SEP="(^|[;&|({][[:space:]]*|(^|[;&|({][[:space:]]*|[[:space:]])${PREF}[[:space:]]+)"
RUN='((npx|bunx|npm[[:space:]]+exec|pnpm[[:space:]]+dlx|yarn[[:space:]]+dlx)[[:space:]]+(-{1,2}[A-Za-z0-9-]+[[:space:]]+)*)?'
BIN='([A-Za-z0-9_./-]*/)?(@google/)?'
OPT='([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:];&|][^[:space:];&|]*)?)*'
# (giri lenti 2/10, area 20 R1, provato eseguendo) VARS — assegnazioni di variabile davanti al comando (`CI=1 npx clasp push`, la forma tipica di un comando generato da un agente) e
# VERSIONE — la versione dopo il nome (`npx @google/clasp@latest push`) passavano. Una VAR=val seguita da clasp NON ha il rischio del falso positivo di `env`/`sudo` (non apre a un comando
# arbitrario: l'ancora SEP e il sottocomando push|deploy restano), quindi si riconosce. Restano fuori `env`, `sudo`, `ssh`, `yarn clasp` (forme da aggressore, dichiarate sotto).
VARS='([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*'
VERSIONE='(@[A-Za-z0-9._^~-]+)?'
FINE='([[:space:];&|)"'"'"']|$)'
INVOCAZIONE="${SEP}${VARS}${RUN}${BIN}clasp${VERSIONE}${OPT}[[:space:]]+(push|deploy|create-deployment|update-deployment|undeploy|delete-deployment|run-function|run)${FINE}"
# `bash -c "…"` (e sh/zsh/dash): le virgolette sono DATI per lo spoglio qui sotto, ma
# l'interprete le ESEGUE — si guarda il comando intero, con l'invocazione dentro le virgolette.
# (Q5 R4): la shell anche dopo `/` (/bin/bash), con opzioni lunghe o con argomento prima di -c (--norc,
# -o pipefail), `--` dopo -c; e `eval "…"`, che esegue la stringa come bash -c
SHC="(^|[;&|({[:space:]/])((ba|z|da)?sh[[:space:]]+(-{1,2}[A-Za-z-]+([[:space:]]+[a-z]+)?[[:space:]]+)*-[A-Za-z]*c([[:space:]]+--)?|eval)[[:space:]]+[\"']([^\"']*[;&|({][[:space:]]*)?${VARS}${RUN}${BIN}clasp${VERSIONE}${OPT}[[:space:]]+(push|deploy|create-deployment|update-deployment|undeploy|delete-deployment|run-function|run)${FINE}"

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
# (revisione 10 giri, 2026-09-23): lo spoglio lavorava PER RIGA (sed) — uno span fra backtick
# che va a capo non si toglieva, e il SAL che documentava le forme vietate e' stato negato.
# Ora l'a capo diventa `;` (e' un separatore della shell: «cd x⏎clasp push» resta negato),
# poi si tolgono i backtick (anche su piu' righe), poi le virgolette. Il controllo `bash -c`
# guarda il comando SENZA backtick ma CON le virgolette: fra backtick e' un dato citato.
# (2026-09-23, sì di Luca): il CORPO di un heredoc e' dato, non comando. Misurato due volte in una
# sessione: un heredoc che scriveva un file (python che riscrive CLAUDE.md, `cat >> SAL.md`)
# citava la regola «(… MAI)» fra parentesi e veniva NEGATO: l'a capo diventa `;`, la `(` e' un
# separatore, e il testo del file sembrava un'invocazione. Il corpo si toglie — tranne quando
# resta prudente tenerlo: la riga del heredoc nutre una SHELL (`bash <<EOF`, `cat <<EOF | sh`:
# quel corpo si esegue), la riga ha piu' di un heredoc, o il heredoc non si chiude mai.
# `<<<` (herestring) non e' un heredoc. Banco: tests/test-clasp-block-hook.sh, casi «heredoc».
senza_heredoc() {
  awk -v Q="'" '
    function scrivi_buf() { printf "%s", buf; buf = "" }
    dentro {
      t = $0; if (trattino) sub(/^\t+/, "", t)
      if (t == delim) { dentro = 0; buf = ""; next }
      buf = buf $0 "\n"; next
    }
    {
      print
      riga = $0; n = 0; resto = riga; re = "<<-?[ \t]*[\"" Q "]?[A-Za-z_][A-Za-z0-9_]*"
      while (match(resto, re)) {
        prima = (RSTART > 1) ? substr(resto, RSTART - 1, 1) : ""
        op = substr(resto, RSTART, RLENGTH)
        if (prima != "<" && substr(op, 3, 1) != "<") { n++; trovato = op }
        resto = substr(resto, RSTART + RLENGTH)
      }
      if (n != 1) next
      if (riga ~ /(^|[;&|({ \t\/])((ba|z|da)?sh|source|\.)([ \t<]|$)/) next   # (Q5 R4): anche /bin/bash, bash<<, source, .
      trattino = (substr(trovato, 3, 1) == "-")
      d = trovato; sub(/^<<-?[ \t]*/, "", d); gsub("[\"" Q "]", "", d)
      delim = d; dentro = 1; buf = ""
    }
    END { if (dentro) scrivi_buf() }
  '
}
CMD_H=$(printf '%s\n' "$CMD" | senza_heredoc)
CMD_UNA=$(printf '%s' "$CMD_H" | tr '\n' ';')
CMD_NOBT=$(printf '%s' "$CMD_UNA" | sed "s/\`[^\`]*\`//g")
# (Q5 R6): gli apici ATTACCATI a una parola senza spazi si tolgono prima dello spoglio — `clasp "push"` e
# `clasp 'deploy'` (forme comuni negli script generati) diventavano `clasp ` e passavano. Una stringa con
# spazi resta un dato (`grep 'npx clasp push' docs`).
CMD_ATT=$(printf '%s' "$CMD_NOBT" | sed -E "s/\"([^\" ]*)\"/\\1/g; s/'([^' ]*)'/\\1/g")
CMD_STRIPPED=$(printf '%s' "$CMD_ATT" | sed "s/'[^']*'//g; s/\"[^\"]*\"//g")

# NEGATO davvero: scrittura in produzione senza staging e senza rollback
if grep -qE "$INVOCAZIONE" <<<"$CMD_STRIPPED" || grep -qE "$SHC" <<<"$CMD_NOBT"; then
  jq -n --arg r "NEGATO (clasp-block-hook): clasp push/deploy scrive in PRODUZIONE senza staging né rollback. La regola è del metodo AI_Programmer: il deploy è dell'umano, che prima confronta col vivo (clasp clone + diff). Se il push è davvero giusto, lo fa Luca a mano." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
fi

# (2026-09-23, giro A7 della notte): deploy-ora e' il GESTO di Luca, dal suo terminale — un agente
# non lo invoca. Prima `echo si | bash tools/deploy-ora.sh X` passava questo cancello (vede solo il
# comando esterno) e deploiava. Si nega l'invocazione, non la citazione: `grep deploy-ora …` passa.
DEPLOY_ORA="${SEP}${RUN}((ba|z|da)?sh[[:space:]]+)?([A-Za-z0-9_./~-]*/)?deploy-ora(\.sh)?([[:space:]]|;|$)"
if grep -qE "$DEPLOY_ORA" <<<"$CMD_STRIPPED"; then
  jq -n --arg r "NEGATO (clasp-block-hook): deploy-ora e' il gesto del deploy di Luca, dal suo terminale — un agente non lo invoca (il deploy e' dell'umano). Prepara il pacchetto con $(dove tools/prepara-deploy.sh) e lascialo a lui." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
fi

# H7a: la via documentata — npm run push / npm run deploy — risolta da package.json
# (2026-09-24, quarto ventaglio, Q5 R3): si risolveva solo `(npm|…) run <nome>` e solo nel package.json di
# $PWD — passavano `pnpm push`, `yarn push`, `bun push` (senza run), `npm start`, le catene (`dp` → `npm run
# push`), `npm --prefix sub …`, `cd sub && npm run …`: eseguivano davvero clasp push col clasp finto. Ora:
# gli script di OGNI package.json sotto $PWD (profondita' 3, node_modules fuori) che arrivano a clasp
# push/deploy, anche per catena, sono vietati per NOME a qualunque runner nello stesso segmento.
if grep -qE '(^|[^A-Za-z0-9_-])(npm|yarn|pnpm|bun)([[:space:]]|$)' <<<"$CMD_STRIPPED"; then
  # (2026-09-24, quinto ventaglio, R2 R3): npm risale le cartelle fino al package.json piu' vicino, e qui si
  # cercava solo da $PWD in giu' — da src/ (la forma normale di un progetto clasp) `npm run push` usava il
  # package.json della radice e passava. Ora: la cartella della sessione (campo cwd dell'input, se no $PWD),
  # i package.json sotto di lei e sotto la radice del progetto (CLAUDE_PROJECT_DIR, se no la radice git), e
  # quelli delle cartelle antenate, come fa npm.
  QUI=$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null); [ -d "$QUI" ] || QUI="$PWD"
  RADICE="${CLAUDE_PROJECT_DIR:-$(git -C "$QUI" rev-parse --show-toplevel 2>/dev/null || echo "$QUI")}"
  SCRIPTS=$( { find "$QUI" "$RADICE" -maxdepth 3 -name node_modules -prune -o -name package.json -print 2>/dev/null
               SU="$QUI"; while [ -n "$SU" ] && [ "$SU" != / ]; do [ -f "$SU/package.json" ] && echo "$SU/package.json"; SU=$(dirname "$SU"); done; } \
    | sort -u | while IFS= read -r PJ; do jq -r --arg f "$PJ" '(.scripts // {}) | to_entries[] | "\($f)\t\(.key)\t\(.value)"' "$PJ" 2>/dev/null; done)
  VIETATI=""; ORIGINE=""
  for _giro in 1 2 3 4; do   # catene: fino al punto fisso, al massimo 4 anelli
    while IFS=$'\t' read -r PJ NOME VAL; do
      [ -n "$NOME" ] || continue
      grep -qxF "$NOME" <<<"$VIETATI" && continue
      if grep -qE "$INVOCAZIONE" <<<"$VAL" || { [ -n "$VIETATI" ] && grep -qE "(npm|yarn|pnpm|bun)[[:space:]]+((run|run-script)[[:space:]]+)?($(tr '\n' '|' <<<"$VIETATI" | sed 's/|$//; s/[.[*^$()+?{]/\\&/g'))([[:space:];&|]|$)" <<<"$VAL"; }; then
        VIETATI=$(printf '%s\n%s' "$VIETATI" "$NOME" | sed '/^$/d'); ORIGINE="$ORIGINE $NOME:${PJ#"$QUI"/}"
      fi
    done <<<"$SCRIPTS"
  done
  while IFS= read -r SCR; do
    [ -n "$SCR" ] || continue
    SCR_RE=$(sed 's/[.[*^$()+?{|]/\\&/g' <<<"$SCR")
    if grep -qE "(^|[^A-Za-z0-9_-])(npm|yarn|pnpm|bun)([[:space:]]+[^;&|]*)?[[:space:]]${SCR_RE}([[:space:];&|)]|$)" <<<"$CMD_STRIPPED"; then
      jq -n --arg r "NEGATO (clasp-block-hook): lo script «${SCR}» ($(tr ' ' '\n' <<<"$ORIGINE" | grep "^$SCR_RE:" | head -1 | cut -d: -f2-)) arriva a clasp push/deploy — scrive in PRODUZIONE senza staging né rollback. Il deploy è dell'umano (report REPO-I H7; quarto ventaglio Q5: runner senza run, npm start, catene, sottocartelle)." \
        '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
      exit 0
    fi
  done <<<"$VIETATI"
fi

# (dal campo REPO-Q 2026-09-02: l'agente ha GENERATO un loop di clasp push
# che includeva directory dichiarate clone-di-sola-lettura nel CLAUDE.md del
# repo — Luca l'ha eseguito e ha sovrascritto 2 progetti sviluppati altrove.
# La guardia ora verifica anche il caso GENERAZIONE)
if grep -qE "$INVOCAZIONE" <<<"$CMD"; then
  MB="$PWD/.mirror-boundaries"
  if [ -f "$MB" ]; then
    jq -n --arg c "ATTENZIONE: questa directory ha .mirror-boundaries (cloni di sola lettura). Un clasp push qui sovrascriverebbe progetti sviluppati altrove. Verifica PRIMA di eseguire." \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$c}}'
    exit 0
  fi
fi

# (Q27, 2026-09-23): qui e sopra `grep … <<<"$X"`, mai `echo "$X" | grep -q` — sotto pipefail, su un
# comando di molte righe il produttore moriva di SIGPIPE e l'avviso taceva (5 su 5, tests/test-e002-codice.sh)
# ADVISORY: comandi che leggono/passano credenziali — possibili e a volte
# legittimi, ma chi li lancia deve sapere cosa sta toccando
if grep -qE 'clasp\.json|credenziali|\.env|printenv|secret|token[_ =]|refresh_token' <<<"$CMD"; then
  jq -n --arg c "Questo comando tocca credenziali: mai nel diff, mai nei log, mai in chat (pattern segreto-come-impronta). Se stai solo LEGGENDO per verificare un'impronta, ok — ma l'output resta locale." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$c}}'
  exit 0
fi

exit 0
