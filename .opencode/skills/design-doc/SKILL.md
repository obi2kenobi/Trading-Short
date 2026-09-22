---
name: design-doc
description: Trasforma un'idea o una richiesta vaga in 2-3 opzioni concrete confrontate su criteri espliciti dichiarati PRIMA (costo/rischio/reversibilità + criteri specifici alla decisione, in una tabella opzioni×criteri — 4° ciclo, set 2 "progettare", 2026-08-23), SENZA implementare — la scelta resta sempre di chi possiede il progetto. Nato da un debito dichiarato in DEBITI.md (2026-08-21): il comando era citato in METHOD.md/docs/system.md come parte della pipeline "/brainstorming → /design-doc → commessa" ma non esisteva nessun file che lo implementasse (le fonti di verità dichiarate, .zcode/commands/ e .claude/commands/, non esistono nel repo). Usa quando l'utente chiede di progettare una feature nuova, valutare alternative architetturali, o invoca /design-doc esplicitamente — prima di scrivere codice, non dopo. Non sostituisce dev-critic (quello trova gap in codice ESISTENTE); questo struttura una decisione su codice che NON esiste ancora. Non sostituisce /nuova-commessa (quello compone l'issue finale); questo produce l'opzione scelta che /nuova-commessa cita come "da dove nasce" la commessa.
---

# design-doc — le opzioni prima del codice

Il difetto che questo comando chiude è documentato dal vivo in
`docs/test-processo-2026-08-21.md`: il primo tentativo di sviluppare una feature nuova è
stato "pattern-matching, non progettazione" (un bottone gemello copiato invece di una
domanda di dominio) — l'operatore aveva saltato la fase di design. Il sistema non
difendeva il proprio metodo perché il metodo non aveva un comando, solo prosa.

## 0. Input — cosa serve prima di iniziare

Una richiesta, anche vaga ("serve un modo per X", "vorrei che Y funzionasse meglio").
Se la richiesta è già una decisione presa ("fai X con la libreria Y"), chiedi PRIMA se è
una scelta ferma o se vale la pena esplorare alternative — non aprire un design-doc per
decisioni già chiuse (regola "Only what is asked").

## 1. Metodo

1. **Riformula il problema, non la soluzione.** Prima di generare opzioni, scrivi in una
   frase cosa deve essere vero DOPO (il criterio di successo), non come arrivarci — se non
   riesci a farlo, la richiesta è ancora troppo vaga: fai le domande che mancano (stesso
   spirito di `/brainstorming`, che può precedere questo comando quando i requisiti sono
   ancora aperti).
1bis. **Dichiara i VINCOLI DI SQUALIFICA prima dei criteri di confronto** (6° ciclo, set 2,
   2026-08-24 — "scelta delle migliori idee" parte prima: prima di chiedersi quale
   opzione sia migliore, dichiara quali condizioni rendono un'opzione inaccettabile in
   partenza, qualunque sia il suo punteggio): es. "nessun segreto nuovo nella repo
   pubblica", "nessuna dipendenza che rompe il turno notturno", "nessun calcolo
   contabile senza oracolo". Un'opzione che viola un vincolo non entra nella tabella —
   o vi entra SOLO per essere registrata come squalificata, col vincolo violato: una
   gara fra opzioni di cui una è già morta non è un confronto, è teatro. I vincoli di
   squalifica sono pochi (2-3) e verificabili; tutto ciò che non squalifica è un
   criterio di confronto, e va al punto successivo.
2. **Dichiara i criteri di confronto PRIMA delle opzioni** (4° ciclo, set 2
   "progettare", 2026-08-23) — non dopo, e non a criteri diversi per ogni opzione (altrimenti
   il confronto è truccato: ogni opzione vince sul criterio che la favorisce). Tre criteri
   sono quasi sempre rilevanti — **costo** (tempo/effort per arrivare a un primo risultato
   funzionante), **rischio** (cosa si rompe se va male: sicurezza, breaking change, dati),
   **reversibilità** (quanto costa tornare indietro se la scelta si rivela sbagliata) — a
   cui aggiungi 1-2 criteri specifici della decisione (es. "tempo a primo valore",
   "dipendenze nuove", "manutenzione ricorrente") solo se pertinenti, non per riempire una
   lista. Se un criterio proposto dall'utente non è verificabile ("sia elegante"), chiedi
   di riformularlo in modo confrontabile prima di procedere (stesso spirito di `/goal`).
3. **Genera 2-3 opzioni reali**, non una opzione vera e due paglia. Per capire "cosa
   cambia concretamente" senza leggere tutto il codebase (4° ciclo, set 2
   "progettare", giro 2, 2026-08-23): se `graphify-out/graph.json` esiste, usa
   `graphify query`/`graphify explain` per orientarti su dove vivono i componenti
   coinvolti (regola CLAUDE.md §7 "Navigazione before reading" + `AGENTS.md`) — è
   orientamento e localizzazione, non un oracolo su COME i componenti si chiamano a
   vicenda (`calls` non è risolto, lezione già pagata: non fidarti del grafo per la
   semantica, solo per dove guardare). **Se `graphify-out/graph.json` NON esiste**
   (5° ciclo, set 2 "progettare", giro 2, 2026-08-23 — caso reale di questa stessa
   sessione, non ipotetico: il grafo non è installato qui) — non restare senza un
   passo: usa `Grep`/`Glob` sui termini di dominio della richiesta per un territorio
   piccolo e già chiaro, o l'agente `Explore` (breadth "quick"/"medium") quando il
   territorio è ampio o i nomi dei componenti coinvolti non sono ancora noti — stessa
   soglia già in uso nel resto del sistema ("3+ query esplorative → Explore"), non una
   regola nuova inventata qui. Poi, per ogni opzione:
   - cosa cambia concretamente (file/componenti coinvolti, a un livello alto — non il
     territorio riga-per-riga, quello è compito della commessa dopo);
   - **cosa tocca ALTrove: gli effetti di secondo ordine** (6° ciclo, set 2, 2026-08-24)
     — per ogni opzione una riga su cosa potrebbe risentirne INDIRETTAMENTE: il turno
     notturno, il gate, altre skill/agenti che citano ciò che cambia, i progetti
     onboardati che ereditano il pattern. Un'opzione che sembra isolata raramente lo è
     in un sistema dove tutto si cita per riferimento (pattern `citazione-non-presidio`
     al contrario: le citazioni sono fisarmoniche — aggiungi una, e TUTTE le parti che
     la citano si muovono);
   - **un punteggio per ciascun criterio dichiarato al punto 2**, in una tabella
     opzioni×criteri, ogni cella con un giudizio breve (Basso/Medio/Alto o una frase, non
     un numero nudo senza motivazione — un "3/5" senza perché è un trade-off nascosto, non
     uno confrontabile) — mai un'opzione senza controindicazioni dichiarate;
   - quando ha senso scegliERLA (non "è la migliore", ma "sceglila se ti importa di Z").
   La tabella struttura il confronto; non lo decide — resta all'utente scegliere anche
   contro il punteggio più alto, se un criterio pesa più degli altri per lui.
