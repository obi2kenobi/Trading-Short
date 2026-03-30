"""Analisi trade v2 — senza margin call, focus su riduzione perdite"""
import pandas as pd
import numpy as np

trades_raw = [
    (1, "EMERGENCY", -1150.03, -1.30, 0.00, -1.36, "2023-11-10 17:00", "2023-11-10 21:00", 15304.2),
    (2, "TP/SL", 826.97, 0.94, 0.95, -0.37, "2024-01-04 17:00", "2024-01-05 13:00", 16362.8),
    (3, "TP/SL", -543.75, -0.61, 0.26, -0.60, "2024-01-05 21:00", "2024-01-08 13:00", 16265.9),
    (4, "TP/SL", -354.39, -0.40, 0.54, -0.39, "2024-02-21 17:00", "2024-02-21 21:00", 17409.6),
    (5, "TP/SL", -526.62, -0.60, 0.31, -0.61, "2024-03-15 17:00", "2024-03-18 09:00", 17818.4),
    (6, "TP/SL", -697.75, -0.79, 0.05, -0.78, "2024-03-19 17:00", "2024-03-20 09:00", 17916.7),
    (7, "TP/SL", -616.07, -0.71, 0.01, -0.72, "2024-03-27 17:00", "2024-03-28 13:00", 18174.2),
    (8, "TP/SL", -498.95, -0.58, 0.08, -0.57, "2024-03-28 21:00", "2024-03-31 23:00", 18244.4),
    (9, "TP/SL", 678.51, 0.79, 0.80, -0.29, "2024-04-01 21:00", "2024-04-02 13:00", 18254.6),
    (10, "TP/SL", -637.03, -0.74, 0.01, -0.73, "2024-04-02 17:00", "2024-04-03 13:00", 18010.3),
    (11, "Cover", -12.33, -0.01, 0.41, -0.53, "2024-04-05 17:00", "2024-04-09 01:00", 18116.4),
    (12, "TP/SL", -775.22, -0.90, 0.20, -0.89, "2024-04-10 21:00", "2024-04-11 17:00", 17944.3),
    (13, "TP/SL", -506.26, -0.60, 0.42, -0.59, "2024-04-12 17:00", "2024-04-15 13:00", 18027.0),
    (14, "TP/SL", 1187.91, 1.40, 1.41, -0.59, "2024-04-15 21:00", "2024-04-17 17:00", 17718.3),
    (15, "TP/SL", 1253.01, 1.46, 1.47, -0.43, "2024-04-17 21:00", "2024-04-19 01:00", 17543.8),
    (16, "TP/SL", -961.46, -1.11, 0.25, -1.10, "2024-04-19 21:00", "2024-04-22 17:00", 17014.4),
    (17, "TP/SL", -1156.34, -1.34, 0.01, -1.34, "2024-04-25 17:00", "2024-04-25 21:00", 17227.3),
    (18, "TP/SL", 1070.45, 1.27, 1.29, -0.15, "2024-04-30 21:00", "2024-05-01 09:00", 17561.5),
    (19, "Cover", -53.17, -0.06, 0.15, -0.34, "2024-05-24 17:00", "2024-05-26 23:00", 18792.9),
    (20, "TP/SL", 76.28, 0.09, 0.89, -0.39, "2024-05-30 17:00", "2024-05-31 13:00", 18592.9),
    (21, "TP/SL", -197.26, -0.23, 0.77, -0.22, "2024-05-31 17:00", "2024-05-31 21:00", 18330.9),
    (22, "TP/SL", 1196.12, 1.40, 1.41, -0.09, "2024-07-18 17:00", "2024-07-19 17:00", 19800.3),
    (23, "TP/SL", -891.56, -1.04, 0.18, -1.03, "2024-07-19 21:00", "2024-07-22 13:00", 19542.6),
    (24, "TP/SL", 1317.04, 1.52, 1.53, -0.05, "2024-07-24 17:00", "2024-07-25 09:00", 19273.8),
    (25, "TP/SL", -111.84, -0.13, 1.41, -0.94, "2024-07-25 17:00", "2024-07-26 09:00", 19052.3),
    (26, "TP/SL", -313.12, -0.36, 1.20, -0.35, "2024-07-30 21:00", "2024-07-31 01:00", 18810.3),
    (27, "TP/SL", 1893.31, 2.19, 2.20, -0.93, "2024-08-01 21:00", "2024-08-02 13:00", 18758.0),
    (28, "TP/SL", 2049.04, 2.33, 2.34, -1.14, "2024-08-02 17:00", "2024-08-05 05:00", 18302.1),
    (29, "TP/SL", -2496.53, -2.74, 0.29, -2.73, "2024-08-05 17:00", "2024-08-06 01:00", 17833.0),
    (30, "TP/SL", -485.72, -0.55, 0.63, -0.54, "2024-08-23 17:00", "2024-08-25 23:00", 19640.9),
    (31, "TP/SL", 211.65, 0.24, 1.46, -0.28, "2024-08-28 21:00", "2024-08-29 09:00", 19364.1),
    (32, "TP/SL", 1282.04, 1.46, 1.47, -0.38, "2024-09-03 17:00", "2024-09-04 01:00", 19117.2),
    (33, "TP/SL", -198.40, -0.22, 1.35, -0.21, "2024-09-04 17:00", "2024-09-05 13:00", 19044.1),
    (34, "TP/SL", -424.36, -0.48, 1.04, -0.61, "2024-09-06 17:00", "2024-09-09 09:00", 18500.5),
    (35, "TP/SL", -416.55, -0.47, 0.71, -0.47, "2024-10-02 17:00", "2024-10-03 13:00", 19792.2),
    (36, "TP/SL", -773.84, -0.87, 0.29, -0.86, "2024-10-03 17:00", "2024-10-04 13:00", 19738.4),
    (37, "TP/SL", -387.69, -0.44, 0.58, -0.58, "2024-11-04 01:00", "2024-11-05 13:00", 20015.1),
    (38, "TP/SL", -975.21, -1.12, 0.13, -1.11, "2024-12-19 01:00", "2024-12-19 13:00", 21158.9),
    (39, "TP/SL", -531.86, -0.62, 0.66, -0.61, "2024-12-31 21:00", "2025-01-02 05:00", 21043.2),
    (40, "TP/SL", -1138.15, -1.33, 0.00, -1.32, "2025-01-02 21:00", "2025-01-03 13:00", 20847.9),
    (41, "TP/SL", 1302.39, 1.54, 1.55, -0.36, "2025-01-08 17:00", "2025-01-10 13:00", 21172.0),
    (42, "TP/SL", 46.08, 0.05, 1.36, -0.91, "2025-01-10 17:00", "2025-01-13 21:00", 20817.3),
    (43, "TP/SL", -412.64, -0.48, 1.00, -0.47, "2025-01-27 17:00", "2025-01-28 09:00", 21177.3),
    (44, "Cover", 26.96, 0.03, 0.80, -0.87, "2025-02-03 17:00", "2025-02-04 09:00", 21306.1),
    (45, "TP/SL", -601.77, -0.70, 0.36, -0.69, "2025-02-12 17:00", "2025-02-12 21:00", 21635.3),
    (46, "TP/SL", 1117.37, 1.30, 1.31, -0.80, "2025-02-24 17:00", "2025-02-25 13:00", 21424.8),
    (47, "TP/SL", -695.87, -0.81, 0.53, -0.85, "2025-02-25 17:00", "2025-02-26 05:00", 21040.6),
    (48, "TP/SL", -1048.09, -1.22, 0.21, -1.21, "2025-02-26 21:00", "2025-02-27 09:00", 21032.2),
    (49, "TP/SL", 70.30, 0.08, 1.77, -0.04, "2025-02-27 21:00", "2025-02-28 21:00", 20776.6),
    (50, "TP/SL", 1846.78, 2.19, 2.20, -0.01, "2025-03-03 21:00", "2025-03-04 13:00", 20553.2),
    (51, "TP/SL", -1833.40, -2.12, 0.43, -2.16, "2025-03-04 17:00", "2025-03-04 21:00", 20149.1),
    (52, "TP/SL", -648.55, -0.77, 1.39, -1.14, "2025-03-06 21:00", "2025-03-07 21:00", 20006.8),
    (53, "TP/SL", 22.75, 0.03, 2.26, -0.27, "2025-03-10 17:00", "2025-03-11 09:00", 19547.9),
    (54, "TP/SL", -802.79, -0.96, 1.13, -1.37, "2025-03-11 17:00", "2025-03-12 09:00", 19383.7),
    (55, "TP/SL", -976.85, -1.18, 0.66, -1.17, "2025-03-13 17:00", "2025-03-14 13:00", 19265.4),
    (56, "TP/SL", 1032.08, 1.26, 1.27, -0.14, "2025-03-26 17:00", "2025-03-28 05:00", 19995.1),
    (57, "TP/SL", 1303.16, 1.57, 1.58, -0.21, "2025-03-28 17:00", "2025-03-31 01:00", 19355.1),
    (58, "TP/SL", -1155.22, -1.35, 0.12, -1.48, "2025-03-31 17:00", "2025-03-31 21:00", 18954.9),
    (59, "TP/SL", 2351.41, 2.81, 2.82, -1.20, "2025-04-03 17:00", "2025-04-04 09:00", 18590.7),
    (60, "TP/SL", 4632.75, 5.45, 5.46, -1.65, "2025-04-04 17:00", "2025-04-06 23:00", 17707.1),
    (61, "TP/SL", -2144.29, -2.37, 0.52, -2.36, "2025-04-16 21:00", "2025-04-17 09:00", 18081.9),
    (62, "TP/SL", 2829.23, 3.24, 3.25, -1.23, "2025-04-17 17:00", "2025-04-21 17:00", 18184.5),
    (63, "Cover", -1228.60, -1.35, 0.36, -1.34, "2025-10-17 17:00", "2025-10-19 23:00", 24600.2),
    (64, "TP/SL", -1070.54, -1.20, 0.45, -1.20, "2025-11-07 17:00", "2025-11-07 21:00", 24715.8),
    (65, "TP/SL", 1305.52, 1.48, 1.49, -0.08, "2025-11-13 17:00", "2025-11-14 09:00", 25159.1),
    (66, "TP/SL", 1534.44, 1.70, 1.71, -0.89, "2025-11-14 17:00", "2025-11-18 05:00", 25052.2),
    (67, "TP/SL", -1229.54, -1.36, 0.31, -1.44, "2025-11-18 17:00", "2025-11-19 13:00", 24375.3),
    (68, "TP/SL", -18.36, -0.02, 1.99, -0.01, "2025-11-20 21:00", "2025-11-21 17:00", 24317.0),
    (69, "TP/SL", -392.29, -0.44, 0.35, -0.43, "2025-12-01 17:00", "2025-12-02 13:00", 25362.9),
    (70, "TP/SL", -718.62, -0.80, 0.28, -0.79, "2025-12-11 17:00", "2025-12-11 21:00", 25506.1),
    (71, "TP/SL", -489.16, -0.55, 0.48, -0.54, "2025-12-12 17:00", "2025-12-15 13:00", 25228.4),
    (72, "TP/SL", -429.37, -0.49, 0.67, -0.48, "2025-12-17 17:00", "2025-12-18 13:00", 24820.6),
    (73, "TP/SL", -285.62, -0.33, 0.20, -0.32, "2025-12-29 17:00", "2025-12-30 17:00", 25490.9),
    (74, "TP/SL", 70.39, 0.08, 0.65, -0.04, "2025-12-30 21:00", "2025-12-31 13:00", 25500.3),
    (75, "TP/SL", -88.98, -0.10, 0.50, -0.32, "2025-12-31 17:00", "2026-01-02 01:00", 25343.2),
    (76, "TP/SL", -677.82, -0.77, 0.12, -0.76, "2026-01-02 21:00", "2026-01-05 21:00", 25214.0),
    (77, "TP/SL", -613.99, -0.71, 0.28, -0.70, "2026-01-14 17:00", "2026-01-15 05:00", 25333.5),
    (78, "TP/SL", 1061.10, 1.24, 1.25, -0.26, "2026-01-20 17:00", "2026-01-21 09:00", 25220.7),
    (79, "TP/SL", -1046.93, -1.21, 0.11, -1.30, "2026-01-29 17:00", "2026-01-29 21:00", 25449.0),
    (80, "TP/SL", 1362.56, 1.60, 1.61, -0.11, "2026-01-30 17:00", "2026-02-01 23:00", 25725.9),
    (81, "TP/SL", 1640.82, 1.86, 1.87, -0.80, "2026-02-03 21:00", "2026-02-04 17:00", 25211.3),
    (82, "TP/SL", 1757.33, 1.95, 1.96, -0.30, "2026-02-04 21:00", "2026-02-05 13:00", 25005.8),
    (83, "TP/SL", -364.88, -0.40, 1.57, -1.04, "2026-02-05 17:00", "2026-02-06 09:00", 24534.9),
    (84, "TP/SL", -146.76, -0.16, 1.24, -0.17, "2026-02-12 21:00", "2026-02-13 17:00", 24819.3),
    (85, "TP/SL", -1104.58, -1.22, 0.01, -1.21, "2026-02-17 17:00", "2026-02-18 09:00", 24531.4),
    (86, "TP/SL", 1259.80, 1.40, 1.41, -0.41, "2026-02-26 17:00", "2026-03-02 05:00", 24956.8),
    (87, "TP/SL", 1486.31, 1.66, 1.67, -0.71, "2026-03-02 17:00", "2026-03-03 09:00", 24885.8),
    (88, "TP/SL", -1446.78, -1.60, 0.03, -1.65, "2026-03-03 17:00", "2026-03-04 09:00", 24410.5),
    (89, "TP/SL", -859.15, -0.95, 0.45, -0.94, "2026-03-13 17:00", "2026-03-16 09:00", 24393.7),
    (90, "TP/SL", 70.73, 0.08, 1.31, -0.31, "2026-03-18 21:00", "2026-03-19 17:00", 24427.5),
    (91, "TP/SL", 1306.71, 1.45, 1.46, -0.38, "2026-03-19 21:00", "2026-03-20 17:00", 24356.3),
    (92, "TP/SL", -85.43, -0.09, 1.41, -0.43, "2026-03-20 21:00", "2026-03-23 09:00", 23900.1),
    (93, "TP/SL", 350.36, 0.38, 1.92, -0.04, "2026-03-27 17:00", "2026-03-30 09:00", 23363.9),
    (94, "Apertura", 69.26, 0.08, 0.41, -0.21, "2026-03-30 21:00", "2026-03-30 22:22", 22936.7),
]

