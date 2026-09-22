# itera-su-array
**Àncora**: night-shift/night-shift.sh (ROWS[@]) · **Nato**: 2026-08-19 (stdin mangiato)
Mai `while read` su pipe quando il corpo lancia comandi: divorano lo stdin del loop e le righe successive spariscono in silenzio. Si raccoglie prima in array (`while IFS= read -r l; do ROWS+=("$l"); done < <(cmd)` — bash 3.2, NIENTE mapfile su macOS) e si itera per indice.


**Vedi anche**: `copertura-dal-glob`
