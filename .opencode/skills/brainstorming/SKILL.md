---
name: brainstorming
description: Raffina una richiesta vaga in requisiti concreti PRIMA che qualcuno scriva codice o un design-doc — domande socratiche, una alla volta, senza proporre soluzioni finché il problema non è chiaro. Nato da un incidente reale documentato in docs/test-processo-2026-08-21.md: il primo tentativo di sviluppare una feature nuova è stato "pattern-matching, non progettazione" (un bottone gemello copiato invece di una domanda di dominio) perché l'operatore aveva saltato questo passo — citato ovunque in METHOD.md/docs/system.md come prima fase della pipeline ("/brainstorming → /design-doc → commessa") ma mai implementato come file (stesso debito già chiuso per /design-doc). Usa quando l'utente porta un'idea vaga ("servirebbe qualcosa per X", "vorrei migliorare Y") prima di passare a /design-doc o scrivere codice, o invoca /brainstorming esplicitamente. Non sostituisce /design-doc (quello struttura opzioni già chiare, confrontandole su criteri espliciti); questo arriva prima, quando non è ancora chiaro COSA si vuole davvero.
---

# brainstorming — le domande prima delle risposte

Il fallimento che questo comando chiude non è ipotetico: è nella cronaca di
`docs/test-processo-2026-08-21.md` — saltare questo passo ha prodotto una soluzione
copiata da un pattern visto altrove invece che una risposta al problema di dominio
reale. Il sintomo di un brainstorming saltato è sempre lo stesso: la prima frase della
risposta è già una soluzione ("aggiungiamo un bottone che fa X"), non una domanda.

## 0. Quando si usa (e quando NO)

Usalo quando la richiesta è vaga, aperta, o "sembra semplice ma non lo è ancora
abbastanza per essere una commessa". NON usarlo quando la richiesta è già una decisione
ferma e concreta ("aggiungi un campo `note` a questa tabella") — lì si passa dritti al
territorio/commessa, il brainstorming su una richiesta già chiara è solo attrito.

## 1. Metodo — socratico, una domanda alla volta

1. **Non proporre soluzioni nella prima risposta.** Rifletti la richiesta con la domanda
   che manca: chi la usa, quale problema reale risolve (non quale funzionalità aggiunge),
   cosa succede oggi senza — se non sai rispondere a queste da solo, falle all'utente.
2. **Una domanda per turno**, non una lista di dieci. Chi risponde a una domanda alla
   volta resta nel problema; una lista intera invita a rispondere in fretta e superficie.
3. **Divergere PRIMA di convergere (6° ciclo, set 2, 2026-08-24).** Dopo le prime 2-3
   risposte, se il problema ammette letture diverse, proponi 2-3 RIFORMULAZIONI del
   problema — non soluzioni: "il problema è (a) il flusso che non esiste, (b) la
   visibilità di quello che esiste, o (c) i dati che non quadrano?". Una riformulazione
   scelta dall'utente vale più di dieci domande in più: chiude la divergenza con una
   decisione, non con la stanchezza. Se il problema ha UNA sola lettura plausibile,
   salta questo passo — divergere su un problema univoco è attrito, non profondità
   (stesso criterio del punto 5).
3bis. **Cerca la DOMANDA DI DOMINIO, non solo il criterio di successo** (7°
   ciclo, set 2 — dal corpus gas-agent di REPO-E): la riga che dice «se il
   mondo si comporta così, questa soluzione è dannosa». Prima di convergere su
   COSA deve essere vero dopo, chiediti COSA DIPENDE DAL MONDO REALE e non dal
   codice: scadenze contrattuali, regole fiscali, convenzioni aziendali non
   scritte. Se esiste, è la prima cosa da scrivere — e se chi governa non sa
   rispondere, la soluzione va progettata per dichiararlo, non per indovinarlo.
   Se non esiste, dichiara «nessuna domanda di dominio: perché» — il silenzio
   si legge «non serviva» e vuol dire «non ci ho pensato».
4. **Cerca il criterio di successo, non la feature.** "Cosa deve essere vero dopo" è la
   domanda che chiude il brainstorming — quando l'utente la sa rispondere in una frase
   verificabile, il passo è finito (regola "Goal-driven execution" di CLAUDE.md).
5. **Se emergono 2+ strade plausibili**, non scegliere: è il momento di passare a
   `/design-doc`, che le struttura confrontandole su criteri espliciti. Il brainstorming produce IL problema
   chiaro, non la scelta fra soluzioni — quella è lo step successivo, esplicito.
6. **Ferma il brainstorming quando smette di produrre informazione nuova**, non dopo un
   numero fisso di domande: se la seconda domanda rivela già che la richiesta era chiara
   fin dall'inizio, fermati lì — un brainstorming che continua per abitudine è lo stesso
   spreco di un brainstorming saltato (regola "Zero waste").

## 1bis. Il contesto si seleziona prima di chiedere (6° ciclo, set 2, 2026-08-24)

