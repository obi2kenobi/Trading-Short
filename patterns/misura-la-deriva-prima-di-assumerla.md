# misura-la-deriva-prima-di-assumerla
**Àncora**: REPO-J (REPO-J) — diff contro la baseline pre-fix 56e559d, non
contro HEAD che includeva i fix mai deployati: 11 file sembravano divergenti,
3 lo erano davvero (report: docs/campo/2026-08-28-REPO-J-git-live-drift.md) ·
**Nato**: 2026-08-28

Quando un mandato implica «tratta il live come autoritativo e correggi tutto
di nuovo» dopo una sessione di fix non ancora deployata, il passo 0 NON e
eseguire il mandato ne chiedere in astratto: e MISURARE la deriva con un diff
contro la BASELINE ESATTA da cui la sessione di fix e partita (non contro HEAD,
che include i fix stessi), e con diff whitespace-insensitive (il round-trip
di clasp normalizza: 11 file byte-diversi, 3 semanticamente diversi). Solo
dopo aver misurato si torna con una proposta scalata alla deriva REALE.

**Vedi anche**: `regola-provata-non-assunta` · `chiave-stabile-etichetta-libera` · `gas-vivo-definitivo`
