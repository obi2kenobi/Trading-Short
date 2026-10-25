#!/bin/bash
# presidio.sh — il protocollo di presenza per il lavoro condiviso (multiutenza
# sullo stesso repo, 100 giri 2026-08-29). Il problema: due utenti (o due
# sessioni AI) sullo stesso repo nello stesso momento si accorgono l'uno
# dell'altro solo al conflitto. L'assignee GitHub vale per le COMMESSE (giusto
# così); il presidio vale per le ZONE: «sto toccando SAL/oracoli/agente-X
# fino alle 14:30». Presenza dichiarata in PRESIDI.md — un file append-only
# che si fonde col driver union: due presidii simultanei da due cloni
# sopravvivono entrambi al merge, per costruzione.
#
# NESSUN LOCK GLOBALE: il presidio è visibilità, non blocco. Se due persone
# dichiarano la stessa zona, `lista` lo dice a entrambe (CONTESA) e la
# risoluzione è umana (parlarsi, o il secondo si sposta): un lock distribuito
# fareva finta di risolvere ciò che solo la conversazione risolve.
#
# Uso:
#   presidio.sh claim <zona> <nota>     dichiara presenza (scade dopo 4h di default)
#   presidio.sh lista                   i presidii vivi (i scaduti potati, dichiarati)
#   presidio.sh rilascia <zona>         chiude il tuo presidio (fatto o cambiato idea)
# Esce 0 sempre tranne uso errato: la presenza è un servizio, non un gate.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$HERE/PRESIDI.md"
ORARIO=${PRESIDIO_ORE:-4}
# identità: l'override ESPLICITO vince sul git config (due utenti provano sullo
# stesso clone col PRESIDIO_USER; in produzione ognuno ha il suo nome in git)
CHI="${PRESIDIO_USER:-$(git -C "$HERE" config user.name 2>/dev/null || echo "${USER:-io}")}"

