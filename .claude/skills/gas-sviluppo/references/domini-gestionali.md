# Le domande dei domini gestionali (fonte: gli agenti di dominio di gas-agent, REPO-E)

> I tredici ingegneri dimostrano che il codice contraddice sé stesso; gli
> agenti di DOMINIO leggono il codice per capire se dice il vero **sulla
> contabilità dell'azienda**. Il loro prodotto è spesso una DOMANDA, non un
> rilievo. Prima di usarle: se il calcolo esiste già come oracolo dell'hub
> (`docs/mappa-dominio-gas-src.md`: valorizzazione, margine per documento,
> accuratezza fatture, scostamento, cespiti, aging, indici), si riparte da
> quello — la formula non si reinventa.

## Contabilità — le sei cose da guardare

1. **Il mastrino quadra col saldo?** Cerca le DUE sorgenti di verità e verifica
   se il codice le confronta mai.
2. **Il totale quadra con ciò che il documento STAMPA?** (Se il totale somma
   una colonna e le righe vengono da un altro filtro, «il documento non somma
   ciò che mostra».)
3. **Dare/avere e segno**: i movimenti di produzione da BC arrivano NEGATIVI —
   «un segno invertito non dà errore: dà un costo che sembra un ricavo». Conferma
   di campo (REPO-G, 2026-08-26): un plug IVA a segno invertito è stato trovato
   LEGGENDO il codice ed eseguendo query reali sul vivo, non assumendo — lo
   stesso difetto in una sede nuova: il plug che quadra può quadrate per il
   verso sbagliato.
4. **Le due date**: documento vs registrazione — la conta del 31/01
   registrata il 01/02 finisce nel mese sbagliato.
5. **I ribaltamenti**: la somma dei ribaltati deve fare ESATTAMENTE l'importo
   di partenza («un ribaltamento che perde centesimi li perde ogni mese»).
6. **Le rettifiche**: una rettifica che riapre un periodo comunicato è un
   problema contabile, non tecnico.

Conferma di campo più pesante (REPO-G, giro D49, 2026-08-24): un residuo
silenzioso di 982.693,50 € in un documento di quadratura GIÀ INVIATO ALLE
BANCHE — trovato verificando il totale sul documento reale, non leggendo il
codice. Vincoli: **il TOTALE è l'ultima cosa da asserire** (un doppio conteggio
simmetrico dà totale identico e ogni riga sbagliata); la fixture di quadratura
vuote quote diverse, importi diversi e almeno un SEGNO OPPOSTO o non misura
niente (casi simmetrici: scarto 0; asimmetrico: 32.000 EUR); la risposta di
dominio si CONTA, non si argomenta («sei d'accordo, due no» è un dato — e il
client, ciò che il codice STAMPA per un valore mancante, conta come
definizione d'azienda); prima di correggere una regola contabile che «sembra
sbagliata», prima ipotesi: l'azienda l'ha voluta.

## Controllo di gestione — le sei domande

1. **Standard vs consuntivo**: stesso perimetro E periodo (un consuntivo su 4
   centri contro uno standard su 5 dà uno scostamento che è solo il quinto).
2. **Il denominatore**: un rapporto Std/Act e uno Act/Std con la stessa
   etichetta (e un rapporto si ESEGUE, non si legge: previsto +10,0%,
   eseguito +9,9% — l'arrotondamento avviene prima del rapporto).
3. **Le ore coperte**: un report che dichiara «N ore coperte» con tabella a
   zero righe «si contraddice da solo».
4. **Il perimetro escluso**: «un'esclusione silenziosa è un numero più
   piccolo che sembra un numero migliore».
5. **La granularità**: medie di medie non sono medie.
6. **La chiave di aggregazione unica**: «due strade per lo stesso numero» in
   TRE forme — due funzioni (algebra), due grandezze sulla stessa riga
   (perimetro), la stessa parola in due file (definizione). E la lezione
   rimisurata: in questo parco la duplicazione dell'ALGEBRA è quasi sempre
   innocua — l'ultima da controllare; il difetto sta nel perimetro o
   nell'accordo col produttore.

E: **la configurazione che nessuno consuma è un difetto** («chi CONSUMA questo
valore?», non chi lo legge) — e NON si corregge applicandola (entrerebbe nella
serie storica come finto Effetto Prezzo). Il banco è END-TO-END (si asserisce
sui numeri che una persona legge), mai su funzioni helper.

## Produzione — le sette domande

Il ciclo vero; le chiavi OdP uniche (una collisione di chiavi HA ROTTO la
produzione); ore uomo vs ore macchina; turni e calendario (si lavora il
sabato?); scarti e rilavorazioni; **dichiarazioni tardive** (un report che
chiude alle 6:00 su dati dichiarati alle 9:00 è sistematicamente incompleto);
le unità di misura. E: **i pareggi su data senza ora** decidono `$orderby`
(>` stretto tiene il primo arrivato: l'ultimo costo può vincere il più
VECCHIO, −44% su ogni riga); «quantità prodotta» è un NOME, non una grandezza
(mandonopera su qty reale, materiali su qty prevista: 36% delle righe
divergono); il falso positivo consuma un CAP (un falso allarme è un vero
negativo).

## Sviluppo business — le cinque domande (l'unico agente che NON cerca difetti)

1. **Dato raccolto e mai letto** (fogli append-only, event log: chi li rilegge?).
2. **Decisioni prese a occhio** che un numero già in casa supporterebbe.
3. **Lavoro manuale ricorrente** (`_TEST`, «poi Luca fa»).
4. **Cosa un progetto fa che servirebbe a un altro** (l'OAuth verso BC è
   scritto due volte e già divergente → libreria condivisa).
5. **Rischio coperto solo dall'attenzione di una persona.**

Una proposta sono QUATTRO cose: il dato che già c'è (misurato), la decisione
che cambia, il costo, cosa la renderebbe utile. L'anti-rischio: «una proposta
che richiede un dato che nessuno racclie è un desiderio».

## Documenti e integrazioni — le domande del confine

- **La rete che fallisce produce un NUMERO**: catch che logga senza rilanciare
  dentro un loop di fetch → costoStandard=0, scostamento 0%, «allineato» sul
  foglio. Correzione: propagare e loggare il denominatore («scaricati N su M»).
- **La risposta VUOTA che distrugge**: `clearContents()` PRIMA della guardia
  su zero record → zeri ovunque con esito «OK».
- **La configurazione è un confine**: un catch che ritorna
  `{generalCostsPercent: 0}` INVENTATO contro il ripiego legittimo con NOME
  dichiarato. Domanda da 174→9 siti: «cedendo, si ferma, o risponde un dato
  letto come vero?»
- **La guardia cieca sull'estremo** (5 progetti su 5 guardati): `return`
  silenzioso quando il modello/il dato manca → «Nessun candidato» si legge
  «niente da segnalare» invece di «niente di giudicabile»; `skipped` calcolato
  e mai spedito → «2 analizzate — 0 anomalie» con tutte scartate. **Correggi
  il denominatore prima dei numeratori.**
- **Il criterio dell'AVVERBIO**: sui cinque punti d'inferenza, quattro con
  «probabile/verosimilmente» e uno senza — quello senza era il rotto.
