# itera-su-array
**Àncora**: night-shift/night-shift.sh (ROWS[@]) · **Nato**: 2026-08-19 (stdin mangiato)
Il corpo di un `while read` non eredita mai lo stdin del loop — pipe **o file** (`done < file`): un comando del corpo che legge lo stdin divora le righe successive, e spariscono in silenzio. Due cure: si raccoglie prima in array (`while IFS= read -r l; do ROWS+=("$l"); done < <(cmd)` — bash 3.2, NIENTE mapfile su macOS) e si itera per indice; oppure ogni comando del corpo prende `</dev/null` (lo fa il ciclo delle verifiche di `night-shift/night-shift.sh`, dopo E-030). (2026-09-24, V5: qui si diceva solo «su pipe»; E-030 era lo stesso difetto con `done < .night-verify`. Misurato: su un file di 3 righe, `cat` nel corpo fa 1 giro su 3; con `cat </dev/null`, 3 su 3.)


**Vedi anche**: `copertura-dal-glob` · E-030 in `docs/errori/REGISTRO.md`

2026-10-01 (il blocco del grafo, dal banco): la forma nuda «${ARR[@]}» con l'array VUOTO
e' «unbound variable» su bash 3.2 sotto set -u — non solo lo stdin e' la questione: la
FORMA stessa e' il rischio quando l'array puo' nascere vuoto. La forma sicura resta
«${ARR[@]+"${ARR[@]}"}», sempre; o una guardia esplicita di vuotezza prima del loop.
