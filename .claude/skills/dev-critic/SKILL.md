---
name: dev-critic
description: Trova punti deboli, debito tecnico, buchi di sicurezza (allowlist bucabili, segreti esposti — lente sicurezza sempre applicata, §2bis), errori nelle formule di calcolo matematico-finanziarie (quadrature/plug che nascondono un residuo vero, non solo di arrotondamento — lente §2ter) e nuove funzionalità non considerate in uno script, uno strumento o un intero progetto — nel hub AI_Programmer o in un progetto onboardato (es. REPO-C) — combinando lettura critica del codice con un tentativo REALE di usarlo (dogfooding), non solo ispezione statica. Fa anche critica costruttiva propositiva: idee di sviluppo non ancora coperte, confrontando lo scope dichiarato (PROJECT.md/SAL.md/README) con quello implementato. Usa quando l'utente chiede di trovare nuove idee o funzionalità mancanti, criticare o revisionare uno script/progetto in modo approfondito, capire cosa manca prima di svilupparlo oltre, o invoca /dev-critic esplicitamente. Non sostituisce code-review (bug nel diff corrente) né simplify (pulizia del codice cambiato): questo guarda l'intero target, comprese le funzionalità che NON esistono ancora. Non sostituisce nemmeno `audit-commessa` (5° ciclo, set 3 giro 8, 2026-08-23 — la relazione era dichiarata solo da quella parte, non da questa): quello guarda SOLO le commesse night-shift già in coda, pre-flight prima della notte; questo guarda l'intero progetto per gap non ancora considerati, prima che diventino commesse.
---

# dev-critic — critico e scopritore di sviluppo

Trova ciò che l'ispezione superficiale non trova: usa lo strumento davvero, non solo leggerlo.
Nasce da una lezione pagata in questa stessa sessione: la sola lettura degli script di
AI_Programmer non aveva mostrato i gap reali — l'onboarding vero di un progetto esistente
(REPO-C) sì (percorso cloud non documentato, drift di CLAUDE.md, credenziali
committate). Questa skill istituzionalizza quel metodo.

## 0. Target

Chiedi, se non specificato, su cosa lavorare: un percorso/script preciso, un intero repo, o
"il hub + un progetto onboardato" per un confronto tra i due. Senza un target chiaro non
procedere a indovinare (regola del progetto: "se qualcosa è poco chiaro, chiedi").

## 1. Metodo — due fasi, in ordine, mai saltare la seconda

1. **Lettura critica.** Leggi per intero (non solo i punti "notabili") il codice del target E i
   suoi documenti dichiarati (README, PROJECT.md, CLAUDE.md, SAL.md/CHANGELOG). Segna ogni punto
   dove documentazione e codice non coincidono — è quasi sempre lì che si nasconde un gap.
