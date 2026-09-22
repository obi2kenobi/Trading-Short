#!/bin/bash
# pre-commit.sh — il TRUCCETTO che avrei voluto ieri: i controlli VELOCI (2-3
# secondi, non la suite) prima di ogni commit. Nato dai 100 giri assurdi
# (2026-08-29): un commit con un numero sbagliato nel messaggio, glifi alieni,
# un link pendente — tutte cose che una passata di grep becca prima che la
# vergogna diventi pubblica. Si attiva con:
#   git config core.hooksPath .githooks
# (install.sh lo fa per le nuove installazioni; qui si dichiara nel repo.)
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
FALLITI=0

# 4. il messaggio di commit non contiene numeri-test sbagliati: se cita "N test",
#    conta i file veri (ieri: scritto 118, erano 117 — due volte).
#    (D10, test del sistema completo 2026-09-20): il pre-commit di git NON conosce il
#    messaggio — .githooks/pre-commit passava "" e questo controllo non girava mai
#    dall'hook («test: 999 test verdi» e' passato). Ora vive in una funzione chiamata
#    dal gancio commit-msg (`--commit-msg <file>`) E, per compatibilita', dal primo
#    argomento quando lo script e' invocato a mano col messaggio.
controlla_numero_test() {
  local MSG="$1" N_CLAIM N_REAL
  if echo "$MSG" | grep -qE '[0-9]+ test'; then
    N_CLAIM=$(echo "$MSG" | grep -oE '[0-9]+ test' | grep -oE '^[0-9]+' | head -1)
    N_REAL=$(ls tests/test-*.sh 2>/dev/null | wc -l | tr -d ' ')
    [ "$N_CLAIM" != "$N_REAL" ] && { echo "⛔ il messaggio dice \"$N_CLAIM test\" ma i file sono $N_REAL"; return 1; }
  fi
  return 0
}
if [ "${1:-}" = "--commit-msg" ]; then
  controlla_numero_test "$(cat "${2:?uso: pre-commit.sh --commit-msg <file-messaggio>}")" || exit 1
  echo "commit-msg: messaggio OK"
  exit 0
fi