3bis. **Se un criterio CRITICO di un'opzione è ignoto, proponi uno spike** (6° ciclo,
   set 2, 2026-08-24): quando la cella della tabella che deciderebbe la scelta non si
   può riempire leggendo (una latenza non documentata, una libreria mai usata di
   notte, un limite di quota non dichiarato), non indovinare la cella e non lasciarla
   vaga: proponi un esperimento a tempo e scopo vincolati — `/goal "misurare X in
   condizioni Y" | max 1 tentativo`, output da buttare (il codice dello spike NON è
   l'inizio dell'implementazione: quando lo scopo è misurare, il risultato è un
   numero, non una base di codice). Lo spike si fa su UN criterio di UN'opzione, mai
   "per esplorare l'opzione intera" — quello è implementare con un altro nome.
4. **Le opzioni scartate restano scritte**, col perché — non solo la vincente (regola
   "Surface interpretations and tradeoffs — don't pick silently"). Chi legge fra sei mesi
   deve vedere anche cosa NON si è fatto, non solo cosa sì.
4bis. **Se NESSUNA opzione ha un punteggio accettabile sui criteri critici** (5° ciclo,
   set 2, giro 7, 2026-08-23 — "scelta delle migliori idee" quando le idee disponibili
   sono tutte cattive, non solo quando una vince): non forzare una scelta fra tre
   opzioni scadenti solo perché la tabella lo richiede. È un segnale che il problema
   (non la soluzione) va rivisto — torna a `/brainstorming` con quello che le opzioni
   hanno rivelato ("nessuna strada economica non rischia X" è già informazione nuova
   sul problema), non presentare comunque tre opzioni deboli come se il confronto le
   avesse "risolte".
5. **Non implementare.** Questo comando produce un documento, non una PR. Se l'utente
   chiede anche l'implementazione, trattala come uno step separato ed esplicito DOPO che
   la scelta è stata fatta — mai un'opzione già scritta come codice nella risposta.
6. **La scelta finale è dichiarata da chi possiede il progetto**, non presunta. Se
   l'utente non ha ancora scelto, il documento resta con le opzioni aperte — non
   inventare una raccomandazione spacciata per decisione.

## 1bis. Esempio del formato (criteri → tabella, non narrativa libera)

