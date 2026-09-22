---
name: goal
description: Loop di ottimizzazione diurno con un obiettivo verificabile e un tetto di tentativi — un cambiamento per tentativo, verifica dichiarata col suo livello (1-5), verifica avversariale prima di dichiarare vittoria, log di ogni tentativo in loops/. Citato in CLAUDE.md §7 ("/goal <obiettivo verificabile> | max N tentativi") e in docs/system.md/loops/README.md da quando il sistema esiste, ma senza alcun file che lo implementasse — loops/ è rimasta vuota (solo il README) finché non è stato scritto questo comando; il primo loop reale è stato eseguito solo al ciclo successivo (5° ciclo, set 2 giro 3, 2026-08-23 — "costruito" non era ancora "provato"). Usa quando l'utente chiede un'ottimizzazione iterativa con verifica ("ottimizza X finché...", "prova a migliorare Y", esplicitamente con "| max N tentativi"), o invoca /goal. Diverso dal turno notturno: qui c'è SEMPRE un tetto di tentativi (ottimizzazione iterativa diurna), la notte non ne ha mai uno (commessa unica e lunga) — tensione dichiarata e voluta in docs/system.md, non un'incoerenza da correggere.
---

# goal — un obiettivo, un tetto, una prova ad ogni passo

## 0. Sintassi

```
/goal "<obiettivo verificabile>" | max N tentativi
```

Se l'obiettivo NON è già verificabile (es. "rendi il codice più bello"), fermati e
chiedi di riformularlo come verifica — non indovinare un criterio numerico per
un'estetica soggettiva (regola "Goal-driven execution", CLAUDE.md §1). Esempi
verificabili: "tempo di risposta sotto 200ms", "tutti i test passano E il tempo di
build scende sotto 30s", "zero warning di shellcheck".

## 1. Prima di iniziare — dichiara il livello di verifica

I cinque livelli sono in `docs/system.md` ("I cinque livelli di verifica"): 1
deterministico/booleano, 2 regole e vincoli numerici, 3 verità terrena ritardata, 4 LLM
giudice, 5 checkpoint umano. Dichiara qui quale livello copre l'obiettivo — un obiettivo
di livello 4-5 (giudizio, review umana) in un loop automatico senza sorveglianza è un
rischio, dillo esplicitamente prima di procedere.

## 2. Il loop — un cambiamento per tentativo

Per ogni tentativo, fino al tetto N (mai superato: un tetto ignorato non è più un
tetto):

1. **Un solo cambiamento mirato** — non una raffica di modifiche insieme: se il
   tentativo funziona o fallisce, deve essere chiaro COSA ha funzionato o fallito.
2. **Esegui la verifica dichiarata** (il comando/criterio del punto 1) — mai a
   memoria, mai "dovrebbe passare".
3. **Registra il tentativo** in `loops/<data>-<slug>.md` (crea il file al primo
   tentativo): cosa è cambiato, il risultato della verifica, se il tentativo continua o
   si ferma. Un tentativo per sezione — chi legge dopo vede la strada, non solo
   l'arrivo (regola da `loops/README.md`, mai applicata finché questo comando non
   esisteva).
4. Se il tentativo fallisce, il tentativo successivo cambia approccio sulla base di
   COSA è appena stato escluso — non ripetere la stessa modifica sperando in un esito
   diverso.

## 3. Verifica avversariale prima della vittoria (non facoltativa)

Prima di dichiarare l'obiettivo raggiunto, **un secondo passo tenta di smentirlo** —
stesso principio del banco avversariale del turno notturno (`night-shift/morning-gate.sh`): chi ha
costruito la soluzione è il peggior giudice della propria soluzione. In pratica:
- livello 1-2 (deterministico/numerico): fai girare la verifica un'altra volta, in
  condizioni leggermente diverse se possibile (dati diversi, cache pulita) — un passaggio
  che dipende da uno stato caldo non è un passaggio vero;
- livello 3-5 (verità ritardata/giudizio/umano): dichiara esplicitamente che la
  "vittoria" è provvisoria fino al riscontro vero — non chiudere il loop come se fosse
  definitivo quando non può esserlo ancora.

Se la verifica avversariale smentisce il risultato, è un tentativo fallito come gli
altri: registralo e continua (se il tetto non è esaurito) o fermati e dillo (se lo è).

## 4. Fine del loop

- **Vittoria**: obiettivo raggiunto E superata la verifica avversariale — chiudi il log
  in `loops/` con l'esito, riporta un riepilogo breve (non l'intero log) in `SAL.md` se
  la lezione del loop vale per il metodo, non solo per questo obiettivo specifico.
- **Tetto esaurito senza vittoria**: fermati, dillo chiaramente, e riporta cosa hai
  escluso (i tentativi falliti sono informazione, non solo un fallimento) — non
  continuare oltre N "perché quasi ci sono", il tetto è dichiarato per una ragione.

## 5. Cosa NON è questo comando

- Non è il turno notturno: qui c'è sempre un tetto di tentativi (ottimizzazione diurna
  iterativa); la notte non ne ha mai uno (commessa unica, lunga, guardia = review del
  mattino) — due contesti diversi, entrambe le regole sono giuste per il loro contesto
  (`docs/system.md`).
- Non sostituisce il banco avversariale del gate — quello giudica una PR già pronta;
  questo itera PRIMA di aprirla.


## Vedi anche

Quando il design richiede opzioni confrontate: skill `design-doc`.


## Vedi anche

Quando l'obiettivo è ancora vago: skill `brainstorming`.
