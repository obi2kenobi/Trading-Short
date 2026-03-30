"""
Analisi exit ottimale su dati reali NQ Futures 4H.
Per ogni entry della strategia, traccia le barre successive e trova
il miglior punto di uscita.
"""

import yfinance as yf
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

# Entry reali dalla trade list (date, prezzi entry NAS100 CFD)
entries = [
    ("2023-11-10 17:00", 15304.2),
    ("2024-01-04 17:00", 16362.8),
    ("2024-01-05 21:00", 16265.9),
    ("2024-02-21 17:00", 17409.6),
    ("2024-03-15 17:00", 17818.4),
    ("2024-03-19 17:00", 17916.7),
    ("2024-03-27 17:00", 18174.2),
    ("2024-03-28 21:00", 18244.4),
    ("2024-04-01 21:00", 18254.6),
    ("2024-04-02 17:00", 18010.3),
    ("2024-04-05 17:00", 18116.4),
    ("2024-04-10 21:00", 17944.3),
    ("2024-04-12 17:00", 18027.0),
    ("2024-04-15 21:00", 17718.3),
    ("2024-04-17 21:00", 17543.8),
    ("2024-04-19 21:00", 17014.4),
    ("2024-04-25 17:00", 17227.3),
    ("2024-04-30 21:00", 17561.5),
    ("2024-05-24 17:00", 18792.9),
    ("2024-05-30 17:00", 18592.9),
    ("2024-05-31 17:00", 18330.9),
    ("2024-07-18 17:00", 19800.3),
    ("2024-07-19 21:00", 19542.6),
    ("2024-07-24 17:00", 19273.8),
    ("2024-07-25 17:00", 19052.3),
    ("2024-07-30 21:00", 18810.3),
    ("2024-08-01 21:00", 18758.0),
    ("2024-08-02 17:00", 18302.1),
    ("2024-08-05 17:00", 17833.0),
    ("2024-08-23 17:00", 19640.9),
    ("2024-08-28 21:00", 19364.1),
    ("2024-09-03 17:00", 19117.2),
    ("2024-09-04 17:00", 19044.1),
    ("2024-09-06 17:00", 18500.5),
    ("2024-10-02 17:00", 19792.2),
    ("2024-10-03 17:00", 19738.4),
    ("2024-11-04 01:00", 20015.1),
    ("2024-12-19 01:00", 21158.9),
    ("2024-12-31 21:00", 21043.2),
    ("2025-01-02 21:00", 20847.9),
    ("2025-01-08 17:00", 21172.0),
    ("2025-01-10 17:00", 20817.3),
    ("2025-01-27 17:00", 21177.3),
    ("2025-02-03 17:00", 21306.1),
    ("2025-02-12 17:00", 21635.3),
    ("2025-02-24 17:00", 21424.8),
    ("2025-02-25 17:00", 21040.6),
    ("2025-02-26 21:00", 21032.2),
    ("2025-02-27 21:00", 20776.6),
    ("2025-03-03 21:00", 20553.2),
    ("2025-03-04 17:00", 20149.1),
    ("2025-03-06 21:00", 20006.8),
    ("2025-03-10 17:00", 19547.9),
    ("2025-03-11 17:00", 19383.7),
    ("2025-03-13 17:00", 19265.4),
    ("2025-03-26 17:00", 19995.1),
    ("2025-03-28 17:00", 19355.1),
    ("2025-03-31 17:00", 18954.9),
    ("2025-04-03 17:00", 18590.7),
    ("2025-04-04 17:00", 17707.1),
    ("2025-04-16 21:00", 18081.9),
    ("2025-04-17 17:00", 18184.5),
]


def resample_4h(df):
    return df.resample('4h').agg({
        'Open': 'first', 'High': 'max', 'Low': 'min',
        'Close': 'last', 'Volume': 'sum'
    }).dropna()


print("Scarico NQ=F 1h (2y)...")
nq = yf.download("NQ=F", period="2y", interval="1h", progress=False)
if isinstance(nq.columns, pd.MultiIndex):
    nq.columns = nq.columns.get_level_values(0)
