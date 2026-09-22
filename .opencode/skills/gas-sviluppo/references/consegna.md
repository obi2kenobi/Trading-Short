# La consegna — da consulente a operaio (fonte: gas-agent/esecuzione.md di REPO-E)

> Si legge SOLO quando il lavoro è una consegna: un diff destinato alla
> produzione. Per una consulenza basta il metodo.

## Correttori paralleli: worktree DAL PRIMO COMMIT (lezione dell'incidente 2026-08-27)

Due agenti che correggono sullo stesso repo si contendono il checkout: uno scambia
branch sotto l'altro (successo davvero, recuperato con cherry-pick). Il worktree
isolato non e un opzione quando serve: e la CONDIZIONE DI PARTENZA — ogni
correttore nasce in git worktree add proprio, dal primo commit.

## Regola d'oro dell'isolamento

**Un task · un worktree · un ramo · una PR.** Mai due agenti sullo stesso
file; se due task toccano lo stesso file sono UN task (o si serializzano). Il
conflitto si evita per costruzione, non si risolve dopo.

```bash
git worktree add ../wt-<slug-task> -b fix/<slug-task>
# ... lavoro isolato ...
git worktree remove ../wt-<slug-task>   # a PR chiusa
```

## Il ciclo

1. **L'ordine di lavoro arriva da fuori** (Supervisore/pagella/commessa), non
   si inventa.
2. **Allinea il repo al vivo PRIMA di toccare** (`clasp pull` + commit, fatto
   dall'umano o dall'ultimo specchio disponibile): partire dal drift
   significa deployare regressioni.
3. **Isola** (worktree).
4. **Cattura la baseline PRIMA** delle modifiche: senza l'output di prima, la
   parità non è dimostrabile dopo — si cattura prima, mai a posteriori.
5. **Applica** un rilievo alla volta, un commit per rilievo (ogni commit è
   uno stato funzionante).
6. **Dimostra la parità** (sotto). Senza prova non si apre la PR.
7. **Apri la PR** col protocollo. Poi STOP: il merge è dell'umano.

## La prova di parità — tre livelli, si usa il più alto praticabile E SI DICHIARA

| Livello | Cosa | Quando |
|---|---|---|
| **1** | logica pura eseguita due volte (vecchia/nuova) sugli STESSI CASI PRESI DAL VIVO, confronto byte per byte (o runner `npm test` se esiste) | sempre per primo |
| **2** | golden run su copia di STAGING del foglio | ⛔ oggi 0 progetti su ~80 hanno una copia di staging: va detto ogni volta |
| **3** | diff ragionato riga per riga — parità NON dimostrata | solo quando 1 e 2 non sono praticabili, e VA DICHIARATO |

- Un runner verde NON è parità del tuo fix se non copre il percorso toccato:
   `grep` dei nomi delle funzioni modificate nei test.
- L'estrazione della logica pura È parte del fix, non lavoro extra: rende il
  progetto testabile la prossima volta.
- «Il codice è equivalente» senza esecuzione non è una prova; «ho solo
  rinominato» vale il Livello 1 (cinque minuti).
- **Chiamare prova un Livello 3 è l'unico modo in cui questo sistema può fare
  danni**: l'umano che approva deve sapere se sta approvando una prova o un
  argomento.

## Protocollo PR (il corpo, in quest'ordine)

```markdown
## Ordine di lavoro
Fonte: <pagella | scoperta | commessa> · Rilievi affrontati: <elenco>
Rilievi NON affrontati e perché: <elenco, o "nessuno">

## Diff sintetico
<una riga per file>

## Prova di parità
Livello: <1|2|3> · Come: <comando eseguito> · Esito: <output INCOLLATO, non riassunto>

## Cosa resta all'umano
- [ ] Revisione e merge
- [ ] clasp push sul progetto vivo
- [ ] Esecuzione manuale di un entrypoint (se servono nuovi scope)
```

## Il cancello umano: `clasp` mai, in nessuna circostanza

