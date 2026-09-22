# estrattore-test-dipendenza-refactor
**Àncora**: REPO-G tools/test-computeperiod.js estraiFunzioneRigaSingola (regex a
riga singola che avrebbe rotto in silenzio il refactor batch 10: un loop nella
funzione estratta = graffa che la regex non ammette — SAL.md D55, 2026-08-27;
report: docs/campo/2026-08-27-repo-g-esecuzione-quattordici-lenti.md) · **Nato**: 2026-08-27

Quando il banco di regressione di un progetto GAS estrae funzioni vere dal
sorgente con una REGEX (non un parser vero, perché GAS non ha un runner nativo),
quella regex diventa essa stessa un vincolo sulla FORMA futura della funzione:
un refactor innocuo nel codice prodotto (introdurre un loop, un blocco) puo
rompere silenziosamente l'ESTRAZIONE, non la logica. Prima di un refactor che
cambia la forma di una funzione gia coperta da un estrattore fragile: aggiornare
l'estrattore PRIMA, mai contestualmente — o deferire esplicitamente citando
l'estrattore fra le cause.


**Vedi anche**: `banco-sintetico-per-calcoli-critici` · `regola-provata-non-assunta`
