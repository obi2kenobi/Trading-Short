"""
Backtest TEMA-ST-WT PANIC HUNTER v3.5 — core logic in Python
Uses QQQ 4H data as proxy for NAS100
"""

import yfinance as yf
import pandas as pd
import numpy as np
from datetime import datetime, timedelta


def tema(series, period):
    ema1 = series.ewm(span=period, adjust=False).mean()
    ema2 = ema1.ewm(span=period, adjust=False).mean()
    ema3 = ema2.ewm(span=period, adjust=False).mean()
    return 3 * ema1 - 3 * ema2 + ema3


def supertrend(df, factor, atr_period=10):
    atr = df['High'].rolling(atr_period).max() - df['Low'].rolling(atr_period).min()
    # Simple ATR approximation
    tr = pd.concat([
        df['High'] - df['Low'],
        (df['High'] - df['Close'].shift(1)).abs(),
        (df['Low'] - df['Close'].shift(1)).abs()
    ], axis=1).max(axis=1)
    atr = tr.rolling(atr_period).mean()

    hl2 = (df['High'] + df['Low']) / 2
    up = hl2 - factor * atr
    dn = hl2 + factor * atr

    trend = pd.Series(0, index=df.index)
    final_up = up.copy()
    final_dn = dn.copy()

    for i in range(1, len(df)):
        if df['Close'].iloc[i - 1] > final_up.iloc[i - 1]:
            final_up.iloc[i] = max(up.iloc[i], final_up.iloc[i - 1])
        else:
            final_up.iloc[i] = up.iloc[i]

        if df['Close'].iloc[i - 1] < final_dn.iloc[i - 1]:
            final_dn.iloc[i] = min(dn.iloc[i], final_dn.iloc[i - 1])
        else:
            final_dn.iloc[i] = dn.iloc[i]

        if df['Close'].iloc[i] > final_dn.iloc[i - 1]:
            trend.iloc[i] = 1
        elif df['Close'].iloc[i] < final_up.iloc[i - 1]:
            trend.iloc[i] = -1
        else:
            trend.iloc[i] = trend.iloc[i - 1]

    return trend


def wave_trend(hlc3, n1=10, n2=21):
    esa = hlc3.ewm(span=n1, adjust=False).mean()
    d = (hlc3 - esa).abs().ewm(span=n1, adjust=False).mean()
    ci = (hlc3 - esa) / (0.015 * d)
    wt1 = ci.ewm(span=n2, adjust=False).mean()
    wt2 = wt1.rolling(4).mean()
    return wt1, wt2


def resample_to_4h(df):
    """Resample 1h data to 4h OHLCV"""
    ohlc = df.resample('4h').agg({
        'Open': 'first',
        'High': 'max',
        'Low': 'min',
        'Close': 'last',
        'Volume': 'sum'
    }).dropna()
    return ohlc


