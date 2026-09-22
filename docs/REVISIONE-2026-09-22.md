# Revisione dev-critic — Trading-Short

**Data:** 2026-09-22 · **Target:** intero repo (2 file Pine + 7 file Python) · **Metodo:** skill `dev-critic` di AI_Programmer (lettura critica integrale + dogfooding reale, §1) con lente sicurezza (§2bis) e lente matematico-finanziaria (§2ter) applicate entrambe.

**Cosa ho eseguito davvero** (non solo letto): `analyze_entries.py`, `backtest.py`, `optimize.py` e due sonde scritte per questa revisione. **Cosa NON ho potuto eseguire:** i due `.pine` — non esiste un interprete Pine fuori da TradingView. Ogni affermazione sul Pine qui sotto viene da lettura del sorgente, non da esecuzione: è dichiarata come tale.

---

## Sintesi in tre righe

Il repo contiene due sistemi che si presume siano lo stesso — la strategia Pine e il backtest/optimizer Python — e **non lo sono**: divergono su soglia di panic, composizione del punteggio, prezzo di ingresso e su tre dei cinque meccanismi di uscita. Le decisioni registrate nella storia git (`fix: restore TP 1.5%`, `fix: restore original SL at 2.0%`) sono state prese con l'optimizer Python, quindi **misurano una strategia diversa da quella che gira**. In più, misurato: lo stop loss, uno dei sei parametri ottimizzati, **non ha alcun effetto** sul risultato.

---

## 1. Bug confermati

### D1 — Lo stop loss è inerte: un SL al 50% dà lo stesso risultato di uno all'1,5% 🔴 CRITICO
`optimize.py:315` (griglia `sl_pct`), causa in `optimize.py:225-230`.

Lo stop iniziale viene sovrascritto dal trailing stop alla **prima barra dopo l'entry**, prima di qualunque controllo di uscita: `new_trail = lowest + atr14[i] * trail_atr_mult * trail_mult` e `if new_trail < stop_price: stop_price = new_trail`. Su NQ 4H la distanza di trailing è di circa 0,5-0,9%, cioè più stretta di ogni valore della griglia. Lo stop iniziale non viene quindi mai raggiunto.

Misurato sulla configurazione migliore del grid (TP=0.8x, Trail=1.0x, Vol=2.0x, Panic=35, RSI=35), variando **solo** `sl_pct`:

| SL | trade | PF | P&L | uscite SL | max loss |
|---|---|---|---|---|---|
| 0,5% | 103 | 1,604 | +16,07% | 54 | −1,78% |
| 1,0% | 103 | 1,740 | +19,45% | 52 | −1,78% |
| 1,5% | 103 | 1,735 | +19,37% | 52 | −1,78% |
| 2,0% | 103 | 1,735 | +19,37% | 52 | −1,78% |
| 3,0% | 103 | 1,735 | +19,37% | 52 | −1,78% |
| **50,0%** | **103** | **1,735** | **+19,37%** | **52** | **−1,78%** |

**Perché conta:** è esattamente il difetto della lente §2ter — un passo che assorbe (il trailing) rende indistinguibili un parametro che funziona e uno che non esiste. Il commit `b54bf82 fix: restore original SL at 2.0% — 1.2% was too tight` è una decisione presa su una misura che, nello strumento usato per prenderla, non poteva variare. Inoltre 4 dei 5 valori di `sl_pct` moltiplicano per 5 il costo del grid search senza produrre informazione: 5.760 combinazioni di cui ~4.600 ridondanti.

**Suggerimento:** far partire il trailing solo dopo che il trade è in profitto (o dopo N barre), oppure togliere `sl_pct` dalla griglia e dichiarare che lo stop è il trailing. **Trade-off:** ritardare il trailing allarga la perdita massima; toglierlo dalla griglia rende onesto il report ma non migliora la strategia.

### D2 — Pine e Python non implementano la stessa strategia 🔴 CRITICO

| | Pine (`TEMA-ST-WT_PANIC_HUNTER_v3_2.pine`) | Python (`backtest.py` / `optimize.py`) |
|---|---|---|
| Soglia panic normale | 35 (`:292`) | **40** (`backtest.py:150`) |
| Soglia in Strong Bear | 20 (`:292`) | **25** (`backtest.py:151`) |
| Punteggio: gap significativo | +10 (`:273`) | **assente** |
| Punteggio: breakout strutturale | +15 (`:276`) | **assente** |
| Punteggio: bonus footprint | fino a +N (`:289`) | **assente** |
| Prezzo di ingresso | open della barra **successiva** (`strategy.entry`, `:408`) | **close della barra del segnale** (`backtest.py:188`) |
| Uscita per timeout (20 barre) | sì (`:515-521`) | **assente** |
| Uscita per punteggio ponderato WT/ST/TEMA/RSI/FP | sì (`:484-487`, soglia `:485-487`) | **assente** |
| Uscita emergenza RSI | soglia adattiva al regime (`:490-491`) | fissa a 65 (`backtest.py:249`) |

