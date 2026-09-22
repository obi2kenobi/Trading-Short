# lock-per-risorsa
**Àncora**: night-shift/night-shift.sh (LOCK) · **Nato**: 2026-08-21 (turni sovrapposti)
Due esecuzioni sulla stessa risorsa (il turno manuale e quello delle 23:00) = caos. Lock a directory con ETÀ: occupato di fresco → salto; più vecchio di 12h → considerato morto e preso. `mkdir` è atomico, `trap ... RETURN` rilascia.

**Vedi anche**: `cuore-unico-proprietario` · `workdir-e-proprietario` · `watchdog-guardato`

**Addendum (dal campo REPO-K, 2026-08-31 — misurato sul codice vero, non ipotizzato)**: LockService è PER-SCRIPT, non per-riga: un lock attorno a un'operazione lunga (email, file Drive: minuti) blocca OGNI altra scrittura per tutta la durata — peggio del problema. Se l'operazione ha già concorrenza ottimistica documentata (rilettura fresca + rilevamento conflitto), il lock NON si estende: si usa lo script lock SOLO per il check-and-set atomico di un flag (frazioni di secondo), mai per il corpo lungo. Decidere leggendo la strategia esistente, non per riflesso di simmetria.

