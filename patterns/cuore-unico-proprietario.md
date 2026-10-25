# cuore-unico-proprietario
**Àncora**: night-shift/lib.sh:rianima_ollama · **Nato**: 2026-08-21 (la gara persa)
Se una risorsa ha un custode con auto-resurrezione (launchd KeepAlive), NON ucciderla per sostituirla con la tua istanza: resuscita e vi contendete la porta — perdono entrambi. Si fa `launchctl kickstart` AL custode e si aspetta la SUA resurrezione. Regola generale: ogni risorsa ha UN proprietario dichiarato; gli altri chiedono a lui. (2026-09-24, V5 R4: la regola la rispettava solo la sonda; il watchdog d'inizio ciclo e `night-shift/agente.sh` facevano pkill e aspettavano un launchd che su altre macchine non c'è. Ora i tre punti chiamano `rianima_ollama`: custode presente → kickstart a lui; assente → kill e istanza propria.)


**Vedi anche**: `lock-per-risorsa` · `la-staffetta`
