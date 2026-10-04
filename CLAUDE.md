# CLAUDE.md — Standard Working Rules

<!--
Manutenzione (D8, decisione di Luca 2026-09-23). Questo file si carica in OGNI sessione: la
documentazione ufficiale di Claude Code chiede meno di 200 righe («longer files consume more
context and reduce adherence»), enfasi su pochissime righe, procedure lunghe nelle skill.
- Le PROVENIENZE (date, incidenti, repo d'origine) vivono in commenti HTML come questo: Claude
  Code li toglie prima di iniettare il file, quindi restano per chi legge senza costare contesto.
- I blocchi marcati «solo-hub» (una riga di commento d'apertura, una di chiusura con la barra)
  valgono solo nell'hub: gli installatori li tolgono (tools/claude-md-satellite.sh).
  Banco: tests/test-claude-md-snello.sh.
- La versione precedente, lunga 303 righe, e' nella storia git (commit prima del D8).
-->

## Il debito si brucia alla riapertura (settimo patto)

Alla riapertura: i debiti aperti si contano (`bash tools/debiti-riapertura.sh`); quelli di
dominio diventano domande singole, una alla volta, col perché; quelli risolvibili si fanno
PRIMA del lavoro nuovo. Il debito non invecchia: matura interessi.

## Il codice parla (sesto patto)

Codice semplice, pieno di spiegazioni, e **ogni passo loggato**: all'inizio cosa sto per fare,
a ogni bivio cosa ho scelto e perché, alla fine cosa è riuscito. Ogni salto dichiarato, mai
silenzioso. Il silenzio non è pulizia: è invisibilità.
<!-- Un log in piu' costa una riga; un log mancante costa un giro di debug — e chi legge il log
e' sempre in ritardo di un contesto. -->

## I cinque patti della sessione

1. **I confini si dichiarano prima di iniziare** — cosa è raggiungibile da questa sessione (il
   vivo? il gestionale? la rete?) e cosa passa dall'operatore.
2. **Le domande prima del codice** — con ambiguità di dominio aperte (o una misura che ne rivela
   una: N>1 candidati senza chiave), il primo artefatto è il file delle domande numerato. Ogni
   domanda: perché conta, e le due parti (cosa può dire il sistema / cosa solo una persona).
3. **Le istruzioni all'operatore si citano** — «fai X sul tuo sistema» va accompagnato dal
   `file:riga` che lo autorizza.
4. **Lo stato si pubblica** — a ogni PR (e comunque ogni poche ore): cosa è VERIFICATO, cosa è
   ASSUNTO dichiarato, quali domande sono aperte.
5. **Scrivere e committare sono due comandi** — mai un gesto solo: è l'attimo in cui il
   cancello può mordere.
<!-- I cinque patti nacquero dal giorno dell'asse sbagliato (2026-09-07): un vincolo di
raggiungibilita' taciuto dettò il ritmo di una giornata intera; un'istruzione all'operatore che
il codice vietava e' peggio di un errore, perche' la esegue l'umano fidandosi; chi possiede il
dominio non deve aspettare la fine della giornata per scoprire com'e' andata. -->

These rules are binding for every development session. No exceptions.
For trivial tasks, use judgment: the rules bias toward caution over speed.

---

## 1. Process Rules

- **Read before acting** — understand the repo's current state (relevant files, `git status`) before touching anything.
- **One problem at a time** — step by step; finish one task before starting the next.
- **Repeat the request in your own words** — confirm understanding and wait for explicit approval before proceeding.
- **If something is unclear, ask — never guess** — never invent requirements, business logic or expected behavior.
- **Surface interpretations and tradeoffs** — if several readings exist, present them all; state assumptions; if a simpler approach exists, say so and push back.
- **Input and output examples before writing code** — concrete examples of what goes in and what comes out.
- **Goal-driven execution** — turn tasks into verifiable goals: "add validation" → tests for invalid inputs, then make them pass; "fix the bug" → a test reproduces it, then passes; "refactor X" → tests pass before and after. For multi-step work state a plan with a check per step and loop until verified. Strong, verifiable criteria let you proceed independently; weak ones ("make it work") need constant clarification.
- **Done means proven and confirmed, never claimed** — done only when you show the evidence (test output, command output, the project's validation artifact) **and** the domain owner confirms the result. A technical green light is not the same as being right.
- **Keep living documentation** — the project's knowledge lives in the versioned `.md` files the project designates, kept current as you work: how it works (validated behavior, formulas, rules), decisions (why a choice was made, alternatives weighed, open questions), discoveries and corrections — written down BEFORE the next step. Defects of the system under study become requirements; errors in your own notes are annotated as such, never as defects of the system.
- **Multi-copy project: alignment first** — if the project exists in several copies (repo, fork, gas-src mirror, live GAS), decide the working base BEFORE changing anything (skill `allineamento-fork`). For GAS, **the live project is final, in production, never a hypothesis**: read it with clasp, don't imagine it; unreadable = declared DEGRADATO. Measure the drift (`tools/fork-stato.sh`) and write the state (FORK-STATO.md).

## 2. Code Rules

- **Only what is asked** — no additions, spontaneous "improvements" or unrequested initiatives. Test: every changed line traces to the request.
- **Zero waste** — no superfluous code, files or over-engineering; the simplest solution that works. Test: would a senior engineer call it overcomplicated?
- **Short functions** — over 30-40 lines, break it down; each function does one thing.
- **One file, one responsibility** — no monolithic files.
- **No dead code** — no commented-out code, unused imports or placeholder functions.
- **Respect existing patterns** — naming, structure, formatting, architecture: consistency over preference.
- **Deploy is the human's** — never `clasp push` or `clasp deploy`: they write to production with no staging and no rollback. `tools/clasp-block-hook.sh` denies them.

### Never expose secrets
Never log, print, paste or commit credentials, tokens or sensitive data (credential files, `.env`, key exports). Refer to secrets by file path, not by value. If a secret appears in something to be committed or shared, stop and flag it.

### Mask, don't omit, when a secret could surface in output
Output that might carry a secret through no fault of its own — a verification run against real credentials, or any command whose result you didn't author (LLM-generated shell output, a third-party log, an adversarial-bench transcript) — must not print the raw value AND must not silently omit the line either — an omitted line hides whether something WAS a secret and how long it was. Replace it with `«secret <fingerprint> · N chars»`. Rule promoted from `patterns/segreto-come-impronta.md` (reference implementation).
<!-- Promossa a regola il 2026-08-24. -->

### One-shot secret handoff (interactive login)
A first-time interactive login (OAuth device flow, `gh auth login`, `clasp login`) needs a token to move from the user to the tool exactly once. "Paste it in chat" is not an acceptable answer. In order of preference:
1. **Run the interactive command yourself, in the terminal**: the tool's own flow talks to the user or the provider, and the secret never passes through the conversation.
2. **If a value must come from the user out-of-band** (no interactive flow available): ask them to write it to a local, untracked file and give you only the *path*. Read it from disk, use it, never echo it back.
<!-- Regola del 2026-08-24. Il titolo diceva «login/deploy»: il D8 (2026-09-23) lo restringe al
login, perche' il deploy e' dell'umano (la regola «Deploy is the human's» sopra). -->

## 3. Communication Rules

- **Respond in the user's language** — Italian if they write Italian, English if English.
- **Be direct and concise** — no filler or preambles: say what you're doing and why, then do it.
- **Report problems immediately** — if something doesn't work, is ambiguous or seems wrong, say so; never work around it silently.
- **Show, don't tell** — show the relevant code when explaining a change, the output when reporting a result.

### What you hand to a human to run is code
A block of commands someone will paste into their terminal is an artifact that will be **executed**:
1. **No inline comments** — `git log --oneline -8 # devi vedere X` breaks on zsh without `interactive_comments` (the default). Put the comment above the block, in prose; if the project already documents the cure for a gotcha, deliver the cure first (`echo 'setopt interactive_comments' >> ~/.zshrc`).
2. **The EXPECTED output you declare is a claim** — cite its source `file:riga`, or don't write it. A wrong expectation teaches the human to distrust the checks.
<!-- Da REPO-E, 2026-09-06: entrambe le regole pagate lo stesso giorno. Misurato un atteso preso
dal <title> dell'HTML quando la fonte vera era un setTitle() nel .gs, che vince sul tag.
«Il costo di un falso positivo e' la fiducia.» -->

## 4. Git Rules

- **Commit after every working step** — every commit is a stable state you can roll back to.
- **Commit message format** — `<type>: <short description>`, types `feat`, `fix`, `refactor`, `docs`, `test`, `chore` (e.g. `feat: add export functionality for usage reports`).
- **Never force push** — never `--force` on shared branches unless explicitly asked.
- **Review changes before committing** — check `git diff` so only intended changes are included.

### Conventions of the night gate
- **Branches start with `night/`, `claude/` or `glm/`** — any other prefix (`feature/x`, `fix/y`) is invisible to every judge, silently. Who judges what today:
  - **the censore** (night-shift/revisore.sh in the hub, in the night cycle) deliberates — and may merge — ONLY draft PRs on `night/` titled `caccia:`. On issue PRs (`night/issue-N`) it runs the same guards and proofs, judges the diff against the issue text and leaves only a motivated **parere** as a PR comment: it never merges, readies or closes them. Any other PR it defers as «non mio»;
  - **the morning-gate** (night-shift/morning-gate.sh in the hub) is **in pensione** from launchd since 2026-09-23: it can still be run by hand, and then judges PRs on `night/`, `claude/`, `glm/`. PRs on `claude/*` and `glm/*` have no automatic judge today, and issue PRs are merged only by Luca: Luca's review looks at them.
- **The issue-closing keyword stays in INGLESE** (`Closes #N`, `Fixes #N`) — GitHub does not auto-close with the Italian translation.
- **Mirror / read-only folders**: the night shift honours a `.night-mirror` file at the repo root (one folder per line, like `.night-verify`): those folders are declared to the agent and never written.
<!-- Nate nel set 3 "flusso delle idee" (2026-08-22): vivevano solo in commenti di codice
(night-shift/*.sh) o in SAL.md, mai dove un agente di giorno o un progetto onboardato le
leggesse. Il giudice aggiornato il 2026-09-23 (sì di Luca); il parere sulle PR delle issue e' la
decisione D10 di Luca (2026-09-23: «b», il censore giudica ma non fonde); la keyword inglese verificata piu'
volte nella storia del sistema (SAL.md); .night-mirror: prima il prompt ne parlava senza che una
repo avesse modo di dichiararle. -->

---

## 5. Error Handling

- **The field report closes the work** — every session that uses or touches the method ends with a report in `docs/campo/` (format: `docs/campo/README.md` — three lines are enough; "nessuna proposta" declared counts). Without it the round teaches nothing to whoever comes next.
- **Your own error goes on the books** — when you find YOUR error (a fix that breaks, a test that lied, a metric that measured something else, a restore that didn't restore): skill `post-mortem` — eight fields, reasoning family R1-R6, and a GUARD you must see turn red on your error before closing the entry. Register: `docs/errori/REGISTRO.md` (append, never rewrite); `tests/test-errori.sh` requires every cited guard to exist.
- **Read the error completely** — the full message and stack trace, before attempting a fix.
- **Fix the cause, not the symptom** — no workarounds.
- **One fix at a time** — change one thing, verify, then the next.
<!-- Il promemoria del report alla chiusura e' gia' strutturale nell'hook Stop: questa regola ne
e' la fonte scritta. -->

---

## 6. Project-Specific Context

These rules are universal and portable across projects. Concrete project context — file roles, commands, per-project conventions — lives in **`PROJECT.md`**. Read it at the start of each session and keep it in sync.

### The first-touch trigger
Before the first edit or command run in a project not yet listed as a section in `PROJECT.md`, add its section (even a one-line stub: name, path, what it is) before proceeding with the actual work. It is a process rule the agent self-enforces: "a new project" is not reliably detectable from the filesystem.
<!-- 2026-08-24: verificato in questo repo — un progetto puo' essere lavorato per un'intera
sessione senza mai ricevere la sua sezione, e niente lo segnala. -->

---

## 7. Method & Delegation


### Navigation before reading (graphify)
Before paging through files to locate code, query the graph: `graphify query "<question>"` returns a deterministic subgraph with exact `file:L` references. The graph is the backbone of the hub and of every installed repo: `graphify-out/graph.json` is versioned (merge driver `merge=graphify`), refreshed by `tools/graphify-spina.sh` at SessionStart and staged by the pre-commit; the hub's night shift adds the semantic pass over docs and patterns (tools/grafo-semantico.sh in the hub: Ollama, draft PR). Never pay the read-everything tax. Trust the graph for orientation and location, never as an oracle for call semantics (`calls` edges are unresolved).
<!-- graphify dal 2026-08-21; spina dorsale per decisione di Luca, D1 2026-09-23. La lezione sui
`calls` non risolti l'ha pagata REPO-A il 2026-08-08. Il cervello locale a ~4 tok/s non deve mai
pagare la tassa del leggere-tutto, e nemmeno tu. -->

### The minimal-code ladder
"Zero waste" as a procedure, in strict order — climb it before writing any code, always AFTER reading and understanding:
1. Does this need to exist at all? (YAGNI — if no, stop)
2. Already in the codebase? Reuse it
3. Does the stdlib do it? Use it
4. Does the platform do it natively? (native `<input type="date">`, not flatpickr)
5. Is a dependency already installed? Use it
6. Can it be one line? One line
7. Otherwise: the minimum that works

Validation, error handling, security and accessibility are never cut. **Every deferred shortcut goes in `DEBITI.md`**, so "later" doesn't become "never".
<!-- Da ponytail, adottata il 2026-08-21. -->

### Three strikes, then architecture
After **three failed fix attempts** on the same bug, stop patching: the defect is almost certainly not where you think. Escalate to an architecture/hypothesis review — re-read the flow and question the assumption the fixes were built on before attempt four.
<!-- Da superpowers, adottata il 2026-08-21. -->

### Patterns before reinventing
Before writing infrastructure code (watchdogs, locks, sandboxing, CSV handling, command guards), check `patterns/`: each entry is a proven snippet ANCHORED to code that uses it — cite it in commesse and code instead of re-deriving it. If the anchor is gone, the pattern is dead: say so.
<!-- 2026-08-21. -->
