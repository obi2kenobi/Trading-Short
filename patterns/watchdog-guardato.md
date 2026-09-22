# watchdog-guardato
**Àncora**: night-shift/lib.sh:run_guarded · **Nato**: 2026-08-18 (l'agente che girò 4,5 ore)
Ogni comando di durata ignota gira con killer: `( "$@" & pid=$!; ( sleep N; kill $pid ) & w=$!; wait $pid; rc=$?; kill $w )`. Su macOS non c'è `timeout`: questo è il suo sostituto provato. Vale per agenti, verifiche, banco. Eccezione RITRATTA (Luca, 2026-08-31): il turno notturno ora usa il watchdog per-issue (NIGHT_SHIFT_TIMEOUT=240min di default). Il no-limit del 2026-08-21 è costato 3 notti (28-30/8: loop da 59 ore, job vivo che bloccava i turni seguenti) e la review del mattino non poteva guardare ciò che non vedeva. La review resta l'appello: il watchdog limita il loop, non la qualità.


**Vedi anche**: `regola-provata-non-assunta`