Il punteggio massimo in Pine supera 115, in Python è 90 — e la soglia Python è **più alta** di 5 punti. I due errori spingono nella stessa direzione: il Python genera molte meno entrate. Riscontro: la trade list TradingView in `analyze_trades.py` ha 94 trade; `backtest.py` ne trova 19-20 su periodo comparabile.

**Perché conta:** ogni numero prodotto da `optimize.py` descrive una strategia che non è quella deployata. I parametri "ottimali" riportati nella storia git sono stati trasferiti nel `.pine` sulla base di questa misura.

**Suggerimento:** una sola fonte per le regole di ingresso/uscita, e un test di parità che confronta la lista trade Python con quella esportata da TradingView sullo stesso strumento e periodo, con una tolleranza dichiarata. Finché quel test non esiste, l'optimizer non dovrebbe produrre raccomandazioni. **Trade-off:** è lavoro vero (giorni, non ore) e richiede un export TradingView di riferimento congelato nel repo.

### D3 — Gli scenari "se catturassimo il 50% del MFE" usano informazione che al momento della decisione non esiste 🔴 CRITICO
`analyze_entries.py:160-175`, conclusione a `:238`.

Il MFE (massima escursione favorevole) è noto **solo a trade chiuso**. Lo scenario `profit = t_mfe * capture` presuppone una regola di uscita che conosce in anticipo il minimo futuro: nessun TP causale può ottenerlo. Il ramo perdente peggiora la cosa — `scenario_pnl.append(t_mae * 0.7)` (`:171`) riduce arbitrariamente del 30% ogni perdita, senza nessuna giustificazione nel codice o nel commento.

Entrambe le approssimazioni spingono verso l'ottimismo, e la conclusione stampata (`:238`, "Se il TP cattura ≥50% del MFE → strategia profittevole") è il punto di partenza del commit `cf2d9ae feat: implement Runner exit strategy from real data analysis`.

**Suggerimento:** sostituire lo scenario con una regola di uscita **causale** simulata barra per barra sui dati reali (trailing a X·ATR, uscita a tempo, TP a Y·ATR) e misurare quella. **Trade-off:** i numeri che ne escono saranno molto peggiori di quelli attuali.

### D4 — TP controllato prima dello stop nella stessa barra 🟡 latente, impatto misurato nullo su questo dataset
`backtest.py:228` prima di `:239` · `optimize.py:232` prima di `:240`.

Se una barra ha sia `Low <= tp_price` sia `High >= stop_price`, il codice contabilizza **sempre** il take profit. Il dato intrabar non dice quale sia stato toccato per primo: è l'ipotesi ottimistica. TradingView, sulla stessa ambiguità, assume il caso sfavorevole — quindi l'errore allarga la divergenza D2.

**Misurato** (sonda su QQQ 4H, 2 anni, TP=1.5x): 19 uscite, **0 barre ambigue**, delta P&L fra "TP prima" e "SL prima" pari a **+0,00 punti**. Il difetto è reale nella logica ma non ha effetto su questo campione — lo segnalo come latente, non come causa dei risultati attuali. Su griglie con TP più stretti e trailing più largo l'ambiguità cresce.

**Suggerimento:** in caso di ambiguità contabilizzare lo stop (prudenziale) e contare quante volte succede, stampandolo nel report.

### D5 — Il trailing stop usa il minimo della barra corrente prima di controllare il massimo della stessa barra 🟠 ALTO
`backtest.py:213` (poi `:239`) · `optimize.py:223` (poi `:240`).

`lowest_since_entry = min(lowest_since_entry, df['Low'].iloc[i])` viene eseguito **prima** del confronto `df['High'].iloc[i] >= stop_price`. La sequenza è impossibile: non si può conoscere il minimo di una barra prima di sapere se il massimo è arrivato prima. Lo stop della barra *i* viene stretto con un dato della barra *i* stessa.

**Suggerimento:** aggiornare il trailing con il minimo **fino alla barra precedente** (`i-1`) e confrontare solo dopo. **Trade-off:** allenta il trailing di una barra; il P&L riportato peggiorerà.

