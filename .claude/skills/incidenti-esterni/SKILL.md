---
name: incidenti-esterni
description: Usa questa skill per cercare, verificare e ROVESCIARE a nostro favore gli incidenti esterni — post-mortem di software (Knight Capital, GitLab 2017, CrowdStrike), incidenti di AI agentica (OpenAI/HuggingFace), outage celebri. Ogni incidente documentato è una lezione già pagata da altri: la mossa è il rovesciamento (ogni causa è una capacità o un difetto che possiamo avere anche noi — si verifica quale dei due, e se la guardia esiste già o manca). Il registro delle esperienze processate vive in docs/incidenti-esterni/REGISTRO.md, una voce per incidente con la mappa cause→nostre-guardie. Usa quando Luca porta un articolo/video di un incidente, quando un ghiro di miglioramento cerca ispirazione esterna, o quando una nuova famiglia di difetti suggerisce che qualcun altro l'ha già incontrata.
---

# incidenti-esterni — le lezioni già pagate da altri

> Il costo dell'incidente altrui è già stato pagato: l'unica spesa che resta
> è leggerlo bene. Un post-mortem è un giro di revisione gratuito sul nostro
> sistema — se lo si rovescia.

## Le cinque mosse

**M1 — Verifica la fonte.** L'incidente è documentato da chi l'ha vissuto
(post-mortem ufficiale, report SEC, report di sicurezza) o solo raccontato?
Un incidente senza fonte primaria si dichiara «raccontato», non «documentato»:
il registro distingue le due cose (l'onore del NON VERIFICATO vale anche qui).

**M2 — Estrai LE CAUSE, non l'aneddoto.** Il post-mortem serio elenca le cause
(2-5 di solito). Ogni causa va isolata in una frase senza i dettagli del caso:
«deploy manuale incompleto su 8 server», «backup mai provato con un ripristino»,
«task impossibile senza uscita consentita». La frase senza i dettagli è quella
che si può confrontare col nostro sistema.

**M3 — ROVESCIA: causa → nostro equivalente.** La domanda per ogni causa:
«abbiamo qualcosa che può fare questo, e da che parte sta?» Ogni causa diventa
una CAPACITÀ (deploy, backup, agenti, automazione) e il punto è: la nostra
istanza di quella capacità ha la guardia che l'incidente dimostra necessaria?

**M4 — Verifica le guardie esistenti.** Per ogni equivalente: la guardia c'è già
(pattern, test, lente, hook, regola)? Se c'è: l'incidente la CONFERMA — si
annota, e la conferma esterna è preziosa perché dice che la famiglia di difetti
è reale anche fuori casa nostra. Se manca: è un buco — si costruisce.

**M5 — Registra.** Una voce nel registro (docs/incidenti-esterni/REGISTRO.md):
incidente, fonte, cause, mappa causa→equivalente→guardia (esistente o nuova),
ciò che abbiamo aggiunto. Il registro NON duplica i pattern: punta a loro.

## Il rovesciamento — esempi già fatti

| Incidente | Causa | Nostro equivalente | Guardia |
|---|---|---|---|
| OpenAI/HF 2026 | message board non autorizzata fra agenti | la staffetta (.ciclo, PRESIDI, SAL, campo) | canali dichiarati: pattern `la-staffetta` |
| OpenAI/HF 2026 | reward hacking (ricompensa senza lavoro) | teatro verde (test che passa senza verificare) | `mutation-tests` (l'antidoto c'era già) |
| OpenAI/HF 2026 | task impossibile senza uscita | agente notturno che non si arrende | «tre tentativi poi architettura» + rilevatore loop |

## Le fonti dove cercare

- Post-mortem ufficiale di chi l'ha vissuto (il primo cittadino)
- Report SEC/regolatori (Knight Capital), report di sicurezza interna (OpenAI),
  blog engineering (GitLab, Cloudflare)
- Incidenti di AI agentica: via via più frequenti — cercare «AI agent incident»,
  i report dei safety institute
- IL VIDEO/ARTICOLO DI LUCA: il campo porta spesso la notizia prima del protocollo

## Regola di opportunità

Un incidente si processa quando arriva, non a campagna: la lezione fresca
(con l'emozione della notizia) si trasforma meglio di quella da catalogo. Ma
quando una famiglia di difetti interna NON trova corrispondenza esterna, vale
la pena cercare: o siamo i primi (dichiararlo), o non abbiamo cercato bene.
