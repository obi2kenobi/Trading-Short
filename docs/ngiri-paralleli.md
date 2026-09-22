# N giri paralleli — il workflow dichiarativo (dal campo REPO-I, 2026-08-27)

Struttura fissa, contenuto per progetto:

1. DIVIDI il progetto in AREE (REPO-I: 15) — nessuna esclusa, o dichiara l esclusione.
2. Per ogni area, LANCIA due letture indipendenti: una a caccia di difetti silenziosi
   (le lenti di patterns/), una a caccia di possibilita non sviluppate (dev-critic:
   chi porta solo difetti ha fatto un terzo). REPO-I: 30 agenti, batch da 10 per limiti
   di concorrenza.
3. SINTESI a posteriori, senza coordinamento in partenza: un tema che ricorre in >=3
   aree INDIPENDENTI e un TEMA TRASVERSALE (REPO-I: 8) — la convergenza indipendente
   e il segnale di qualita che un giro singolo non da.
4. L esito del giro si dichiara (zero bug su superficie ampia = convergenza, in metodo.md).

Ancora: docs/campo/2026-08-27-controlli-trimestrali.md (19/19 findings ALTA
riproducibili con test PRIMA/DOPO, zero regressioni, zero correzioni respinte).

## Il giro di PRODOTTO (dal campo, 2026-08-27: 72 agenti, 57 proposte confermate)