2. **Dogfooding reale.** Quando l'ambiente lo permette, prova a usare davvero lo strumento o la
   funzionalità su un caso concreto — non ipotetico (esegui lo script, fai l'onboarding vero,
   chiama l'endpoint, apri il flusso che descrivi). Solo l'uso reale rivela i gap di processo che
   la lettura statica non mostra. Se non puoi eseguire davvero (permessi, ambiente, dati
   mancanti), dillo esplicitamente — non fingere di averlo fatto.

## 2. Categorie di output (sempre con file:riga, mai generiche)

- **Bug confermati** — comportamento sbagliato verificabile nel codice attuale.
- **Punti deboli/sicurezza** — dove un input o un errore ragionevole rompe qualcosa in modo
  silenzioso o rischioso.
- **Debito tecnico non tracciato** — scorciatoie prese ma non scritte in DEBITI.md o equivalente.
- **Gap di processo** — emersi solo provando a usare lo strumento, non dalla lettura del codice.
- **Nuove funzionalità non considerate** — confronta lo scope DICHIARATO (cosa i documenti
  dicono che il progetto fa o farà) con quello IMPLEMENTATO: cosa è promesso ma assente, cosa un
  caso d'uso reale richiederebbe e oggi non c'è. Proponi, non implementare senza conferma. Se
  l'idea è ancora vaga (non sai dire in una frase cosa deve essere vero dopo), il passo
  successivo naturale è `/brainstorming`; se sono già visibili 2+ approcci concreti, è
  `/design-doc` (4° ciclo, set 2, giro 9, 2026-08-23) — dillo nel report invece di lasciare
  che l'idea resti un'affermazione isolata senza un passo successivo dichiarato.
  **Se emergono 3+ idee distinte nello stesso report** (5° ciclo, set 2, giro 6,
  2026-08-23 — "scelta delle migliori idee": nessun punto del sistema diceva come
  scegliere DA QUALE idea partire quando più di una emerge insieme, solo come
  strutturare la scelta DENTRO una singola idea già isolata), ordinale con gli stessi
  criteri costo/rischio/reversibilità che `/design-doc` già usa per le opzioni — non
  un punteggio nuovo, lo stesso vocabolario, applicato al portafoglio di idee invece
  che a una sola. Non è una raccomandazione a implementare: è un ordine di lettura per
  chi deve scegliere, la scelta resta di chi possiede il progetto.

Per ogni finding: severità, perché conta, un suggerimento concreto (non vago) e — se è una
scelta di design con impatto (sicurezza, breaking change, costo) — dillo esplicitamente e non
procedere senza il sì del proprietario.

## 2bis. Lente sicurezza — sempre applicata, non solo quando sospetti qualcosa

Due incidenti reali in questo stesso sistema (2026-08-21) sono nati da codice che
"sembrava" a posto a lettura: `gate_allowlist_ok()` bloccava solo il primo token di un
comando (bypassabile con `bash -c`/`python3 -c`), e `credenziali BC.rtf` è finita committata
nella storia git di un progetto onboardato. Nessuno dei due è stato trovato leggendo il
codice per la prima intenzione — solo provando ad aggirarlo o ispezionando cosa contiene
davvero il repo prima di toccarlo. Applica sempre, non solo se il target "sembra" sensibile:

- **Se il target esegue codice generato da un LLM** (banco avversariale, agenti che
  eseguono comandi): una blacklist per parola chiave non basta — verifica se un interprete
  general-purpose (`bash`, `sh`, `python3`, `node`, `awk`, `sed`) resta nell'allowlist, e
  se sì prova a bucarla per davvero (pattern `allowlist-per-segmento`).
- **Se il target stampa output derivato da codice/dati di terzi** (report, trascrizioni,
  log): verifica se un segreto (token, chiave, password) potrebbe finire a schermo in
  chiaro — e se il progetto ha già un modo per mascherarlo (pattern `segreto-come-impronta`)
  prima di proporne uno nuovo.
- **Prima di toccare o onboardare un repo esistente**: ispeziona cosa contiene (file di
  credenziali, `.rtf`/`.env`/config con segreti) PRIMA di lavorarci, non dopo — un secret
  scanner (gitleaks) è preferibile a una lettura a occhio.
- **Se il target ha un sandbox dichiarato** (seatbelt, container): verifica cosa NEGA
  davvero, non cosa dice di negare — un sandbox che blocca solo la rete lascia comunque
  leggibili le credenziali locali a chi ci gira dentro.

## 2ter. Lente matematico-finanziaria — quando il target fa calcoli che devono essere giusti

Nata da un bug reale (2026-08-21, REPO-G — progetto vero, cliente vero, non un
pilota): `gas/Sp.js` (Stato Patrimoniale per le banche) aveva un segno sbagliato nella
formula del plug (`resto2 = serve - suIva`, doveva essere `serve + suIva`). Il bug era
invisibile a lettura E invisibile a "quadratura: 0,00 ✅" — il passo finale di tie-out
(pensato per pochi centesimi di arrotondamento) assorbiva SEMPRE l'intero residuo,
qualunque fosse la sua entità, quindi ogni riscontro storico tornava "in pareggio" anche
quando la logica sottostante non lo era. Trovato solo eseguendo la funzione vera con dati
sintetici (`tools/test-sp.js` in REPO-G) e guardando il residuo PRIMA del
passo di aggiustamento finale, non dopo. Applica quando il target contiene formule con un
invariante di dominio verificabile (contabilità: Attivo=Passivo; riparti che devono
sommare al 100%; conversioni; arrotondamenti):

- **Isola le funzioni di calcolo pure** (senza rete/GAS/DB) e costruisci un banco che le
  esegue davvero con dati sintetici minimi ma realistici nella forma — mai fermarsi alla
  lettura delle formule, un errore di segno si nasconde bene nella prosa di un commento.
- **Misura l'invariante PRIMA di un eventuale passo di aggiustamento finale** (rounding,
  plug, tie-out, quadratura forzata): quel passo esiste per nascondere il rumore, non
  l'errore — se lo misuri solo DOPO, un bug vero e un centesimo di arrotondamento sono
  indistinguibili. Se il residuo pre-aggiustamento supera una soglia ragionevole (non
  pochi centesimi), è un sintomo da riportare, e se il codice lo assorbe comunque in
  silenzio, proponi una guardia che lo segnali (pattern `soglia-con-provenienza`).