# 1. caratteri alieni nei file STAGE-ATI (non tutto il repo: il commit è la frontiera).
#    NOTA: si usa git grep -P, NON grep -P: il grep BSD di macOS non ha -P e
#    moriva in silenzio nel 2>/dev/null — l'hook diceva OK col glifo staged
#    (falso verde trovato verificando l'hook col caso avverso, suo stesso metodo).
# (E-024 family, 2026-09-15): git grep -P senza locale muore rc=128 e il 2>/dev/null
# lo faceva passare per verde. Un rilevatore che muore e' ROSSO: il fallimento non
# e' un'assenza di reperti.
# (D9, test del sistema completo 2026-09-20): la guardia sopra non poteva scattare MAI:
# xargs mappa 1 e 128 sullo stesso 123, e il `grep -v` in coda alla pipe riportava tutto
# a 1 sotto pipefail. Un commit in cirillico e' passato su una macchina senza
# en_US.UTF-8. Ora git grep riceve i pathspec direttamente (array, niente xargs) e il
# suo rc si cattura PRIMA di ogni filtro.
# il locale UTF-8 si SCEGLIE fra quelli installati (en_US.UTF-8 sul Mac, C.utf8 su un
# Linux minimo): un nome fisso che qui non esiste e' proprio cio' che uccideva il
# rilevatore. LC_ALL preimpostato dal chiamante vince (i test lo usano per forzare la morte).
UTF_LOCALE=$(locale -a 2>/dev/null | grep -iE '^(en_US|C)\.(utf8|UTF-8)$' | head -1)
export LANG="${LANG:-${UTF_LOCALE:-en_US.UTF-8}}" LC_ALL="${LC_ALL:-${UTF_LOCALE:-en_US.UTF-8}}"
STAGED_SPEC=()
while IFS= read -r f; do [ -n "$f" ] && STAGED_SPEC+=(":$f"); done < <(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)
ALIENI_RC=0; ALIENI_RAW=""
if [ ${#STAGED_SPEC[@]} -gt 0 ]; then
  ALIENI_RAW=$(git grep -lP '[\x{4E00}-\x{9FFF}\x{0400}-\x{04FF}]' -- "${STAGED_SPEC[@]}" 2>/dev/null); ALIENI_RC=$?
fi
ALIENI=$(printf '%s\n' "$ALIENI_RAW" | grep -vE '^$|docs/errori/REGISTRO.md' || true)
[ "$ALIENI_RC" -ge 2 ] && { echo "⛔ il controllo glifi e' MORTO (git grep rc=$ALIENI_RC: locale?) — rosso, mai finto verde (rc=1 e' «nessun reperto», sano)"; FALLITI=1; }
[ -n "$ALIENI" ] && { echo "⛔ glifi alieni nei file committati:"; echo "$ALIENI"; FALLITI=1; }

# 2. CRLF negli script staged (passano bash -n, muoiono a runtime)
CRLF_SPEC=()
for s in ${STAGED_SPEC[@]+"${STAGED_SPEC[@]}"}; do case "$s" in *.sh|*.py) CRLF_SPEC+=("$s");; esac; done
CRLF=""
[ ${#CRLF_SPEC[@]} -gt 0 ] && CRLF=$(git grep -lP '\r$' -- "${CRLF_SPEC[@]}" 2>/dev/null || true)
[ -n "$CRLF" ] && { echo "⛔ fine-riga CRLF (muoiono a runtime):"; echo "$CRLF"; FALLITI=1; }

# 3. path in backtick nei file .md staged: devono esistere (link pendenti alla
#    frontiera). I nomi NUDI seguono due convenzioni del repo: gli oracoli vivono
#    in tools/, i report di campo in docs/campo/ e il SAL li cita per basename
#    (campo-triage li grepge così). Il path nudo si risolve contro le tre radici
#    prima di dichiararlo pendente — altrimenti l'hook blocca la convenzione
#    invece del difetto (successo alla prima: il commit di chi scriveva l'hook).
PEND=""
TARGET=$(grep -vE '^#|^$' "$HERE/tools/.file-del-target" 2>/dev/null || true)
while IFS= read -r f; do
  [ -f "$f" ] || continue
  while IFS= read -r m; do
    echo "$TARGET" | grep -qxF "$m" && continue          # file-del-target: nel progetto, non qui
    # (2026-09-20): un nome nudo si risolve anche nella CARTELLA del documento che lo cita
    # (docs/bc/README.md cita `CORREZIONI.md` che vive accanto a lui — l'indice BC generato
    # da bc_index.py era bloccato al primo commit che lo toccava dall'hook attivo)
    [ -e "$m" ] || [ -e "$(dirname "$f")/$m" ] || [ -e "tools/$m" ] || [ -e "tests/$m" ] || [ -e "docs/campo/$m" ] || [ -e ".claude/skills/gas-sviluppo/references/$m" ] || PEND="$PEND $f: $m"
  done < <(grep -oE '`[A-Za-z0-9_./-]+\.(md|sh|py)`' "$f" | tr -d '`')
done < <(git diff --cached --name-only 2>/dev/null | grep '\.md$')
[ -n "$PEND" ] && { echo "⛔ path citati ma inesistenti:"; echo "$PEND"; FALLITI=1; }

# 4. numero-test nel messaggio — quando lo script e' invocato a mano col messaggio
#    come primo argomento (dall'hook git arriva vuoto: il controllo vero e' in commit-msg)
controlla_numero_test "${1:-}" || FALLITI=1

# 5. (2026-09-05, report REPO-W) pipeline a sinistra di &&: la regola «mai && dopo
#    una pipe» era nel canone dal 3/9, nata nello stesso repo, indicizzata — e violata
#    TRE volte in una sessione (commit dichiarato verde col banco rosso). Una regola
#    che vive solo come frase non protegge: questo è il controllo che gira. La pipe
#    restituisce l'exit dell'ULTIMO comando: `cmd | tail && git commit` committa
#    anche se cmd non è mai partito.
#    NOTA regex: la negata `[^|&;]*&&` NON funziona nel grep BSD (provato col caso
#    avverso: falso dente silenzioso) — si usa la whitelist dei caratteri tipici
#    fra comando e &&, verificata contro righe colpevoli e benigne.
PIPE_AND=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  # la guardia cita il pattern che sorveglia nel proprio commento: non è peccato
  case "$f" in tools/pre-commit.sh|.githooks/pre-commit) continue;; esac
  while IFS= read -r riga; do
    PIPE_AND="$PIPE_AND $f: $riga"
  done < <(grep -nE '\|[[:space:]]*[A-Za-z][a-zA-Z0-9 ._-]*&&' "$f" | sed 's/^\([0-9]*\):/riga \1:/' || true)
done < <(git diff --cached --name-only 2>/dev/null | grep -E '\.(sh|py)$')
[ -n "$PIPE_AND" ] && { echo "⛔ pipeline seguita da && (l'esito è del solo ultimo comando — la regola del 3/9 era prose, ora è un dente):"; echo "$PIPE_AND"; FALLITI=1; }

# 6. (contromisura REPO-V 7/9) citazioni file:riga nei .md staged: la riga citata esiste
STAGED_MD=$(git diff --cached --name-only 2>/dev/null | grep '\.md$' || true)
if [ -n "$STAGED_MD" ]; then
  if ! bash "$HERE/tools/cita-verifica.sh" $STAGED_MD; then FALLITI=1; fi
fi

# 7. (E-025, 2026-09-14) NOMI VERO-DA-CASA alla frontiera: report col partner e persone
#    e' entrato nel repo pubblico perche' la chiave (repos.key) e' vuota su questa macchina
#    e nessun controllo guardava i .md in commessa. La chiave dei nomi sta in ~/.privacy-nomi
#    (HOME: sopravvive ai cloni, non entra nel repo). Assente = DEGRADATO FORTE, mai muto.
if [ -f "$HOME/.privacy-nomi" ]; then
  LEAK=""
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    # eccezione DICHIARATA (2026-09-14): docs/bc/ documenta lo SCHEMA del tenant — i nomi
    # delle entita' (es. le estensioni del gruppo) sono FATTI, rinominarli mentirebbe
    # sulla documentazione. La prosa nei report resta protetta.
    case "$f" in docs/bc/*) continue;; esac
    while IFS= read -r nome; do
      [ -n "$nome" ] || continue
      grep -qi "$nome" "$f" && LEAK="$LEAK\n  $f contiene '$nome'"
    done < "$HOME/.privacy-nomi"
  done < <(git diff --cached --name-only 2>/dev/null | grep -E '\.md$' || true)
  if [ -n "$LEAK" ]; then
    echo "⛔ nomi veri in file in committa (repo pubblica, lavoro privato):$LEAK"
    echo "   anonimizza (codici REPO-*, [partner], [operatore]) oppure rimuovi il nome da ~/.privacy-nomi SE e' pubblico per contratto"
    FALLITI=1
  fi
else
  echo "⚠ privacy: ~/.privacy-nomi assente — il controllo nomi e' DEGRADATO (non e' un via libera)"
fi

[ "$FALLITI" -eq 0 ] && echo "pre-commit: controlli rapidi OK" || echo "pre-commit: correggi e ricommetti (oppure --no-verify, sapendo cosa fai)"
exit $FALLITI
