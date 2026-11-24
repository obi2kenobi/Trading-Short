# Trading-Short

Strategia di trading short sul panico di mercato, in due forme:
- **Pine** (TradingView): `TEMA-ST-WT_PANIC_HUNTER_v3_2.pine` e `PANIC_HUNTER_SIGNALS.pine`
- **Python** (backtest/ottimizzazione/analisi): `backtest.py`, `optimize.py`, `analyze_entries.py`, `analyze_exit_2h.py`, `analyze_real_exits.py`, `analyze_trades.py`, `analyze_v2.py`

Nota: il codice Pine e Python NON implementano esattamente la stessa strategia (soglie/punteggio/ingresso/uscite divergenti) — vedi `docs/LLM-GUIDA.md` §1 e §5.

## Requisiti
- Python 3 con `yfinance`, `pandas`, `numpy` (le analisi con fixture potrebbero non richiedere rete)
- Per il controllo sintattico: `bash tools/py-gate.sh`

## Installazione
```bash
git clone <repo> && cd Trading-Short-m016
pip install yfinance pandas numpy
```

## Uso
- Controllo sintassi dei .py: `bash tools/py-gate.sh`
- Backtest (richiede rete per `yfinance`): `python3 backtest.py`
- Ottimizzazione grid (richiede rete): `python3 optimize.py`
- Analisi (fixture hardcoded, niente rete): `python3 analyze_entries.py`, `python3 analyze_trades.py`, `python3 analyze_v2.py`
- Analisi uscite (rete): `python3 analyze_exit_2h.py`, `python3 analyze_real_exits.py`
- Verifica pre-turno: `./.night-verify`

## Struttura
- `patterns/`: catalogo pattern/metodo (65 file .md)
- `docs/`: guida LLM, campo, errori, archivio
- `tools/`: script di governance (py-gate, gas-gate, privacy-check, ...)
- `tests/`: `test-errori.sh` (lente per guardie del registro errori)
- `CLAUDE.md`, `DEBITI.md`: canone e debiti

## Verifica
`bash tools/py-gate.sh` → exit 0 se tutti i .py compilano.

## Limiti
Nessun requirements.txt; chiavi/segreti non sono presenti nel repo. I numeri dei backtest dipendono dal giorno di lancio (`period="2y"`) e non sono riproducibili. Le strategie Pine non sono eseguibili fuori TradingView.