df = pd.DataFrame(trades_raw, columns=['trade','signal','pnl_usd','pnl_pct','mfe_pct','mae_pct','entry_date','exit_date','entry_price'])
df['entry_date'] = pd.to_datetime(df['entry_date'])
df['exit_date'] = pd.to_datetime(df['exit_date'])
df['bars_held'] = ((df['exit_date'] - df['entry_date']).dt.total_seconds() / 3600 / 4).astype(int)

wins = df[df['pnl_usd'] > 0]
losses = df[df['pnl_usd'] <= 0]

print("=" * 70)
print("  ANALISI v2 — 94 TRADE SENZA MARGIN CALL")
print("=" * 70)

print(f"\n  Trade: {len(df)} | Win: {len(wins)} | Loss: {len(losses)}")
print(f"  Win Rate: {len(wins)/len(df)*100:.1f}%")
print(f"  P&L: {df['pnl_usd'].sum():+.0f} USD ({df['pnl_pct'].sum():+.1f}%)")
print(f"  Avg Win: {wins['pnl_pct'].mean():+.2f}% | Avg Loss: {losses['pnl_pct'].mean():.2f}%")
pf = abs(wins['pnl_usd'].sum() / losses['pnl_usd'].sum())
print(f"  Profit Factor: {pf:.2f}")

