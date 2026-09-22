# vivo-gia-in-git
**Àncora**: REPO-E Sistema-Gestione-Magazzino GAS+BC, sessione del deploy v78 (vedi
`docs/campo/2026-09-06-repo-e-sette-risposte-deploy-v78.md`) — 18 file su 18 già in git, che
assolse anche i 12 che `diff` dichiarava «diversi» · **Nato**: 2026-09-06 (il metodo dice «il
vivo è definitivo, si legge» — ma su un delta di 9.759 righe il diff file-per-file è
illeggibile, e una procedura illeggibile si salta: cercare il modo binario)

Prima di un push la domanda operativa non è «cosa è diverso dal vivo» — su un delta grande la
risposta è un muro di righe — bensì **«il vivo contiene qualcosa che git non ha mai visto?»**.
Quella è binaria, e git sa risponderla senza leggere niente:

```bash
clasp pull
for f in *.js Dashboard.html appsscript.json; do
  h=$(git hash-object "$f")
  git cat-file -e "$h" 2>/dev/null && echo "GIA IN GIT:  $f" || echo "NON IN GIT:  $f"
done
```

`hash-object` calcola lo sha del contenuto scaricato dal vivo; `cat-file -e` dice se quell'oggetto
esiste già nel database del repo. Se esiste, quel contenuto è stato committato: il vivo non ha
nulla di non versionato, e il push **non cancella lavoro in silenzio**. Se non esiste, quel file
ha dentro qualcosa che nessuno ha mai messo in git — e solo QUEI file (di solito zero, o pochi)
meritano il diff. Il «leggi il vivo prima di scriverci» smette di essere una regola e diventa un
numero. I file che il diff dichiara «diversi» sono spesso solo la distanza fra la versione
deployata e `main` — non una deriva: il test li assolve senza leggerli.

**Nota di famiglia**: è `gas-vivo-definitivo` reso eseguibile a costo zero — e il rovescio di
`clone-shallow-mente-sulla-storia`: lì il clone povero mentiva sul passato, qui il database
git intero viene interrogato sull'oggetto, non sulla storia dei rami.

**Vedi anche**: `gas-vivo-definitivo`, `clone-shallow-mente-sulla-storia`
