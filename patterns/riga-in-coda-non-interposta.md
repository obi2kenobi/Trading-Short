# riga-in-coda-non-interposta
**Àncora**: REPO-H Main.gs generateCopertina_ (PR #25: sezione aggiunta in
coda per non spostare i bold hardcoded a riga 8 e 15; primo tentativo
interposto, scoperto dal banco con stub PRIMA del commit — report:
docs/campo/2026-08-27-cespiti-12-pr.md §3) · **Nato**: 2026-08-27

Quando un foglio/report ha posizioni di riga hardcoded altrove (getRange(8,1)
per un titolo), la sezione NUOVA va sempre aggiunta IN CODA, mai interposta —
interporla sposta silenziosamente ogni riferimento successivo. E quando serve
una riga nuova, meglio il calcolo dinamico (15 + N + 2) di un altro numero
fisso. Famiglia della formattazione-fantasma: lo stato attaccato alla
POSIZIONE, non alla logica.


**Vedi anche**: `copertura-dal-glob`
