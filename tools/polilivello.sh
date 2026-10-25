#!/bin/bash
# polilivello.sh — lo scaffold MECCANICO dell'analisi polilivello (skill
# polilivello). Produce il grezzo di L2 (struttura) e i semi di L4/L5
# (meccanica e storia): entrypoint, fogli e cartelle toccati, dipendenze
# esterne, formule candidate, date, marcatori di debito. Il SENSO — L1
# l'identità, L3 il comportamento, L6 la critica — non è meccanico: lo compila
# l'agente col protocollo della skill, citando. Questo tool esiste perché i
# primi quattro livelli di grezzo sono sempre gli stessi grep, e farli a mano
# costa il tempo della comprensione vera.
#
# Uso: bash tools/polilivello.sh <dir-progetto>
# Esce 0 (è uno studio, non un gate; il verdetto è il report stesso) · 1 uso.
set -uo pipefail
DIR="${1:-}"
# (sesto ventaglio, rinviati di S3 R6): una cartella relativa che comincia col trattino e' un percorso, non un'opzione.
case "$DIR" in -*) DIR="./$DIR" ;; esac
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
  echo "uso: polilivello.sh <dir-progetto>" >&2; exit 1
fi

echo "# Scaffold polilivello — $(basename "$DIR") ($(date +%F))"
echo ""

# --- L2: struttura ---
FILES=$(find "$DIR" -type f \( -name '*.js' -o -name '*.gs' -o -name '*.html' -o -name '*.json' \) | wc -l | tr -d ' ')
RIGHE=$(find "$DIR" -type f \( -name '*.js' -o -name '*.gs' \) -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
echo "## L2 struttura (meccanico)"
echo "File codice: $FILES · righe js/gs: $RIGHE"
echo ""
# N.B. i progetti GAS di questo parco nominano gli entrypoint con VERBI DI
# DOMINIO italiani (analizza, calcola, genera...): il grep solo doGet/main/run
# li mancherebbe TUTTI — successo sul primo bersaglio vero (analizzaRatingClienti)
echo "### Entrypoint (trigger standard + verbi di dominio italiani)"
grep -rnE "function (doGet|doPost|onOpen|onEdit|onInstall|main|init|run[A-Z_]|[aA]nalizza|[cC]alcola|[gG]enera|[aA]ggiorna|[cC]ontrolla|[eE]sporta|[iI]mporta|[pP]repara|[vV]erifica|[sS]incronizza)[A-Za-z_]*\(" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | head -12 | sed 's/^/  /'
TRG=$(grep -rnE "ScriptApp\.newTrigger|TriggerBuilder" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | head -5)
[ -n "$TRG" ] && { echo "  trigger programmatici:"; echo "$TRG" | sed 's/^/    /'; }
echo ""
# gli ID spesso stanno in const in testa (folderInputId = '1-IPY...'), non in
# letterale dentro la chiamata: si greppe l'assegnazione E i letterali lunghi
echo "### Fogli / cartelle / documenti toccati (ID in const o letterali)"
grep -rnE "(const|let|var) +[a-zA-Z_]+(Id|ID) *=" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | head -6 | sed 's/^/  /'
grep -rhoE "['\"][A-Za-z0-9_-]{25,}['\"]" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | sort -u | head -6 | sed 's/^/  ID: /'
echo ""
echo "### Dipendenze esterne"
grep -rlE "UrlFetchApp" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | head -3 | sed 's/^/  UrlFetch: /'
grep -rhoE "ODataV4|Business Central|graph\.microsoft|api\.businesscentral" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | sort -u | head -3 | sed 's/^/  BC: /'
# (riga riparata 2026-08-29 al PRIMO uso esterno — Centrale_Rischi: un avanzo
# di scrittura `| semi=$(cat)` mandava unbound-variable alla riga Properties)
grep -rlE "PropertiesService" "$DIR" --include='*.js' --include='*.gs' 2>/dev/null | head -3 | sed 's/^/  Properties: /' || true
echo ""

# --- L4: semi di meccanica ---
echo "## L4 semi di meccanica"
echo "### Formule candidate (righe con aritmetica assegnata)"
grep -rnE "(\*|/)[[:space:]]*[0-9]+|[a-zA-Z_]+[[:space:]]*=[[:space:]]*[a-zA-Z_]+[[:space:]]*(\+|-|\*|/)[[:space:]]*" "$DIR" --include='*.gs' --include='*.js' 2>/dev/null | grep -vE "//|function |if |for |while " | head -10 | sed 's/^/  /'
echo ""
# costanti magiche: numeri ≥3 cifre o decimali DENTRO espressioni, con la riga
# intera come contesto (1000*60*60*24 nel rating è la conversione giorno-in-ms:
# un'assunzione su COME si misura il tempo, sepolta come moltiplicazione)
echo "### Assunzioni implicite (costanti magiche in espressioni)"
grep -rnE "[0-9]{3,}|[0-9]+\.[0-9]+" "$DIR" --include='*.gs' --include='*.js' 2>/dev/null | grep -E "(\*|/|\+|-) *[0-9]|[0-9] *(\*|/)" | grep -vE "function |Logger|log\(" | head -6 | sed 's/^/  /'
echo ""

# --- L5: semi di storia ---
echo "## L5 semi di storia"
echo "### Date citate nel codice"
grep -rhoE "20[12][0-9]-[01][0-9]-[0-3][0-9]" "$DIR" --include='*.gs' --include='*.js' --include='*.json' 2>/dev/null | sort -u | tail -5 | sed 's/^/  /'
echo "### Marcatori di debito (TODO, FIXME, si potrebbe, andrebbe, legacy)"
grep -rniE "TODO|FIXME|si potrebbe|andrebbe|legacy|da fare" "$DIR" --include='*.gs' --include='*.js' 2>/dev/null | head -8 | sed 's/^/  /'
if [ -d "$DIR/.git" ]; then
  echo "### git log (ultimi 5)"
  git -C "$DIR" log --oneline -5 2>/dev/null | sed 's/^/  /'
fi
echo ""
echo "## Da compilare a mano (il protocollo della skill polilivello)"
echo "  L1 Identità: <una riga guadagnata>"
echo "  L3 Cosa fa: <per entrypoint: trigger → input → output>"
echo "  L6 Come potrebbe farlo meglio: <dopo le provocazioni P1-P10 della skill brainstorming>"
