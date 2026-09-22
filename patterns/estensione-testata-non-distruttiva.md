# estensione-testata-non-distruttiva
**Àncora**: REPO-G gas/Sheets.js estendiHeaderSeManca_ (colonne di audit
modificato_da/modificato_il aggiunte a fogli Google Sheets GIÀ in produzione
senza migrazione manuale, con test dedicato: foglio 3 colonne → 5, righe
intatte — report: docs/campo/2026-08-27-repo-g-esecuzione-quattordici-lenti.md) ·
**Nato**: 2026-08-27

Per aggiungere colonne a un Google Sheet che un progetto GAS gia legge/scrive in
produzione: la testata si LEGGE, si calcola il delta rispetto alle colonne
attese, e si APPENDONO solo le mancanti — MAI una riscrittura dell intera
intestazione. Evita sia il passo di migrazione manuale al cliente sia il
disallineamento silenzioso delle colonne esistenti rispetto ai dati sotto.
Imparentato con FORMATTAZIONE FANTASMA (famiglie-difetti) ma sul CONTENUTO
della testata invece che sul formato della cella.


**Vedi anche**: `verdetto-sempre-visibile` · `copertura-dal-glob` · `doppio-livello-escaping`
