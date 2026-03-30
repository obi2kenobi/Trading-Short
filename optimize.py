"""
Optimizer TEMA-ST-WT PANIC HUNTER v3.5
Grid search sui parametri principali usando NQ Futures 4H
"""

import yfinance as yf
import pandas as pd
import numpy as np
from itertools import product
import warnings
warnings.filterwarnings('ignore')


def tema(series, period):
    ema1 = series.ewm(span=period, adjust=False).mean()
    ema2 = ema1.ewm(span=period, adjust=False).mean()
    ema3 = ema2.ewm(span=period, adjust=False).mean()
    return 3 * ema1 - 3 * ema2 + ema3


def calc_atr(df, period):
    tr = pd.concat([
        df['High'] - df['Low'],
        (df['High'] - df['Close'].shift(1)).abs(),
        (df['Low'] - df['Close'].shift(1)).abs()
    ], axis=1).max(axis=1)
    return tr.rolling(period).mean()


def supertrend(close, high, low, factor, atr):
    hl2 = (high + low) / 2
    up = hl2 - factor * atr
    dn = hl2 + factor * atr

    n = len(close)
    trend = np.zeros(n)
    final_up = up.values.copy()
    final_dn = dn.values.copy()
    close_v = close.values

    for i in range(1, n):
        if close_v[i - 1] > final_up[i - 1]:
            final_up[i] = max(up.values[i], final_up[i - 1])
        else:
            final_up[i] = up.values[i]

        if close_v[i - 1] < final_dn[i - 1]:
            final_dn[i] = min(dn.values[i], final_dn[i - 1])
        else:
            final_dn[i] = dn.values[i]

        if close_v[i] > final_dn[i - 1]:
            trend[i] = 1
        elif close_v[i] < final_up[i - 1]:
            trend[i] = -1
        else:
            trend[i] = trend[i - 1]

    return trend


def wave_trend(hlc3, n1=10, n2=21):
    esa = hlc3.ewm(span=n1, adjust=False).mean()
    d = (hlc3 - esa).abs().ewm(span=n1, adjust=False).mean()
    ci = (hlc3 - esa) / (0.015 * d)
    wt1 = ci.ewm(span=n2, adjust=False).mean()
    wt2 = wt1.rolling(4).mean()
    return wt1.values, wt2.values


