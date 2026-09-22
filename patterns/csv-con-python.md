# csv-con-python
**Àncora**: night-shift/gate-summary.sh · **Nato**: 2026-08-21 (due bug di fila)
Mai splittare CSV a mano sulle virgole in bash: è la causa di due bug consecutivi (colonna persa, doppio inserimento). `python3` col modulo `csv` (DictReader): zero dipendenze, virgolette e campi vuoti gestiti. Ogni volta che un CSV bash cresce oltre 3 colonne, si passa a python.


**Vedi anche**: `itera-su-array` · `jq-slurp` · `edifact-release-character` · `il-precedente-porta-il-vincolo-pagato`
