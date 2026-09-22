---
name: controllo-gestione
description: Ancora un problema matematico-contabile (contabilità analitica, di magazzino, controllo di gestione, margini, cespiti) ai dati e alle formule REALI di Gruppo Camarlinghi prima di scrivere codice — mai indovinare una formula di business. Nato dal Set 1 "agenti" del 4° ciclo di auto-miglioramento (2026-08-23): un censimento di REPO-E (repo esterno, cartella gas-src/, ~90 progetti Google Apps Script reali) ha trovato una decina di calcoli di controllo di gestione già implementati (scostamento standard/effettivo, valorizzazione magazzino, roll-forward cespiti, margini per fattura) ma nessun metodo condiviso per affrontarne uno NUOVO senza reinventare la logica. Generalizza per questo dominio lo stesso schema già in uso ad-hoc per Business Central in PROJECT.md ("censimento campi prima dell'analisi" + "riscontro"). Usa quando una richiesta implica calcolare/riconciliare/analizzare una cifra contabile o gestionale reale (non un esempio didattico) per Gruppo Camarlinghi. Non sostituisce /design-doc (quello decide un'architettura software, non tocca la correttezza di un numero); non sostituisce /brainstorming (quello chiarisce cosa serve, questo assume il problema chiaro e ancora la formula ai dati reali prima che tocchino cifre finanziarie).
---

# controllo-gestione — la formula si trova, non si indovina

Il rischio che questo comando chiude: un agente che deve calcolare un margine, una
valorizzazione di magazzino o uno scostamento standard/effettivo per Gruppo Camarlinghi
non ha alcuna base per inventare la formula — è logica di business reale, con soldi reali
dietro. Un progetto reale di gestione magazzino (repo esterno REPO-E, cartella gas-src/)
distingue esplicitamente "articolo non contato" da "articolo contato a zero": un
dettaglio che sembra pedante ma è un requisito di dominio, non un'opinione di stile —
indovinarlo al contrario produce un numero sbagliato che nessun test rivela finché
qualcuno in azienda non lo nota.

## 0. Input — cosa serve prima di iniziare

Una richiesta di calcolo/riconciliazione/analisi su una cifra contabile o gestionale reale
(non un esercizio teorico). Se la richiesta è ancora vaga su COSA deve essere vero dopo
("miglioriamo il controllo di gestione"), usa prima `/brainstorming`.

## 1. Metodo

1. **Individua la fonte dato reale.** Endpoint Business Central già censito in
   `docs/bc/endpoints/` (usa quello, non un'ipotesi sullo schema), oppure un progetto
   esistente in un repo onboardato (es. la cartella gas-src/ di REPO-E) che tratta lo
   stesso tema. Mai inventare la forma dei dati (regola CLAUDE.md "Forma dei dati
   verificata").
2. **Cerca se la formula esiste già.** Prima di scriverla, grep nel codice esistente
   (GAS, altri tool, altri fogli) per lo stesso calcolo o uno molto simile — se c'è, è
   l'ORACOLO: citala per file:riga esatto (senza riportare nomi di progetto interni nei
   file versionati di questo hub pubblico — descrivi il calcolo, non il nome commerciale),
   non parafrasata a memoria. Se non esiste in nessuna forma, **non si indovina**: si
   chiede al proprietario del dominio (Luca) prima di scrivere una riga di codice (regola
   CLAUDE.md "mai indovinare la logica di business").
3. **Costruisci input e output concreti PRIMA del codice.** Numeri veri o rappresentativi
   dello schema reale, non simbolici (`x`, `y`) — regola CLAUDE.md "Input e output di
   esempio prima di scrivere codice". Se la formula viene da un oracolo esistente, l'
   esempio è quello stesso oracolo con dati concreti, non un caso nuovo inventato.
4. **Implementa solo il minimo che passa quell'esempio.** Nessuna generalizzazione
   anticipata (FIFO/LIFO/altri metodi non richiesti, parametri non richiesti) finché un
   secondo caso reale non la richiede — scala minima del ciclo (§ "minimal-code ladder" di
   CLAUDE.md).
5. **Distingui sempre "dato assente" da "valore zero"** quando il dominio lo richiede
   (non contato ≠ contato a zero; nessuna vendita ≠ vendita a margine zero) — è un tipo di
   bug ricorrente nei calcoli contabili reali già osservato in progetti esistenti, va
   trattato come requisito di default in ogni nuovo calcolo, non riscoperto ogni volta.
6. **Verifica con un riscontro**, non solo un test verde: confronta il risultato con un
   totale noto (l'interfaccia BC, il foglio Google esistente, un conteggio manuale) —
   "fatto" è provato E confermato dal proprietario del dominio (regola CLAUDE.md "Done
   means proven and confirmed"). Nella tassonomia condivisa di `docs/system.md`
   §"I cinque livelli di verifica" (5° ciclo, set 3 giro 7, 2026-08-23 — stessa
   tassonomia già richiesta da `/goal` e dal wizard `/nuova-commessa`): il test contro
   un oracolo esistente è livello 1-2 (deterministico/soglia), il riscontro contro un
   totale BC non ancora chiuso è livello 3 (verità terrena ritardata) — dichiaralo se
   la commessa lo richiede, non lasciarlo implicito.

## 2. Dove va documentato il calcolo (mai solo nel codice)

- La formula e la sua fonte (oracolo citato per file:riga, o la conferma del proprietario
  del dominio se non esisteva) vanno in un commento nel tool stesso E in una voce di
  `SAL.md` — non solo in uno dei due, altrimenti chi legge il codice fra sei mesi non sa
  se la formula era verificata o assunta. Nei file versionati di questo hub pubblico,
  cita il repo esterno per codice anonimo (es. REPO-E), mai per nome — la mappatura reale
  vive solo in `night-shift/repos.key` (locale, gitignored).
- Se il calcolo lavora su un endpoint BC, la mappatura del campo usato deve esistere in
  `docs/bc/endpoints/<Nome>.md` — se non c'è ancora, va prima censita (vedi `PROJECT.md`),
  non assunta al volo dentro il nuovo tool.

## 3. Esempi già risolti con questo metodo

- `tools/riconciliazione_magazzino.py` — riconciliazione inventario fisico. Oracolo: un
  modulo di riconciliazione inventario di un progetto reale di gestione magazzino (repo
  esterno REPO-E, cartella gas-src/, non in questo hub). Caso pilota: `qty_bc=120,
  costo_finale=4.50, qty_fisica=115` → `delta=-5, deltaValore=-22.50€`. Test di
  riscontro: `tests/test-riconciliazione-magazzino.sh`.
- `tools/scostamento_standard_effettivo.py` — scostamento costo standard vs effettivo per
  articolo, con severità e trend. Oracolo: un modulo di controllo di gestione produzione
  (stesso repo esterno REPO-E, dominio diverso — prova che il metodo generalizza, non è
  legato a un solo calcolo). Test di riscontro:
  `tests/test-scostamento-standard-effettivo.sh`.
- `tools/rollforward_cespiti.py` — roll-forward annuale cespiti (costo storico, fondo,
  valore netto). Oracolo: un modulo di quadratura/roll-forward cespiti (stesso repo
  esterno REPO-E, terzo dominio diverso). Il segno del fondo (convenzionalmente
  negativo) è l'invariante critico — esattamente il tipo di errore che la lente
  dev-critic §2ter (sopra) cerca in un calcolo già scritto. Test di riscontro:
  `tests/test-rollforward-cespiti.sh`.
- `tools/indici_crisi.py` — indici della crisi d'impresa (CNDCEC/CCII), quarto dominio
  diverso (stesso repo esterno REPO-E) — la lettura più diretta di "temi
  economico-industriali". Le soglie sono pubbliche (CNDCEC, settore ATECO), non un dato
  aziendale: la mappatura conto→aggregato (specifica del piano dei conti reale) NON è
  riprodotta, il tool prende gli aggregati già calcolati come input. Test di riscontro:
  `tests/test-indici-crisi.sh`, con gli stessi tre scenari già validati nel test
  dell'oracolo (riscontro doppio: oracolo + aritmetica a mano).
- `tools/scadenzario_aging.py` — classificazione a fasce di scadenza (aging) e totali
  per scadenzario clienti/fornitori, quinto dominio diverso (5° ciclo, stesso repo
  esterno REPO-E). Confini di fascia (`<` non `<=` ai limiti negativi, `<=` ai limiti
  positivi) e convenzione di segno fornitori (fattura=uscita negativa, nota di
  credito=entrata positiva) letti riga per riga sul codice reale, non indovinati. Test
  di riscontro: `tests/test-scadenzario-aging.sh`, con tutti i confini di fascia
  verificati uno per uno più un caso aggregato derivato a mano.

## 4. Regole non negoziabili (eredità da CLAUDE.md)

- Nessuna formula contabile/gestionale si scrive senza un oracolo citato o una conferma
  esplicita del proprietario del dominio — mai una plausibile a memoria.
- "Non misurato" e "misurato a zero" sono sempre due categorie distinte quando il dominio
  lo prevede.
- Fatto = provato (test/riscontro) E confermato da chi possiede il dominio, mai l'uno
  senza l'altro.
- Repo pubblica: nomi di repo/progetti privati mai per nome, sempre per codice anonimo
  (regola CLAUDE.md "Public repo, private work").

## 5. Dopo il merge: non è più compito di questa skill

Questa skill copre la COSTRUZIONE (prima del codice). La REVISIONE di un calcolo
contabile/gestionale già scritto — trovare un segno sbagliato in una formula, un
plug/quadratura che nasconde un residuo vero — è la lente §2ter di `dev-critic`
(nata da un bug reale: un segno invertito nel plug di uno stato patrimoniale, invisibile
a lettura perché il tie-out finale assorbiva sempre l'intero residuo). Il pattern
`patterns/banco-sintetico-per-calcoli-critici.md` descrive la tecnica (isolare la
funzione di calcolo pura, eseguirla con dati sintetici, misurare l'invariante PRIMA
dell'aggiustamento finale) — è la stessa disciplina usata nei test di questa skill
(§3), applicata lì alla revisione invece che alla costruzione.

## 6. Delega a un subagent (5° ciclo, set 1, 2026-08-23)

Questo metodo esiste anche come tre subagent Claude Code (`.claude/agents/`, non solo
skill invocata a comando), un ruolo per fase — invocabili con il tool Agent
(`subagent_type`). Nota di processo (set 1 giro 8, poi corretta): un primo tentativo
di invocazione subito dopo il commit dei file era stato rifiutato ("Agent type non
trovato"); un secondo tentativo più tardi lo stesso giorno ha invocato tutti e tre con
successo — l'invocabilità dipende da un refresh del roster degli agenti disponibili,
non è garantita nella stessa sessione/turno in cui i file vengono scritti. Dettaglio
in `docs/system.md` §"Limiti dichiarati" #6.

- `contabilita-analitica` — applica/verifica un calcolo GIÀ risolto (§3) ai dati reali;
  sola lettura, non dubita della formula.
- `costruttore-calcoli-gestionali` — segue questo metodo per COSTRUIRE un calcolo
  NUOVO (nessuno dei casi in §3 lo risolve); Edit/Write autorizzati.
- `revisore-calcoli-critici` — applica la lente §2ter (sopra) a un calcolo già
  scritto; sola lettura, non costruisce né applica.

Delegare a uno di questi non sostituisce il metodo di questo file: l'agente eredita
la stessa disciplina (oracolo prima del codice, mai indovinare), cambia solo chi
esegue il passo.


## Vedi anche

skill `brainstorming` (il passo prima) · skill `design-doc` (il passo dopo)
