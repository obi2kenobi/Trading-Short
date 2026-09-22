#!/bin/bash
# pattern-reminder-hook.sh — hook PreToolUse (Edit|Write|Bash), 2026-08-24.
# Feedback di un utente esterno: la consultazione di patterns/ prima di certe modifiche
# dipendeva dalla memoria dell'agente in quel turno, non da un meccanismo del sistema.
# Quando il file_path toccato matcha una categoria sensibile (auth/secret/credential/
# token/login/password, incluse le varianti italiane), stampa un reminder con le righe
# pertinenti del registro patterns/README.md — non blocca mai l'operazione (allow sempre).
# 6° ciclo, set 3 (2026-08-24): esteso a Bash — il varco documentato nella voce SAL del
# 5° ciclo: l'hook copriva Edit|Write ma "non copre il modo in cui si è lavorato oggi
# (clasp deploy, probe su BC)". Un COMANDO che stampa/legge segreti (printenv, cat di
# .env/chiavi, curl con token in chiaro) ora riceve lo stesso reminder. Resta un
# reminder, non un cancello; l'estensione a UserPromptSubmit (confronto compito↔skill)
# resta decisione di Luca, come dichiarato nel SAL.
set -uo pipefail
# fallback jq: se assente, gli hook degradano al silenzio senza rompere la sessione
if ! command -v jq >/dev/null 2>&1; then exit 0; fi
HERE="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRO="$HERE/patterns/README.md"

# bug reale (revisione 14 lenti, 2026-08-28): `md5` non esiste su Linux (solo md5sum) —
# `printf '%s' "$PWD" | md5 | head -c 12` falliva silenziosamente, l'hash collassava a
# stringa vuota, e OGNI directory di lavoro finiva sullo stesso file di contatore
# ("/tmp/ai-programmer-sal-counter." — mai ripulito, vive fuori da qualunque scratch di
# test). Verificato dal vivo: la suite intera in ordine falliva a metà (39/87), il test
# da solo passava sempre — il verdetto dipendeva dallo stato residuo di ALTRE esecuzioni.
sal_hash() {
  if command -v md5 >/dev/null 2>&1; then
    printf '%s' "$1" | md5 | head -c 12
  elif command -v md5sum >/dev/null 2>&1; then
    printf '%s' "$1" | md5sum | head -c 12
  else
    printf '%s' "$1" | cksum | tr -d ' \t\n'
  fi
}

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"

# 2026-08-24, report sul campo (F5): la regola "SAL prima del passo successivo" è
# scritta due volte (CLAUDE.md + PROJECT.md) e veniva saltata comunque — il
# promemoria esisteva solo per il turno notturno (morning-gate), mai per una
# sessione diurna che edita molto senza toccare SAL.md. Contatore per directory di
# lavoro: dopo 5 edit senza SAL.md, il promemoria entra nel contesto (mai un blocco).
sal_promemoria() {
  local stato="/tmp/ai-programmer-sal-counter.$(sal_hash "$PWD")"
  case "$FILE_PATH" in
    */SAL.md|SAL.md) : > "$stato" 2>/dev/null; return 1 ;;
  esac
  [ -f "$PWD/SAL.md" ] || return 1
  local n
  n=$(($(cat "$stato" 2>/dev/null || echo 0) + 1))
  echo "$n" > "$stato" 2>/dev/null
  [ $((n % 5)) -eq 0 ] || return 1
  return 0
}

# ramo Bash: comandi che toccano/printano materiale sensibile
if [ -n "$COMMAND" ] && [ -z "$FILE_PATH" ]; then
  echo "$COMMAND" | grep -qiE '\.env|id_rsa|id_ed25519|\.pem|\.key|printenv|/usr/bin/security|keychain|repos\.key|Authorization:|Bearer |api[_-]?key|ZHIPUAI_API_KEY|GH_TOKEN' || exit 0
  HITS_B=""
  [ -f "$REGISTRO" ] && HITS_B="$(grep -E '^\| \[' "$REGISTRO" | grep -iE 'segreto|credenzial|token' | head -5)"
  if [ -n "$HITS_B" ]; then
    CTX_B="Il comando tocca materiale sensibile — pattern pertinenti in patterns/README.md prima di procedere:
$HITS_B"
  else
    CTX_B="Il comando tocca materiale sensibile — vale comunque CLAUDE.md \"Never expose secrets\" / \"Mask, don't omit\" / \"One-shot secret handoff\"."
  fi
  jq -n --arg ctx "$CTX_B" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",additionalContext:$ctx}}'
  exit 0
fi

[ -z "$FILE_PATH" ] && exit 0

# giri avversari 2026-08-28 (B1): il promemorio SAL scattava PRIMA del ramo
# sensibile e con l'exit 0 SOPPROMEVA il richiamo dei pattern — ogni quinto edit
# su un file di credenziali perdeva il contesto di sicurezza. Priorità invertita
# di documentazione contro sicurezza. Ora: il sensibile viene PRIMA, e il
# promemorio SAL gli si ACCODA (mai sostituisce).

CTX_SENS=""
if echo "$FILE_PATH" | grep -qiE 'auth|secret|credential|credenzial|token|login|password|segret'; then
  HITS=""
  if [ -f "$REGISTRO" ]; then
    HITS="$(grep -E '^\| \[' "$REGISTRO" | grep -iE 'segreto|credenzial|token' | head -5)"
  fi
  if [ -n "$HITS" ]; then
    CTX_SENS="File sensibile ($FILE_PATH) — pattern pertinenti in patterns/README.md prima di procedere:
$HITS"
  else
    CTX_SENS="File sensibile ($FILE_PATH) — nessun pattern specifico trovato nel registro patterns/README.md, ma vale comunque CLAUDE.md \"Never expose secrets\" / \"Mask, don't omit\" / \"One-shot secret handoff\"."
  fi
fi

CTX_SAL=""
if sal_promemoria; then
  CTX_SAL="Hai fatto $(( $(cat "/tmp/ai-programmer-sal-counter.$(sal_hash "$PWD")" 2>/dev/null || echo 0) )) edit e SAL.md non è tra questi — se in questo giro c'è una scoperta o una correzione, va scritta in SAL.md PRIMA del passo successivo (CLAUDE.md 'keep living documentation' + PROJECT.md del progetto). Un promemoria, non un blocco."
fi

[ -z "$CTX_SENS" ] && [ -z "$CTX_SAL" ] && exit 0
CTX="$CTX_SENS
$CTX_SAL"
[ "$CTX" = "
" ] && exit 0

jq -n --arg ctx "$CTX" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",additionalContext:$ctx}}'
