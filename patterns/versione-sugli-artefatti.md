# versione-sugli-artefatti
**Àncora**: REPO-A (REPO-A) — tools/grafo-findings.js:221 e tools/grafo-parco.js:137 (`prodotto_da`) · **Nato**: 2026-08-08 (lo schema di graphify è cambiato fra minor e ha rotto tre strumenti contemporaneamente)
Ogni documento generato da uno strumento esterno che evolve (graphify) porta in fronte, stampata, la versione che l'ha prodotto — o dichiara esplicitamente che non risponde a `--version`: mai un numero silenzioso che invecchia senza dirlo. Un report senza questa riga è indistinguibile da uno prodotto da uno schema diverso, e lo schema DI FATTO cambia fra versioni minor. Verificato sul codice: entrambi i file stampano `> Prodotto da **${out.prodotto_da || "(versione non dichiarata: \`graphify --version\` non risponde)"}**` — l'assenza della versione è essa stessa una riga visibile nel documento, non un buco silenzioso. Lezione già importata in AI_Programmer (SAL.md, 2026-08-21: "aggiornare solo a versioni verificate e stampare la versione sugli artefatti") — questo pattern le dà l'ancora formale che mancava nel registro.


**Vedi anche**: `citazione-non-presidio`
