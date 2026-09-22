"""Quanto diverge il porting di backtest.py dal Pine, a parita' di barre.

Non serve l'export di TradingView: entrambe le logiche girano sulle STESSE barre
sintetiche, quindi ogni differenza e' imputabile al codice e a nient'altro. E' la
misura del difetto D2 del report, fatta invece che stimata.

Uso: python3 parity/diagnosi_porting.py
"""

import sys

import numpy as np
import pandas as pd

sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parent))

import pine_entry as pe
import pine_ta
from selftest_banco import mercato_in_discesa


def entrata_backtest_py(df: pd.DataFrame) -> pd.DataFrame:
    """La condizione di entrata come e' scritta oggi in backtest.py:86-160.

    Trascrizione fedele, difetti inclusi: ATR e RSI come medie semplici, soglia
    40/25, niente gap ne' bonus breakout, TEMA200 su barre operative con ewm.
    """
    o, h, l, c, v = (df[k] for k in ("Open", "High", "Low", "Close", "Volume"))
    tr = pd.concat([h - l, (h - c.shift(1)).abs(), (l - c.shift(1)).abs()], axis=1).max(axis=1)
    atr14 = tr.rolling(14).mean()

    e1 = c.ewm(span=200, adjust=False).mean()
    e2 = e1.ewm(span=200, adjust=False).mean()
    tema200 = 3 * e1 - 3 * e2 + e2.ewm(span=200, adjust=False).mean()
    ema50 = c.ewm(span=50, adjust=False).mean()
    is_bear = c < tema200
    is_strong_bear = is_bear & (ema50 < tema200)

    d = c.diff()
    rs = d.where(d > 0, 0).rolling(14).mean() / (-d.where(d < 0, 0)).rolling(14).mean()
    rsi = 100 - 100 / (1 + rs)

    esa = ((h + l + c) / 3).ewm(span=10, adjust=False).mean()
    dev = (((h + l + c) / 3) - esa).abs().ewm(span=10, adjust=False).mean()
    wt1 = ((((h + l + c) / 3) - esa) / (0.015 * dev)).ewm(span=21, adjust=False).mean()

    spike = v > v.rolling(20).mean() * 2.0
    corpo, rng_ = (c - o).abs(), h - l
    panic_bar = (c < o) & (corpo > atr14 * 1.5) & (corpo > rng_ * 0.7)
    rsi_panic = rsi < 35
    crashing = (rsi < rsi.shift(1) - 5) & (rsi < 50)
    accel = ((c - c.shift(1)) / c.shift(1) * 100 < -0.5) & (
        (c - c.shift(3)) / c.shift(3) * 100 < -1.5
    )
    rosse = (c < o) & (c.shift(1) < o.shift(1)) & (c.shift(2) < o.shift(2))
    score = (
        spike.astype(int) * 20 + panic_bar.astype(int) * 25 + rsi_panic.astype(int) * 15
        + crashing.astype(int) * 10 + accel.astype(int) * 15 + rosse.astype(int) * 5
    )
    soglia = np.where(is_strong_bear, 25, 40)

    trend = pine_ta.supertrend_trend(h, l, c, 2.4, tr.rolling(10).mean())
    out = pd.DataFrame(index=df.index)
    out["short_ok"] = (
        (score >= soglia) & is_bear & (trend == -1)
        & ((wt1 < wt1.rolling(4).mean()) | rsi_panic) & spike
    )
    out["panic_score"] = score
    return out


def main() -> int:
    op, day = mercato_in_discesa()
    pine = pe.short_ok(op, day)
    py = entrata_backtest_py(op)
    valide = pine["htf_pronto"]

    a, b = pine["short_ok"] & valide, py["short_ok"] & valide
    solo_pine, solo_py, insieme = (a & ~b).sum(), (b & ~a).sum(), (a & b).sum()

    print("Divergenza del porting attuale, stesse barre su entrambi i lati")
    print(f"  barre confrontabili (filtro bear pronto): {int(valide.sum())}\n")
    print(f"  segnali del Pine (porting fedele)     {int(a.sum())}")
    print(f"  segnali di backtest.py                {int(b.sum())}")
    print(f"  coincidenti                           {int(insieme)}")
    print(f"  solo Pine (backtest.py li perde)      {int(solo_pine)}")
    print(f"  solo backtest.py (fantasma)           {int(solo_py)}")
    tot = int(a.sum()) or 1
    print(f"\n  accordo sulle entrate: {insieme / tot * 100:.0f}% dei segnali del Pine")

    print("\n  Scomposizione della causa, sulle barre in bear market:")
    bear = pine["is_bear"] & valide
    print(f"    panic score  Pine medio {pine.loc[bear, 'panic_score'].mean():.1f}"
          f"  ·  backtest.py medio {py.loc[bear, 'panic_score'].mean():.1f}")
    print(f"    soglia       Pine 35/20  ·  backtest.py 40/25")
    print(f"    bear market  Pine {int(pine.loc[valide, 'is_bear'].sum())} barre"
          f"  ·  backtest.py {int((op['Close'] < (3 * op['Close'].ewm(span=200, adjust=False).mean() - 3 * op['Close'].ewm(span=200, adjust=False).mean().ewm(span=200, adjust=False).mean() + op['Close'].ewm(span=200, adjust=False).mean().ewm(span=200, adjust=False).mean().ewm(span=200, adjust=False).mean()))[valide].sum())} barre")
    return 0


if __name__ == "__main__":
    sys.exit(main())
