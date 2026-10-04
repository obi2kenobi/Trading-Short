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
# (2026-09-24, notte dei giri, T1#5): «ha .claude/skills» non basta — ce l'ha anche ogni satellite, e la
# copia del garante che vive in un satellite (tools/installa-citati.sh ce la porta) si credeva l'hub:
# dentro il satellite taceva, su un'altra repo installava dal satellite, che non ha gli strumenti per
# farlo. L'hub e' la cartella che ha cio' che il garante usa: claude-md-satellite.sh e copia-hook.sh.
e_hub() { [ -d "$1/.claude/skills" ] && [ -f "$1/tools/claude-md-satellite.sh" ] && [ -f "$1/tools/copia-hook.sh" ]; }
SELF_HUB="$(cd "$(dirname "$0")/.." && pwd)"
e_hub "$SELF_HUB" && HUB="$SELF_HUB" || HUB="${AI_PROGRAMMER_HUB:-$HOME/.zcode/workspace/default/AI_Programmer}"
CWD="${CLAUDE_PROJECT_DIR:-$PWD}"
# (2026-09-24, sesto ventaglio, S1): il rimedio stampato era «sync-repo.sh --standard» senza l'argomento che
# sync-repo vuole — incollato, rispondeva con l'uso ed usciva 1. Il nome si legge dall'origin GitHub, se c'e'.
SAT=$(git -C "$CWD" remote get-url origin 2>/dev/null | sed -nE 's#^.*github\.com[:/]([^/]+/[^/]+)$#\1#p' | sed 's/\.git$//')
SYNC="bash $HUB/tools/sync-repo.sh ${SAT:-<owner/repo>} --standard"

# l'hub deve esistere: se no, silenzio (non possiamo installare da dove non c'è)
e_hub "$HUB" || exit 0

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
      echo "  per aggiornare: $SYNC (dall'hub, scelta consapevole)" >&2
      echo "  (D16) le skill dello standard sono dell'hub: l'aggiornamento le riscrive, le regole locali vanno in PROJECT.md" >&2
    fi
    # (2026-09-24, notte dei giri, T1#2): i guardiani del commit arrivano con lo standard, ma
    # core.hooksPath e' configurazione LOCALE (non viaggia col clone): spenti, il pre-commit che il
    # CLAUDE.md cita non gira. Si dice, col comando; accenderli resta una scelta (D13).
    if [ -d "$CWD/.githooks" ] && [ "$(git -C "$CWD" config core.hooksPath 2>/dev/null)" != ".githooks" ]; then
      echo "⚠ AI_Programmer: i guardiani del commit (.githooks) qui sono SPENTI — per accenderli: git config core.hooksPath .githooks" >&2
    fi
    # (2026-09-24, quinto ventaglio, R2 R1): «installato» voleva dire solo «SessionStart non vuoto» — un satellite
    # SENZA cancello clasp (script tolto, o PreToolUse tolto da settings.json) dava la stessa uscita di uno a
    # posto: niente. Ogni hook dichiarato deve esistere, e il cancello deve essere registrato.
    DICHIARATI=$(bash "$HUB/tools/copia-hook.sh" --elenco "$CWD/.claude/settings.json" 2>/dev/null)
    while IFS= read -r H; do
      [ -n "$H" ] && [ ! -f "$CWD/$H" ] && echo "⚠ AI_Programmer: hook dichiarato e ASSENTE: $H — settings.json punta a uno script che qui non c'e' (per rimetterlo: $SYNC)" >&2
    done <<<"$DICHIARATI"
    grep -qxF 'tools/clasp-block-hook.sh' <<<"$DICHIARATI" \
      || echo "⚠ AI_Programmer: cancello clasp NON registrato in .claude/settings.json — clasp push/deploy qui non sono negati (per rimetterlo: $SYNC)" >&2
    exit 0
  fi
fi

# (giro 27, 2026-09-20): un settings.json PROPRIO senza i nostri hook veniva SOVRASCRITTO dal
# cp qui sotto — la personalizzazione del progetto persa da un hook silenzioso. Si avverte,
# non si tocca: l'installazione su una repo che ha gia' scelto i suoi hook e' una scelta umana.
if [ -f "$CWD/.claude/settings.json" ]; then
  echo "⚠ AI_Programmer: $CWD ha un .claude/settings.json proprio senza i nostri hook — non lo sovrascrivo (per installare: $SYNC, scelta consapevole)" >&2
  exit 0
fi

# NON installato → INSTALLA
echo "STANDARD AI_PROGRAMMER INSTALLATO automaticamente su $CWD" >&2

# (giro 27): niente mkdir di patterns qui — la creava vuota e il ciclo sotto la vedeva «gia' presente»
mkdir -p "$CWD/.claude" "$CWD/.opencode"

# CLAUDE.md (se non esiste già un CLAUDE.md proprio)
# (D8, Luca 2026-09-23): la versione senza i blocchi del solo hub (tools/claude-md-satellite.sh)
[ -f "$CWD/CLAUDE.md" ] || bash "$HUB/tools/claude-md-satellite.sh" "$HUB/CLAUDE.md" > "$CWD/CLAUDE.md" \
  || { rm -f "$CWD/CLAUDE.md"; echo "⚠ AI_Programmer: CLAUDE.md dell'hub con marcatori solo-hub rotti — non installato" >&2; }

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
# (2026-09-24, R2 R1): gli strumenti e i file che lo standard CITA — UNA lista, quella degli altri tre
# installatori. Il garante era il quarto e non la usava: mancavano 18 file (DEBITI, REGISTRO, pre-commit…).
bash "$HUB/tools/installa-citati.sh" "$CWD" --solo-mancanti >/dev/null \
  || echo "⚠ AI_Programmer: installa-citati.sh fallito — alcuni file citati dal CLAUDE.md qui mancano" >&2

# .night-verify minimo se assente
if [ ! -f "$CWD/.night-verify" ]; then
  echo "# Verifiche del turno di notte (VUOTO = il gate lo dice)" > "$CWD/.night-verify"
fi

echo "Installato: CLAUDE.md, skill, agenti, hook, patterns. Il metodo è ora STRUTTURALE in questo repo." >&2
