"""Verdetto di parita' sulle ENTRATE: il Python spara sulle stesse barre del Pine?

Il confronto usa la lista trade di TradingView come oracolo DOPPIO: da un lato le
entrate da riprodurre, dall'altro gli intervalli in cui la strategia era in posizione.
Serve il secondo perche' il Pine filtra con `not inShort` (:407): senza sapere quando
era dentro, un segnale Python su una barra occupata sembrerebbe un falso positivo.

Ogni divergenza esce con la scomposizione del panic score su quella barra: il punto
non e' sapere CHE diverge, e' sapere QUALE addendo la causa.

Uso:
  python3 parity/compare.py --bars 4h.csv --trades trades.csv [--daily giornaliero.csv]

Esiti: 0 parita' entro tolleranza · 1 divergente o input insufficiente.
Il verdetto e' sempre sull'ultima riga.
"""

import argparse
import sys

import pandas as pd

sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parent))

import pine_entry as pe
import tv_export as tv

COMPONENTI = [
    "is_vol_spike",
    "is_panic_bar",
    "is_rsi_panic",
    "is_rsi_crashing",
    "is_price_accel",
    "significant_gap",
    "consecutive_red",
    "is_structural_breakout",
]


def barra_di(indice: pd.DatetimeIndex, quando: pd.Timestamp):
    """La barra che contiene `quando` — l'ultima aperta non dopo di esso."""
    pos = indice.searchsorted(quando, side="right") - 1
    return None if pos < 0 else indice[pos]


def intervalli_in_posizione(trade: pd.DataFrame, indice: pd.DatetimeIndex) -> pd.Series:
    """Maschera: True sulle barre in cui l'oracolo era GIA' dentro una posizione.

    La barra dell'entrata resta False (e' li' che il segnale deve coincidere); quella
    dell'uscita torna libera, perche' il Pine puo' rientrare dalla barra dopo.
    """
    dentro = pd.Series(False, index=indice)
    for apertura, chiusura in zip(trade["entrata"], trade["uscita"]):
        fine = indice[-1] if pd.isna(chiusura) else chiusura
        dentro.loc[(indice > apertura) & (indice <= fine)] = True
    return dentro


def scomponi(comp: pd.DataFrame, quando) -> str:
    """Le componenti accese su una barra, piu' il punteggio contro la soglia."""
    riga = comp.loc[quando]
    accese = [k for k in COMPONENTI if bool(riga.get(k, False))]
    return (
        f"score {int(riga['panic_score'])}/{int(riga['panic_threshold'])}"
        f" · bear={bool(riga['is_bear'])} strong={bool(riga['is_strong_bear'])}"
        f" · ST={int(riga['trend_in'])} wtDown={bool(riga['wt_down'])}"
        f" volSpike={bool(riga['is_vol_spike'])}"
        f" · accese: {', '.join(accese) if accese else 'nessuna'}"
    )


def confronta(comp: pd.DataFrame, trade: pd.DataFrame, max_dettagli: int) -> int:
    """Stampa il confronto e ritorna il numero di divergenze."""
    idx = comp.index
    attese = [barra_di(idx, t) for t in trade["entrata"]]
    coperte = [(t, b) for t, b in zip(trade["entrata"], attese) if b is not None]
    fuori = len(attese) - len(coperte)
    if fuori:
        print(f"\n  {fuori} entrate dell'oracolo cadono prima della prima barra esportata: escluse")

    attese_set = {b for _, b in coperte}
    dentro = intervalli_in_posizione(trade, idx)
    sparati = set(idx[comp["short_ok"] & ~dentro])

    mancate = sorted(attese_set - sparati)
    extra = sorted(sparati - attese_set)

    print(f"\n{'=' * 72}\n  ENTRATE — Pine {len(attese_set)} · Python {len(sparati)}\n{'=' * 72}")
    print(f"  coincidenti      {len(attese_set & sparati)}")
    print(f"  mancate dal Python (il Pine entra, il Python no)   {len(mancate)}")
    print(f"  in piu' dal Python (il Python entra, il Pine no)   {len(extra)}")

    if not comp["htf_pronto"].any():
        print("\n  ⛔ il filtro bear market non e' MAI pronto su questi dati:")
        print("     TEMA200 giornaliero vuole 597 barre daily di riscaldamento.")
        print("     Esporta anche il grafico GIORNALIERO e passalo con --daily.")

    for titolo, elenco in (("MANCATE", mancate), ("IN PIU'", extra)):
        if not elenco:
            continue
        print(f"\n  --- {titolo} (prime {min(len(elenco), max_dettagli)} di {len(elenco)}) ---")
        for quando in elenco[:max_dettagli]:
            print(f"    {quando}  {scomponi(comp, quando)}")

    return len(mancate) + len(extra)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--bars", required=True, help="Export chart data del TF operativo")
    ap.add_argument("--trades", required=True, help="List of Trades della stessa esecuzione")
    ap.add_argument("--daily", help="Export chart data giornaliero (filtro bear market)")
    ap.add_argument("--max-dettagli", type=int, default=15)
    a = ap.parse_args()

    print("Banco di parita' Pine ↔ Python — ambito: sole ENTRATE\n")
    barre = tv.leggi_barre(a.bars)
    giorni = tv.leggi_barre(a.daily) if a.daily else None
    trade = tv.leggi_trade(a.trades)

    comp = pe.short_ok(barre, giorni)
    if comp.attrs["htf_derivato"]:
        print("\n  ASSUNZIONE DICHIARATA: nessun --daily, le barre giornaliere sono")
        print("  ricavate ricampionando quelle operative. Non sono quelle che")
        print("  TradingView usa per request.security: la divergenza che ne esce")
        print("  non e' attribuibile alla logica.")

    divergenze = confronta(comp, trade, a.max_dettagli)
    print()
    if divergenze == 0:
        print("PARITA' ENTRATE: VERDE — le stesse barre su entrambi i lati")
        return 0
    print(f"PARITA' ENTRATE: ROSSA — {divergenze} barre divergenti")
    return 1


if __name__ == "__main__":
    sys.exit(main())
