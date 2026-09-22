# verdetto-sempre-visibile
**Àncora**: REPO-A (REPO-A) — tools/banco-lib.js:verdetto · **Nato**: 2026-08-17 (due consegne nello stesso giorno si sono riscritte il caricatore)
Un banco che esegue meno attese di quelle dichiarate non deve "sembrare più piccolo": `verdetto(casi, atteseTotali)` stampa SEMPRE la riga `attese eseguite: N/M · fallite: K` (mai una settima forma diversa) e, sopra, la ripartizione in due gruppi — PARITÀ rotti (la correzione ha rotto il resto) e CORREZIONE mancanti (non corregge) — così chi legge sa quale delle due malattie ha. Eseguito dal vivo su una consegna reale del parco (`docs/progetti/REPO-C_SD/.../banco.js` contro `gas-src/REPO-C_SD__1Bu4OzD5`): `attese eseguite: 8/8 · fallite: 4` con `PARITÀ rotti: 0 · CORREZIONE mancanti: 4` — nessuna riga di stato nasconde N<M.


**Vedi anche**: `scarto-mai-silenzioso`
