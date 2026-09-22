# citazione-non-presidio
**Àncora**: REPO-A (REPO-A) — tools/pattern-strumenti.js:senzaControllo, funzione `contiene` (riga 158) · **Nato**: 2026-08-07 (conteggio su di sé: 23 difetti corretti, 4 introdotti nel codice nuovo, tre erano pattern già applicati dallo stesso autore nei giorni prima)
"Già applicato in" NON è "qualcuno ti ferma se non lo applichi": il primo è un posto da cui copiare (agisce solo se qualcuno apre il catalogo), il secondo è un lint/gate che accusa da solo chi non lo rispetta. Ogni voce del catalogo (`dove`+`ancora`) dice dove il pattern vive; solo le voci con `controllo` (un secondo file:ancora, un gate reale) sono presidiate — le altre dichiarano esplicitamente `perche` non lo sono, invece di fingere una garanzia che nessuno controlla. La prova che la distinzione conta: l'autore ha violato lui stesso un pattern che aveva scritto due giorni prima ("le letture care stanno nella pipeline"), rilevandolo solo **cronometrando** la suite (4,3→8s), non ricordando. Eseguito dal vivo: `node tools/pattern-strumenti.js` → 11 pattern, 5/11 presidiati da un controllo automatico, 0 ancore morte.


**Vedi anche**: `versione-sugli-artefatti` · `presidio-senza-consumatori`