### D6 — Gli indicatori Python non sono quelli di Pine 🟠 ALTO
`backtest.py:86-89`, `:110-114` · `optimize.py:22-26`, `:70-75`.

`ta.atr` e `ta.rsi` di Pine usano lo smoothing di Wilder (RMA, α = 1/n). Il Python usa la media mobile semplice (`tr.rolling(14).mean()`, `delta.where(...).rolling(period).mean()`). Sono curve diverse, con reattività diversa: contribuiscono a D2 anche a parità di regole. Il TEMA e il WaveTrend, invece, sono corretti (`ewm(adjust=False)` ↔ `ta.ema`).

**Suggerimento:** `ewm(alpha=1/n, adjust=False)` per entrambi.

### D7 — Le barre "4H" non sono barre 4H 🟠 ALTO
`backtest.py:67-76` · `optimize.py:269-273` · `analyze_exit_2h.py:56-66`.

`df.resample('4h')` allinea i bucket sulla mezzanotte del fuso dell'indice, non sulla sessione. **Misurato** su QQQ 1h → 4h: i bucket contengono 2, 3 o 4 barre orarie (1 / 499 / 493 casi), e l'ora di apertura assume **cinque** valori diversi (7, 8, 11, 12, 15) perché l'ora legale sposta l'indice. Nessuna di queste barre coincide con le 4H di TradingView, su cui la strategia è tarata.

**Suggerimento:** `resample('4h', origin=...)` ancorato all'apertura di sessione, oppure scaricare direttamente le barre 4H. **Trade-off:** cambia il dataset e quindi tutti i risultati storici già pubblicati.

### D8 — `np.roll` fa entrare l'ultima barra del dataset nella prima 🟢 BASSO
`optimize.py:116` e `:119`.

`np.roll(rsi, 1)` porta `rsi[-1]` in posizione 0: la barra 0 viene confrontata con l'**ultima** del campione. Stessa cosa per `consec_red` sulle barre 0 e 1. È look-ahead vero, ma le prime 200 barre sono scartate (`start = 200`), quindi oggi non ha effetto. Resta una trappola per chiunque abbassi `start`.

**Suggerimento:** `pd.Series(...).shift(1)`, che riempie con NaN.

### D9 — `profit_factor = 99.0` quando non ci sono perdite, e la classifica lo premia
`optimize.py:264`, usato per l'ordinamento a `:361` e `:399`.

Un sentinella numerico entra nella stessa colonna dei valori reali e vince ogni ordinamento per profit factor. Sul dataset attuale nessuna configurazione senza perdite supera i 15 trade, quindi non emerge — ma è un difetto strutturale: la classifica non distingue "infinito" da "molto buono".

**Suggerimento:** `np.inf` o `None`, ed escludere esplicitamente quelle righe dalla classifica dichiarandolo.

---

## 2. Sicurezza e affidabilità

### S1 — `default_qty_value = 90` con posizione short è la causa dei margin call
`TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:25-27` (`strategy.percent_of_equity`, 90).

La trade list reale in `analyze_trades.py` contiene decine di righe `Margin call` intercalate ai trade normali: TradingView liquida parzialmente perché la posizione supera il margine. Non è un evento di mercato, è la configurazione di sizing.

**Perché conta:** quei margin call sono perdite vere nel conteggio, e `analyze_v2.py` — il file su cui poggiano le conclusioni successive — è dichiaratamente "senza margin call" e li ha **rimossi a mano**. Il dataset su cui si è deciso è quindi il dataset con una parte delle perdite tolta.

**Suggerimento:** portare il sizing a un livello sostenibile (rischio per trade, non percentuale di equity) e rieseguire il backtest TradingView da zero. **Trade-off:** tutti i P&L storici del repo diventano non confrontabili. È una scelta di design con impatto: non la faccio senza il tuo sì.

### S2 — `request.security` senza `lookahead` esplicito né offset
`TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:19`, `:107`, `:108`.

`close_htf`, `tema200_htf`, `ema50_htf` leggono il timeframe giornaliero senza `[1]` e senza `barmerge.lookahead_*` dichiarato. Il default (`lookahead_off`) evita il look-ahead sullo storico, ma **in tempo reale** il valore della candela daily in formazione cambia a ogni tick: il filtro `isBearMarket` può accendersi e spegnersi durante la giornata, con segnali che compaiono e scompaiono. Backtest e live divergono.

Non ho potuto verificarlo eseguendo — serve TradingView. È una lettura del sorgente.

