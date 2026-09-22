# migrazione-con-interruttore
**Àncora**: REPO-Q split produzione per anno, 2026-09-02 · **Nato**: 2026-09-02
Il pattern per migrare dati in GAS senza scegliere fra «deploy rischioso» e «migrazione al buco»: (1) codice deployato INERTE dietro una Script Property; (2) migrazione a freddo, a chunk ripartibili, con watermark salvato DOPO ogni scrittura; (3) verifica; (4) si accende l'interruttore; (5) la sorgente resta come copia di sicurezza; (6) il recupero spazio è un passo SEPARATO, dopo una notturna verificata. Il pregio: il deploy NON cambia comportamento — si può pushare a metà giornata senza finestra di manutenzione. Rollback disponibile fino all'ultimo passo.

**Vedi anche**: `pipeline-a-ripresa` (vedi estrazione-llm-spezzata) · `banco-sintetico-per-calcoli-critici`
