# edifact-release-character
**Àncora**: REPO-J (Gestione-ordini-REPO-J) Parsers.gs:77 (repo esterna, non in questo hub) content.split("'") —
report: docs/campo/2026-08-28-REPO-J-50-agenti.md §1.7 · **Nato**: 2026-08-28

Lo standard EDIFACT prevede il carattere di rilascio ? seguito dal delimitatore
per rappresentare il delimitatore STESSO dentro un dato: L?'Aquila e un apice
legittimo in un nome. Uno split("'") senza gestire il release character spezza
il segmento a meta: nome vuoto, indirizzo vuoto, citta vuota — nessuna
eccezione, nessun log. La cura: pre-processare il tracciato sostituendo
?' con un placeholder prima dello split, poi ripristinare.


**Vedi anche**: `forma-dei-dati-verificata`
