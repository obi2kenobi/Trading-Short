# estrazione-per-testabilita
**Àncora**: REPO-I (controlli trimestrali GAS+BC, vedi docs/campo/2026-08-27-controlli-trimestrali.md)
- quasi ogni fix del ciclo 2026-08-27 ha isolato logica pura da un involucro che tocca
servizi reali (Sheets/Drive/Gmail/BC) PER PODERLA TESTARE, dichiarando l'involucro
"non testabile fuori da Apps Script" invece di forzare un mock che finge · **Nato**: 2026-08-27

Isolare la logica di dominio in funzioni pure (input dati, output dati) e lasciare
l'involucro dei servizi dichiarato NON testabile fuori da GAS non e un dettaglio
implementativo: e il movimento che rende possibile la prova PRIMA/DOPO senza
inventare mock che fingono di verificare. Un mock che sostituisce il servizio e
poi si asserisce su cio che il mock stesso ha restituito non prova nulla del vivo:
l'estrazione onesta prova la logica e DICHIARA il confine. Occorso con la stessa
frequenza delle quattro lenti storiche nel ciclo REPO-I: quinta lente a pieno titolo
(gia presente in nuce in consegna.md Livello 1: "l'estrazione della logica pura E
parte del fix").


**Vedi anche**: `banco-sintetico-per-calcoli-critici` · `estrattore-test-dipendenza-refactor` · `estensione-testata-non-distruttiva`