def calc_rsi(close, period=14):
    delta = close.diff()
    gain = delta.where(delta > 0, 0).rolling(period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(period).mean()
    rs = gain / loss
    return (100 - (100 / (1 + rs))).values


def precompute(df, st_factor=2.4, tema_period=28):
    """Precompute indicators that depend on specific parameters"""
    atr14 = calc_atr(df, 14).values
    atr10 = calc_atr(df, 10).values

    tema200 = tema(df['Close'], 200).values
    ema50 = df['Close'].ewm(span=50, adjust=False).mean().values
    close_v = df['Close'].values

    is_bear = close_v < tema200
    is_strong_bear = is_bear & (ema50 < tema200)

    tema_in = tema(df['Close'], tema_period).values
    tema_slope = np.zeros(len(df))
    tema_slope[1:] = tema_in[1:] - tema_in[:-1]
    tema_slope_ma = pd.Series(tema_slope).rolling(3).mean().values

    trend = supertrend(df['Close'], df['High'], df['Low'], st_factor, pd.Series(atr10, index=df.index))

    hlc3 = (df['High'] + df['Low'] + df['Close']) / 3
    wt1, wt2 = wave_trend(hlc3, n1=10, n2=21)
    wt_down = wt1 < wt2

    rsi = calc_rsi(df['Close'], 14)

    vol_ma20 = df['Volume'].rolling(20).mean().values
    volume = df['Volume'].values

    candle_body = np.abs(close_v - df['Open'].values)
    candle_range = df['High'].values - df['Low'].values
    is_bearish = close_v < df['Open'].values

    price_change1 = np.zeros(len(df))
    price_change3 = np.zeros(len(df))
    price_change1[1:] = (close_v[1:] - close_v[:-1]) / close_v[:-1] * 100
    price_change3[3:] = (close_v[3:] - close_v[:-3]) / close_v[:-3] * 100

    is_rsi_crashing = (rsi < np.roll(rsi, 1) - 5) & (rsi < 50)

    red_bar = close_v < df['Open'].values
    consec_red = red_bar & np.roll(red_bar, 1) & np.roll(red_bar, 2)

    vol_sma50 = df['Volume'].rolling(50).mean().values
    vol_sma200 = df['Volume'].rolling(200).mean().values
    with np.errstate(divide='ignore', invalid='ignore'):
        vol_density = np.where(vol_sma200 > 0, vol_sma50 / vol_sma200, 1.0)
    is_vol_void = vol_density < 0.7

    regime_mult = np.ones(len(df))
    regime_mult[is_bear] = 1.2
    regime_mult[is_strong_bear] = 1.4
    regime_mult[is_strong_bear & is_vol_void] = 1.8

    return {
        'atr14': atr14, 'atr10': atr10,
        'is_bear': is_bear, 'is_strong_bear': is_strong_bear,
        'trend': trend, 'wt_down': wt_down, 'rsi': rsi,
        'vol_ma20': vol_ma20, 'volume': volume,
        'candle_body': candle_body, 'candle_range': candle_range,
        'is_bearish': is_bearish,
        'price_change1': price_change1, 'price_change3': price_change3,
        'is_rsi_crashing': is_rsi_crashing,
        'consec_red': consec_red,
        'regime_mult': regime_mult,
        'high': df['High'].values, 'low': df['Low'].values,
        'close': close_v, 'open': df['Open'].values,
    }


def run_backtest(data, tp_atr_mult, sl_pct, trail_atr_mult,
                 vol_spike_mult, panic_threshold_normal, rsi_panic_level):
    """Fast backtest with numpy arrays"""
    n = len(data['close'])
    close = data['close']
    high = data['high']
    low = data['low']
    atr14 = data['atr14']
    is_bear = data['is_bear']
    is_strong_bear = data['is_strong_bear']
    trend = data['trend']
    wt_down = data['wt_down']
    rsi = data['rsi']
    volume = data['volume']
    vol_ma20 = data['vol_ma20']
    regime_mult = data['regime_mult']

    # Vol spike
    is_vol_spike = volume > vol_ma20 * vol_spike_mult

    # Panic bar
    is_panic_bar = data['is_bearish'] & (data['candle_body'] > atr14 * 1.5) & (data['candle_body'] > data['candle_range'] * 0.7)

    # RSI panic
    is_rsi_panic = rsi < rsi_panic_level

    # Price acceleration
    is_price_accel = (data['price_change1'] < -0.5) & (data['price_change3'] < -1.5)

    # Panic score
    panic_score = (
        is_vol_spike.astype(np.int32) * 20 +
        is_panic_bar.astype(np.int32) * 25 +
        is_rsi_panic.astype(np.int32) * 15 +
        data['is_rsi_crashing'].astype(np.int32) * 10 +
        is_price_accel.astype(np.int32) * 15 +
        data['consec_red'].astype(np.int32) * 5
    )

    # Adaptive threshold
    panic_threshold = np.where(is_strong_bear, max(panic_threshold_normal - 15, 15), panic_threshold_normal)
    is_panic_mode = panic_score >= panic_threshold

    # Entry signal
    entry = (is_panic_mode & is_bear & (trend == -1) &
             (wt_down | is_rsi_panic) & is_vol_spike)

    # Backtest loop
    trades_pnl = []
    trades_reason = []
    in_pos = False
    entry_price = 0.0
    stop_price = 0.0
    tp_price = 0.0
    lowest = 0.0

    start = 200
    for i in range(start, n):
        if not in_pos:
            if entry[i]:
                in_pos = True
                entry_price = close[i]
                lowest = low[i]

                # Stop
                if is_strong_bear[i]:
                    recent_high = np.max(high[max(0, i - 3):i + 1])
                    stop_price = recent_high + atr14[i] * 0.5
                else:
                    stop_price = entry_price * (1 + sl_pct)

                # TP
                tp_dist = atr14[i] * tp_atr_mult * regime_mult[i]
                tp_price = entry_price - tp_dist
        else:
            lowest = min(lowest, low[i])

            # Trailing
            trail_mult = 1.8 if is_strong_bear[i] else (1.3 if is_bear[i] else 1.0)
            new_trail = lowest + atr14[i] * trail_atr_mult * trail_mult
            if new_trail < stop_price:
                stop_price = new_trail

            # TP hit
            if low[i] <= tp_price:
                pnl = (entry_price - tp_price) / entry_price * 100
                trades_pnl.append(pnl)
                trades_reason.append('TP')
                in_pos = False
                continue

            # SL hit
            if high[i] >= stop_price:
                pnl = (entry_price - stop_price) / entry_price * 100
                trades_pnl.append(pnl)
                trades_reason.append('SL')
                in_pos = False
                continue

            # Emergency
            if rsi[i] > 65:
                pnl = (entry_price - close[i]) / entry_price * 100
                trades_pnl.append(pnl)
                trades_reason.append('EM')
                in_pos = False

    if not trades_pnl:
        return None

    pnl_arr = np.array(trades_pnl)
    wins = pnl_arr[pnl_arr > 0]
    losses = pnl_arr[pnl_arr <= 0]
    reasons = np.array(trades_reason)

    total_pnl = pnl_arr.sum()
    win_rate = len(wins) / len(pnl_arr) * 100 if len(pnl_arr) > 0 else 0
    pf = abs(wins.sum() / losses.sum()) if len(losses) > 0 and losses.sum() != 0 else 99.0
    avg_win = wins.mean() if len(wins) > 0 else 0
    avg_loss = losses.mean() if len(losses) > 0 else 0

    return {
        'trades': len(pnl_arr),
        'win_rate': win_rate,
        'total_pnl': total_pnl,
        'avg_pnl': pnl_arr.mean(),
        'avg_win': avg_win,
        'avg_loss': avg_loss,
        'profit_factor': pf,
        'max_win': pnl_arr.max(),
        'max_loss': pnl_arr.min(),
        'tp_count': int((reasons == 'TP').sum()),
        'sl_count': int((reasons == 'SL').sum()),
        'em_count': int((reasons == 'EM').sum()),
    }


def resample_to_4h(df):
    return df.resample('4h').agg({
        'Open': 'first', 'High': 'max', 'Low': 'min',
        'Close': 'last', 'Volume': 'sum'
    }).dropna()


# === MAIN ===
print("=" * 70)
print("  OPTIMIZER — PANIC HUNTER v3.5")
print("=" * 70)

print("\nScarico dati NQ=F (Nasdaq Futures) — 1h, 2 anni...")
nq = yf.download("NQ=F", period="2y", interval="1h", progress=False)
if isinstance(nq.columns, pd.MultiIndex):
    nq.columns = nq.columns.get_level_values(0)

df = resample_to_4h(nq)
print(f"  Barre 4H: {len(df)}")
print(f"  Range: {df.index[0].strftime('%Y-%m-%d')} — {df.index[-1].strftime('%Y-%m-%d')}")

# Precompute indicators (ST factor e TEMA period fissi per ora)
print("\nPrecomputo indicatori...")
for st_factor, tema_period in [(2.4, 28)]:
    data = precompute(df, st_factor=st_factor, tema_period=tema_period)

# Grid search
print("\nGrid search in corso...\n")

param_grid = {
    'tp_atr_mult':     [0.8, 1.0, 1.2, 1.5, 1.8, 2.0, 2.5, 3.0],
    'sl_pct':           [0.01, 0.015, 0.02, 0.025, 0.03],
    'trail_atr_mult':  [1.0, 1.5, 2.0, 2.5],
    'vol_spike_mult':  [1.5, 2.0, 2.5],
    'panic_threshold': [30, 35, 40, 45],
    'rsi_panic_level': [30, 35, 40],
}

keys = list(param_grid.keys())
values = list(param_grid.values())
combos = list(product(*values))
print(f"  Combinazioni totali: {len(combos)}")

results = []
for idx, combo in enumerate(combos):
    params = dict(zip(keys, combo))

    r = run_backtest(
        data,
        tp_atr_mult=params['tp_atr_mult'],
        sl_pct=params['sl_pct'],
        trail_atr_mult=params['trail_atr_mult'],
        vol_spike_mult=params['vol_spike_mult'],
        panic_threshold_normal=params['panic_threshold'],
        rsi_panic_level=params['rsi_panic_level'],
    )

    if r and r['trades'] >= 10:  # minimo 10 trade per significatività
        r.update(params)
        results.append(r)

    if (idx + 1) % 500 == 0:
        print(f"  {idx + 1}/{len(combos)} testate...")

print(f"\n  Completate. Configurazioni valide (≥10 trade): {len(results)}")

if not results:
    print("  Nessun risultato valido trovato.")
    exit()

results_df = pd.DataFrame(results)

# === TOP BY PROFIT FACTOR (min 15 trade) ===
print("\n" + "=" * 70)
print("  TOP 15 — PROFIT FACTOR (min 15 trade)")
print("=" * 70)

filtered = results_df[results_df['trades'] >= 15].sort_values('profit_factor', ascending=False).head(15)
for _, row in filtered.iterrows():
    print(f"  PF {row['profit_factor']:.2f} | WR {row['win_rate']:.0f}% | "
          f"P&L {row['total_pnl']:+.1f}% | {int(row['trades'])}t | "
          f"TP={row['tp_atr_mult']}x SL={row['sl_pct']*100:.1f}% "
          f"Trail={row['trail_atr_mult']}x Vol={row['vol_spike_mult']}x "
          f"Panic={int(row['panic_threshold'])} RSI={int(row['rsi_panic_level'])}")

# === TOP BY TOTAL P&L ===
print("\n" + "=" * 70)
print("  TOP 15 — P&L TOTALE (min 15 trade)")
print("=" * 70)

filtered = results_df[results_df['trades'] >= 15].sort_values('total_pnl', ascending=False).head(15)
for _, row in filtered.iterrows():
    print(f"  P&L {row['total_pnl']:+.1f}% | PF {row['profit_factor']:.2f} | "
          f"WR {row['win_rate']:.0f}% | {int(row['trades'])}t | "
          f"TP={row['tp_atr_mult']}x SL={row['sl_pct']*100:.1f}% "
          f"Trail={row['trail_atr_mult']}x Vol={row['vol_spike_mult']}x "
          f"Panic={int(row['panic_threshold'])} RSI={int(row['rsi_panic_level'])}")

# === TOP BY WIN RATE (con PF > 1.0) ===
print("\n" + "=" * 70)
print("  TOP 15 — WIN RATE (PF > 1.0, min 15 trade)")
print("=" * 70)

filtered = results_df[(results_df['trades'] >= 15) & (results_df['profit_factor'] > 1.0)].sort_values('win_rate', ascending=False).head(15)
for _, row in filtered.iterrows():
    print(f"  WR {row['win_rate']:.0f}% | PF {row['profit_factor']:.2f} | "
          f"P&L {row['total_pnl']:+.1f}% | {int(row['trades'])}t | "
          f"TP={row['tp_atr_mult']}x SL={row['sl_pct']*100:.1f}% "
          f"Trail={row['trail_atr_mult']}x Vol={row['vol_spike_mult']}x "
          f"Panic={int(row['panic_threshold'])} RSI={int(row['rsi_panic_level'])}")

# === BEST OVERALL (score: PF * sqrt(trades) * total_pnl_sign) ===
print("\n" + "=" * 70)
print("  TOP 15 — SCORE BILANCIATO (PF × sqrt(trade) × P&L>0)")
print("  Bilancia profittabilità, robustezza e numero trade")
print("=" * 70)

f = results_df[results_df['trades'] >= 15].copy()
f['score'] = f['profit_factor'] * np.sqrt(f['trades']) * np.where(f['total_pnl'] > 0, 1, 0.3)
filtered = f.sort_values('score', ascending=False).head(15)
for _, row in filtered.iterrows():
    print(f"  Score {row['score']:.1f} | PF {row['profit_factor']:.2f} | "
          f"WR {row['win_rate']:.0f}% | P&L {row['total_pnl']:+.1f}% | {int(row['trades'])}t | "
          f"TP={row['tp_atr_mult']}x SL={row['sl_pct']*100:.1f}% "
          f"Trail={row['trail_atr_mult']}x Vol={row['vol_spike_mult']}x "
          f"Panic={int(row['panic_threshold'])} RSI={int(row['rsi_panic_level'])}")

# === DETTAGLIO MIGLIORE ===
print("\n" + "=" * 70)
print("  DETTAGLIO — CONFIGURAZIONE MIGLIORE (Score)")
print("=" * 70)
best = filtered.iloc[0]
print(f"""
  TP ATR Multiplier:     {best['tp_atr_mult']}x
  Stop Loss:             {best['sl_pct']*100:.1f}%
  Trail ATR Multiplier:  {best['trail_atr_mult']}x
  Volume Spike Mult:     {best['vol_spike_mult']}x
  Panic Threshold:       {int(best['panic_threshold'])}
  RSI Panic Level:       {int(best['rsi_panic_level'])}

  Trade:                 {int(best['trades'])}
  Win Rate:              {best['win_rate']:.1f}%
  P&L Totale:            {best['total_pnl']:+.2f}%
  P&L Medio per trade:   {best['avg_pnl']:+.2f}%
  Avg Win:               {best['avg_win']:+.2f}%
  Avg Loss:              {best['avg_loss']:+.2f}%
  Profit Factor:         {best['profit_factor']:.2f}
  Max Win:               {best['max_win']:+.2f}%
  Max Loss:              {best['max_loss']:+.2f}%
  Exit TP:               {int(best['tp_count'])}
  Exit SL:               {int(best['sl_count'])}
  Exit Emergency:        {int(best['em_count'])}
""")
