# Brief dei giri — <progetto>, <data>

Un file solo, letto da ogni giro. Il prompt del singolo giro dice soltanto: «area X, lente Y,
scrivi in <cartella>/<X>-<Y>.md — le regole sono nel brief».

## Contesto
- Cos'è il progetto, per chi, cosa NON è raggiungibile (vivo, gestionale, rete).
- Cosa esiste già e non va riproposto (PR, giri precedenti).

## Aree (nessuna esclusa, o esclusione dichiarata)
| # | Area | Ancora (file:riga-riga) |
|---|---|---|
| A1 | … | `<file>:<da>-<a>` |

## Lenti (consolidate: stessi file + stessa domanda = una lente)
| # | Lente | La domanda | Batteria |
|---|---|---|---|
| L1 | … | … | correttezza / prodotto |

## Regole di ogni giro
1. Scrivi il tuo file PRIMA di rispondere: se muori dopo, il giro resta. Il file va in
   `docs/giri/<data>/grezzi/<lente>.md` (ignorata da git: non entra nel commit, e non sparisce con `/tmp`).
2. Una lente, un'area: non guardare le altre.
3. Formato per ogni voce: **Oggi** (cosa succede ora, con `file:riga`) · **Manca** (il buco
   specifico) · **Proposta** (una mossa concreta, non un principio).
4. Al massimo 6 finding, in ordine di gravità (alta / media / bassa).
5. Se la lente non trova niente, scrivi «nulla in questa lente» e perché.
6. Nessuna feature «da manuale» senza riscontro nel codice; nessun dato inventato.
7. In testa al file, il modello che ha eseguito il giro.

## Uscita del consolidamento (dopo i giri)
| Rilievo | Segnalato da N lenti | Verificato eseguendo | Esito (Implementata/Esclusa/Rinviata/Già coperta) |
|---|---|---|---|
