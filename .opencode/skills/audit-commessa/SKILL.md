---
name: audit-commessa
description: Pre-flight serale su una commessa (issue con label night-shift) prima che il turno di notte la incontri — verifica sul codice reale ogni assunzione su dati/funzioni/strutture che la commessa fa, con enfasi sulla forma dei dati Business Central quando il progetto ne dipende, e (§2bis, 4° ciclo 2026-08-23) sulla formula citata quando la commessa calcola una cifra contabile/gestionale reale. Nato dal primo giro reale (2026-08-21, REPO-B): 3 commesse su 4 avevano difetti veri, tutti di forma-dati, trovati eseguendo non leggendo. Usa quando l'utente chiede di auditare/verificare una o più commesse notturne, invoca /audit-commessa esplicitamente, o prima di lasciare una issue night-shift pronta per la notte su un progetto che parla con BC o calcola una cifra contabile. Non sostituisce dev-critic (quello guarda l'intero progetto per gap/nuove idee); questo guarda SOLO le commesse in coda, contro il codice che già esiste.
---

# audit-commessa — il pre-flight che il turno non può fare da solo

Una commessa che assume la forma dei dati senza verificarla sul codice costa alla notte ore
di palude (pattern `forma-dei-dati-verificata`, `patterns/forma-dei-dati-verificata.md`): il
modello locale capisce il codice ma non converge quando deve inferire da tre file diversi
quale funzione produce davvero un dato. Il giorno se ne accorge leggendo ed eseguendo; questo
audit lo fa PRIMA che la notte incontri il problema, non dopo.

## 0. Target

Una o più issue con label `night-shift`, ancora aperte, non ancora prese dal turno. Se
l'utente non specifica quali, prendi tutte le `night-shift` open del repo indicato.

## 1. Metodo — per ogni commessa

1. **Struttura del template.** Verifica che la issue abbia `## Design` (obbligatoria: il
   turno salta le issue senza, `.github/ISSUE_TEMPLATE/night-shift.md`) e `## Commessa`. Se
   manca `## Design`, fermati qui — non ha senso auditare i dati di una commessa che la
   notte non toccherebbe comunque — e **dillo con un commento sulla issue stessa** (non nel
   body, che resta di chi la possiede): cosa manca, che l'audit dei dati non procede finché
   non c'è, senza chiudere né correggere altro (trovato ambiguo al Giro 4 dei test
   2026-08-21: "fermati e dillo" non specificava a chi/dove — un commento sull'issue rende
   la scoperta visibile a chi la possiede, non solo alla sessione che ha auditato).
1bis. **Il riferimento in `## Design` esiste davvero (5° ciclo, set 2 giro 5,
   2026-08-23).** Il gate meccanico del turno notturno (`night-shift/night-shift.sh`) accetta
   qualunque stringa che SOMIGLI a un riferimento (un link, "SAL.md", "issue #42", un
   nome file con estensione — regex, non verifica) — un riferimento inventato ma
   verosimile ("vedi SAL.md") passerebbe il gate senza che nulla lo controlli davvero.
   Questo audit lo fa: apri il riferimento citato (la voce in `SAL.md`, il file in
   `docs/design/`, la issue/PR) e verifica che esista E, se è un design-doc, che
   contenga la tabella opzioni×criteri richiesta da
   `.claude/skills/design-doc/SKILL.md` §2 — non solo che il testo "somigli" a una
   citazione.
2. **Estrai ogni claim verificabile**: nomi di variabili/funzioni citati, forma di un oggetto
   dati, "dove vive" un dato, colonne/campi che la commessa assume esistano — E ogni
   **convenzione di dominio** presentata come fatto (es. "il prefisso X significa Y",
   "i clienti con pattern Z sono..."). Se esiste `docs/GRAMMATICA_DOMINIO.md`, verificaci
   la convenzione PRIMA di crederla: una riga assente o marcata `⏳ da confermare` significa
   che la commessa tratta un'ipotesi come un fatto (trovato al Giro 5 dei test 2026-08-21:
   una convenzione inventata sul prefisso articolo avrebbe svuotato il 100% di un report
   reale — verificato eseguendo il filtro sui dati, non presumendo).
3. **Apri il file vero e verifica.** Non fidarti del nome che "suona giusto": leggi la
   funzione citata, conta i campi, esegui uno snippet quando è più veloce che leggere
   (`node -e`, un test sintetico — pattern `esegui-non-leggere`). Se il progetto ha un banco
   di validazione separato dal codice GAS (pattern del "banco prima, poi GAS": Python/Node
   prima, `.gs` dopo), la forma dei dati vera è spesso lì, non nell'oggetto che la dashboard
   espone a schermo.
