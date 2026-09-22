---
name: selezione-contesto
description: Seleziona il contesto giusto prima di progettare, decidere o scrivere una commessa — non tutto quello che esiste: un pacchetto limitato di fonti (SAL del dominio, pattern già pagati, mappa dei domini, oracoli, poi graphify/grep), con un BUDGET esplicito (quante fonti, quanto tempo) e le ESCLUSIONI dichiarate (cosa si è scelto deliberatamente di NON leggere e perché). Nata nel 6° ciclo set 2 (2026-08-24): design-doc aveva un orientamento graphify-o-fallback per trovare i componenti, ma la domanda a monte era più larga — quali lezioni, quali pattern, quale dominio caricare PRIMA di aprire il codice; e la risposta era sempre "dipende dall'agente", cioè nessuna. Usa quando si apre un lavoro nuovo (design-doc, commessa, /goal), quando il contesto raccolto sembra più grande del compito, o invoca /selezione-contesto esplicitamente. Non sostituisce audit-commessa (quello verifica assunzioni di commesse già scritte): questo sceglie cosa caricare prima che il lavoro esista.
---

# selezione-contesto — meno contesto, più giusto

Il fallimento silenzioso che questo comando chiude ha due facce opposte, entrambe
pagate in questo repo: arrivare a un design SENZA le lezioni già scritte in SAL
(riscoprire a costo pieno ciò che un giro aveva già pagato — il filo comune dei gap
trovati dal 5° ciclo: "contenuto che esiste solo se qualcuno se ne ricorda"), o
arrivarci con TUTTO il contesto caricato (il documento medio annega il compito, e
chi legge perde il criterio per distinguere ciò che conta).

Selezione non significa raccolta: significa scegliere anche cosa escludere, e
dichiararlo.

## 1. L'ordine delle fonti (dalla più densa alla più grezza)

1. **SAL del dominio** (`SAL.md` dell'hub, o il SAL del progetto) — grep per il tema,
   non lettura integrale: le voci datate sono già densità pura (ciò che un giro ha
   imparato, compresso).
2. **`patterns/`** — se il tema tocca una famiglia di bug già catalogata
   (l'indice in `patterns/README.md`), il pattern dice in dieci righe ciò che un
   incidente ha insegnato in un pomeriggio.
3. **La mappa dei domini** (`docs/mappa-dominio-gas-src.md`) se il lavoro è un
   calcolo gestionale: dice se esiste già un oracolo e quale dominio è scoperto —
   caricare il REPO esterno quando l'oracolo esiste già è sprezzo del budget.
4. **Gli oracoli** (`tools/*.py` con formula minata) — per il calcolo, questi
   SONO il contesto: docstring con file:riga della fonte reale.
5. **graphify / Grep / Explore** — solo per dove vivono i componenti: se
   `graphify-out/graph.json` esiste, query mirata; altrimenti la soglia già in uso
   nel sistema (3+ query esplorative → agente Explore). L'orientamento, non la
   semantica (lezione già pagata sul grafo, citata in design-doc §3).

## 2. Il budget (dichiarato, non implicito)

- **Fonti**: al massimo 5 voci di contesto caricate per un compito ordinario; un
  compesso grande (territorio notturno, refactoring multiplo) può salirne, ma il
  numero si DICHIARA nel documento che ne esce ("contesto: SAL voci X e Y, pattern
  Z, oracolo W — 4 fonti").
- **Profondità**: una fonte si legge per estratto (grep + righe attorno), non per
  intero, salvo che il compito SIA quella fonte (es. revisionare proprio il SAL).
- **Tempo**: se dopo il budget di fonti il quadro manca ancora, non raddoppiare le
  fonti — è il segnale che la richiesta è troppo larga: torna a `/brainstorming`
  con ciò che manca, invece di caricare il mondo per compensare una domanda non
  fatta.

## 3. Le esclusioni si scrivono (la parte che nessuno fa)

Il pacchetto di contesto dichiara anche cosa NON è stato caricato e perché:
"non letti i progetti REPO-E del dominio X (l'oracolo esiste già)", "non caricata
la cronaca completa del 2026-08-21 (la lezione è già in pattern Y)". Chi legge il
documento sa dove finisce il quadro — e il prossimo giro sa dove allargarlo senza
ripartire da zero. Un'esclusione silenziosa è un buco travestito da scelta.

## 3bis. La ricetta della densità (7° ciclo, set 2 — nata da un dogfood reale)

Quando il compito è "serve un oracolo per questo dominio?", la domanda che
decide non è il nome della categoria ma QUANTO PESO HA LA FORMULA nel codice
reale del dominio. Ricetta rapida (minuti, non letture integrali):

1. `grep -c "function" progetto/*.js` — quante funzioni esistono;
2. `grep -nE "calcola|somma|soglia|tasso|percent|importo" progetto/*.js | grep -v "^\s*//"` — quante fanno ARITMETICA di dominio (non I/O, non filtro);
3. se la risposta è "per lo più filtri/esclusioni/controlli di coerenza", il
   dominio vuole un PROGETTO (`sviluppatore-gas`) o un censimento
   (`revisore-gas`), non un oracolo Python: un oracolo per un dominio a densità
   di flusso è un pettine (bocciato per principio — la lezione del 6° ciclo);
4. se la densità c'è, cerca l'ORACOLO-DATI (listino, tabella, piano): una
   formula senza la sua tabella di verità non può nascere — la tabella diventa
   una domanda di dominio, non un'estrazione a memoria.

## 4. Quando il contesto trovato CHIUDE il compito

Se il giro di selezione trova il problema già risolto, già deciso o già pagato
(una voce SAL, un oracolo, un pattern che lo copre), il compito non è progettare:
è riportare il riferimento e fermarsi. Il contesto più efficace è quello che
soprassiede al lavoro, non quello che lo prepara.


## Vedi anche

skill `brainstorming` (il passo prima) · skill `design-doc` (il passo dopo)
