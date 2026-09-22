---
name: verifica-visiva
description: Prende uno screenshot reale della dashboard/webapp GAS appena deployata (URL /dev o /exec di Apps Script) e lo confronta con quello di prima, prima che la "review visiva di Luca" sia l'unico controllo sul risultato. Nato da un pattern ripetuto senza eccezioni nell'audit di REPO-B (2026-08-21): tutte e 4 le commesse #10-13 finivano con "review visiva nel deploy" come unica verifica del frontend — nessun agente aveva mai guardato lo schermo. Usa quando l'utente chiede di verificare visivamente un deploy GAS, confrontare prima/dopo di una dashboard, o prima di consegnare una PR che tocca Index.html/App.html di un progetto Apps Script. Richiede un URL di deploy reale e raggiungibile (clasp deploy fatto, sessione autenticata) — se non c'è, dillo e fermati: non si finge uno screenshot che non si può prendere.
---

# verifica-visiva — lo schermo, non solo il codice

Il banco avversariale prova la logica; questo prova che la pagina **si apre e mostra qualcosa
di sensato**. Sono due controlli diversi: un banco verde e un frontend che mostra una pagina
bianca (o l'errore "Autorizzazione richiesta") sono entrambi possibili insieme.

## 0. Prerequisito — non aggirabile

Serve un URL di deploy Apps Script raggiungibile (`.../exec` o `.../dev`), con la sessione
Google già autenticata nel browser che lo strumento controlla. Senza questo:
- **non fingere** uno screenshot leggendo il codice HTML e descrivendo cosa "dovrebbe" mostrare;
- dillo esplicitamente all'utente: "verifica visiva non eseguibile qui, serve [cosa manca]".

## 1. Metodo

1. `node tools/verifica-visiva.js <url> <percorso-output.png>` — apre l'URL con Chromium
   headless via CLI (`--dump-dom` + `--screenshot`, **zero dipendenze nuove**: NON
   Playwright, assente in questo repo), aspetta un timeout fisso di 8s
   (`--virtual-time-budget=8000`, nessuna attesa di un selettore — bug reale corretto:
   revisione 14 lenti, 2026-08-28, questa riga descriveva un comportamento che il tool
   non ha mai avuto: un terzo argomento verrebbe silenziosamente ignorato), salva lo
   screenshot a schermo intero.
2. **Guardia contro il falso verde**: lo strumento controlla anche il testo della pagina per
   segnali di errore comuni di Apps Script ("Autorizzazione richiesta", "Errore di script",
   "exception", pagina vuota sotto una soglia di caratteri) — se ne trova uno, lo script esce
   1 e lo dice, anche se lo screenshot si è salvato correttamente. Uno screenshot preso non è
   uno screenshot buono.
3. Se esiste uno screenshot precedente allo stesso percorso logico (stesso nome, run
   precedente), confrontane le dimensioni file come primo indizio grezzo di "è cambiato
   qualcosa" — non un diff pixel-perfect, solo un segnale povero ma gratuito.
4. Allega il PNG al report del gate (o mandalo con SendUserFile se sei in una sessione
   interattiva) — non descriverlo a parole: chi legge deve vederlo.

## 2. Regole

- Mai eseguire azioni che modificano dati nella pagina (click su bottoni che scrivono,
  "Salva registro", ecc.) — solo apertura, attesa, screenshot. È una verifica, non un test E2E
  con side-effect su dati reali di produzione.
- Se la pagina richiede OAuth interattivo (primo accesso), fermati e dillo: questo strumento
  verifica un deploy già autorizzato, non fa il login per la prima volta.
- Il confronto prima/dopo è un aiuto per l'occhio umano, non un verdetto automatico: la
  decisione "questo screenshot è giusto" resta alla review di Luca — lo strumento gliela
  porta pronta, non la sostituisce.

## 3. Limite dichiarato

Non eseguibile da una sessione senza clasp/OAuth locale (es. questa sessione cloud, al
momento della sua scrittura, 2026-08-21): verificato che il meccanismo Playwright/Chromium
funziona nell'ambiente (screenshot di una pagina locale), non verificato contro un vero
deploy Apps Script — richiede il Mac con la sessione Google autenticata.


## Vedi anche

Per il metodo completo di sviluppo GAS: skill `gas-sviluppo`.


## Vedi anche

La formula da verificare segue la skill `controllo-gestione`.
