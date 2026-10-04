#!/bin/bash
# fork-stato.sh — la misura della deriva fra le copie di un progetto (skill
# allineamento-fork, mossa M3). Date N cartelle, produce: per ogni copia
# (file, righe, hash normalizzato), la matrice delle differenze, e il VERDETTO
# secondo la tabella M4 — compreso chi è la base di lavoro e cosa fare PRIMA
# di toccare qualsiasi file.
#
# L'hash è NORMALIZZATO: righe vuote e spazi finali via, ordine file stabile —
# così due copie che differiscono solo di formattazione non risultano divergenti
# (la deriva che conta è quella di contenuto, non di resa).
#
# Uso: bash tools/fork-stato.sh <dir1> <dir2> [<dir3>...]
#      (una delle copie può essere un clasp clone fresco del vivo: M2 della skill)
# Esce 0 se tutte uguali · 1 se c'è deriva (con verdetto) · 2 uso errato o DEGRADATO (non so misurare).
set -uo pipefail
[ $# -ge 2 ] || { echo "uso: fork-stato.sh <dir1> <dir2> [<dir3>...]" >&2; exit 2; }

# (Q18, 2026-09-23, giro A2 della notte): tre ALLINEATE falsi, riprodotti. (a) Si misuravano solo
# .gs/.js: l'Index.html di una webapp e appsscript.json (scope, fuso, runtime) — che clasp porta —
# restavano fuori. (b) Due copie VUOTE (un clasp clone fallito) davano ALLINEATE. (c) Senza shasum
# le impronte erano vuote, quindi uguali. Ora: si misura cio' che clasp porta; una copia senza
# codice o un hash che non si puo' calcolare e' DEGRADATO (exit 2), mai un verdetto.
codice() { # i file di codice della copia, in ordine stabile (.git e node_modules fuori)
  find "$1" -type f \( -name '*.gs' -o -name '*.js' -o -name '*.html' -o -name 'appsscript.json' \) \
    ! -name '.clasp*' ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | sort
}
# lo strumento di hash: shasum (Mac), sha1sum (Linux), python3 in ultima istanza
if command -v shasum >/dev/null 2>&1; then HASHER="shasum"
elif command -v sha1sum >/dev/null 2>&1; then HASHER="sha1sum"
elif command -v python3 >/dev/null 2>&1; then HASHER="python3 -c 'import hashlib,sys; print(hashlib.sha1(sys.stdin.buffer.read()).hexdigest())'"
else
  echo "VERDETTO: DEGRADATO — nessuno strumento di hash (shasum, sha1sum, python3): non so misurare la deriva" >&2
  exit 2
fi
impronta() { # hash normalizzato del codice della copia (il marcatore porta il percorso relativo:
  local d="$1"   # lo stesso nome in due cartelle diverse non si confonde)
  codice "$d" | while IFS= read -r f; do
      sed 's/[[:space:]]*$//' "$f" | grep -v '^$'
      echo "---FILE---${f#"$d"/}"
    done | eval "$HASHER" | awk '{print $1}'
}
conta() { codice "$1" | wc -l | tr -d ' '; }
# (2026-09-24, terzo ventaglio, V3): la matrice a coppie, file per file. Prima ogni copia si confrontava
# solo con la prima: che due copie coincidessero fra loro lo dicevano solo le impronte, e QUALI file
# differivano restava da cercare coi diff.
impronta_file() { sed 's/[[:space:]]*$//' "$1" | grep -v '^$' | eval "$HASHER" | awk '{print $1}'; }
relativi() { codice "$1" | while IFS= read -r f; do echo "${f#"$1"/}"; done; }
confronta_coppia() { # $1 $2 cartelle, $3 $4 nomi: una riga «A ↔ B: uguali» o «A ↔ B: N file — …»
  local a="$1" b="$2" diversi="" soloa="" solob="" n=0 r parti=""
  while IFS= read -r r; do
    if [ ! -f "$b/$r" ]; then soloa="$soloa $r"; n=$((n+1))
    elif [ "$(impronta_file "$a/$r")" != "$(impronta_file "$b/$r")" ]; then diversi="$diversi $r"; n=$((n+1)); fi
  done < <(relativi "$a")
  while IFS= read -r r; do [ -f "$a/$r" ] || { solob="$solob $r"; n=$((n+1)); }; done < <(relativi "$b")
  [ "$n" -eq 0 ] && { echo "  $3 ↔ $4: uguali"; return; }
  [ -n "$diversi" ] && parti="diversi:$diversi"
  [ -n "$soloa" ] && parti="${parti:+$parti; }solo in $3:$soloa"
  [ -n "$solob" ] && parti="${parti:+$parti; }solo in $4:$solob"
  echo "  $3 ↔ $4: $n file — $parti"
}
righe() { codice "$1" | while IFS= read -r f; do cat "$f"; done | wc -l | tr -d ' '; }

# array INDICIZZATI (bash 3.2 di macOS non ha declare -A: gli indici qui sono
# numerici 0..N-1, l'associativo non serve e il -A fa solo sputare errori)
declare -a HASH FILES RIGHE NOMI DIRS
N=0
for d in "$@"; do
  # (sesto ventaglio, rinviati di S3 R6): una cartella relativa che comincia col trattino e' un percorso, non un'opzione.
  case "$d" in -*) d="./$d" ;; esac
  [ -d "$d" ] || { echo "⛔ copia inesistente: $d" >&2; exit 2; }
  NOME=$(basename "$d" | sed 's/__[A-Za-z0-9_-]*$//')   # via il suffisso id GAS
  HASH[$N]=$(impronta "$d"); FILES[$N]=$(conta "$d"); RIGHE[$N]=$(righe "$d"); NOMI[$N]="$NOME"; DIRS[$N]="${d%/}"
  N=$((N+1))
