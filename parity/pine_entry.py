"""Porta della CONDIZIONE DI ENTRATA di TEMA-ST-WT PANIC HUNTER, dal sorgente Pine.

Ambito: solo `shortOK` (TEMA-ST-WT_PANIC_HUNTER_v3_2.pine:403) e le sue componenti.
Le uscite, i riempimenti e il sizing NON sono qui: replicarli significa replicare il
broker emulator di TradingView, ed e' il secondo giro.

Ogni componente esce come colonna propria: quando una barra diverge, il confronto
deve poter dire QUALE addendo del panic score e' responsabile, non solo che diverge.

Impostazioni: i default del Pine. Con `Enable Panic Score Boost` = false (:82) e
`Enable Footprint Exit Warning` = false (:84) il footprint non tocca la logica di
trading, quindi l'assenza di request.footprint() qui non e' un'approssimazione.
"""

from dataclasses import dataclass

import sys

import numpy as np
import pandas as pd

sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parent))

import pine_ta as ta


@dataclass(frozen=True)
class Params:
    """Default del Pine. tf_mult vale 1.0 sul 4H (:128-130)."""

    tema_htf: int = 200
    ema_htf: int = 50
    tema_len_in: int = 28
    st_factor_in: float = 2.4
    atr_len: int = 14
    atr_st_len: int = 10
    rsi_len: int = 14
    wt_n1: int = 10
    wt_n2_in: int = 21
    vol_spike_mult: float = 2.0
    panic_bar_atr_mult: float = 1.5
    rsi_panic_level: int = 35
    panic_threshold: int = 35
    panic_threshold_strong_bear: int = 20
    usa_bonus_breakout: bool = True
    usa_soglia_ridotta: bool = True


def _filtro_htf(df: pd.DataFrame, htf: pd.DataFrame | None, p: Params):
    """isBearMarket / isStrongBear da `request.security(tickerid, "D", ...)` (:19,:107-108).

    Semantica lookahead_off: su una barra intraday e' visibile il valore dell'ultima
    barra giornaliera GIA' CHIUSA — da cui lo shift(1).
    """
    derivato = htf is None
    if derivato:
        htf = df.resample("1D").agg({"Close": "last"}).dropna()
    chiusura = htf["Close"]
    tema200 = ta.tema(chiusura, p.tema_htf).shift(1)
    ema50 = ta.ema(chiusura, p.ema_htf).shift(1)
    close_htf = chiusura.shift(1)

    def stendi(s: pd.Series) -> pd.Series:
        return s.reindex(s.index.union(df.index)).ffill().reindex(df.index)

    close_d, tema_d, ema_d = stendi(close_htf), stendi(tema200), stendi(ema50)
    is_bear = close_d < tema_d
    return is_bear, is_bear & (ema_d < tema_d), tema_d.notna(), derivato


def componenti(df: pd.DataFrame, htf: pd.DataFrame | None = None, p: Params = Params()):
    """Tutte le componenti dell'entrata, una colonna ciascuna.

    `df` vuole colonne Open/High/Low/Close/Volume e indice temporale ordinato.
    """
    o, h, l, c, v = (df[k] for k in ("Open", "High", "Low", "Close", "Volume"))
    atr14 = ta.atr(h, l, c, p.atr_len)
    atr10 = ta.atr(h, l, c, p.atr_st_len)
    is_bear, is_strong_bear, htf_pronto, derivato = _filtro_htf(df, htf, p)

    rsi = ta.rsi(c, p.rsi_len)
    corpo, escursione = (c - o).abs(), h - l
    esa = ta.ema((h + l + c) / 3.0, p.wt_n1)
    d = ta.ema(((h + l + c) / 3.0 - esa).abs(), p.wt_n1)
    wt1 = ta.ema(((h + l + c) / 3.0 - esa) / (0.015 * d), p.wt_n2_in)

    out = pd.DataFrame(index=df.index)
    out["is_vol_spike"] = v > ta.sma(v, 20) * p.vol_spike_mult
    out["is_panic_bar"] = (c < o) & (corpo > atr14 * p.panic_bar_atr_mult) & (corpo > escursione * 0.7)
    out["is_rsi_panic"] = rsi < p.rsi_panic_level
    out["is_rsi_crashing"] = (rsi < rsi.shift(1) - 5) & (rsi < 50)
    out["is_price_accel"] = ((c - c.shift(1)) / c.shift(1) * 100 < -0.5) & (
        (c - c.shift(3)) / c.shift(3) * 100 < -1.5
    )
    out["significant_gap"] = (o < l.shift(1)) & ((l.shift(1) - o) > atr14 * 0.5)
    out["consecutive_red"] = (c < o) & (c.shift(1) < o.shift(1)) & (c.shift(2) < o.shift(2))
    out["is_structural_breakout"] = (c < ta.linreg(c, 100)) & is_strong_bear
    out["trend_in"] = ta.supertrend_trend(h, l, c, p.st_factor_in, atr10)
    out["wt_down"] = wt1 < ta.sma(wt1, 4)
    out["is_bear"] = is_bear
    out["is_strong_bear"] = is_strong_bear
    out["htf_pronto"] = htf_pronto
    out["rsi"] = rsi
    out.attrs["htf_derivato"] = derivato
    return out


def panic_score(comp: pd.DataFrame, p: Params = Params()) -> pd.Series:
    """Somma pesata del Pine (:267-276). Sette addendi piu' il bonus strutturale."""
    pesi = {
        "is_vol_spike": 20,
        "is_panic_bar": 25,
        "is_rsi_panic": 15,
        "is_rsi_crashing": 10,
        "is_price_accel": 15,
        "significant_gap": 10,
        "consecutive_red": 5,
    }
    score = sum(comp[k].fillna(False).astype(int) * w for k, w in pesi.items())
    if p.usa_bonus_breakout:
        score = score + comp["is_structural_breakout"].fillna(False).astype(int) * 15
    return score


def short_ok(df: pd.DataFrame, htf: pd.DataFrame | None = None, p: Params = Params()):
    """shortOK del Pine (:403), con il punteggio e le componenti a fianco."""
    comp = componenti(df, htf, p)
    comp["panic_score"] = panic_score(comp, p)
    soglia = np.where(
        p.usa_soglia_ridotta & comp["is_strong_bear"].fillna(False),
        p.panic_threshold_strong_bear,
        p.panic_threshold,
    )
    comp["panic_threshold"] = soglia
    comp["is_panic_mode"] = comp["panic_score"] >= soglia
    comp["short_ok"] = (
        comp["is_panic_mode"]
        & comp["is_bear"].fillna(False)
        & (comp["trend_in"] == -1)
        & (comp["wt_down"].fillna(False) | comp["is_rsi_panic"].fillna(False))
        & comp["is_vol_spike"].fillna(False)
        & comp["htf_pronto"]
    )
    return comp