Distinto dal giro di bug: cerca cosa MANCA, non cosa è rotto. Struttura:
1. **Mappa dei percorsi utente reali** (chi usa cosa, in che ordine, con quali dipendenze) — prima delle lenti.
2. **Lenti di prodotto** (10+): ciclo di vita, leggibilità ("si spiega da solo?"), automazione del manuale residuo, osservabilità, produttività, resilienza sul campo, KPI calcolabili-ma-non-mostrati, configurabilità self-service, messaggi parlanti, usabilità nel contesto REALE (mobile/touch in magazzino).
3. **Verifica di fondatezza per ogni proposta**: un secondo agente apre il codice e verifica che il dato/meccanismo citato esista — la proposta generica si scarta. Ogni proposta cita file:riga, per chi, costo stimato.
4. **Critica di completezza**: cosa nessuna lente ha toccato (nel caso: governo dell'accesso nel tempo) + i PREREQUISITI NASCOSTI (una proposta che è prerequisito di altre due si fa per prima: risolve per costruzione, non con tre patch).
5. **Le 3 a miglior rapporto valore/costo per l'uso di oggi** — non un backlog: la scelta resta al proprietario.
Filtro d'ingresso che ha funzionato: vietare le "feature da manuale SaaS" senza riscontro concreto nel codice.

## La consolidazione delle lenti È zero-waste (dal campo REPO-G, 2026-08-27)

Cinquanta giri richiesti, consolidati in 14 lenti realmente distinte: evitare
passate quasi-duplicate è la stessa disciplina zero-waste del metodo applicata
al processo di revisione stesso. Il criterio: due lenti che rileggono gli
stessi file con la stessa domanda sono UNA lente; due che li leggono con
domande diverse (bug vs prodotto vs prevenzione) restano due. E ogni proposta
ancorata a file:riga letto davvero — mai principio da manuale.


## Le cinque lenti per area del giro di prodotto (dal campo REPO-I, 2026-08-27)

Ogni area del progetto si legge con le stesse cinque domande — strutturate
così che nessuna fugga:

1. **Buco nel processo**: quale test di revisione/controllo un professionista
   farebbe SEMPRE e che qui non esiste? (cut-off, subsequent events, completezza)
2. **Parlantezza**: cosa nel report parlerebbe a chi non ha scritto il codice?
   (codici grezzi, sigle non sciolte, soglie senza criterio, segni senza spiegazione)
3. **Fatica residua dopo il verde**: cosa deve ancora fare l'umano che il sistema
   potrebbe fare da solo? (copia-incolla, click ripetuti, uscite dal prodotto)
4. **Continuità e sostituibilità**: se chi mantiene il sistema domani cambia,
   cosa si perde? (decisioni nella memoria di sessione, mappature senza casa,
   soglie senza motivazione, contratti d'interfaccia non documentati)
5. **Coerenza fra aree gemelle**: Clienti/Fornitori, Ferie/TFR, Banche/Cespiti —
   cosa uno dei due ha che l'altro non ha, senza una ragione scritta?

I TEMI TRASVERSALI (≥3 aree indipendenti che li trovano da sole) sono il segnale
più forte: emersi senza coordinamento, sono la prova che non sono opinioni.
Il campo REPO-I ne ha trovati 12 — in testa: «segnalato una volta, mai richiuso»
(il follow-up che non persiste), «funzioni scritte senza porta d'ingresso»,
«il verde che nasconde un dato mai arrivato».


## Le due batterie di lenti (dal campo REPO-I Fase 3, 2026-08-28)

Le 4 lenti storiche (scarto-mai-silenzioso ecc.) sono tarate su CORRETTEZZA:
un verde plausibile e sbagliato. Le 5 lenti del giro di prodotto sono tarate su
PROCESSO e MANUTENIBILITA: un modulo che funziona ma e incoerente col gemello,
una funzione senza porta d'ingresso, un follow-up che non persiste. Non sono
sostituibili: sono ORTOGONALI. Il metodo riconosce due batterie con obiettivi
dichiarati diversi — usare quelle giuste per il tipo di problema cercato.

## La tassonomia a quattro categorie (provata su 245 casi senza eccezioni)

Ogni idea del catalogo finisce in UNA di queste (mai una quinta necessaria):
1. **Implementata** — fatta, collaudata
2. **Esclusa** — serve una decisione di dominio o un dato non disponibile
3. **Rinviata** — sproporzionata, o bloccata da un vincolo tecnico/organizzativo
4. **Gia coperta** — verificata come non-gap: un altro modulo o tooltip la risolveva

## La regola delle tre ricomparse (dal campo, stessa fonte)

Quando la stessa lacuna infrastrutturale interrompe o restringe il lavoro per
la TERZA volta in progetti diversi, non e piu «rinviata»: e MATURA PER
L'INVESTIMENTO — il costo di continuarci intorno ha superato il costo di colmarla.


## La consolidazione delle lenti e zero-waste (dal campo REPO-G, 2026-08-27)

Cinquanta giri richiesti, consolidati in 14 lenti realmente distinte: evitare
passate quasi-duplicate e la stessa disciplina zero-waste applicata al processo
di revisione stesso. Due lenti che leggono gli stessi file con la stessa domanda
sono UNA lente; due che li leggono con domande diverse restano due.


## La doppia fase e le smentite dichiarate (dal campo REPO-J, 2026-08-28)

50 agenti in DUE FASI: 35 di scoperta + 15 di verifica avversariale.
Il budget permette di verificare solo i primi 15 per severità: 13 CONFERMATI,
2 SMENTITI. Le smentite sono la prova che la verifica non e cosmetica:
l'agente che cerca di confutare a volte CI RIESCE — e il rilievo iniziale
muore li, dichiarato. (Totale: 153 rilievi grezzi → 59 bug/sicurezza →
15 verificati → 13 confermati + 2 smentiti + 44 NON VERIFICATI dichiarati.)

## La lente sviluppo-business trova bug, non feature (stesso campo)

Le 3 analisi dedicate a nuove idee hanno convergentemente prodotto BUG e
debito tecnico invece di funzionalita speculative — coerente con la regola:
un'idea speculativa senza un caso reale resta non-ancora-matura. Quando la
lente business trova solo difetti, e il segnale che il codice non e pronto
per crescere: prima si ripara, poi si costruisce.


## La sessione continua come pattern ricorrente (dal campo REPO-K, 2026-08-28)

SECONDA volta (REPO-F, poi REPO-K) che la stessa tensione si presenta con lo
stesso esito: l'utente chiede esplicitamente di non fermarsi, e l'istruzione
esplicita vince sulla cautela di default. Ormai non e una domanda aperta isolata
ma un PATTERN RICORRENTE: dichiararlo nel canone come terzo regime legittimo
(oltre passo-per-passo e batch-autorizzato): la sessione continua su richiesta
esplicita dell'utente, col vincolo che il ripasso finale resta obbligatorio.


## La consolidazione delle lenti e zero-waste (dal campo REPO-G, 2026-08-27)

Cinquanta giri richiesti, consolidati in 14 lenti realmente distinte: evitare
passate quasi-duplicate e la stessa disciplina zero-waste applicata al processo
di revisione stesso. Due lenti che leggono gli stessi file con la stessa domanda
sono UNA lente; due che li leggono con domande diverse restano due.

(Persa la TERZA volta e ritrovata il 2026-09-19: la guardia che la presidiava
era zittita dal teatro del verdetto — il cancello non era l'ultima riga.)
