#!/bin/bash
# debiti-riapertura.sh — IL DEBITO SI BRUCIA ALLA RIAPERTURA (regola di Luca, 2026-09-09):
# alla riapertura di un progetto, i debiti DI DOMINIO diventano DOMANDE SINGOLE (una alla
# volta, col perché) e quelli RISOLVIBILI si fanno PRIMA di procedere. Il debito non è un
# backlog che invecchia: è un passivo che matura interessi.
# ⚠ QUESTO TOOL NON SCRIVE: legge DEBITI.md e le domande aperte, e prepara la riapertura.
#
# Uso: bash tools/debiti-riapertura.sh [dir-progetto]   (default: repo corrente)
# Esce: 0 (informa, non blocca — la pressione sta nel farla visibile) · 1 cartella inesistente
set -uo pipefail
DIR="${1:-.}"
SE="$(cd "$(dirname "$0")" && pwd)"
cd -- "$DIR" || { echo "⛔ dir inesistente: $DIR"; exit 1; }
echo "== RIAPERTURA: il debito si brucia qui =="

python3 - <<'PY'
import re, os, sys

def leggi(p):
    try: return open(p, encoding="utf-8", errors="ignore").read()
    except FileNotFoundError: return ""

deb = leggi("DEBITI.md")
if not deb:
    print("nessun DEBITI.md: niente da bruciare (dichiarato, non taciuto)")
    sys.exit(0)

# Una sezione e' APERTA se ha almeno una RIGA DI DEBITO (riga di tabella che inizia con una
# data) non saldata; senza righe di debito, se il corpo non dice SALDATO.
# (Revisione 10 giri, 2026-09-23): prima bastava UNA parola «saldato» nel corpo per chiudere
# la sezione intera — 8+ righe aperte restavano invisibili perche' condividevano la sezione
# con una riga saldata (es. l'hook clasp con codice morto, sotto «Pattern candidato»).
RIGA_DEBITO = re.compile(r"^\|\s*\d{4}-\d{2}-\d{2}")
SALDO_PAROLA = re.compile(r"SALDAT[OA]", re.I)
# (2026-09-23, notte dei giri): «SALDAT[OA]» ovunque nella riga la chiudeva — anche «NON SALDATO»
# o «PARZIALMENTE SALDATA» (sul DEBITI vero una riga cosi' era chiusa da un mese). Una menzione
# conta come saldo solo se non e' preceduta da una negazione o da un «in parte».
NEGA_SALDO = re.compile(r"(non|parzialmente|in parte|meta'|metà)\s+$", re.I)
class _Saldo:
    def search(self, testo):
        return any(not NEGA_SALDO.search(testo[max(0, m.start() - 16):m.start()])
                   for m in SALDO_PAROLA.finditer(testo))
SALDO = _Saldo()
sezioni = re.split(r"^## ", deb, flags=re.M)[1:]
def celle_di(riga):
    return [c.strip() for c in riga.strip().strip("|").split("|")]
# (2026-09-24, quinto ventaglio, R1 R1): l'unita' di conto era la SEZIONE — dieci righe vive nella stessa
# sezione, nove domande di dominio a se', uscivano «DOMINIO: 1». Ora ogni riga viva e' un debito: il titolo
# e' «sezione — scorciatoia», il corpo e' la prosa della sezione piu' la riga. Una sezione senza righe di
# debito resta un debito solo, come prima.
aperte = []
sezioni_vive = 0
# (2026-09-24, quinto ventaglio, R1 R3): una riga SALDATO spariva anche col residuo ⏳ che dichiara («fatto.
# ⏳ NON verificato dal vivo»). I residui si raccolgono a parte: non gonfiano gli aperti, ma si vedono.
residui = []
for s in sezioni:
    titolo = s.split("\n")[0].strip()
    righe = s.split("\n")[1:]
    debiti = [l for l in righe if RIGA_DEBITO.match(l.strip())]
    for l in debiti:
        if SALDO.search(l) and "⏳" in l:
            c = celle_di(l)
            residui.append((f"{titolo} — {(c[1] if len(c) > 1 else '')[:70]}", re.search(r"⏳[^|]*", l).group(0).strip()))
    if debiti:
        vive = [l for l in debiti if not SALDO.search(l)]
        if not vive:
            continue
        sezioni_vive += 1
        prosa = [l for l in righe if not l.strip().startswith("|")]
        for v in vive:
            c = celle_di(v)
            scorciatoia = c[1] if len(c) > 1 else ""
            aperte.append((f"{titolo} — {scorciatoia[:70]}", "\n".join(prosa + [v])))
    elif not SALDO.search(s):
        sezioni_vive += 1
        aperte.append((titolo, s))

