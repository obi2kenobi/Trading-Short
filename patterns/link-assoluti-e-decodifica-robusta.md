# link-assoluti-e-decodifica-robusta
**Àncora**: REPO-CR doGet · **Nato**: 2026-09-01 (Centrale_Rischi: click sui mesi → pagina bianca)
Le Web App GAS nel sandbox risolvono i link RELATIVI contro googleusercontent, e il redirect interno DOPPIO-CODIFICA i parametri (dipende dal percorso: click vs URL diretto produce codifiche diverse). La forma sicura: URL ASSOLUTO costruito dal server + decodifica ripetuta finché la stringa si stabilizza, come inciso standard nei doGet. Non è un dettaglio cosmetico: senza questo, ogni navigazione interna della webapp si rompe in modo diverso a seconda di COME ci si arriva.

**Vedi anche**: `manifest-webapp-nel-repo` · `banco-browser-per-webapp-gas`