Prima della prima domanda, un giro rapido di contesto con budget (il metodo completo
è la skill `selezione-contesto`): le voci SAL della stesso dominio, i pattern già
pagati, la mappa dei domini (`docs/mappa-dominio-gas-src.md`) se la richiesta tocca
calcoli gestionali. Non per riempire la conversazione di riferimenti — per non
chiedere all'utente ciò che il sistema SA già, e per riconoscere una lezione già
scritta quando la rivede. Se il giro di contesto trova il problema già risolto o
già discusso, dillo alla prima risposta: il brainstorming più breve è quello che
un altro documento ha già fatto.

## 2. Cosa NON fare

- Non uscire da questo passo con del codice scritto — è un chiarimento di requisiti, non
  un'implementazione (stessa regola di `/design-doc`: passi separati, espliciti).
- Non inventare il criterio di successo per l'utente ("immagino che tu voglia Z") — se
  manca, è proprio quello che questo comando deve far emergere, chiedendolo.
- Non trasformare una domanda socratica in un modulo a caselle: è una conversazione, non
  un questionario — la domanda successiva dipende dalla risposta precedente, non da una
  lista precompilata.

## 3. Dopo il brainstorming

Il problema chiaro (criterio di successo + vincoli reali) passa a `/design-doc` se
esistono più strade plausibili, o direttamente a `/nuova-commessa` se la strada è unica e
il territorio è piccolo e noto. Il brainstorming stesso non produce un documento
permanente — è `/design-doc` (o la sezione `## Design` della commessa) a farlo, citando
cosa è emerso qui in una frase, non riportando la conversazione intera.


## 4. La fase GENERATIVA — le dieci provocazioni (potenziata 2026-08-29)

La parte socratica raffina una richiesta che c'è già. Ma quando l'obiettivo è
GENERARE — nuove idee, suggestioni, «come lo potrebbe fare meglio» su un
progetto studiato — servono provocazioni, non domande. Dieci, in tre famiglie;
si usano DOPO un'analisi polilivello (skill `polilivello`): le provocazioni
senza comprensione sono modelli, non idee.

**Sul COSA (il progetto stesso):**
- **P1 Il test del vuoto**: cosa sparirebbe domani senza che nessuno se ne
  accorgesse? (ciò che nessuno noterebbe è il primo candidato all'archivio —
  e il secondo è il sospetto che nessuno lo usi davvero)
- **P2 La next-question**: se il progetto sparisse stasera, cosa ricreeremmo
  uguale e cosa faremmo diverso? La seconda lista è la roadmap.
- **P3 Il vicino**: un altro progetto del parco ha già risolto la stessa
  cosa? (la mappa di dominio esiste per questo: prima di inventare, conta)

**Sul COME (il funzionamento):**
- **P4 La scala**: ×10 dati, ×10 utenti, 1/10 della frequenza — cosa si
  rompe per primo? Il primo a rompersi è il collo di bottiglia vero.
- **P5 Il ribaltamento**: se l'output fosse l'input? se il batch fosse
  interattivo, e l'interattivo batch? se il controllo venisse PRIMA invece
  che dopo?
- **P6 Il costo zero**: quale miglioramento non tocca produzione? (un
  oracolo, un banco, un report in più: i miglioramenti sicuri si fanno prima)

**Sul CHI (le persone intorno):**
- **P7 La domanda di dominio**: cosa sa il proprietario che il codice non sa?
  (scadenze contrattuali, convenzioni, eccezioni vissute — regola già del
  metodo, qui diventa generativa: ogni risposta è un oracolo da minare)
- **P8 L'ostacolo**: quale parte l'utente evita? quale foglio nessuno apre?
  Ciò che si evita è dove sta il valore non consegnato.
- **P9 Il debito visibile**: TODO, «si potrebbe», «andrebbe» nei commenti —
  il codice ha già confessato i suoi desideri: raccogli la lista.
- **P10 La fusione**: due progetti che fanno metà della stessa cosa? (nel
  parco è successo: due rating clienti nati separati, una cessione factoring
  fatta tre volte) — la fusione è l'idea più grande e la più politica.

Regola di raccolta: ogni idea che nasce dalle provocazioni finisce in una
LISTA numerata con la provocazione che l'ha generata (P4: ...) — poi si
attraversa la lista con i criteri del dominio (valore, costo, rischio), non
con l'entusiasmo. Il passaggio a commessa/design-doc resta lo stesso del §3.

### Quando l'utente dice «decidi tu su tutto» (dal campo Golilla, 2026-09-01)

La delega esplicita della decisione NON è un permesso di indovinare. Il triage per ogni
questione delegata: (a) **implementa** se è difesa-in-profondità, reversibile, e non richiede
dati inventati (es. aggiungere un gate senza cambiare il comportamento per l'utente legittimo);
(b) **dichiara bloccato-sui-dati** se serve un valore reale che non hai (es. un codice BC):
decidi la POLICY, dichiara il blocco sul DATO; (c) **rifiuta esplicitamente** se richiederebbe
indovinare una formula di business o una soglia finanziaria — citando «oracolo prima della
formula» come ragione, non come timidezza. Ogni decisione presa si dichiara nel report con
il criterio usato.

## Vedi anche

skill `design-doc` (il passo dopo) · skill `polilivello` (lo studio che dà alle
provocazioni il terreno vero: Cosa fa? Come lo fa? Come lo potrebbe fare meglio?)
