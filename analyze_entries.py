"""Analisi entry signals — il segnale è corretto? A quali condizioni è profittevole?"""
import numpy as np

trades = [
    # (trade#, signal, pnl_pct, mfe_pct, mae_pct, entry_price, entry_date)
    (1, "EMERGENCY", -1.30, 0.00, -1.36, 15304.2, "2023-11-10"),
    (2, "TP/SL", 0.94, 0.95, -0.37, 16362.8, "2024-01-04"),
    (3, "TP/SL", -0.61, 0.26, -0.60, 16265.9, "2024-01-05"),
    (4, "TP/SL", -0.40, 0.54, -0.39, 17409.6, "2024-02-21"),
    (5, "TP/SL", -0.60, 0.31, -0.61, 17818.4, "2024-03-15"),
    (6, "TP/SL", -0.79, 0.05, -0.78, 17916.7, "2024-03-19"),
    (7, "TP/SL", -0.71, 0.01, -0.72, 18174.2, "2024-03-27"),
    (8, "TP/SL", -0.58, 0.08, -0.57, 18244.4, "2024-03-28"),
    (9, "TP/SL", 0.79, 0.80, -0.29, 18254.6, "2024-04-01"),
    (10, "TP/SL", -0.74, 0.01, -0.73, 18010.3, "2024-04-02"),
    (11, "Cover", -0.01, 0.41, -0.53, 18116.4, "2024-04-05"),
    (12, "TP/SL", -0.90, 0.20, -0.89, 17944.3, "2024-04-10"),
    (13, "TP/SL", -0.60, 0.42, -0.59, 18027.0, "2024-04-12"),
    (14, "TP/SL", 1.40, 1.41, -0.59, 17718.3, "2024-04-15"),
    (15, "TP/SL", 1.46, 1.47, -0.43, 17543.8, "2024-04-17"),
    (16, "TP/SL", -1.11, 0.25, -1.10, 17014.4, "2024-04-19"),
    (17, "TP/SL", -1.34, 0.01, -1.34, 17227.3, "2024-04-25"),
    (18, "TP/SL", 1.27, 1.29, -0.15, 17561.5, "2024-04-30"),
    (19, "Cover", -0.06, 0.15, -0.34, 18792.9, "2024-05-24"),
    (20, "TP/SL", 0.09, 0.89, -0.39, 18592.9, "2024-05-30"),
    (21, "TP/SL", -0.23, 0.77, -0.22, 18330.9, "2024-05-31"),
    (22, "TP/SL", 1.40, 1.41, -0.09, 19800.3, "2024-07-18"),
    (23, "TP/SL", -1.04, 0.18, -1.03, 19542.6, "2024-07-19"),
    (24, "TP/SL", 1.52, 1.53, -0.05, 19273.8, "2024-07-24"),
    (25, "TP/SL", -0.13, 1.41, -0.94, 19052.3, "2024-07-25"),
    (26, "TP/SL", -0.36, 1.20, -0.35, 18810.3, "2024-07-30"),
    (27, "TP/SL", 2.19, 2.20, -0.93, 18758.0, "2024-08-01"),
    (28, "TP/SL", 2.33, 2.34, -1.14, 18302.1, "2024-08-02"),
    (29, "TP/SL", -2.74, 0.29, -2.73, 17833.0, "2024-08-05"),
    (30, "TP/SL", -0.55, 0.63, -0.54, 19640.9, "2024-08-23"),
    (31, "TP/SL", 0.24, 1.46, -0.28, 19364.1, "2024-08-28"),
    (32, "TP/SL", 1.46, 1.47, -0.38, 19117.2, "2024-09-03"),
    (33, "TP/SL", -0.22, 1.35, -0.21, 19044.1, "2024-09-04"),
    (34, "TP/SL", -0.48, 1.04, -0.61, 18500.5, "2024-09-06"),
    (35, "TP/SL", -0.47, 0.71, -0.47, 19792.2, "2024-10-02"),
    (36, "TP/SL", -0.87, 0.29, -0.86, 19738.4, "2024-10-03"),
    (37, "TP/SL", -0.44, 0.58, -0.58, 20015.1, "2024-11-04"),
    (38, "TP/SL", -1.12, 0.13, -1.11, 21158.9, "2024-12-19"),
    (39, "TP/SL", -0.62, 0.66, -0.61, 21043.2, "2024-12-31"),
    (40, "TP/SL", -1.33, 0.00, -1.32, 20847.9, "2025-01-02"),
    (41, "TP/SL", 1.54, 1.55, -0.36, 21172.0, "2025-01-08"),
    (42, "TP/SL", 0.05, 1.36, -0.91, 20817.3, "2025-01-10"),
    (43, "TP/SL", -0.48, 1.00, -0.47, 21177.3, "2025-01-27"),
    (44, "Cover", 0.03, 0.80, -0.87, 21306.1, "2025-02-03"),
    (45, "TP/SL", -0.70, 0.36, -0.69, 21635.3, "2025-02-12"),
    (46, "TP/SL", 1.30, 1.31, -0.80, 21424.8, "2025-02-24"),
    (47, "TP/SL", -0.81, 0.53, -0.85, 21040.6, "2025-02-25"),
    (48, "TP/SL", -1.22, 0.21, -1.21, 21032.2, "2025-02-26"),
    (49, "TP/SL", 0.08, 1.77, -0.04, 20776.6, "2025-02-27"),
    (50, "TP/SL", 2.19, 2.20, -0.01, 20553.2, "2025-03-03"),
    (51, "TP/SL", -2.12, 0.43, -2.16, 20149.1, "2025-03-04"),
    (52, "TP/SL", -0.77, 1.39, -1.14, 20006.8, "2025-03-06"),
    (53, "TP/SL", 0.03, 2.26, -0.27, 19547.9, "2025-03-10"),
    (54, "TP/SL", -0.96, 1.13, -1.37, 19383.7, "2025-03-11"),
    (55, "TP/SL", -1.18, 0.66, -1.17, 19265.4, "2025-03-13"),
    (56, "TP/SL", 1.26, 1.27, -0.14, 19995.1, "2025-03-26"),
    (57, "TP/SL", 1.57, 1.58, -0.21, 19355.1, "2025-03-28"),
    (58, "TP/SL", -1.35, 0.12, -1.48, 18954.9, "2025-03-31"),
    (59, "TP/SL", 2.81, 2.82, -1.20, 18590.7, "2025-04-03"),
    (60, "TP/SL", 5.45, 5.46, -1.65, 17707.1, "2025-04-04"),
    (61, "TP/SL", -2.37, 0.52, -2.36, 18081.9, "2025-04-16"),
    (62, "TP/SL", 3.24, 3.25, -1.23, 18184.5, "2025-04-17"),
    (63, "Cover", -1.35, 0.36, -1.34, 24600.2, "2025-10-17"),
    (64, "TP/SL", -1.20, 0.45, -1.20, 24715.8, "2025-11-07"),
    (65, "TP/SL", 1.48, 1.49, -0.08, 25159.1, "2025-11-13"),
    (66, "TP/SL", 1.70, 1.71, -0.89, 25052.2, "2025-11-14"),
    (67, "TP/SL", -1.36, 0.31, -1.44, 24375.3, "2025-11-18"),
    (68, "TP/SL", -0.02, 1.99, -0.01, 24317.0, "2025-11-20"),
    (69, "TP/SL", -0.44, 0.35, -0.43, 25362.9, "2025-12-01"),
    (70, "TP/SL", -0.80, 0.28, -0.79, 25506.1, "2025-12-11"),
    (71, "TP/SL", -0.55, 0.48, -0.54, 25228.4, "2025-12-12"),
    (72, "TP/SL", -0.49, 0.67, -0.48, 24820.6, "2025-12-17"),
    (73, "TP/SL", -0.33, 0.20, -0.32, 25490.9, "2025-12-29"),
    (74, "TP/SL", 0.08, 0.65, -0.04, 25500.3, "2025-12-30"),
    (75, "TP/SL", -0.10, 0.50, -0.32, 25343.2, "2025-12-31"),
    (76, "TP/SL", -0.77, 0.12, -0.76, 25214.0, "2026-01-02"),
    (77, "TP/SL", -0.71, 0.28, -0.70, 25333.5, "2026-01-14"),
    (78, "TP/SL", 1.24, 1.25, -0.26, 25220.7, "2026-01-20"),
    (79, "TP/SL", -1.21, 0.11, -1.30, 25449.0, "2026-01-29"),
    (80, "TP/SL", 1.60, 1.61, -0.11, 25725.9, "2026-01-30"),
    (81, "TP/SL", 1.86, 1.87, -0.80, 25211.3, "2026-02-03"),
    (82, "TP/SL", 1.95, 1.96, -0.30, 25005.8, "2026-02-04"),
    (83, "TP/SL", -0.40, 1.57, -1.04, 24534.9, "2026-02-05"),
    (84, "TP/SL", -0.16, 1.24, -0.17, 24819.3, "2026-02-12"),
    (85, "TP/SL", -1.22, 0.01, -1.21, 24531.4, "2026-02-17"),
    (86, "TP/SL", 1.40, 1.41, -0.41, 24956.8, "2026-02-26"),
    (87, "TP/SL", 1.66, 1.67, -0.71, 24885.8, "2026-03-02"),
    (88, "TP/SL", -1.60, 0.03, -1.65, 24410.5, "2026-03-03"),
    (89, "TP/SL", -0.95, 0.45, -0.94, 24393.7, "2026-03-13"),
    (90, "TP/SL", 0.08, 1.31, -0.31, 24427.5, "2026-03-18"),
    (91, "TP/SL", 1.45, 1.46, -0.38, 24356.3, "2026-03-19"),
    (92, "TP/SL", -0.09, 1.41, -0.43, 23900.1, "2026-03-20"),
    (93, "TP/SL", 0.38, 1.92, -0.04, 23363.9, "2026-03-27"),
    (94, "Apertura", 0.05, 0.41, -0.21, 22936.7, "2026-03-30"),
]

