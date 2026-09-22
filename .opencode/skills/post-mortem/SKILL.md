---
name: post-mortem
description: Usa questa skill QUANDO scopri un tuo errore — un fix che ha rotto qualcos'altro, un test che mentiva, una metrica che misurava un'altra cosa, un output che non tornava. Non per i bug del dominio (quelli vanno negli oracoli): per i TUI errori di processo e di ragionamento. L'errore non si archivia: si mette A REGIME — otto campi, una guardia che deve sparare se l'errore torna, e la famiglia di ragionamento che lo ha prodotto. Il registro vive in docs/errori/REGISTRO.md e la lente test-errori.sh pretende che ogni voce sia completa e che la guardia esista davvero.
---

# Post-mortem a regime — il protocollo

> L'errore trovato è un evento; l'errore a regime è un sistema. La differenza:
> l'evento si dimentica, il sistema spara la prossima volta.

## Quando scatta

Hai appena scoperto di aver sbagliato: un tuo fix ha rotto altro, un tuo test
verificava niente, la tua metrica misurava un'altra cosa, il tuo ripristino
non ha ripristinato, la tua asserzione citava un output che non esiste.
**Ferma il fix. Prima il post-mortem, poi si ripara** — il post-mortem freddo
è più onesto di quello fatto dopo essersi giustificati col contesto.

## I campi (tutti obbligatori — l'ottavo dal 2026-09-09)

Dal report REPO-V «la settimana contata»: il campo **«Chi l'ha trovato» (lente / vivo / padrone
del dominio)** è obbligatorio — è il dato che mostra l'asimmetria: le lenti prendono gli errori
meccanici, il dominio quelli di giudizio, che sono i più costosi. Il registro senza quel campo
conta gli errori e nasconde la loro forma.

1. **Sintomo** — cosa si è VISTO per primo (il rosso, l'output strano, il file
   perso). Il sintomo, non la diagnosi.
2. **Causa prossima** — il meccanismo tecnico (cosa nel codice ha prodotto
   l'effetto).
3. **Causa del ragionamento** — LA PARTE CHE MIGLIORA TE: perché l'hai pensato
   così? Quale scorciatoia, quale assunzione data per scontata, quale verifica
   saltata «perché tanto era ovvio».
4. **Perché non ci ha fermati prima** — quale lente/test/hook dormiva, e se
   non esisteva: perché nessuno l'aveva chiesto.
5. **Guardia** — il test/hook/lente che d'ora in poi spara se l'errore torna.
   Una voce di registro senza guardia è una lamentela, non un post-mortem.
6. **Verifica della guardia** — come sappiamo che la guardia spara davvero:
   il post-mortem si chiude solo dopo aver PROVATO la guardia sul caso
   dell'errore (mutazione/incubo riprodotto → rosso → ripristino).
7. **Aggiramento** — se l'errore si ripresenta in attesa di fix meglio: come
   si gira intanto (il workaround onesto, dichiarato).

## Le sei famiglie di ragionamento

Ogni errore va classificato (il registro le usa; più di una se serve):

- **R1 Assunzione non verificata** — «il write avviene dopo il calcolo»,
  «il restore funziona», «tanto è lo stesso file». L'antidoto: la cosa
  ovvia si prova comunque, especially se è ovvia.
- **R2 Verde senza dati** — test che non può fallire, metrica che non misura,
  confronto vuoto==vuoto. L'antidoto: ogni strumento si prova sul caso in cui
  DEVE dire no (mutation-testing, caso negativo).
- **R3 Precondizione non chiesta** — albero sporco, tool presente, file
  tracciato. L'antidoto: il tool dichiara le proprie precondizioni e si ferma
  se mancano (guardia d'ingresso, non da fede).
- **R4 Autoriferimento** — la sonda che si prende, il probe coperto dal test
  che lo testa. L'antidoto: l'arnese non sta nel mirino delle proprie sonde;
  i nomi di prova si costruiscono a runtime.
- **R5 Memoria contro realtà** — asserzioni su stringhe ricordate, header che
  descrivono il progetto del primo giorno, numeri citati a mente. L'antidoto:
  si asserisce sull'output VERO, si legge l'header prima di fidarsi.
- **R6 Effetto collaterale ignorato** — il verdetto verificato, lo stato
  lasciato sporco; il file di prova cancellato ma non quello che ci hai
  scritto dentro. L'antidoto: dopo ogni esperimento si controlla lo stato
  (`git status`), non solo l'esito.

## La voce di registro

Formato (append a `docs/errori/REGISTRO.md`, mai riscritto):

```markdown
## E-NNN <titolo breve, il sintomo>
- Data / sessione: YYYY-MM-DD (<dove stavi facendo cosa>)
- Famiglia: R1…R6 (+ eventuali)
- Chi l'ha trovato: lente / vivo / padrone del dominio (obbligatorio da E-024, 2026-09-09)
- Sintomo: …
- Causa prossima: …
- Causa del ragionamento: …
- Perché non ci ha fermati: …
- Guardia: <file di test/hook/lente> — <cosa fa>
- Verifica guardia: <mutazione/incubo → rosso, quando>
- Aggiramento: …
```

Chiude la voce solo chi ha visto la guardia diventare rossa sul proprio
errore. La lente `tests/test-errori.sh` controlla che ogni voce abbia i sette
campi, la famiglia canonica, e che il file della guardia esista.
