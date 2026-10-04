# pipefail-grep-sigpipe
**Àncora**: tools/e002-siti.py:siti · **Nato**: 2026-08-28 (il ciclo che segnalava 34 collegamenti mancanti di cui alcuni falsi)
`echo "$GRANDE" | grep -q "$x" || segnala` con `set -o pipefail`: quando grep trova la corrispondenza presto esce subito, echo sta ancora scrivendo, riceve SIGPIPE (141), pipefail rende fallita l'intera pipeline → **il ramo `||` scatta proprio quando la corrispondenza C'È**. Il falso positivo appare solo con input oltre il buffer della pipe (64KB su macOS): sotto quella soglia il ciclo gira verde e il bug dorme. Scoperto perché il conteggio dei finding cambiava fra run identici (34, 36, 39, 5): la non-deterministicità è l'indizio. Rimedio: grep direttamente sui file (`grep -qF "$x" file1 file2`), niente pipe, niente truncation con `head -c`. Regola generale: sotto pipefail ogni `cmd1 | grep -q` su cmd1 costoso è sospetto — il produttore muore di SIGPIPE quando il consumatore ha già vinto.

**Vedi anche**: `verdetto-sempre-visibile` · `misura-la-deriva-prima-di-assumerla` · `confronto-non-vuoto`

**Riàncorato (2026-09-24, terzo ventaglio, V5)**: l'àncora `tools/ciclo-vivo.sh:lente-2` era morta — le
lenti di ciclo-vivo sono state riscritte il 2026-09-23 e la famiglia vive ora in un rilevatore unico,
`tools/e002-siti.py` (virgolette e commenti compresi), usato da `tests/test-e002-codice.sh` e
`tests/test-e002-banchi-curati.sh`: zero siti nel repo. Le due cure: `grep -q … <<<"$X"` quando il
produttore e' un echo/printf, `… | grep -c … >/dev/null` per qualunque produttore (`-c` legge tutto
l'input; `-q` con `>/dev/null` non basta, GNU grep esce presto lo stesso).