def run_backtest(df, tp_atr_mult=1.5, sl_pct=0.02, trail_atr_mult=1.5):
    """Run the core strategy backtest"""

    # ATR
    tr = pd.concat([
        df['High'] - df['Low'],
        (df['High'] - df['Close'].shift(1)).abs(),
        (df['Low'] - df['Close'].shift(1)).abs()
    ], axis=1).max(axis=1)
    atr14 = tr.rolling(14).mean()
    atr10 = tr.rolling(10).mean()

    # TEMA 200 (daily proxy — use longer period on 4H: 200 * 6 = 1200 bars? too much)
    # Simplified: use 200-bar TEMA on 4H as bear market filter
    tema200 = tema(df['Close'], 200)
    ema50 = df['Close'].ewm(span=50, adjust=False).mean()
    is_bear = df['Close'] < tema200
    is_strong_bear = is_bear & (ema50 < tema200)

    # TEMA IN (28)
    tema_in = tema(df['Close'], 28)
    tema_slope = tema_in - tema_in.shift(1)
    tema_slope_ma = tema_slope.rolling(3).mean()
    is_tema_falling = (tema_slope < 0) & (tema_slope_ma < 0)

    # Supertrend IN
    trend_in = supertrend(df, factor=2.4, atr_period=10)

    # Wave Trend
    hlc3 = (df['High'] + df['Low'] + df['Close']) / 3
    wt1_in, wt2_in = wave_trend(hlc3, n1=10, n2=21)
    wt_down = wt1_in < wt2_in

    # RSI
    delta = df['Close'].diff()
    gain = delta.where(delta > 0, 0).rolling(14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(14).mean()
    rs = gain / loss
    rsi = 100 - (100 / (1 + rs))

    # Volume
    vol_ma20 = df['Volume'].rolling(20).mean()
    is_vol_spike = df['Volume'] > vol_ma20 * 2.0

    # Panic detection
    candle_body = (df['Close'] - df['Open']).abs()
    candle_range = df['High'] - df['Low']
    is_bearish = df['Close'] < df['Open']
    is_panic_bar = is_bearish & (candle_body > atr14 * 1.5) & (candle_body > candle_range * 0.7)

    is_rsi_panic = rsi < 35
    is_rsi_crashing = (rsi < rsi.shift(1) - 5) & (rsi < 50)

    price_change1 = (df['Close'] - df['Close'].shift(1)) / df['Close'].shift(1) * 100
    price_change3 = (df['Close'] - df['Close'].shift(3)) / df['Close'].shift(3) * 100
    is_price_accel = (price_change1 < -0.5) & (price_change3 < -1.5)

    red_bar = df['Close'] < df['Open']
    consec_red = red_bar & red_bar.shift(1) & red_bar.shift(2)

    # Panic score
    panic_score = (
        is_vol_spike.astype(int) * 20 +
        is_panic_bar.astype(int) * 25 +
        is_rsi_panic.astype(int) * 15 +
        is_rsi_crashing.astype(int) * 10 +
        is_price_accel.astype(int) * 15 +
        consec_red.astype(int) * 5
    )

    # Adaptive threshold
    panic_threshold = pd.Series(40, index=df.index)
    panic_threshold[is_strong_bear] = 25
    is_panic_mode = panic_score >= panic_threshold

    # ENTRY: isPanicMode AND isBearMarket AND trend_in == -1 AND (wtDown OR isRsiPanic) AND isVolSpike
    entry_signal = (
        is_panic_mode &
        is_bear &
        (trend_in == -1) &
        (wt_down | is_rsi_panic) &
        is_vol_spike
    )

    # Regime mult for TP
    vol_sma50 = df['Volume'].rolling(50).mean()
    vol_sma200 = df['Volume'].rolling(200).mean()
    vol_density = vol_sma50 / vol_sma200
    is_vol_void = vol_density < 0.7

    regime_mult = pd.Series(1.0, index=df.index)
    regime_mult[is_bear] = 1.2
    regime_mult[is_strong_bear] = 1.4
    regime_mult[is_strong_bear & is_vol_void] = 1.8

    # --- BACKTEST ---
    trades = []
    in_position = False
    entry_price = 0
    entry_atr = 0
    entry_regime = 1.0
    stop_price = 0
    lowest_since_entry = 0
    trail_atr = trail_atr_mult

    for i in range(200, len(df)):
        if not in_position:
            if entry_signal.iloc[i]:
                in_position = True
                entry_price = df['Close'].iloc[i]
                entry_atr = atr14.iloc[i]
                entry_regime = regime_mult.iloc[i]
                lowest_since_entry = df['Low'].iloc[i]

                # Stop: structural in strong bear, else % fixed
                if is_strong_bear.iloc[i]:
                    recent_high = df['High'].iloc[max(0, i - 3):i + 1].max()
                    stop_price = recent_high + atr14.iloc[i] * 0.5
                else:
                    stop_price = entry_price * (1 + sl_pct)

                # TP level
                tp_price = entry_price * (1 - (entry_atr * tp_atr_mult * entry_regime) / entry_price)

                trades.append({
                    'entry_bar': i,
                    'entry_date': df.index[i],
                    'entry_price': entry_price,
                    'tp_price': tp_price,
                    'initial_stop': stop_price,
                    'regime_mult': entry_regime,
                })
        else:
            # Update trailing
            lowest_since_entry = min(lowest_since_entry, df['Low'].iloc[i])

            # Trail regime multiplier
            if is_strong_bear.iloc[i]:
                tr_mult = 1.8
            elif is_bear.iloc[i]:
                tr_mult = 1.3
            else:
                tr_mult = 1.0

            new_trail = lowest_since_entry + atr14.iloc[i] * trail_atr * tr_mult
            if new_trail < stop_price:
                stop_price = new_trail

            # Check TP hit (intrabar: low reached TP)
            if df['Low'].iloc[i] <= tp_price:
                exit_price = tp_price  # limit order fills at exact price
                pnl_pct = (entry_price - exit_price) / entry_price * 100
                trades[-1]['exit_date'] = df.index[i]
                trades[-1]['exit_price'] = exit_price
                trades[-1]['exit_reason'] = 'TP'
                trades[-1]['pnl_pct'] = pnl_pct
                in_position = False
                continue

            # Check SL hit (intrabar: high reached stop)
            if df['High'].iloc[i] >= stop_price:
                exit_price = stop_price
                pnl_pct = (entry_price - exit_price) / entry_price * 100
                trades[-1]['exit_date'] = df.index[i]
                trades[-1]['exit_price'] = exit_price
                trades[-1]['exit_reason'] = 'SL'
                trades[-1]['pnl_pct'] = pnl_pct
                in_position = False
                continue

            # Emergency exit: RSI > 65
            if rsi.iloc[i] > 65:
                exit_price = df['Close'].iloc[i]
                pnl_pct = (entry_price - exit_price) / entry_price * 100
                trades[-1]['exit_date'] = df.index[i]
                trades[-1]['exit_price'] = exit_price
                trades[-1]['exit_reason'] = 'EMERGENCY'
                trades[-1]['pnl_pct'] = pnl_pct
                in_position = False
                continue

    # Close open position at end
    if in_position and trades:
        exit_price = df['Close'].iloc[-1]
        pnl_pct = (entry_price - exit_price) / entry_price * 100
        trades[-1]['exit_date'] = df.index[-1]
        trades[-1]['exit_price'] = exit_price
        trades[-1]['exit_reason'] = 'OPEN'
        trades[-1]['pnl_pct'] = pnl_pct

    return pd.DataFrame(trades)


def print_results(trades_df, label=""):
    if trades_df.empty:
        print(f"\n{'=' * 60}")
        print(f"  {label}")
        print(f"{'=' * 60}")
        print("  Nessun trade trovato.")
        return

    completed = trades_df[trades_df['exit_reason'] != 'OPEN']
    if completed.empty:
        print(f"\n  {label} — Nessun trade completato.")
        return

    wins = completed[completed['pnl_pct'] > 0]
    losses = completed[completed['pnl_pct'] <= 0]

    tp_trades = completed[completed['exit_reason'] == 'TP']
    sl_trades = completed[completed['exit_reason'] == 'SL']
    em_trades = completed[completed['exit_reason'] == 'EMERGENCY']

    total_pnl = completed['pnl_pct'].sum()
    avg_pnl = completed['pnl_pct'].mean()
    win_rate = len(wins) / len(completed) * 100

    avg_win = wins['pnl_pct'].mean() if len(wins) > 0 else 0
    avg_loss = losses['pnl_pct'].mean() if len(losses) > 0 else 0

    print(f"\n{'=' * 60}")
    print(f"  {label}")
    print(f"{'=' * 60}")
    print(f"  Trade totali:     {len(completed)}")
    print(f"  Win / Loss:       {len(wins)} / {len(losses)}")
    print(f"  Win Rate:         {win_rate:.1f}%")
    print(f"  P&L Totale:       {total_pnl:.2f}%")
    print(f"  P&L Medio:        {avg_pnl:.2f}%")
    print(f"  Avg Win:          {avg_win:.2f}%")
    print(f"  Avg Loss:         {avg_loss:.2f}%")
    print(f"  Profit Factor:    {abs(wins['pnl_pct'].sum() / losses['pnl_pct'].sum()):.2f}" if len(losses) > 0 and losses['pnl_pct'].sum() != 0 else "  Profit Factor:    ∞")
    print(f"  ---")
    print(f"  Exit TP:          {len(tp_trades)} ({len(tp_trades)/len(completed)*100:.0f}%)")
    print(f"  Exit SL:          {len(sl_trades)} ({len(sl_trades)/len(completed)*100:.0f}%)")
    print(f"  Exit Emergency:   {len(em_trades)} ({len(em_trades)/len(completed)*100:.0f}%)")
    print(f"  ---")
    print(f"  Max Win:          {completed['pnl_pct'].max():.2f}%")
    print(f"  Max Loss:         {completed['pnl_pct'].min():.2f}%")


# === MAIN ===
print("Scarico dati QQQ (proxy NAS100) — 1h, max disponibile...")
qqq = yf.download("QQQ", period="2y", interval="1h", progress=False)
# Flatten MultiIndex columns
if isinstance(qqq.columns, pd.MultiIndex):
    qqq.columns = qqq.columns.get_level_values(0)
print(f"  Righe 1h: {len(qqq)}")

# Resample to 4H
df_4h = resample_to_4h(qqq)
print(f"  Righe 4h: {len(df_4h)}")
print(f"  Range: {df_4h.index[0]} — {df_4h.index[-1]}")

# Test con diversi TP multiplier
for tp_mult in [1.0, 1.5, 2.0, 2.5, 3.0]:
    trades = run_backtest(df_4h, tp_atr_mult=tp_mult, sl_pct=0.02, trail_atr_mult=1.5)
    print_results(trades, f"TP ATR Mult = {tp_mult}x")

# Anche NQ futures se disponibile
print("\n\nScarico dati NQ=F (Nasdaq futures) — 1h...")
try:
    nq = yf.download("NQ=F", period="2y", interval="1h", progress=False)
    if isinstance(nq.columns, pd.MultiIndex):
        nq.columns = nq.columns.get_level_values(0)
    if len(nq) > 100:
        df_nq_4h = resample_to_4h(nq)
        print(f"  Righe 4h: {len(df_nq_4h)}")
        print(f"  Range: {df_nq_4h.index[0]} — {df_nq_4h.index[-1]}")

        for tp_mult in [1.0, 1.5, 2.0, 2.5, 3.0]:
            trades = run_backtest(df_nq_4h, tp_atr_mult=tp_mult, sl_pct=0.02, trail_atr_mult=1.5)
            print_results(trades, f"NQ Futures — TP ATR Mult = {tp_mult}x")
    else:
        print("  Dati insufficienti per NQ futures")
except Exception as e:
    print(f"  NQ futures non disponibile: {e}")