> Osservazione dal campo (2026-08-26): il divieto copre DUE rischi distinti
> che vale la pena nominare separati — (1) il maneggiare le credenziali che
> autorizzano il deploy (credenziale clasp unica e condivisa: rischio
> assoluto, non si allenta), (2) la scrittura in produzione senza staging né
> rollback (rischio reale ma di altra natura). La regola resta integralmente
> in vigore; allentare la parte (2) — es. deploy assistito con credenziali
> fuori dalla portata dell'agente — è decisione del proprietario, non
> un'interpretazione (DEBITI la registra). Il costo del confine com'è: ~20
> cicli manuali in una sessione, ognuno un'interruzione per l'umano.

- Il push scrive in **produzione** senza staging automatico e senza rollback.
- Il parco condivide **una sola credenziale clasp** (rate limit e
  attribuzione).
- Un push cieco deploya il drift e può cambiare l'accesso di una webapp senza
  che nessuno l'abbia chiesto.
- Il **drift lo puoi segnalare TU prima**, confrontando repo e specchio
  dell'ultimo mirror — l'umano arriva al push sapendo cosa aspettarsi.
- ⛔ Il manifest NON dice chi accede alla webapp: `webapp.access` è il default
  dei nuovi deployment; l'accesso vero sta nell'impostazione del deployment,
  che non sta in nessun file (un «accesso anonimo» si verifica
  nell'interfaccia, non si chiude come falso positivo sul manifest).

## Routing dei costi (fonte: gas-agent/routing-costi.md — valori di partenza, non dati)

Due assi: **determinismo** della trasformazione e **costo dell'errore**.
Alto determinismo + errore economico → modello piccolo/effort basso (task
meccanici: rimozione codice commentato, `parseInt` senza radix, righe
lunghe). Basso determinismo O errore costoso → modello grande/effort alto
(sicurezza/segreti, architettura, giudizio). Sugli economici: parti basso,
sali AL FALLIMENTO, al secondo fallimento passa all'umano. Sui costosi da
sbagliare: parti alto, niente escalation. E chi GIUDICA non è chi ha
scritto (un agente che rivede il proprio lavoro tende a confermarlo).
Le leve PRIMA del modello: progressive disclosure, non rileggere, raggruppare
task omogenei (il contesto si paga per lotto), ordine di lavoro preciso (un
agente che deve SCOPRIRE cosa fare costa molte volte uno a cui è DETTO).


## I due regimi di conferma (dal campo REPO-I, 2026-08-27)

Le regole passo-per-passo valgono PER INTERO su analisi, decisioni di dominio,
logica nuova, ambiguita reale. Su un batch di fix GIA diagnosticati con precisione
(file, riga, causa) da unanalisi precedente, il proprietario puo dare unautorizzazione
unica a procedere in sequenza: comprimere le conferme li e legittimo, non indisciplina.

## Da verificare dal vivo (il terzo stato, dal campo REPO-I)

Fra "difetto" e "confermato" esiste lo stato che una sessione non puo chiudere da sola:
testato in isolamento, NON ancora visto girare nel vivo (Gmail/Drive/BC reali). Il corpo
PR porta una sezione "## Da verificare dal vivo" con le caselle di cio che resta: e il
livello 3 dei cinque (verita terrena ritardata) reso tracciabile, non reinventato per PR.


## Gerarchia di verifica per il DOM (dal campo REPO-G, 2026-08-27)

Quando un fix tocca HTML/JS che gira nel BROWSER (non solo la logica
server-side), il banco vm non basta: estrae e prova la logica, ma non vede
il rendering, gli event handler, il CSS. Gerarchia:
1. banco vm (logica pura) — sempre, per ogni fix
2. **Playwright headless** — quando il fix tocca il DOM: apre l'HTML reale
   in Chromium, aspetta i selettori, verifica che i bottoni rispondano e i
   dati siano visibili. Costo: minimo (nessuna dipendenza nel progetto,
   eseguito da directory esterna, pattern fuori-repo già canone).
3. screenshot — quando serve il colpo d'occhio (già coperto da verifica-visiva)
