# patterns/ — i trucchi ancorati

Ogni pattern è uno snippet/rule **provato**, con l'ÀNCORA al codice che lo usa (file:funzione)
e la lezione che l'ha creato. Regola ereditata da `pattern-strumenti.js` di REPO-A:
**l'ancora deve esistere, o la voce non sopravvive** — lo snippet non ancorato è folklore.
Consumo: gli agenti citano il pattern nelle commesse invece di iniettare codice. La ricerca
oggi è il registro qui sotto; l'indicizzazione nel grafo richiede il pass semantico dei
documenti (DEBITI: da valutare se vale i token).

## Registro

| Pattern | Ancora | Nato il |
|---|---|---|
| [allowlist-per-segmento](allowlist-per-segmento.md) | night-shift/lib.sh:gate_allowlist_ok | 2026-08-21 |
| [ambiente-censimento-dichiarato](ambiente-censimento-dichiarato.md) | REPO-N | 2026-08-28 |
| [autorita-di-dominio-batte-oracolo](autorita-di-dominio-batte-oracolo.md) | REPO-S: CLAUDE.md (regola vincolante ufficio tecnico) | 2026-09-03 |
| [banco-browser-per-webapp-gas](banco-browser-per-webapp-gas.md) | progetto onboardato: dashboard.html/dashboard_scripts.html | 2026-08-21 |
| [banco-progetto-locale](banco-progetto-locale.md) | REPO-N | 2026-08-28 |
| [banco-sintetico-per-calcoli-critici](banco-sintetico-per-calcoli-critici.md) | REPO-G: tools/test-sp.js · gas/Sp.js:366 | 2026-08-21 |
| [chiave-stabile-etichetta-libera](chiave-stabile-etichetta-libera.md) | REPO-I: 2 punti ciclo Fase 3 | 2026-08-28 |
| [citazione-non-presidio](citazione-non-presidio.md) | REPO-A: tools/pattern-strumenti.js:senzaControllo | 2026-08-07 |
| [clasp-push-non-e-produzione](clasp-push-non-e-produzione.md) | REPO-K 3ª sessione (deployment versionato) | 2026-09-01 |
| [clone-shallow-mente-sulla-storia](clone-shallow-mente-sulla-storia.md) | REPO-S: git rev-parse --is-shallow-repository | 2026-09-03 |
| [collisione-namespace-globale-gas](collisione-namespace-globale-gas.md) | REPO-Q 2026-09-02 | 2026-09-02 |
| [confronto-non-vuoto](confronto-non-vuoto.md) | tests/test-opencode-agent-sync.sh:corpo() | 2026-08-28 |
| [contenitore-che-riscrive](contenitore-che-riscrive.md) | REPO-W: Foglio.gs isoDaCella_/valoreDiCella_ (report: docs/campo/2026-09-05-repo-w-quattordici-giri-revisione.md) | 2026-09-05 |
| [copertura-dal-glob](copertura-dal-glob.md) | questo hub: tests/test-skills-structure.sh, .night-verify | 2026-08-23 |
| [csv-con-python](csv-con-python.md) | night-shift/gate-summary.sh | 2026-08-21 |
| [cuore-unico-proprietario](cuore-unico-proprietario.md) | night-shift/night-shift.sh (probe/kickstart) | 2026-08-21 |
| [diagnosi-differenziale-webapp-gas](diagnosi-differenziale-webapp-gas.md) | REPO-E deploy v74 | 2026-09-02 |
| [dipendenza-tra-rami-paralleli](dipendenza-tra-rami-paralleli.md) | REPO-H: 2 occorrenze auto-corrette | 2026-08-27 |
| [doppio-livello-escaping](doppio-livello-escaping.md) | REPO-K: Scripts.html escapeJsAttr | 2026-08-28 |
| [due-verifiche-due-domande](due-verifiche-due-domande.md) | REPO-Q banco 2026-09-02 | 2026-09-02 |
| [edifact-release-character](edifact-release-character.md) | REPO-J: Parsers.gs split | 2026-08-28 |
| [esegui-non-leggere](esegui-non-leggere.md) | standard di verifica (SAL/dev-critic) | 2026-08-21 |
| [estensione-testata-non-distruttiva](estensione-testata-non-distruttiva.md) | REPO-G: Sheets.js estendiHeaderSeManca_ | 2026-08-27 |
| [estrattore-test-dipendenza-refactor](estrattore-test-dipendenza-refactor.md) | REPO-G: test-computeperiod.js estraiFunzioneRigaSingola | 2026-08-27 |
| [estrazione-llm-spezzata](estrazione-llm-spezzata.md) | Centrale_Rischi loops/2026-08-28 (spike misurato) | 2026-08-29 |
| [estrazione-per-testabilita](estrazione-per-testabilita.md) | REPO-I: quasi ogni fix del ciclo 2026-08-27 | 2026-08-27 |
| [forma-dei-dati-verificata](forma-dei-dati-verificata.md) | .github/ISSUE_TEMPLATE/night-shift.md | 2026-08-21 |
| [gas-vivo-definitivo](gas-vivo-definitivo.md) | skills/allineamento-fork (regola 1) | 2026-08-29 |
| [guardia-nel-ponte-non-nella-condivisa](guardia-nel-ponte-non-nella-condivisa.md) | REPO-F: AccessoWeb.gs (incidente 2026-08-15) | 2026-08-27 |
| [il-precedente-porta-il-vincolo-pagato](il-precedente-porta-il-vincolo-pagato.md) | REPO-Q 2026-09-02 | 2026-09-02 |
| [itera-su-array](itera-su-array.md) | night-shift/night-shift.sh (ROWS) | 2026-08-19 |
| [jq-slurp](jq-slurp.md) | night-shift/morning-gate.sh | 2026-08-21 |
| [la-riga-di-default-e-il-caso-peggiore](la-riga-di-default-e-il-caso-peggiore.md) | REPO-S: app/web/src/Configurator.tsx:185,1201 | 2026-09-03 |
| [la-staffetta](la-staffetta.md) | .ciclo/findings_storico + PRESIDI.md | 2026-08-31 |
| [lettura-esecuzione-precedente](lettura-esecuzione-precedente.md) | REPO-I: 5 moduli indipendenti | 2026-08-28 |
| [link-assoluti-e-decodifica-robusta](link-assoluti-e-decodifica-robusta.md) | REPO-CR doGet | 2026-09-01 |
| [lo-stub-che-mente-al-rovescio](lo-stub-che-mente-al-rovescio.md) | Controlli-trimestrali PR #103 | 2026-09-01 |
| [lock-per-risorsa](lock-per-risorsa.md) | night-shift/night-shift.sh (LOCK) | 2026-08-21 |
| [manifest-webapp-nel-repo](manifest-webapp-nel-repo.md) | REPO-CR appsscript.json | 2026-09-01 |
| [migrazione-con-interruttore](migrazione-con-interruttore.md) | REPO-Q split 2026-09-02 | 2026-09-02 |
| [misura-la-deriva-prima-di-assumerla](misura-la-deriva-prima-di-assumerla.md) | REPO-J: diff baseline vs HEAD | 2026-08-28 |
| [misura-prima-di-toccare](misura-prima-di-toccare.md) | REPO-E: risposte alle domande di dominio 6 e 7 | 2026-09-06 |
| [numero-col-suo-comando](numero-col-suo-comando.md) | REPO-E: report di campo 2026-09-06 (le 798 attese non riproducibili) | 2026-09-06 |
| [oracolo-dal-sistema-vecchio](oracolo-dal-sistema-vecchio.md) | REPO-S: tools/motore-test/harness.php | 2026-09-03 |
| [oracolo-indipendente](oracolo-indipendente.md) | REPO-A: tools/grafo-verifica.js (assi C/D) | 2026-08-21 |
| [pipefail-grep-sigpipe](pipefail-grep-sigpipe.md) | tools/ciclo-vivo.sh (lente collegamenti) | 2026-08-28 |
| [ponte-branch-usa-e-getta](ponte-branch-usa-e-getta.md) | REPO-J: live-snapshot via GitHub | 2026-08-28 |
| [presidio-senza-consumatori](presidio-senza-consumatori.md) | REPO-S: engine meta.warnings (zero consumatori) | 2026-09-03 |
| [regola-provata-non-assunta](regola-provata-non-assunta.md) | REPO-A: tools/test-motore.js:eq + blocco vm | 2026-07-30 |
| [riga-in-coda-non-interposta](riga-in-coda-non-interposta.md) | REPO-H: Main.gs generateCopertina_ | 2026-08-27 |
| [sabotaggio-plausibile](sabotaggio-plausibile.md) | REPO-V: settimana contata (report: docs/campo/2026-09-09-repo-v-settimana-errori-del-programmatore.md) | 2026-09-09 |
| [scarto-mai-silenzioso](scarto-mai-silenzioso.md) | progetto onboardato: Extractor.gs:applicaVincoliRange_ | 2026-08-21 |
| [segreto-come-impronta](segreto-come-impronta.md) | REPO-A: tools/maschera-segreti.js:mascheraSegreti | 2026-08-11 |
| [soglia-con-default-guardato](soglia-con-default-guardato.md) | REPO-I: soglie di legge indici di crisi | 2026-08-27 |
| [soglia-con-provenienza](soglia-con-provenienza.md) | REPO-A: tools/soglie.js:derive | 2026-08-07 |
| [somma-diversa-da-zero-non-e-presenza](somma-diversa-da-zero-non-e-presenza.md) | REPO-H: ProcessData.gs findDisposals (report: docs/campo/2026-08-27-revisione-cespiti-gas-bc.md) | 2026-08-27 |
| [stato-vuoto-dalla-pipeline](stato-vuoto-dalla-pipeline.md) | progetto onboardato: WebApp.gs:aggregaPerDashboard_ | 2026-08-21 |
| [test-che-certifica-il-bug](test-che-certifica-il-bug.md) | REPO-S: api/src/routes/orders.test.ts (where senza tenant) | 2026-09-03 |
| [tolleranza-derivata-non-scelta](tolleranza-derivata-non-scelta.md) | REPO-R ingestione 2026-09-02 | 2026-09-03 |
| [trovare-non-e-fallire](trovare-non-e-fallire.md) | REPO-A: tools/riallinea-mirror.sh:trova | 2026-08-12 |
| [verdetto-sempre-visibile](verdetto-sempre-visibile.md) | REPO-A: tools/banco-lib.js:verdetto | 2026-08-17 |
| [versione-sugli-artefatti](versione-sugli-artefatti.md) | REPO-A: tools/grafo-findings.js:221 | 2026-08-08 |
| [vivo-gia-in-git](vivo-gia-in-git.md) | REPO-E: deploy v78, 18/18 (report: docs/campo/2026-09-06-repo-e-sette-risposte-deploy-v78.md) | 2026-09-06 |
| [watchdog-guardato](watchdog-guardato.md) | night-shift/lib.sh:run_guarded | 2026-08-18 |
| [workdir-e-proprietario](workdir-e-proprietario.md) | regola processo (SAL 2026-08-21) | 2026-08-21 |
