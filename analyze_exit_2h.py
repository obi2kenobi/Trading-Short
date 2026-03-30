"""
Exit su 2H con entry su 4H — dati reali NQ Futures.
Doppia granularità per catturare meglio i profitti.
"""

import yfinance as yf
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')

entries = [
    ("2024-04-01 21:00", 18254.6), ("2024-04-02 17:00", 18010.3),
    ("2024-04-05 17:00", 18116.4), ("2024-04-10 21:00", 17944.3),
    ("2024-04-12 17:00", 18027.0), ("2024-04-15 21:00", 17718.3),
    ("2024-04-17 21:00", 17543.8), ("2024-04-19 21:00", 17014.4),
    ("2024-04-25 17:00", 17227.3), ("2024-04-30 21:00", 17561.5),
    ("2024-05-24 17:00", 18792.9), ("2024-05-30 17:00", 18592.9),
    ("2024-05-31 17:00", 18330.9), ("2024-07-18 17:00", 19800.3),
    ("2024-07-19 21:00", 19542.6), ("2024-07-24 17:00", 19273.8),
    ("2024-07-25 17:00", 19052.3), ("2024-07-30 21:00", 18810.3),
    ("2024-08-01 21:00", 18758.0), ("2024-08-02 17:00", 18302.1),
    ("2024-08-05 17:00", 17833.0), ("2024-08-23 17:00", 19640.9),
    ("2024-08-28 21:00", 19364.1), ("2024-09-03 17:00", 19117.2),
    ("2024-09-04 17:00", 19044.1), ("2024-09-06 17:00", 18500.5),
    ("2024-10-02 17:00", 19792.2), ("2024-10-03 17:00", 19738.4),
    ("2024-11-04 01:00", 20015.1), ("2024-12-19 01:00", 21158.9),
    ("2024-12-31 21:00", 21043.2), ("2025-01-02 21:00", 20847.9),
    ("2025-01-08 17:00", 21172.0), ("2025-01-10 17:00", 20817.3),
    ("2025-01-27 17:00", 21177.3), ("2025-02-03 17:00", 21306.1),
    ("2025-02-12 17:00", 21635.3), ("2025-02-24 17:00", 21424.8),
    ("2025-02-25 17:00", 21040.6), ("2025-02-26 21:00", 21032.2),
    ("2025-02-27 21:00", 20776.6), ("2025-03-03 21:00", 20553.2),
    ("2025-03-04 17:00", 20149.1), ("2025-03-06 21:00", 20006.8),
    ("2025-03-10 17:00", 19547.9), ("2025-03-11 17:00", 19383.7),
    ("2025-03-13 17:00", 19265.4), ("2025-03-26 17:00", 19995.1),
    ("2025-03-28 17:00", 19355.1), ("2025-03-31 17:00", 18954.9),
    ("2025-04-03 17:00", 18590.7), ("2025-04-04 17:00", 17707.1),
    ("2025-04-16 21:00", 18081.9), ("2025-04-17 17:00", 18184.5),
]

print("Scarico NQ=F 1h (2y)...")
nq = yf.download("NQ=F", period="2y", interval="1h", progress=False)
if isinstance(nq.columns, pd.MultiIndex):
    nq.columns = nq.columns.get_level_values(0)

# Resample a 2H
df_2h = nq.resample('2h').agg({
    'Open': 'first', 'High': 'max', 'Low': 'min',
    'Close': 'last', 'Volume': 'sum'
}).dropna()

# Resample a 4H per confronto
df_4h = nq.resample('4h').agg({
    'Open': 'first', 'High': 'max', 'Low': 'min',
    'Close': 'last', 'Volume': 'sum'
}).dropna()

print(f"  Barre 2H: {len(df_2h)} | Barre 4H: {len(df_4h)}")

LOOKAHEAD_2H = 40  # 40 barre 2H = 80h = stesso di 20 barre 4H
LOOKAHEAD_4H = 20

def build_paths(df, entries, lookahead):
    paths = []
    for entry_date_str, _ in entries:
        entry_dt = pd.Timestamp(entry_date_str, tz='UTC')
        idx = df.index.searchsorted(entry_dt)
        if idx >= len(df) - lookahead:
            continue
        entry_price = df.iloc[idx]['Close']
        path = {'best': [], 'worst': [], 'close': [], 'date': entry_date_str}
        for j in range(1, lookahead + 1):
            if idx + j >= len(df):
                break
            bar = df.iloc[idx + j]
            path['best'].append((entry_price - bar['Low']) / entry_price * 100)
            path['worst'].append((entry_price - bar['High']) / entry_price * 100)
            path['close'].append((entry_price - bar['Close']) / entry_price * 100)
        if len(path['close']) >= lookahead:
            path['best'] = np.array(path['best'])
            path['worst'] = np.array(path['worst'])
            path['close'] = np.array(path['close'])
            paths.append(path)
    return paths

paths_2h = build_paths(df_2h, entries, LOOKAHEAD_2H)
paths_4h = build_paths(df_4h, entries, LOOKAHEAD_4H)
print(f"  Matchate 2H: {len(paths_2h)} | 4H: {len(paths_4h)}")

def simulate(paths, tp, sl, max_bars):
    pnls = []
    for p in paths:
        exited = False
        for b in range(min(max_bars, len(p['close']))):
            if p['best'][b] >= tp:
                pnls.append(tp)
                exited = True
                break
            if p['worst'][b] <= -sl:
                pnls.append(-sl)
                exited = True
                break
        if not exited:
            pnls.append(p['close'][min(max_bars, len(p['close'])) - 1])
    arr = np.array(pnls)
    N = len(arr)
    wins = (arr > 0).sum()
    loss_sum = abs(arr[arr <= 0].sum())
    win_sum = arr[arr > 0].sum()
    pf = win_sum / loss_sum if loss_sum > 0 else 99
    return {
        'total': arr.sum(), 'avg': arr.mean(), 'wr': wins/N*100,
        'pf': pf, 'wins': wins, 'N': N,
        'tp': tp, 'sl': sl, 'max_bars': max_bars
    }

