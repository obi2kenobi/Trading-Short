# 2026-09-22 — onboarding AI_Programmer + dev-critic su Trading-Short
**Autore**: sessione cloud Claude Code (richiesta di Luca) — repo `obi2kenobi/Trading-Short`, PR #57

## Cosa ho usato
- **`tools/sync-repo.sh --standard`**: NON RAGGIUNGIBILE dal cloud (nessuna `gh` CLI). Il blocco alle righe 15-21 dello script lo dichiara e dice cosa fare — ho replicato a mano la lista ITEM + `copia-hook.sh` + `.night-verify`. **Ha funzionato perché il blocco c'era**: senza, la sessione sarebbe morta sul comando insegnato in `docs/benvenuto-collaboratori.md`.
- **`tools/garante-standard.sh`**: silenzio = a standard. Verifica dall'interno, un comando.
- **`tools/copia-hook.sh`**: ha derivato 3 hook da `settings.json` + seminato `.gitignore` coi residui. Zero liste a mano.
- **skill `dev-critic`**: §0 (chiedi il target) → ho chiesto invece di indovinare su un repo eterogeneo Pine+Python; §1 fase 2 (dogfooding) → è la fase che ha prodotto i 3 finding veri; §2ter (misura PRIMA del passo che assorbe) → ha trovato il difetto principale; §3 (non correggere durante l'analisi) → rispettata.
- **`tools/cita-verifica.sh`**: OK su 40+ citazioni `file:riga` del report. La lente ha girato sul mio output, non solo sul codice altrui.
- **`tools/privacy-check.sh`**: GATE DEGRADATO dichiarato (manca `night-shift/repos.key`). Un gate che dice di non aver controllato vale più di un verde bugiardo.
- **hook `pattern-reminder-hook.sh`**: ha sparato su `segreto-come-impronta` quando ho lanciato la lente sicurezza. Pertinente, non rumore.
- **`patterns/`**: usati come vocabolario nel report — `fixture-provenienza`, `soglia-con-provenienza`, `scarto-mai-silenzioso`, `versione-sugli-artefatti`, `citazione-non-presidio`.

## Cosa ho improvvisato
- **Due sonde di misura scritte da zero** (`scratchpad/probe.py`, `probe2.py`) per non *assumere* due difetti letti nel codice. Esito opposto fra le due: la sonda sull'ordine TP/SL ha misurato **impatto zero** (0 barre ambigue su 19 uscite) e il finding è sceso da CRITICO a latente; la sonda sulla sensibilità dello stop ha misurato che **un SL al 50% dà lo stesso risultato di uno all'1,5%** ed è diventato il finding principale. Senza le sonde avrei riportato due bug con la stessa severità, e mi sarei sbagliato su entrambe.
- **Lettura dell'hub come fonte di verità operativa**: nessun tool diceva "da cloud fai così", l'ho ricavato leggendo l'header di `sync-repo.sh`. Ha funzionato solo perché quel commento è scritto.
- **Sostituto al `banco-sintetico`**: §2ter propone un banco su dati sintetici; qui il target è un backtest su dati di mercato reali e il banco naturale era una sonda su dati veri con un parametro fatto variare oltre il suo intervallo dichiarato (SL fino al 50%, fuori griglia). È lo stesso principio, altro materiale.

## Cosa ha retto / ostacolato
**Ha retto:**
- `dev-critic` §1 fase 2: i 3 finding misurati vengono **tutti** dall'esecuzione, nessuno dalla lettura. La lettura da sola aveva prodotto un falso positivo (credevo `grpVisual` fosse usato prima della dichiarazione a `TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:44` — era un artefatto del mio `sed -n '1,45p;100,120p'` che concatena due intervalli). Verificato prima di scriverlo.
- `dev-critic` §2ter: la frase "quel passo esiste per nascondere il rumore, non l'errore" ha mappato 1:1 su un dominio che con la contabilità non c'entra niente — il trailing stop assorbiva il parametro `sl_pct` esattamente come un plug assorbe un residuo. **La lente è più generale di come è scritta.**
- Le regole di `CLAUDE.md` "chiedi, non indovinare" e "ripeti la richiesta": la domanda sul `CLAUDE.md` da sovrascrivere e sull'ampiezza dell'installazione ha evitato 137 file scritti sull'assunzione sbagliata.

**Ha ostacolato:**
- Niente attrito vero. Unico costo: `sync-repo.sh --standard` non è eseguibile da qui, quindi la replica a mano della lista ITEM va tenuta allineata a occhio con lo script — se domani qualcuno aggiunge un ITEM, il percorso cloud non lo sa.

## Proposta al canone
1. **`sync-repo.sh --from-here <dir>`** — un modo per portare a standard una directory locale **già clonata**, senza `gh`, senza PR. Oggi l'unico percorso cloud è "replica a mano la lista", e la lista vive dentro un `for ITEM in ...` che nessuno può riusare. Il rischio è concreto: la stessa divergenza silenziosa che `sync-repo.sh` è nato per chiudere (F2) si riapre sul percorso cloud. Costo basso (estrarre la lista in `tools/.standard-items` e farla leggere da entrambi i rami), rischio basso, reversibile.
2. **`dev-critic` §2ter: generalizzare il titolo.** Si chiama "lente matematico-finanziaria … contabilità" e cita solo invarianti contabili. Qui ha trovato il difetto centrale di un **backtest di trading**, dominio mai nominato. Basta una riga di esempi (`trailing stop che assorbe lo stop iniziale`, `passo di normalizzazione che assorbe un parametro`) perché chi arriva su un target non contabile riconosca che la lente lo riguarda.
3. **Un pattern nuovo: `parametro-che-non-muove`.** Prima di riportare che un parametro è "ottimale", farlo variare **oltre l'intervallo dichiarato** e verificare che il risultato cambi davvero. Un parametro inerte è indistinguibile da uno ben tarato se lo si guarda solo dentro la sua griglia — ed è così che è passato inosservato per 7 commit di tuning. Provenienza: questa sessione, `optimize.py:315`, misurato.