pnl = np.array([t[2] for t in trades])
mfe = np.array([t[3] for t in trades])
mae = np.array([t[4] for t in trades])

print("=" * 70)
print("  ANALISI SEGNALE DI ENTRATA")
print("=" * 70)

# 1. Il segnale indica la DIREZIONE corretta?
print("\n" + "=" * 70)
print("  1. IL SEGNALE INDICA LA DIREZIONE GIUSTA?")
print("=" * 70)

went_down = mfe > 0.1  # prezzo è sceso di almeno 0.1% dopo entry
never_down = mfe <= 0.1  # il prezzo non è MAI sceso significativamente

print(f"\n  Il prezzo è sceso dopo l'entry (MFE > 0.1%): {went_down.sum()}/{len(trades)} ({went_down.sum()/len(trades)*100:.0f}%)")
print(f"  Il prezzo NON è mai sceso (MFE ≤ 0.1%):     {never_down.sum()}/{len(trades)} ({never_down.sum()/len(trades)*100:.0f}%)")
print(f"  → Il segnale indica la direzione giusta nel {went_down.sum()/len(trades)*100:.0f}% dei casi")

# Quanto scende mediamente?
print(f"\n  MFE medio (quanto scende):           {mfe.mean():.2f}%")
print(f"  MFE medio sui trade che scendono:    {mfe[went_down].mean():.2f}%")
print(f"  MAE medio (quanto sale contro):      {mae.mean():.2f}%")

