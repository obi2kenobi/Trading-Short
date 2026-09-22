"""Banco delle primitive: ogni ta.* confrontata con un oracolo INDIPENDENTE.

L'oracolo non è un'altra chiamata alla stessa funzione: è un ciclo Python scritto a
mano dalla definizione, o numpy. Una funzione confrontata con se stessa certifica
solo di essere deterministica.

Misura anche quanto le primitive di pandas usate oggi in backtest.py si scostano da
quelle di Pine: è il numero che giustifica l'esistenza di questo modulo.

Uso: python3 parity/selftest.py   ·   esce 0 se tutto verde, 1 al primo rosso
"""

import sys

import numpy as np
import pandas as pd

sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parent))

import pine_ta as ta

TOL = 1e-9
ESITI = []


def verifica(nome: str, ottenuto, atteso, tol: float = TOL) -> None:
    a = np.asarray(ottenuto, dtype="float64")
    b = np.asarray(atteso, dtype="float64")
    both_nan = np.isnan(a) & np.isnan(b)
    delta = np.where(both_nan, 0.0, np.abs(a - b))
    peggio = float(np.nanmax(delta)) if delta.size else 0.0
    ok = peggio <= tol and bool((np.isnan(a) == np.isnan(b)).all())
    ESITI.append(ok)
    print(f"  [{'OK ' if ok else 'ROSSO'}] {nome:<34} scarto max {peggio:.3e}")


def serie_di_prova(n: int = 300, seed: int = 7) -> pd.DataFrame:
    """OHLCV sintetico ma di forma realistica: random walk con range e volume."""
    rng = np.random.default_rng(seed)
    close = 20000 + np.cumsum(rng.normal(0, 60, n))
    span = np.abs(rng.normal(0, 45, n)) + 10
    open_ = close - rng.normal(0, 40, n)
    high = np.maximum(open_, close) + span
    low = np.minimum(open_, close) - span
    vol = np.abs(rng.normal(1e6, 3e5, n))
    idx = pd.date_range("2025-01-01", periods=n, freq="4h")
    return pd.DataFrame(
        {"Open": open_, "High": high, "Low": low, "Close": close, "Volume": vol}, index=idx
    )


def oracolo_ricorsivo(vals, n, alpha):
    """ema/rma dalla definizione: innesco SMA(n), poi alpha*v + (1-alpha)*acc."""
    out, acc = [np.nan] * len(vals), np.nan
    for i in range(len(vals)):
        if i + 1 < n:
            continue
        if i + 1 == n:
            acc = sum(vals[:n]) / n
        else:
            acc = alpha * vals[i] + (1 - alpha) * acc
        out[i] = acc
    return out


def oracolo_rsi(vals, n):
    """RSI di Wilder da definizione, senza pandas."""
    up = [np.nan] + [max(vals[i] - vals[i - 1], 0.0) for i in range(1, len(vals))]
    dn = [np.nan] + [max(vals[i - 1] - vals[i], 0.0) for i in range(1, len(vals))]
    ru = oracolo_ricorsivo(up[1:], n, 1.0 / n)
    rd = oracolo_ricorsivo(dn[1:], n, 1.0 / n)
    out = [np.nan]
    for u, d in zip(ru, rd):
        if np.isnan(u) or np.isnan(d):
            out.append(np.nan)
        elif d == 0:
            out.append(100.0)
        elif u == 0:
            out.append(0.0)
        else:
            out.append(100.0 - 100.0 / (1.0 + u / d))
    return out


def oracolo_tr(h, l, c):
    out = [h[0] - l[0]]
    for i in range(1, len(c)):
        out.append(max(h[i] - l[i], abs(h[i] - c[i - 1]), abs(l[i] - c[i - 1])))
    return out


def oracolo_linreg(vals, n):
    """Retta ai minimi quadrati con numpy.polyfit, altra strada rispetto a pine_ta."""
    out = [np.nan] * len(vals)
    x = np.arange(n, dtype="float64")
    for i in range(n - 1, len(vals)):
        m, q = np.polyfit(x, np.asarray(vals[i - n + 1 : i + 1], dtype="float64"), 1)
        out[i] = q + m * (n - 1)
    return out


