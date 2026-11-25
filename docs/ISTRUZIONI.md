---
repo: Trading-Short
software: [backtest.py, optimize.py, analyze_exit_2h.py, analyze_real_exits.py, analyze_entries.py, analyze_trades.py, analyze_v2.py, TEMA-ST-WT_PANIC_HUNTER_v3_2.pine, PANIC_HUNTER_SIGNALS.pine, tools/py-gate.sh]
aggiornato: 2026-11-25
---
# Istruzioni d'uso — Trading-Short
Nel repo non c'è un file di dipendenze: ogni script indica le sue.
## backtest.py
### Requisiti
Python 3, `yfinance`, `pandas`, `numpy`; rete (Yahoo Finance).
### Installazione
`pip install yfinance pandas numpy` — non verificato (pip non eseguito, rete vietata).
### Avvio
`python3 backtest.py`
### Uso
Backtest Python di PANIC HUNTER v3.5 su QQQ 1h (proxy NAS100), `period="2y"`; stampa a terminale.
### Verifica
Non verificato: richiede rete. Verifica statica: `bash tools/py-gate.sh`.
### Problemi noti
Non riproducibile (`period` dipende dal giorno); strategia diversa dal Pine (docs/LLM-GUIDA.md §5, D2).
## optimize.py
### Requisiti
Python 3, `yfinance`, `pandas`, `numpy`; rete.
### Installazione
`pip install yfinance pandas numpy` — non verificato (pip non eseguito).
### Avvio
`python3 optimize.py`
### Uso
Grid search dei parametri su NQ=F 1h, `period="2y"`; stampa i risultati.
### Verifica
Non verificato: richiede rete.
### Problemi noti
`sl_pct` inerte (righe 225-230, griglia riga 315; D1); `np.roll` con look-ahead (righe 116, 119; D8); `profit_factor=99.0` senza perdite (riga 264; D9).
## analyze_exit_2h.py
### Requisiti
Python 3, `yfinance`, `pandas`, `numpy`; rete.
### Installazione
`pip install yfinance pandas numpy` — non verificato (pip non eseguito).
### Avvio
`python3 analyze_exit_2h.py`
### Uso
Analisi delle uscite con entry su 4H e uscite su 2H, dati NQ=F; stampa a terminale.
### Verifica
Non verificato: richiede rete.
### Problemi noti
Il docstring dice 2H/4H, ma il download è `interval="1h"` (riga 43): verificare prima di usare i numeri.
## analyze_real_exits.py
### Requisiti
Python 3, `yfinance`, `pandas`, `numpy`; rete.
### Installazione
`pip install yfinance pandas numpy` — non verificato (pip non eseguito).
### Avvio
`python3 analyze_real_exits.py`
### Uso
Per ogni entry traccia le barre successive e cerca l'uscita migliore, su NQ=F (riga 89).
### Verifica
Non verificato: richiede rete.
### Problemi noti
Docstring 4H, download `interval="1h"`: stessa discrepanza di analyze_exit_2h.py.
## analyze_entries.py
### Requisiti
Python 3, `numpy`; nessuna rete.
### Installazione
`pip install numpy` — non verificato (numpy assente, pip non eseguito).
### Avvio
`python3 analyze_entries.py`
### Uso
Analizza i segnali di entrata; i dati sono la lista `trades = [...]` nel codice (fixture).
### Verifica
Non verificato: numpy assente.
### Problemi noti
Dati fissi nel codice: per nuovi trade va modificata la lista.
## analyze_trades.py
### Requisiti
Python 3, `pandas`; nessuna rete.
### Installazione
`pip install pandas` — non verificato (pandas assente, pip non eseguito).
### Avvio
`python3 analyze_trades.py`
### Uso
Legge la trade list di TradingView incollata nella stringa `data` (colonne separate da tab) e ne fa l'analisi.
### Verifica
Non verificato: pandas assente.
### Problemi noti
Il parsing si basa sul formato di esportazione TradingView: cambiarlo lo rompe.
## analyze_v2.py
### Requisiti
Python 3, `pandas`, `numpy`; nessuna rete.
### Installazione
`pip install pandas numpy` — non verificato (assenti, pip non eseguito).
### Avvio
`python3 analyze_v2.py`
### Uso
Analisi v2 senza margin call; i dati sono la lista `trades_raw` nel codice (fixture).
### Verifica
Non verificato: pandas e numpy assenti.
### Problemi noti
Dati fissi nel codice, come analyze_entries.py.
## TEMA-ST-WT_PANIC_HUNTER_v3_2.pine
### Requisiti
Account TradingView; Pine v6; nessuna rete dal repo.
### Installazione
Incollare il file nell'editor Pine di TradingView e salvarlo.
### Avvio
Aggiungere lo script al grafico NQ/NAS100 in TradingView.
### Uso
Strategia short sul panico di mercato (904 righe).
### Verifica
Non verificato: esegue solo in TradingView.
### Problemi noti
`default_qty_value=90` (riga 26) con short causa margin call (S1); logica diversa dai .py (D2).
## PANIC_HUNTER_SIGNALS.pine
### Requisiti
Account TradingView; Pine v6.
### Installazione
Incollare il file nell'editor Pine di TradingView e salvarlo.
### Avvio
Aggiungere lo script al grafico in TradingView.
### Uso
Solo segnali di ingresso, senza gestione posizione (525 righe).
### Verifica
Non verificato: esegue solo in TradingView.
### Problemi noti
Soglie e punteggio diversi dalla strategia TEMA (docs/LLM-GUIDA.md §5, D2).
## tools/py-gate.sh
### Requisiti
bash, python3; nessuna rete.
### Installazione
Nessuna.
### Avvio
`bash tools/py-gate.sh`
### Uso
Compila ogni .py tracciato. Exit 0 = tutti compilano; 1 = errore di sintassi; 2 = perimetro.
### Verifica
Eseguito 2026-11-25: «Sintassi python: tutti i .py compilano (7 file)», exit 0 (VERDE).
### Problemi noti
Controlla solo la sintassi, non la logica; lo esegue `.night-verify`.
