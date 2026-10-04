---
name: n-giri
description: Il metodo degli N giri (i «cinquanta giri») per analizzare a fondo un progetto intero — N letture indipendenti, un'area e una lente per giro, a caccia di difetti silenziosi e di cio' che manca; poi verifica avversariale, sintesi dei temi trasversali, correzione a banco. Usa quando l'utente chiede N giri, cinquanta giri, un'analisi lenta e approfondita ripetuta N volte, una revisione a ventaglio di un progetto o di un'area, o invoca /n-giri. Nato dal campo (REPO-I, REPO-G, REPO-J, REPO-W, Budget Vendite): prima esisteva solo come artefatto finito da ricostruire a mano. Non e' dev-critic (una critica singola, un target) ne' goal (ottimizzazione iterativa con tetto di tentativi): qui la forza e' l'indipendenza di molte letture e la loro verifica.
---

# n-giri — molte letture indipendenti, un metodo che non si ricostruisce a mano

Il workflow dichiarativo, con le misure del campo, e' in `docs/ngiri-paralleli.md`. Questa skill
e' la procedura. Gli esempi completi stanno nell'hub, nei report di campo di REPO-I (2026-08-27) e
di Budget Vendite (2026-09-19), in docs/campo/.

## 0. Prima di partire

- **Confini dichiarati**: cosa è raggiungibile (il vivo? il gestionale? `gh`?) e cosa no. I giri
  leggono il codice; nessun giro tocca il vivo.
- **Settimo patto**: `bash tools/debiti-riapertura.sh`. I debiti risolvibili vanno prima, quelli di
  dominio diventano domande.
- **Che giro è?** Bug (correttezza), prodotto (cosa manca), o entrambi. Sono due batterie di lenti
  ORTOGONALI: si sceglie quella giusta per il problema cercato.

## 1. Il brief unico, scritto PRIMA dei giri

Un file solo, copiato da `references/brief-modello.md`, con:
- **Le aree**, ancorate a `file:riga-riga`: nessuna esclusa, oppure l'esclusione è dichiarata.
- **Le lenti**, dichiarate e consolidate. Due lenti che leggono gli stessi file con la stessa
  domanda sono UNA lente; con domande diverse restano due (zero-waste applicato alla revisione).
- **Le regole e il formato d'uscita** (sotto). Il prompt del singolo giro resta di tre righe:
  area, lente, file dove scrivere.

N = aree × lenti. Cinquanta non è un numero sacro: consolidate le lenti, si arriva dove si arriva
(REPO-G: cinquanta richiesti, 14 lenti realmente distinte).

## 2. I giri: una lente per giro, un'area per giro, mai due

Regole di ogni giro, scritte nel brief:
1. **Il giro scrive il suo file PRIMA di rispondere.** Un giro il cui unico prodotto è la risposta
   finale si perde quando l'agente muore, e un limite esaurito a metà del ventaglio è il caso
   normale: Budget Vendite, 16 giri su 20 sopravvissuti a un blocco caduto. **Dove**: nel repo, in
   `docs/giri/<data>/grezzi/`, una cartella ignorata da git — prima di partire
   `git check-ignore docs/giri/<data>/grezzi/x.md` deve rispondere, altrimenti si aggiunge la riga
   `docs/giri/*/grezzi/` al `.gitignore`. Mai nello scratchpad in `/tmp`: il 2026-09-24 una pulizia di
   `/tmp` ha cancellato sei rapporti grezzi in un colpo (E-044). Mai con un nome qualunque fuori da
   `grezzi/`: un rapporto chiamato come il giro (T1, B3) non è ignorato e finirebbe nel commit, con le sue citazioni non
   verificate.
2. **Formato Oggi / Manca / Proposta**, ogni voce ancorata a un `file:riga` letto davvero. Mai un
   principio da manuale.
3. **Tetto di 6 finding per giro**, in ordine di gravità: costringe a scegliere.
4. **«Nulla in questa lente» è un esito valido e dichiarato**, con la motivazione: dice dove la
   lente non morde.
5. **Modello dichiarato per blocco**: se i giri non girano tutti sullo stesso modello, il risultato
   non è omogeneo, e va scritto.
6. I giri partono a lotti, per i limiti di concorrenza; nessun coordinamento fra loro.

## 3. Verifica avversariale: i rilievi si provano, non si contano

- Una seconda fase di agenti prova a **confutare** i rilievi più gravi (REPO-J: 35 di scoperta +
  15 di verifica). **Le smentite si dichiarano**: sono la prova che la verifica non è cosmetica.
  I non verificati restano dichiarati come tali.
- **La convergenza non è una conferma.** Il consolidamento ha due colonne distinte: *segnalato da
  N lenti* e *verificato eseguendo*. La prima non promuove mai la seconda, per nessun N. I giri
  leggono tutti la stessa fonte: se la fonte induce una premessa sbagliata, la ereditano tutti
  (E-001, Budget Vendite). La convergenza dice dove guardare, non cosa concludere.

## 4. Sintesi

- **Temi trasversali**: un tema che emerge da solo in ≥3 aree indipendenti è il segnale più forte.
  Va prima dei singoli rilievi.
- **Tassonomia a quattro categorie**, senza mai una quinta: Implementata · Esclusa (serve una
  decisione di dominio o un dato) · Rinviata (sproporzionata o bloccata) · Già coperta.
- **Prerequisiti nascosti**: una proposta che è prerequisito di altre due si fa per prima.
- **Le domande di dominio** vanno in un file numerato, ciascuna con: perché conta, cosa può dire il
  sistema, cosa solo una persona. Mai indovinate; nel frattempo il codice fa una scelta provvisoria
  dichiarata.

## 5. Correzione (se richiesta)

- **Banco prima della correzione**: il test rosso sul difetto, poi la cura, poi il sabotaggio che
  lo rifà rosso. Una correzione alla volta, un commit per passo.
- I temi trasversali si curano alla radice, non con N patch.
- La regola delle tre ricomparse: la stessa lacuna che ferma il lavoro per la terza volta, in
  progetti diversi, è matura per l'investimento.

## 6. Chiusura

- **L'esito si dichiara**: quanti rilievi, quanti verificati, quante smentite, cosa non è stato
  provato contro il vivo. Zero bug su una superficie ampia è convergenza, non fallimento.
- Il lavoro non finito va nominato in DEBITI.md, nel file delle domande e nel report di campo in
  `docs/campo/`.
- **Sessione continua**: se l'utente chiede esplicitamente di non fermarsi, l'istruzione vince
  sulla cautela di default; il ripasso finale resta obbligatorio.