def main() -> int:
    df = serie_di_prova()
    c = df["Close"]
    vals = c.tolist()

    print("Banco primitive Pine — oracoli indipendenti\n")
    verifica("sma(20)", ta.sma(c, 20), c.rolling(20).mean())
    verifica("ema(21) vs definizione", ta.ema(c, 21), oracolo_ricorsivo(vals, 21, 2 / 22))
    verifica("rma(14) vs Wilder", ta.rma(c, 14), oracolo_ricorsivo(vals, 14, 1 / 14))
    verifica("rsi(14) vs Wilder", ta.rsi(c, 14), oracolo_rsi(vals, 14))
    verifica(
        "true_range vs definizione",
        ta.true_range(df["High"], df["Low"], c),
        oracolo_tr(df["High"].tolist(), df["Low"].tolist(), vals),
    )
    verifica(
        "atr(14) vs rma(tr)",
        ta.atr(df["High"], df["Low"], c, 14),
        oracolo_ricorsivo(oracolo_tr(df["High"].tolist(), df["Low"].tolist(), vals), 14, 1 / 14),
    )
    verifica("linreg(100) vs polyfit", ta.linreg(c, 100), oracolo_linreg(vals, 100), tol=1e-6)

    trend = ta.supertrend_trend(df["High"], df["Low"], c, 2.4, ta.atr(df["High"], df["Low"], c, 10))
    dominio_ok = set(trend.unique()) <= {-1, 0, 1}
    ESITI.append(dominio_ok)
    print(f"  [{'OK ' if dominio_ok else 'ROSSO'}] supertrend dominio in (-1,0,1)")

    print("\nScostamento delle primitive usate oggi in backtest.py (non e' un errore del")
    print("banco: e' la misura di quanto il porting attuale non e' Pine)\n")
    lungo = serie_di_prova(1500, seed=11)
    cl = lungo["Close"]
    pine_atr = ta.atr(lungo["High"], lungo["Low"], cl, 14)
    pandas_atr = ta.true_range(lungo["High"], lungo["Low"], cl).rolling(14).mean()
    scarto_atr = ((pandas_atr - pine_atr).abs() / pine_atr * 100).dropna()
    d = cl.diff()
    pandas_rsi = 100 - 100 / (
        1 + d.where(d > 0, 0).rolling(14).mean() / (-d.where(d < 0, 0)).rolling(14).mean()
    )
    scarto_rsi = (pandas_rsi - ta.rsi(cl, 14)).abs().dropna()
    print(f"  ATR(14)  rolling.mean vs rma  : scarto medio {scarto_atr.mean():.2f}%  max {scarto_atr.max():.2f}%")
    print(f"  RSI(14)  rolling.mean vs rma  : scarto medio {scarto_rsi.mean():.2f} punti  max {scarto_rsi.max():.2f}")
    print("    (la strategia confronta rsi<35 e rsi>65: un errore di questa taglia cambia il segnale)")

    for periodo in (28, 200):
        pine_t = ta.tema(cl, periodo)
        e1 = cl.ewm(span=periodo, adjust=False).mean()
        e2 = e1.ewm(span=periodo, adjust=False).mean()
        pandas_t = 3 * e1 - 3 * e2 + e2.ewm(span=periodo, adjust=False).mean()
        scarto = (pandas_t - pine_t).abs().dropna()
        primo = int(pine_t.notna().argmax()) if pine_t.notna().any() else -1
        print(f"  TEMA({periodo}) ewm vs ema innescata: scarto medio {scarto.mean():.1f} punti prezzo  max {scarto.max():.1f}")
        print(f"    prima barra valida: Pine {primo}, pandas 0 — {primo} barre in cui il filtro Pine e' na e quello Python no")

    rossi = ESITI.count(False)
    print(f"\nbanco primitive: {len(ESITI) - rossi}/{len(ESITI)} verdi")
    return 1 if rossi else 0


if __name__ == "__main__":
    sys.exit(main())