# classificazione: DI DOMINIO se la sezione chiede una decisione/contains domande/dominio/Luca;
# RISOLVIBILE altrimenti (lavoro tecnico che la sessione può fare da sola).
# (D21b, test del sistema completo 2026-09-20): si guarda il corpo INTERO — con una finestra
# di 600 caratteri «Valutare Qwen 3.8 Flash» (decisione hardware di Luca a offset 754)
# finiva tra i RISOLVIBILI.
# (Revisione 10 giri, 2026-09-23): terza classe, IN ATTESA — la riga dichiara con «⏳» l'evento
# esterno che la sblocca (il Mac, la terza ricorrenza, un gh autenticato). Prima finivano tra
# i RISOLVIBILI «da fare subito» cose che nessuna sessione poteva fare subito. Il marcatore e'
# esplicito nella riga, non indovinato: una sezione e' IN ATTESA se TUTTE le sue righe vive lo
# portano (una riga viva senza ⏳ la riporta fra le altre due classi).
dominio, risolvibili, attesa = [], [], []
for titolo, corpo in aperte:
    t = titolo.lower()
    vive = [l for l in corpo.split("\n") if RIGA_DEBITO.match(l.strip())]
    if vive and all("⏳" in l for l in vive):
        attesa.append((titolo, corpo))
        continue
    if re.search(r"dominio|decis|domanda|luca|valutare da|da decidere|censire", t + " " + corpo.lower()):
        dominio.append((titolo, corpo))
    else:
        risolvibili.append((titolo, corpo))

def perche_di(corpo):
    """La prima riga «perché» UTILE della sezione. (D21a): la regex `perch` combaciava con
    l'intestazione della tabella («| Data | Scorciatoia | Perché rimandata | …») e tutte le
    domande mostravano quella. Le intestazioni e i separatori di tabella si saltano; da una
    riga di tabella si prende la cella che risponde, non la riga intera."""
    righe = corpo.split("\n")
    # una riga di debito ha la sua colonna «Perché rimandata» (la terza): e' quella che risponde
    vive = [l for l in righe if RIGA_DEBITO.match(l.strip())]
    if len(vive) == 1 and len(celle_di(vive[0])) > 2:
        return re.sub(r"^perch[eé] conta:\s*", "", celle_di(vive[0])[2], flags=re.I)
    for i, l in enumerate(righe):
        s = l.strip()
        if not s:
            continue
        if s.startswith("|"):
            if re.match(r"^\|\s*:?-{3,}", s):
                continue  # separatore
            if i + 1 < len(righe) and re.match(r"^\|\s*:?-{3,}", righe[i + 1].strip()):
                continue  # intestazione: la riga sotto e' il separatore
            celle = [c.strip() for c in s.strip("|").split("|")]
            for c in celle:
                if re.search(r"perch|serve|decide", c, re.I):
                    return c
            continue
        if re.search(r"perch|serve|decide", s, re.I):
            return s.strip("- #* ")
    return ""

