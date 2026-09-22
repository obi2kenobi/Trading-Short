# contenitore-che-riscrive
**Àncora**: REPO-W GAS+BC fatture fornitore estere Fase 2 (vedi
`docs/campo/2026-09-05-repo-w-quattordici-giri-revisione.md`) — `Foglio.gs`,
funzioni `isoDaCella_` e `valoreDiCella_`, banco con 6 attese e 3 sabotaggi · **Nato**:
2026-09-05 (quattordici giri di revisione sullo stesso codice: due difetti diversi,
stessa forma, nessuno dei pattern precedenti la copriva)

Il contenitore in cui scrivi **non restituisce quello che gli hai dato**. Due casi
veri, stesso meccanismo:

1. **Coercizione silenziosa di tipo**: la stringa `'2026-01-31'` scritta in un foglio
   torna indietro come `Date`. Il controllo che la rileggeva rispondeva «data non
   leggibile» su OGNI riga — un controllo di dominio spento in silenzio, senza un
   errore da nessuna parte, con il banco verde perché il banco passava stringhe.
2. **Il valore diventa codice**: una stringa che inizia per `=`, `+`, `-`, `@` torna
   indietro come il RISULTATO di una formula. Se quei campi arrivano dall'esterno
   (OCR, email, upload, scraping), chi manda il documento controlla i valori con cui
   il sistema decide. Non esfiltrazione: controllo sulla decisione.

La domanda generale, che vale per un foglio come per un CSV, un DB con coercizione
di tipo, una cache che serializza, un IPC che normalizza: **ciò che rileggi dal
contenitore è ciò che gli hai dato?** La verifica va fatta alla frontiera: una
funzione `leggi-da-contenitore` (qui `valoreDiCella_`) che normalizza o rifiuta,
con attese che usano il TIPO che quel confine restituisce davvero — un banco che
passa il tipo comodo da scrivere invece di quello che arriva dal confine è un banco
che mente (regola del report: «il doppio che semplifica il tipo è un doppio che mente»).
Per le stringhe esterne destinate a una cella: neutralizzare i prefissi di formula
(`=`, `+`, `-`, `@`) prima della scrittura — e il sabotaggio del banco deve includere
la MEZZA difesa (neutralizzare solo `=` dimenticando `+ - @`): il banco deve distinguere
una difesa da una mezza difesa, non solo la difesa dall'assenza.

**Nota di famiglia**: vicina a `doppio-livello-escaping` (entrambe: il confine
trasforma il dato) ma qui il problema è il confine di LETTURA-riscrittura che
coerisce o esegue, non l'escaping ripetuto in scrittura. Vicina anche a
`autorita-di-dominio-batte-oracolo`: la decisione presa sul dato letto è di dominio,
ma il difetto nasce prima — nel contratto non scritto con il contenitore.

**Vedi anche**: `doppio-livello-escaping`, `autorita-di-dominio-batte-oracolo` (la regola
«la sonda distingue zero da domanda sbagliata» è nel metodo, REPO-W 3/9)