# 2. Distribuzione MFE
print(f"\n{'=' * 70}")
print(f"  2. DISTRIBUZIONE MFE — quanto profitto è disponibile?")
print(f"{'=' * 70}")

brackets = [(0, 0.1), (0.1, 0.5), (0.5, 1.0), (1.0, 1.5), (1.5, 2.0), (2.0, 3.0), (3.0, 6.0)]
for lo, hi in brackets:
    mask = (mfe >= lo) & (mfe < hi)
    count = mask.sum()
    avg_pnl = pnl[mask].mean() if count > 0 else 0
    total_pnl = pnl[mask].sum()
    print(f"  MFE {lo:.1f}-{hi:.1f}%: {count:2d} trade ({count/len(trades)*100:4.0f}%) | avg P&L {avg_pnl:+.2f}% | tot P&L {total_pnl:+.1f}%")

# 3. Il problema: TP cattura poco
print(f"\n{'=' * 70}")
print(f"  3. EFFICIENZA TP — quanto del profitto disponibile catturiamo?")
print(f"{'=' * 70}")

# Solo trade con MFE significativo
good_entries = [(t, p, m) for t, p, m in zip(trades, pnl, mfe) if m > 0.5]
print(f"\n  Trade con MFE > 0.5% (il segnale era buono): {len(good_entries)}")
good_pnl = np.array([p for _, p, _ in good_entries])
good_mfe = np.array([m for _, _, m in good_entries])
print(f"  MFE medio: {good_mfe.mean():.2f}%")
print(f"  P&L medio: {good_pnl.mean():.2f}%")
print(f"  Efficienza: {good_pnl.mean()/good_mfe.mean()*100:.0f}%")
print(f"  Win rate su questi: {(good_pnl > 0).sum()}/{len(good_pnl)} ({(good_pnl > 0).sum()/len(good_pnl)*100:.0f}%)")

# 4. Scenario: se catturassimo il 50% del MFE
print(f"\n{'=' * 70}")
print(f"  4. SCENARI — se catturassimo più MFE?")
print(f"{'=' * 70}")

