#!/bin/bash
# privacy-check.sh — il hub è PUBBLICO: nessun nome di repo privata nei file versionati
# NÉ nella storia git — un nome committato e poi rimosso dal file resta comunque
# leggibile per sempre via git log/show (GitHub non lo dimentica). La chiave
# (night-shift/repos.key) è locale e gitignored: questo check la usa come lista nera.
# Pattern: citazione-non-presidio.
#
# v3 (nuovo ciclo 10 giri, 2026-08-22): prima scansionava solo `git ls-files` (i file
# tracciati OGGI) — un nome committato e poi tolto dal file corrente restava esposto
# per sempre nella storia, e il check diceva comunque "pulito". Aggiunta la scansione
# della storia: contenuto di ogni commit passato (pickaxe -S) e messaggi di commit
# (--grep), su TUTTI i branch (--all), non solo quello corrente.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
KEY="$HERE/night-shift/repos.key"
# v4 (2026-08-24, report dal campo su REPO-G): senza chiave il gate è CIECO — e usciva 0,
# cioè "promosso", proprio nelle sessioni cloud dove la chiave non esiste per disegno.
# Un gate che non può giudicare non dice pulito: dice degradato, e fallisce.
[ -f "$KEY" ] || { echo "⛔ privacy-check: GATE DEGRADATO — repos.key assente: NON ho controllato niente (né file, né storia git). Questo non è un verdetto di pulizia: crea night-shift/repos.key (locale, gitignored) per rendere il gate reale." >&2; exit 1; }
RC=0

# giri avversari 2026-08-28 (A20): un segreto VERO non deve aspettare che repos.key
# ne conosca il nome. Le FORME generiche (prefissi di token AWS/GitHub/Anthropic/Slack,
# chiavi private PEM) si cercano sempre, su tutti i file tracciati. I file di TEST e
# l'archivio SAL citano queste forme per parlarne: esclusi per costruzione.
SHAPES='sk-ANTHROPIC|sk-proj-|ghp_[A-Za-z0-9]{20}|gho_[A-Za-z0-9]{20}|github_pat_|AKIA[0-9A-Z]{12}|xoxb-|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
SHAPE_HIT=$( (cd "$HERE" && git ls-files -z | xargs -0 grep -lE "$SHAPES" 2>/dev/null)   | grep -vE '^tests/|SAL-ARCHIVIO\.md|repos\.key|tools/privacy-check\.sh|tools/giri-avversari\.sh' || true)
if [ -n "$SHAPE_HIT" ]; then
  echo "⛔ privacy-check: FORMA DI SEGRETO generica in:" >&2
  echo "$SHAPE_HIT" | sed 's/^/  file: /' >&2
  RC=1
fi

# scan_termine <termine> <etichetta>: FALLISCE se il termine compare nei file tracciati
# oggi, nel CONTENUTO di un commit passato (pickaxe), o nel messaggio di un commit passato.
scan_termine() {
  local termine="$1" etichetta="$2"
  [ -z "$termine" ] && return 0
  local FILES HIST MSG ALL
  FILES=$( (cd "$HERE" && git ls-files -z | xargs -0 grep -l -F "$termine" 2>/dev/null) | grep -v "repos.key" || true)
  HIST=$( (cd "$HERE" && git log --all --oneline -S"$termine" -- . 2>/dev/null) | sed 's/^/storia: /' || true)
  MSG=$( (cd "$HERE" && git log --all --oneline --grep="$termine" -F 2>/dev/null) | sed 's/^/messaggio: /' || true)
  ALL=$(printf '%s\n%s\n%s\n' "$FILES" "$HIST" "$MSG" | grep -v '^$' || true)
  if [ -n "$ALL" ]; then
    echo "⛔ $etichetta NEL REPO PUBBLICO ($termine) in:" >&2
    echo "$ALL" | head -8 >&2
    RC=1
  fi
}

# bug reale (revisione 14 lenti, 2026-08-28): `while read ... done < file` salta
# silenziosamente l'ultima riga se il file non termina con newline (comunissimo con
# editor che non lo aggiungono) — un nome sensibile su quella riga passava "pulito" per
# errore. La condizione `|| [ -n "$code" ]` cattura anche l'ultima riga senza newline
# (read fallisce a EOF ma ha comunque popolato le variabili).
while IFS='=' read -r code name || [ -n "$code" ]; do
  case "$code" in \#*|"") continue ;; esac
  base="${name##*/}"
  scan_termine "$base" "NOME PRIVATO"
  scan_termine "$name" "NOME PRIVATO"
done < "$KEY"

# v2 (giro 4/10 del ciclo precedente): anche PERSONE e TERMINI riservati — chiavi
# PERSONA=x / TERMINI=a,b,c nella stessa repos.key. La privacy non è solo il nome delle repo.
while IFS='=' read -r chiave valore || [ -n "$chiave" ]; do
  case "$chiave" in PERSONA|TERMINI) ;; *) continue ;; esac
  IFS=',' read -ra TERMINI_ARR <<<"$valore"
  for t in "${TERMINI_ARR[@]}"; do
    tt=$(echo "$t" | xargs)
    scan_termine "$tt" "TERMINE PRIVATO"
  done
done < "$KEY"

[ $RC -eq 0 ] && echo "privacy-check: pulito (file correnti + storia git, tutti i branch)"
exit $RC