init() {
  [ -f "$FILE" ] || cat > "$FILE" <<EOF
# PRESIDI.md — chi sta toccando cosa, adesso (protocollo di presenza)

> Il registro dei presidii: una riga per presenza dichiarata, append-only,
> merge union come i diari. I presidii scaduti vengono potati da \`lista\` e
> dichiarati nel conteggio. Non è un lock: è visibilità. Due presidii sulla
> stessa zona = CONTESA, e la contesa si risolve parlandosi, non da git.

| Dichiarato | Chi | Zona | Scade | Nota |
|---|---|---|---|---|
EOF
}

# (2026-09-24, terzo ventaglio, V3): il rilascio CANCELLAVA la riga, e un file che si riscrive non regge
# il merge union: se nell'altro clone qualcuno appendeva un presidio nello stesso punto, il merge riportava
# in vita la riga rilasciata e `lista` la contava viva (riprodotto). Ora il rilascio APPENDE una riga con
# nota RILASCIO, che chiude i presidii dello stesso chi sulla stessa zona scritti PRIMA di lei nel file
# (l'ordine regge il merge: le righe comuni restano davanti). La potatura degli scaduti riscrive ancora,
# ma una riga scaduta che un merge riporta e' scaduta anche li', e si ripota.
vivi() { # $1 = adesso: stampa le righe dei presidii vivi (non scaduti, non chiusi da un RILASCIO dopo)
  awk -F'|' -v ora="$1" '
    function t(x) { gsub(/^ +| +$/, "", x); return x }
    /^\| 20/ { n++; r[n]=$0; k[n]=t($3) "|" t($4); s[n]=t($5); nota[n]=t($6) }
    END {
      for (i = n; i >= 1; i--) {
        if (nota[i] == "RILASCIO") { chiuso[k[i]] = 1; continue }
        if ((k[i] in chiuso) || (s[i] != "?" && s[i] < ora)) continue
        # (2026-09-24, sesto ventaglio, S2 R6): la riga più recente di chi|zona è il presidio; le prime sono
        # rinnovi superati, non presidii in più (niente apostrofi qui: siamo dentro gli apici della shell)
        if (k[i] in visto) continue
        visto[k[i]] = 1
        vivo[i] = 1
      }
      for (i = 1; i <= n; i++) if (i in vivo) print r[i]
    }' "$FILE"
}

case "${1:-}" in
  claim)
    ZONA="${2:?uso: presidio.sh claim <zona> <nota>}"; NOTA="${3:-}"
    init
    ADESSO=$(date +%Y-%m-%dT%H:%M)
    SCADE=$(date -v+${ORARIO}H +%Y-%m-%dT%H:%M 2>/dev/null || date -d "+$ORARIO hours" +%Y-%m-%dT%H:%M 2>/dev/null || echo "?")
    # contesa attuale? (presidio vivo di ALTRO sulla stessa zona)
    VIVI=$(vivi "$ADESSO" | grep -F "| $ZONA |" || true)
    # (S2 R6): lo stesso autore sulla stessa zona era una «CONTESA» con se' stesso — e' un rinnovo
    MIO=$(grep -F "| $CHI | $ZONA |" <<<"$VIVI" || true)
    VIVI=$(grep -vF "| $CHI | $ZONA |" <<<"$VIVI" || true)
    [ -n "$MIO" ] && echo "rinnovo: la tua presenza su '$ZONA' c'era gia' — la scadenza si sposta"
    if [ -n "$VIVI" ]; then
      echo "⚠ CONTESA: sulla zona '$ZONA' c'è già:"; echo "$VIVI"
      echo "  (dichiarato lo stesso: la visibilità non è un permesso — ma avvisati a vicenda)"
    fi
    printf '| %s | %s | %s | %s | %s |\n' "$ADESSO" "$CHI" "$ZONA" "$SCADE" "$NOTA" >> "$FILE"
    echo "presidio dichiarato: $CHI su '$ZONA' fino alle $SCADE"
    echo "ricordati di committare PRESIDI.md presto (la presenza si vede solo se pushata)"
    ;;
  lista)
    [ -f "$FILE" ] || { echo "nessun presidio: il registro non esiste ancora"; exit 0; }
    ADESSO=$(date +%Y-%m-%dT%H:%M)
    POTATI=0
    TMP=$(mktemp)
    while IFS= read -r riga; do
      case "$riga" in
        "| Dichiarato"*|""|"#"*|">"*|---*|"|"*---*) echo "$riga" >> "$TMP"; continue ;;
      esac
      SCAD=$(echo "$riga" | awk -F'|' '{print $5}' | tr -d ' ')
      SCAD="${SCAD:-?}"
      if [ "$SCAD" != "?" ] && [ "$SCAD" \< "$ADESSO" ]; then
        POTATI=$((POTATI+1))
      else
        echo "$riga" >> "$TMP"
      fi
    done < "$FILE"
    [ "$POTATI" -gt 0 ] && { mv "$TMP" "$FILE"; echo "potati $POTATI presidii scaduti (dichiarato, non in silenzio)"; } || rm -f "$TMP"
    ELENCO=$(vivi "$ADESSO")
    VIVI=$(grep -c . <<<"$ELENCO")
    echo "== presidii vivi: $VIVI =="
    [ "$VIVI" -gt 0 ] && sed 's/^/  /' <<<"$ELENCO" || echo "  (nessuno)"
    # contese: stessa zona, chi diversi
    # contesa VERA: due CHI DIVERSI sulla stessa zona (il conteggio parte da 1:
    # il primo nome è sempre lì — si confrontano i nomi distinti, non gli spazi)
    awk -F'|' '/^\| 20/ {c=$3; z=$4; gsub(/ /,"",z); nomi[z"|"c]=1} END {for (k in nomi) {split(k,p,"|"); n[p[1]]++} for (z in n) if (n[z]>1) print "  ⚠ CONTESA su " z ": " n[z] " presidii distinti"}' <<<"$ELENCO" || true
    ;;
  rilascia)
    ZONA="${2:?uso: presidio.sh rilascia <zona>}"
    [ -f "$FILE" ] || { echo "registro assente: niente da rilasciare"; exit 0; }
    MIEI=$(vivi "$(date +%Y-%m-%dT%H:%M)" | awk -F'|' -v c="$CHI" -v z="$ZONA" '{a=$3; b=$4; gsub(/^ +| +$/,"",a); gsub(/^ +| +$/,"",b)} a==c && b==z')
    [ -n "$MIEI" ] || { echo "nessun presidio vivo di $CHI su '$ZONA': niente da rilasciare"; exit 0; }
    # la riga di rilascio scade con l'ultimo presidio che chiude: si potano insieme
    SCADE=$(awk -F'|' '{x=$5; gsub(/ /,"",x); if (x > m) m=x} END {print m}' <<<"$MIEI")
    printf '| %s | %s | %s | %s | RILASCIO |\n' "$(date +%Y-%m-%dT%H:%M)" "$CHI" "$ZONA" "$SCADE" >> "$FILE"
    echo "rilasciati $(grep -c . <<<"$MIEI") presidii di $CHI su '$ZONA' (riga RILASCIO appesa: il registro resta append-only)"
    ;;
  *)
    echo "uso: presidio.sh claim <zona> <nota> | lista | rilascia <zona>" >&2
    exit 1 ;;
esac