# === PATTERN PERDITE ===
print(f"\n{'=' * 70}")
print(f"  ANALISI PERDITE — dove si perde?")
print(f"{'=' * 70}")

# Perdite per dimensione
big_losses = losses[losses['pnl_pct'] < -1.0]
med_losses = losses[(losses['pnl_pct'] >= -1.0) & (losses['pnl_pct'] < -0.5)]
small_losses = losses[losses['pnl_pct'] >= -0.5]
print(f"\n  Grosse (> -1%):   {len(big_losses)} trade, tot {big_losses['pnl_usd'].sum():+.0f} USD")
print(f"  Medie (-0.5/-1%): {len(med_losses)} trade, tot {med_losses['pnl_usd'].sum():+.0f} USD")
print(f"  Piccole (< -0.5%):{len(small_losses)} trade, tot {small_losses['pnl_usd'].sum():+.0f} USD")

# MFE delle perdite — quante avevano profitto disponibile?
print(f"\n--- PERDITE CON MFE ALTO (avevano profitto ma perso) ---")
loss_good_mfe = losses[losses['mfe_pct'] > 0.5]
loss_no_mfe = losses[losses['mfe_pct'] <= 0.1]
loss_some_mfe = losses[(losses['mfe_pct'] > 0.1) & (losses['mfe_pct'] <= 0.5)]
print(f"  MFE > 0.5% (andato bene poi perso): {len(loss_good_mfe)} trade, {loss_good_mfe['pnl_usd'].sum():+.0f} USD")
print(f"  MFE 0.1-0.5% (un po' di profitto):  {len(loss_some_mfe)} trade, {loss_some_mfe['pnl_usd'].sum():+.0f} USD")
print(f"  MFE < 0.1% (mai in profitto):        {len(loss_no_mfe)} trade, {loss_no_mfe['pnl_usd'].sum():+.0f} USD")

