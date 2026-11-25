# BUG-G4 — correzione dei bug (M-031.74b.2)

Stato: due bug corretti (BUG-1, BUG-2) su ramo fix/g4-2026-11. CANDIDATO-3 non trattato: fuori da questo mandato.
Prove: riproduzioni in harness Python puro fuori repo (/tmp/m031b): pandas e numpy non installati, installarli richiede rete non autorizzata. Il codice reale NON è stato eseguito.

## BUG-1
Dove: optimize.py, blocco «DETTAGLIO — CONFIGURAZIONE MIGLIORE» (~riga 415), best = filtered.iloc[0] su filtered vuoto.
Gravità: media. Il run non produce il dettaglio (IndexError) quando nessuna configurazione ha >=15 trade, pur avendone >=10.
Prova: PRIMA, con la stessa logica di filtro/indicizzazione su 4 configurazioni con 10-14 trade: «ERRORE: IndexError list index out of range». Harness /tmp/m031b/repro_bug1.py.
Correzione: f90c99f — guardia if filtered.empty: stampa e exit() prima di iloc[0].
Test: DOPO, stessa logica con guardia: nessun IndexError. Non verificato sul run reale (pandas assente).

## BUG-2
Dove: optimize.py run_backtest (~righe 223-245) e backtest.py run_backtest (~righe 211-247): trailing aggiornato con il Low della barra prima del controllo SL sull'High della stessa barra.
Gravità: alta per i risultati: uscita registrata su una barra in cui lo stop è stato stretto dallo stesso minimo, con esito ottimistico o errato.
Prova: PRIMA, short entry 100, stop 102, barra 0 con Low 90 e High 92: uscita SL sulla barra 0 a 91 (+9%). Harness /tmp/m031b/repro_bug2.py. DOPO: nessuna uscita sulla barra 0; SL sulla barra 1 a 91.
Correzione: 8f28d04 — in optimize.py e backtest.py: controlli TP e SL con lo stop delle barre precedenti, poi aggiornamento del trailing.
Test: harness DOPO come sopra. Non verificato sui dati reali né sui risultati del backtest.

## CANDIDATO-3 (non trattato)
TP controllato prima dello SL nella stessa barra (backtest.py ~228, optimize.py ~232). Resta aperto, decisione del Capo.
