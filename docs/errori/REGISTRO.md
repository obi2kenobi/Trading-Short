# Registro degli errori — ogni voce con: Data/sessione, Famiglia (R1-R6), Sintomo,
# Causa prossima, Causa del ragionamento, Perché non ci ha fermati, Guardia (+ file che esiste),
# Verifica guardia, Aggiramento. Dal 2026-09-09 (report REPO-V, settimana contata) anche:
# **Chi l'ha trovato** (lente / vivo / padrone del dominio) — è il dato che mostra l'asimmetria:
# le lenti prendono gli errori meccanici, il dominio quelli di giudizio. Obbligatorio da E-024.

## E-001 Il canone svuotato da un write anticipato
- Data / sessione: 2026-08-28 (100 giri del ciclo-vivo)
- Famiglia: R1 (assunzione non verificata)
- Sintomo: metodo.md da 314 righe a 9 — e la suite rimasta 103/103 verde.
- Causa prossima: `open(path,'w')` eseguito da Python PRIMA di un NameError
  successivo sulla stessa riga: il file troncato a zero subito, la scrittura
  mai avvenuta; il giro dopo ha riscritto sopra solo l'indice.
- Causa del ragionamento: «prima calcolo la stringa, poi scrivo» — il
  side-effect dell'apertura in scrittura è PRIMA del calcolo, ma a mente era
  dopo. L'ordine mentale del codice non è l'ordine di esecuzione.
- Perché non ci ha fermati: nessun test guardava il CONTENUTO del canone,
  solo l'esistenza. Un file svuotato soddisfa tutti i test di esistenza.
- Guardia: tests/test-canone-integrita.sh — sezioni portanti + soglia 10KB +
  indice che punta a file esistenti.
- Verifica guardia: canone svuotato a mano → rosso (provato in sessione).
- Aggiramento: write atomico (file .tmp + os.replace) nelle modifiche scriptate.

## E-002 I falsi positivi SIGPIPE della lente 2
- Data / sessione: 2026-08-28 (analisi dei 100 giri)
- Famiglia: R2 (verde senza dati) + R5
- Sintomo: il ciclo segnalava 34-39 pattern non citati, con numeri che
  cambiavano fra run identici (34, 36, 39, 5).
- Causa prossima: `echo "$GRANDE" | grep -q "$x"` sotto `set -o pipefail`:
  grep -q esce alla prima corrispondenza, echo prende SIGPIPE (141), la
  pipeline «fallisce» e il pattern CITATO risulta mancante.
- Causa del ragionamento: fiducia nello status della pipeline senza chiedersi
  chi può morire dentro la pipe. La non-deterministicità era l'indizio e
  è rimasta in vista tre run prima che qualcuno la guardasse.
- Perché non ci ha fermati: il finding «34 pattern mancanti» era PLAUSIBILE
  (i gap veri erano 33): un bug che produce quasi-il-vero non si nota.
- Guardia: tools/ciclo-vivo.sh (lente 2 grep -qF diretta sui file) +
  patterns/pipefail-grep-sigpipe.md (la regola portatile).
- Verifica guardia: 3 run consecutivi → stesso numero (fatto in sessione);
  l'attacco avversario C1 (gaming HTML) regge.
- Aggiramento: mai `cmd | grep -q` su cmd costoso sotto pipefail: si greppe
  il file, o si cattura l'output prima.

## E-003 Il test anti-drift che confrontava vuoto con vuoto
- Data / sessione: 2026-08-28 (lenti di architettura)
- Famiglia: R2 (verde senza dati)
- Sintomo: test-opencode-agent-sync verde da giorni mentre gli specchi erano
  driftati davvero (5 agenti su 6).
- Causa prossima: `corpo()` usava due `sed '1,/^---$/d'` concatenate: la prima
  consumava entrambe le recinzioni del frontmatter, la seconda non trovava
  `---` e per semantica sed cancellava fino a EOF. Estrazione sempre vuota,
  `diff vuoto vuoto` sempre verde.
- Causa del ragionamento: il test era stato scritto quando i corpi coincidevano
  DAVVERO: verde per coincidenza, non per verifica. Nessuno ha mai visto il
  test diventare rosso, quindi nessuno sapeva se sapesse.
- Perché non ci ha fermati: è il problema del teorema non testato: un test
  che non ha mai fallito non ha mai detto niente.
- Guardia: tests/test-opencode-agent-sync.sh (non-vuotezza prima del diff,
  conteggio righe) + patterns/confronto-non-vuoto.md (la regola portatile).
- Verifica guardia: corpo driftato iniettato a mano → rosso (provato); righe confrontate
  ora visibili nell'output (89, non più vuoto==vuoto).
- Aggiramento: leggere l'output del test, non solo l'exit code: un "OK"
  senza numeri è sospetto quanto un diff vuoto.

## E-004 L'harness avversario sull'albero sporco
- Data / sessione: 2026-08-28 (giri avversari)
- Famiglia: R3 (precondizione non chiesta)
- Sintomo: due fix della sessione spariti; verdenti a cascata senza senso
  (il deny «assente» mentre il suo test passava 10/10).
- Causa prossima: la batteria di mutazioni ripristinava con `git checkout --`
  su un albero che conteneva lavoro NON COMMITTATO: ogni ripristino
  cancellava i fix appena scritti.
- Causa del ragionamento: il precondition check l'avevo chiesto al sistema
  (gli avversari lo pretendevano) ma non a me stesso che lo stavo usando.
- Perché non ci ha fermati: nessuna guardia d'ingresso sullo stato dell'albero.
- Guardia: tools/mutation-tests.sh e tools/giri-avversari.sh (exit 2 su
  albero sporco) — ha già fermato l'autore stesso, due volte.
