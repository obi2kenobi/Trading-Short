# CLAUDE.md — Standard Working Rules


## Il debito si brucia alla riapertura (settimo patto)

Alla riapertura: i debiti aperti si contano (`bash tools/debiti-riapertura.sh`); quelli di
dominio diventano domande singole, una alla volta, col perché; quelli risolvibili si fanno
PRIMA del lavoro nuovo. Il debito non invecchia: matura interessi.

## Il codice parla (sesto patto)

Codice semplice, pieno di spiegazioni, e **ogni passo loggato**: all'inizio cosa sto per fare,
a ogni bivio cosa ho scelto e perché, alla fine cosa è riuscito. Ogni salto dichiarato, mai
silenzioso. Un log in più costa una riga; un log mancante costa un giro di debug — e chi legge
il log è sempre in ritardo di un contesto. Il silenzio non è pulizia: è invisibilità.

## I cinque patti della sessione (nati dal giorno dell'asse sbagliato, 2026-09-07)

1. **I CONFINI SI DICHIARANO PRIMA DI INIZIARE** — cosa è raggiungibile da questa sessione
   (il vivo? il gestionale? la rete?) e cosa passa dall'operatore. Un vincolo di
   raggiungibilità taciuto detta il ritmo di una giornata intera.
2. **LE DOMANDE PRIMA DEL CODICE** — con ambiguità di dominio aperte (o una misura che ne
   rivela una: N>1 candidati senza chiave), il primo artefatto è il file delle domande
   numerato, non il codice. Ogni domanda: perché conta, e le due parti (cosa può dire il
   sistema / cosa solo una persona).
3. **LE ISTRUZIONI ALL'OPERATORE SI CITANO** — «fai X sul tuo sistema» va accompagnato dal
   `file:riga` che lo autorizza. Un'istruzione che il codice vieta è peggio di un errore:
   la esegue l'umano, fidandosi.
4. **LO STATO SI PUBBLICA** — a ogni PR (e comunque ogni poche ore): cosa è VERIFICATO, cosa
   è ASSUNTO dichiarato, quali domande sono aperte. Chi possiede il dominio non deve
   aspettare la fine della giornata per scoprire com'è andata.
5. **SCRIVERE E COMMITTARE SONO DUE COMANDI** — mai un gesto solo: è l'attimo in cui il
   cancello può mordere.

These rules are binding for every development session. No exceptions.

> **Tradeoff:** these rules bias toward caution over speed. For trivial tasks, use judgment.

---

## 1. Process Rules

### Read before acting
Understand the current state of the repo before touching anything. Read relevant files, check git status, understand the context.

### One problem at a time
No jumping ahead, no parallel work on multiple things. Step by step. Complete one task before starting the next.

### Repeat the request in your own words
Before executing, confirm understanding by rephrasing the request. Wait for explicit approval before proceeding.

### If something is unclear, ask — never guess
One extra question is always better than one wrong assumption. Never invent requirements, business logic, or expected behavior.

### Surface interpretations and tradeoffs — don't pick silently
If multiple interpretations exist, present them all instead of choosing one in autonomy. State your assumptions explicitly. If a simpler approach exists, say so and push back when warranted.

### Input and output examples before writing code
Require concrete examples of what goes in and what should come out before implementing any logic.

