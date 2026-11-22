# Indice archivio (mandato G7, 2026-11-22)

Documenti archiviati come SUPERATI (documento datato + almeno una affermazione smentita,
verificata in sola lettura). I file restano per la storia; le loro affermazioni non sono
più affidabili come stato corrente.

| Documento archiviato | Motivo (DIVERSO verificato) | Classe |
|---|---|---|
| REVISIONE-2026-09-22.md | Rapporto di revisione datato 2026-09-22. Le finding di codice D1–D9/S1–S4 risultano ancora vere sul codice attuale (verificate `sed -n` su optimize.py/backtest.py/TEMA pine), MA l'affermazione P3 «`patterns/fixture-provenienza.md` è installato» è SMENTITA: il file è assente (`ls -e`); la lente `tools/fixture-provenienza.sh` c'è, il pattern no. Provenienza git (commit b54bf82, cf2d9ae, PR 57) NON VERIFICABILE: clone shallow (1 commit 8f60797). | SUPERATO |
| 2026-09-22-onboarding-e-dev-critic-trading-short.md | Report di campo datato 2026-09-22. Smentito da 3 riferimenti assenti: `tools/sync-repo.sh`, `tools/copia-hook.sh`, `docs/benvenuto-collaboratori.md` (tutti `ls -e` assenti). Strumenti realmente usati e presenti: `tools/garante-standard.sh`, `tools/cita-verifica.sh`, `tools/privacy-check.sh`. | SUPERATO |

Nota: i due documenti archiviati descrivono eventi/revisioni del 2026-09-22 (PR #57) e sono
cronologia, non stato corrente. Le regole di metodo e il formato report restano validi nei
documenti viventi (CLAUDE.md, DEBITI.md, docs/campo/README.md).
