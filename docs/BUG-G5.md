# BUG-G5 — ricerca bug gravi (M-032.74b)

NON TROVATO: nessun bug grave confermato con riproduzione, diverso da BUG-G4 (IndexError in optimize.py; trailing prima dello SL in optimize.py e backtest.py; TP prima dello SL come CANDIDATO-3, lasciato aperto da G4). Dettaglio sotto.

File letti: backtest.py (354 righe, integrale); optimize.py (righe 14-437: indicatori, run_backtest, grid search, classifiche); analyze_exit_2h.py (righe 55-110, simulazione); analyze_real_exits.py (righe 108-126 e 175-210); analyze_entries.py (righe 95-112); analyze_v2.py (righe 80-101); analyze_trades.py (righe 145-175); TEMA-ST-WT_PANIC_HUNTER_v3_2.pine (solo grep di soglie).
Ricerche: pattern shift(-, iloc[0], iloc[-1], divisioni per len, open/to_csv/unlink, confronto parametri Python/Pine.
Non letti: PANIC_HUNTER_SIGNALS.pine (525 righe), analyze_entries.py per intero, analyze_v2.py oltre riga 101, costruttori dei dati hardcoded.
Nessun test nel repo (git ls-files non mostra file di test): test del repo NO-TEST. pandas, numpy e yfinance non installati, rete non autorizzata: nessuna riproduzione eseguita sul codice reale.

Candidati non confermati (da decidere dal Capo, NON corretti):

## Candidato A — optimize.py, run_backtest: PF sentinella 99.0
Dove: optimize.py, run_backtest, calcolo di pf (riga ~ 270): se non ci sono perdite, pf = 99.0.
Gravità: media. Il valore 99 è una costante arbitraria confrontata con PF reali nelle classifiche e nello score (PF × sqrt(trade)).
Prova: ispezione del codice, non riprodotta (serve numpy per eseguire la funzione).
Correzione: non fatta. Decisione del Capo: inf oppure esclusione dalle classifiche.
Test: non eseguito.

## Candidato B — parità Python/Pine delle soglie
Dove: backtest.py run_backtest (panic threshold 40/25, emergency RSI > 65 fisso) e optimize.py (max(normale-15, 15)); TEMA-ST-WT_PANIC_HUNTER_v3_2.pine righe 291-292 (soglia 35/20), 50-51 (exit RSI 65, emergenza 72), 68 (soglia ridotta).
Gravità: da valutare: i backtest possono non rappresentare la strategia Pine v3.2 (il sorgente Python si dichiara v3.5).
Prova: confronto testuale delle costanti, non eseguito.
Correzione: non fatta: quale versione è quella di riferimento lo decide il Capo.
Test: non eseguito.

## Candidato C — simulazioni di analyze_exit_2h.py e analyze_real_exits.py: TP prima dello SL nella stessa barra
Dove: analyze_exit_2h.py simulate (riga ~ 92-101), analyze_real_exits.py (riga ~ 189-200): il TP è controllato prima dello SL sulla stessa barra. È la stessa famiglia di CANDIDATO-3 di BUG-G4 (backtest.py ~228, optimize.py ~232), già lasciata aperta.
Gravità: media per i risultati delle simulazioni.
Correzione: non fatta, per non duplicare il lavoro di G4.

Verifica dei tre punti: vedi Rapporto del mandato.
