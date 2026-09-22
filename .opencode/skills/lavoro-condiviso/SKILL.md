---
name: lavoro-condiviso
description: Usa questa skill quando sul repo lavorano DUE O PIÙ persone o sessioni nello stesso momento — presenza dichiarata prima di toccare, diari append-only che non confliggono, codice su rami separati, e la disciplina push. Il fallimento che chiude: due mani sulla stessa zona che si accorgono l'una dell'altra solo al conflitto di merge. Il presidio («sto toccando X fino alle 14:30») è visibilità, NON un lock: la contesa si risolve parlandosi. Usa quando inizi un lavoro su un repo condiviso, quando vedi PRESIDI.md con voci vive, o quando due sessioni partono insieme.
---

# lavoro-condiviso — due mani, zero sorprese

## 1. Prima di iniziare: guarda e dichiara

```
bash tools/presidio.sh lista            # chi c'è adesso, e su cosa
bash tools/presidio.sh claim <zona> <nota>   # la tua presenza (4h, poi scade da sé)
```

La zona è il pezzo che toccherai («oracoli», «skill gas-sviluppo», «agente
revisore-gas», «SAL»). Il presidio si COMMITTA E SI PUSHA presto: la presenza
visibile è quella che arriva all'altro clone. Presidio scaduto = potato e
dichiarato da `lista`, mai in silenzio.

## 1bis. Processare un report dal campo È un lavoro su zona

Il caso E-016: due sessioni hanno processato lo STESSO report in parallelo senza
presidio — spreco di un'ora, scoperto solo al push rifiutato. La convenzione dei nomi
(date-slug) rende la collisione benigna (stesso file, nessuna divergenza), MA il
lavoro duplicato è spreco evitabile: `presidio.sh claim campo-<slug>` prima di
iniziare il processing, `rilascia` a fine commit.

## 2. Le tre classi di file (chi confligge e chi no)

| Classe | File | Due mani insieme |
|---|---|---|
| **Append-only** | SAL.md, docs/campo/*.md, PRESIDI.md | SICURO: merge union — entrambe le voci sopravvivono al merge, verificato |
| **Codice** | tools/, skills/, agents/ | SU RAMI: una mano un ramo una PR; il presidio evita di partire due volte sullo stesso punto |
| **Stato locale** | .ciclo/, .campo-rem (gitignored) | OGNI CLONE IL SUO: il ciclo di Luca non vede quello di Lavinia — e va bene così |

## 3. La disciplina del push (il punto dove le mani si scontrano davvero)

1. `git pull --rebase` PRIMA di pushare (il conflitto si risolve da chi arriva
   secondo, sul proprio ramo, non in main).
2. MAI force-push su rami condivisi. Il force-push è del solo ramo proprio
   mai merged, e va dichiarato.
3. I diari si appendono e si pushano spesso: una voce pushata è una voce che
   l'altro riceve intera (union); dieci voci in locale sono dieci righe che
   l'altro riscrive per sbaglio.
4. Se il merge arriva lo stesso: i diari si risolvono da soli (union), il
   codice si risolve sul ramo di chi arriva secondo — LEGGENDO il presidio
   dell'altro prima di scegliere chi cede.

## 4. Contesa: l'allerta non è un divieto

`lista` dichiara «⚠ CONTESA su zona: N presidii distinti». La risposta NON è
aspettare meccanicamente: è parlarsi (o, fra sessioni AI, leggere il NOTE
dell'altro presidio e scegliere zone diverse). Un lock distribuito fingerebbe
di risolvere ciò che solo la conversazione risolve.

## 5. Il turno notturno resta centralizzato

repos.conf e repos.key vivono sul Mac che gira la notte: il turno notturno è
CENTRALIZZATO PER DISEGNO (AGENTS.md §0bis). Il distribuito è il lavoro
diurno: due mani, due cloni, i medesimi rami convenuti (claude/*, night/*,
glm/*), la stessa regola del presidio.
