# lettura-esecuzione-precedente
**Àncora**: REPO-I, 5 moduli indipendenti (Mastrini fornitori, Banche, Cespiti,
Ferie, TFR) — lo stesso movimento in tutti, nessuno coordinato con gli altri
(report: docs/campo/2026-08-28-repo-i-fase3.md §4.10) · **Nato**: 2026-08-28

Prima di scrivere la riga della nuova esecuzione in un diario append-only,
si rilegge l'ultimo stato per lo stesso soggetto (documento, banca, categoria,
dipendente). Così l'esecuzione puo dire «questo era gia segnalato, ed e ancora
aperto» oppure «questo era chiuso ed e ricomparso», invece di trattare ogni
esecuzione come se fosse la prima. E il gemello dei dati di
estrazione-per-testabilita: quello estrae per POTER testare la logica, questo
rilegge per POTER distinguere nuovo/persistente/ricomparso.


**Vedi anche**: `stato-vuoto-dalla-pipeline` · `scarto-mai-silenzioso`
