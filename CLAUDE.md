# CLAUDE.md — Trading-Short (sintesi operativa, ≤100 righe)

## Scopo
Strategia di trading short sul panico di mercato, due forme: Pine (TradingView) e Python (backtest/ottimizzazione/analisi). Il codice Pine e Python NON implementano esattamente la stessa strategia (soglie/punteggio/ingresso/uscite divergenti) — vedi docs/LLM-GUIDA.md.

## Struttura
- Radice: `backtest.py`, `optimize.py`, `analyze_entries.py`, `analyze_exit_2h.py`, `analyze_real_exits.py`, `analyze_trades.py`, `analyze_v2.py` (7 .py)
- Pine: `TEMA-ST-WT_PANIC_HUNTER_v3_2.pine` (904 righe), `PANIC_HUNTER_SIGNALS.pine` (525 righe)
- `patterns/`: catalogo pattern/metodo (66 file .md)
- `docs/`: LLM-GUIDA.md, campo/, errori/, archivio/, ngiri-paralleli.md, _inventario.tsv, _guida-lista.txt, _revisione.tsv
- `tools/`: py-gate.sh, gas-gate.sh, privacy-check.sh, debiti-riapertura.sh e altri (11 script .sh)
- `tests/`: test-errori.sh
- `DEBITI.md`: debiti aperti

## Comandi di build/test
- `bash tools/py-gate.sh` — controllo sintassi .py (exit 0 = OK)
- `./.night-verify` — verifica pre-turno
- `python3 analyze_entries.py` / `analyze_trades.py` / `analyze_v2.py` — analisi con fixture, niente rete
- `python3 backtest.py` / `optimize.py` / `analyze_exit_2h.py` / `analyze_real_exits.py` — richiedono rete (yfinance)
- Esito NON verificato in questa sessione: non ho eseguito py-gate né gli script (rete vietata). Comando di verifica: `bash tools/py-gate.sh`.

## Convenzioni
- Codice semplice, spiegazioni, ogni passo loggato; ogni salto dichiarato.
- I confini si dichiarano prima di iniziare; le domande prima del codice quando c'è ambiguità di dominio.
- Il debito si brucia alla riapertura: conta aperti, risolvibili PRIMA del lavoro nuovo.
- Comunicazione: risposte brevi in italiano, con prove e percorsi.

## Cosa non toccare
- Codice applicativo (.py, .pine): fuori perimetro per questo giro.
- File in docs/archivio/ e docs/errori/: non riscrivere storico.
- Segreti: mai committare; in .env.example solo segnaposto.
- Canoni importati (DEBITI.md, docs/campo/README.md, docs/ngiri-paralleli.md): importati, non rielaborare in questo giro.

## Segreti
Nessuna chiave reale nel repo. Se ne aggiunge uno: segnaposto in `.env.example`, mai valori.

## Rimandi
- Guida LLM completa: docs/LLM-GUIDA.md
- Canone/metodo completo: docs/REGOLE-CLAUDE-originale.md (copia originale 298 righe)
