---
repo: Trading-Short
linguaggi: [Python, Pine Script, Shell]
stato: attivo (sviluppo)
aggiornato: 2026-11-26
---
# Scheda tecnica — Trading-Short

## Scopo
Strategia di trading short sul panico di mercato, in due forme divergenti: Pine (TradingView) e Python (backtest/ottimizzazione/analisi). Codice Pine e Python NON implementano esattamente la stessa strategia (soglie/punteggio/ingresso/uscite differenti); vedi docs/LLM-GUIDA.md §1 e §5.

## Architettura
- Radice: 7 script `.py` (backtest, optimize, 5 analisi) + 2 file `.pine` (TEMA 904 righe, SIGNALS 525 righe).
- `patterns/`: catalogo pattern/metodo (66 file .md), cross-repo.
- `docs/`: guida LLM, regole campo, registro errori, archivio superato, inventario.
- `tools/`: 11 script .sh di governance (py-gate, gas-gate, privacy-check, ...).
- `tests/`: test-errori.sh (lente sulle guardie citate nel registro errori).
- Git: clone shallow, ramo docs/g7-giro5-2026-11; no requirements.txt.

## Componenti
| Nome | Ruolo | File |
|------|-------|------|
| backtest.py | Backtest PANIC HUNTER su QQQ 1h | backtest.py |
| optimize.py | Grid search parametri su NQ=F 1h | optimize.py |
| analyze_entries.py / analyze_trades.py / analyze_v2.py | Analisi con fixture hardcoded (no rete) | rispettivi .py |
| analyze_exit_2h.py / analyze_real_exits.py | Analisi uscite (rete yfinance) | rispettivi .py |
| TEMA-ST-WT_PANIC_HUNTER_v3_2.pine | Strategie TradingView principale | TEMA-ST-WT_PANIC_HUNTER_v3_2.pine |
| PANIC_HUNTER_SIGNALS.pine | Segnali TradingView secondari | PANIC_HUNTER_SIGNALS.pine |
| py-gate.sh | Gate di sintassi .py | tools/py-gate.sh |
| test-errori.sh | Lente registro errori | tests/test-errori.sh |

## Dati e interfacce
- Dati: nessuna cache nel repo; i .py scaricano via yfinance da Yahoo Finance (QQQ / NQ=F, 1h, `period="2y"`).
- Interfacce: solo terminale (stampa/esportazione a stdout); Pine solo in TradingView.
- Analisi con fixture: analyze_entries/trades/v2 — nessun dato esterno.
- Segreti: nessun valore reale nel repo; variabili d'ambiente non usate (nessun `os.environ`/`getenv` trovato).

## Dipendenze
- Python 3: yfinance, pandas, numpy (non pinnati; nessun requirements.txt).
- Pine: TradingView (nessuna installazione locale).
- Shell: coreutils per i gate in tools/.
- Verifica statica: `bash tools/py-gate.sh` → exit 0 (7 file compilano, 2026-11-26).

## Configurazione
Nessuna variabile d'ambiente né file di configurazione con segreti. Parametri nel codice: `period="2y"` (backtest.py:321/340, optimize.py:297), `interval="1h"`, `st_factor=2.4`, `tema_period=28`, `panic=40`, `strong-bear=25` (backtest.py:150-151), `default_qty_value=90` (TEMA pine:26).

## Build e test
- `bash tools/py-gate.sh` → "Sintassi python: tutti i .py compilano (7 file)", exit 0 (eseguito 2026-11-26).
- `./.night-verify` → verifica pre-turno (non eseguito in questa sessione, non necessario).
- `python3 analyze_entries.py` / `analyze_trades.py` / `analyze_v2.py` → fixture, non eseguiti in questa sessione ("non verificato").
- `python3 backtest.py` / `optimize.py` / `analyze_exit_2h.py` / `analyze_real_exits.py` → richiedono rete yfinance, mai eseguiti ("non verificato").
- `tests/test-errori.sh` → non eseguito in questa sessione ("non verificato").
- Pine: nessun interprete fuori TradingView ("non verificato").

## Deploy
Nessuna pipeline CI/CD. Pine deployato manualmente in TradingView. Python: esecuzione manuale locale a terminale. GitHub origin; nessun push automatico.

## Rischi e debito tecnico
- D1: stop loss `sl_pct` inerte (sovrascritto dal trailing stop) — optimize.py:225-230, griglia :315.
- D2: Pine e Python diversa strategia (D2, LLM-GUIDA §5).
- D8: `np.roll` introduce look-ahead — optimize.py:116/119, oggi mascherato da `start=200`.
- D9: `profit_factor=99.0` quando nessuna perdita — optimize.py:264.
- D7: `resample('4h')` allinea alla mezzanotte del fuso, non alla sessione — backtest.py:70.
- S1: `default_qty_value=90` con short causa margin call — TEMA pine:26.
- Nessun requirements.txt; nessun test automatico sul progetto (solo py-gate sintattico).
- Numeri dei backtest non riproducibili (`period="2y"` relativo al giorno di lancio).
- privacy-check.sh degradato (manca `night-shift/repos.key`): il suo verde non vale.
- Clone shallow: storia git non accessibile.
