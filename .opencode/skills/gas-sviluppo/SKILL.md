---
name: gas-sviluppo
description: Il sistema generale per sviluppare e revisionare progetti Google Apps Script gestionali (contabilità, magazzino, ciclo attivo/passivo, controllo di gestione, produzioni) — il metodo e le famiglie di difetti MISURATE sul parco reale di ~90 progetti REPO-E, non buon senso generico. Due modalità distinte, CONSULENZA (rispondere a una domanda tecnica: basta il decision tree) e CONSEGNA (produrre un diff che va in produzione: serve anche l'isolamento, la prova di parità e il cancello umano) — confonderle è il modo più facile di fare danni. Fonte: la skill gas-agent di REPO-E (v0.1.0, 95 file, misure 2026-08 su tutto il parco), portata qui in forma distillata con provenienza — l'autorità piena resta là. Usa per qualsiasi sviluppo GAS: nuovo progetto, feature, correzione, revisione, integrazione Business Central, sicurezza, performance. I sub-file si caricano SOLO quando servono (disclosure progressiva): references/metodo.md sempre, references/consegna.md solo per consegne, references/famiglie-difetti.md quando si tocca codice esistente, references/domini-gestionali.md per i calcoli del dominio.
---

# gas-sviluppo — il parco già pagato, portato negli agenti

Il presupposto che questa skill incarna: **il parco REPO-E (~90 progetti GAS che
fanno girare un'azienda vera: ordini, listini, fatture, tesoreria — da soli, di
notte, e sbagliano in silenzio) è già la migliore documentazione possibile**.
Ogni difetto qui citato è MISURATO su quel parco, con popolazione e data. Un
pattern che gira in produzione da mesi batte un pattern scritto a tavolino; un
errore già pagato da un giro, e scritto, non va ripagato.

**Provenienza e confine**: questo file è il DISTILLATO operativo della skill
`gas-agent` di REPO-E (v0.1.0, 2026-08, 95 file). Quando la sessione ha accesso
al repo REPO-E, le pagine di là sono L'AUTORITÀ (specialisti completi, esemplari
con file:riga, pagella aggiornata); questo distillato esiste perché l'hub e i
progetti che lo ereditano devono avere il metodo anche quando REPO-E non è
montato. Le due cose non divergono per negotio: chi cambia una regola qui la
riverifica là.

## Le due modalità (la prima decisione, sempre)

| | CONSULENZA | CONSEGNA |
|---|---|---|
| Prodotto | una risposta | un diff destinato alla produzione |
| Serve | `.claude/skills/gas-sviluppo/references/metodo.md` + il sub-file del campo | anche `.claude/skills/gas-sviluppo/references/consegna.md` (isolamento, parità, PR, cancello umano) |
| Rischio | un consiglio sbagliato si scarta | un diff sbagliato va in produzione |

## Loading sequence (disclosure progressiva — non caricare tutto)

1. **Sempre**: `.claude/skills/gas-sviluppo/references/metodo.md` — i quattro verbi, l'ordine, il banco, i
   sabotaggi, le regole non negoziabili (è il mandato distillato).
2. **Se si tocca codice esistente**: `.claude/skills/gas-sviluppo/references/famiglie-difetti.md` — le
   famiglie misurate del parco con le popolazioni e la domanda discriminante
   di ciascuna: la lente con cui si guarda PRIMA di rilevare.
3. **Se il lavoro è una consegna**: `.claude/skills/gas-sviluppo/references/consegna.md` — worktree (copia di lavoro isolata dello stesso repository),
   baseline, prova di parità a 3 livelli, protocollo PR, `clasp` (lo strumento Google per il deploy Apps Script) mai.
4. **Se il lavoro calcola cifre di dominio**: `.claude/skills/gas-sviluppo/references/domini-gestionali.md`
   — le domande della contabilità, del controllo di gestione, della
   produzione, dello sviluppo business (con gli oracoli dell'hub quando il
   calcolo esiste già: `docs/mappa-dominio-gas-src.md` dice quali).

## I quattro verbi (scheda completa in metodo.md)

ANALIZZA (il progetto intero, il censimento è il primo prodotto — anche i
difetti ASSENTI dichiarati col comando che li cerca) → TESTA (il banco si
scrive PRIMA della correzione: PARITÀ + CORREZIONE) → CORREGGE (nella copia di
lavoro, poi sabota la correzione stessa) → PROGETTA (dieci righe: cosa resta,
cosa serve, le domande di dominio da fare a una persona).

## Gli oracoli e i tool dell'hub

tools/ contiene 16 tool Python: 11 oracoli contabili, 2 rilevatori (gas_qualita, verifica_banco), indice BC e correttore tipi.

## Il primo artefatto: le domande, non il codice

Quando una sessione apre una repo con ambiguità di dominio aperte (o con una misura che ne
rivela una: N>1 candidati senza chiave), il PRIMO artefatto consegnato è il **file delle
domande numerate** — ognuna con perché conta e le due parti dichiarate (cosa può dire il
sistema / cosa solo una persona), riga `Risposta` vuota, conteggio in testa. Il codice viene
dopo le risposte, o dopo che le domande sono state poste. Su REPO-W questo modello ha chiuso
17 domande in un giro; su REPO-V la domanda decisiva è arrivata a fine giornata, col pannello
sbagliato già costruito. `tools/fixture-provenienza.sh` è il dente gemello per i banchi.

## Il catalogo pattern

patterns/ contiene i pattern minati dal campo: cerca prima di reinventare. Il conto vive nell'indice (`ls patterns/*.md | grep -v README | wc -l`), non qui: un numero in questa riga invecchia il giorno dopo.
Indice: patterns/README.md

## Le tre regole che non negoziano

1. **Esegui, non dedurre** (misurato sul parco: 60 comandi di lettura su 61,
   e l'unica esecuzione della giornata aveva trovato il difetto peggiore).
2. **`clasp push` mai** — il deploy sul vivo lo fa una persona dal suo Mac.
3. **Mai il valore di una credenziale**, e mai proporre di ruotarla: si
   prosegue e si dichiara.


## Vedi anche

Per calcoli contabili specifici: skill `controllo-gestione` con i suoi 11 oracoli.


## Vedi anche

Dopo il deploy, la verifica visiva: skill `verifica-visiva`.