- **Prova scenari avversariali, non solo il caso felice**: segno invertito (perdita
  invece di utile), lo squilibrio che supera la capienza di ogni meccanismo di
  assorbimento, voci a saldo zero, valori enormi. Il caso che ha rivelato il bug reale
  sopra era il caso NORMALE (l'IVA assorbe una parte del plug), non un edge case scelto
  ad arte — non fidarti che "i numeri reali già validati" abbiano davvero esercitato la
  formula nel modo giusto.
- Il pattern esteso (banco Node/vm su codice GAS puro, senza dipendenze) è documentato in
  `patterns/banco-sintetico-per-calcoli-critici.md`.
- Questa lente REVISIONA un calcolo già scritto. Per COSTRUIRE un calcolo
  contabile/gestionale nuovo (non ancora scritto) senza indovinare la formula, usa
  `.claude/skills/controllo-gestione/SKILL.md` — stessa disciplina (oracolo citato,
  invariante verificato con dati concreti), applicata prima del codice invece che dopo.
- Questa lente esiste anche come subagent dedicato, `.claude/agents/revisore-calcoli-critici.md`
  (5° ciclo, set 3 giro 1, 2026-08-23 — la direzione mancante: `controllo-gestione`
  cita già i tre agenti al suo §6, questa lente non citava ancora quello che la
  incarna). L'invocabilità del tool Agent su questo e gli altri due agenti del set
  dipende da un refresh del roster (`docs/system.md` §"Limiti dichiarati" #6) — non
  presumere che un'invocazione fallita subito dopo aver scritto un agente sia un
  bug del file.

## 3. Regole non negoziabili (eredità da CLAUDE.md del hub)

- Questo è un giro di analisi, non di correzione: non modificare codice durante questa fase. Se
  l'utente chiede anche il fix, trattalo come step separato ed esplicito, dopo aver mostrato i
  findings.
- Ogni proposta ha un trade-off dichiarato — niente "miglioramenti" senza costo o rischio
  indicato ("Only what is asked", "Surface interpretations and tradeoffs").
- Se il target ha una documentazione viva propria (SAL.md, DEBITI.md, CORREZIONI.md), suggerisci
  di scrivere lì le scoperte — non lasciarle solo in chat ("Keep living documentation").
- Le idee di nuove funzionalità si propongono, non si scrivono, finché non è chiesto
  esplicitamente ("Only what is asked").

## 4. Output

Un report strutturato nell'ordine: bug → sicurezza → gap di processo → debito tracciato →
nuove idee. Riferimenti file:riga verificabili in ogni punto. Se l'utente deve passarlo ad altri
(umano o altro LLM), scrivilo come file autosufficiente — leggibile senza il contesto di questa
conversazione — non solo come testo in chat.


## Vedi anche

skill `brainstorming` (il passo prima) · skill `design-doc` (il passo dopo)
