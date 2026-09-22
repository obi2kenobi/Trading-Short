# somma-diversa-da-zero-non-e-presenza
**Àncora**: progetto onboardato (repo cespiti GAS+BC standalone, REPO-H — vedi
`docs/campo/2026-08-27-revisione-cespiti-gas-bc.md`) — `ProcessData.gs:findDisposals`,
`ReportRollForward.gs:computeDisposalCost/computeDisposalFondo` · **Nato**: 2026-08-27
(un report di cessioni cespiti che usava `if (accumulatore !== 0)` per decidere se un
evento andava mostrato — e un cespite ceduto ma già interamente ammortizzato, il caso
PIÙ comune di dismissione, produceva un accumulatore esattamente zero per compensazione
legittima fra due suoi stessi componenti, sparendo dal report senza errore)

Usare "l'accumulatore di un evento è diverso da zero" come test per "l'evento è
avvenuto" è strutturalmente fragile ogni volta che l'accumulatore somma componenti che
possono cancellarsi a vicenda per compensazione legittima — non solo nel caso raro in
cui capitano per coincidenza, ma nel caso NORMALE del dominio (qui: costo residuo e
fondo ammortamento che si annullano esattamente quando un bene è già ammortizzato al
100%, la situazione più comune di una cessione, non un edge case). Il sintomo è
insidioso perché il test funziona quasi sempre nei casi di test scritti a mano
(nessuno scrive per riflesso un caso "il totale è zero ma l'evento è reale") e fallisce
silenziosamente sui dati reali più comuni, non sui più rari. La correzione non tocca la
soglia né l'arrotondamento (non è un problema di `soglia-con-provenienza`): sostituisce
il test aritmetico con un **flag booleano impostato al momento dell'evento** (qui:
`yearDisposed`, alzato dentro il punto di classificazione del movimento, non derivato
da una somma successiva) — la presenza diventa una proprietà osservata all'origine, non
un'inferenza da un calcolo che può cancellarsi. Verificato dal vivo: un test sintetico
con un cespite già ammortizzato all'apertura, ceduto nell'esercizio con movimenti di
segno opposto che si annullano esattamente, restava escluso dal report PRIMA del fix e
visibile DOPO, sull'identico input — eseguito realmente (non solo letto) in un banco
Node, suite 19/19. Riusabile ovunque una funzione decida "mostra/includi/conta questo
elemento" controllando che una somma di più componenti sia diversa da zero, invece di
un segnale impostato esplicitamente quando il componente viene osservato.

**Nota di famiglia**: vicino a `scarto-mai-silenzioso` ma non coincidente — lì il
problema è una regola di validazione che scarta un valore senza dirlo; qui il valore
non viene scartato da nessuna regola, è il TEST DI ESISTENZA stesso a essere costruito
sul dato sbagliato (un'aritmetica che può cancellarsi) invece che su un segnale diretto.


**Vedi anche**: `stato-vuoto-dalla-pipeline`
