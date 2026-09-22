# dipendenza-tra-rami-paralleli
**Àncora**: REPO-H, due occorrenze auto-corrette nella stessa sessione (PR #25
chiamava writeEmptyMessage_ della #24 non mergiata; PR #28 passava il 4°
parametro della firma introdotta in #24 — report:
docs/campo/2026-08-27-cespiti-12-pr.md §3) · **Nato**: 2026-08-27

Piu PR indipendenti dallo stesso main: NESSUNA puo richiamare funzioni/firme
introdotte da un altra PR non ancora mergiata, anche se verrebbe naturale —
il branch preso da solo deve restare eseguibile (la funzione li NON esiste
ancora). Completamento autoriale della regola di composizione del corpus
(la compatibilita fra consegne si PROVA eseguendo sull albero composto):
chi scrive branch paralleli li scrive gia autosufficienti, e dichiara le
dipendenze vere (la #30 dopo la #29) nel piano.


**Vedi anche**: `lock-per-risorsa`
