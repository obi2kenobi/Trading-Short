# soglia-con-provenienza
**Àncora**: REPO-A (REPO-A) — tools/soglie.js:derive (riga 164) · **Nato**: 2026-08-07/giro 369 (MARGINE=2 scelto ragionando, non misurando; al primo impiego vero ha bloccato un commit su codice giusto — la varianza reale era 2,7×)
Una soglia scritta a mano (un numero con un nome, tipo `MARGINE`, `SCARTO_PERCENTUALE`, `FIFO_LOOKBACK_MESI`) dichiara su QUANTE osservazioni è calibrata, o non è una misura: è un'opinione con la sintassi di un numero. "Prima si conta sui dati veri, poi si decide" era stato archiviato come "non meccanizzabile" — comodo ma sbagliato: una soglia CON UN NOME si riconosce staticamente, quindi si può pretendere che dichiari `su` (quante osservazioni) e `come`, con un controllo anti-deriva che confronta il valore dichiarato con quello letto nel sorgente vero. Eseguito dal vivo: `node tools/soglie.js` sulle costanti reali di REPO-A → 1 sola calibrata su dati veri su 14 censite, 7 scelte a ragionamento, 6 non sono soglie affatto — e la sola calibrata portava una prosa che la contraddiceva (dichiarava 90%, il codice allarmava al 70%).


**Vedi anche**: `soglia-con-default-guardato` · `tolleranza-derivata-non-scelta`
