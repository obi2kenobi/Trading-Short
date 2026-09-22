#!/bin/bash
# ⚠ QUESTO TOOL SCRIVE: copia CLAUDE.md, .claude/, .opencode/, patterns/, tools/hook dentro la repo corrente (all'installazione dello standard)
# garante-standard.sh — rende l'installazione di AI_Programmer OBBLIGATORIA:
# gira a OGNI sessione su QUALSIASI repo (via ~/.claude/settings.json, livello utente)
# e se il repo non ha lo standard, LO INSTALLA senza chiedere. Il metodo diventa
# un fatto, non una scelta: non dipende da chi se lo ricorda.
#
# Come funziona:
#   1. individua l'hub AI_Programmer più vicino (env AI_PROGRAMMER_HUB o percorso fisso)
#   2. verifica se il repo corrente ha .claude/settings.json con i nostri hook
#   3. se NON li ha: copia CLAUDE.md, .claude/settings.json, .claude/skills, .claude/agents,
#      .opencode, patterns, tools hook — come sync-repo.sh --standard ma in un comando
#      silenzioso che gira da hook, senza che nessuno debba ricordarsi di invocarlo
#   4. se LI HA già: silenzio (nessun costo, nessun output)
#
# Installazione (una volta, a livello UTENTE):
#   bash tools/install-garante.sh
set -uo pipefail
# (morso 6, 2026-09-15): il percorso FISSO mentiva quando il garante gira da UNA COPIA
# DIVERSA dell'hub (l'automazione notturna): confrontava il metodo del branch notte contro
# il metodo della copia workspace, non aggiornata — falso DIVERGE che bocciava i fix del
# turno. L'HUB e' la copia DA CUI il garante stesso vive: dirname $0/.. Il fisso resta
# solo come ripiego se chi lo invoca non e' dentro un hub (SessionStart utente).
SELF_HUB="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$SELF_HUB/.claude/skills" ] && HUB="$SELF_HUB" || HUB="${AI_PROGRAMMER_HUB:-$HOME/.zcode/workspace/default/AI_Programmer}"
CWD="${CLAUDE_PROJECT_DIR:-$PWD}"

# l'hub deve esistere: se no, silenzio (non possiamo installare da dove non c'è)
[ -d "$HUB/.claude/skills" ] || exit 0

# il repo corrente È l'hub? non installare su se stesso
[ "$(cd "$CWD" 2>/dev/null && pwd)" = "$(cd "$HUB" 2>/dev/null && pwd)" ] && exit 0

# già installato? (settings.json con il nostro SessionStart hook)
if [ -f "$CWD/.claude/settings.json" ]; then
  if jq -e '.hooks.SessionStart // empty | length > 0' "$CWD/.claude/settings.json" >/dev/null 2>&1; then
    # (fase B adattiva, 2026-09-07): installazione ESISTENTE — se il canone dell'hub
    # e' cresciuto rispetto a quello installato, si AVVERTE (mai sovrascrivere: il repo
    # puo' aver personalizzato). Un'installazione ferma al mese scorso insegnerebbe il
    # metodo del mese scorso: il garante che non guarda la deriva e' un garante una-tantum.
    if ! diff -q "$HUB/.claude/skills/gas-sviluppo/references/metodo.md"                  "$CWD/.claude/skills/gas-sviluppo/references/metodo.md" >/dev/null 2>&1; then
      echo "⚠ AI_Programmer: il metodo installato qui DIVERGE da quello dell'hub (regole nuove mancate)." >&2
      echo "  per aggiornare: bash $HUB/tools/sync-repo.sh --standard (dall'hub, scelta consapevole)" >&2
    fi
    exit 0
  fi
fi

# (giro 27, 2026-09-20): un settings.json PROPRIO senza i nostri hook veniva SOVRASCRITTO dal
# cp qui sotto — la personalizzazione del progetto persa da un hook silenzioso. Si avverte,
# non si tocca: l'installazione su una repo che ha gia' scelto i suoi hook e' una scelta umana.
if [ -f "$CWD/.claude/settings.json" ]; then
  echo "⚠ AI_Programmer: $CWD ha un .claude/settings.json proprio senza i nostri hook — non lo sovrascrivo (per installare: bash $HUB/tools/sync-repo.sh --standard, scelta consapevole)" >&2
  exit 0
fi

# NON installato → INSTALLA
echo "STANDARD AI_PROGRAMMER INSTALLATO automaticamente su $CWD" >&2

# (giro 27): niente mkdir di patterns qui — la creava vuota e il ciclo sotto la vedeva «gia' presente»
mkdir -p "$CWD/.claude" "$CWD/.opencode"

# CLAUDE.md (se non esiste già un CLAUDE.md proprio)
[ -f "$CWD/CLAUDE.md" ] || cp "$HUB/CLAUDE.md" "$CWD/CLAUDE.md"

# settings.json (gli hook:SessionStart/UserPromptSubmit/PreToolUse)
cp "$HUB/.claude/settings.json" "$CWD/.claude/settings.json"

# skill, agenti, specchi OpenCode, pattern: solo dove la cartella NON esiste. (giro 27,
# 2026-09-20): `cp -R dir dir` su una destinazione esistente ANNIDA (skills/skills) e
# sovrascrive il personalizzato; una cartella gia' presente si dichiara e si lascia stare.
for D in .claude/skills .claude/agents .opencode/agent .opencode/skills patterns; do
  if [ -e "$CWD/$D" ]; then
    echo "  $D: gia' presente, non toccato" >&2
  else
    mkdir -p "$CWD/$(dirname "$D")"
    cp -R "$HUB/$D" "$CWD/$D" 2>/dev/null || echo "  $D: copia fallita" >&2
  fi
done

# hook scripts: TUTTI gli eventi, derivati da settings.json (giro 27 — D34: qui si leggeva
# solo .hooks.PreToolUse, e tools/metodo-reminder-hook.sh — SessionStart/UserPromptSubmit/
# Stop — restava a terra: ogni repo installata dal garante aveva un settings.json che punta
# a uno script inesistente. La lista la deriva tools/copia-hook.sh, la stessa di sync-repo.)
mkdir -p "$CWD/tools"
bash "$HUB/tools/copia-hook.sh" "$CWD" >/dev/null \
  || echo "⚠ AI_Programmer: copia degli hook fallita — settings.json punta a script che qui mancano" >&2

# le lenti dello standard (fixture-provenienza, cita-verifica): contromisure REPO-V 7/9
for L in fixture-provenienza.sh cita-verifica.sh debiti-riapertura.sh; do
  [ -f "$HUB/tools/$L" ] && cp "$HUB/tools/$L" "$CWD/tools/$L"
done

# .night-verify minimo se assente
if [ ! -f "$CWD/.night-verify" ]; then
  echo "# Verifiche del turno di notte (VUOTO = il gate lo dice)" > "$CWD/.night-verify"
fi

echo "Installato: CLAUDE.md, skill, agenti, hook, patterns. Il metodo è ora STRUTTURALE in questo repo." >&2
