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
# (revisione 10 giri, 2026-09-23): conta solo la dichiarazione del TOTALE verde («N test
# verdi/superati/passati/OK») — prima ogni «N test» era letto cosi', e «6 test rossi» o
# «2 test nuovi» (conteggi parziali, legittimi) venivano respinti.
controlla_numero_test() {
  local MSG="$1" N_CLAIM N_REAL
  local TOTALE='[0-9]+ test (verdi|superati|passati|OK|in verde)'
  if grep -qiE "$TOTALE" <<<"$MSG"; then
    N_CLAIM=$(echo "$MSG" | grep -oiE "$TOTALE" | grep -oE '^[0-9]+' | head -1)
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
# (Q9, 2026-09-23, giro A2 della notte): ogni controllo leggeva il WORKING TREE, ma il commit
# porta l'INDICE — un glifo stage-ato e poi tolto solo dal disco passava (falso verde), il caso
# inverso bloccava (falso rosso). E `git diff --name-only` mette fra virgolette ottali i nomi
# accentati ("docs/perch\303\251.md"): `[ -f ]` li saltava, git grep moriva. Ora i nomi escono
# senza virgolette e i contenuti si leggono dall'indice. (Un nome con un a-capo resta fuori.)
staged() { git -c core.quotePath=false diff --cached --name-only "$@" 2>/dev/null; }
indice() { git show ":$1" 2>/dev/null; }     # il contenuto che il commit porta
nell_indice() { git cat-file -e ":$1" 2>/dev/null; }

# 0bis. (2026-09-24, quarto ventaglio, Q5 R2): le FORME di segreto (token, chiavi, credenziali Google) nel
#    contenuto dell'INDICE. Vivevano solo in tools/privacy-check.sh, che gira la notte: una sessione di giorno
#    poteva committare e pushare un token sull'hub pubblico, «controlli rapidi OK». Stesse forme e stesse
#    esclusioni di privacy-check (tests/ compreso dal 2026-09-24: i banchi compongono le forme a runtime). Si dice il FILE, mai il valore.
if [ -f "$HERE/tools/privacy-check.sh" ]; then
  SHAPES=$(sed -n "s/^SHAPES='\(.*\)'$/\1/p" "$HERE/tools/privacy-check.sh")
  if [ -z "$SHAPES" ]; then
    echo "⚠ forme di segreto: illeggibili da tools/privacy-check.sh — controllo DEGRADATO"
  else
    FORME=""
    while IFS= read -r f; do
      case "$f" in *SAL-ARCHIVIO.md|*repos.key|tools/privacy-check.sh|tools/giri-avversari.sh|"") continue ;; esac
      N=$(indice "$f" | grep -cE "$SHAPES")
      [ "${N:-0}" -gt 0 ] && FORME="$FORME\n  $f ($N righe)"
    done < <(staged --diff-filter=ACMR)
    [ -n "$FORME" ] && { printf '⛔ forma di segreto nei file in stage (il valore non si stampa):%b\n   togli il segreto (riferiscilo per percorso, CLAUDE.md §2) e ricommetti\n' "$FORME"; FALLITI=1; }
  fi
fi

