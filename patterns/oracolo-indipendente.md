# oracolo-indipendente
**Àncora**: REPO-A (REPO-A) — tools/grafo-verifica.js (assi C "fedeltà estrazione" e D "golden") · **Nato**: 2026-08-21 (formalizzato in AI_Programmer come "verificare-il-grafo, non fidarsi")
Non ci si fida di ciò che uno strumento (graphify) dice di aver estratto: si cross-verifica con un secondo oracolo indipendente e più semplice — una regex `function NAME(` che nessuno strumento complesso alimenta — e i "mancanti" diventano una misura quantitativa dell'inaffidabilità, non un'opinione. Sopra questo, i "golden": fatti noti e veri sul parco reale (es. "un progetto sano non deve avere globali duplicate", "una funzione nota è lunga esattamente 9 righe") che DEVONO continuare a valere: un golden rotto è un gate hard, non un report. Eseguito dal vivo: `node tools/grafo-verifica.js` sul mirror reale di 91 progetti → 17 golden verificati (D1-D17) tutti veri più un problema reale trovato sul colpo (A4: una collisione di nomi-progetto dopo troncamento a 48 caratteri).


## Secondo caso reale (2026-08-27, REPO-H — docs/campo/2026-08-27)

`docs/bc/endpoints/*.md` come oracolo indipendente in revisione ANY-repo GAS+BC:
ha smentito la documentazione del progetto (sbagliata su un codice registro)
prima che un fix allineasse il codice GIUSTO al documento SBAGLIATO. Il catalogo
endpoint è oracolo dichiarato per ogni revisione che tocchi dati BC.


**Vedi anche**: `regola-provata-non-assunta` · `oracolo-dal-sistema-vecchio`