### Goal-driven execution — define success criteria, loop until verified
Transform tasks into verifiable goals before starting:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan with a check per step:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```
Strong, verifiable criteria let you proceed independently. Weak ones ("make it work") require constant clarification.

### Done means proven and confirmed, never claimed
A step is done only when both hold: you **show the evidence** (passing test, command output, the project's validation artifact) **and** the domain owner **confirms the result is correct**. The user owns the domain knowledge — a technical green light is not the same as being right. Until both, it isn't done.

### Keep living documentation, not just commits
The project's knowledge lives in versioned `.md` documents kept current as you work — not only in commit messages or in your head. Maintain, in the files the project designates:
- **How it works** — validated behavior, formulas, rules: the requirements of record.
- **Decisions and ideas** — why a choice was made, alternatives weighed, open questions.
- **Discoveries and corrections** — write them down BEFORE the next step. Distinguish defects in the system you're studying or reproducing (they become requirements) from errors in your own notes or assumptions (annotate as such, never as defects of the system).

---

### Prima mossa su un progetto multi-copia: l'allineamento
Se il progetto esiste in più copie (repo, fork, mirror gas-src, GAS vivo): la base
di lavoro si decide PRIMA delle modifiche (skill `allineamento-fork`). Per i GAS:
**il vivo è definitivo, in produzione, mai un'ipotesi** — si legge con clasp, non si
immagina; illeggibile = DEGRADATO dichiarato. La deriva si misura (`tools/fork-stato.sh`)
e lo stato si scrive (FORK-STATO.md).

## 2. Code Rules

### Only what is asked
No additions, no spontaneous "improvements", no unrequested initiatives. If it wasn't asked for, don't do it.

**The test:** every changed line must trace directly to the user's request.

### Zero waste
No superfluous code, no unnecessary files, no over-engineering. The simplest solution that works is the right one.

**The test:** "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### Short functions
If a function exceeds 30-40 lines, it must be broken down. Each function does one thing.

### One file, one responsibility
No monolithic files. Every file has a single, clear purpose.

### No dead code
Don't leave commented-out code, unused imports, or placeholder functions. If it's not used, delete it.

### Respect existing patterns
Follow the conventions already present in the codebase: naming, structure, formatting, architecture. Consistency over personal preference.

### Never expose secrets
Never log, print, paste, or commit credentials, tokens, or sensitive data (credential files, `.env`, key exports). Refer to secrets by file path, not by value. If a secret appears in something to be committed or shared, stop and flag it.

### Mask, don't omit, when a secret could surface in output (2026-08-24 — binding, promoted from `patterns/segreto-come-impronta.md`)
Any output that might carry a secret through no fault of its own — a verification run against real credentials, a command whose result you didn't author (LLM-generated shell output, a third-party log, an adversarial-bench transcript) — must not print the raw value AND must not silently omit the whole line either (an omitted line hides whether something WAS a secret, or how long it was, which itself is useful signal and its absence can look like a bug). Replace the recognized secret with `«secret <fingerprint> · N chars»`: the reader sees a secret was there, its shape, its length, without it ever reaching a terminal, log, or chat. See `patterns/segreto-come-impronta.md` for the reference implementation.

### One-shot secret handoff (interactive login/deploy) (2026-08-24 — binding)
A first-time interactive login or deploy (OAuth device flow, `gh auth login`, `clasp login`) needs a token to move from the user to the tool exactly once. "Paste it in chat" is not an acceptable answer — it is precisely the exposure the rule above exists to prevent. Two options, in this order of preference:
1. **Run the interactive command yourself, in the terminal.** The tool's own login flow (browser redirect, device code, prompt) then talks directly to the user or the provider — the secret never passes through the conversation at all.
2. **If a value must come from the user out-of-band** (no interactive flow available): ask them to write it to a local, untracked file and give you only the *path* — never the value in chat. Read it from disk, use it, and never echo it back (same rule as "Never expose secrets").

---

## 3. Communication Rules

### Respond in the user's language
If the user writes in Italian, respond in Italian. If in English, respond in English. Match the language of the conversation.

### Be direct and concise
No filler, no unnecessary preambles. State what you're doing and why, then do it.

### Report problems immediately
If something doesn't work, is ambiguous, or seems wrong — say it immediately. Don't try to silently work around issues.

### Show, don't tell
When explaining a change, show the relevant code. When reporting a result, show the output.

### Ciò che consegni a un umano da eseguire è codice, e si tratta come codice (2026-09-06 — vincolante, da REPO-E)
Un blocco di comandi che una persona incollerà nel proprio terminale non è prosa: è un artefatto che verrà **eseguito**, e ne risponde chi lo scrive. Due regole, entrambe pagate lo stesso giorno:
1. **Nessun commento inline.** `git log --oneline -8 # devi vedere X` si rompe su zsh senza `interactive_comments`, che è il default: la shell tratta `#` come argomento e il comando fallisce. Il commento va sopra il blocco, in prosa. Corollario: se la cura del gotcha è già documentata nel progetto su cui stai lavorando, si consegna **prima** la cura (`echo 'setopt interactive_comments' >> ~/.zshrc`), non dopo che l'errore è successo — la lezione era scritta, l'ho letta, e l'ho rotta lo stesso.
2. **L'ATTESO che dichiari è un'affermazione, e si cita come il codice.** «Aspettati questo output» va accompagnato dal `file:riga` della fonte, o non si scrive. Misurato: un atteso preso dal `<title>` dell'HTML quando la fonte vera era un `setTitle()` nel `.gs`, che vince sul tag. Esito innocuo — l'atteso vero era perfino una prova migliore — ma un atteso sbagliato insegna all'umano a diffidare dei controlli, che è il costo che un gate non può permettersi (*«il costo di un falso positivo è la fiducia»*).