Richiesta: "vorrei essere avvisato quando il gate del mattino fallisce, non solo trovarlo
nel report". Vincoli di squalifica (dichiarati PRIMA, verificabili): (1) nessun segreto
nuovo nella repo pubblica, (2) nessun canale che dipenda da un servizio esterno
obbligatorio per il gate. Criteri di confronto dichiarati prima delle opzioni: **costo**,
**rischio**, **reversibilità**, più uno specifico alla decisione: **dipendenze nuove**.
(L'opzione webhook di terze parti SENZA fallback locale violerebbe il vincolo 2: entra
nella tabella solo come "squalificata", non come concorrente.)

| Opzione | Costo | Rischio | Reversibilità | Dipendenze nuove |
|---|---|---|---|---|
| A. Estendere `night-shift/morning-digest.sh` esistente (già invia notifiche macOS) | Basso — una riga in più nello script già presente | Basso — nessun canale nuovo, nessun segreto nuovo | Alta — si rimuove una riga | Nessuna |
| B. Webhook Slack/Discord | Medio — nuovo endpoint, nuovo segreto da gestire | Medio — un segreto in più da mascherare (pattern `segreto-come-impronta`) | Media — richiede rimuovere il webhook lato servizio esterno | Un token/webhook URL |
| C. Solo il report esistente, nessun avviso attivo | Zero | Zero | Totale (nessun cambiamento) | Nessuna |

La tabella struttura il confronto ma non sceglie: A vince su costo/rischio/reversibilità,
ma se l'obiettivo è essere avvisato anche lontano dal Mac, B può comunque essere la
scelta giusta nonostante il punteggio peggiore — la decisione resta di chi possiede il
progetto (punto 6).

## 2. Dove va a vivere il documento (mai solo in chat)

Il documento persistito include SEMPRE la tabella opzioni×criteri del punto 3, non solo
la scelta finale in prosa (4° ciclo, set 2, giro 3, 2026-08-23) — altrimenti chi legge fra
sei mesi vede COSA è stato scelto ma non PERCHÉ quel punteggio, e il confronto strutturato
del passo 3 si perde nel momento esatto in cui servirebbe di più (a decisione già presa,
quando nessuno lo ricostruisce più a mente).

- **In questo hub**: una voce in `SAL.md` (sezione "### <data> — design: <titolo>"),
  stesso formato delle altre voci — è già la fonte di verità per decisioni qui.
- **In un progetto onboardato con un proprio diario vivo** (es. `docs/bc/SAL.md`,
  o un `SAL.md` di progetto): stessa convenzione, nello stesso file.
- **In un progetto senza diario vivo**: crea `docs/design/<slug-titolo>.md` — un file per
  decisione, con le opzioni e la scelta. Lo slug deve essere stabile: una commessa futura
  lo cita per percorso esatto (vedi §3).

In ogni caso: **il documento ha un percorso o un link stabile**, perché la sezione
`## Design` di una commessa night-shift lo deve poter citare per riferimento reale, non
per prosa (pattern `citazione-non-presidio`: un design-doc che vive solo nella
conversazione non è verificabile da chi legge la issue dopo).

## 3. Dopo la scelta — notte o giorno, non solo la notte (4° ciclo, set 2, giro 10, 2026-08-23)

Quando l'opzione è scelta, il passo successivo dipende dal territorio, non è sempre lo
stesso:

- **Territorio grande, o esecuzione da modello locale** → `/nuova-commessa`: la sezione
  `## Design` della issue cita il PERCORSO del documento appena scritto (non lo riassume a
  memoria) — "da dove nasce" diventa un riferimento verificabile, non un'affermazione.
- **Territorio piccolo, verificabile in poche iterazioni durante il giorno** → `/goal
  "<obiettivo verificabile derivato dal criterio di successo del punto 1>" | max N
  tentativi` — non ha senso passare dalla coda notturna (commessa precaricata, PR bozza,
  review del mattino) per un cambiamento che il giorno stesso può verificare e chiudere.
  L'obiettivo del `/goal` è il criterio di successo dichiarato al punto 1 del metodo, non
  uno nuovo inventato qui.

Nei due casi il documento del design-doc resta il "da dove nasce" — cambia solo CHI
esegue e con quale disciplina di verifica, non se il design è stato fatto.

## 4. Regole non negoziabili (eredità da CLAUDE.md)

- Niente implementazione in questo passo — è un documento di decisione, non una PR.
- Ogni opzione ha un trade-off dichiarato, comprese quelle scartate.
- I criteri si dichiarano PRIMA delle opzioni, sempre gli stessi per tutte — mai
  criteri diversi scelti a posteriori per far vincere un'opzione già preferita.
- Il punteggio struttura il confronto, non lo decide: non trasformare la tabella in
  una raccomandazione implicita — la scelta resta di chi possiede il progetto.
- Se la richiesta è ambigua su COSA deve essere vero dopo, fermati e chiedi — non
  indovinare il criterio di successo per poi progettare la risposta sbagliata.


## Vedi anche

skill `brainstorming` (il passo prima)
