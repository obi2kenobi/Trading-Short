# regola-provata-non-assunta
**Àncora**: REPO-A (REPO-A) — tools/test-motore.js:eq (riga 39) e il blocco `vm` (riga 4388) · **Nato**: 2026-07-30 (inLoop sbagliato in due modi opposti, penalità più alta del motore, nessun test se ne accorse)
Un'asserzione è una funzione a livello di modulo (`eq(atteso, avuto, cosa)`, niente framework): se lancia, `uncaughtException` dice fin dove la suite è arrivata invece di sparire in uno stack trace. Per le regole sul comportamento del linguaggio (es. "due `const` omonime in file diversi sono fatali") la regola NON si assume dalla documentazione: si prova costruendo lo snippet e caricandolo in `vm` con un contesto condiviso — il modello più vicino a come Apps Script carica più file in un unico programma. Eseguito dal vivo: `node tools/test-motore.js` → **2005 asserzioni, 0 fallite**; nello stesso file un limite di `vm` è documentato e provato (`var`+`const` non lancia su contesti `vm` separati, lancia se concatenati in un solo script — verificato su Node v26.7.0).


**Vedi anche**: `esegui-non-leggere`
