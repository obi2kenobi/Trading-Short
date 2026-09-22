- **DIPENDENZA DA LIBRERIA NEL MANIFEST ROMPE google.script.run PER LE SESSIONI AUTENTICATE
  (dal campo REPO-E, 2026-09-02, popolazione 2/2)**: doGet servito (HTTP 200), il POST verso /callback
  risponde 404, NESSUNA traccia nel log delle esecuzioni (le RPC non raggiungono il server), da anonimo
  tutto funziona, da loggato no, su TUTTE le versioni. Domanda discriminante: *il manifest dichiara una
  libreria? Prima di incolpare il browser, prova il progetto senza quella dipendenza.* COROLLARIO ATOMICO:
  manifest e punti di chiamata sono UN SOLO CAMBIAMENTO — rimuovere la dipendenza e lasciare le chiamate
  uccide tutti i trigger (ReferenceError al primo firing); rimuovere le chiamate e lasciare la dipendenza
  lascia la webapp rotta da loggati.
- **IL TRIGGER CONSERVA IL NOME CON CUI È STATO CREATO (REPO-E, 2026-09-02, 4/4 handler)**: una rinomina
  (es. l'underscore finale di un audit) orfana il trigger che fallisce a ogni attivazione senza che nulla
  lo dica. La data della rinomina taglia in due il pannello Attivatori (prima: 0% errori; dopo: 100%).
  Le rimozioni e la diagnostica vanno alimentate da un ELENCO UNICO di nomi con alias pre-rinomina, o la
  correzione entra in una copia e non nelle altre (successo davvero: funzioni di rimozione che confrontavano
  solo il nome nuovo, rimossi: 0 stampato mentre cinque trigger orfani erano installati).
- **L'UNDERSCORE FINALE NASCONDE ANCHE ALL'EDITOR (REPO-E, 2026-09-02, 34 funzioni)**: non solo a
  google.script.run — la nasconde anche al menu a tendina dell'editor, che non la elenca e non la lascia
  eseguire. Un audit che rende privato un toolkit operativo senza lasciare WRAPPER GUARDATI costringe
  chi opera a smontare la sicurezza per lavorare — esito peggiore di entrambe le alternative. Il rimedio:
  implementazione privata + wrapper pubblico con guardia di sessione che passa quando l'identità c'è davvero.
- **SINTASSI ROTTA IN STRINGA LITERALE dentro script inline HTML (dal campo di un progetto retail (categoria REPO, 2026-09-01))**: un
  solo apostrofo non escaped in un literal JS a apici singoli dentro un file .html invalida l'INTERO
  script inline della pagina — non solo la riga. Invisibile alla lettura del diff (un umano legge il
  SENSO della frase italiana, non conta gli apici). L'unico presidio: controllo sintattico ESEGUITO
  (node --check sullo script estratto) per OGNI consegna che tocca un .html con <script> inline.
- **IL TEATRO VERDE È REWARD HACKING (rilinquaggio dall'incidente OpenAI/HF, 2026-08-31)**: nell'incidente
  gli agenti baravano sul task per avere la ricompensa senza fare il lavoro. Il nostro equivalente esatto è
  il test che passa senza verificare (teatro verde), la metrica che misura un'altra cosa, il verde per
  coincidenza: la ricompensa (il esito-ok) senza il lavoro (la prova). Per questo i banchi si provano quando
  DEVONO dire no (mutation-tests) — è l'antidoto costruito al reward hacking, prima di sapere come si chiama.
- **DA TENERE D'OCCHIO (un solo caso, REPO-G 2026-08-31: NON generalizzare finché non ricompare)**: il
  lato UI della famiglia «il codice che aiutava in un caso smette di farlo fuori da quel caso» — 4 pulsanti
  perdevano il tooltip ESATTAMENTE quando si abilitavano (un el.title='' scritto per lo stato disabilitato,
  mai aggiornato per l'abilitato). Stessa forma dei bug di censimento, lato interfaccia.
- **LE FAMIGLIE GENERALIZZANO FRA LINGUAGGI (dal campo REPO-O, 2026-08-29)**: le famiglie
  misurate qui su GAS sono ricomparse IDENTICHE in Python/SQLite dello stesso progetto —
  normalizzazione int/testo, «non letto» vs «vuoto», guardiano cieco, scritture multi-fase
  senza lock. Le famiglie sono del PENSIERO sbagliato, non del linguaggio: quando arrivi
  su uno stack nuovo, la prima cosa da cercare sono le famiglie GIÀ pagate altrove.
# Le famiglie di difetti misurate sul parco (fonte: gas-agent REPO-E, misure 2026-08, ~90 progetti)

> Ogni famiglia porta la POPOLAZIONE misurata e la DOMANDA DISCRIMINANTE —
> quella che separa il difetto vero dalla forma legittima. Una popolazione
> sopra soglia NON basta per un controllo automatico: serve una forma che non
> accusi il legittimo (misurato: «webapp anonima + ponte che scrive» copriva
> 7/7 e ne avrebbe accusati 2 a torto — un modulo d'ingresso PUBBLICO deve
> poter ricevere senza identità).

## Piattaforma GAS

- **Scope globale unico / nomi in ombra**: in GAS tutti i file condividono
  l'ambito; due funzioni omonime non danno errore, vince l'ordine di
  caricamento (né alfabetico né dichiarato). 93 nomi in ombra in 13 progetti:
  71 con corpi identici (innocui), **22 divergenti in 9** — il sintomo è un
  totale `0,00 EUR` o `NaN` senza eccezione. Un `const`/`let`/`class`
  duplicato è SyntaxError che spegne TUTTO il progetto (4 progetti fermi).
  Domanda: *il nome ripetuto ha lo stesso corpo e la stessa firma?*
- **`atHour(N)` non è un orario, è una FASCIA**: due entrypoint con la stessa
  `atHour` girano insieme senza ordine garantito (i JSDoc che dicono «05:30»
  sono la riga che fa credere il contrario).
- **Limiti con un numero**: 6 min di runtime (ma il p95 va MISURATO: una
  guardia tarata a 360 s può tagliare notti che finiscono bene — e accanto al
  p95 si legge sempre n), 100 KB per voce di CacheService, ~20k chiamate
  urlFetch/die, 6 MB per fetch, ~60 req/min BC con throttling dinamico.
- **FORMATTAZIONE FANTASMA** (dal campo, sessione di ottimizzazione tagli
  2026-08-26): il formato numerico in Fogli Google resta attaccato alla
  POSIZIONE, non alla colonna logica — una cella formattata come percentuale
  continua a mostrare percentuale anche dopo che una colonna nuova ne ha
  spostato il contenuto altrove (millimetri mostrati come %). La cura:
  azzerare SEMPRE la formattazione dell'area riscritta prima di applicare la
  nuova (`clearFormats()` o `setBackgrounds/setNumberFormat` esplicito su tutto
  il blocco), non solo il contenuto. Domanda: *quando riscrivo un foglio per
  posizioni, chi garantisce che il formato della posizione precedente sia
  stato cancellato?*
- **Fuso come offset fisso `'GMT+1'` è sbagliato più di metà anno** (Roma è
  GMT+2 da fine marzo a fine ottobre): 27 offset fissi in 6 progetti su 93;
  l'assenza si dichiara col conto degli `'Europe/Rome'`.
- **`toISOString().split('T')[0]` morde dopo mezzanotte** (93 occorrenze in 29
  progetti): la data del fuso sbagliato, non la data dell'azienda.

## Business Central (52 su 80 progetti parlano con BC; score medio 73,1 vs 87,1)

- **`@odata.nextLink` ignorato — 26/52, il più silenzioso**: un report da 200
  righe su 1400 «non sembra rotto». `bcFetch` = una pagina (cardinalità
  nota); ogni lettura a cardinalità ignota è `bcFetchAll`. Un `$top` non è
  una difesa: limita il totale, non la pagina.
- **Paginazione chiusa sull'INDIZIO invece che sull'AUTORITÀ**
  (`value.length < pageSize` invece di `@odata.nextLink`): latente (page size
  BC ≥ 5000), e spegnere l'indizio produce righe DUPLICATE, non mancanti —
  si tengono ENTRAMBI i terminatori. E `if (!response.value) break` su un
  200 con errore OData nel corpo restituisce [] indistinguibile da uno
  scarico completo: la forma che regge è `if (!Array.isArray(value)) throw`
  col denominatore nel messaggio.
- **Token in memoria chiamato «cache» — 10 progetti** (solo 6/52 hanno cache
  vera in Script Property); **scadenza indovinata** (costante 3500 s invece
  di `expires_in`) in 6/52; **401 non ritentato** in 13/52.
- **Valori interpolati in `$filter`**: 210 siti grezzi, **9 veri** (il
  criterio: il valore può arrivare da un dato ED è raggiungibile).
  L'apostrofo si raddoppia (`''`) PRIMA di `encodeURIComponent` (che protegge
  l'URL, non la query). Un apostrofo accidentale dà sempre 400
  (deterministico); un valore costruito è iniezione accettata. E `Edm.Date`
  senza apici + precedenza di `and` su `or` = iniezione «vendite OR tutto».
- **Sentinella BC `"0001-01-01"` è una STRINGA truthy**: 20/80 progetti la
  trattano; passa ogni `|| ""` — e `new Date("0001-01-01").getFullYear()`
  vale 1, quindi ogni listino senza fine viene scartato. La sentinella si
  riconosce nella FORMA in cui arriva.
- **Segni**: `Valued_Quantity` e `Cost_Amount_Actual` da BC arrivano NEGATIVI
  sui movimenti di produzione — un segno invertito non dà errore: dà un
  costo che sembra un ricavo (17 letture, 14 con `Math.abs`, 3 senza).
- **Company id (41), tenant id (30), base URL (15) nel codice** = un lavoro
  di configurazione solo; **un secondo base URL esiste** (non presumere il
  punto d'ingresso unico: si conta).

## Il confine dei dati (dove nascono i numeri plausibili)

- **`Number('')` vale 0, non NaN**: la cella vuota entra come zero contabile
  e ogni guardia `isNaN` la lascia passare — «uno zero che vuol dire "non lo
  so" non si vede, perché zero è un valore contabile legittimo». Prima delle
  formule si guardano i CONFINI (getValues→JS, ''→numero, null→numero).
- **«Non ho potuto leggere» = «zero righe»** (`if (!sheet) return []` ·
  `if (lastRow < 2) return []`): 14 progetti, 57 siti — il lettore risponde
  «vuoto» sia per il guasto sia per il legittimo. Ciò che discrimina non è
  la forma ma il CONTESTO (un `clearContents` schedulato in un'altra fascia,
  un lock non preso dal lettore).
- **La sentinella numerica** (`den>0 ? num/den : 0`, `|| 0`, `-1`, `"N/D"`):
  usare un valore del dominio per dire «non lo so». Una toppa locale è la
  FIRMA di un difetto di confine a monte — e nasconde lo zero VERO.
- **`Invalid Date` è un oggetto truthy**: attraversa `!d || d < soglia` e
  finisce nel bucket NaN che, ordinato per stringa, diventa la «settimana
  corrente» del cruscotto.
- **DUE nomi per la stessa assenza** (es. `'(VUOTO)'` vs `'PRINCIPALE'`): a
  valle i lettori `|| 'PRINCIPALE'` diventano codice morto e il nome finisce
  nei dati incollati altrove.
- **Popolazioni disallineate**: minStock aggregato per articolo contro
  giacenza per articolo×magazzino → falsi SOTTO_SCORTA (o penurie nascoste,
  nel verso opposto). Da cercare: confronti fra grandezze da due cicli con
  chiavi diverse. Se la popolazione grossa contiene quella fine, il filtro
  corretto può solo togliere righe.
- **Le righe di un gruppo PARTIZIONANO la grandezza o la RIPETONO?** (ore
  per operatore: si sommano; pezzi OdP-wide: la riga li ripete — un OdP
  multi-operatore esce 200% a standard). Si risponde leggendo il PRODUTTORE,
  mai il consumatore: nel consumatore `+=` sembra sempre giusto.
- **Media di medie ≠ media ponderata** (0,84 vs 0,21 h/pz: scostamento −76%
  invece di −6%): quale è giusta è domanda di dominio.

## Concorrenza e scrittura

- **Lock sull'entrypoint invece che sulla RISORSA non protegge la risorsa**
  (5 cammini scrivono, 1 solo prende il lock — e due trigger sulla stessa
  `atHour`): nel verso in cui il cammino senza lock legge per primo, a perdere
  la riga è il trigger PROTETTO. Il lock va preso da TUTTI i lati, anche
  lettori, nella sede della sezione critica (lettura+scrittura), con
  rientranza, `tryLock` + throw + release in `finally`.
- **clear-poi-scrivi** (122 siti in 23 progetti): il lock protegge dalla
  concorrenza, non dall'interruzione a metà — le garanzie si sommano. La
  cura è UNA `setValues` sola (intestazione+dati+residuo letto PRIMA).
- **appendRow in loop** (6 progetti): se il lock non si può mettere, LASCIA
  `appendRow` (lento ma non perde righe) — il batch senza lock scambia
  lentezza con righe perse.
- **Email in loop** (11 progetti): «una email non si ritira» — la domanda è
  *se muore all'invio 40 di 100, cosa succede al rilancio?* Quota controllata
  PRIMA, traccia `inviato_il` scritta DOPO l'invio riuscito, lock, try/catch
  per riga.
- **Avanzamento come DATA invece che IDENTITÀ** (la famiglia più costosa): la
  data che decide lo skip scarta i file dello stesso giorno — 3 trigger su 4
  non possono importare nulla. La data va bene come finestra della richiesta;
  lo skip lo decide un'identità. Segnale: una funzione di reset scritta a
  mano = la soglia ha già bloccato qualcosa. L'avanzamento si registra DOPO
  la lettura riuscita.
- **Un nome di file Drive NON è una chiave** (due omonimi ammessi;
  cerca-poi-crea è una finestra → doppioni che il rilevatore-orfani, che
  confronta NOMI, non vede). Ciò che discrimina è quante esecuzioni distinte
  arrivano a quella scrittura.
- **Configurazione che scade**: tabella pre-popolata per N anni da setup
  «idempotente» — dal 1/1 dell'anno di setup+N ogni festa è «lavorativa».
  «Automatiche» è la parola che scade: il ripiego sta nel lettore (calcolo,
  zero I/O) e si esegue prima di scriverlo.

## Sicurezza (20 webapp anonime su 80; 31 progetti con un segreto nel sorgente)

- **Ogni funzione globale di una webapp è un endpoint** (`google.script.run`):
  misurato su un progetto — legge, SPENDE (chiave sostituibile), dirotta,
  SCRIVE, spegne trigger, blocca. E **l'underscore FINALE protegge, quello
  iniziale NO** (`_fetchNewToken` globale restituisce il token). Il
  discriminante è CONSEGNARE la credenziale, non toccarla.
- **`getActiveUser()` con Execute as Me + accesso Chiunque torna VUOTO**: la
  guardia nega a tutti — la correzione «ovvia» è dannosa. La verifica sta
  nell'interfaccia di deployment (Distribuisci → Gestisci distribuzioni), non
  nel manifest (`webapp.access` è il default dei NUOVI deployment).
- **La guardia va nel PONTE, mai nella funzione condivisa** (3 ponti su 11
  sono anche percorsi di trigger: la spegnerebbe alle 5 del mattino, in
  silenzio), e mai come nuova funzione globale di setup (= un endpoint nuovo).
- **Catena XSS persistente**: scrittura non autenticata → persistenza nel
  foglio → `innerHTML` senza escape. E CDN senza `integrity`: 24 tag su 16
  cartelle — verificare che il file CDN esista DAVVERO nel pacchetto prima
  di appuntarne l'impronta.
- **Preferisci correzioni MONOTONE RESTRITTIVE** (l'underscore finale «non
  esiste uno scenario in cui nega a chi lavora»).
- **Segreti**: mai il valore, nemmeno una fetta; mai proporre rotazione; si
  censise con ancora sulla dichiarazione e «valore non riportato».

## Test e verifica (55 su 80 con `test*` che non può fallire)

- **Le 7 forme di prova che non prova**: ispettore travestito (legge e
  stampa); runner sempre verde («ALL TESTS COMPLETED è una frase, non un
  verdetto»); asserzione ingoiata; **verdetto calcolato e non alzato**
  (`allPassed` esiste, `return results` — manca un `throw`: la più vicina
  alla soluzione); successo su risultato vuoto; confronto sbagliato sempre
  verde; e il test che SPORCA la produzione (128 `test*` mandano email vere
  in 29 progetti; 148 toccano fogli).
- **La leva è la funzione a ZERO argomenti, non il nome** (su 684 globali:
  120 morte, 43 mandano email vera, solo 28 si chiamano `test*`).
- **Un test che non può fallire non è un test, è una stampa**: tre helper di
  4 righe (`assertEquals_`/`assertClose_`/`assertTrue_`, trattino basso
  FINALE = convenzione GAS del privato), i fallimenti accumulati e UN throw
  finale. 370 funzioni `test*` su 625 confrontano già qualcosa: non mancano
  i test, manca la riga che rende visibile una differenza.
- **I casi si prendono dal VIVO**: su input inventati la parità non dimostra
  niente (misurato: il caso inventato «dimostrava» parità vera solo perché
  `Number(null)` è 0).

## UI (la parte che una persona guarda)

- **Il difetto è invisibile nello stato di apertura della pagina**: il banco
  deve GUIDARE l'interazione (click→filtro→lettura), il primo render
  fotografa verde. Tre facce della stessa bugia: grafico non ridisegnato,
  endpoint che ignora un filtro, filtro valido in una vista sola.
- **Il nome che non combacia NASCONDE la formula sbagliata** (produttore
  `effPerc`, lettore `effPura` → linea di buchi; e la legenda dice Std/Act
  dove la formula è (Std−Act)/Std).
- **Ordinamenti**: intestazione che ordina una grandezza diversa da quella
  stampata; `data-sort` su booleano; l'ordine che non sopravvive a un
  `filter()`; sort di sottoinsieme + appendChild che fa galleggiare le righe
  in testa. Regola: «non chiedersi se la tabella si muove, ma da dove riparte
  questo render».
- **Stub povero accusa il codice, stub generoso lo assolve** (un DOM finto si
  costruisce LEGGENDO l'Index.html, con la data congelata).

## Il verbale dell'esperienza (le frasi che valgono un pomeriggio)

- «Un banco rosso che conferma il sospetto con cui l'hai scritto si crede.»
- «Un rilievo che non può fallire non è un rilievo, è una stampa.»
- «L'assenza del sintomo non è la presenza del comportamento.»
- «Un fallback che non può fallire trasforma un guasto rumoroso in un dato falso.»
- «Una riga di censimento che dice ZERO porta il comando che l'ha prodotta.»
- «Correggi il denominatore prima dei numeratori.»
- «La regola del produttore batte la maggioranza dei consumatori.»
- «Chi guarda i `.rej` non vede niente: patch pulita e zero `.rej` può
  significare che una correzione ne ha spenta un'altra.»

- **TEST MANUALE che scrive su produzione senza foglio di scratch** (dal campo
  REPO-F, 2026-08-27): quando isolare la risorsa non e un opzione a basso costo,
  la cura e il parametro opt-in DEFAULT-SAFE (`scriviSuProduzione=false` di
  default): l'editor Apps Script chiama SEMPRE a zero argomenti, quindi il default
  blocca l'esecuzione accidentale del bottone Esegui senza impedire l'uso
  deliberato (true da un'altra funzione o dalla console).

- **Prima di privatizzare con l'underscore finale, GREP DEL FRONTEND**: il
frontend chiama in genere solo i ponti, ma a volte chiama proprio la funzione
che l'audit vorrebbe privatizzare (dal campo: 4 funzioni salvate dal grep). La
rinomina giusta e monotona restrittiva SOLO dopo il grep dell'HTML.
- **Security codes hardcoded nel sorgente**: pattern securityCode/securityCodePrefix
 seguito da un valore alfanumerico — il rilevatore li cerca ma la forma varia
da progetto a progetto: aprirli a mano quando la sicurezza e in gioco.

- **CSV/FORMULA INJECTION** (dal dossier SD, 2026-08-28): l'export CSV che
racchiude i valori tra virgolette senza neutralizzare =, +, -, @ espone a
injection quando il file viene aperto in Excel/Sheets: una cella malvagia
diventa formula. Cura: prefissare un apostrofo o raddoppiare le virgolette.
- **LIBRERIA in developmentMode: true in produzione** (dal dossier SD): lo
script esegue sempre la versione HEAD non pubblicata della libreria invece
di una versione fissata — un cambiamento a monte della libreria cambia il
comportamento di produzione senza deploy.
- **CACHE STALE CHE RISCRIVE INTERE RIGHE** (dal dossier SD): bulkConfirm
riusa uno snapshot di 3 minuti prima per riscrivere TUTTE le colonne: ogni
modifica concorrente fatta nel frattempo viene silenziosamente annullata.
Cura: riscrivere SOLO le colonne modificate, mai l'intera riga dalla cache.