# (D5, decisione di Luca 2026-09-23: «a») LA PREMESSA INVECCHIA COL CODICE. Una voce motiva il
# rinvio con un fatto sul codice; se un file che cita e' cambiato in git DOPO la voce, la premessa
# va riverificata (dal campo REPO-G: credenziali spostate via nella PR #36, obiezione rimasta
# com'era per giorni). La data della voce e' la PIU' RECENTE scritta nella riga: chi riverifica
# la aggiorna, e l'orologio riparte. Solo file che esistono; senza git, lo si dichiara.
import subprocess
IN_GIT = subprocess.run(["git", "rev-parse", "--git-dir"], capture_output=True).returncode == 0
def premesse(corpo):
    avvisi = []
    if not IN_GIT:
        return avvisi
    for riga in corpo.split("\n"):
        if not RIGA_DEBITO.match(riga.strip()):
            continue
        data = max(re.findall(r"\d{4}-\d{2}-\d{2}", riga))
        for f in sorted(set(re.findall(r"`([A-Za-z0-9_./-]+)`", riga))):
            if not os.path.isfile(f):
                continue
            log = subprocess.run(["git", "log", f"--since={data} 23:59:59", "--format=%cs", "--", f],
                                 capture_output=True, text=True).stdout.split()
            if log:
                avvisi.append(f"⚠ premessa da riverificare: {f} cambiato {len(log)} volte dopo il {data} (ultimo {log[0]})")
    return avvisi[:3]
def stampa_premesse(corpo):
    for a in premesse(corpo): print(f"      {a}")

print(f"debiti APERTI: {len(aperte)} — di DOMINIO: {len(dominio)} (domande, una alla volta) · RISOLVIBILI: {len(risolvibili)} (da fare PRIMA di procedere) · IN ATTESA: {len(attesa)} (evento esterno dichiarato)")
print()
if risolvibili:
    print("DA FARE SUBITO (risolvibile — il prossimo lavoro parte dopo questi):")
    for i, (t, _) in enumerate(risolvibili, 1):
        print(f"  R{i}. {t}")
        stampa_premesse(_)
    print()
if dominio:
    print("DOMANDE SINGOLE PER IL PADRONE DEL DOMINIO (una alla volta, nell'ordine — ogni risposta chiude un debito):")
    for i, (t, c) in enumerate(dominio, 1):
        perche = perche_di(c)
        print(f"  D{i}. {t}")
        if perche: print(f"      perché conta: {perche[:100]}")
        stampa_premesse(c)
    print()
    print("Modello: una domanda per messaggio, risposta → subito codice/regola, poi la prossima.")
if attesa:
    print("IN ATTESA DI UN EVENTO (dichiarato con ⏳ nella riga — non si fa ora, si guarda che l'evento non sia gia' accaduto):")
    for i, (t, c) in enumerate(attesa, 1):
        ev = [re.search(r"⏳[^|]*", l).group(0).strip() for l in c.split("\n") if "⏳" in l]
        print(f"  A{i}. {t}")
        for e in ev: print(f"      {e[:110]}")
        stampa_premesse(c)
    print()
if residui:
    print("SALDATI CON RESIDUO ⏳ (chiusi, ma con una prova dichiarata che manca — si guarda se l'evento e' accaduto):")
    for i, (t, e) in enumerate(residui, 1):
        print(f"  S{i}. {t}")
        print(f"      {e[:110]}")
    print()
print(f"chiusi/storici: {len(sezioni) - sezioni_vive} sezioni saldate restano come memoria.")
if not IN_GIT:
    print("premesse: la cartella non e' una repo git — l'invecchiamento delle premesse NON e' controllato (dichiarato)")
PY

# (2026-09-24, quinto ventaglio, R1 R6): le citazioni file:riga della memoria scivolano col codice (nove su
# dieci). Qui se ne dice solo il conto; l'elenco lo da' cita-verifica. Un avviso: la riapertura non si ferma.
# (2026-09-25, ottavo ventaglio, O3 R2): DEBITI_SENZA_DERIVA=1 la salta. Un git blame per citazione cresce col tempo: il
# gancio d'avvio (10 s di tetto) la pagava per poi scartarla, e da circa 250 citazioni moriva — sessione senza patti.
if [ "${DEBITI_SENZA_DERIVA:-0}" != 1 ] && [ -f DEBITI.md ] && [ -f "$SE/cita-verifica.sh" ]; then
  DOCS=(DEBITI.md); [ -f docs/errori/REGISTRO.md ] && DOCS+=(docs/errori/REGISTRO.md)
  echo "$(bash "$SE/cita-verifica.sh" --deriva "${DOCS[@]}" 2>&1 | tail -1) — l'elenco: bash tools/cita-verifica.sh --deriva ${DOCS[*]}"
fi