if len(loss_good_mfe) > 0:
    print(f"\n  Dettaglio perdite con MFE > 0.5%:")
    for _, r in loss_good_mfe.iterrows():
        print(f"    #{int(r['trade']):3d} | MFE {r['mfe_pct']:+.2f}% → P&L {r['pnl_pct']:+.2f}% | MAE {r['mae_pct']:.2f}% | {r['bars_held']}bar | {r['entry_date'].strftime('%Y-%m-%d')}")

print(f"\n  Dettaglio perdite MAI in profitto (MFE < 0.1%):")
for _, r in loss_no_mfe.iterrows():
    print(f"    #{int(r['trade']):3d} | MFE {r['mfe_pct']:+.2f}% → P&L {r['pnl_pct']:+.2f}% | {r['bars_held']}bar | {r['entry_date'].strftime('%Y-%m-%d')}")

# === TRADE CONSECUTIVI ===
print(f"\n{'=' * 70}")
print(f"  SERIE CONSECUTIVE")
print(f"{'=' * 70}")

streak = 0
max_loss_streak = 0
max_win_streak = 0
current_type = None
for _, r in df.iterrows():
    if r['pnl_usd'] > 0:
        if current_type == 'W':
            streak += 1
        else:
            streak = 1
            current_type = 'W'
        max_win_streak = max(max_win_streak, streak)
    else:
        if current_type == 'L':
            streak += 1
        else:
            streak = 1
            current_type = 'L'
        max_loss_streak = max(max_loss_streak, streak)