for capture in [0.3, 0.4, 0.5, 0.6, 0.7]:
    scenario_pnl = []
    for t in trades:
        t_mfe = t[3]
        t_mae = t[4]
        if t_mfe > 0.3:  # entry con MFE sufficiente
            # Catturiamo capture% del MFE, con cap allo stop
            profit = t_mfe * capture
            scenario_pnl.append(profit)
        else:
            # MFE basso = perdiamo (usiamo MAE come proxy)
            scenario_pnl.append(t_mae * 0.7)  # perdiamo ~70% del MAE
    sp = np.array(scenario_pnl)
    wins = (sp > 0).sum()
    print(f"  Cattura {capture*100:.0f}% MFE: P&L tot {sp.sum():+.1f}% | avg {sp.mean():+.2f}% | WR {wins}/{len(sp)} ({wins/len(sp)*100:.0f}%)")

# 5. Analisi entry consecutive — le entry ripetute funzionano?
print(f"\n{'=' * 70}")
print(f"  5. ENTRY CONSECUTIVE — rientrare subito funziona?")
print(f"{'=' * 70}")

from datetime import datetime
dates = [datetime.strptime(t[6], "%Y-%m-%d") for t in trades]
first_entry = []
reentry = []
for i, t in enumerate(trades):
    if i == 0:
        first_entry.append(t)
        continue
    days_gap = (dates[i] - dates[i-1]).days
    if days_gap <= 2:  # re-entry entro 2 giorni
        reentry.append(t)
    else:
        first_entry.append(t)

fe_pnl = np.array([t[2] for t in first_entry])
re_pnl = np.array([t[2] for t in reentry])

print(f"\n  Prima entry (gap > 2gg): {len(first_entry)} trade | avg P&L {fe_pnl.mean():+.2f}% | WR {(fe_pnl>0).sum()}/{len(fe_pnl)} ({(fe_pnl>0).sum()/len(fe_pnl)*100:.0f}%)")
print(f"  Re-entry (≤2gg):         {len(reentry)} trade | avg P&L {re_pnl.mean():+.2f}% | WR {(re_pnl>0).sum()}/{len(re_pnl)} ({(re_pnl>0).sum()/len(re_pnl)*100:.0f}%)")

# 6. Mai in profitto — queste entry sono sbagliate
print(f"\n{'=' * 70}")
print(f"  6. ENTRY MAI IN PROFITTO (MFE < 0.1%) — queste sono sbagliate")
print(f"{'=' * 70}")

never = [(t, p, m) for t, p, m in zip(trades, pnl, mfe) if m <= 0.1]
print(f"\n  {len(never)} entry non vanno MAI nella direzione giusta:")
for t, p, m in never:
    print(f"    #{t[0]:2d} | {t[6]} | entry {t[5]:.0f} | MFE {m:.2f}% | P&L {p:+.2f}%")
print(f"\n  Totale perso: {sum(p for _, p, _ in never):.2f}%")

# 7. Conclusione
print(f"\n{'=' * 70}")
print(f"  7. CONCLUSIONE")
print(f"{'=' * 70}")

big_wins = pnl[pnl >= 1.0]
small_gains = pnl[(pnl > 0) & (pnl < 1.0)]
small_losses = pnl[(pnl <= 0) & (pnl > -1.0)]
big_losses = pnl[pnl <= -1.0]

print(f"""
  STRUTTURA P&L:
  Big win (≥1%):      {len(big_wins):2d} trade | tot {big_wins.sum():+.1f}%  ← questi fanno i soldi
  Small win (<1%):    {len(small_gains):2d} trade | tot {small_gains.sum():+.1f}%
  Small loss (>-1%):  {len(small_losses):2d} trade | tot {small_losses.sum():+.1f}%
  Big loss (≤-1%):    {len(big_losses):2d} trade | tot {big_losses.sum():+.1f}%  ← questi li mangiano

  Il segnale di entry è CORRETTO nel {went_down.sum()/len(trades)*100:.0f}% dei casi.
  Il prezzo scende in media di {mfe.mean():.2f}% dopo l'entry.

  IL PROBLEMA NON È L'ENTRY — è l'exit:
  - MFE medio {mfe.mean():.2f}% ma P&L medio {pnl.mean():.2f}%
  - Catturiamo solo {pnl.mean()/mfe.mean()*100:.0f}% del profitto disponibile
  - {len(big_losses)} grosse perdite (≤-1%) mangiano {big_losses.sum():.1f}%

  PROFITTABILITÀ REALE:
  Se il TP cattura ≥50% del MFE → strategia profittevole
  Se il SL limita le perdite a -1% max → elimina le grosse loss
""")
