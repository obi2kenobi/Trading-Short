#!/bin/bash
# cita-verifica.sh — una citazione file:riga che non esiste e' un'istruzione che rompe in
# silenzio (REPO-V 7/9: tre citazioni :riga sbagliate in un design doc, scritte senza
# verificarle). Il dente: ogni `file:NNN` citato nei .md staged deve puntare a un file vero
# con almeno NNN righe. La verifica del CONTENUTO resta umana; l'esistenza della riga no.
# Uso (dal pre-commit, sui .md staged): cita-verifica.sh <file...>
set -uo pipefail
# (report REPO-F 2026-09-19, difetto 4): senza argomenti usciva 0 in silenzio —
# «successo su risultato vuoto» dentro una lente del canone. Niente input,
# niente verdetto.
[ $# -eq 0 ] && { echo "cita-verifica: manca il documento (uso: cita-verifica.sh <file.md>)" >&2; exit 2; }
# --deriva <file...> (2026-09-24, quinto ventaglio, R1 R6): la riga citata esiste ancora, ma e' ancora QUELLA?
# DEBITI e REGISTRO motivano i saldi con file:riga, e il REGISTRO e' append-only: nove citazioni su dieci
# erano scivolate. Per ogni citazione: il commit che ha scritto la riga del documento (git blame), la riga
# citata in quel commit, la stessa riga oggi. Diversa = «scivolata», e dove e' andata se si trova. Un AVVISO:
# rc 0 (la memoria non si riscrive, si cita con un'ancora). Lavora nella repo della cartella corrente.
if [ "$1" = "--deriva" ]; then
  shift
  [ $# -eq 0 ] && { echo "cita-verifica: --deriva vuole i documenti (uso: cita-verifica.sh --deriva <file.md...>)" >&2; exit 2; }
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "cita-verifica --deriva: non e' una repo git — deriva NON controllata (dichiarato)"; exit 0; }
  python3 - "$@" <<'PY'
import os, re, subprocess, sys
CIT = re.compile(r"([A-Za-z0-9_./-]+\.(?:md|sh|py|js|gs|json|html)):(\d+(?:[,-]\d+)*)(?!:\d)")
def git(*a):
    r = subprocess.run(["git", *a], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else None
vecchi, contate, scivolate = {}, 0, 0
for doc in sys.argv[1:]:
    if not os.path.isfile(doc):
        continue
    for i, riga in enumerate(open(doc, encoding="utf-8", errors="ignore"), 1):
        for cit, nums in CIT.findall(riga):
            if not os.path.isfile(cit):
                continue
            blame = git("blame", "-L", f"{i},{i}", "--porcelain", "--", doc)
            sha = blame.split()[0] if blame else ""
            if not sha or set(sha) == {"0"}:
                continue  # riga non ancora committata: niente passato con cui confrontare
            if (sha, cit) not in vecchi:
                vecchi[(sha, cit)] = (git("show", f"{sha}:{cit}") or "").split("\n")
            prima = vecchi[(sha, cit)]
            oggi = open(cit, encoding="utf-8", errors="ignore").read().split("\n")
            for n in (int(x) for x in re.split(r"[,-]", nums)[:1] + re.findall(r",(\d+)", nums)):
                if n > len(prima):
                    continue
                contate += 1
                if n <= len(oggi) and oggi[n - 1] == prima[n - 1]:
                    continue
                scivolate += 1
                dove = [str(k) for k, l in enumerate(oggi, 1) if l == prima[n - 1] and l.strip()][:3]
                print(f"  scivolata: {doc}:{i} cita {cit}:{n} (scritta in {sha[:7]}) — "
                      + (f"ora e' a {', '.join(dove)}" if dove else "la riga di allora non c'e' piu'"))
print(f"citazioni file:riga scivolate: {scivolate} su {contate} (avviso: si cita con un'ancora, la memoria non si riscrive)")
PY
  exit 0
fi
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
ROSSI=0
TARGET=$(grep -vE '^#|^$' "$HERE/tools/.file-del-target" 2>/dev/null || true)
for f in "$@"; do
  [ -f "$f" ] || continue
  # estrae i riferimenti file:NUMERO (backtick o nudi), esclude URL e orari HH:MM
  while IFS=: read -r cit line; do
    [ -n "$cit" ] || continue
    case "$cit" in *.md|*.sh|*.py|*.js|*.gs|*.json|*.html) ;; *) continue;; esac
    # i file delle repo di campo (dichiarati in .file-del-target) si citano ma non
    # vivono qui: la loro verifica spetta alla repo che li ospita
    grep -qxF "$cit" <<<"$TARGET" && continue
    [ -f "$cit" ] || { echo "  $f cita '$cit:$line': file inesistente"; ROSSI=$((ROSSI+1)); continue; }
    N=$(wc -l < "$cit" | tr -d ' ')
    if ! [ "$line" -le "$N" ] 2>/dev/null; then
      echo "  $f cita '$cit:$line': il file ha solo $N righe"
      ROSSI=$((ROSSI+1))
    fi
  done < <(grep -oE '`?[A-Za-z0-9_./-]+\.(md|sh|py|js|gs|json|html):[0-9]+`?' "$f" | tr -d '`' | grep -vE ':[0-9]{2}:[0-9]{2}$' || true)
done
[ "$ROSSI" -gt 0 ] && { echo "⛔ $ROSSI citazioni file:riga rotte (istruzioni che rompono in silenzio)"; exit 1; }
[ "$#" -gt 0 ] && echo "citazioni file:riga verificate: OK"
exit 0
