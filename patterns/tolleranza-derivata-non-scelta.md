# tolleranza-derivata-non-scelta
**Àncora**: REPO-R ingestione 2026-09-02 (oracolo con 3 divergenze su 14) · **Nato**: 2026-09-03
Quando l'oracolo esiste ma NON torna esatto, la tolleranza si DERIVA dal meccanismo che genera lo scarto, non si sceglie a occhio. (a) L'ipotesi sul meccanismo si dichiara (arrotondamento all'unità, troncamento, ecc.); (b) la soglia si calcola da quell'ipotesi (arrotondamento → max n×0,5 per riga con n addendi — è un bound, non una preferenza); (c) finché l'ipotesi non è confermata dal proprietario del dominio, si FLAGGA (Coerenza: OK / DA VERIFICARE diff N) invece di scartare o approvare in silenzio. Le due reazioni sbagliate: uguaglianza secca (falsi allarmi → il controllo viene spento) e soglia a occhio (il giorno che il residuo è vero non lo vedi).

**Vedi anche**: `oracolo-indipendente` · `soglia-con-provenienza` · `soglia-con-default-guardato`