- Verifica guardia: file sporco → exit 2 con messaggio (provato; successo
  davvero, due volte, la seconda mentre committavo l'harness indurito).
- Aggiramento: `git stash` prima di attaccare, se il lavoro va tenuto.

## E-005 Le mutazioni leakate (il verdetto sì, lo stato no)
- Data / sessione: 2026-08-28 (giri avversari)
- Famiglia: R6 (effetto collaterale ignorato)
- Sintomo: dopo il run, 10+ file sporchi; le difese successive giudicavano
  un albero wreckato.
- Causa prossima: il restore era alla fine dell'attacco successivo (o mai):
  fra mutazione e ripristino passava un intero attacco, e le difese in mezzo
  valutavano lo stato inquinato.
- Causa del ragionamento: verificavo il verdetto di ogni attacco, mai lo
  stato complessivo fra un attacco e l'altro.
- Perché non ci ha fermati: la batteria usciva con un resoconto sensato:
  il report era pulito, il mondo no.
- Guardia: tools/giri-avversari.sh (`difesa_test` ripristina subito dopo il
  verdetto; trap EXIT con `git checkout -- .`).
- Verifica guardia: post-run `git status --porcelain` vuoto (provato).
- Aggiramento: dopo ogni harness di mutazioni, un `git status` a mani:
  costa un secondo, compra l'albero.

## E-006 La metrica che misurava un'altra cosa (due volte)
- Data / sessione: 2026-08-28 (giri di chiarezza)
- Famiglia: R2 (verde senza dati) + R5
- Sintomo: il censimento di chiarezza dichiarava «nudi» i file .py meglio
  documentati del repo (valorizzazione_magazzino: density 0.01).
- Causa prossima: contava i `#`, non le docstring: nei .py la documentazione
  STA nelle docstring — la metrica misurava lo stile, non la chiarezza.
- Causa del ragionamento: ho scritto la metrica prima di chiedermi «come si
  documenta un .py in QUESTO repo». E l'ho rifatta due volte (la seconda con
  l'header-intent) prima di guardare un file vero per falsificarla.
- Perché non ci ha fermati: produceva un risultato plausibile e ordinabile.
- Guardia: tests/test-chiarezza.sh (conta docstring+commenti; il caso noto
  più documentato deve risultare COMPLETO — la metrica si falsifica su un vero).
- Verifica guardia: valorizzazione risulta COMPLETO nella lente (provato).
- Aggiramento: ogni metrica nuova parte da un caso noto vero e uno falso.

## E-007 L'auto-copertura del probe
- Data / sessione: 2026-08-28 (self-test del banco)
- Famiglia: R4 (autoriferimento)
- Sintomo: il banco 7 dichiarava «presidiato» il file probe scoperto — perché
  il test che lo creava ne conteneva il nome.
- Causa prossima: il test cerca il basename nei test: il basename del probe
  era letterale nel test stesso.
- Causa del ragionamento: il tester e il testato condividevano il nome per
  comodità di scrittura.
- Perché non ci ha fermati: il banco era verde: il verde dell'autoriferimento
  somiglia al verde vero.
- Guardia: tests/test-banco-passaggio.sh (probe a nome runtime `$$`,
  il commento nel test spiega perché il nome letterale mentiva).
- Verifica guardia: probe runtime → banco rosso correttamente (provato).
- Aggiramento: i nomi di prova non si scrivono letterali dove si cerca.

## E-008 L'asserzione che citava un verdetto inesistente
- Data / sessione: 2026-08-28 (test del banco mutazioni)
- Famiglia: R5 (memoria contro realtà)
- Sintomo: test rosso con il banco VERDE: rc=0 e "FAIL run completo non
  pulito (rc=0)".
- Causa prossima: il grep del test cercava "test reagiscono, 0 teatri"; il
  verdetto reale è "test reagiscono alla mutazione, 0 teatri verdi".
- Causa del ragionamento: asserzione scritta A MEMORIA su come suonava
  l'output del tool che avevo scritto io stesso poche ore prima.
- Perché non ci ha fermati: nessuna verifica dell'assert contro l'output.
- Guardia: tests/test-mutation-tests.sh (l'asserzione citava un verdetto
  inesistente: ora la stringa è incollata dall'output reale del banco).
- Verifica guardia: test verde col verdetto reale (provato).
- Aggiramento: nelle asserzioni di stringa, `tail` dell'output vero accanto.

## E-009 Il test fantasma committato
- Data / sessione: 2026-08-28 (test di campo-triage)
- Famiglia: R3 + R6
- Sintomo: un test banale (`PASS=0; [ $PASS -ge 0 ]`) committato al posto di
  quello vero; il banco lo scopre come TEATRO.
- Causa prossima: il test originale non era MAI stato tracciato da git; un
  esperimento lo sovrascrisse; il `git checkout --` di ripristino fallì in
  SILENZIO (non-tracked); la copia di sicurezza in /tmp venne sovrascritta
  dalla seconda versione dell'esperimento stesso.
- Causa del ragionamento: ho creduto al ripristino senza controllarlo; e ho
  riusato lo stesso path di backup per due esperimenti diversi.
- Perché non ci ha fermati: il file esisteva e passava: due verdetti facili.
- Guardia: tools/banco-passaggio.sh (banchi 4 e 7) +
  tests/test-campo-triage.sh (ricostruito in sandbox, teatro-proof).
- Verifica guardia: neutralizzazione → rosso (provato).
- Aggiramento: `git ls-files <file>` prima di credere a un checkout; backup
  con nome unico per esperimento.

## E-010 L'edit incompleto verificato solo sintatticamente
- Data / sessione: 2026-08-28 (fix HOME di install.sh)
- Famiglia: R1 (assunzione non verificata)
- Sintomo: install.sh muore «USER_NAME: unbound variable» dopo il MIO fix.
- Causa prossima: il replace ha tolto la riga che definiva USER_NAME insieme
  al blocco che la usava restava.
- Causa del ragionamento: verificai con `bash -n` (sintassi) invece di
  eseguire: l'unbound variable è run-time, la sintassi non la vede.
- Perché non ci ha fermati: fretta fra due fix; il test vero arrivò subito
  dopo e lo prese — la guardia esisteva, il ragionamento l'aveva saltata.
- Guardia: tests/test-install.sh (esegue l'install vero nella HOME finta:
  l'unbound variable run-time lo prende al primo giro, bash -n mai).
- Verifica guardia: test-install rosso al primo giro dopo l'errore (provato).
- Aggiramento: nessuno: il costo di eseguire è sempre minore del costo di
  credere.

## E-011 Il contratto dichiarato e mai provato
- Data / sessione: 2026-08-28 (mutation-testing dei test)
- Famiglia: R2 (verde senza dati)
- Sintomo: test-backup-config passava col tool neutralizzato; scoperto poi
  che il tool moriva 127 in SILENZIO senza gh.
- Causa prossima: il test si auto-saltava quando gh era presente: il ramo
  «senza gh» non veniva mai esercitato nell'ambiente di chi sviluppava.
- Causa del ragionamento: skip per condizione d'ambiente comodo: la condizione
  era SEMPRE vera dove girava il test.
- Perché non ci ha fermati: tre OK verdi convincono.
- Guardia: tests/test-backup-config.sh (forza il ramo senza gh via PATH,
  niente skip d'ambiente) + tools/backup-config.sh (guardia gh esplicita).
- Verifica guardia: tool neutralizzato → rosso; senza gh → messaggio pulito
  (provati entrambi).
- Aggiramento: ogni skip condizionale va rivoltato: l'ambiente si SIMULA,
  non si aspetta.

## E-012 L'header fossile
- Data / sessione: 2026-08-28 (giri di chiarezza)
- Famiglia: R5 (memoria contro realtà)
- Sintomo: l'header di ciclo-vivo prometteva ciclo A-B-C, memoria in
  stato.json, generazione automatica di test, prioritizzazione: NULLA di
  tutto ciò esisteva nel codice.
- Causa prossima: header scritto al concepimento, mai aggiornato mentre
  l'implementazione divergeva (battito CUORE invece di A-B-C, file piatti
  invece di JSON, coda invece di generazione).
- Causa del ragionamento: la documentazione high-level si scrive una volta e
  si dà per stabile; il codice sotto continua a muoversi.
- Perché non ci ha fermati: nessuna lente confrontava le promesse
  dell'header con ciò che il codice fa.
- Guardia: tests/test-ciclo-vivo.sh (stato.json citabile solo come storia
  mai esistita) + tests/test-chiarezza.sh S1 (intent in testa, verificabile).
- Verifica guardia: header riscritto e presidiato; la verifica di guardia è
  la lente stessa (run verde dopo il fix, rossa se l'header torna a mentire).
- Aggiramento: quando leggi un header per capire, grepba la prima promessa
  concreta contro il codice: se la prima non torna, non fidarti delle altre.

## E-013 I glifi alieni che tornano (terza volta in un giorno)
- Data / sessione: 2026-08-28 (pattern, SAL, e DI NUOVO nel registro stesso)
- Famiglia: R5 (memoria contro realtà) — con ricorrenza
- Sintomo: caratteri CJK dentro parole italiane («alla自身的 pratica»,
  «in阳台», «driftato人工») — prodotti da un agente che scrive italiano.
- Causa prossima: contaminazione del campione di generazione: il modello
  inserisce glifi di un altro script in punti casuali del testo italiano.
- Causa del ragionamento: nessuno: è un difetto di generazione, non di
  giudizio — MA la terza volta nello stesso giorno dice che la guardia va
  resa più larga, non rasa al caso singolo.
- Perché non ci ha fermati: la prima volta è stata trovata a mano dai giri
  ignoranti (S1), le altre due dalla lente stessa. Il punto: SENZA lente,
  tre testi pubblici con glifi alieni sarebbero stati committati.
- Guardia: tools/giri-ignoranti.sh (sonda S1: CJK/cirillico/arabo su tutti
  i tracciati, escluso l'archivio storico).
- Verifica guardia: pianto un glifo → FIND immediato (provato in batteria,
  attacco C6 degli avversari).
- Aggiramento: rilettura umana dei diff per i testi in prosa; la lente per
  tutto il resto.

## E-014 La trappola pipefail-grep-q che rinasce in ogni test nuovo
- Data / sessione: 2026-08-29 (test-presidio, terza ricorrenza in due giorni)
- Famiglia: R5 (memoria contro realtà) + R2
- Sintomo: il test nuovo falliva proprio quando lo strumento funzionava (la
  CONTESA urlata non vista, il rilascio riuscito dichiarato fallito).
- Causa prossima: `cmd | grep -q X` con cmd multi-riga sotto pipefail: grep -q
  esce al primo match, cmd prende SIGPIPE, la pipeline dà 141 → il ramo `|| ko`
  scatta. Variante inedita scoperta insieme: `grep -c X file | grep -q "^0$"`
  — grep -c esce 1 quando conta ZERO, la pipeline fallisce quando è VERO.
- Causa del ragionamento: so scrivere la pipa prima di ricordare che sotto
  pipefail il verdetto è della pipeline intera, non dell'ultimo comando. È la
  terza volta CHE LA SCRIVO NUOVA sapendola — la conoscenza di un pattern non
  immunizza dal riscriverlo: solo la forma catturata-prima lo fa.
- Perché non ci ha fermati: i test fallivano in direzione «male» plausibile.
- Guardia: tests/test-presidio.sh (la forma catturata-prima, con il commento
  che spiega perché la pipa è vietata) + questa voce come memoria viva. La
  regola portatile: nei test, `OUT=$(cmd || true)` prima di greppare; per i
  conteggi-zero `! grep -q`, mai `grep -c | grep -q`.
- Verifica guardia: test-presidio 9/9 dopo la riscrittura; le celle vecchie
  della suite non usano più `cmd | grep -q` su verdetto.
- Aggiramento: quando serve proprio la pipa: `set +o pipefail` locale al check.

## E-015 Il gate del mattino che crasciava in silenzio sul conf vuoto
- Data / sessione: 2026-08-29 (domanda di Luca: «come è andato il lavoro notturno?»)
- Famiglia: R3 (precondizione non chiesta) + R2
- Sintomo: nessun gate dal 25/8; lanciato a mano: `REPO_LIST[@]: unbound variable`.
- Causa prossima: lista vuota (conf solo commenti) + `"${REPO_LIST[@]}"` sotto
  set -u su bash 3.2 = unbound, non lista vuota.
- Causa del ragionamento: il gate era sempre stato chiamato CON argomenti o da
  conf pieno: il caso vuoto mai provato. Il silenzio di 4 giorni è sembrato
  «niente da giudicare», non «il giudice non partiva».
- Perché non ci ha fermati: il morning-gate logga il proprio completamento:
  l'assenza di log nuova non alertava nessuno.
- Guardia: night-shift/morning-gate.sh (messaggio pulito + exit 1 su lista
  vuota; ${arr[@]+...} per bash 3.2).
- Verifica guardia: lanciato senza args/conf → messaggio e rc=1 (provato);
  tests/test-morning-digest.sh presidia il battito (GIUDICE FERMO se gate non completa).
- Aggiramento: chiamare il gate con le repo esplicite (come fatto fino al 25).

## E-016 Il medesimo report processato due volte in parallelo
- Data / sessione: 2026-08-31 (REPO-G, due sessioni, ~1h di distanza)
- Famiglia: R3 (precondizione non chiesta) + R4
- Sintomo: push rifiutato; il remoto conteneva il report già processato da un'altra sessione.
- Causa prossima: nessuna delle due sessioni ha dichiarato il presidio prima di iniziare.
- Causa del ragionamento: il presidio esiste dalla vigilia ma «processare un report» non
  è stato riconosciuto come LAVORO SU UNA ZONA (sembra lettura, è scrittura).
- Perché non ci ha fermati: la collisione è stata BENIGNA per costruzione (convenzione
  date-slug: stesso report → stesso file → nessuna divergenza) — il danno è stato solo
  lavoro duplicato, e il verde finale ha nascosto lo spreco.
- Guardia: tools/presidio.sh (claim prima di processare) + la regola scritta nella
  skill lavoro-condiviso §1bis: il processing di un report dal campo È un lavoro su zona.
- Verifica guardia: il claim contesa avvisato nelle prove del turno stesso (9/9 test).
- Aggiramento: la convenzione dei nomi rende comunque idempotente l'esito: tenuta.

## E-017 Tre notti perse: il turno incastrato invisibile
- Data / sessione: 2026-08-31 (scoperta alla domanda «come sono andate le ultime notti?»)
- Famiglia: R2 (verde/silenzio senza dati) + R1
- Sintomo: nessun TURNO FINITO dal 28/8; nessun turno avviato il 29 e 30; silenzio totale.
- Causa prossima: opencode in loop di rilettura MAI tornato (~59h, 104h CPU); il job
  vivo ha impedito a launchd di avviare i turni seguenti (niente doppioni).
- Causa del ragionamento: la decisione «nessun limite di tempo» (Luca, 21/8) presupponeva
  «la guardia è la review del mattino» — ma la review non aveva NIENTE da guardare: il
  gate era rotto (E-015) e nessuno strumento mostrava un processo vivo da 59 ore.
- Perché non ci ha fermati: l'assenza di log sembrava coda vuota (stessa famiglia del
  gate muto).
- Guardia: tools/turno-vivo.sh (detector del processo oltre soglia, in system-health;
  non uccide: VISIBILITÀ, la scelta del rimedio resta della review del mattino) +
  DEBITI «il turno senza limite ha bruciato 3 notti» per la decisione del watchdog.
- Verifica guardia: girato oggi: nessun processo attivo → rc 0 (caso sano provato;
  il caso rotto è il documento stesso di oggi: 59h reali).
- Aggiramento: pkill -f "opencode run" (pulizia consolidata), il turno si scioglie.

## E-018 L'agente genera il comando, l'umano lo esegue, il confine salta
- Data / sessione: 2026-09-02 (REPO-Q, incidente reale post-audit)
- Famiglia: R1 (assunzione non verificata) + R3 (precondizione non chiesta)
- Sintomo: clasp push da REPO-Q ha sovrascritto il live di 2 progetti sviluppati altrove.
- Causa prossima: l'agente ha generato un loop di comandi che includeva directory dichiarate
  clone-di-sola-lettura nel CLAUDE.md, senza verificarle. Luca le ha eseguite correttamente.
- Causa del ragionamento: la regola «clasp push MAI da agente» era rispettata alla lettera —
  ma il rischio stava nella GENERAZIONE del comando, non nell'esecuzione.
- Perché non ci ha fermati: la guardia clasp-block-hook DENY blocca l'agente che esegue,
  non l'agente che consiglia. Il push è arrivato da un umano su un altro repo.
- Guardia: tools/clasp-block-hook.sh (check .mirror-boundaries) + pattern
  clasp-push-non-e-produzione (addendum generazione).
- Verifica guardia: il caso reale è il documento stesso; l'hook compila e i test passano.
- Aggiramento: nei repo multi-mirror, creare .mirror-boundaries con gli scriptId vietati.

## E-019 Il plist su disco e il job caricato dicono due copie diverse
- Data / sessione: 2026-09-03 (scoperta pre-notte, prima che scattasse)
- Famiglia: R2 (silenzio: tutto sembrava installato) + R1 (assunzione non verificata)
- Sintomo: il plist on-disk puntava alla copia workspace (con repos.conf VUOTA per privacy),
  ma il job caricato in launchd girava ancora dalla copia night-shift-work (con la coda reale).
  Al prossimo reboot/reload il turno sarebbe partito sulla copia sbagliata: notte di no-op
  silenziosa, "nessuna issue night-shift, Buonanotte" — senza che nessuna repo fosse in coda.
- Causa prossima: il 28/8 install.sh è stato rieseguito DALLA COPIA WORKSPACE: lo script fa
  del repo dove gira la fonte di verità ("HUB") e ha riscritto il plist verso il workspace;
  il bootstrap successivo è fallito in silenzio (2>/dev/null), lasciando vivo il vecchio job.
- Causa del ragionamento: "idempotente: rieseguire non rompe nulla" — vero per i symlink,
  falso per il puntamento: rieseguire DA UNA COPIA DIVERSA cambia quale copia è produzione.
  Nessuna verifica che il job caricato corrispondesse al plist appena scritto.
- Perché non ci ha fermati: launchctl list mostra solo etichetta e rc; il divergenza on-disk
  vs caricato è invisibile finché non si fa launchctl print. I turni continuavano a partire.
- Guardia: night-shift/install.sh (verifica post-bootstrap che il job caricato punti
  davvero all'HUB appena installato + avviso se l'HUB è dentro una workspace di sviluppo).
- Verifica guardia: eseguito oggi: allineato plist+job su night-shift-work (f8d8092, coda
  reale 4 repo, albero pulito); preflight modello ripassato sotto PATH launchd nudo.
- Aggiramento: rifare l'installazione SOLO dalla copia di automazione (night-shift-work),
  mai dalla workspace di sviluppo.

## E-020 La verifica è passata perché girava in un'altra shell (E-002, 4a ricorrenza)
- Data / sessione: 2026-09-04 (notte del 3/9 persa, diagnosi mattutina)
- Famiglia: R1 (assunzione non verificata) + R2 (verde senza dati)
- Sintomo: turno morto alle 23:00:03 col messaggio "modello assente" — col modello
  PRESENTE, il server attivo e la richiesta /api/tags servita con 200 (nei log GIN).
  Terza notte persa; stessa firma delle due precedenti, causa DIVERSA.
- Causa prossima: `ollama list | grep -q "$MODEL_TAG"` sotto `set -uo pipefail`:
  grep -q esce al primo match, ollama list prende SIGPIPE scrivendo le righe restanti,
  rc 141, pipefail boccia la pipeline. Dimostrato: la forma vecchia fallisce 199/200
  oggi; la forma curata (cattura-prima) 100/100.
- Causa del ragionamento: il preflight del 3/9 ha provato la pipeline in una bash
  FRESCA senza `set -o pipefail` — le condizioni della verifica non erano le condizioni
  della produzione. Un test che non riproduce l'ambiente del bug non può certificare che il
  bug non c'è.
- Perché non ci ha fermati: il messaggio d'errore ("modello assente") era plausibile
  e coincideva col fallimento REALE del 2/9 (PATH) — due cause diverse, una firma sola.
- Guardia: tests/test-risolvi-issue.sh (igiene E-002: nessuna pipeline grep -q nei
  tool del turno + i tre esiti del solver contro un server mock) e cattura-prima in
  night-shift/night-shift.sh, night-shift/install.sh, night-shift/risolvi-issue.sh.
  Bonus colto dal test: il solver risolveva i percorsi del Territorio contro la CWD
  del chiamante invece di $DIR — in produzione non avrebbe MAI applicato direttamente.
- Verifica guardia: check modello curato 100/100 sotto pipefail; suite con il test
  nuovo a verde; forma vecchia 199/200 fallimenti (il documento della corsa).
- Aggiramento: nessuno voluto — la corsa SIGPIPE è il nemico, non un'opzione.

## E-021 Il log diceva "committato e pushato" mentre il commit era morto
- Data / sessione: 2026-09-04 (prova dal vivo su repo sandbox, 6 giri)
- Famiglia: R2 (verde/silenzio senza dati) + R1 (assunzione non verificata)
- Sintomo: solver OK (9s, fix applicato, node --check verde) ma NESSUNA PR: set -u
  uccideva il commit (la variabile si chiama CTYPE, il codice diceva TIPO) e la riga
  dopo affermava comunque "fix committato e pushato". La PR poi cadeva per un push
  mai avvenuto — con contatore a "1 PR bozza" anche quando la PR era "aborted".
- Causa prossima: quattro difetti in cascata nella consegna: TIPO/CTYPE; esito del
  commit non controllato (log incondizionato); PR senza --draft né --head/--base
  espliciti; push del branch night/* con lease nudo che legge l'upstream di main
  (ereditato dal checkout -B su clone single-branch) e rifiuta sempre "stale info".
- Causa del ragionamento: il pezzo di consegna (commit→push→PR) non era mai stato
  provato dal vivo END-TO-END: i 20 test del 2/9 provavano il solver, le notti vere
  morivano prima di arrivarci. Il codice dopo il primo successo presunto non aveva denti.
- Perché non ci ha fermati: il log affermava il successo — il contrario di un silenzio:
  un dato falso è più difficile da sospettare di un'assenza.
- Guardia: tests/test-risolvi-issue.sh (che presidia il solver) + la prova sandbox
  documentata qui; il log di consegna ora riporta l'esito del COMANDO (commit/push
  fallito = warning + contatore FAILED), PR solo --draft con --head/--base espliciti,
  push -u con lease al valore atteso letto dal refspec esplicito.
- Verifica guardia: 6° giro: PR bozza #3 creata (draft: true, solo il file target),
  fix corretto (percentuale + Math.max 0), 7° giro: "PR già aperta, skip" (idempotenza).
- Aggiramento: verrebbe voglia di --force secco sul push: il lease al valore atteso
  protegge la stessa cosa senza aprirla a tutti.

## E-022 La proposta spedita come PR: PATCH valeva come successo
- Data / sessione: 2026-09-05 (primo turno riuscito, notte del 4/9)
- Famiglia: R1 (assunzione non verificata) + R2 (il contatore diceva 1 PR)
- Sintomo: PR #16 sul Bilancio con dentro SOLO scarti: il .night-patch proposto e
  l'App.html.night-bak intero (+739 righe). Nessun fix applicato, contatore "1 PR bozza".
- Causa prossima: il solver esce 0 sia quando APPLICA sia quando PROPOSE (PATCH mode);
  il turno tratta rc=0 come "fix consegnato" → git add -A committa patch e bak.
  Il bak non veniva rimosso quando la sostituzione falliva (grep trova la funzione,
  la regex a colonna zero no — la notte l'ha lasciato lì).
- Causa del ragionamento: contratto d'uscita ambiguo — "0 = tutto bene" copriva due
  esiti che meritano azioni opposte (celebrare la PR vs pubblicare una proposta).
  Un codice d'uscita che non distingue non è un contratto.
- Perché non ci ha fermati: il turn era finito VERDE (TURNO FINITO, 1 PR bozza) —
  il primo mai completato. Il successo recente abbassa la guardia sul contenuto.
- Guardia: night-shift/risolvi-issue.sh (exit 3 = proposta; bak rimosso se la
  sostituzione fallisce) + tests/test-risolvi-issue.sh (caso PROPOSTA: exit 3 e
  nessun bak in giro) + il turno pubblica la proposta come commento all'issue,
  mai come PR (contatore PROPOSTE separato).
- Verifica guardia: test 6/6 (APPLICATO / PATCH exit 3 / PROPOSTA senza bak / RIFIUTO).
  Il caso reale: PR #16 chiusa, proposta ripubblicata nell'issue #10.
- Aggiramento: le Feature (funzioni nuove + wiring) restano proposte fino al debito
  DEBITI "solver: inserzione di funzioni nuove".

## E-023 L'ottimizzazione che bloccava la capacità nuova
- Data / sessione: 2026-09-08 (notte del 7/9, la prima con l'inserzione)
- Famiglia: R1 (assunzione non verificata: "la proposta è lo stato finale")
- Sintomo: l'issue #10 saltata "SENZA rigenerare" un secondo dopo l'apertura: la prima
  inserzione vera del solver non è mai partita. La notte è finita verde e onesta — e non
  ha fatto il lavoro che esisteva per fare.
- Causa prossima: il check pre-solver sulla proposta esistente (nato il 7/9 per risparmiare
  i 262s di GPU della rigenerazione) scattava prima che il solver potesse provare la
  capacità nuova. Presupponeva che un commento di proposta fosse definitivo.
- Causa del ragionamento: l'ottimizzazione è stata costruita sul mondo di ieri (proposta =
  stato finale) senza rileggere la stratificazione dei presidî: PR aperta → skip (stava già
  sopra, prima di tutto); proposta effettiva di stanotte → niente duplicati (check nel ramo
  RC=3). Il check pre-solver era il terzo strato, quello che non serviva.
- Perché non ci ha fermati: il log diceva una cosa VERA ("proposta già pubblicata") — un
  messaggio corretto per il mondo in cui era stato scritto.
- Guardia: night-shift/night-shift.sh (la stratificazione al posto del check: PR → skip;
  RC=3 → commento idempotente; il ritento con capacità migliore non è spam), presidiata da
  tests/test-flusso-artefatti.sh.
- Verifica guardia: il turno rilanciato a mano sul Bilancio ha processato la #10 col solver
  (vedi SAL 2026-09-08): l'inserzione ha avuto la sua battuta.
- Aggiramento: se una proposta resta la proposta (RC=3), il check nel ramo evita i duplicati.

## E-024 I rilevatori mentono: tre verdicti plausibili su casi falsi, in un'ora
- Data / sessione: 2026-09-09 (dieci giri di rilettura integrale)
- Famiglia: R1 (assunzione non verificata: il rilevatore funziona)
- Chi l'ha trovato: la sessione stessa, applicando «verifica la cosa stessa, non quella accanto» al proprio rilevatore
- Sintomo: 59 riferimenti pendenti inesistenti dichiarati dalle skill (erano tutti veri); poi
  la S16 restava rossa su un indice appena rigenerato; la S17 non mordeva il proprio fixture.
- Causa prossima: tre difetti di rilevatore in cascata — cwd di default invece del repo,
  concatenazione '.'+path senza slash ('.SAL.md'), ricerca di una tabella dove l'indice è
  una lista puntata.
- Causa del ragionamento: i rilevatori vengono scritti e CREDUTI: nessuno verifica il
  verificatore col caso noto prima di fidarsi del suo verdetto. È la stessa famiglia di
  E-020 (verifica nelle condizioni sbagliate) portata dentro gli strumenti dell'hub.
- Perché non ci ha fermati: i verdicti erano plausibili e locali — un elenco di falsi
  pendenti sembra lavoro fatto, non un bug del misuratore.
- Guardia: tools/prova-rilevatori.sh (l'antivirus: canarini in quarantena per ogni sonde
  che conta — pianta il difetto noto, pretende quel FIND, clone pulito verde) +
  tests/test-prova-rilevatori.sh nel banco + autoasserzioni dentro i rilevatori (S17).
- Verifica guardia: 4/4 canarini tenuti, clone pulito verde, morso provato.
- Aggiramento: un rilevatore nuovo senza canarino nell'antivirus — la regola del canone
  («nasce col canarino dentro, o è un'opinione con l'uniforme da controllo») lo vieta.

## E-025 I nomi veri sono entrati nella repo pubblica (e pure nel mio SAL)
- Data / sessione: 2026-09-14 (report della settimana dello specchio, committuto da sessione parallela)
- Famiglia: R2 (ho agito senza la guardia) + R1 (presupposto repos.key operativo)
- Chi l'ha trovato: la sessione che processava il report, rileggendo il file appena arrivato
- Sintomo: report di campo pushato sull'hub pubblico con nome della repo, nome del partner
  (due società) e due persone. Quattro commit nella storia. E una riga del SAL (9/9) col
  nome della repo — scritta DENTRO la frase che documentava l'anonimizzazione.
- Causa prossima: repos.key è vuota su questa macchina per design (i termini entrano "solo
  dopo lo spurgo della storia git", DEBITI 24/8) e privacy-check gira degradato senza
  dire niente a nessuno che stesse committendo; nessun controllo alla frontiera del commit.
- Causa del ragionamento: il gate della privacy viveva nel banco (che si lancia a fine
  passaggio) e non alla frontiera (dove si committa): un report scritto di fretta da una
  sessione nuova passa dalla frontiera, non dal banco.
- Perché non ci ha fermati: il pre-commit controllava path, glifi, CRLF e citazioni —
  tutto tranne il contenuto umano dei nomi.
- Guardia: tools/pre-commit.sh controllo 7 — i .md in committa contro ~/.privacy-nomi
  (chiave in HOME: sopravvive ai cloni, dominio di fidusta giusto); assente = DEGRADATO
  FORTE a ogni commit, mai silenzio. Morso provato (nome del partner iniettato → rc 1).
- Verifica guardia: bonifica dei file vivi (zero residui), morso rc=1, file rinominato
  alla convenzione REPO-V.
- Aggiramento: rimuovere un nome da ~/.privacy-nomi senza contratto che lo dichiara
  pubblico — la lista è della persona, non della sessione.

## E-026 La notte che non è mai partita: la registrazione spuria teneva il posto
- Data / sessione: 2026-09-16 (notte del 15/9, prima della finestra 23-06)
- Famiglia: R2 (ho agito — ripristinato il plist — senza verificare l'effetto) + R1
- Chi l'ha trovato: il mattino, leggendo una console ferma alle 20:37
- Sintomo: zero turni in tutta la finestra 23-06. La console mostra un solo spettro
  (20:37, fuori finestra) e un accesso alle 23:00 uscito col lock «turno precedente
  ancora in corsa» — su un turno MORTO da due ore (lock orfano: morto senza trap).
- Causa prossima: il bootstrap di ripristino del plist ha fallito (rc 5) una volta;
  il ripiego ha lasciato attiva una registrazione il cui PATH punta a un plist in una
  directory TMP — quella ha sparito lo scettro delle 20:37 e scritto altrove. Il plist
  di casa (23-06) e' rimasto su disco MAI CARICATO. Il Mac ha poi dormito (senza
  caffeinate non c'e' stato nulla a tenerlo sveglio).
- Causa del ragionamento: dopo il bootstrap ho verificato stato e calendario DEL PLIST
  SU DISCO, non il PATH DEL JOB CARICATO. Contano le cose caricate, non quelle scritte.
- Perché non ci ha fermati: il controllo di E-019 verifica il puntamento dell'HUB dentro
  il job, non QUALE plist abbia generato il job.
- Guardia: tools/system-health.sh (il job nightshift caricato deve puntare al plist di
  casa; registrazione spuria → ROSSO col rimedio scritto). E il lock orfano: soglia 3h
  gia' prevista, ma alle 23:00 il lock aveva 2.4h e ha mentito — la soglia si abbassa
  a 1h (un turno che dura piu' di un'ora e' gia' un'anomalia da guardare, non da aspettare).
- Verifica guardia: stamattina il dente dice OK col path di casa; il lock orfano rimosso a mano.
- Aggiramento: rifare il bootstrap SENZA guardare launchctl print path = .

## E-027 Il riclono pulito che mangiava lo stato locale
- Data / sessione: 2026-09-16 (test definitivo, ciclo delle 09:53)
- Famiglia: R2 (autodistruzione su percorso di ripristino non provato) + R1
- Chi l'ha trovato: il test definitivo richiesto da Luca (09:30-10:00-11:00)
- Sintomo: la copia di automazione SPARITA. Il prep del turno ha fallito checkout
  (strascico di un'interferenza manuale), ha fatto il suo «riclono pulito» (rm -rf),
  e il clone e' fallito a sua volta: coda, chiave privacy e memoria del turno —
  tutto GITIGNORED, tutto CANCELLATO, nessuna copia altrove.
- Causa prossima: il percorso di auto-riparazione distruggeva lo stato locale prima
  di avere la sua sostituzione, e non era mai stato provato fino in fondo (falliva
  PRIMA del rm nelle prove).
- Causa del ragionamento: «riclono pulito» trattava la copia come usa-e-getta, ma
  la copia porta FILES GITIGNORED che non vivono DA NESSUNA PARTE ALTRO: non e'
  usa-e-getta. Lo stato locale e' parte del sistema.
- Perché non ci ha fermati: il clone era sempre riuscito, il ramo rm+clone non
  girava mai — fino alla mattina in cui la rete era ballerina.
- Guardia: night-shift/night-shift.sh (salvataggio in .state-salvate prima del
  rm, ripristino dopo il clone riuscito).
- Verifica guardia: la coda e la chiave ricostruite a mano stamattina (contenuto
  noto dalla sessione); il percorso ora provato dal caso reale.
- Aggiramento: interferire manualmente con la copia mentre il turno gira —
  il trigger dell'intera cascata era quello (dichiarato: colpa dell'operatore).

## E-028 La dashboard committata che non compilava
- Data / sessione: 2026-09-17 (pomeriggio, mentre si costruiva la caccia-miglioria)
- Famiglia: R1 (verde che mente) + E-002 (righe fuse da scrittura automatizzata)
- Chi l'ha trovato: la suite (.night-verify S2 rossa su dashboard.py) durante la
  verifica del lavoro di oggi — non un occhio umano, il gate.
- Sintomo: tools/dashboard.py com'era committato NON compilava. Due istruzioni
  fuse da un '\n' letterale (paste/scrittura andata storta nel commit 'dashboard
  v3'), e la logica 'verifiche ultimo ciclo' PROMESSA da quel commit era sparita
  (s["verifiche"] mai riempito: la pagina diceva sempre 'tutte verdi'). La
  dashboard sullo schermo girava bene perche' il processo era partito PRIMA del
  danno: il codice in memoria copriva il codice sul disco.
- Causa prossima: una scrittura ha fuso due righe in una, e nessun controllo
  verificava la sintassi dei .py prima del commit.
- Causa del ragionamento: .night-verify compilava gli .sh (shellcheck) ma i .py
  li guardava solo con sonde basate su regex (docstring, densita') — una riga
  fusa passa tutte le regex. Un file che non parte non puo' passare nessun gate
  a base di lettura: serve ESEGUIRLA, la sintassi.
- Perché non ci ha fermati: il processo vivo mascherava tutto (la finestra di
  Luca funzionava), e la S2 era rossa per la densita' — il sintomo visibile
  (pochi commenti) era vero ma secondario; nessuno ando' a compilare il file.
- Guardia: tests/test-dashboard.sh prova la logica con un log finto a casi
  noti, e il gate .night-verify compila OGNI .py tracciato (compile() su tutti
  i git ls-files '*.py') — un file rotto e' rosso al banco, sempre.
- Verifica guardia: bash .night-verify verde con la dashboard riparata; il
  compile() rosso provato sul file corrotto prima della riparazione.
- Aggiramento: committare .py solo dopo che un processo nuovo li ha caricati
  (il riavvio della dashboard, non il processo che gira da ore).

## E-029 Il gate nuovo che urlava al lupo ogni notte
- Data / sessione: 2026-09-18 (prima notte del gate py, turno delle 13:10)
- Famiglia: R3 (contratto implicito violato) + R1
- Chi l'ha trovato: il turno stesso — VERIFICA ROSSA ripetuta a ogni ciclo con
  il gate py appena aggiunto, mentre lo stesso gate girava verde a mano.
- Sintomo: la riga py di .night-verify risultava ROSSA solo quando la eseguiva
  il turno. A mano: verde. Nel log: `(eval):[:1: unknown condition: -eq`.
- Causa prossima: il turno esegue ogni riga di .night-verify come
  `eval "ai_timeout 120 <riga>"` — ai_timeout esegue UN COMANDO. La riga
  iniziava con `PYFAIL=0; for ...`: l'assegnazione diventava ARGOMENTO di
  ai_timeout (mai assegnata), e la coda `[ $PYFAIL -eq 0 ]` moriva di unary
  con la variabile vuota.
- Causa del ragionamento: il contratto «una riga = un comando eseguibile da
  timeout(1)» era IMPLICITO — mai dichiarato in .night-verify, mai provato da
  un test. E la riga storica della suite (`N=0; TOT=...`) lo violava da
  sempre, sopravvivendo perche' finiva per caso con un echo: il verde di
  fortuna normalizzava il pattern rotto.
- Perché non ci ha fermati: il turno deduplica i rossi in una issue e aspetta
  il giorno — un falso rosso stabile non disturba nessuno finche' qualcuno
  non legge la riga con i suoi occhi (diag: stesso comando, due esiti).
- Guardia: tools/py-gate.sh e tools/suite.sh (un comando per riga, testati da
  tests/test-py-gate.sh che respinge le righe composte con assegnazione) e il
  contratto dichiarato a voce nei commenti di .night-verify.
- Verifica guardia: il loop del turno simulato con source llm/_timeout.sh —
  rosso prima, verde dopo; il contratto controllato dalla suite a ogni giro.
- Aggiramento: scrivere in .night-verify righe shell composte che iniziano
  con un'assegnazione — ripassa il controllo del contratto a ogni commit.

## E-030 Il test che si mangiava le verifiche successive
- Data / sessione: 2026-09-18 (pomeriggio, osservando il turno: 5/5 invece di 6/6)
- Famiglia: E-002 (stdin condiviso tra pipe e redirect) + R1
- Chi l'ha trovato: il turno stesso — conteggio costante 5/5 su un file da 6
  righe, per due cicli di fila. La discrepanza era nel log, visibile a chi
  contasse le righe dichiarate.
- Sintomo: `.night-verify 5/5 verdi` con 6 righe dichiarate. La riga della
  sal-indice non veniva MAI eseguita dal turno (solo a mano), da sempre.
- Causa prossima: il loop legge il file con `< .night-verify`; il comando
  eval'ato dentro eredita quello stdin. Un test della suite legge stdin e
  divora le righe successive del file: il loop finisce una riga prima.
- Causa del ragionamento: e' lo stdin condiviso di E-002 in forma di file
  redirect. Non emergeda finche' la suite MORIVA a 120s (timeout): il test
  divorante stava oltre i 120s. Il budget @420 della suite l'ha fatta girare
  completa per la prima volta — e il verde silenzioso e' diventato conteggio
  visibile. Ogni limite tolto rivela chi si nascondeva dietro.
- Perché non ci ha fermati: 5/5 verdi sembrava successo; la riga saltata era
  l'ultima del file e non lasciava traccia del salto (nessun rosso mancato).
- Guardia: night-shift/night-shift.sh e night-shift/morning-gate.sh eseguono le
  verifiche dichiarate con `</dev/null` — il comando non tocca MAI il file che
  alimenta il loop. Dimostrato: loop con `cat` in mezzo, 2 comandi senza cura,
  3 con.
- Verifica guardia: riprodotto in sandbox (cat divora la riga successiva senza
  </dev/null, non la tocca con); il turno al giro dopo conta 6/6.
- Aggiramento: un comando in .night-verify che legga stdin — ora innocuo, ma
  se legge input INTERATTIVO aspettera' fino al timeout (dichiarato).

## E-031 La caccia sana che il turno chiamava fallita
- Data / sessione: 2026-09-18 (pomeriggio — tre 'caccia non ha converto' di fila
  mentre integravo la caccia-miglioria)
- Famiglia: R4 (interfaccia con contratto invertito) + R1
- Chi l'ha trovato: il log del turno, leggendo tre rc=1 di fila come 'fallita'
  e chiedendosi perche' la miglioria non partiva MAI nei giri buoni.
- Sintomo: 'caccia non ha converto (rc=1)' a ogni giro sano; 'caccia pulita'
  + cooldown quando la lente trovava PROBLEMI. La caccia-miglioria partiva
  solo su rc=0 — cioe' solo quando c'erano problemi: la finestra sbagliata.
- Causa prossima: caccia-lente esce 0 = problemi trovati, 1 = sana. Il turno
  integrava rc=0 come 'trovato e corretto' e rc=1 come 'non ha converto':
- Causa del ragionamento: il contratto degli exit code era scritto SOLO nel
  codice della caccia, mai dichiarato al punto d'uso. Chi integra legge il
  proprio assunto (0=bene) invece della fonte. L'ambiguita' era anche dentro
  caccia-lente: rc=1 significa 'sana' MA anche 'strumento muto'.
- Perché non ci ha fermati: 'non ha converto — nessun problema, riprova al
  prossimo giro' suona innocuo: un fallimento ripetuto con tono rassicurante
  non urta, e il sistema non moriva.
- Guardia: night-shift/night-shift.sh dichiara il contratto rc al punto d'uso
  (rc=0=lente segnala, rc=1=sana) e la miglioria parte nella finestra giusta
  (SANA). Il log ora DISTINGUE: 'lente dichiara sana' vs 'LENTE SEGNALA'.
- Verifica guardia: il log del turno dopo il fix mostra la lente sana seguita
  dalla miglioria; i turni con rc=0 riportano il verdetto della lente.
- Aggiramento: cambiare il contratto degli exit di caccia-lente senza
  aggiornare il punto d'uso (e viceversa).

## E-032 Il canarico piantato nel repo vivo
- Data / sessione: 2026-09-18 (test di un'ora, seconda ora — fantasma attivo
  dalle 17:21)
- Famiglia: E-002 (stato condiviso) + R1
- Chi l'ha trovato: il banco, per un pomeriggio: FIND S1 caratteri alieni
  DEBITI.md a intermittenza — rosso, verde, rosso — con il file PULITO a ogni
  controllo a riposo.
- Sintomo: FIND S1 DEBITI.md fantasma nel banco del turno, alternato a banchi
  verdi, senza che DEBITI.md contenesse mai glifi a riposo (md5 identico alle
  copie pulite).
- Causa prossima: tests/test-giri-ignoranti.sh piantava il suo canarico CJK
  NEL DEBITI.md DEL REPO VERO e lo ripristinava col checkout: per la durata
  del test il glifo era visibile a OGNI batteria ignoranti sovrapposta (il
  banco del turno, il banco dentro la suite). Se il ripristino sfiorava una
  operazione git del turno, il canarico restava in campo per il giro dopo.
- Causa del ragionamento: il canarico era un fixture senza quarantena —
  prova-rilevatori.sh, nato due settimane prima, lavorava gia' in clone di
  quarantena per ESATTAMENTE questo motivo. La lezione non era stata portata
  ai test delle sonde.
- Perché non ci ha fermati: il finding era VERO nel momento in cui la S1 lo
  vedeva (il glifo c'era davvero!) — un falso positivo perfettamente onesto:
  il difetto era il palcoscenico, non l'attore.
- Guardia: tests/test-giri-ignoranti.sh pianta in clone di quarantena (git
  clone --local + gitignored portati a mano): il repo vivo non vede MAI il
  canarico, e non esiste ripristino che possa mancare — la quarantena si butta.
- Verifica guardia: test 13/13; il banco del turno con per-run log e sonde
  pulite nei giri successivi.
- Aggiramento: piantare fixture nei file del repo vivo invece che in
  quarantena — la suite gira dentro il sistema che prova.

## E-033 Il riclono che cancella prima di verificare
- Data / sessione: 2026-09-19, 13:26 (turno FERMO 40 minuti, beccato da turno-vivo)
- Famiglia: R2 (autodistruzione su percorso di ripristino) + R1
- Chi l'ha trovato: turno-vivo, il detector del log fermo («TURNO INCASTRATO:
  ultimo ciclo 40 minuti fa») — prima cattura reale dall'aggiornamento
  all'era continua.
- Sintomo: il turno FERMO. exec "$0" con lo script file INESISTENTE; anche
  .sal-turni.md irraggiungibile. La copia di lavoro CANCELLATA.
- Causa prossima: un blip di rete di ~30 secondi ha fatto fallire
  checkout/reset di main; il percorso di ripristino ha salvato lo stato
  (E-027 ✓) e poi ha fatto rm -rf PRIMA del clone — e il clone e' fallito
  nello stesso blip: cancellazione senza sostituta, processo morto al
  riavvio successivo.
- Causa del ragionamento: il riclono trattava il clone come scontato. La
  lezione E-027 (salvare lo stato prima del rm) curava i FILE GITIGNORED ma
  non l'ORDINE: rm e clone verificato devono essere un ATOMO — o nasce la
  copia nuova, o resta la vecchia.
- Perché non ci ha fermati: nei test il clone riusciva sempre; il caso
  «rete che cade proprio durante il ripristino da caduta di rete» non era
  mai stato provato (la congiunzione dei due eventi).
- Guardia: night-shift/night-shift.sh — clone in dir NUOVA ($DIR.nuova-$$),
  scambio rm+mv SOLO al successo; clone fallito = copia vecchia resta
  (stantia ma viva) e si riprova al prossimo giro, a voce alta.
- Verifica guardia: il recupero del 13:26 eseguito a mano (clone riuscito
  appena la rete e' tornata); il percorso clone-fallito ora lascia la copia.
- Aggiramento: far cadere la rete esattamente durante il riclono — ora
  sopravvive con una copia stantia e una riga di log.

## E-034 Il live come banco di prova
- Data / sessione: 2026-09-20 (la settimana del «perché non trova nulla?»)
- Famiglia: R6 (processo) + R1
- Chi l'ha trovato: Luca, la domanda che chiude la settimana: «vorrei capire il
  perche' abbiamo tardato tanto, probabilmente c'e' un errore di logica».
- Sintomo: giorni persi. Giorni a far fare a un modello un lavoro meccanico;
  giorni a inseguire «nessuna miglioria trovata» che era Ollama morto; ore a
  guardare finestre live (10 min a ciclo, cooldown 30) per scoprire cio' che
  un test deterministico di 3 secondi avrebbe detto subito.
- Causa prossima: ogni pezzo nuovo andava in produzione e si scopriva lì.
- Causa del ragionamento: **abbiamo osservato il sistema invece di provarlo**.
  Il live era il banco. Ma il live ha cicli lenti, contese (Ollama), lag di
  versione (il turno gira il codice di un giro fa), e cooldown che moltiplicano
  ogni esperimento per trenta minuti. Il sandbox e' istantaneo, pulito e
  ripetibile cento volte.
- Perché non ci ha fermati: nel live qualcosa FUNZIONA sempre un po' — i sintomi
  arrivano generici («non trova», «rosso») e ogni indagine sembra unica invece
  di riconoscere la classe.
- Guardia: tests/test-catena-viva.sh — la catena INTERA (censimento →
  trasformatore → gate → saldato → censore → rinvio onesto) provata in sandbox
  deterministica; e la regola: **nessun cambiamento alla catena sale senza
  passare da lì**. E' nella suite, quindi .night-verify lo esegue a ogni giro.
- Verifica guardia: 11/11 al primo giro completo; soak di 100 esecuzioni.
- Aggiramento: fare debug sul live di cio' che e' riproducibile in sandbox.

## E-035 Lo stub che sbaglia argomento e il tool che copia nella CWD
- Data / sessione: 2026-09-20 (test del sistema completo, sessione Fable — prova T5)
- Famiglia: R1 (assunzione non verificata) + R6 (effetto collaterale ignorato)
- Chi l'ha trovato: la sessione stessa, da `git status` dell'hub dopo la prova: 100+ file
  dello standard staged DENTRO l'hub (`.claude/skills/skills/…`, `patterns/patterns/…`).
- Sintomo: `sync-repo.sh --standard` lanciato dall'hub con uno stub di `gh` ha copiato
  lo standard nell'hub stesso invece che nel clone della repo di destinazione.
- Causa prossima: lo stub `gh repo clone REPO DIR` clonava in `$3` (= REPO) invece che in
  `$4` (= DIR): il clone «riusciva» (rc 0) senza creare la directory di lavoro; il tool
  faceva `cd "$TMP/work"` SENZA guardia e proseguiva nella CWD, cioe' nell'hub.
- Causa del ragionamento: ho scritto lo stub dalla memoria della firma di `gh repo clone`
  senza rileggere la chiamata reale del tool (R1); e ho lanciato il tool dall'hub, dando
  per scontato che scrivesse solo nel suo tmp (R6).
- Perché non ci ha fermati: il tool controllava l'rc del clone, non l'esistenza della
  directory; il `cd` fallito non fermava nulla; `cp -r` su directory esistenti annidava in
  silenzio. Tre silenzi in fila. E il mio stub non aveva un test suo.
- Guardia: `tools/sync-repo.sh` — `cd "$TMP/work" || exit 1` nei due rami, e copia del
  CONTENUTO delle directory (`dir/.`) invece di `cp -r dir dir`; `tests/test-sync-repo.sh`
  caso D14 (clone che «riesce» senza directory → errore detto, CWD intatta, hub senza file
  nuovi) e caso «riallineo senza annidamento».
- Verifica guardia: prima della cura il caso D14 era rosso (rc=0, CWD toccata); dopo, 14/14.
  Il caso reale e' stato ripulito a mano (`git reset`, `git clean` sulle cartelle annidate)
  e l'albero verificato PULITO prima del commit del report.
- Aggiramento: lanciare un tool che scrive «nel suo tmp» dalla radice di un repo vivo
  fidandosi del tmp. La regola: gli stub si provano da soli prima di provare il sistema, e
  i tool che scrivono si lanciano da una directory sacrificabile.

## E-036 Le verifiche notturne dell'hub rosse la notte dopo il merge dei venti giri
- Data / sessione: 2026-09-21 (turno delle 05:09; sessione Fable dei venti giri, riaperta da Luca con la dashboard)
- Famiglia: R3 (verifica fatta su un ambiente diverso da quello che giudica) + R1 (assunzione non verificata)
- Chi l'ha trovato: il turno notturno sull'hub — due righe «VERIFICA ROSSA» nel log
  (`shellcheck --severity=warning …` e `bash tools/suite.sh`), portate da Luca con la dashboard.
- Sintomo: sul Mac la suite era rossa e shellcheck segnava due warning; nella sessione cloud
  (Linux) la stessa suite era 149/149 e shellcheck non era mai stato lanciato.
- Causa prossima: (1) due righe mie con SC2124 (`${@: -1}` in `tools/giri-avversari.sh`,
  `${FINDINGS[@]+…}` in `tools/ciclo-vivo.sh`); (2) `timeout 30`/`timeout 20` nudi in tre test
  (`tests/test-bc-map.sh`, `tests/test-bc-tipi-metadata.sh`, `tests/test-dashboard.sh`) —
  macOS non ha timeout(1): «command not found», rc 127, atteso «irraggiungibile» mai stampato.
- Causa del ragionamento: ho verificato la chiusura (suite, mutazioni, banco) solo su Linux e
  ho dato per scontato che «verde qui» valesse anche sul Mac dove il turno esegue davvero le
  verifiche (R3); la riga shellcheck sta nel `.night-verify` dell'hub dalla prima riga, l'ho
  letta al giro 28 e non l'ho eseguita perche' il binario mancava — ho assunto che mancasse
  ovunque (R1). La lente di portabilita' che avevo appena scritto (D22) non aveva la regola
  proprio sulla forma che il canone aveva gia' pagato con E-029 (ai_timeout esiste per questo).
- Perché non ci ha fermati: nessun banco della chiusura eseguiva le righe di `.night-verify`
  dell'hub; la lente di portabilita' cercava stat/sed/date/bad-substitution ma non timeout(1).
- Guardia: `tests/test-portabilita.sh` — regola «timeout(1) nudo» (rossa sulle tre righe prima
  della cura, verde dopo); shellcheck installato nella sessione (`pip install shellcheck-py`)
  e la riga del `.night-verify` eseguita a mano prima del push.
- Verifica guardia: `bash tests/test-portabilita.sh` 8 → 9 attese; la riga shellcheck del
  `.night-verify` esce 0; `tests/test-bc-map.sh` 4/4, `tests/test-bc-tipi-metadata.sh` 6/6,
  `tests/test-dashboard.sh` 14/14 con `ai_timeout`.
- Aggiramento: chiudere un passaggio con la suite verde su una macchina che non e' quella
  del turno senza eseguire le righe di `.night-verify` una per una. La regola: la chiusura
  esegue il `.night-verify` dell'hub riga per riga, non solo la suite.

## E-037 grep -P: il controllo che muore zitto
- Data / sessione: 2026-09-21 (pomeriggio del cambio modello; sessione hub di Luca)
- Famiglia: R3 (precondizione non chiesta: grep BSD, non GNU) + R2 (verde senza dati)
- Chi l'ha trovato: sessione hub (occhio sul log del turno) — la riga
  `grep: invalid option -- P` ripetuta due cicli di fila, che nessuno guardava.
- Sintomo: il parse del livello ciclo-vivo restituiva vuoto («ciclo-vivo  —  »),
  il check CRLF false-verdava, la sonda hangul E1 degli avversari non ha MAI
  girato su questa Mac. Tutto verde, tutto morto all'apertura.
- Causa prossima: quattro siti con `grep -P` (PCRE): `grep -oP "Livello: \d+"` in
  night-shift/night-shift.sh:347, `grep -rlP '\r$'` in night-shift/night-shift.sh:419 e
  tools/giri-ignoranti.sh:178, `grep -rlP '[\x{AC00}-\x{D7AF}]'` in
  tools/giri-avversari.sh:320. Il grep di macOS (BSD) non ha -P: esce 2 subito.
- Causa del ragionamento: i controlli sono stati scritti come su Linux (R3) e il
  loro fallimento all'apertura produceva silenzio verde (R2): l'assenza del
  finding passava per assenza del problema. E-036 (stessa famiglia portabilita')
  aveva curato stat/sed/date/timeout proprio il giorno prima — la lente cercava
  quelle forme, non questa.
- Perché non ci ha fermati: nessuna lente vietava grep -P; il log della console
  mostrava l'errore ma il conteggio delle verifiche restava nel verde perche'
  l'errore stava DENTRO una verifica che "passava".
- Guardia: `tests/test-portabilita.sh` — regola «nessun grep -P nudo» (git grep -P
  resta lecito: altro binario, con LANG UTF-8).
- Verifica guardia: `bash tests/test-portabilita.sh` 9 → 10 attese; la regola era
  rossa sui quattro siti prima della cura, verde dopo; nel log del turno la riga
  ciclo-vivo ora porta «Livello: 4».
- Aggiramento: aggiungere un controllo con un'opzione che non esiste sul grep di
  casa e non leggere il log. La regola: ogni controllo nuovo si prova VOLUTAMENTE
  rosso una volta (su un colpevole) prima di fidarsi del suo verde.

## E-038 Le graffe perse e il commento che ingoia il backslash
- Data / sessione: 2026-09-21 (serata "chiudiamo tutto"; sessione hub di Luca)
- Famiglia: R1 (assunzione non verificata) + R2 (verde senza dati: check vacui)
- Chi l'ha trovato: sessione hub, con quattro dump crescenti (OUT dell'agente,
  i .json serviti dal mock, gli argv di azione, di nuovo i .json) — ogni strato
  diceva una cosa diversa finche' il colpevole non e' rimasto solo.
- Sintomo: «A3: rifiuti loggati: 0» stabile da giorni, scambiato per un test che
  "dipende dalla malizia del modello". Il modello non c'entrava: i tentativi
  proibiti li inietta il mock, deterministicamente.
- Causa prossima: (1) la forma `azione "{\"action\":\"read\",…}"` — quote
  annidate con escape dentro "$(…)" — nel contesto del test spezzava l'azione in
  frammenti sul bash 3.2: l'agente riceveva `"action":"read"` SENZA graffe, lo
  trattava come risposta finale, completava in 1 turno; (2) la prima cura ha
  messo un commento in mezzo alla catena di continuazione `\`: il `#` dopo
  `\`-newline commenta la riga inghiottendo il backslash finale — lo scenario
  partiva SENZA corpi, «FINISH (dossier esaurito)» al primo turno.
- Causa del ragionamento: ho assunto che una forma di quoting che funziona in un
  contesto funzionasse in tutti (R1 — la replica manuale in isolamento PASSAVA:
  il difetto viveva solo nel contesto completo, E-034 al contrario); e i due
  check di confinamento che passavano VACUAMENTE (il segreto non passa perche'
  l'azione non arriva manco a essere tentata) erano verde senza dati (R2). Il
  solo check che diceva la verita' era quello che falliva.
- Perché non ci ha fermati: nessuna guardia sul contratto mock-agente verificava
  che le azioni iniettate ARRIVASSERO intere; il test passava 13-14 su 15 e il
  FAIL veniva letto come "capriccio del modello".
- Guardia: `tests/test-agente.sh` stesso A3 («tre rifiuti dichiarati nel log»):
  rosso prima della cura, 15/0 dopo — con entrambe le sfide vive passate dal
  modello nuovo. Il check dei rifiuti LOGGATI resta obbligatorio: e' quello che
  smaschera il confinamento vacuo.
- Verifica guardia: `bash tests/test-agente.sh` → 15 OK, 0 FAIL (era 13-14 OK,
  1 FAIL); suite completa verificata dopo.
- Aggiramento: fidarsi del verdetto verde di un check i cui fratelli passano
  vacuamente. E scrivere commenti dentro le catene di continuazione: il commento
  sta SOPRA il comando, sempre.
