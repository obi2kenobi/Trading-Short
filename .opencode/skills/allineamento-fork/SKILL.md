---
name: allineamento-fork
description: Usa questa skill COME PRIMA MOSSA quando arrivi su un progetto che esiste in più copie — repo upstream, fork, mirror locale (la cartella gas-src del supervisor), e soprattutto il GAS VIVO in produzione. Il fallimento che chiude è ricorrente e costoso: si lavora sulla propria copia (spesso la più vecchia), si fanno modifiche, e solo POI ci si accorge del fork disallineato — confusione, rifiuti, lavoro rifatto. Qui si decide SIN DA SUBITO qual è la base di lavoro, prima di toccare qualunque file. Per i progetti GAS vale la regola assoluta: IL GAS VIVO È DEFINITIVO, IN PRODUZIONE, MAI UN'IPOTESI — quando due copie discordano, vince il vivo, e il vivo si LEGGE (clasp pull/clone), non si immagina. Il materiale meccanico lo prepara tools/fork-stato.sh; la decisione segue la tabella qui sotto.
---

# allineamento-fork — la prima mossa, prima delle modifiche

> L'ordine degli errori è sempre lo stesso: (1) scelgo una copia perché ce
> l'ho sotto mano, (2) ci lavoro, (3) scopro l'altra copia, (4) cerco di
> riconciliare a cose fatte. Questo protocollo inverte l'ordine: PRIMA si
> sa chi comanda, POI si lavora.

## 0. Quando scatta

Appena un progetto esiste (o può esistere) in più di una copia: un repo
GitHub e un fork; un mirror locale (gas-src) e il progetto vivo su Apps
Script; due cartelle di lavoro. Anche se sei «sicuro» che coincidono: la
convinzione non è una verifica.

## 1. Le cinque mosse (in questo ordine, nessuna saltata)

**M1 — Enumera le copie.** Ogni copia nota: repo upstream (owner/repo),
fork (owner/repo), mirror locale (percorso), e IL VIVO (nome progetto GAS).
Chi enumera le copie trova anche le copie dimenticate (la cartella di tre
settimane fa con lo stesso nome).

**M2 — Leggi il VIVO.** Se il progetto è GAS: `clasp clone` in una cartella
temporanea (mai sopra una copia esistente). Il vivo non si assume: si
scarica. Se clasp non è disponibile o non autenticato: DEGRADATO dichiarato
— ogni confronto seguente è ipotesi, e va scritto «vivo non letto», non
taciuto (l'onore del NON VERIFICATO vale anche qui).

**M3 — Misura la deriva.** `bash tools/fork-stato.sh <copie...>`: matrice di
confronto (file diversi, righe diverse, hash normalizzato) fra tutte le
copie, vivo incluso. Non serve leggere i diff: serve sapere CHI È INDIETRO
e DI QUANTO.

**M4 — Decidi la base con la tabella.** Sin da subito, per iscritto:

| Situazione | Base di lavoro | Il da farsi |
|---|---|---|
| Tutte uguali | la tua copia | si lavora; confronto col vivo prima di ogni PR |
| VIVO avanti | IL VIVO | prima si porta il vivo nella copia di lavoro (clasp pull + commit «allineamento al vivo»), POO le modifiche — mai sopra una copia indietro |
| Fork avanti sul vivo | il fork, consapevoli | le modifiche del fork non-deployate sono IPOTESI finché l'umano non deploya: si lavora lì, ma ogni confronto dichiara «il vivo è indietro di N file» |
| La TUA copia è indietro su entrambi | NESSUNA | non si tocca niente: prima l'allineamento, le tue modifiche sopra una copia vecchia andrebbero rimescolate |
| Vivo illeggibile | la copia più fresca, DEGRADATO | si lavora dichiarando: ogni conclusione sul vivo è ipotesi fino a lettura |

**M5 — Scrivi lo stato.** Un file `FORK-STATO.md` nella copia di lavoro (o
la sezione nella commessa): copie enumerate, deriva misurata, base decisa,
data. La sessione prossima non deve ri-sospettare: legge e sa.

## 2. Le tre regole non negoziabili

1. **IL GAS VIVO È DEFINITIVO.** In produzione, sempre. Il repo può essere
   indietro, il fork avanti (ipotesi), il mirror stantio: quando discordano,
   vince il vivo — e il vivo si LEGGE, non si ricorda, non si deduce, non si
   ipotizza. «Dovrebbe essere così» è la frase vietata.
2. **Mai modifiche sopra una copia non allineata.** Il costo dell'allineamento
   prima è minuti; il costo della riconciliazione dopo è il lavoro rifatto
   più la fiducia persa nel repo.
3. **Lo stato si scrive, non si ricorda.** L'allineamento di oggi è la
   convinzione sbagliata di domani: FORK-STATO.md con data, o non è successo.

## 3. Degradato ≠ Disponibile

Se il vivo non si può leggere (niente clasp, niente credenziali, rete), il
lavoro NON si ferma — ma cambia nome: tutto ciò che dipende dal vivo è
ipotesi dichiarata. Si scrive «vivo non letto, base = fork del GG/MM»
nell'intestazione, e la prima azione della sessione con credenziali è M2.
Il degradato silenzioso è il bug: quello dichiarato è un metodo.
