# collisione-namespace-globale-gas
**Àncora**: REPO-Q sessione 2026-09-02 (scaricaMappaPostingDateBc_ sovrascritta silenziosamente) · **Nato**: 2026-09-02
In un progetto Apps Script tutti i file condividono UN SOLO namespace globale: due funzioni con lo stesso nome — anche in file diversi, anche con firme diverse — e l'ultima caricata vince SILENZIOSAMENTE. Nessun errore in deploy, nessun errore a runtime: chi chiama la funzione gira quella sbagliata, con parametri ignorati, filtro diverso, comportamento imprevedibile. L'unico segnale è nel log: stringhe che non hai scritto tu. Guardia meccanica (due comandi, esito binario, vuoto = pulito): `grep -rhoE "^function [A-Za-z_][A-Za-z0-9_]*" --include="*.gs" . | sed 's/^function //' | sort | uniq -c | awk '$1>1'` (idem per `^var`). Va eseguita PRIMA di ogni push: il modo di fallire è il silenzio, quindi serve un controllo che parli.

**Vedi anche**: `copertura-dal-glob` · `estrazione-per-testabilita`