df = resample_4h(nq)
print(f"  Barre 4H: {len(df)}, range {df.index[0]} — {df.index[-1]}")

# Per ogni entry, traccia le prossime N barre
LOOKAHEAD = 30  # guarda fino a 30 barre avanti (120h = 5 giorni)

all_paths = []  # lista di array: % change da entry per ogni barra
matched = 0

for entry_date_str, entry_price_ig in entries:
    entry_dt = pd.Timestamp(entry_date_str, tz='UTC')

    # Trova la barra più vicina nei dati NQ
    idx = df.index.searchsorted(entry_dt)
    if idx >= len(df) - LOOKAHEAD:
        continue

    # Usa il close della barra come proxy entry price
    entry_bar = df.iloc[idx]
    entry_price = entry_bar['Close']

    # Traccia le prossime LOOKAHEAD barre
    path_high = []  # max profitto (per short: entry - low)
    path_low = []   # max avverso (per short: entry - high)
    path_close = [] # P&L al close

    for j in range(1, LOOKAHEAD + 1):
        if idx + j >= len(df):
            break
        bar = df.iloc[idx + j]
        # Per uno short: profitto = (entry - price) / entry * 100
        pnl_close = (entry_price - bar['Close']) / entry_price * 100
        pnl_best = (entry_price - bar['Low']) / entry_price * 100  # miglior caso
        pnl_worst = (entry_price - bar['High']) / entry_price * 100  # peggior caso

        path_close.append(pnl_close)
        path_high.append(pnl_best)
        path_low.append(pnl_worst)

    if len(path_close) >= LOOKAHEAD:
        all_paths.append({
            'close': np.array(path_close),
            'best': np.array(path_high),
            'worst': np.array(path_low),
            'date': entry_date_str,
            'price': entry_price,
        })
        matched += 1

print(f"\n  Entry matchate: {matched}/{len(entries)}")

# === ANALISI ===
N = len(all_paths)
bars = LOOKAHEAD

print(f"\n{'=' * 70}")
print(f"  COSA SUCCEDE DOPO L'ENTRY — barra per barra (media di {N} trade)")
print(f"{'=' * 70}")

print(f"\n  {'Barra':>5} {'Ore':>5} {'Close%':>8} {'Best%':>8} {'Worst%':>8} {'%InProfit':>10}")
for b in range(bars):
    closes = np.array([p['close'][b] for p in all_paths])
    bests = np.array([p['best'][b] for p in all_paths])
    worsts = np.array([p['worst'][b] for p in all_paths])
    in_profit = (closes > 0).sum() / N * 100

    print(f"  {b+1:5d} {(b+1)*4:5d}h {closes.mean():+8.2f} {bests.mean():+8.2f} {worsts.mean():+8.2f} {in_profit:9.0f}%")

# Profitto massimo cumulativo per ogni trade
print(f"\n{'=' * 70}")
print(f"  MFE CUMULATIVO — max profitto raggiunto entro N barre")
print(f"{'=' * 70}")

print(f"\n  {'Entro':>6} {'MFE medio':>10} {'MFE mediano':>12} {'% con MFE>1%':>13}")
for horizon in [1, 2, 3, 4, 5, 6, 8, 10, 15, 20, 30]:
    if horizon > bars:
        break
    mfes = []
    for p in all_paths:
        max_profit = max(p['best'][:horizon])
        mfes.append(max_profit)
    mfes = np.array(mfes)
    pct_gt1 = (mfes > 1.0).sum() / N * 100
    print(f"  {horizon:3d}bar {mfes.mean():+10.2f}% {np.median(mfes):+12.2f}% {pct_gt1:12.0f}%")

# Simulazione: exit ottimale con TP fisso + SL fisso + max holding
print(f"\n{'=' * 70}")
print(f"  SIMULAZIONE EXIT — TP fisso + SL fisso (dati reali)")
print(f"{'=' * 70}")

best_score = -999
best_params = None
results = []

