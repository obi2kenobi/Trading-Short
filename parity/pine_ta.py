"""Primitive ta.* di Pine Script, con la semantica di TradingView, non quella di pandas.

La differenza che conta: `ta.ema(src, n)` di Pine resta `na` per le prime n-1 barre
e si innesca con la SMA delle prime n, poi ricorre. `Series.ewm(span=n, adjust=False)`
parte dal primo valore. Su un TEMA200 le due curve restano distinguibili per centinaia
di barre. Stessa cosa per `ta.rma` (Wilder), che backtest.py sostituisce con una SMA.
"""

import numpy as np
import pandas as pd


def sma(src: pd.Series, n: int) -> pd.Series:
    """ta.sma — NaN finché non ci sono n barre."""
    return src.rolling(n).mean()


def _seeded_recursive(src: pd.Series, n: int, alpha: float) -> pd.Series:
    """Ricorsione con innesco SMA(n) sulla prima finestra piena di valori non-NaN.

    Comune a ta.ema (alpha = 2/(n+1)) e ta.rma (alpha = 1/n).
    """
    out = pd.Series(np.nan, index=src.index, dtype="float64")
    vals = src.to_numpy(dtype="float64")
    acc, filled = np.nan, 0
    for i, v in enumerate(vals):
        if np.isnan(v):
            continue
        filled += 1
        if filled < n:
            continue
        if filled == n:
            window = vals[: i + 1]
            acc = np.nanmean(window[~np.isnan(window)][-n:])
        else:
            acc = alpha * v + (1 - alpha) * acc
        out.iloc[i] = acc
    return out


def ema(src: pd.Series, n: int) -> pd.Series:
    """ta.ema — alpha = 2/(n+1), innesco SMA(n)."""
    return _seeded_recursive(src, n, 2.0 / (n + 1.0))


def rma(src: pd.Series, n: int) -> pd.Series:
    """ta.rma — smoothing di Wilder, alpha = 1/n, innesco SMA(n)."""
    return _seeded_recursive(src, n, 1.0 / n)


def tema(src: pd.Series, n: int) -> pd.Series:
    """3*ema - 3*ema(ema) + ema(ema(ema)), nella forma scritta nel Pine."""
    e1 = ema(src, n)
    e2 = ema(e1, n)
    e3 = ema(e2, n)
    return 3 * e1 - 3 * e2 + e3


def true_range(high: pd.Series, low: pd.Series, close: pd.Series) -> pd.Series:
    """ta.tr — sulla prima barra vale high-low: non esiste un close precedente."""
    prev = close.shift(1)
    tr = pd.concat([high - low, (high - prev).abs(), (low - prev).abs()], axis=1).max(axis=1)
    tr.iloc[0] = high.iloc[0] - low.iloc[0]
    return tr


def atr(high: pd.Series, low: pd.Series, close: pd.Series, n: int) -> pd.Series:
    """ta.atr — rma del true range, NON la sua media semplice."""
    return rma(true_range(high, low, close), n)


def rsi(src: pd.Series, n: int) -> pd.Series:
    """ta.rsi — rma di guadagni e perdite, NON la loro media semplice."""
    delta = src.diff()
    up = rma(delta.clip(lower=0), n)
    down = rma((-delta).clip(lower=0), n)
    out = 100.0 - 100.0 / (1.0 + up / down)
    out = out.mask(down == 0, 100.0)
    out = out.mask(up == 0, 0.0)
    return out.where(up.notna() & down.notna())


def linreg(src: pd.Series, n: int, offset: int = 0) -> pd.Series:
    """ta.linreg — valore della retta ai minimi quadrati sulle ultime n barre."""
    x = np.arange(n, dtype="float64")
    sx, sxx = x.sum(), (x * x).sum()
    denom = n * sxx - sx * sx

    def endpoint(window: np.ndarray) -> float:
        sy = window.sum()
        sxy = (x * window).sum()
        slope = (n * sxy - sx * sy) / denom
        intercept = (sy - slope * sx) / n
        return intercept + slope * (n - 1 - offset)

    return src.rolling(n).apply(endpoint, raw=True)


def supertrend_trend(high, low, close, factor: float, atr_series: pd.Series) -> pd.Series:
    """La ricorsione supertrend ESATTAMENTE come scritta nel Pine (:344-350).

    Non è `ta.supertrend`: il Pine la riscrive a mano confrontando close[1] con le
    bande della barra precedente. Un porting su ta.supertrend darebbe un'altra serie.
    """
    hl2 = (high + low) / 2.0
    up_c = (hl2 - factor * atr_series).to_numpy(dtype="float64")
    dn_c = (hl2 + factor * atr_series).to_numpy(dtype="float64")
    c = close.to_numpy(dtype="float64")

    n = len(c)
    up, dn = up_c.copy(), dn_c.copy()
    trend = np.zeros(n, dtype="int64")
    for i in range(1, n):
        prev_up = up[i - 1] if not np.isnan(up[i - 1]) else up_c[i]
        prev_dn = dn[i - 1] if not np.isnan(dn[i - 1]) else dn_c[i]
        up[i] = max(up_c[i], prev_up) if c[i - 1] > prev_up else up_c[i]
        dn[i] = min(dn_c[i], prev_dn) if c[i - 1] < prev_dn else dn_c[i]
        if c[i] > prev_dn:
            trend[i] = 1
        elif c[i] < prev_up:
            trend[i] = -1
        else:
            trend[i] = trend[i - 1]
    return pd.Series(trend, index=close.index)