**Suggerimento:** `request.security(syminfo.tickerid, tf_filter, close[1], lookahead=barmerge.lookahead_on)`, forma canonica anti-repaint. **Trade-off:** il filtro reagisce un giorno più tardi.

### S3 — La freccia di segnale sul grafico non rispetta la condizione dell'entry
`TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:561` vs `:407-408` (condizione a `:403`).

L'entry richiede `barstate.isconfirmed`; la `plotshape` no. Sulla barra in formazione la freccia appare e sparisce senza che nessun ordine venga mandato. Lo stesso vale per la label a `:594`, che stampa `close` come prezzo di entrata mentre l'ordine reale viene eseguito all'open della barra dopo.

**Perché conta:** è probabilmente l'origine dell'assunzione sbagliata in D2 (Python entra a `close` della barra del segnale).

### S4 — Nessun segreto trovato, e il gate lo dichiara
Ho cercato credenziali nel working tree e nella storia git (`--diff-filter=A` su tutti i rami, pattern `api_key|secret|password|token|BEGIN`): **nessun match** nei sorgenti del progetto. `tools/privacy-check.sh` (lente dello standard appena installata) si dichiara **degradato**: manca `night-shift/repos.key`, quindi non ha controllato nulla. Il verdetto di pulizia sopra è il mio, non il suo.

---

## 3. Gap di processo (emersi solo eseguendo)

### P1 — Il repo non dichiara le sue dipendenze
Nessun `requirements.txt`, `pyproject.toml`, `setup.py`. Per eseguire ho dovuto installare `yfinance` a mano. Ho ricevuto `yfinance 1.7.0`, `pandas 3.0.6`, `numpy 2.4.6` — versioni molto più recenti di quelle su cui il codice è stato scritto. Gli script girano, ma nessuno può sapere se i numeri di oggi sono quelli di allora.

### P2 — I risultati non sono riproducibili: il dataset cambia a ogni esecuzione
`backtest.py:321`, `optimize.py:297`, e tutti gli `analyze_*` che scaricano: `period="2y"` è relativo al **giorno in cui si lancia**. **Misurato oggi:** `backtest.py` copre 2024-09-23 → 2026-09-21. Le trade list congelate negli `analyze_*.py` partono da **2023-11-10**: il backtest non può nemmeno raggiungere il periodo che quelle analisi descrivono (Yahoo limita il dato orario a 730 giorni). Nessuna cache, nessun file di dati nel repo.

### P3 — Le fixture hardcoded non hanno provenienza, e non concordano fra loro
`analyze_entries.py:5-99`, `analyze_v2.py:5-...`, `analyze_trades.py:5-...`, `analyze_real_exits.py:15-...`.

Quattro liste di trade scritte a mano nel sorgente, senza indicare da quale export TradingView, quale strumento, quale configurazione, quale data. **Non coincidono:** lo stesso trade — identificato dalla terna identica in entrambi i file (segnale `EMERGENCY`, P&L −1,30%, MFE 0,00%, MAE −1,36%) — vale **−1209,51 USD** in `analyze_trades.py:7` e **−1150,03 USD** in `analyze_v2.py:6`. Due numeri per lo stesso trade; `analyze_trades.py` non riporta le date, quindi l'abbinamento è per contenuto, non per chiave. Uno dei due è sbagliato e non c'è modo di sapere quale.

Il pattern dello standard è `fixture-provenienza` (`patterns/fixture-provenienza.md`) e la lente `tools/fixture-provenienza.sh` è ora installata nel repo.

### P4 — L'uscita di emergenza non scatta mai
Misurato: in **tutte** le esecuzioni di `backtest.py` (5 valori di TP, QQQ 2 anni) la riga `Exit Emergency` è `0 (0%)`. TP e stop arrivano sempre prima. Uno dei tre meccanismi di uscita del backtest è codice che non viene mai eseguito, e nessun output lo segnalava.

### P5 — Il grid search non ha né out-of-sample né costi
`optimize.py:313-322`: 5.760 combinazioni su un solo campione, il migliore scelto per profit factor su ~100 trade. Nessuna divisione train/test, nessun walk-forward, nessuna commissione, nessuno slippage, riempimenti a prezzo esatto su TP e stop. Su una strategia che shorta il panico — dove gli stop sono proprio i momenti in cui il book si allarga — è l'ipotesi meno realistica possibile. Il Pine dichiara `commission_value = 0.01` (0,01%), il Python nulla.

