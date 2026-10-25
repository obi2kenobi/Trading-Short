# lock-per-risorsa
**Àncora**: night-shift/night-shift.sh (LOCK) · **Nato**: 2026-08-21 (turni sovrapposti)
Due esecuzioni sulla stessa risorsa (il turno manuale e quello delle 23:00) = caos. Lock a directory col **PID** dentro: `prendi_lock_turno <dir> [programma]` di `night-shift/lib.sh` — PID vivo e di quel programma = occupato, a qualunque età; PID morto o riusato = orfano, preso subito; il furto dell'orfano è serializzato (`<dir>.furto`) e rigiudicato. `mkdir` è atomico, il trap rilascia. Lo usano il turno, il lock per repo, il morning-gate, ciclo-vivo. (2026-09-24, V5: qui si diceva «lock con ETÀ, oltre 12 h morto» — il lock per repo lo faceva fino al 2026-09-24, e dopo un kill -9 saltava la repo per 12 ore; il codice ancorato ora fa il contrario, e il pattern lo dice.)

**Addendum (Q10, 2026-09-23)**: per il lock GLOBALE del turno l'età non basta — un ciclo con l'issue lenta dura fino a 4h (watchdog) e la soglia di 1h lo rubava a un turno vivo. `night-shift/lib.sh` prendi_lock_turno mette il PID nel lock: vivo e del turno = occupato a qualunque età, morto o riusato = orfano (E-026) preso subito, stesso PID = suo (resta preso attraverso l'exec di fine ciclo). E si prende PRIMA di ogni passo distruttivo (self-pull, pkill), non dopo.

**Vedi anche**: `cuore-unico-proprietario` · `workdir-e-proprietario` · `watchdog-guardato`

**Addendum (dal campo REPO-K, 2026-08-31 — misurato sul codice vero, non ipotizzato)**: LockService è PER-SCRIPT, non per-riga: un lock attorno a un'operazione lunga (email, file Drive: minuti) blocca OGNI altra scrittura per tutta la durata — peggio del problema. Se l'operazione ha già concorrenza ottimistica documentata (rilettura fresca + rilevamento conflitto), il lock NON si estende: si usa lo script lock SOLO per il check-and-set atomico di un flag (frazioni di secondo), mai per il corpo lungo. Decidere leggendo la strategia esistente, non per riflesso di simmetria.

