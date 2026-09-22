# cuore-unico-proprietario
**Àncora**: night-shift/night-shift.sh (probe → launchctl kickstart) · **Nato**: 2026-08-21 (la gara persa)
Se una risorsa ha un custode con auto-resurrezione (launchd KeepAlive), NON ucciderla per sostituirla con la tua istanza: resuscita e vi contendete la porta — perdono entrambi. Si fa `launchctl kickstart` AL custode e si aspetta la SUA resurrezione. Regola generale: ogni risorsa ha UN proprietario dichiarato; gli altri chiedono a lui.


**Vedi anche**: `lock-per-risorsa` · `la-staffetta`
