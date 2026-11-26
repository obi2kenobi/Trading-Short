# LLM-GUIDA — Trading-Short

Guida per un LLM che deve sviluppare il progetto. Generata dal mandato G7 (2026-11-22).
Regola di questa guida: ogni comando qui con un "esito" è un comando ESEGUITO in questa
sessione con l'esito reale; i restanti sono marcati esplicitamente "non verificato".

## 1. Scopo
Trading-Short è una strategia di trading short sul panico di mercato, in due forme:
- Pine (TradingView): `TEMA-ST-WT_PANIC_HUNTER_v3_2.pine` (904 righe) e `PANIC_HUNTER_SIGNALS.pine` (525 righe).
- Python (backtest/ottimizzazione): `backtest.py`, `optimize.py`, `analyze_entries.py`,
  `analyze_exit_2h.py`, `analyze_real_exits.py`, `analyze_trades.py`, `analyze_v2.py`.
ATTENZIONE: il codice Pine e quello Python NON implementano la stessa strategia — divergono su
soglia panic, composizione del punteggio, prezzo d'ingresso e 3 dei 5 meccanismi di uscita
(verifica in sola lettura su `backtest.py`/`optimize.py`/TEMA pine; cfr. §5 e docs/archivio/).
I numeri prodotti da `optimize.py` descrivono una strategia diversa da quella deployata in Pine.

## 2. Struttura (dal grafo ~/graphify-out/Trading-Short/graph.json: 857 nodi, 811 link, 0 failed)
- `patterns/` (66 file .md): catalogo di pattern/metodo; gli ANCOR sono cross-repo (vedi §6).
- `.claude/` e `.opencode/` (24 file .md ciascuno): specchi quasi identici di config agenti+skill (hub).
- `docs/`: guida vivente + `docs/errori/REGISTRO.md` (registro errori) + `docs/archivio/` (superati).
- `tools/` (11 script .sh): gate di governance del metodo (py-gate, gas-gate, privacy-check, ...).
- `tests/test-errori.sh`: lente che verifica l'esistenza delle guardie citate nel registro errori.
- Codice: 7 `.py` a radice + 2 `.pine` + `.opencode/plugins/graphify.js`.
- "Punto d'ingresso del test": `.night-verify` -> `bash tools/py-gate.sh` (compila i .py tracciati).
- Il grafo NON contiene comunita' (campo `community` assente in ogni nodo): non riportabili.

## 3. Come si avvia / come si testa
ESEGUITO in questa sessione (esito reale, sola lettura):
- `bash tools/py-gate.sh` -> "Sintassi python: tutti i .py compilano (7 file)", exit 0.
- `git switch -c docs/razionalizzazione-2026-11` -> branch creato, albero pulito (git status --short vuoto).
- Verifica righe del codice con `sed -n`/`grep`: `optimize.py:315` sl_pct, `:264` profit_factor=99.0,
  `:116`/`:119` np.roll; `backtest.py:150` panic=40, `:151` strong-bear=25; `TEMA pine:26`
  default_qty_value=90 -> tutte confermate.
NON VERIFICATO (non eseguito in questa sessione):
- `python3 backtest.py` / `optimize.py` / `analyze_exit_2h.py` / `analyze_real_exits.py`: richiedono
  rete (`yf.download`) e un ambiente con yfinance/pandas/numpy; non eseguiti (rete vietata dal mandato).
- `analyze_entries.py` / `analyze_trades.py` / `analyze_v2.py`: usano fixture hardcoded (no rete), ma
  non eseguiti qui -> "non verificato".
- Strategie Pine: nessun interprete Pine fuori TradingView -> "non verificato".
- Riproducibilita: `period="2y"` e' relativo al giorno di lancio (`backtest.py:321`, `:340`,
  `optimize.py:297`); i numeri cambiano a ogni esecuzione. Nessuna cache/dati nel repo.

## 4. Convenzioni
- Metodo di lavoro: regole di canone in `CLAUDE.md` (privacy, debito, comunicazione, git) — valide e portatili.
- Nomi/luoghi: script Python a radice; gate in `tools/`; pattern in `patterns/`; report di campo in `docs/campo/`.
- Gate di governance: `.night-verify` esegue `bash tools/py-gate.sh` (compila i .py: exit 0 = ok, 1 = rotto, 2 = perimetro).
- Segreti: "public repo, private work" — mai nomi di repo/private in un file versionato; `tools/privacy-check.sh`
  li controlla, ma qui e' DEGRADATO (manca `night-shift/repos.key`, assente) -> il suo verde non vale.

## 5. Punti fragili (verifica in sola lettura sul codice attuale)
- D1: lo stop loss (`sl_pct`) e' inerte — il trailing stop lo sovrascrive alla prima barra
  (`optimize.py:225-230`; griglia `:315`); 4 dei 5 valori della griglia sono ridondanti.
- D2: Pine e Python non sono la stessa strategia (soglie/punteggio/ingresso/uscite divergenti).
- D8: `np.roll` introduce look-ahead (`optimize.py:116`, `:119`) — oggi mascherato da `start=200`.
- D9: `profit_factor=99.0` quando nessuna perdita "vince" ogni ordinamento (`optimize.py:264`).
- D7: `resample('4h')` allinea alla mezzanotte del fuso indice, non alla sessione (`backtest.py:70`).
- S1: `default_qty_value=90` con posizione short causa margin call (`TEMA pine:26`).
- Nessun `requirements.txt`/`pyproject`; nessun test automatico sul progetto (solo `py-gate` sintattico).

## 6. Documenti superati (archivati) e dove
- `docs/archivio/REVISIONE-2026-09-22.md` — revisione datata 2026-09-22: le finding di codice
  D1-D9/S1-S4 risultano ancora vere sul codice attuale, MA l'affermazione P3 "patterns/fixture-provenienza.md
  installato" e' smentita (file assente). Cronologia, non stato corrente.
- `docs/archivio/2026-09-22-onboarding-e-dev-critic-trading-short.md` — report di campo datato che
  cita `tools/sync-repo.sh`, `tools/copia-hook.sh`, `docs/benvenuto-collaboratori.md` (tutti assenti).
- Motivi completi in `docs/archivio/INDICE.md`.
- Documenti GUIDA "DA CORREGGERE" (corretti con una NOTA in testa, non riscritti): `CLAUDE.md`, `DEBITI.md`,
  `docs/campo/README.md`, `patterns/README.md`, `docs/ngiri-paralleli.md` — importano canone/metodo dall'hub
  e citano infrastrutture hub ASSENTI qui (`night-shift/`, `llm/`, `PROJECT.md`, `docs/system.md`,
  `tools/fork-stato.sh`, ...). Leggerli come riferimento, non come cablaggio vivo.

## 7. Cosa NON si e' verificato (limiti onesti)
- Clone shallow (1 commit `8f60797`): la storia git (hash `b54bf82`, `cf2d9ae`, PR #57) non e' accessibile.
- Esecuzione dei 7 `.py` e delle 2 strategie Pine: non eseguiti (rete/interprete non disponibili).
- NON-REVISIONATI (da un secondo giro): `.claude/` (24 .md), `.opencode/` (24 .md + 1 .js),
  `patterns/` (66 .md), `docs/errori/REGISTRO.md`. Vederli nel file `docs/_revisione.tsv` (colonna classe).

Istruzioni d'uso di ogni software (comandi, requisiti, problemi noti): `docs/ISTRUZIONI.md`.

Scheda tecnica sintetica: `docs/SCHEDA-TECNICA.md`.
