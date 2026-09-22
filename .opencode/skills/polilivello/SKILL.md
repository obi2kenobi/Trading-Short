---
name: polilivello
description: Usa questa skill quando devi STUDIARE un progetto di destinazione prima di toccarlo — capire COSA FA, COME LO FA, e COME POTREBBE FARLO MEGLIO attraverso sei livelli di analisi (identità, struttura, comportamento, meccanica, storia, dominio), chiudendo con la fase critica che apre il brainstorming. Non è la selezione del contesto (skill selezione-contesto: cosa caricare per un lavoro) e non è il brainstorming (skill brainstorming: raffinare una richiesta) — è lo STUDIO del bersaglio: quella comprensione che nel campo ha fatto la differenza fra revisioni che trovano e revisioni che guardano. Il materiale grezzo dei livelli meccanici lo prepara tools/polilivello.sh; il senso lo fai tu. Usa quando arrivi su un progetto nuovo, quando una revisione deve partire, quando un'idea di miglioramento non nasce, o invoca /polilivello esplicitamente.
---

# polilivello — capire il bersaglio prima di avere ragioni su di lui

> Le tre domande di senso, in ordine: **Cosa fa? Come lo fa? Come lo potrebbe
> fare meglio?** Saltare la prima produce consigli per un progetto immaginato;
> saltare la seconda produce suggerimenti generici; solo chi ha risposto le
> prime due ha il diritto di rispondere la terza.

## 0. Quando scatta

Arrivi su un progetto di destinazione (nuovo da onboardare, da revisionare, da
migliorare, o su cui far nascere idee). La tentazione è partire dal livello che
si conosce già (il codice, se sei programmatore; il foglio, se sei utente).
Il protocollo impone l'ordine: dal GROSSO al fine, dall'identità alla critica.

## 1. I sei livelli

**L1 — Identità** (una riga, guadagnata). Che cos'è questo progetto per chi lo
usa? Non il nome del file: la frase che direbbe l'utente («il pezzo che ogni
mese mi dice quanto vale il magazzino»). Se non riesci a scriverla in una riga,
non hai ancora capito il progetto — hai solo letto dei file.

**L2 — Struttura** (la mappa). File e dimensioni, entrypoint (trigger, menu,
function*), fogli e cartelle Drive toccati, dipendenze esterne (BC, UrlFetch,
Properties), il grafo se esiste (graphify). Meccanico: `tools/polilivello.sh <dir>`.

**L3 — Comportamento — COSA FA** (per ogni entrypoint): quando parte, cosa
legge, cosa scrive, cosa vede l'utente. Il verbo del progetto: conta, avvisa,
trasforma, archivia? Un progetto che «fa tante cose» è spesso un progetto che
fa una cosa mal dichiarata più tre pezzi orfani: elencali separatamente.

**L4 — Meccanica — COME LO FA** (dentro il motore): le formule (dove stanno?
sono dichiarate con provenienza o sepolte?), i flussi dati (da dove a dove),
i punti di fragilità (famiglie di difetti già misurate: `famiglie-difetti`),
le assunzioni implicite (le cose che il codice dà per scontato sul mondo).

**L5 — Storia** (perché è così): date nel codice, commenti che raccontano
incidenti, git log se c'è, il SAL se il progetto ne ha uno. La storia spiega
le stranezze: il pezzo contorto spesso è una cicatrice, non un errore — e
«sistemarla» senza saperlo riapre la ferita.

**L6 — Critica — COME POTREBBE FARLO MEGLIO**: qui, e solo qui, si apre il
brainstorming. Con L1-L5 in mano, le provocazioni della skill `brainstorming`
(fase generativa) partono da terreno vero invece che dall'immaginazione.

## 2. Le regole dello studio

1. **Una riga di identità prima di dieci di codice.** Se dopo L2 non sai dire
   cosa fa per l'utente, rileggi la struttura finché non lo sai.
2. **Cita, non parafrasa.** Ogni affermazione di comportamento porta file:riga.
   «Cerca la prima riga utile» è un'opinione; «Codice.js:46-58 salta l'header»
   è un fatto.
3. **Le formule si cercano, non si indovinano.** Se il progetto calcola, la
   formula sta da qualche parte: trovala e citane la fonte. Se non la trovi,
   dichiara «formula non localizzata» — è un rilievo, non un vuoto da riempire.
4. **La storia non si giudica.** Le cicatrici si documentano; si «sistemano»
   solo dopo aver capito cosa hanno guarito.
5. **La critica senza le prime due domande è vietata.** Il primo «si potrebbe
   fare meglio» arriva solo dopo L3 e L4 compilati: chi consiglia prima ha
   smesso di studiare.

## 3. Il foglio di lavoro

L'output dello studio (in docs/ o nel report di commessa):

```markdown
# <Progetto> — analisi polilivello (data)
L1 Identità: <una riga guadagnata>
L2 Struttura: <N file, M entrypoint, dipendenze: ...> (scaffold: polilivello.sh)
L3 Cosa fa: <per entrypoint: trigger → input → output>
L4 Come lo fa: formule (file:riga) · flussi · fragilità · assunzioni implicite
L5 Storia: <date, incidenti citati, perché è così>
L6 Come potrebbe farlo meglio: <dopo le provocazioni — rimanda al brainstorming>
```

Il comando `bash tools/polilivello.sh <dir-progetto>` produce lo scaffold
meccanico di L2 e i semi di L4/L5 (entrypoint, fogli toccati, dipendenze,
date, marcatori di debito, TODO/legacy): il senso lo compili tu, livello per
livello, citando.