# 0. (2026-09-24, notte dei giri, T1#3): la CHIAVE della privacy (repos.key: nomi, persone, termini) e la
#    lista dei nomi (.privacy-nomi) non entrano mai in un commit, in nessun percorso — l'hub si
#    affidava al .gitignore, e un `git add -f` o una chiave in un altro percorso (un satellite) passavano.
CHIAVI=$(staged --diff-filter=ACMR | grep -E '(^|/)(repos\.key|\.privacy-nomi)$' || true)
[ -n "$CHIAVI" ] && { echo "⛔ la chiave della privacy e' in stage — mai in un commit (git rm --cached):"; echo "$CHIAVI"; FALLITI=1; }
STAGED_SPEC=()
# (2026-09-24, sesto ventaglio, rinviati di S3 R6): «:(top,literal)», non «:» nudo. Col «:» nudo un nome che comincia
# con «-» era magia sconosciuta (rc 128, «MORTO»), e «!x.md» diventava un'esclusione di x.md: il glifo passava.
while IFS= read -r f; do [ -n "$f" ] && STAGED_SPEC+=(":(top,literal)$f"); done < <(staged --diff-filter=ACMR)
ALIENI_RC=0; ALIENI_RAW=""
if [ ${#STAGED_SPEC[@]} -gt 0 ]; then
  ALIENI_RAW=$(git -c core.quotePath=false grep --cached -lP '[\x{4E00}-\x{9FFF}\x{0400}-\x{04FF}]' -- "${STAGED_SPEC[@]}" 2>/dev/null); ALIENI_RC=$?
fi
ALIENI=$(printf '%s\n' "$ALIENI_RAW" | grep -vE '^$|docs/errori/REGISTRO.md' || true)
[ "$ALIENI_RC" -ge 2 ] && { echo "⛔ il controllo glifi e' MORTO (git grep rc=$ALIENI_RC: locale?) — rosso, mai finto verde (rc=1 e' «nessun reperto», sano)"; FALLITI=1; }
[ -n "$ALIENI" ] && { echo "⛔ glifi alieni nei file committati:"; echo "$ALIENI"; FALLITI=1; }

# 2. CRLF negli script staged (passano bash -n, muoiono a runtime)
CRLF_SPEC=()
for s in ${STAGED_SPEC[@]+"${STAGED_SPEC[@]}"}; do case "$s" in *.sh|*.py) CRLF_SPEC+=("$s");; esac; done
CRLF=""; CRLF_RC=1
# (revisione 10 giri, 2026-09-23): era `… 2>/dev/null || true` — un git grep -P morto (rc 128:
# PCRE o locale) passava per «nessun CRLF». Stessa regola del controllo glifi qui sopra.
if [ ${#CRLF_SPEC[@]} -gt 0 ]; then
  CRLF=$(git -c core.quotePath=false grep --cached -lP '\r$' -- "${CRLF_SPEC[@]}" 2>/dev/null); CRLF_RC=$?
fi
[ "$CRLF_RC" -ge 2 ] && { echo "⛔ il controllo CRLF e' MORTO (git grep rc=$CRLF_RC: locale/PCRE?) — rosso, mai finto verde"; FALLITI=1; }
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
  nell_indice "$f" || continue
  while IFS= read -r m; do
    grep -qxF -- "$m" <<<"$TARGET" && continue       # file-del-target: nel progetto, non qui («--»: un nome col trattino non e' un'opzione)
    # (2026-09-20): un nome nudo si risolve anche nella CARTELLA del documento che lo cita
    # (docs/bc/README.md cita `CORREZIONI.md` che vive accanto a lui — l'indice BC generato
    # da bc_index.py era bloccato al primo commit che lo toccava dall'hook attivo)
    [ -e "$m" ] || [ -e "$(dirname "$f")/$m" ] || [ -e "tools/$m" ] || [ -e "tests/$m" ] || [ -e "docs/campo/$m" ] || [ -e "patterns/$m" ] || [ -e ".claude/skills/gas-sviluppo/references/$m" ] || PEND="$PEND $f: $m"
  done < <(indice "$f" | grep -oE '`[A-Za-z0-9_./-]+\.(md|sh|py)`' | tr -d '`')
# (2026-09-24, quinto ventaglio, R1 R5): SAL-ARCHIVIO.md e' storia congelata — cita i file com'erano quando
# fu scritto; ci entra in stage solo l'indice rigenerato da sal-indice. Qui e al controllo 6 non si guarda.
done < <(staged | grep '\.md$' | grep -vx 'SAL-ARCHIVIO.md')
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
#    (D8, 2026-09-23): la `|` non deve far parte di un `||` — l'OR logico seguito da && non e'
#    una pipeline, e il dente scattava su un commento di bootstrap-app.sh.
PIPE_AND=""
while IFS= read -r f; do
  nell_indice "$f" || continue
  # la guardia cita il pattern che sorveglia nel proprio commento: non è peccato
  case "$f" in tools/pre-commit.sh|.githooks/pre-commit) continue;; esac
  while IFS= read -r riga; do
    PIPE_AND="$PIPE_AND $f: $riga"
  done < <(indice "$f" | grep -nE '(^|[^|])\|[[:space:]]*[A-Za-z][a-zA-Z0-9 ._-]*&&' | sed 's/^\([0-9]*\):/riga \1:/' || true)
done < <(staged | grep -E '\.(sh|py)$')
[ -n "$PIPE_AND" ] && { echo "⛔ pipeline seguita da && (l'esito è del solo ultimo comando — la regola del 3/9 era prose, ora è un dente):"; echo "$PIPE_AND"; FALLITI=1; }

# 6. (contromisura REPO-V 7/9) citazioni file:riga nei .md staged: la riga citata esiste
# (dominio 2026-09-23): i report di campo citano i file dei repo AUDITATI
# (case esterne: config.gs, vendite.gs...) — prove portate come evidenza, non
# istruzioni che devono risolvere nell'hub. Esenti dal file:riga, dichiarato.
# (Q9): cita-verifica legge file su disco — gli si passa una COPIA dell'indice, e i messaggi
# tornano col path vero. I file citati si risolvono contro il working tree: dichiarato.
IDX=$(mktemp -d); trap 'rm -rf "$IDX"' EXIT
COPIE=()
while IFS= read -r f; do
  nell_indice "$f" || continue
  mkdir -p "$IDX/$(dirname "$f")"; indice "$f" > "$IDX/$f"; COPIE+=("$IDX/$f")
done < <(staged | grep '\.md$' | grep -v '^docs/campo/' | grep -vx 'SAL-ARCHIVIO.md' || true)
if [ ${#COPIE[@]} -gt 0 ]; then
  CV=$(bash "$HERE/tools/cita-verifica.sh" "${COPIE[@]}"); CV_RC=$?
  printf '%s\n' "${CV//$IDX\//}"
  [ "$CV_RC" -eq 0 ] || FALLITI=1
fi

# 7. (E-025, 2026-09-14) NOMI VERO-DA-CASA alla frontiera: report col partner e persone
#    e' entrato nel repo pubblico perche' la chiave (repos.key) e' vuota su questa macchina
#    e nessun controllo guardava i .md in commessa. La chiave dei nomi sta in ~/.privacy-nomi
#    (HOME: sopravvive ai cloni, non entra nel repo). Assente = DEGRADATO FORTE, mai muto.
if [ -f "$HOME/.privacy-nomi" ]; then
  LEAK=""
  # (2026-09-25, settimo ventaglio, V1 R1): la lista si legge con la regola di privacy-check (nomi_locali), non con
  # una copia sua: la copia saltava l'ultima riga senza a capo e prendeva un «#» per un nome.
  NOMI=$(bash "$HERE/tools/privacy-check.sh" --elenca-nomi "$HOME/.privacy-nomi" 2>/dev/null)
  if [ -z "$NOMI" ] && grep -c '[^[:space:]#]' "$HOME/.privacy-nomi" >/dev/null 2>&1; then
    echo "⛔ nomi: la lista ha righe ma tools/privacy-check.sh non l'ha letta (assente o rotto) — controllo MORTO, rosso"
    FALLITI=1
  fi
  while IFS= read -r f; do
    nell_indice "$f" || continue
    # eccezione DICHIARATA (2026-09-14): docs/bc/ documenta lo SCHEMA del tenant — i nomi
    # delle entita' (es. le estensioni del gruppo) sono FATTI, rinominarli mentirebbe
    # sulla documentazione. La prosa nei report resta protetta. (2026-09-26, domanda 15): la regola la
    # dice privacy-check, la stessa che applica di notte — prima qui c'era una copia, e la notte no.
    bash "$HERE/tools/privacy-check.sh" --esente-nomi "$f" && continue
    # (2026-09-24, quarto ventaglio, Q5 R5): si guardavano solo i .md — un nome in uno script o in un .txt
    # passava. Ora ogni file di TESTO in stage (i binari fuori), e il nome nell'uscita e' la sua impronta.
    indice "$f" | grep -Ic . >/dev/null || continue   # -c legge tutto: niente SIGPIPE sotto pipefail (E-002)
    CONTENUTO=$(indice "$f")
    while IFS= read -r nome; do
      [ -n "$nome" ] || continue
      grep -qiF -- "$nome" <<<"$CONTENUTO" && LEAK="$LEAK\n  $f contiene «nome $(printf '%s' "$nome" | { shasum -a 256 2>/dev/null || sha256sum; } | cut -c1-8) · ${#nome} caratteri»"
    done <<<"$NOMI"
  done < <(staged --diff-filter=ACMR || true)
  if [ -n "$LEAK" ]; then
    echo "⛔ nomi veri in file in committa (repo pubblica, lavoro privato):$LEAK"
    echo "   anonimizza (codici REPO-*, [partner], [operatore]) oppure rimuovi il nome da ~/.privacy-nomi SE e' pubblico per contratto"
    FALLITI=1
  fi
else
  echo "⚠ privacy: ~/.privacy-nomi assente — il controllo nomi e' DEGRADATO (non e' un via libera)"
fi

# 9. (2026-09-24, terzo ventaglio, V5 R3b): due fix sul codice ancorato (lock, watchdog) hanno cambiato la
#    regola, e i pattern che la descrivono sono rimasti com'erano. Quando si tocca un file ancorato senza il
#    suo pattern, il gancio lo chiede. Avviso, non blocco: il pattern puo' essere ancora vero.
if [ -d "$HERE/patterns" ]; then
  ANCORE=$(for p in patterns/*.md; do [ "$p" = patterns/README.md ] || printf '%s\t%s\n' "$p" "$(sed -n 2p "$p")"; done)
  IN_STAGE=$(staged)
  while IFS= read -r f; do
    case "$f" in patterns/*|graphify-out/*|"") continue ;; esac
    while IFS= read -r p; do
      [ -n "$p" ] && ! grep -qxF "$p" <<<"$IN_STAGE" \
        && echo "⚠ stai cambiando $f, ancorato da $p: il pattern dice ancora il vero?"
    done < <(grep -F -- "$f" <<<"$ANCORE" | cut -f1)
  done <<<"$IN_STAGE"
fi

# 8. (D1, Luca 2026-09-23: graphify spina dorsale, grafo VERSIONATO) il grafo segue il commit.
#    Solo se i controlli sono passati, se il commit tocca qualcosa FUORI dal grafo, e se la spina
#    e' installata qui (graphify-out/.gitattributes: la scrive tools/graphify-spina.sh alla
#    prima sessione). Il grafo si costruisce dal working tree, non dall'indice: dichiarato.
#    (E-002: `git diff | grep -q` sotto pipefail puo' morire di SIGPIPE — si cattura prima)
FUORI_GRAFO=$(staged | grep -v '^graphify-out/' || true)
if [ "$FALLITI" -eq 0 ] && [ -n "$FUORI_GRAFO" ] && [ -f "$HERE/graphify-out/.gitattributes" ] && [ -f "$HERE/tools/graphify-spina.sh" ]; then
  bash "$HERE/tools/graphify-spina.sh" "$HERE" --stage
fi

[ "$FALLITI" -eq 0 ] && echo "pre-commit: controlli rapidi OK" || echo "pre-commit: correggi e ricommetti (oppure --no-verify, sapendo cosa fai)"
exit $FALLITI
