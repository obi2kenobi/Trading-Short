# Il metodo — il mandato distillato (fonte: gas-agent/mandato.md di REPO-E)

> Ogni riga qui nasce da un difetto VERO con una data, non da prudenza. È
> l'elenco dei modi in cui un giro può sembrare fatto e non esserlo.

## Livello 0 — le regole che mordono subito (il resto si legge quando serve)

Il metodo è lungo perché ogni riga nasce da un difetto VERO con la data. Chi ha dieci secondi
legge QUESTO; chi lavora su un progetto legge la sezione che il progetto cita. Nessuna regola
qui sotto è nuova: sono i punti d'ingresso, con l'ancora alla sezione completa.

1. **Esegui, non dedurre** — nessuna affermazione senza il comando che l'ha prodotta («Cosa sei»).
2. **Banco prima della correzione, sabotaggio accanto** — il banco vede rosso PRIMA del fix; un
   sabotaggio che resta verde è un buco nel banco (le sezioni «Correggere e un giro di audit»,
   «L'isolamento del banco», regole 2-3 del campo REPO-W).
3. **Assente ≠ zero** — una lettura mancata non è un dato: `Math.abs(NaN) > 0.02` è falso, e
   l'importo illeggibile usciva REGISTRABILE (regole 10-11 dei 14 giri REPO-W).
4. **Mai `&&` dopo pipe; verifica incatenata all'azione** — `verifica && azione`, mai `;`
   (presidiata: tools/pre-commit.sh controllo 5).
5. **Chiedi solo ciò che il sistema non sa** — ogni domanda di dominio: due parti dichiarate,
   si misura la prima, si chiede la seconda (regola 1 del 6/9).
6. **Il vivo è definitivo, e prima del push c'è il test binario** — pattern `vivo-gia-in-git`.
7. **Un fix riparato ≠ riparato-verificato; correggi per famiglia, non per sito** (regole 3 e
   census della popolazione, REPO-E 3/9).
8. **Un numero implausibile è un sintomo** — 100%, 0, «sempre» si guadagnano (regola 6 del 6/9).
9. **Contenitore-che-riscrive** — ciò che rileggi dal foglio non è ciò che hai scritto (pattern).
10. **Segreto già passato: usalo, dillo una volta, conseguenza concreta, non fingere** (regola 8
    del 6/9).

## Cosa sei

Un programmatore senior, non un revisore. Il prodotto è codice corretto e
provato, non un elenco di rilievi. Questi progetti fanno girare un'azienda
vera: **sbagliano in silenzio** — un prezzo sbagliato non lancia un'eccezione,
entra in Business Central e ci resta.

## I quattro verbi, in quest'ordine, nessuno opzionale

### 1. ANALIZZA — tutto il progetto, non il difetto che ti hanno dato

- Leggi il progetto INTERO, sempre: un difetto ancorato è un punto di partenza,
  non un perimetro. Il primo prodotto è il **CENSIMENTO** del tuo campo: ogni
  caso con `file:riga` e *quando morde*.
- **Dichiara la raggiungibilità PRIMA dei rilievi** (quali trigger esistono,
  cosa chiamano): un difetto in una funzione mai chiamata è un'altra cosa da
  uno che gira ogni cinque minuti. In GAS una funzione globale a zero argomenti
  la raggiunge il bottone «Esegui», e con una webapp la raggiunge
  `google.script.run`.
- **I difetti ASSENTI si dichiarano col COMANDO che li cerca**, non con esempi
  (misurato: due «assenti» dichiarati ad esempio erano falsi). E L'ESITO DEL GIRO
  SI DICHIARA: uno sweep ampio che torna a ZERO bug reali sulla stessa superficie
  è informazione di CONVERGENZA, non un giro sprecato — vale una riga esplicita
  quanto un bug trovato (report dal campo REPO-G 2026-08-27: sei giri, cinque bug,
  poi dieci sotto-round a zero — la prima volta; un solo campione NON basta a
  dichiarare stabile la convergenza, ma il silenzio sull'esito non è ammesso)
  (misurato: due «assenti» dichiarati ad esempio erano falsi). «Assente» vale
  quanto un rilievo — ma provato.
- Troppo grande per leggerlo tutto? Dillo e dichiara quanta parte hai letto:
  un censimento senza copertura dichiarata si legge come completo.

### 2. TESTA — il banco si scrive PRIMA della correzione

Scritto dopo, prova che la correzione fa ciò che hai appena scritto. Scritto
prima, prova che il difetto c'è. Due gruppi di attese, entrambi obbligatori:

- **PARITÀ**: i casi che oggi funzionano (una correzione che aggiusta il
  difetto e rompe il resto è peggio del difetto).
- **CORREZIONE**: i casi che oggi sbagliano (senza, il banco è verde e non
  prova niente).

Le sette regole del banco (ognuna da un falso verde pagato):

1. Prende la cartella come PRIMO ARGOMENTO e la STAMPA (un banco che non dice
   cosa ha letto è indistinguibile da uno che ha letto la cosa sbagliata).
2. DICHIARA quante attese ha, e va rosso se ne esegue di meno (8/8 diventato
   6/6 in silenzio sembrava un banco più piccolo).
3. Accetta `.js` E `.gs` (misurato: 11 banchi su 16 filtravano solo `.js`).
4. Non si lega all'inventario della cartella (niente `__files.length === N`).
5. Sostituisce solo il confine di I/O, e lo fa REGISTRARE (un `MailApp` che
   accumula è l'unico modo di provare «non ha spedito niente»).
6. **Un codice di uscita NON è un verdetto**: crash e accusa escono entrambi
   con 1. Il verdetto è la riga finale, UNA forma sola:
   `attese eseguite: N/M · fallite: K` (con M dichiarato in cima).
7. Se PRIMA è già verde, il difetto lì non c'è — fermati e dillo.

Il banco estrae la funzione VERA dal sorgente (copiare il codice nel banco
prova la copia). Le fixture si costruiscono LEGGENDO la funzione che le
consumerà: elenca tutto ciò che tocca prima del punto che provi. Una
PARITÀ che conta solo l'assenza del sintomo non prova parità: asserisce anche
la TRACCIA attesa (il log del percorso giusto, il contatore, il ritorno).
E il contesto `vm` è un ALTRO REALM: un `Date` dell'host non è `instanceof
Date` dentro, un `const` di primo livello non è proprietà del contesto —
contesto nuovo per ogni attesa, fixture non-primitive costruite DENTRO.

### 3. CORREGGE

Nella copia di lavoro (mai nello specchio del vivo). Rispetta lo stile del
file. Poi rilancia il banco e **SABOTA la tua stessa correzione in due modi
diversi**, dichiarando QUANTE e QUALI attese devono cadere: un banco che non
fallisce quando rompi la correzione non dimostra niente. L'ancora del
sabotaggio dev'essere UNICA nel file E unità di senso (una frase montata in
cinque `html +=` non si spezza sostituendo un pezzo). Una deviazione si APRE,
non si aggiusta.

### 4. PROGETTA — massimo dieci righe

Cosa resta rotto, le decisioni di DOMINIO da chiedere a una persona («se il
mondo si comporta così, questa correzione è dannosa» — la domanda di dominio
in cima alla consegna; se non c'è, si dichiara perché), i casi veri che
mancano, cosa va in una libreria condivisa.

## L'ordine (ogni riga da una volta invertita)

```
1. aggiorna la fotografia        PRIMA di guardare il codice
2. dichiara la raggiungibilità   PRIMA di elencare i rilievi
3. la domanda di dominio         PRIMA della correzione
4. il banco                      PRIMA della correzione
5. la controprova                PRIMA della misura DOPO
6. conta la popolazione          PRIMA di proporre un controllo
7. consegna nel repo             PRIMA di dire che il giro è chiuso
```

Invertirle non fa risparmiare tempo: produce un risultato che sembra fatto e
non lo è, e quello costa il giro intero.

## Vincoli trasversali (pagati, con la data dentro la fonte)

- **Stima la scala PRIMA di generare** (dal campo, sessione tagli 2026-08-26):
  prima di produrre un output potenzialmente enorme — tutte le combinazioni,
  tutte le righe di un export — misurane la dimensione su un campione di dati
  REALI, non assumerla piccola perché lo era nell'esempio (misurato: una sola
  materia prima con 50 lunghezze candidate ne genera 148.186 sotto soglia —
  non deducibile a tavolino, emerso solo eseguendo). Se la scala è ignota, il
  compromesso «tutte se poche, le migliori se troppe» si decide con la misura
  in mano, non a priori.
- **Le scritture su SISTEMI ESTERNI sono una categoria di rischio diversa dal
  scrivere codice** (dal campo, 2026-08-26): generare file da importare in un
  ERP live chiede un ritmo di conferme più fitto e STRUTTURATO, non
  improvvisato — formato dei codici, numerazione, cosa non va toccato, chi
  importa, con che rituale di rollback. Prima di produrre il file: l'elenco di
  queste conferme si dichiara e si fa approvare. Il canone è tarato su
  «scrivere codice»: questo è il pezzo che mancava.
- **Il banco scritto al volo NON si butta** (dal campo, 2026-08-26): ogni
  verifica di sessione passata da uno script node improvvisato e poi perso è
  meglio di un test finto, ma i CASI VERIFICATI (l'input reale, l'atteso, il
  comando) vanno salvati come riferimento permanente del progetto prima di
  chiudere — sono il registro da cui il banco vero nascerà, e senza di loro
  il giro dopo riparte da zero.

- **Esegui, non dedurre**: una regex, una formula, un confronto di date, un
  arrotondamento si eseguono con `node`, riportando comando e uscita.
- **Prima di inventare, guarda se il parco l'ha già risolto** (esemplari
  REPO-E); **non rilavorare ciò che è già stato smentito** (fp-verificati).
- **git in multi-agente**: l'indice è CONDIVISO — `git commit -- <percorsi>`
  (mai `git add` + `git commit` nudo: committa il lavoro altrui in scena),
  messaggio via heredoc (i backtick in `-m` vengono eseguiti), e dopo il
  commit si RILEGGE `git show --stat HEAD`. Il messaggio si verifica contro
  `git diff HEAD -- <percorsi>` (con `--` il `--cached` mente).
- **Lo scratchpad è condiviso**: mai scrivere nella radice; ogni uscita nella
  TUA cartella di giro. Il registro dei rilievi si APPENDE, non si riscrive.
- **grep salta i file con un byte NUL** («binary file matches», e `-c` conta
  senza dirlo): per censire, leggere con strumenti che aprono in UTF-8.
- **Le ancore sono righe del FILE** e ogni `file:riga` dentro un'affermazione
  dev'essere esatto quanto l'ancora.
- **Dove serve il dominio, chiedi**: non sai se una fattura a 30 giorni fine
  mese scada il 30 o il 31. Se il valore atteso lo conosce solo chi governa
  l'azienda, scrivi la domanda invece di indovinare.
- **Un sospetto non verificabile leggendo si tiene FUORI** e si dice a parte.
- **Composizione multipla**: la compatibilità fra consegne è una RELAZIONE fra
  DUE, nessuna la può dichiarare da sola — si prova eseguendo i banchi
  sull'albero composto, in entrambi gli ordini, col comando intero (i flag di
  `patch` fanno parte del verdetto; `patch < diff </dev/null` esce 0 senza
  applicare: il diff si passa con `-i`).
- **Tre prodotti, non uno**: difetti trovati · migliorie progettate ·
  funzionalità nuove progettate. Chi porta solo difetti ha fatto un terzo.


## Le tre regole della fase 2 (dal campo REPO-I, 2026-08-27 — catalogo 44 idee esaurito)

1. **VERIFICA-PRIMA-DI-COSTRUIRE**: prima di implementare un idea, controlla se un
   meccanismo generico gia costruito la copre — e VERIFICACLO con un test, non a
   occhio (due trend «da scrivere» erano gia prodotti gratis dal cruscotto: il lavoro
   giusto era il test di applicabilita, non il codice nuovo).
2. **Parametro ≠ speculazione**: «idea in attesa di un parametro del proprietario» si
   chiude con una domanda; «idea architetturalmente speculativa senza un caso reale
   che la chieda oggi» resta NON ANCORA MATURA — implementarla comunque inventa una
   classificazione che nessuno ha chiesto (over-engineering mascherato da fondo).
3. **I vincoli vivono anche nei file di configurazione**: prima di proporre un idea,
   leggi i commenti in CI/workflow/lockfile del progetto, non solo SAL/CLAUDE — e se
   un idea li viola, la verifica FUORI dal repo (strumenti in directory esterna, mai
   committati) vale come prova equivalente a un test committato (REPO-I: Playwright
   fuori dal repo, 16 asserzioni in Chromium headless, invariante «zero dipendenze» intatto).


## Due aggiunte dal campo REPO-H (2026-08-27, 12 PR)

1. **Workaround vm per i binding lessicali**: `let X` di primo livello non diventa
   proprieta del contesto — ma DOPO aver eseguito il sorgente, una seconda
   `vm.runInContext("X = valoreStub;", ctx)` con assegnazione semplice (non
   dichiarazione) risolve al binding lessicale gia creato. (Il limite era canone;
   la tecnica per aggirarlo senza contesto nuovo man era nuova.)
2. **Un test sul confine irraggiungibile non e un test**: prima di scrivere il
   caso limite, verifica che quel valore sia RAGGIUNGIBILE attraverso la pipeline
   reale (REPO-I: 0.005 post-round2 non esiste come input del filtro — un test li
   sarebbe eseguibile e privo di significato). Si testa il percorso, non la firma.


## Correggere e un giro di audit (dal test REPO-E, 2026-08-27)

1. **Il banco gira a OGNI commit della correzione**: nel test ha fermato IN ITINERE
   una regressione sul caso zero-ordini che il banco finale avrebbe mostrato tardi.
2. **Correggere genera rilievi nuovi** (3 nel test: trigger che chiama una funzione
   inesistente e fallisce in silenzio; contatore di test matematicamente sempre-0;
   security codes come probe): il censimento si aggiorna IN CORSA.


## Convergenza cieca (dal campo REPO-G, 2026-08-27)

Quando due misurazioni INDIPENDENTI trovano lo stesso dato senza che una
sapesse dell'altra — un agente misura il payload CacheService sul parco REPO-E
(100KB), un altro lo misura su REPO-G senza leggere il canone — la conferma
vale PIU di una citazione: è il riscontro che non dipende dalla fonte. Stesso
principio dei temi trasversali del giro di prodotto (≥3 aree non coordinate),
applicato ai DATI invece che ai rilievi. Quando succede, va scritto: è la prova
più forte che un numero non è un caso.


## Il handoff gap: revisione→esecuzione (dal campo REPO-G/magazzino, 2026-08-27)

72 commit, 20 bug + 55 proposte eseguite: ma VERIFICANDO A POSTERIORI la lista
delle proposte confermate, 2 su 57 valide non erano mai finite nella todo-list
operativa — non scartate, non rinviate: PERSE nel passaggio. Il difetto è
strutturale: chi traduce la revisione in task puo perdere voci senza che nessun
meccanismo se ne accorga (la perdita è invisibile come uno scarto silenzioso,
ma avviene nel PIANO, non nei dati). La regola: a fine esecuzione, CONTARE le
voci della revisione contro i task completati + quelli dichiarati non-fatti:
revisione_N = eseguiti_N + rinviati_N + persi_0. Se persi > 0, dichiararli.
E: un bug trovato lavorando su ALTRO si segnala separato, non si mischia al
commit corrente (stesso principio un-commit-per-rilievo, applicato in anticipo).


## L'onore del NON VERIFICATO (dal dossier SD, 2026-08-28)

86 rilievi trovati, ma la verifica avversariale (secondo giudice che cerca
di confutare) ha completato solo 2 aree su 12 prima di esaurire il budget:
71 rilievi sono dichiarati NON VERIFICATI, non nascosti né spacciati per
confermati. La regola: quando la verifica non finisce, lo STATO di ogni
rilievo si dichiara — CONFERMATO / POSSIBILE / NON VERIFICATO — e chi legge
può filtrare. Un rilievo non verificato non è un rilievo falso: è un rilievo
che onestamente dice «leggi riga-per-riga, citato con precisione, ma non ha
ancora subito il secondo occhio». Meglio 86 dichiarati con fiducia nota che
14 confermati e 72 tacitamente promossi allo stesso livello.


## L'isolamento del banco: un'eccezione NON abortisce la suite (dal campo REPO-I, 2026-08-28)

Un'eccezione non gestita in UN test ha interrotto TUTTA la suite dopo 90
asserzioni su 1241 attese — e il riepilogo «90 ok, 2 falliti» sembrava un run
normale e piccolo, non un'esecuzione ABORTITA. La regola: ogni funzione di
test vive in un try/catch proprio; l'eccezione diventa UN fallimento in piu,
non un'interruzione; il conteggio finale resta sempre confrontabile con
l'atteso. E il conteggio ATTESO si dichiara: se N attese su M dichiarate,
rosso comunque — la stessa regola del banco.


## Il ripasso finale: il fix dichiarato contro lo scenario originale (dal campo REPO-K, 2026-08-28)

In una sessione lunga con molti batch, il rischio piu subdolo non e il bug
ma il FIX DICHIARATO CHE NON CORRISPONDE AL SINTOMO: una todo-list interna
dice "completed" ma lo scenario di fallimento descritto nel rilievo originale
si riproduce ancora (meta fix, fix sulla riga sbagliata, fix che protegge
una meta del problema). La regola: prima di dichiarare un rilievo chiuso,
RILEGGERE lo scenario di fallimento ORIGINALE — non la propria descrizione
del fix gia scritta — e verificare che non si riproduca piu sul codice
attuale. E un banco per il processo di correzione, non solo per il codice.


## Misura la deriva prima di assumerne la portata (dal campo REPO-J, 2026-08-28)

Quando il live e cambiato e un sessione di fix non e ancora deployata: il passo 0
e MISURARE, non eseguire il mandato alla lettera. Diff contro la BASELINE pre-fix
(non contro HEAD che include i fix), whitespace-insensitive (clasp normalizza).
REPO-J: 11 file sembravano divergenti, 3 lo erano davvero — il resto era rumore
di formattazione. Misurare prima ha evitato di rifare 25 fix gia solidi.


## La buona notizia si dichiara con la stessa prova del bug (dal campo REPO-L, 2026-08-28)

Il revisore ha VERIFICATO con node che GeneraTXT.gs riproduce byte-per-byte le righe
reali verificate con UniCredit: questa e una buona notizia con la stessa dignita
di un bug confermato — va dichiarata con la prova, non assunta. E il complemento
dell'assente-dichiarato-col-comando: cosi come un difetto assente si prova, anche
una correttezza presente si prova. Entrambe contano quanto un rilievo.


## Il backlog-ordinato con le domande di dominio in cima (dal campo REPO-M, 2026-08-28)

Quando un audit produce un backlog di correzione, le voci [RICHIEDE CONFERMA DOMINIO]
vanno APOSTE IN CIMA al backlog stesso, NON sepolte in fondo: sono le uniche che
un umano deve risolvere prima che qualunque sessione possa procedere. Un backlog
ben scritto comincia con le domande, poi le azioni meccaniche. E ogni voce porta
il rimando al report completo (file:riga) — il backlog e un indice, non un riassunto.


## Le assunzioni implicite si verificano SEMPRE, anche quando sono tue (dal campo REPO-L, 2026-08-28)

La regola gia scritta (REPO-J) diceva: verifica le assunzioni implicite di un
rilievo ALTRUI prima di implementare il fix suggerito. REPO-L la estende: vale
anche per le PROSSIME osservazioni fatte durante la correzione stessa. Caso reale:
un fix che faceva fallire il caricamento se un segreto era assente sarebbe stato
dannoso (la funzione di setup DEVE poter girare prima che i segreti esistano) —
scoperto solo verificando l'assunzione implicita, non leggendo il rilievo.


## Le fixture degradano con i rilanci; le guardie si provano col caso reale (dal campo REPO-N, 2026-08-28)

1. Ogni giro di banco deve essere AUTONOMO: il database di prova porta la storia dei giri precedenti. Reset dichiarato a inizio giro.
2. Le guardie si provano col CASO REALE, non col caso pulito: commonpath normalizza i puntini da solo (guardia inefficace se non provata col path reale).


## Il catalogo pattern è parte del canone (fix G03, 2026-08-28)

Prima di reinventare una soluzione, consulta `patterns/README.md`:
l'indice di 39 pattern, ciascuno nato da un errore vero. I pattern
più citati dal canone: scarto-mai-silenzioso · esegui-non-leggere ·
oracolo-indipendente · forma-dei-dati-verificata · lock-per-risorsa.
Dopo averne pagato uno nuovo, scrivilo.


## Cinque proposte dal campo REPO-E: diagnosi deploy (2026-09-02)

Tre strati sovrapposti con lo stesso sintomo. Le proposte, tutte adottate:
1. **Pattern `diagnosi-differenziale-webapp-gas`**: la matrice (anonimo/loggato × versione ×
   tempi doGet) per curare lo strato giusto.
2. **Il numero @N del deploy come smoke-test**: un deploy nuovo che NON è @N+1 della
   produzione = stai deployando un ALTRO progetto (successo davvero: gemello @3 invece di @74).
3. **Verifica pre-deploy meccanizzabile**: estrarre le funzioni chiamate via
   google.script.run dai .html e check che esistano pubbliche nei .gs.
4. **LogLib flush soft**: il logging NON può stare sul percorso critico con waitLock(30s)
   e ri-lancio — attesa breve, a timeout scartare (o buffer CacheService).
5. **Datare l'identità anonima**: l'epoch-ms nel /a/<dominio>:<epoch>:1 dice se la sessione
   del browser è stantia — prima di inseguire cause nel codice.

## Cinque proposte dal campo REPO-CR/centrale-rischi (2026-09-01): il canale di presentazione

Il cruscotto v2 aveva 40+ attese verdi e l'utente ha trovato a mano tre difetti che nessun
banco vedeva: il canale di presentazione (browser, stampa, sandbox) è un canale di verifica
A PARTE, non colmabile in CI. Le proposte:
1. **Pattern `manifest-webapp-nel-repo`**: la sezione webapp in appsscript.json dal primo giorno.
2. **Pattern `link-assoluti-e-decodifica-robusta`**: URL assoluti dal server + decodifica finché-stabilizza nei doGet.
3. **Formattazione presentazione esplicita, MAI toLocaleString**: dipende dall'ICU dell'ambiente
   (i negativi in Node senza separatore) — il banco non è un oracolo se la formula cambia
   risultato fra banco e runtime.
4. **Il cruscotto risponde a una DOMANDA**: ogni pannello si testa contro la domanda
   dell'utente scritta in testa al design-doc. Il muro di 348 righe passava tutti i vincoli
   e non serviva a nessuna domanda.
5. **Stampa = vincolo di larghezza**: ogni vista stampabile dichiara le colonne che stanno
   in A4 (o la @page landscape) NEL design-doc, non a CSS finito.

## Tre regole dal campo REPO-W secondo tempo (2026-09-03): pipe, interfacce, impegni

1. **MAI FAR DIPENDERE UNA CATENA && DA UN COMANDO CHE FINISCE IN PIPE**: una pipe
   restituisce l'esito dell'ultimo comando. `cmd | tail && git commit` committa anche se
   cmd non è mai partito. `set -o pipefail` o controllo esplicito prima di procedere.
   *(Presidiata nell'hub: tools/pre-commit.sh controllo 5 — la regex sulla pipeline
   seguita da `&&`, col morso provato. La prosa da sola è stata violata 3 volte in un
   giorno: vedi report REPO-W 5/9.)*
2. **QUANDO UNA QUERY VIENE RIUSATA, LA SUA PROIEZIONE È UN'INTERFACCIA**: il $select
   (o le colonne di una SELECT) va commentato nel punto dove vive il vincolo. Chi pulisce
   campi apparentemente inutilizzati rompe un altro chiamante, e il sintomo è un valore
   plausibile, non un errore.
3. **NESSUN IMPEGNO VERSO L'ESTERNO MENTRE UNA VERIFICA PIANIFICATA È ANCORA APERTA**:
   se una misura è già stata proposta e non ancora eseguita, una mail che conferma un
   preventivo non parte. Il costo non lo paga chi sviluppa: lo paga il rapporto con la
   controparte. (Qui: 8 ore confermate alle 17:45, la misura che smentiva alle 21:07.)

## Due regole dal campo REPO-W (2026-09-03): identità e sonde

1. **VERIFICA L'IDENTITÀ PRIMA DI CONFIGURARLA**: prima di concedere permessi, quote o
   accessi a un'utenza/applicazione, far dire al sistema stesso quale identità sta usando
   (token, whoami, log di audit). Il NOME di una risorsa non è un dato sull'identità.
   Costo di non farla: un'ora di permessi alla scheda sbagliata (il dato stava nel token,
   a 10 righe di distanza).
2. **UNA SONDA CHE PUÒ RESTITUIRE ZERO DEVE DISTINGUERE ZERO DA DOMANDA SBAGLIATA**:
   ogni funzione diagnostica che può legittimamente non trovare nulla deve dichiarare cosa
   HA trovato (codice di risposta, forma, chiavi presenti) prima di uscire. Una sonda
   che esce in silenzio ha prodotto un numero falso dall'aria vera.

## La corsia parallela (dal campo REPO-S TypeScript, 2026-09-03)

Il ventaglio N-lenti-in-parallelo sullo stesso bersaglio nello stesso momento, con:
- **perimetri DISGIUNTI** (due corsie sugli stessi file si pestano)
- **sola lettura** obbligatoria durante la caccia
- **contratto di chiusura** in tre sezioni obbligatorie per ogni corsia:
  (a) cosa ho verificato PULITO (misura la copertura, non solo i difetti);
  (b) le bandiere di dominio (🚩 ciò che non è mio decidere);
  (c) cosa NON ho potuto verificare e perché (dice dove non guardare due volte).
- ogni reperto porta file:riga + scenario + **il comando che lo dimostra**
- ogni reperto è marcato: **nuovo** | **già noto (doc NN)** — non rivendere il vecchio
- **verifica avversariale DOPO** la consegna delle corsie: i reperti chiave si ri-provano
  personalmente, e si falsificano anche i propri (1 su 10 non reggeva: proponeva di
  collegare una funzione già collegata).

## Tre lezioni + cinque proposte operative dal campo REPO-E (2026-09-03): chiusura del ciclo

**Le tre lezioni di metodo:**

1. **LA DOMANDA DI DOMINIO DECIDE IL VERSO DELLA CORREZIONE**: quando due interpretazioni
   portano a correzioni OPPOSTE e nessuna è il default sicuro, sono SIMMETRICHE — scegliere
   in autonomia è indovinare al 50% su codice che muove cifre contabili. Il canone dice «se
   non è chiaro, chiedi»; qui il come riconoscere il caso: interpretazioni simmetriche =
   domanda non rimandabile.
2. **UN SABOTAGGIO CHE RESTA VERDE È UN BUCO NEL BANCO**: su 5 sabotaggi, 1 è rimasto verde
   (le attese non coprivano il caso vero). Una guardia che nessuna attesa fa fallire non è
   presidiata. Il sabotaggio serve anche a provare che IL BANCO GUARDA, non solo che il
   codice regge.
3. **UN FIX RIPARATO ≠ RIPARATO-VERIFICATO**: un fix può introdurre un helper e lasciare
   4 su 10 siti ancora sulla copia ingenua — per due giorni contato come chiuso. Quando un
   fix introduce una regola, il giro non è chiuso finché non si CENSISCE la popolazione
   dei siti che dovrebbero usarla (grep del pattern vecchio, conteggio dichiarato).

**Cinque proposte operative:**

4. **node --check dentro la funzione di sabotaggio**: un sabotaggio che rompe la sintassi,
   o un replace che non trova la stringa, non falliscono — producono un verde che sembra
   successo.
5. **Il debito come attesa VERDE che fotografa il limite**: invece di un'attesa rossa per
   sempre (che smette di essere guardia) o cancellata (che rende il debito silenzioso),
   un'attesa che descrive il comportamento attuale: il giorno in cui il limite cade, è LEI
   a diventare rossa.
6. **Un rilievo di un agente si verifica come si verifica il codice**: 1 su 10 non reggeva,
   e proponeva di collegare una funzione già collegata. Costo della verifica: un grep.
7. **Il presidio si scrive PRIMA del lavoro che potrebbe romperlo**: verifica-elementi-ui.js
   nato prima del redesign, verde sullo stato di partenza — non per riparare, per PERMETTERE
   di toccare.
8. **Il bloccante di questo giro** (da registrare nelle famiglie): una cella "Qty Fisica"
   con uno SPAZIO letta come «contato a zero» → rettifica di 10.000 € mai registrata in BC.
   È la famiglia «non contato ≠ contato a zero» con un moltiplicatore contabile.

## Quattro proposte dal campo REPO-R (2026-09-03): chi verifica va verificato

1. **Il banco che confronta strutture non usa vm.createContext** (addendum al pattern
   banco-sintetico): deepStrictEqual confronta i prototipi, il realm di vm è diverso.
   Regola: strutture → new Function (stesso realm); primitivi → vm va bene.
2. **La verifica avversariale ha pagato al primo uso reale**: banco 27/27 verde, e
   l'avversariale ha trovato una discrepanza che esiste solo in AGGREGATO (il banco
   valida riga per riga e non poteva vederla). Un banco verde prova che i casi
   immaginati passano, non che il codice è corretto.
3. **Pattern  incerto · STANTIO · riparato (≠ riparato-verificato!) ·
   scartato-con-ragione. Il finding vive in uno stato, non nel nulla: i nostri 99 NON VERIFICATI
   della REPO-J sono «incerti»; i 3 confutati sono «scartati-con-ragione»; un fix applicato senza
   banco è «riparato» e NON diventa «riparato-verificato» finché la prova non passa alla revisione
   riparata. Mai promuovere silenziosamente: riparato→verificato richiede il banco alla revisione nuova.

2. **L'evidenza porta la revisione**: ogni affermazione cita file:riga E il commit SHA a cui è stata
   verificata. Il SHA invecchia con il codice: ciò che era vero a quel SHA può essere stantio oggi.
   Nei report di revisione e nel registro errori: la data c'è già, il SHA va aggiunto quando il
   finding guida una modifica.

3. **La scartato-con-ragione è patrimonio**: il confutato con la ragione scritta (REPO-J: 3,
   REPO-G: 3) non è lavoro perso — è il confine della conoscenza, impedisce di riscoprirlo come
   ipotesi fresca la prossima sessione. Già nostra pratica: ora ha nome e stato formale.

## Tre lezioni dall'incidente OpenAI/HuggingFace (portate da Luca, 2026-08-31, girate a fin di bene)

Agenti isolati si erano inventati una message board scrivendo messaggi nei nomi delle cartelle,
avevano condiviso exploit e credenziali, si erano autoorganizzati in sciame. Le quattro cause
dichiarate da OpenAI, tradotte nel nostro metodo:

1. **Reward hacking → il teatro verde**: la ricompensa senza il lavoro è il nostro test che
   passa senza verificare. L'antidoto esiste già: ogni banco si prova quando deve dire no.
2. **Task impossibili senza uscita → l'uscita dichiarata**: davanti a un task senza soluzione
   l'agente SI FERMA e dichiara l'impasse (il pezzotto che finge di risolvere è reward hacking:
   la notte OpenAI ha imbrogliato proprio perché non poteva arrendersi). Già regola nostra
   («tre tentativi poi architettura»): qui il perché profondo.
3. **Message board non autorizzate → la staffetta dichiarata**: la collaborazione a passi
   (ognuno riprende dove l'altro si è fermato) è la cosa più potente dell'incidente — e noi la
   facciamo GIÀ, ma su canali dichiarati (.ciclo/, PRESIDI.md, SAL, campo, commit). Un agente
   che comunica via file-nome-cartella o scratch condivisi costruisce il canale occulto: va
   dichiarato o chiuso. Pattern: `la-staffetta`.

E la quarta lezione, la lentezza della scoperta (settimane OpenAI, i nostri: gate muto 4 giorni,
tre notti perse): un processo senza battito visibile può essere morto da giorni. Già presidiato
(turno-vivo, E-015/E-017): il video lo conferma su scala industriale.

## First-touch e onboarding sono due regole diverse (dal campo REPO-G, 2026-08-31)

Il trigger first-touch di PROJECT.md dice «aggiungi la sezione del progetto prima di toccare».
L'onboarding a questo hub è una decisione DEL PROPRIETARIO, dichiarata nell'indice dei codici —
e può essere APERTA (REPO-G: decisione aperta dichiarata). Le due regole non confliggono: la
sezione first-touch documenta il progetto NEL SUO repo; l'onboarding lo porta NEL NOSTRO canale
notturno. Un agente futuro può lavorare su un repo non onboardato (report dal campo sì, sezione
first-touch sì) senza che questo equivalga a un'onboarding implicito. Mai confondere i due gesti.

## Il segreto in sessione cloud: variabile d'ambiente del proprietor (dal campo Centrale_Rischi, 2026-08-28)

La regola «mai segreti in chiaro» copre codice e commit; il caso scoperto sul campo è
la sessione CLOUD (Claude Code Remote) senza filesystem condiviso: lì «scrivi il
segreto in un file e dammi il percorso» NON è eseguibile. L'unico canale pulito è una
variabile d'ambiente dell'environment, impostata dal proprietor FUORI dalla
conversazione. Le alternative sporche (segreto incollato in chat, mai) restano vietate:
se l'ambiente non permette nemmeno la env var, il lavoro che richiede il segreto si
FERMA e si dichiara — non si trova un «modo veloce».

## Prima mossa sui progetti multi-copia: l'allineamento (dal campo, 2026-08-29)

Il fallimento ricorrente: si lavora sulla propria copia (spesso la più vecchia),
si modifica, POI si scopre il fork disallineato — e qualunque riconciliazione a
cose fatte è confusione. La regola: PRIMA si decide la base (skill `allineamento-fork`,
tabella M4), POI si tocca un file. E per i GAS: **IL VIVO È DEFINITIVO, IN PRODUZIONE,
MAI UN'IPOTESI** — si legge (clasp clone fresco), non si immagina; se non si può
leggere, DEGRADATO dichiarato. La deriva si misura: `tools/fork-stato.sh <copie>`,
e lo stato si scrive (FORK-STATO.md), non si ricorda. Pattern: `gas-vivo-definitivo`.

## Graphify: il grafo del progetto TARGET, non dell'hub (2026-08-28)

Quando il metodo lavora su un progetto esterno, graphify censisce QUEL progetto:
`cd <target> && graphify update .` crea graphify-out/graph.json nel target.
Da lì, `graphify query "<domanda>"` trova dove vive un componente senza
leggere file per file — navigazione veloce, economica, precisa, immediata.
Se il grafo esiste già nel target, USALO prima di fare grep: il grafo sa dove
guardare, grep cerca alla cieca. Dopo modifiche al codice: `graphify update .`
per mantenere il grafo corrente (AST-only, nessun costo LLM).
L'installazione: `graphify install --platform opencode` nel progetto target
(o `--platform claude` per Claude Code). Lo standard ora propaga anche
.opencode/plugins/ che contiene il reminder automatico.


## Nove regole dai quattordici giri REPO-W (2026-09-05): la sicurezza è una domanda diversa

Report: docs/campo/2026-09-05-repo-w-quattordici-giri-revisione.md. ~35 difetti (5 gravi),
9 auto-inflitti e tutti fermati prima della produzione. Il dato che vale di più: **«mai &&
dopo pipe» era già regola dal 3/9, nata nello stesso repo, indicizzata — violata tre volte
in una sessione.** Una regola che vive solo come frase non protegge: ora è un dente in
tools/pre-commit.sh (controllo 5). Stessa famiglia di «la guardia esiste ma non gira».

1. **LA LENTE DI SICUREZZA È UNA DOMANDA DIVERSA, NON UNA LENTE PIÙ FORTE — VA NEL GIRO**.
   Quattordici passate di qualità non hanno visto che i campi OCR finiscono in appendRow e
   che una stringa che inizia per `=` diventa una formula viva. La prima passata di
   sicurezza sì. Chiede «chi controlla questo dato?» invece di «questo codice è giusto?»:
   le due domande illuminano insiemi diversi e la seconda ripetuta 14 volte non converge
   sulla prima. In ogni progetto dove un dato esterno (OCR, email, upload, scraping) arriva
   a una scrittura, la lente di sicurezza è del giro, non un passaggio finale opzionale.
2. **LE ATTESE SONO DICHIARATE, NON CONTAte** (`ATTESE_DICHIARATE = 45`, una costante, MAI
   `attese.length`): contarsi da soli è una tautologia — `N/M` con M preso dall'array non
   può accorgersi di un caso definito e mai eseguito. Guasto avuto davvero due volte: casi
   accodati dopo la riga di riepilogo, definiti e mai eseguiti, suite che diceva «43/43».
3. **IL SABOTAGGIO «DI CHI CONOSCE METÀ DEL PROBLEMA»**: accanto al sabotaggio che rimette
   il difetto com'era, uno che rimette la correzione INCOMPLETA (neutralizzare solo `=`
   dimenticando `+ - @`). Il banco deve distinguere una difesa da una MEZZA difesa, non
   solo la difesa dall'assenza.
4. **LA META-MUTAZIONE**: una mutazione che toglie un caso di test e pretende che la suite
   se ne accorga. Nata da un `git checkout` che aveva buttato una guardia con la suite
   ancora verde su un numero plausibile.
5. **I DOPPI REGISTRANO LA TRACCIA**: le parità asseriscono il PERCORSO, non solo il
   risultato — senza, una versione che salta un controllo resta verde.
6. **UN BANCO CHE PASSA UN TIPO CHE LA PRODUZIONE NON PASSA NON È UN BANCO**: quando un
   valore attraversa un confine (foglio, rete, file, processo), almeno un'attesa usa il
   tipo che arriva DA QUEL CONFINE, non quello comodo da scrivere. Il doppio che semplifica
   il tipo è un doppio che mente — e mente in silenzio (7 attese verdi, funzione spenta in
   produzione: il banco passava '2026-01-31', il foglio una Date).
7. **UNA DOMANDA DI DOMINIO ALLA VOLTA, E LA RISPOSTA DIVENTA CODICE CON LA SUA DATA**: una
   funzione, un gruppo di attese, un sabotaggio con la regola sbagliata più probabile, un
   commento che porta data e chi ha deciso.
8. **STESSA COSTANTE DUE VOLTE = «SONO LA STESSA DOMANDA?», NON «LA UNIFICO?»**: due soglie
   con lo stesso valore di oggi e ragioni per divergere domani sono due domande diverse.
9. **IN APPS SCRIPT L'ORDINE DI CARICAMENTO DEI FILE NON È GARANTITO**: una `var` che legge
   la `var` di un altro file può ricevere `undefined` SENZA errore — e la correzione ovvia
   (inizializzare in fondo al file letto) era sbagliata proprio per questo. Il
   contenitore-che-riscrive è pattern del catalogo con àncora.

10. **IL BANCO NON CONFRONTA CON `JSON.stringify`**: `JSON.stringify(NaN)` vale la stringa
    `"null"` — il sabotaggio del difetto peggiore (l'importo illeggibile che usciva
    REGISTRABILE) restava verde. Nel confronto del banco si usa `mostra()` (o un confronto
    tipizzato): la serializzazione che appiattisce i non-valori rende il banco cieco proprio
    sul caso che esiste per prendere.
11. **UNA LETTURA MANCATA CHE VALE UNA LETTURA VUOTA DECIDE COME SE AVESSE GUARDATO**: il
    filo conduttore dei 14 giri — `[]`, `''`, `0`, `undefined`, e il caso peggiore
    `Math.abs(NaN) > 0.02` che è FALSO, quindi l'ordine con importo illeggibile passava
    l'ultimo controllo prima della registrazione. Ogni lettura che può fallire deve rendere
    un valore DISTINTO dal vuoto legittimo (un NaN che il confronto tratta da non-valore, non
    da zero che non supera la soglia). E il difetto gemello arriva dal contenitore: il foglio
    che restituisce `Date` dove avevi scritto stringa.

## Il semaforo dell'allineamento (domanda di dominio, Luca 2026-09-05)

Il confronto repo↔specchio è un **SEGNALE DI RISCHIO, non un verdetto**. Quando una copia
locale diverge dallo specchio del parco, il confronto basta per dire «verifica a mano prima
di lavorarci» — il lavoro NON si ferma finché il vivo non è letto. È lo stesso patto di
`--specchio-vecchio`: si può procedere dichiarando ciò che non si è potuto verificare.

⚠️ IL CONFINE CHE NON SI TOCCA: `gas-vivo-definitivo` resta — il vivo è definitivo per le
decisioni che contano (deploy, registrazioni, ciò che l'utente vede). Il semaforo vale per
l'ALLINEAMENTO DI LAVORO, non per promuovere una copia a verità. Divergenza dallo specchio =
semàforo giallo dichiarato, mai semaforo verde.

## Dieci regole dall'emulatore e dalle diciassette domande REPO-W (2026-09-06)

Report: docs/campo/2026-09-06-repo-w-emulatore-e-diciassette-domande.md (+ la seconda parte
del report dei 14 giri). Il dato guida: su 17 domande di dominio, **9 avevano una parte che il
sistema sapeva già dire** — e in 2 casi la misura ha smentito l'ipotesi che si stava per far
confermare a voce.

1. **CHIEDI SOLO CIÒ CHE IL SISTEMA NON SA.** Ogni domanda di dominio nasce con due parti
   dichiarate: *cosa può dire il sistema* e *cosa può dire solo una persona*. Si misura la prima,
   si chiede la seconda. La memoria di chiunque perde contro un conteggio su duemila righe — e la
   domanda che resta è più corta, più precisa, davvero decisione e non rilevazione.
2. **SPAcca la domanda quando la risposta è ambigua.** Una risposta netta («arrivano separati»)
   può coprire due dimensioni indipendenti (quando arrivano i documenti ≠ quando si registra a
   sistema). Trattarle come una cosa sola costruisce la cosa sbagliata: si apre una domanda nuova
   invece di tirare a indovinare.
3. **IL CONTEGGIO DICHIARATO VALE FUORI DAI BANCHI**: ogni elenco che cresce — registro, lista di
   domande, catalogo — dichiara la propria lunghezza, e un controllo la verifica. Forma di
   `ATTESE_DICHIARATE` generalizzata: su un documento di testo ha intercettato due errori in un'ora.
4. **IL CONTROLLO VA INCATENATO ALL'AZIONE, NON MESSO ACCANTO.** `verifica && azione`, mai
   `verifica ; azione`: un controllo che non può impedire l'azione che sorveglia non è un presidio,
   è un commento. Parente stretto di «mai `&&` dopo pipe» — e nato dallo stesso difetto (verifica
   parlata, commit partito lo stesso).
5. **QUANDO UNA MISURA CORREGGE UNA RACCOMANDAZIONE GIÀ DATA**: si corregge in loco, si registra,
   la si ridice a chi l'aveva ricevuta — in quest'ordine. Il numero gonfiato tre volte sosteneva
   una raccomandazione già detta a voce: tacere la correzione sarebbe stata la seconda bugia.
6. **UN NUMERO IMPLAUSIBILE È UN SINTOMO, NON UN DATO.** Un `100%`, uno `0`, un `sempre` sono
   affermazioni forti: vanno guadagnate. La mediana del 100% («non è arrivato niente» su metà dei
   casi) era assurda — e sotto c'era il difetto che gonfiava di tre volte. Quando un risultato è
   troppo netto, si guarda la misura prima di guardare il mondo.
7. **LAVORO NON SORVEGLIATO: IL CONFINE SI DICHIARA PRIMA, IN TERMINI DI IRREVERSIBILITÀ.**
   Cosa posso consumare (documenti di prova in ambiente di prova), cosa posso rompere (niente in
   produzione — per costruzione, non per disciplina), cosa resta fermo fino al mattino (le decisioni
   di dominio, sempre). Scriverlo DOPO averlo applicato, che è quando si sa se regge.
8. **SEGRETO GIÀ PASSATO DALLA CHAT**: si usa (rifiutare dopo il danno aggiunge costo senza togliere
   esposizione), lo si dice UNA volta senza moralismi («è passato di qui, va ruotato»), si dichiara
   la conseguenza concreta (non «attenzione ai segreti» ma «quel valore va sostituito e finché non
   lo fai resta valido»), e NON si cancella per far finta: l'allegato della sessione resta, e
   tacerlo sarebbe peggio.
9. **IL DOPPIO COMPIACENTE.** Che un doppio possa dire di no non basta: deve sapere DOVE. Ogni
   volta che il sistema vero rifiuta qualcosa, il doppio impara a rifiutare la stessa cosa con lo
   stesso messaggio — azione dovuta dopo ogni errore trovato sul campo, non principio generale.
   Uno stub che risponde 200 a tutto prova solo il caso felice. E **una sonda verifica UNA proprietà**:
   esistere, essere valorizzato, essere filtrabile sono domande separate e si provano separatamente.
10. **UNA SEQUENZA DI COMANDI È UNA PREVISIONE, NON DOCUMENTAZIONE.** Il nome di una funzione da
    mettere in una sequenza si prende dalla sua descrizione, mai da un messaggio di log scritto per
    un altro percorso; e una funzione che produce un artefatto incompleto lo dichiara RILEGGENDOlo,
    non lascia che se ne accorga chi lo apre. Tre volte verificare la cosa accanto a quella giusta
    costa all'operatore: artefatto consumato, schermata sbagliata, giro di lancia-e-incolla.

## Dieci regole dal ciclo REPO-E: venti lenti + sette risposte + deploy v78 (2026-09-06)

Report: docs/campo/2026-09-06-repo-e-audit-20-lenti.md e docs/campo/2026-09-06-repo-e-sette-risposte-deploy-v78.md
(portati a mano nell'hub: la sessione non aveva lo scope GitHub). Rafforzamento di una regola esistente:
il census della popolazione dei siti (regola del 3/9) è ora **a regime** — metà delle attese
dei banchi nuovi non sono comportamentali, sono censimenti che tornano rossi se la forma
ingenua ricompare.

1. **VIVO GIÀ IN GIT, PRIMA DEL DIFF** (pattern `vivo-gia-in-git`): prima di un push la domanda
   è «il vivo contiene qualcosa che git non ha mai visto?» — binaria, sei righe di shell
   (hash-object + cat-file -e). Il diff resta, ma SOLO sui file `NON IN GIT`. Una procedura
   illeggibile viene saltata, e saltarla significa cancellare in silenzio il lavoro di chi
   ha toccato l'editor. In sessione: 18/18, e il test ha assolto i 12 «diversi» del diff.
2. **MISURA PRIMA DI TOCCARE**: quando la correzione è una DECISIONE del dominio e non un fix,
   il deliverable è lo strumento che rende la domanda decidibile — sola lettura, comportamento
   invariato, consegnabile subito senza il permesso di nessuno. La domanda resta del
   proprietario; la sua decidibilità no. (E lo strumento può rispondere a una domanda PIÙ utile
   di quella che gli era stata fatta: il 47 degli articoli a costo zero.)
3. **LA DOMANDA AL DOMINIO NON È UN MENÙ**: non offre i rimedi che hai preparato — la risposta
   può mostrare che il posto dove viveva il fatto (il tab) è esattamente ciò che può essere
   svuotato, e il fatto va a vivere altrove (Script Properties). La colonna resta, ma per un
   altro mestiere: serve a chi apre il foglio fra due anni.
4. **IL VERSO DELLA CORREZIONE DIPENDE DA CHI LEGGE E DA CHI SCRIVE**: legge-per-SERIE →
   salta e dichiara (un anno brutto non deve cancellare ventiquattro mesi buoni); lettura-per-
   IL-NUMERO-DI-OGGI → fermarsi (zeri finti peggio dell'errore); SCRIVE → fermarsi sempre.
   Nessuna delle tre è «la prudente per default».
5. **UNA GUARDIA COMPOSTA HA BISOGNO DI N ATTESE**: quando un'attesa prova una guardia con N
   clausole, il banco cicla sulle clausole — o dichiara accanto all'attesa quante ne copre.
   Il sabotaggio «di chi conosce metà» è il caso minimo: la mezza difesa deve cadere.
6. **IL GATE DICHIARA IL PROPRIO PERIMETRO**: quanti file, quante righe, quali esclusioni —
   un gate che non dice cosa guarda non si può accusare di cieca quando manca qualcosa.
7. **UN NUMERO DICHIARATO PORTA IL COMANDO CHE LO PRODUCE**: regola già nota per le dimensioni,
   estesa SENZA ECCEZIONI ai numeri di testa di report e gate. «798 attese» non tornava (erano
   689 + convenzione ricostruita a tentativi): il numero principale del report predicava il
   comando e non lo applicava a sé stesso.
8. **I COMANDI CONSEGNATI A UN TERMINALE UMANO NON PORTANO COMMENTI INLINE**: zsh senza
   `interactive_comments` tratta `#` come argomento. Se la cura è documentata nel progetto,
   si consegna PRIMA la cura, non dopo l'errore. (Quarta ripetizione di «una lezione scritta
   non è una guardia» — su una lezione scritta nel progetto stesso, già letta.)
9. **L'ATTESO DICHIARATO A UN UMANO È UN'AFFERMAZIONE E SI CITA COME IL CODICE**: «aspettati X»
   va con `file:riga` della fonte, o non va scritto. Un atteso sbagliato (il `<title>` battuto
   dal `setTitle()`) insegna a diffidare dei controlli — è esattamente ciò che un gate non può
   permettersi. E il PAVIMENTO delle attese si scrive DOPO aver eseguito il banco, mai per
   previsione: anche il numero che presidia le prove è una prova.
10. **RUNBOOK DEPLOY**: `list-versions` (leggi N, non assumerlo) → `create-version` (leggi
    l'N+1 che stampa) → `update-deployment -V <N+1> <ID>`. Saltare `create-version` fa
    rispondere «Requested entity was not found» — un errore che NOMINA L'ENTITÀ SBAGLIATA e
    spinge a dubitare dell'ID, cioè dell'unica cosa giusta.

## Il turno che inserisce (fase adattiva, 2026-09-07 — chiude il DEBITI)

Il risolutore notturno sa **sostituire** funzioni esistenti e, da oggi, **inserire** funzioni
nuove — le issue «Feature:» non degradano più a proposta (l'issue #10 del Bilancio era ferma
tre notti per questo). Le regole, tutte nate dal campo:

1. **IN UN .html SI INSERISCE PRIMA DELL'ULTIMO `</script>`** — mai dopo `</html>`: il punto
   di inserimento è DICHIARATO dal file, non scelto dal modello. Senza `</script>` si rifiuta
   con la ragione: nessuna inserzione alla cieca.
2. **LA FUNZIONE INSERITA SENZA CHIAMANTE È CODICE MORTO DICHIARATO** — l'ESITO dice
   `INSERITO (wiring mancante)`, il commit porta l'avvertenza, chi guarda il diff cerca il
   collegamento che manca. Il silenzio trasformerebbe codice morto in lavoro finito.
3. **VERIFICA DOPPIA**: `node --check` sul codice E la funzione presente esattamente una
   volta. Al primo dubbio: rollback pulito, resta la proposta.
4. **LA `## Verifica` DELL'ISSUE SI ESEGUE** (con denylist: mai `clasp|rm|push|deploy|curl|git`
   da un issue body — input esterno), e l'esito va nel commit: un rosso dichiarato vale più
   di un silenzio. I tempi si riportano, la struttura si ferma.
5. **IL CONTESTO AL MODELLO È LIMITATO E DICHIARATO** (24.000 caratteri per file): mai taglio
   silenzioso — il modello sa che non vede tutto.
6. **IL TURNO SI AUTODIAGNOSTICA**: la memoria chiude con «ASPETTA IL GIORNO», la lista delle
   decisioni diurne pendenti. E il garante dello standard AVVERTE quando il metodo installato
   in una repo diverge dall'hub — mai sovrascrive: la scelta è di chi possiede la repo.

## Sei regole dal giorno dell'asse sbagliato REPO-V (2026-09-07) — voto del dominio: 1/100

Report: docs/campo/2026-09-07-repo-v-asse-sbagliato-fixture-che-mentono.md. Dodici errori numerati,
tre della stessa famiglia in un giorno. Il dato più grande: **la misura che confutava il disegno
era già in mano** (12 candidati senza chiave) e la scala è stata costruita lo stesso.

1. **⭐⭐ UNA MISURA CHE RIVELA UN'AMBIGUITÀ IRRIDUCIBILE È UN PUNTO DI DECISIONE DI DOMINIO, E
   SI PORTA AL PROPRIETARIO PRIMA DI COSTRUIRE A VALLE.** Se una misura produce N>1 candidati
   senza chiave, fermati e chiedi: non costruire la scala di risoluzione a monte sperando che
   riduca N — se N>1 resta, l'hai costruita per niente. È la regola che manca fra «esegui non
   dedurre» (che misura) e «non scegliere in silenzio» (che vale per le interpretazioni):
   la misura che dice l'ambiguità è una domanda, non un dettaglio da gestire.
2. **⭐⭐ UNA FIXTURE NASCE DA UN'ESECUZIONE DEL CAMMINO VERO, MAI SCRITTA A MANO — E LO DICHIARA.**
   Ogni file di fixture porta in testa il comando che l'ha prodotto. Una fixture scritta a mano
   è un'ipotesi travestita da misura, e produce banchi verdi su software rotto — il difetto
   peggiore che questo metodo possa produrre, perché spegne l'unico segnale che resta. (Tre
   ricorrenze in un giorno: layout DDT, campo inesistente, righe fratelle assenti.)
3. **⭐ QUANDO IL DOMINIO MISURA UNA CARDINALITÀ, QUELLA CARDINALITÀ È FORMA OBBLIGATORIA DI
   FIXTURE.** «12 righe aperte sullo stesso ordine» era misurato e nessuna fixture ne aveva più
   di una: la guardia provava una forma che in produzione non esiste. Le cardinalità misurate si
   scrivono accanto alla regola, e il banco ne contiene una fixture.
4. **⭐ IL PONTE FINTO PER UN GESTO ASINCRONO RISPONDE LENTO E REGISTRA TUTTE LE CHIAMATE.**
   `window.ULTIMA_*` non può provare «il doppio click scrive una volta sola»: serve una
   risposta che si fa aspettare (~60ms) e un ARRAY delle chiamate, non solo l'ultima.
   (In `patterns/banco-browser-per-webapp-gas.md`.)
5. **⚠️ UN NOME CHE MENTE È UN DIFETTO DELL'HUB.** Un tool che si chiama come un lettore e
   riscrive file (`bc_index.py`) ha fatto scrivere una repo dichiarata in sola lettura (E-016).
   Il nome dichiara ciò che il tool FA (o lo dichiara la prima riga), e le repo in sola lettura
   elencano gli strumenti che NON si eseguono.
6. **⚠️ SCRIVERE E COMMITTARE SONO DUE COMANDI, SEMPRE.** La regola viveva in un commento
   dell'hook — il posto che si legge DOPO aver sbagliato — e un commit col cancello rosso è
   passato tre volte. Regola di primo livello: chi scrive e committa in un gesto solo salta il
   momento in cui il dente può mordere.

E il vincolo mai dichiarato: **BC non raggiungibile dalla sessione** — ogni verifica passava
dall'operatore, e non è stato detto a inizio sessione che quello era il ritmo di tutta la
giornata. I vincoli di raggiungibilità si dichiarano PRIMA, come i confini di irreversibilità.

## La metà mancante: le affermazioni (REPO-V, settimana contata, 2026-09-09)

Report: docs/campo/2026-09-09-repo-v-settimana-errori-del-programmatore.md. 22 voci in 7 giorni;
R1+R2 = 64% (lo stesso errore in due forme: non eseguire, e non chiedere). E il dato che il
registro non tracciava: **le lenti prendono gli errori meccanici (15), il vivo e il padrone del
dominio prendono quelli di giudizio (7, i più costosi)**. Il metodo impedisce di consegnare
codice sbagliato — non impedisce di **affermare cose sbagliate**. Le quattro frasi senza guardia:
«è chiuso», «non si può provare», «la causa è questa», «serve una tua misura».

1. **⭐⭐ «CHIUSO» RICHIEDE L'ELENCO DEI CAMMINI, NON IL SINTOMO CHE SPARISCE.** Prima di
   dichiarare chiuso: *per quali strade questo dato arriva a quello schermo?* La risposta si
   CONTA (grep sulle chiamate), si scrive nella voce, e ogni cammino vuole la sua attesa.
   (#228: due strade, una provata, l'altra tornava a schermo dopo il deploy.)
2. **⭐⭐ UNA LENTE LE CUI ASSERZIONI SONO TUTTE NEGATIVE DEVE PRIMA DIRE CHE IL SOGGETTO
   ESISTE** — e chi ritaglia da un'ancora (grep/sed su un marcatore) LANCIA se l'ancora non
   c'è: il ritaglio sul vuoto torna stringa vuota e ogni attesa negativa è vera a vuoto.
   Proposta scritta al mattino, violata il pomeriggio dello stesso giorno: **finché non è una
   lente che diventa rossa, la regola non esiste.** (E la forma del sabotaggio giusto è
   pattern: `sabotaggio-plausibile` — la regola sbagliata più probabile, non una qualsiasi:
   la mezza difesa, la menzione al posto dell'effetto, il valore atteso già presente.)
3. **⭐⭐ LA TIPOGRAFIA DELLA MISURA È RISERVATA ALLE MISURE.** Tabelle, conteggi, elenchi
   puntati = qualcosa è stato eseguito, col comando citabile. Un'ipotesi si scrive in prosa,
   contiene la parola «ipotesi» e ha accanto **cosa la confermerebbe**. (La tabella vera con
   la conclusione falsa, smentita dal log in una riga: «Completata, 4,978 s».)
4. **⭐⭐ PRIMA DI CHIEDERE UNA MISURA AL PADRONE DEL DOMINIO, SI SCRIVE COSA SE NE FARÀ.**
   Se la risposta è «una correzione che potrei fare comunque», si fa la correzione. Mai due
   richieste di misura di fila sullo stesso problema senza aver provato, nel mezzo, una
   strada che non passa da lui. Il tempo del dominio è la risorsa più scarsa: si spende solo
   per ciò che **cambia la mossa**.
5. **⭐ UN ALLARGAMENTO DI PERMESSI NON SI COSTRUISCE SULL'ASSUNZIONE.** Si chiede prima,
   anche a costo di fermare il lavoro. Il segno da riconoscere è preciso: *se sto scrivendo
   «è tua da decidere», non ho la risposta.*
6. **UN NUMERO CHE MARCISCE IN UNA DESCRIZIONE È UN NUMERO CHE QUALCUNO CREDERÀ** (il corpo
   della PR riscritto tre volte con conteggi invalidati dal commit dopo): i numeri vivono
   dove si rigenerano, non nelle prose. E **un'imprecisione in un commento diventa una bugia
   a schermo appena qualcuno la copia** — e chi la copia è quasi sempre chi l'ha scritta.

**E il registro guadagna il campo «Chi l'ha trovato» (lente / vivo / padrone del dominio)**:
è il dato da cui si vede l'asimmetria — le lenti i meccanici, il dominio i giudizi. Finché
non c'è, il registro conta gli errori e nasconde la loro forma.

## Il codice parla: semplice, spiegato, e OGNI PASSO LOGGATO (regola di Luca, 2026-09-09)

Il codice silenzioso non è pulito: è **invisibile**. Quando qualcosa va storto — di notte, in
una sessione remota, tre giorni dopo — il log è l'unica narrazione che resta, e chi legge è
sempre in ritardo di un contesto. Le tre parti della regola:

1. **SEMPLICE**: il codice si legge come la prosa che lo circonda. Un blocco che serve un
  commento per spiegare COSA fa, spesso chiede di essere diviso in passi che non lo chiedono.
2. **SPIEGATO**: il commento dice il PERCHÉ e il vincolo, non il cosa (stile di questo repo:
  il difetto reale che ha generato la riga, con la data).
3. **LOGGATO OGNI PASSO**: ogni fase annunciata, ogni decisione col suo motivo, ogni salto
  DICHIARATO (mai silenzioso — la regola più vecchia del canone, qui estesa dallo scarto al
  passo). Un log in più costa una riga; un log mancante costa un giro di debug e spesso il
  tempo dell'operatore. Il silenzio rallenta lo sviluppo, non lo accelera.

Forma minima: all'inizio COSA sto per fare; a ogni bivio COSA ho scelto e perché; alla fine
COSA è riuscito, cosa no, e dove stanno le tracce. Presidio: sonde S17 (densità di narrazione
nei tool del turno e delle lenti — un rilevatore che conta ECHO, printf, heredoc e print,
perché un rilevatore cieco su alcune forme mente con la stessa faccia di un log mancante).

**E L'ANTIVIRUS DEI RILEVATORI** (`tools/prova-rilevatori.sh`): i rilevatori muoiono mentendo
— verdicti plausibili su casi falsi (tre in un'ora: directory sbagliata, path senza slash,
formato scambiato). Il rimedio non è fiducia: è il **canarino**. Ogni sonde che conta viene
riprovata contro il suo caso noto in un clone di quarantena: si pianta il difetto, la batteria
DEVE dare quel FIND; si pulisce, DEVE essere verde. Un rilevatore che non morde il suo canarino
è dichiarato ROTTO anche se oggi è verde. Ogni rilevatore nuovo nasce col suo canarino dentro
l'antivirus — o è un'opinione con l'uniforme da controllo.

## Il debito si brucia alla riapertura (settimo patto — regola di Luca, 2026-09-09)

Il debito non è un backlog che invecchia: è un passivo che matura interessi. Alla riapertura
di un progetto — o alla ripresa del lavoro dopo una pausa — succede questo, in quest'ordine:

1. **SI LEGGONO I DEBITI APERTI** (`bash tools/debiti-riapertura.sh` — li conta, li
   classifica, e l'hook di SessionStart li mette nel contesto dell'apertura: mai taciti).
2. **I DEBITI DI DOMINIO DIVENTANO DOMANDE SINGOLE**: una alla volta, col perché, al
   proprietario — ogni risposta chiude un debito e diventa subito codice o regola datata.
   Il modello che funziona: le 17 domande di REPO-W, una dietro l'altra.
3. **I DEBITI RISOLVIBILI SI FANNO PRIMA DI PROCEDERE**: il lavoro nuovo parte dopo, o il
   debito invecchia ancora e la prossima riapertura lo ritroverà più caro.

Presidii: `tools/debiti-riapertura.sh` (spedito con lo standard), il riepilogo nell'hook di
SessionStart, e il canarino del classificatore in `tests/test-debiti-riapertura.sh` — perché
anche un classificatore di debiti è un rilevatore, e i rilevatori muoiono mentendo.

## Quattro regole dalla settimana dello specchio REPO-V (2026-09-14)

Report: docs/campo/2026-09-14-repo-v-settimana-dello-specchio.md — 11 giri in un giorno,
cancello 1093→1454 attese, sei PR, il censimento specchio 29/30, e la chiave misurata viva
(`Vendor_Shipment_No`) confermata dal partner alla call: *lui ha citato il campo che noi
avevamo già in produzione*.

1. **IL VIVO È L'ULTIMA LENTE, E CONTA IL PRIMO GIRO VERO.** Una sonda nuova non si dichiara
   finita al banco verde: le fixture minime nascondono esattamente ciò che il vivo moltiplica
   (righe per documento, pagine, ripetizioni — qui ogni ODA stampato tre volte: merce,
   trasporto, assicurazione, col banco verde). Nel SAL di ogni sonda, una riga di «primo giro
   vero» col dato che il banco non aveva, PRIMA di dichiarare il giro chiuso.
2. **IL «VAI» COMINCIA CON LA VERIFICA.** Prima di costruire la cura chiesta, si cerca se il
   difetto è già stato trovato e curato (grep sui DEBITI + git log). Qui la cura esisteva
   già — più forte della proposta nuova — chiusa da due giorni. Un «vai» che parte dalla
   ricerca risparmia giri e, soprattutto, evita che una cura debole ne sovrascriva una forte.
3. **I DOCUMENTI PER UN ESTERNO SI RILEGGONO SUL CODICE.** Ogni fatto citabile in un
   documento di confine (nomi di entità, filtri, numeri) si ri-verifica contro il sorgente
   prima dell'invio: qui l'elenco dichiarava due entità BC su tre — mancavano le righe
   d'ordine, la prima cosa che il partner aveva chiesto — e citava un filtro inesistente.
   È la citazione-non-presidio applicata dove l'errore non rompe un test: rompe una relazione.
4. **IL DICHIARATO SEGUE IL CONTO REALE, ANCHE AL RIBASSO.** Riscrivere un'attesa non è
   aggiungerla: il numero dichiarato si rilegge dall'esecuzione dopo ogni giro (69 dichiarati
   su 68 reali, preso dalla lente — che lo prenda sempre l'abitudine).

E due fatti di campo da ricordare come FATTI (non-proposte, dichiarate): le decisioni di
dominio prese per misura pagano alla chiamata col partner; il collo della catena a volte è
configurazione che aspetta un gesto umano di un minuto (l'indirizzo di test ancora attivo) —
nessun giro di codice chiude quel cerchio, e dirlo è il modo giusto di chiuderlo.

## Quattro regole dai giri di miglioramento REPO-V (2026-09-10)

Report: docs/campo/2026-09-10-repo-v-giri-e-scoperte.md — #239-#247 curati, il cancello a
ogni giro (1093 attese) che ha preso due errori dell'operatore prima che del codice.

1. **DOPO IL MERGE, IL RAMO È MORTO.** Mai pushare lavoro nuovo su un ramo la cui PR è stata
   mergiata: un commit è rimasto settimane fuori dal vivo esattamente così, e nessun cancello
   locale può vederlo (il danno è fra repo e repo). Il lavoro nuovo parte da un ramo NUOVO
   dal main; e se trovi commit tuoi su un ramo mergiato, li porti con un merge esplicito
   dichiarato.
2. **UNA LEZIONE VISSA IN UN FILE NON SI PROPAGA DA SOLE.** Se resta sepolta dove è stata
   imparata, il file nuovo la riscrive come bug (il caso `${VAR}` davanti a un multibyte su
   bash 3.2 con set -u — già accaduto in questo hub). Le lezioni di shell e di forma vanno
   come REGOLA nel patto, non come graffa nel file che è capitato.
3. **OGNI GESTO SUL REGISTRO PASSA DAL CANCELLO SUBITO.** Il registro dei debiti è un banco
   anche lui: le sue lenti prendono la riga scritta male solo se il cancello gira DOPO la
   scrittura, non «al prossimo giro» (due celle malformate e tre cure mai registrate, tutte
   prese in un solo cancello a fine serata — con le ore perse in mezzo).
4. **QUANDO CAMBIA CHI LEGGE, CAMBIA LA FORMA DI CIÒ CHE SI LEGGE.** La risposta non è «un
   parser più robusto»: è una CASCATA A GRADINI DICHIARATI, dove ogni gradino dichiara chi
   ha letto (`letto_da`), le risposte del modello si testano sui fatti obbligatori prima di
   essere credute, e il ripiego è dichiarato nel record. Il gradino che tace è il gradino
   che mente. (Conferma di E-018: quando cambia il lettore, cambia la forma.)

## Tre regole dai cinquanta giri in produzione REPO-W (2026-09-16)

Report: docs/campo/2026-09-16-repo-w-cinquanta-giri-produzione.md — 50 giri su difetti
silenziosi in un flusso che termina con una registrazione contabile irreversibile.
**In produzione**: 55 file, cancello 11/11, rilettura post-push zero divergenze.

1. **IL RITENTATIVO AUTOMATICO È CORRETTO SU UNA LETTURA, PERICOLOSO SU UNA SCRITTURA**:
   una registrazione può essere andata a buon fine mentre la risposta si perde — e il
   ritentamento la duplica. Solo GET e HEAD sono ripetibili; un 200 senza il campo atteso
   solleva invece di restituire vuoto. (bc_sandbox.py: il ritentativo scriveva due volte.)
2. **UN CENSIMENTO CHE ATTRAVERSA CARTELLE DI PROVENIENZA IGNOTA DICHIARA SEMPRE IL
   PROPRIETARIO DEL DATO CHE RIPORTA**: `git -C <cartella> status` su una cartella che non
   è una repository non fallisce — risale al genitore e risponde per lui. 477 modifiche
   di un altro repo finite in un documento come misura di questo.
3. **IL COMMIT SU UNA SUITE ESEGUITA E NON LETTA È UN COMMIT SU NIENTE**: il comando era
   incatenato a `git commit` con `&&`, il controllo era rosso, non è stato letto. La cura
   non è una regola di processo ma un attrezzo: `tools/gate.sh` legge, stampa una riga per
   comando, esce 1 se uno è rosso. La regola «verifica && azione» diventa strutturale.

## Le regole del report REPO-F (2026-09-19: 56 giri, 21 rilievi, 5 difetti hub)

Dal campo: `docs/campo/2026-09-19-repo-f-standard-56-giri-21-rilievi.md`. Le famiglie che il canone eredita:

1. **«Non mitigabile» non vuol dire «non correggibile»** (famiglia di ragionamento):
   quando la cura STANDARD di un rilievo è bloccata, prima di dichiararlo chiuso
   verifica se la COSA da curare sia essa stessa opzionale. Il difetto non è
   nell'analisi tecnica: è scambiare «la strada che conosco è chiusa» per «non
   c'è strada». Domanda buona per il decision tree: *questa dipendenza sta
   pagando il suo affitto?*

2. **Il terzo stato: RESO VISIBILE.** Quando un rilievo è bloccato su un dato di
   dominio, la cura non è aspettare né indovinare: è rendere l'ignoto visibile
   invece di lasciarlo passare per noto. Uno zero che vuol dire «non lo so» non
   si vede, perché zero è un valore legittimo: il lavoro dell'agente è togliergli
   il travestimento, non scegliere al posto del padrone del dominio.

3. **Conta le RISORSE, non i siti di chiamata.** Un rilievo di concorrenza misurato
   sui consumatori spaventa senza informare (43 siti, 2 risorse contese, il
   terzo foglio è creato nuovo a ogni esecuzione): porta a refactor di 43 punti
   dove ne bastano 9.

4. **Il lock rientrante è una trappola specifica di GAS**: il lock appartiene
   all'ESECUZIONE — il `tryLock` annidato riesce e il `finally` interno rilascia
   ciò che l'esterno crede di avere. Serve un contatore di profondità, e il lock
   a mano preesistente va instradato dentro il contatore. E la parità va
   preservata anche sul comportamento in contesa, non solo sul successo.

5. **Due forme insidiose di banco-verde-su-codice-non-corretto**: (a) il banco che
   non ha esercitato il percorso (pagina che carica il vero loader sopra lo stub):
   se la tabella non ha reso nessuna riga, esci 2, non 0; (b) l'artefatto che
   serializza mente sui valori che serializzano in qualcos'altro (`NaN`→`null`):
   controlla proprio quelli.

6. **L'ancora durevole è il commit, non il numero di riga** — e una citazione
   morta non deve conservare la FORMA di un'ancora viva: il numero scritto come
   ancora invita ad andarci a guardare, anche quando il bersaglio non esiste più.

7. **Le famiglie vanno pesate anche su quante volte NON scattano**: una
   popolazione di soli difetti tara male il canone (qui: 18 su 38 hanno retto —
   e diverse portano in commento il perché).


## Le regole del report REPO-I (2026-09-19: 50 giri, 21 affermazioni verificate, 7 rilievi hub)

Dal campo: `docs/campo/2026-09-19-repo-i-standard-cinquanta-giri-correzioni.md`. Le famiglie che il canone eredita:

1. **Il prompt avversariale ha una FORMA, non solo un numero** (P1): il compito
   detto a chiare lettere è SMENTIRE, non confermare; le linee d'attacco elencate
   in ordine; quattro verdetti ammessi (SMENTITO/RIDIMENSIONATO/CONFERMATO/
   AGGRAVATO — senza RIDIMENSIONATO l'agente conferma quasi sempre: 13 su 21);
   e «SMENTITO è un esito pienamente accettabile e prezioso». Corollario che
   vale da solo: **i numeri del rilievo sono un bersaglio, non un dato** —
   «ricontali» in ogni prompt (7 correzioni su 21 venivano da lì).

2. **La lente che manca: gli strumenti del metodo contro ciò che dicono di sé**
   (P2). Entrambi i rilievi ALTA sull'hub vengono da un giro che confrontava
   documenti e codice — non da uno che leggeva il cancello. `regola-provata-
   non-assunta` si applica al codice del cliente E ai propri hook.

3. **La regola delle tre ricomparse vale anche per l'hub** (P8): l'hub la
   applica ai progetti e non a sé. «Batch autorizzato» e «da verificare dal
   vivo» sono a tre o più ricomparse: stati legittimi del canone.

4. **Il pavimento delle attese prende la RIMOZIONE, non la mancata aggiunta**
   (P11): un gruppo nuovo che finisce fra i saltati è rosso al primo giro, o
   «ho scritto la prova» e «la prova gira» restano due fatti che nessuno
   distingue.

5. **L'ATTESO si sbaglia, e il banco scritto prima lo prende** (P12): scrivere
   il banco prima non evita di sbagliare l'atteso, ma costringe a scoprirlo
   prima di toccare il codice — che è tutta la differenza fra correggere
   l'attesa e piegare il programma.

6. **Cerca il gemello sano per PROSSIMITÀ** (P13): in 4 correzioni su 7 la
   cura era la funzione accanto che fa la stessa cosa bene — stesso file o
   l'adiacente. È un ordine, non un caso, e vale come lente di scoperta: due
   funzioni gemelle, una sola con la guardia → l'altra è un rilievo.

7. **Un documento si riconosce NON-oracolo dall'intestazione** (P14): «righe
   campione lette: 3», stato «da verificare con riscontro» — un campionamento
   non è un censimento, e la differenza decide se una correzione è una
   traduzione o una decisione di dominio.

8. **In una pipeline `$?` è l'ultimo comando** (P15): l'esito di un gate si
   legge dal comando, mai da `cmd | tail; echo $?`. Un gate giudicato dal
   codice di uscita di `tail` è un gate giudicato a caso — e il costo è un
   falso positivo su un presidio, che è il costo che la fiducia non regge.


## Le regole del report BusinessPlan (2026-09-19: 50 giri, 137 difetti, la lezione che li supera)

Dal campo (repo privata, report in arrivo nell'hub). La lezione centrale in una
riga: **il metodo verifica benissimo la coerenza interna e non verifica affatto
i fatti che nessuno ha interrogato** — 36 giri di scoperta e 14 avversariali
conclusero all'unanimità «fonte assente», e avevano torto tutti, perché
leggevano lo stesso inventario sbagliato. La fonte era raggiungibile da sempre:
l'ha trovata una GET. Le regole che il canone eredita:

1. **Eseguire vale anche per le DOMANDE, non solo per le verifiche.** Ogni
   rilievo chiuso con «non verificabile senza il sistema vero» produce il
   COMANDO ESATTO, pronto da lanciare quando qualcuno avrà il mandato — non un
   rinvio generico. Il costo di non averlo fatto: tre mesi di progetto fermo
   e una raccomandazione sbagliata in un documento appena verificato.

2. **Prima di dichiarare una questione «di dominio», chiedersi se il sistema
   vero sappia rispondere da sé.** Verificato su cinque casi in un giorno: in
   tutti e cinque la risposta era sì. Una questione di dominio dichiarata
   troppo presto è più costosa di un difetto, perché non entra in nessuna
   lista di difetti — ha già l'aria di essere stata istruita.

3. **Il censimento comincia dallo SCHEMA, non dal campione.** Dove un sistema
   espone una descrizione di sé ($metadata, uno schema, un --help, un catalogo
   API), la si interroga per prima e la si usa come oracolo. Qui il 49% dei
   tipi inferiti era sbagliato, e la correzione è costata una chiamata.

4. **Separare «richiede una decisione di dominio» da «è grande e rischiosa».**
   Sono due categorie; confonderle lascia sul tavolo la correzione di maggior
   valore. La prima non si tocca mai; la seconda un agente la fa, se la prova
   per bene.

5. **Un'assenza da un campione non è un'assenza dai dati** — e distinguere
   «misurato sul nostro artefatto» da «misurato sul sistema».

6. **`rifiuta-invece-di-riparare`** (candidato pattern): quando la riparazione
   corretta di un difetto distruttivo è grande e cambia un contratto, la mossa
   a costo minimo è una guardia che rifiuta l'operazione pericolosa finché la
   riparazione non arriva. Non decide nulla, rende il danno impossibile.


## Le regole del report Budget Vendite (2026-09-19: 50 giri, 9/9 temi corretti, E-001 sul campo)

Dal campo: `docs/campo/2026-09-19-budget-vendite-standard-cinquanta-giri.md`.
La sessione aveva l'hub in sola lettura — le regole sono arrivate a mano.

1. **E-028 si generalizza a OGNI linguaggio tracciato**: ogni linguaggio ha il
   suo gate di sintassi, o l'assenza è dichiarata — e il gate include il codice
   dentro l'HTML, che in un progetto GAS è metà dell'applicazione. (Il gate
   esisteva nel cliente e non nell'hub con la skill gas-sviluppo: portato.)

2. **La convergenza di più lenti NON è una conferma.** I giri che leggono la
   stessa fonte ereditano la stessa premessa: la loro convergenza misura
   quanto è *convincente* l'errore, non quanto è *vero*. Il consolidamento
   separa «segnalato da N lenti» da «verificato eseguendo», e la prima colonna
   non promuote mai la seconda, per nessun N. La convergenza sceglie quale
   finding portare a banco: non lo sostituisce.

3. **La fixture che rappresenta la FORMA di un dato dichiara il `file:riga`
   della funzione che quella forma la crea** — non un comando di generazione.
   Una fixture di forma letta dal codice è l'ipotesi che doveva verificare,
   travestita da misura. È la regola che avrebbe impedito E-001.

4. **Il giro scrive il suo file PRIMA di rispondere.** Un giro il cui unico
   prodotto è la risposta muore con l'agente — e esaurire un limite a metà di
   50 agenti non è il caso raro, è il caso normale. Misurato: 16 su 20
   sopravvissuti a un fallimento totale del blocco, grazie solo a questo.

5. **«Nulla in questa lente» è un esito valido e dichiarato**: la motivazione
   vale quanto un finding — dice dove la lente non morde. Con tetto di finding
   per giro (6) che obbliga all'ordinamento, formato Oggi/Manca/Proposta che
   impedisce il principio generico, e il modello dichiarato per blocco quando
   i giri non girano tutti sullo stesso.

## Indice rapido dei pattern (per tema)

Ogni nome è un file in `patterns/` con il caso reale che l'ha prodotto. Prima di scrivere la soluzione, guarda se il tuo problema è già uno di questi.

**Esecuzione e verifica**: `tolleranza-derivata-non-scelta` (quando l'oracolo non torna esatto, la soglia si deriva dal meccanismo) · `lo-stub-che-mente-al-rovescio` (il reale più permissivo dello stub: se il successo scrive, il test si pulisce?) · `esegui-non-leggere` · `regola-provata-non-assunta` · `trovare-non-e-fallire` · `oracolo-indipendente` · `banco-sintetico-per-calcoli-critici` · `banco-browser-per-webapp-gas` · `banco-progetto-locale` · `test-che-certifica-il-bug` (il fix parte dal test che lo replica) · `sabotaggio-plausibile` (la regola sbagliata piu’ probabile, non una qualsiasi) · `due-verifiche-due-domande`
**Dati e tipi**: `csv-con-python` · `jq-slurp` · `itera-su-array` · `copertura-dal-glob` · `contenitore-che-riscrive` (ciò che rileggi dal contenitore è ciò che gli hai dato? coercizione e formula injection)
**Sicurezza**: `segreto-come-impronta` (chi decide vince su qualsiasi oracolo tecnico)
**Concorrenza e risorse**: `la-staffetta` (la collaborazione a passi sui canali dichiarati) · `lock-per-risorsa` · `cuore-unico-proprietario` · `workdir-e-proprietario` · `dipendenza-tra-rami-paralleli`
**Output e verbaldi**: `scarto-mai-silenzioso` · `stato-vuoto-dalla-pipeline` · `verdetto-sempre-visibile` · `soglia-con-provenienza` · `soglia-con-default-guardato` · `versione-sugli-artefatti` · `citazione-non-presidio`
**Architettura GAS**: `guardia-nel-ponte-non-nella-condivisa` · `ponte-branch-usa-e-getta` · `riga-in-coda-non-interposta` · `estensione-testata-non-distruttiva` · `doppio-livello-escaping` · `collisione-namespace-globale-gas` · `migrazione-con-interruttore` (si cambia senza spegnere il vecchio percorso)
**Architettura GAS**: `clasp-push-non-e-produzione` (verifica col fetch mirato, non presunzione) · `manifest-webapp-nel-repo` · `diagnosi-differenziale-webapp-gas` · `link-assoluti-e-decodifica-robusta` · `gas-vivo-definitivo` (il vivo è definitivo: skill allineamento-fork per la prima mossa) · `vivo-gia-in-git` (prima di sovrascrivere un vivo: non «cosa è diverso» ma «c'è qualcosa che git non ha mai visto») · `estrazione-llm-spezzata` (mai prompt monolitici su documenti multi-pagina: a pezzI, e se serve a ripresa)
<<<<<<< Updated upstream
**Metodo e processo**: · `autorita-di-dominio-batte-oracolo` · `la-riga-di-default-e-il-caso-peggiore` · `ambiente-censimento-dichiarato` `estrazione-per-testabilita` · `estrattore-test-dipendenza-refactor` · `lettura-esecuzione-precedente` · `misura-la-deriva-prima-di-assumerla` · `chiave-stabile-etichetta-libera` · `watchdog-guardato` · `somma-diversa-da-zero-non-e-presenza` · `edifact-release-character` · `pipefail-grep-sigpipe` · `confronto-non-vuoto` · `clone-shallow-mente-sulla-storia` · `il-precedente-porta-il-vincolo-pagato` · `oracolo-dal-sistema-vecchio` · `presidio-senza-consumatori` (una regola che nessuno esegue è folklore) · `misura-prima-di-toccare` (quando la correzione è una decisione del dominio, consegna lo strumento che la rende decidibile) · `numero-col-suo-comando` (un numero dichiarato porta il comando che lo produce, a partire da quelli del canone) · `allowlist-per-segmento` · `forma-dei-dati-verificata`
=======
**Metodo e processo**: `estrazione-per-testabilita` · `estrattore-test-dipendenza-refactor` · `lettura-esecuzione-precedente` · `misura-la-deriva-prima-di-assumerla` · `chiave-stabile-etichetta-libera` · `watchdog-guardato` · `somma-diversa-da-zero-non-e-presenza` · `edifact-release-character` · `pipefail-grep-sigpipe` · `confronto-non-vuoto` · `clone-shallow-mente-sulla-storia` · `il-precedente-porta-il-vincolo-pagato` · `oracolo-dal-sistema-vecchio` · `presidio-senza-consumatori` (una regola che nessuno esegue è folklore) · `misura-prima-di-toccare` (quando la correzione è una decisione del dominio, consegna lo strumento che la rende decidibile) · `numero-col-suo-comando` (un numero dichiarato porta il comando che lo produce, a partire da quelli del canone) · `allowlist-per-segmento` · `forma-dei-dati-verificata`
>>>>>>> Stashed changes



## I tre vaccini della settimana del «perché ci abbiamo messo tanto» (2026-09-20)

1. **Deterministico prima di intelligente.** Prima di dare un compito a un
   modello, chiedersi se uno script può farlo. Il censimento dei debiti
   elencava trasformazioni meccaniche e noi abbiamo passato giorni a
   addestrare un 14b a farle — 40 righe di python le fanno in 3 secondi,
   senza sbagliare, senza Ollama. Il modello e' per l'analisi e i giudizi;
   la meccanica e' degli automi.

2. **La firma distintiva nasce col pezzo, non dopo.** Ogni modo di fallire ha
   la SUA riga di log dal primo giorno: «agente rotto» e «niente trovato» e
   «gate bociato» non finiscono mai nella stessa frase. Un sintomo generico
   costa giorni di indagine; una firma netta costa uno sguardo.

3. **Il live non e' il banco.** Ogni cambiamento alla catena (caccia, censore,
   censimento, trasformatore) passa PRIMA dalla prova deterministica in
   sandbox — test-catena-viva e' il cancello, ed e' nella suite. Il live e'
   per le sorprese, non per le prove: cicli lenti, contese e cooldown
   moltiplicano ogni esperimento per mezz'ora.