print(f"  Max win consecutive:  {max_win_streak}")
print(f"  Max loss consecutive: {max_loss_streak}")

# === DURATA TRADE ===
print(f"\n{'=' * 70}")
print(f"  DURATA TRADE (barre 4H)")
print(f"{'=' * 70}")

print(f"  Durata media win:  {wins['bars_held'].mean():.1f} barre ({wins['bars_held'].mean()*4:.0f}h)")
print(f"  Durata media loss: {losses['bars_held'].mean():.1f} barre ({losses['bars_held'].mean()*4:.0f}h)")

# Perdite veloci (1-2 barre) vs lente
fast_loss = losses[losses['bars_held'] <= 2]
slow_loss = losses[losses['bars_held'] > 2]
print(f"\n  Perdite veloci (≤2 bar): {len(fast_loss)} trade, {fast_loss['pnl_usd'].sum():+.0f} USD")
print(f"  Perdite lente (>2 bar):  {len(slow_loss)} trade, {slow_loss['pnl_usd'].sum():+.0f} USD")

# === PERIODI ===
print(f"\n{'=' * 70}")
print(f"  P&L PER PERIODO")
print(f"{'=' * 70}")

df['quarter'] = df['entry_date'].dt.to_period('Q')
for q, group in df.groupby('quarter'):
    w = (group['pnl_usd'] > 0).sum()
    l = (group['pnl_usd'] <= 0).sum()
    wr = w / len(group) * 100
    print(f"  {q} | {len(group):2d} trade | WR {wr:4.0f}% | P&L {group['pnl_usd'].sum():+8.0f} USD ({group['pnl_pct'].sum():+.1f}%)")