done

echo "== fork-stato — $(date +%F) =="
for i in $(seq 0 $((N-1))); do
  echo "  ${NOMI[$i]}: ${FILES[$i]} file · ${RIGHE[$i]} righe · impronta ${HASH[$i]:0:12}"
done
for i in $(seq 0 $((N-1))); do
  if [ "${FILES[$i]}" -eq 0 ] || [ -z "${HASH[$i]}" ]; then
    echo ""
    echo "VERDETTO: DEGRADATO — la copia ${NOMI[$i]} non ha codice misurabile (clone fallito? cartella sbagliata?): nessun verdetto sulla deriva"
    exit 2
  fi
done

# matrice: quante copie differiscono da quante
UGUALI=1
BASE=0
for i in $(seq 1 $((N-1))); do
  if [ "${HASH[$i]}" != "${HASH[$BASE]}" ]; then UGUALI=0; fi
done

if [ $UGUALI -eq 1 ]; then
  echo ""
  echo "VERDETTO: ALLINEATE — tutte le copie coincidono (contenuto normalizzato)."
  echo "  Base di lavoro: qualunque copia. Confronto col vivo comunque prima di ogni PR."
  exit 0
fi

echo ""
echo "VERDETTO: DIVERGENTI — la tabella M4 decide:"
for i in $(seq 0 $((N-1))); do
  D="="
  [ "${HASH[$i]}" != "${HASH[$BASE]}" ] && D="≠"
  echo "  ${NOMI[$i]} $D ${NOMI[$BASE]}"
done
echo "Confronto a coppie, file per file:"
for i in $(seq 0 $((N-2))); do
  for j in $(seq $((i+1)) $((N-1))); do confronta_coppia "${DIRS[$i]}" "${DIRS[$j]}" "${NOMI[$i]}" "${NOMI[$j]}"; done
done
echo "  (chi è avanti non si misura dal contenuto: lo dicono la storia delle copie — git log, data"
echo "  dell'ultimo deploy — e la tabella M4 della skill)"
cat <<TAB
  Il da farsi SIN DA SUBITO (skill allineamento-fork):
  - IL GAS VIVO È DEFINITIVO: se una copia è un clasp clone fresco del vivo,
    È LEI la base — le altre si allineano a lei, mai il contrario.
  - La copia più indietro non si tocca: prima l'allineamento (commit
    «allineamento al vivo»), poi le modifiche.
  - Scrivi FORK-STATO.md (copie, deriva, base scelta, data): la sessione
    prossima legge, non ri-sospetta.
TAB
exit 1
