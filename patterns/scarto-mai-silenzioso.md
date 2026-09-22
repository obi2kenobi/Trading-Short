# scarto-mai-silenzioso
**Àncora**: progetto onboardato (pipeline GAS di raccolta dati esterni) — Extractor.gs:applicaVincoliRange_ · **Nato**: 2026-08-21 (terza occorrenza indipendente della stessa famiglia di bug in due progetti diversi: un plug contabile che assorbiva un residuo reale nel tie-out, un pool di costi che spariva sotto una guardia anti-divisione-per-zero, e qui un valore fuori-range azzerato senza traccia — nessuno dei tre era visibile a lettura, solo a esecuzione)
Una funzione che scarta, azzera o clampa un valore in base a una regola (range plausibile, guardia anti-zero-division, soglia di scarto) deve DIRE cosa ha scartato, non solo farlo — un dato perso silenziosamente è indistinguibile da un dato mai arrivato, e chi legge un "quadra ✅"/"nessun errore" a valle non ha modo di sapere che la regola ha appena cancellato qualcosa senza volerlo (un limite calibrato per un caso noto può sempre incontrarne un altro, legittimo, che ricade nello stesso range). Il fix non tocca la regola né le sue soglie — resta un problema di dominio, non di igiene del codice — cambia solo la funzione da void a "ritorna cosa ha scartato", e il chiamante lo logga se non vuoto. Verificato dal vivo su tutti e tre i casi: nessuna soglia cambiata, solo un canale in più per vedere quando scatta. Riusabile ovunque una regola di validazione/normalizzazione trasformi silenziosamente un valore "sospetto" in null/0/default.


## Il segnale PARZIALE è più pericoloso del silenzio (2026-08-27, REPO-H)

Un conteggio senza importo, unanomalia per record senza riga aggregata nei totali:
il segnale parziale dà falsa copertura — chi legge smette di cercare. Lo scarto
si dichiara COMPLETO (importo E conteggio), o non è dichiarato.

**Vedi anche**: `verdetto-sempre-visibile` · `somma-diversa-da-zero-non-e-presenza` · `stato-vuoto-dalla-pipeline`
