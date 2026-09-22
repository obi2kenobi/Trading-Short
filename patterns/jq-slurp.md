# jq-slurp
**Àncora**: night-shift/morning-gate.sh (N=...) · **Nato**: 2026-08-21 (il conto-chiavi)
`jq 'length'` su uno STREAM di oggetti conta le CHIAVI dell'oggetto, non gli elementi (3 invece di 1!). Contare elementi: `jq -s 'length'` (slurp). Sintomo riconoscibile: contatori che tornano "3" quando ti aspetti 1.


**Vedi anche**: `csv-con-python`
