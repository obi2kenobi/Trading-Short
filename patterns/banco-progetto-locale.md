# banco-progetto-locale
**Àncora**: REPO-N (gestionale parrocchie, Flask+SQLite): banco costruito a
mano in sessione — 3 errori di binding SQL nel proprio script di prova prima
di girare (report: docs/campo/2026-08-28-parrocchie-fase1.md F2) · **Nato**: 2026-08-28

Quando un progetto esterno non ha harness di test, il banco si costruisce in
quattro passi: riscrivi i percorsi dati verso una sandbox; semina fixture
MARCATA come prova (mai dati veri); esercita rotte/CLI del progetto vero
(non una copia); asserisci e fallisci rumorosamente. Il banco resta nel repo
e diventa il .night-verify eseguibile. La regola dell'aspettativa-derivata-a-mano
vale anche per il codice del banco stesso.


**Vedi anche**: `banco-sintetico-per-calcoli-critici`