# === RE-ENTRY DOPO LOSS ===
print(f"\n{'=' * 70}")
print(f"  RE-ENTRY DOPO LOSS — peggiorano?")
print(f"{'=' * 70}")

prev_loss = False
after_loss = []
after_win = []
for _, r in df.iterrows():
    if prev_loss:
        after_loss.append(r['pnl_pct'])
    else:
        after_win.append(r['pnl_pct'])
    prev_loss = r['pnl_usd'] <= 0

print(f"  Trade dopo un loss:  {len(after_loss)} | avg P&L {np.mean(after_loss):+.2f}%")
print(f"  Trade dopo un win:   {len(after_win)} | avg P&L {np.mean(after_win):+.2f}%")

# === EFFICIENZA ===
print(f"\n{'=' * 70}")
print(f"  EFFICIENZA CATTURA PROFITTO")
print(f"{'=' * 70}")

df['efficiency'] = df.apply(lambda r: r['pnl_pct'] / r['mfe_pct'] * 100 if r['mfe_pct'] > 0.1 else 0, axis=1)
eff_trades = df[df['mfe_pct'] > 0.1]
print(f"  Trade con MFE > 0.1%: {len(eff_trades)}")
print(f"  Efficienza media: {eff_trades['efficiency'].mean():.0f}%")
print(f"  (100% = catturi tutto il profitto disponibile)")

# Win efficiency
win_eff = wins[wins['mfe_pct'] > 0.1]
print(f"  Efficienza win: {win_eff['efficiency'].mean():.0f}%")
loss_eff = losses[losses['mfe_pct'] > 0.1]
print(f"  Efficienza loss (profitto perso): {loss_eff['efficiency'].mean():.0f}%")

# === SUGGERIMENTI ===
print(f"\n{'=' * 70}")
print(f"  SUGGERIMENTI")
print(f"{'=' * 70}")

never_profit = losses[losses['mfe_pct'] <= 0.1]
print(f"""
  1. ENTRY SBAGLIATE: {len(never_profit)} trade non sono MAI andati in profitto
     Totale perso: {never_profit['pnl_usd'].sum():+.0f} USD
     → Serve un filtro addizionale per evitare queste entry

  2. PROFITTO NON CATTURATO: {len(loss_good_mfe)} trade avevano MFE > 0.5%
     ma sono chiusi in perdita ({loss_good_mfe['pnl_usd'].sum():+.0f} USD)
     → Il trailing stop è troppo largo o troppo lento per questi

  3. PERDITE VELOCI: {len(fast_loss)} trade persi in ≤2 barre ({fast_loss['pnl_usd'].sum():+.0f} USD)
     → Spesso il prezzo rimbalza subito dopo l'entry

  4. EFFICIENZA: catturi solo {eff_trades['efficiency'].mean():.0f}% del profitto disponibile
     → C'è margine per migliorare il TP/trailing
""")