### P6 — Nessun test, nessun `__main__`, nessun argomento
Tutti gli script eseguono al momento dell'import (`backtest.py:317` in poi, `optimize.py:288` in poi). La mia sonda, importando `backtest`, ha scaricato QQQ e stampato l'intero backtest come effetto collaterale. Zero test nel repo. Ticker, periodi e griglie sono costanti nel sorgente.

### P7 — Il codice contraddice la propria intestazione
`TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:3-10` annuncia "partial exits", "v3.3: sistema a 2 TP", "v3.4: TP1 0.3%/40%, TP2 1.2%/60% + Breakeven dopo TP1", "v3.5: TP1 Rebound Close". **Niente di tutto questo esiste nel codice:** c'è una sola `strategy.exit` con un solo `limit` (`:528`), nessun `qty_percent`, nessun breakeven. Restano solo un input chiamato `tp1_perc_input` (`:55`) e una cella di dashboard etichettata "TP1/TP2" (`:853`) che descrive un sistema assente.

Quattro numeri di versione diversi per lo stesso file: nome file `v3_2`, `@title` v3.4, `@version` 3.5, `strategy()` v3.5. Il file `PANIC_HUNTER_SIGNALS.pine` dichiara `@version 4.0` pur condividendo la stessa logica di ingresso (`SIGNALS:307`, identica a `:403` della strategia). Pattern `versione-sugli-artefatti`.

---

## 4. Debito tecnico non tracciato

- `backtest.py:20` — `atr` calcolato da max/min e immediatamente sovrascritto quattro righe dopo. Codice morto.
- `backtest.py:89` — `atr10` calcolato e mai usato.
- `backtest.py:102` / `optimize.py:92-94` — `is_tema_falling` e `tema_slope_ma` calcolati e mai usati in nessuna condizione. Nel Pine `isTemaFalling` (`:340`) esiste solo per colorare la dashboard (`:754`): un filtro che non filtra.
- `optimize.py:307` — `for st_factor, tema_period in [(2.4, 28)]` è un ciclo su un solo elemento: impalcatura per una ricerca su quei due parametri, mai fatta.
- `optimize.py:11` — `warnings.filterwarnings('ignore')` globale. Con pandas 3 e numpy 2 nasconde deprecazioni che riguardano proprio le operazioni usate qui (`.iloc` su Series, divisioni con NaN). Pattern `scarto-mai-silenzioso`.
- `optimize.py:352` — `exit()` invece di `sys.exit()`.
- `TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:221-224` — `fpCVD` è una somma cumulativa mai azzerata: cresce senza limite per tutta la durata del grafico. Il confronto con la sua SMA a 5 (`:224`) resta sensato, ma il livello assoluto non significa nulla.
- Nessun `.gitignore` prima di oggi; nessun README, nessun file che dichiari cosa fa il progetto e su quale strumento gira.

---

## 5. Idee non ancora considerate — ordinate per costo/rischio/reversibilità

Proposte, non implementate (dev-critic §3).

1. **Test di parità Pine ↔ Python.** Un export TradingView congelato nel repo e un confronto trade-per-trade con tolleranza dichiarata. *Costo medio, rischio basso, reversibile.* È la precondizione di ogni altra cosa: senza, D2 si riforma da sola. Se parte, il passo naturale è `/design-doc` (ci sono già 2+ approcci: riscrivere il Python sul Pine, o generare entrambi da una specifica unica).
2. **Dataset congelato + costi di transazione.** Salvare le barre in un parquet nel repo e aggiungere commissione e slippage al backtest. *Costo basso, rischio basso, reversibile.* Chiude P2 e metà di P5 in poche ore.
3. **Walk-forward al posto del grid search singolo.** Ottimizzare su finestra mobile, misurare fuori campione. *Costo medio, rischio basso, reversibile.* Senza, ogni numero dell'optimizer è in-sample.
4. **Sizing basato sul rischio per trade.** Chiude S1 alla radice. *Costo basso, rischio ALTO in senso finanziario, reversibile ma invalida tutto lo storico.* È tua la decisione.
5. **Sostituire lo scenario MFE con una regola di uscita causale.** Chiude D3. *Costo medio, rischio basso.* L'idea è ancora vaga su quale famiglia di regole provare: il passo naturale è `/brainstorming`, non codice.

---

## Cosa NON ho fatto

Nessuna riga di codice del progetto è stata modificata: questa è una revisione, non una correzione (dev-critic §3). Le uniche scritture sono i file dello standard AI_Programmer e questo documento.

Il progetto non ha un diario vivo (`SAL.md`, `DEBITI.md` del progetto): le voci della §4 andrebbero scritte in `DEBITI.md`, ora presente nel repo, invece di restare qui.