for tp_pct in [0.5, 0.8, 1.0, 1.2, 1.5, 2.0, 2.5, 3.0]:
    for sl_pct in [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]:
        for max_bars in [3, 5, 8, 12, 20]:
            trade_pnls = []
            for p in all_paths:
                exited = False
                for b in range(min(max_bars, bars)):
                    # TP hit? (best price reached TP)
                    if p['best'][b] >= tp_pct:
                        trade_pnls.append(tp_pct)
                        exited = True
                        break
                    # SL hit? (worst price reached SL)
                    if p['worst'][b] <= -sl_pct:
                        trade_pnls.append(-sl_pct)
                        exited = True
                        break
                if not exited:
                    # Timeout: chiudi al close dell'ultima barra
                    trade_pnls.append(p['close'][min(max_bars, bars) - 1])

            arr = np.array(trade_pnls)
            wins = (arr > 0).sum()
            total = arr.sum()
            avg = arr.mean()
            wr = wins / N * 100
            win_sum = arr[arr > 0].sum()
            loss_sum = abs(arr[arr <= 0].sum())
            pf = win_sum / loss_sum if loss_sum > 0 else 99

            score = pf * np.sqrt(N) * (1 if total > 0 else 0.3)
            results.append({
                'tp': tp_pct, 'sl': sl_pct, 'max_bars': max_bars,
                'total': total, 'avg': avg, 'wr': wr, 'pf': pf,
                'wins': wins, 'score': score
            })
            if score > best_score:
                best_score = score
                best_params = results[-1]

# Sort by score
results.sort(key=lambda x: x['score'], reverse=True)

print(f"\n  TOP 20 CONFIGURAZIONI (TP + SL + Max Holding):\n")
print(f"  {'TP%':>5} {'SL%':>5} {'MaxBar':>6} {'P&L tot':>8} {'Avg':>6} {'WR':>5} {'PF':>5} {'Win':>4}")
for r in results[:20]:
    print(f"  {r['tp']:5.1f} {r['sl']:5.1f} {r['max_bars']:6d} {r['total']:+8.1f}% {r['avg']:+6.2f} {r['wr']:4.0f}% {r['pf']:5.2f} {r['wins']:4d}")

print(f"\n{'=' * 70}")
print(f"  CONFIGURAZIONE OTTIMALE")
print(f"{'=' * 70}")
b = best_params
print(f"""
  TP:         {b['tp']:.1f}%
  SL:         {b['sl']:.1f}%
  Max Bars:   {b['max_bars']} barre ({b['max_bars']*4}h)

  P&L totale: {b['total']:+.1f}%
  P&L medio:  {b['avg']:+.2f}%
  Win Rate:   {b['wr']:.0f}%
  Profit Factor: {b['pf']:.2f}
  Win/Loss:   {b['wins']}/{N - b['wins']}
""")

# Confronto con strategia attuale
print(f"{'=' * 70}")
print(f"  CONFRONTO CON STRATEGIA ATTUALE")
print(f"{'=' * 70}")
print(f"""
  ATTUALE:  P&L +2.4% | WR 39% | PF 1.06 | 94 trade
  OTTIMALE: P&L {b['total']:+.1f}% | WR {b['wr']:.0f}% | PF {b['pf']:.2f} | {N} trade

  Differenza: {b['total'] - 2.4:+.1f}% di P&L in più
""")

# Analisi: cosa succede se usciamo dopo N barre (senza TP/SL)?
print(f"{'=' * 70}")
print(f"  EXIT A TEMPO — se chiudiamo dopo N barre senza condizioni")
print(f"{'=' * 70}")
print(f"\n  {'Barre':>6} {'P&L tot':>8} {'Avg':>7} {'WR':>5} {'Mediana':>8}")
for hold in [1, 2, 3, 4, 5, 6, 8, 10, 15, 20]:
    if hold > bars:
        break
    closes = np.array([p['close'][hold-1] for p in all_paths])
    wr = (closes > 0).sum() / N * 100
    print(f"  {hold:4d}bar {closes.sum():+8.1f}% {closes.mean():+7.2f} {wr:4.0f}% {np.median(closes):+8.2f}")