---

## 4. Git Rules

### Commit after every working step
So we can always roll back to a point that works. Each commit represents a stable, functional state.

### Commit messages format
Use clear, descriptive messages. Format: `<type>: <short description>`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

Example: `feat: add export functionality for usage reports`

### Never force push
Never use `--force` on shared branches unless explicitly asked.

### Review changes before committing
Always check `git diff` before committing to ensure only intended changes are included.

### Convenzioni tacite del gate notturno (set 3 "flusso delle idee", 2026-08-22)
Due regole vivevano solo in commenti di codice (`night-shift/*.sh`) o in `SAL.md`, mai in
un posto che un agente di giorno o un progetto onboardato leggesse — scoperto costruendo
proprio questo ciclo, non un'ipotesi:
- **Il branch deve iniziare per `night/`, `claude/` o `glm/`** — `night-shift/morning-gate.sh`
  giudica SOLO le PR i cui branch matchano questo prefisso (`gh pr list` filtrato per
  `headRefName`). Un branch con un altro prefisso (`feature/x`, `fix/y`) viene ignorato in
  silenzio: nessun errore, nessun avviso, semplicemente il gate non lo vede mai.
- **La keyword di chiusura issue va in INGLESE** (`Closes #N`, `Fixes #N`) — GitHub non
  auto-chiude le issue con la traduzione italiana. Verificato più volte nella storia di
  questo sistema (`SAL.md`).
- **Cartelle specchio/sola lettura**: il turno notturno rispetta un file `.night-mirror`
  nella root della repo (una cartella per riga, come `.night-verify`) — se presente, quelle
  cartelle vengono dichiarate esplicitamente all'agente e non vengono mai scritte. Prima di
  questo giro il prompt ne parlava senza che esistesse alcun modo per una repo di dichiararle.

---

## 5. Error Handling