4. **Se il progetto dipende da Business Central**, applica anche la lente specifica (§2).
5. **Se la commessa calcola/riconcilia una cifra contabile o gestionale** (margine,
   valorizzazione, scostamento, roll-forward, ecc.), applica la lente specifica (§2bis).
6. **Correggi il body** della issue (via API, mai committando sul workdir della notte —
   pattern `workdir-e-proprietario`) aggiungendo `## Forma dei dati (verificata sul codice)`:
   per ogni claim, ✅ se vero con la citazione file:funzione, ❌ con la correzione se falso.

## 2. Lente Business Central — quello che questa sessione ha già pagato

Verifica specificamente questi punti quando la commessa parla di dati BC, prima di fidarti
della prosa della commessa:

- **Aggregazione per famiglia ≠ aggregazione per codice.** Un oggetto che espone un totale
  "per famiglia"/"per gruppo" NON implica che il dettaglio per singolo codice esista nello
  stesso oggetto — spesso è un dataset separato, caricato on-demand da un'altra funzione
  (lezione diretta: `bilancio.acquistato` per famiglia vs `righeAcquisto_()` per codice,
  REPO-B issue #11). Se la commessa dice "il dato è già in `X`", apri `X` e
  conta i campi — non assumere che "già presenti" significhi "nello stesso oggetto".
- **Gli endpoint OData hanno buchi noti**: niente OR annidati su certi filtri (torna HTTP 501
  — il dettaglio "HTTP 501" è in `SAL.md:235-236` di REPO-B, non in
  `Cache.gs`: il codice lì (riga 14) dice solo "non supporta filtri complessi", senza lo
  status code — citazione corretta al Giro 11/12 dei test 2026-08-21, prima diceva solo
  "Cache.gs" e l'ancora non c'era per quel dettaglio specifico), paginazione con `@odata.nextLink` da non
  dimenticare. Se la commessa descrive un filtro complesso, verifica che l'endpoint citato lo
  supporti davvero, non che "dovrebbe".
- **Il catalogo endpoint è la fonte di verità sui campi**, non la memoria di chi scrive la
  commessa: se esiste un `CATALOGO_ENDPOINT_BC.md` nel progetto, i nomi di campo vanno letti
  lì, non riscritti a memoria.
- **Le credenziali non si citano per valore**: se la commessa deve menzionare come si
  autentica, cita il percorso del file/la variabile, mai il segreto (pattern
  `segreto-come-impronta` per qualunque output che potrebbe stamparlo per errore).

## 2bis. Lente controllo-gestione — quando la commessa calcola un numero contabile/gestionale

Nata dal Set 1 "agenti" del 4° ciclo (2026-08-23), insieme alla skill
`.claude/skills/controllo-gestione/SKILL.md`. Verifica specificamente questi punti
quando la commessa calcola/riconcilia una cifra contabile o gestionale reale (margine,
valorizzazione, scostamento, roll-forward, ecc.), prima di fidarti della prosa della
commessa:

- **La formula citata è un vero oracolo, non una plausibile a memoria.** Se la commessa
  dice "il margine si calcola come X", apri il file:riga citato e verifica che dica
  davvero X — non che "sembra ragionevole". Se non cita nessun file:riga e nessuna
  conferma esplicita del proprietario del dominio, la commessa sta indovinando: fermati
  e dillo con un commento, come per una `## Design` assente (§1.1).
- **"Dato assente" e "valore zero" restano due categorie distinte** quando il dominio lo
  richiede (non contato ≠ contato a zero) — se la commessa non lo distingue e il calcolo
  originale lo fa, è un'assunzione sbagliata da correggere nel body, non un dettaglio.
- **Un residuo di quadratura/plug misurato solo DOPO un aggiustamento finale non prova
  nulla** (lente `dev-critic` §2ter) — se la commessa descrive una verifica di questo
  tipo, verifica che l'invariante sia misurato PRIMA dell'aggiustamento.

## 3. Regole non negoziabili

- Non implementare il fix della commessa in questo passo: è un audit, non una correzione. Se
  la correzione è piccola e ovvia (una data nel nome file, un refuso), puoi farla, ma dillo
  esplicitamente come passo separato.
- Ogni correzione al body è verificata per esecuzione dove possibile, non per lettura — se
  scrivi "la funzione X fa Y", hai eseguito o letto X riga per riga, non presunto dal nome.
- Se una commessa risulta interamente obsoleta (il codice fa già quello che chiede), dillo
  chiaramente e lascia la decisione di chiudere a chi possiede la issue.

## 4. Output

Un body di issue aggiornato con `## Forma dei dati (verificata sul codice)`, e un riepilogo
finale: quante commesse auditate, quante correzioni, quante erano già giuste — lo stesso
formato del primo giro (REPO-B, 2026-08-21: 3/4 difettose).


## Vedi anche

skill `dev-critic` (gap di progetto) · skill `controllo-gestione` (cifre)
