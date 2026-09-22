# Banco di parità Pine ↔ Python — entrate

Risponde a una domanda sola: **il Python spara sulle stesse barre del Pine?**
Finché la risposta è no, ogni numero prodotto da `backtest.py` e `optimize.py`
descrive una strategia diversa da quella che gira su TradingView (difetto D2 di
`docs/REVISIONE-2026-09-22.md`).

Ambito dichiarato: **solo le entrate**. Le uscite, i riempimenti all'open della barra
successiva e il sizing al 90% con i margin call vogliono la replica del broker
emulator di TradingView: è il secondo giro, non questo.

## Cosa serve da TradingView

Tre export dello **stesso** simbolo e della **stessa** esecuzione, altrimenti il
confronto non è attribuibile:

| # | Cosa | Come | Obbligatorio |
|---|---|---|---|
| 1 | Barre del TF operativo (4H) | grafico 4H → ⋮ → *Export chart data* | sì |
| 2 | Lista trade | pannello Strategy Tester → *List of Trades* → esporta | sì |
| 3 | Barre **giornaliere** | stesso simbolo su grafico D → *Export chart data* | sì, in pratica |

Il terzo export sembra facoltativo e non lo è. Il filtro bear market del Pine legge il
timeframe giornaliero (`request.security(syminfo.tickerid, "D", ...)`,
`TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:19,107-108`) e il TEMA200 giornaliero **vuole 597
barre daily di riscaldamento** prima di produrre il primo valore — misurato, non
stimato (`parity/selftest.py`). Senza quelle barre il filtro è `na`, nessuna entrata
può scattare e il banco lo dice invece di restituire un verde vuoto.

Quindi l'export giornaliero deve partire **almeno 600 giorni di borsa prima** (≈ 2 anni
e mezzo) dell'inizio del periodo che vuoi confrontare.

Impostazioni del Pine: lascia i **default**. Con `Enable Panic Score Boost` (`:82`) e
`Enable Footprint Exit Warning` (`:84`) a `false` — che sono i default — il footprint
non tocca la logica di trading, e l'assenza di `request.footprint()` qui non è
un'approssimazione. Se li accendi, il banco non è più valido: il footprint vuole dati
tick che fuori da TradingView non esistono.

## Come si lancia

```bash
pip install -r parity/requirements.txt

python3 parity/compare.py \
    --bars   export_4h.csv \
    --trades lista_trade.csv \
    --daily  export_daily.csv
```

Esiti: `0` parità, `1` divergenza o input insufficiente. Il verdetto è sempre
sull'ultima riga.

Ogni barra divergente esce con la scomposizione del panic score su quella barra —
quali addendi erano accesi, il punteggio contro la soglia, lo stato di Supertrend e del
filtro bear. Il punto non è sapere **che** diverge: è sapere **quale** componente la
causa.

## I banchi (girano senza export)

```bash
python3 parity/selftest.py        # le primitive ta.* contro oracoli indipendenti
python3 parity/selftest_banco.py  # il comparatore sa diventare rosso quando deve
python3 parity/diagnosi_porting.py # di quanto diverge backtest.py, a parità di barre
```

`selftest.py` confronta ogni `ta.*` con un ciclo Python scritto dalla definizione o con
numpy — mai con un'altra chiamata a se stessa. Misura anche quanto le primitive di
pandas usate oggi in `backtest.py` si scostano da quelle di Pine:

```
ATR(14)  rolling.mean vs rma  : scarto medio 4.74%  max 18.19%
RSI(14)  rolling.mean vs rma  : scarto medio 6.65 punti  max 24.32
TEMA(200): prima barra valida Pine 597, pandas 0
```

Un RSI che sbaglia fino a 24 punti contro soglie a 35 e 65 non è un dettaglio di
arrotondamento: è un altro segnale.

`selftest_banco.py` fabbrica export finti e pretende tre esiti: coerente → VERDE,
un'entrata tolta → 1 divergenza, un'entrata spostata di una barra → 2 divergenze. Un
banco che non può diventare rosso non verifica niente.

`diagnosi_porting.py` fa girare la logica di `backtest.py` e quella portata dal Pine
sulle **stesse** barre sintetiche, così ogni differenza è imputabile al codice:

```
segnali del Pine (porting fedele)     27
segnali di backtest.py                17
solo Pine (backtest.py li perde)      14
solo backtest.py (fantasma)            4
accordo sulle entrate: 48% dei segnali del Pine
panic score medio: Pine 13.0 · backtest.py 6.4
```

## Cosa questi banchi NON provano

L'oracolo dei banchi sintetici è il porting stesso: provano l'impianto (lettura,
allineamento, maschera in-posizione, verdetto), **non** che il porting sia fedele al
Pine. Quello lo può dire solo `compare.py` con un export vero. Finché quell'export non
arriva, il 48% qui sopra misura che i due codici sono diversi — non quale dei due ha
ragione.

## Mappa dei file

| File | Responsabilità |
|---|---|
| `pine_ta.py` | primitive `ta.*` con la semantica di TradingView (innesco SMA, rma di Wilder) |
| `pine_entry.py` | la condizione `shortOK` del Pine (`:403`) e le sue componenti |
| `tv_export.py` | lettura degli export TradingView, mappatura colonne dichiarata |
| `compare.py` | il verdetto di parità |
| `selftest.py` | banco delle primitive |
| `selftest_banco.py` | banco del comparatore |
| `diagnosi_porting.py` | divergenza del porting attuale |
