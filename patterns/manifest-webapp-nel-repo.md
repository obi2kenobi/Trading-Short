# manifest-webapp-nel-repo
**Àncora**: REPO-CR appsscript.json (sezione webapp) · **Nato**: 2026-09-01 (Centrale_Rischi cruscotto: il redeploy clasp ha perso l'entry point)
Ogni progetto GAS con Web App deve avere la sezione `webapp` in `appsscript.json` DAL PRIMO GIORNO. Il redeploy clasp senza di essa distrugge la config "App web" della deployment esistente: l'URL /exec dava errore Drive perché la config viveva solo nella deployment creata dall'UI. Con la sezione nel manifest (nel repo), ogni deploy futuro la conserva. Nota: aggiornare il manifest remoto richiede `clasp push --force`. La Web App che funziona nel vivo e sparisce al deploy successivo è la bomba a orologeria che si disarma con una riga di JSON.

**Vedi anche**: `esegui-non-leggere` · `banco-browser-per-webapp-gas` · `diagnosi-differenziale-webapp-gas`