# === CONFRONTO 2H vs 4H ===
print(f"\n{'=' * 70}")
print(f"  CONFRONTO EXIT 2H vs 4H — stesse configurazioni")
print(f"{'=' * 70}")

configs = [
    (0.5, 1.0, "TP 0.5% SL 1.0%"),
    (0.8, 1.0, "TP 0.8% SL 1.0%"),
    (1.0, 1.0, "TP 1.0% SL 1.0%"),
    (1.0, 1.2, "TP 1.0% SL 1.2%"),
    (1.5, 1.0, "TP 1.5% SL 1.0%"),
    (1.5, 1.2, "TP 1.5% SL 1.2%"),
    (2.0, 1.2, "TP 2.0% SL 1.2%"),
    (2.0, 1.5, "TP 2.0% SL 1.5%"),
]

print(f"\n  {'Config':<18} {'--- 4H EXIT ---':>30} {'--- 2H EXIT ---':>30}")
print(f"  {'':18} {'P&L':>7} {'WR':>5} {'PF':>5} {'':>4} {'P&L':>7} {'WR':>5} {'PF':>5} {'Diff':>6}")

for tp, sl, label in configs:
    # 4H: max 12 barre (48h)
    r4 = simulate(paths_4h, tp, sl, 12)
    # 2H: max 24 barre (48h) — stesso tempo
    r2 = simulate(paths_2h, tp, sl, 24)
    diff = r2['total'] - r4['total']
    print(f"  {label:<18} {r4['total']:+7.1f}% {r4['wr']:4.0f}% {r4['pf']:5.2f}      {r2['total']:+7.1f}% {r2['wr']:4.0f}% {r2['pf']:5.2f} {diff:+6.1f}%")

# === GRID SEARCH SU 2H ===
print(f"\n{'=' * 70}")
print(f"  GRID SEARCH COMPLETO — EXIT SU 2H")
print(f"{'=' * 70}")

results_2h = []
for tp in [0.3, 0.5, 0.8, 1.0, 1.2, 1.5, 2.0, 2.5, 3.0]:
    for sl in [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]:
        for mb in [4, 6, 8, 12, 16, 24, 30]:  # barre 2H
            r = simulate(paths_2h, tp, sl, mb)
            r['hours'] = mb * 2
            r['score'] = r['pf'] * np.sqrt(r['N']) * (1 if r['total'] > 0 else 0.3)
            results_2h.append(r)

results_2h.sort(key=lambda x: x['score'], reverse=True)

print(f"\n  TOP 15 PER SCORE (bilanciato):\n")
print(f"  {'TP%':>5} {'SL%':>5} {'Bar':>4} {'Ore':>4} {'P&L':>8} {'Avg':>6} {'WR':>5} {'PF':>5}")
for r in results_2h[:15]:
    print(f"  {r['tp']:5.1f} {r['sl']:5.1f} {r['max_bars']:4d} {r['hours']:3d}h {r['total']:+8.1f}% {r['avg']:+6.2f} {r['wr']:4.0f}% {r['pf']:5.2f}")

# TOP per P&L
results_2h.sort(key=lambda x: x['total'], reverse=True)
print(f"\n  TOP 15 PER P&L TOTALE:\n")
print(f"  {'TP%':>5} {'SL%':>5} {'Bar':>4} {'Ore':>4} {'P&L':>8} {'Avg':>6} {'WR':>5} {'PF':>5}")
for r in results_2h[:15]:
    print(f"  {r['tp']:5.1f} {r['sl']:5.1f} {r['max_bars']:4d} {r['hours']:3d}h {r['total']:+8.1f}% {r['avg']:+6.2f} {r['wr']:4.0f}% {r['pf']:5.2f}")

# === MFE barra per barra 2H ===
print(f"\n{'=' * 70}")
print(f"  MFE CUMULATIVO SU 2H — quando arriva il max profitto?")
print(f"{'=' * 70}")
N = len(paths_2h)
print(f"\n  {'Bar':>4} {'Ore':>4} {'MFE med':>8} {'MFE p50':>8} {'%>0.5%':>7} {'%>1%':>6}")
for h in [1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 30]:
    if h > LOOKAHEAD_2H:
        break
    mfes = np.array([max(p['best'][:h]) for p in paths_2h])
    print(f"  {h:4d} {h*2:3d}h {mfes.mean():+8.2f}% {np.median(mfes):+8.2f}% {(mfes>0.5).sum()/N*100:6.0f}% {(mfes>1.0).sum()/N*100:5.0f}%")

# === BEST 2H CONFIG ===
all_sorted = sorted(results_2h, key=lambda x: x['score'], reverse=True)
b = all_sorted[0]
print(f"\n{'=' * 70}")
print(f"  CONFIGURAZIONE OTTIMALE EXIT 2H")
print(f"{'=' * 70}")
print(f"""
  TP:           {b['tp']:.1f}%
  SL:           {b['sl']:.1f}%
  Max Holding:  {b['max_bars']} barre 2H ({b['hours']}h)

  P&L totale:   {b['total']:+.1f}%
  P&L medio:    {b['avg']:+.2f}%
  Win Rate:     {b['wr']:.0f}%
  Profit Factor:{b['pf']:.2f}
  Win/Loss:     {b['wins']}/{b['N'] - b['wins']}
""")