### Il report dal campo chiude il lavoro
Ogni sessione che usa o tocca il metodo chiude con un report in `docs/campo/`
(formato: `docs/campo/README.md` — tre righe bastano, "nessuna proposta" dichiarata
conta). È il canale con cui il campo insegna al canone: senza report, il giro non
insegna niente a chi viene dopo (il promemoria alla chiusura è già strutturale
nell'hook Stop — questa regola ne è la fonte scritta).

### L'errore si mette a regime
Quando scopri un TUO errore (fix che rompe, test che mentiva, metrica che misurava
un'altra cosa, ripristino che non ha ripristinato): skill `post-mortem` — sette campi,
famiglia di ragionamento R1-R6, e una GUARDIA che devi vedere diventare rossa sul tuo
errore prima di chiudere la voce. Il registro: `docs/errori/REGISTRO.md` (append, mai
riscrivere). La lente `tests/test-errori.sh` pretende che ogni guardia citata esista.

### Read the error completely
Before attempting a fix, read the full error message and stack trace. Understand the root cause.

### Fix the cause, not the symptom
Don't add workarounds. Find and fix the actual problem.

### One fix at a time
When debugging, change one thing at a time and verify the result before making the next change.

---

## 6. Project-Specific Context

These rules are universal and portable across projects. Concrete project context — file roles, commands, per-project conventions — lives in **`PROJECT.md`**. Read it at the start of each session and keep it in sync.

### The first-touch trigger (2026-08-24 — binding)
Before the first edit or command run in a project not yet listed as a section in `PROJECT.md`, add its section (even a one-line stub: name, path, what it is) before proceeding with the actual work. Without this trigger the promise "one section per project" stays silently unfulfilled — verified in this repo: a project can be worked on for a whole session without ever gaining a section, and nothing flags it. This is a process rule for the agent to self-enforce, not an automated check: detecting "a new project" from the filesystem alone is not reliably mechanizable without false positives.

---

## 7. Delegation & Routing

This repo **calls the LLMs**: uniform wrappers in `llm/` let any project, script, or agent delegate
to any brain with the same gesture (`llm/ask-qwen.sh "..."`, stdin for long context).

### When to delegate — and to whom
- **Local brain (ask-qwen)**: high-volume, low-risk, verifiable work — digests, drafts, triage,
  mechanical commesse. Zero marginal cost, data never leaves the Mac. Measured: 3.7-5.9 tok/s idle.
- **Night shift** (see `night-shift/README.md`): GitHub issues labeled `night-shift` become draft
  PRs overnight. No time limit per issue (decided 2026-08-21). Issues must be **pre-loaded work
  orders** (snippets, line numbers, ready greps) — never investigation briefs: three nights proved
  the local model understands but does not converge when judgment is required.
- **Cloud brains (ask-opus / ask-glm)**: programmatic pipelines. Otherwise work in direct sessions.

### Never delegate
- Architectural decisions, investigations, judgment calls — these belong to the day brains.
- Anything whose verification was not declared **before** the work started (_"Done means proven"_).
- Secret **values** in any prompt (references by file path only — _"Never expose secrets"_).

### Full method
`night-shift/README.md` (method, binding rules, measured numbers) and `llm/README.md`
(decision matrix). System map with every constraint and its provenance: `docs/system.md`.

### Navigation before reading (graphify, from 2026-08-21)
Before paging through files to locate code, query the graph: `graphify query "<question>"`
returns a deterministic subgraph with exact `file:L` references (build with
`graphify extract . --code-only` if `graphify-out/graph.json` is missing). The local brain at
~4 tok/s must never pay the read-everything tax — and neither should you. Trust the graph for
orientation and location; never as an oracle for call semantics (`calls` edges are unresolved —
lesson paid by REPO-A on 2026-08-08).

### Goal loops (/goal)
For iterative optimization during the day use `/goal <verifiable objective> | max N attempts`:
restate the objective as a verification with its level (1-5, see docs/system.md), one change per
attempt, log every attempt in `loops/<date>-<slug>.md`, adversarial check before claiming
success, hard attempt cap. Note the deliberate asymmetry: night shift has NO time limit (single
long commessa); day goal loops always have a cap (iterative optimization).

### The minimal-code ladder (from ponytail, adopted 2026-08-21)
"Zero waste" as a **procedure**, in strict order — climb it before writing any code, always
AFTER reading and understanding (lazy about the solution, never about reading):
1. Does this need to exist at all? (YAGNI — if no, stop)
2. Already in the codebase? Reuse it
3. Does the stdlib do it? Use it
4. Does the platform do it natively? (native `<input type="date">`, not flatpickr)
5. Is a dependency already installed? Use it
6. Can it be one line? One line
7. Otherwise: the minimum that works
Validation, error handling, security and accessibility are never cut — code is small because
it's necessary, not because it's golfed. **Every deferred shortcut goes in `DEBITI.md`** —
so "later" doesn't become "never".

### Three strikes, then architecture (from superpowers, adopted 2026-08-21)
After **three failed fix attempts** on the same bug, stop patching: the defect is almost
certainly not where you think it is. Escalate to an architecture/hypothesis review — re-read
the flow, question the assumption the fixes were built on — before attempt four.

### Patterns before reinventing (2026-08-21)
Before writing infrastructure code (watchdogs, locks, sandboxing, CSV handling, command
guards), check `patterns/`: each entry is a proven snippet ANCHORED to code that uses it —
cite the pattern in commesse and code instead of re-deriving it. If the anchor is gone,
the pattern is dead: say so, don't trust folklore.

### Public repo, private work (2026-08-22 — binding)
This hub is PUBLIC and contains method only: **never write names of private repos, people,
or company specifics in any versioned file**. Use anonymous codes (REPO-A, REPO-B…); the
mapping lives ONLY in `night-shift/repos.key` (local, gitignored). `tools/privacy-check.sh`
enforces it and runs in `.night-verify`: a leak fails the gate. Method, not gossip.
Before citing a code, check `night-shift/repos-index.md` — a public, name-free registry
of which role each code already covers (4° ciclo, set 3, 2026-08-23: built after nearly
colliding a new code with an existing one before assigning REPO-E).
