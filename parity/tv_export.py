"""Lettori degli export di TradingView, con mappatura dichiarata e mai indovinata.

I nomi delle colonne cambiano con la lingua dell'interfaccia e con la versione:
l'italiano scrive "Data/Ora" e "P&L netto %", l'inglese "Date/Time" e "Net P&L %".
Qui la mappatura si RISOLVE e si stampa. Se una colonna richiesta non si trova, la
lettura fallisce a voce alta elencando le colonne viste: una mappatura sbagliata in
silenzio produrrebbe un verdetto di parita' senza significato.
"""

import sys

import numpy as np
import pandas as pd

ALIAS_BARRE = {
    "time": ("time", "data", "date", "datetime", "data/ora", "date/time"),
    "Open": ("open", "apertura"),
    "High": ("high", "massimo", "max"),
    "Low": ("low", "minimo", "min"),
    "Close": ("close", "chiusura"),
    "Volume": ("volume", "vol"),
}

ALIAS_TRADE = {
    "trade_n": ("trade #", "trade#", "n. operazione", "operazione #", "trade"),
    "tipo": ("type", "tipo"),
    "segnale": ("signal", "segnale"),
    "data": ("date/time", "data/ora", "datetime", "data", "time"),
    "prezzo": ("price usd", "prezzo usd", "price", "prezzo"),
}


def _risolvi(colonne, alias: dict, obbligatorie: tuple) -> dict:
    """Associa ogni nome canonico a una colonna reale; alza se ne manca una obbligatoria."""
    normali = {str(c).strip().lower(): c for c in colonne}
    mappa = {}
    for canonico, varianti in alias.items():
        for v in varianti:
            if v in normali:
                mappa[canonico] = normali[v]
                break
    mancanti = [k for k in obbligatorie if k not in mappa]
    if mancanti:
        raise ValueError(
            f"colonne non trovate: {mancanti}\n  colonne presenti: {list(colonne)}\n"
            "  aggiungi l'alias in tv_export.py invece di rinominare il CSV a mano"
        )
    return mappa


def leggi_barre(percorso: str) -> pd.DataFrame:
    """'Export chart data' di TradingView -> OHLCV con indice temporale UTC-naive."""
    raw = pd.read_csv(percorso)
    mappa = _risolvi(raw.columns, ALIAS_BARRE, ("time", "Open", "High", "Low", "Close"))
    df = pd.DataFrame(
        {k: raw[mappa[k]] for k in ("Open", "High", "Low", "Close") if k in mappa}
    )
    df["Volume"] = raw[mappa["Volume"]] if "Volume" in mappa else 0.0
    df.index = _tempo(raw[mappa["time"]])
    df = df[~df.index.isna()].sort_index()
    print(f"  barre lette da {percorso}: {len(df)} — da {df.index[0]} a {df.index[-1]}")
    if "Volume" not in mappa:
        print("  ATTENZIONE: nessuna colonna volume. isVolSpike sara' sempre falso e")
        print("  l'entrata NON puo' scattare: riesporta includendo il volume.")
    return df


def leggi_trade(percorso: str) -> pd.DataFrame:
    """'List of Trades' -> una riga per operazione, con entrata E uscita appaiate.

    Le uscite servono quanto le entrate: senza, non si sa quando la strategia era
    flat, e il Pine filtra le entrate con `not inShort` (:407).
    """
    raw = pd.read_csv(percorso)
    mappa = _risolvi(raw.columns, ALIAS_TRADE, ("trade_n", "tipo", "data"))
    df = pd.DataFrame({k: raw[v] for k, v in mappa.items()})
    df["data"] = _tempo(df["data"])
    tipo = df["tipo"].astype(str).str.lower()
    df["lato"] = np.where(
        tipo.str.contains("entry|entrata|ingresso", na=False),
        "entrata",
        np.where(tipo.str.contains("exit|uscita|chiusura", na=False), "uscita", ""),
    )
    if not (df["lato"] == "entrata").any():
        raise ValueError(
            f"nessuna ENTRATA riconosciuta. Valori di '{mappa['tipo']}': "
            f"{sorted(df['tipo'].astype(str).unique())}\n"
            "  l'export deve contenere sia le righe di entrata sia quelle di uscita"
        )
    trade = (
        df[df["lato"] != ""]
        .dropna(subset=["data"])
        .pivot_table(index="trade_n", columns="lato", values="data", aggfunc="first")
        .reset_index()
    )
    if "uscita" not in trade.columns:
        trade["uscita"] = pd.NaT
        print("  ATTENZIONE: nessuna riga di uscita: le posizioni sono trattate come")
        print("  chiuse subito, e un segnale su una barra occupata risultera' in piu'.")
    trade = trade.dropna(subset=["entrata"]).sort_values("entrata").reset_index(drop=True)
    aperte = int(trade["uscita"].isna().sum())
    print(f"  operazioni lette da {percorso}: {len(trade)}"
          f" — da {trade['entrata'].iloc[0]} a {trade['entrata'].iloc[-1]}"
          + (f" ({aperte} senza uscita)" if aperte else ""))
    return trade


def _tempo(col: pd.Series) -> pd.DatetimeIndex:
    """Accetta ISO, 'YYYY-MM-DD HH:MM' e unix in secondi."""
    numerica = pd.to_numeric(col, errors="coerce")
    if numerica.notna().all() and numerica.median() > 1e8:
        return pd.DatetimeIndex(pd.to_datetime(numerica, unit="s", utc=True)).tz_localize(None)
    t = pd.to_datetime(col, errors="coerce", utc=True, format="mixed")
    return pd.DatetimeIndex(t).tz_localize(None)


if __name__ == "__main__":
    for p in sys.argv[1:]:
        print(f"\n{p}:")
        print(pd.read_csv(p, nrows=3).to_string())
