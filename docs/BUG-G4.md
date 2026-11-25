# BUG-G4 — candidati (M-031.74b.1)

Analisi solo: nessuna correzione in questo mandato.

CANDIDATO-1: optimize.py:415 — crash (IndexError) quando nessuna configurazione ha >=15 trade: `filtered` è vuoto e `filtered.iloc[0]` solleva eccezione prima di stampare il dettaglio. Il filtro a riga 341 accetta >=10 trade, quindi lo scenario è possibile.
CANDIDATO-2: optimize.py:223-245 (stesso schema in backtest.py:211-225 e 238-247) — il trailing stop viene stretto con il Low della barra corrente PRIMA del controllo SL sull'High della stessa barra: un SL può essere registrato su un movimento avvenuto prima del minimo (uscita fantasma, perdita/esito errato).
CANDIDATO-3: backtest.py:228 e optimize.py:232 — il TP viene controllato prima dello SL: se TP e SL cadono nella stessa barra, l'esito è sempre TP (ordine intrabarra assunto favorevole, risultati ottimistici).
