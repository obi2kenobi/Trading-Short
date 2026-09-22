# chiave-stabile-etichetta-libera
**Àncora**: REPO-I, due punti del ciclo Fase 3 (nome controllo come chiave di
serie storica nel registro audit; nome conto che identifica un aggregazione)
— report: docs/campo/2026-08-28-repo-i-fase3.md §4.12 · **Nato**: 2026-08-28

Mai rinominare un identificatore usato come CHIAVE in una serie storica
append-only, un log, o un registro — anche per un nome oggettivamente piu
chiaro. Il codice funzionerebbe (nessun errore immediato), ma la continuita
della serie si rompe in modo INVISIBILE: il nuovo nome non trova il passato,
il passato resta orfano. L'etichetta piu leggibile si aggiunge ACCANTO, mai
AL POSTO. E la generalizzazione precisa del «rename rischioso»: il rischio
specifico e la rottura silenziosa della continuita storica, non quella
funzionale immediata.


**Vedi anche**: `citazione-non-presidio` · `versione-sugli-artefatti`
