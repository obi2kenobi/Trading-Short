"""Analisi trade list da TradingView"""
import pandas as pd

# Parse the data
data = """Trade #	Tipo	Segnale	P&L netto USD	P&L netto %	Escursione favorevole %	Escursione avversa %	Dimensione posizione (quantità)
1	Uscita short	Margin call	-83.63	-1.37	0.00	-1.36	0.4
2	Uscita short	EMERGENCY	-1209.51	-1.30	0.00	-1.36	6.1
3	Uscita short	Margin call	-134.25	-0.85	0.05	-0.84	1
4	Uscita short	TP/SL	-723.09	-0.89	0.05	-0.88	5.2
5	Uscita short	TP/SL	71.49	0.07	0.86	-0.21	5.9
6	Uscita short	TP/SL	-74.14	-0.08	0.91	-0.16	5.9
7	Uscita short	Margin call	-51.36	-0.32	0.12	-0.31	1
8	Uscita short	Cover	-109.28	-0.13	0.12	-0.49	5
9	Uscita short	Margin call	-114.14	-0.69	0.21	-0.68	1
10	Uscita short	TP/SL	-423.53	-0.53	0.21	-0.68	4.8
11	Uscita short	TP/SL	1078.64	1.12	1.13	-0.24	5.5
12	Uscita short	Margin call	-125.92	-1.81	0.12	-1.80	0.4
13	Uscita short	TP/SL	-1564.68	-1.73	0.12	-1.80	5.2
14	Uscita short	TP/SL	-360.34	-0.38	0.60	-0.37	5.3
15	Uscita short	TP/SL	-569.61	-0.60	0.31	-0.61	5.3
16	Uscita short	Margin call	-129.4	-0.72	0.05	-0.71	1
17	Uscita short	Cover	-367.61	-0.48	0.05	-0.71	4.3
18	Uscita short	Margin call	-114.85	-0.63	0.01	-0.62	1
19	Uscita short	TP/SL	-539.06	-0.71	0.01	-0.72	4.2
20	Uscita short	TP/SL	-541.41	-0.58	0.08	-0.57	5.1
21	Uscita short	TP/SL	736.26	0.79	0.80	-0.29	5.1
22	Uscita short	Margin call	-133.72	-0.74	0.01	-0.73	1
23	Uscita short	TP/SL	-557.4	-0.74	0.01	-0.73	4.2
24	Uscita short	Cover	-13.38	-0.01	0.41	-0.53	5.1
25	Uscita short	Margin call	-101.7	-0.57	0.04	-0.56	1
26	Uscita short	TP/SL	-678.32	-0.90	0.20	-0.89	4.2
27	Uscita short	TP/SL	-549.35	-0.60	0.42	-0.59	5.1
28	Uscita short	Margin call	-50.85	-0.29	0.50	-0.28	1
29	Uscita short	TP/SL	1039.42	1.40	1.41	-0.59	4.2
30	Uscita short	Margin call	-77.72	-0.44	0.36	-0.43	1
31	Uscita short	TP/SL	1099.58	1.46	1.47	-0.43	4.3
32	Uscita short	Margin call	-109.01	-0.64	0.25	-0.63	1
33	Uscita short	TP/SL	-848.35	-1.11	0.25	-1.10	4.5
34	Uscita short	Margin call	-92.83	-1.35	0.01	-1.34	0.4
35	Uscita short	TP/SL	-1156.34	-1.34	0.01	-1.34	5
36	Uscita short	TP/SL	1159.65	1.27	1.29	-0.15	5.2
37	Uscita short	Margin call	-84.72	-0.46	0.05	-0.45	1
38	Uscita short	TP/SL	-372.49	-0.50	0.05	-0.54	4
39	Uscita short	Margin call	-74.93	-0.40	0.18	-0.39	1
40	Uscita short	TP/SL	66.33	0.09	0.89	-0.39	4
41	Uscita short	TP/SL	-209.85	-0.23	0.77	-0.22	5
42	Uscita short	TP/SL	1151.1	1.26	1.27	-0.24	4.6
43	Uscita short	TP/SL	-264.78	-0.29	0.92	-0.71	4.7
44	Uscita short	TP/SL	1404.84	1.52	1.53	-0.05	4.8
45	Uscita short	TP/SL	-119.13	-0.13	1.41	-0.94	4.9
46	Uscita short	TP/SL	-340.34	-0.36	1.20	-0.35	5
47	Uscita short	Margin call	-176.77	-0.94	0.22	-0.93	1
48	Uscita short	TP/SL	1646.36	2.19	2.20	-0.93	4
49	Uscita short	Margin call	-211.28	-1.15	0.10	-1.14	1
50	Uscita short	TP/SL	1792.91	2.33	2.34	-1.14	4.2
51	Uscita short	Margin call	-137.48	-1.93	0.29	-1.92	0.4
52	Uscita short	TP/SL	-2447.58	-2.74	0.29	-2.73	5
53	Uscita short	TP/SL	-647.61	-0.69	0.36	-0.68	4.8
54	Uscita short	Margin call	-103.04	-0.52	0.00	-0.51	1
55	Uscita short	TP/SL	-410.17	-0.55	0.63	-0.54	3.8
56	Uscita short	TP/SL	225.75	0.24	1.46	-0.28	4.8
57	Uscita short	Margin call	-74.23	-0.39	0.00	-0.38	1
58	Uscita short	TP/SL	1086.95	1.46	1.47	-0.38	3.9
59	Uscita short	Margin call	-26.21	-0.14	0.00	-0.13	1
60	Uscita short	TP/SL	-168.85	-0.22	1.35	-0.21	4
61	Uscita short	Margin call	-114.01	-0.62	0.54	-0.61	1
62	Uscita short	TP/SL	-362.48	-0.48	1.04	-0.61	4.1
63	Uscita short	TP/SL	-693.52	-0.75	0.52	-0.80	4.7
64	Uscita short	Margin call	-143.36	-0.73	0.29	-0.72	1
65	Uscita short	TP/SL	-420.17	-0.58	0.29	-0.72	3.7
66	Uscita short	TP/SL	-405.31	-0.44	0.58	-0.58	4.6
67	Uscita short	Margin call	-26.22	-0.12	0.00	-0.11	1
68	Uscita short	TP/SL	1439.21	2.02	2.78	-0.11	3.3
69	Uscita short	Margin call	-200.85	-0.95	0.14	-0.94	1
70	Uscita short	TP/SL	-102.79	-0.14	1.13	-0.94	3.4
71	Uscita short	Margin call	-140.38	-0.67	0.00	-0.66	1
72	Uscita short	TP/SL	-971.59	-1.33	0.00	-1.32	3.5
73	Uscita short	TP/SL	1409.06	1.54	1.55	-0.17	4.3
74	Uscita short	Margin call	-190.78	-0.92	0.48	-0.91	1
75	Uscita short	TP/SL	39.33	0.05	1.36	-0.91	3.5
76	Uscita short	TP/SL	-442.84	-0.48	1.00	-0.47	4.4
77	Uscita short	Cover	28.98	0.03	0.80	-0.87	4.3
78	Uscita short	TP/SL	1323.19	1.44	1.53	-0.11	4.2
79	Uscita short	Margin call	-172.8	-0.81	0.06	-0.80	1
80	Uscita short	TP/SL	949.77	1.30	1.31	-0.80	3.4
81	Uscita short	Margin call	-180.83	-0.86	0.53	-0.85	1
82	Uscita short	TP/SL	-594.04	-0.81	0.53	-0.85	3.5
83	Uscita short	Margin call	-235.93	-1.12	0.21	-1.11	1
84	Uscita short	TP/SL	-894.71	-1.22	0.21	-1.21	3.5
85	Uscita short	TP/SL	77.16	0.08	1.77	-0.04	4.5
86	Uscita short	TP/SL	2026.96	2.19	2.20	-0.01	4.5
87	Uscita short	Margin call	-175.23	-2.17	0.43	-2.16	0.4
88	Uscita short	TP/SL	-1833.4	-2.12	0.43	-2.16	4.3
89	Uscita short	Margin call	-181.42	-0.91	0.11	-0.90	1
90	Uscita short	TP/SL	-571.34	-0.77	1.39	-1.14	3.7
91	Uscita short	TP/SL	24.87	0.03	2.26	-0.27	4.7
92	Uscita short	Margin call	-106.96	-1.38	1.13	-1.37	0.4
93	Uscita short	TP/SL	-821.46	-0.96	1.13	-1.37	4.4
94	Uscita short	TP/SL	-1067.72	-1.18	0.66	-1.17	4.7
95	Uscita short	TP/SL	1132.77	1.26	1.27	-0.14	4.5
96	Uscita short	TP/SL	1424.38	1.57	1.58	-0.21	4.7
97	Uscita short	Margin call	-282.62	-1.49	0.12	-1.48	1
98	Uscita short	TP/SL	-1001.19	-1.35	0.12	-1.48	3.9
99	Uscita short	Margin call	-224.24	-1.21	0.24	-1.20	1
100	Uscita short	TP/SL	2037.88	2.81	2.82	-1.20	3.9
101	Uscita short	Margin call	-117.83	-1.66	0.00	-1.65	0.4
102	Uscita short	TP/SL	4729.26	5.45	5.46	-1.65	4.9
103	Uscita short	Margin call	-230.84	-1.28	0.52	-1.27	1
104	Uscita short	TP/SL	-1886.98	-2.37	0.52	-2.36	4.4
105	Uscita short	Margin call	-224.66	-1.24	0.06	-1.23	1
106	Uscita short	TP/SL	2534.52	3.24	3.25	-1.23	4.3
107	Uscita short	TP/SL	-302.11	-0.31	0.57	-0.31	4.2
108	Uscita short	TP/SL	-488.78	-0.50	1.75	-0.49	4
109	Uscita short	Margin call	-143.25	-0.57	0.39	-0.56	1
110	Uscita short	TP/SL	1166.1	1.60	1.61	-0.56	2.9
111	Uscita short	Margin call	-300.27	-1.21	0.45	-1.20	1
112	Uscita short	TP/SL	-892.12	-1.20	0.45	-1.20	3
113	Uscita short	TP/SL	1454.72	1.48	1.49	-0.08	3.9
114	Uscita short	TP/SL	1662.31	1.70	1.71	-0.89	3.9
115	Uscita short	Margin call	-353.81	-1.45	0.31	-1.44	1
116	Uscita short	TP/SL	-1030.15	-1.36	0.31	-1.44	3.1
117	Uscita short	TP/SL	-20.35	-0.02	1.99	-0.01	4.1
118	Uscita short	TP/SL	-437.12	-0.44	0.35	-0.43	3.9
119	Uscita short	Margin call	-195.92	-0.77	0.28	-0.76	1
120	Uscita short	TP/SL	-595.43	-0.80	0.28	-0.79	2.9
121	Uscita short	Margin call	-129.86	-0.51	0.48	-0.50	1
122	Uscita short	TP/SL	-405.3	-0.55	0.48	-0.54	2.9
123	Uscita short	TP/SL	-478.44	-0.49	0.67	-0.48	3.9
124	Uscita short	TP/SL	-319.22	-0.33	0.20	-0.32	3.8
125	Uscita short	TP/SL	78.67	0.08	0.65	-0.04	3.8
126	Uscita short	TP/SL	-99.45	-0.10	0.50	-0.32	3.8
127	Uscita short	TP/SL	-735.91	-0.77	0.12	-0.76	3.8
128	Uscita short	Margin call	-100.28	-0.40	0.28	-0.39	1
129	Uscita short	TP/SL	-505.64	-0.71	0.28	-0.70	2.8
130	Uscita short	Margin call	-67.25	-0.27	0.00	-0.26	1
131	Uscita short	TP/SL	873.85	1.24	1.25	-0.26	2.8
132	Uscita short	Margin call	-333.72	-1.31	0.11	-1.30	1
133	Uscita short	TP/SL	-862.18	-1.21	0.11	-1.30	2.8
134	Uscita short	TP/SL	1527.72	1.60	1.61	-0.11	3.7
135	Uscita short	Margin call	-204.06	-0.81	0.17	-0.80	1
136	Uscita short	TP/SL	1312.65	1.86	1.87	-0.80	2.8
137	Uscita short	TP/SL	1903.78	1.95	1.96	-0.30	3.9
138	Uscita short	TP/SL	-394.47	-0.40	1.57	-1.04	4
139	Uscita short	TP/SL	-163.07	-0.16	1.24	-0.17	4
140	Uscita short	Margin call	-294.54	-1.20	0.01	-1.19	1
141	Uscita short	TP/SL	-895.61	-1.22	0.01	-1.21	3
142	Uscita short	TP/SL	1364.78	1.40	1.41	-0.41	3.9
143	Uscita short	Margin call	-179.09	-0.72	0.28	-0.71	1
144	Uscita short	TP/SL	1238.59	1.66	1.67	-0.71	3
145	Uscita short	Margin call	-162.53	-1.66	0.03	-1.65	0.4
146	Uscita short	TP/SL	-1446.78	-1.60	0.03	-1.65	3.7
147	Uscita short	TP/SL	-928.81	-0.95	0.45	-0.94	4
148	Uscita short	TP/SL	76.47	0.08	1.31	-0.31	4
149	Uscita short	TP/SL	1412.66	1.45	1.46	-0.38	4
150	Uscita short	TP/SL	-92.18	-0.09	1.41	-0.43	4.1
151	Uscita short	TP/SL	377.31	0.38	1.92	-0.04	4.2
152	Uscita short	Apertura	93.38	0.09	0.41	-0.21	4.3"""

lines = data.strip().split('\n')
header = lines[0].split('\t')
rows = []
for line in lines[1:]:
    parts = line.split('\t')
    rows.append({
        'trade': int(parts[0]),
        'signal': parts[2],
        'pnl_usd': float(parts[3]),
        'pnl_pct': float(parts[4]),
        'mfe_pct': float(parts[5]),
        'mae_pct': float(parts[6]),
        'qty': float(parts[7]),
    })

df = pd.DataFrame(rows)

print("=" * 70)
print("  ANALISI TRADE LIST — PANIC HUNTER v3.5 (TradingView)")
print("=" * 70)

# Separate margin call trades
mc = df[df['signal'] == 'Margin call']
real = df[df['signal'] != 'Margin call']

print(f"\n  Trade totali:           {len(df)}")
print(f"  Di cui Margin Call:     {len(mc)} ({len(mc)/len(df)*100:.0f}%)")
print(f"  Trade reali:            {len(real)}")

print(f"\n--- MARGIN CALL (il problema) ---")
print(f"  Sempre perdenti:        {(mc['pnl_usd'] < 0).sum()}/{len(mc)}")
print(f"  P&L totale MC:          {mc['pnl_usd'].sum():.0f} USD")
print(f"  P&L medio MC:           {mc['pnl_pct'].mean():.2f}%")
print(f"  Qty media MC:           {mc['qty'].mean():.1f} (sempre ~1 contratto)")

print(f"\n--- TRADE REALI (senza MC) ---")
wins = real[real['pnl_usd'] > 0]
losses = real[real['pnl_usd'] <= 0]
print(f"  Trade:                  {len(real)}")
print(f"  Win / Loss:             {len(wins)} / {len(losses)}")
print(f"  Win Rate:               {len(wins)/len(real)*100:.1f}%")
print(f"  P&L totale:             {real['pnl_usd'].sum():.0f} USD")
print(f"  P&L medio:              {real['pnl_pct'].mean():.2f}%")
print(f"  Avg Win:                {wins['pnl_pct'].mean():.2f}%")
print(f"  Avg Loss:               {losses['pnl_pct'].mean():.2f}%")
loss_sum = abs(losses['pnl_usd'].sum())
win_sum = wins['pnl_usd'].sum()
print(f"  Profit Factor:          {win_sum/loss_sum:.2f}" if loss_sum > 0 else "  PF: inf")

# By exit type (real trades only)
print(f"\n--- PER TIPO DI EXIT ---")
for sig in real['signal'].unique():
    subset = real[real['signal'] == sig]
    avg = subset['pnl_pct'].mean()
    total = subset['pnl_usd'].sum()
    wr = (subset['pnl_usd'] > 0).sum() / len(subset) * 100
    print(f"  {sig:12s}  {len(subset):3d} trade | WR {wr:.0f}% | avg {avg:+.2f}% | tot {total:+.0f} USD")

# MFE analysis (how much profit was available)
print(f"\n--- ESCURSIONE FAVOREVOLE (MFE) ---")
print(f"  Il trade medio ha visto un massimo profitto di {real['mfe_pct'].mean():.2f}%")
print(f"  Ma il P&L medio chiuso è {real['pnl_pct'].mean():.2f}%")
print(f"  Efficienza cattura: {(real['pnl_pct'].mean() / real['mfe_pct'].mean() * 100):.0f}% del profitto disponibile")

# Trades with MFE > 1% but closed at loss
good_mfe_bad_exit = real[(real['mfe_pct'] > 1.0) & (real['pnl_pct'] < 0)]
print(f"\n  Trade con MFE > 1% ma chiusi in perdita: {len(good_mfe_bad_exit)}")
if len(good_mfe_bad_exit) > 0:
    print(f"  P&L perso su questi: {good_mfe_bad_exit['pnl_usd'].sum():.0f} USD")
    print(f"  Profitto che si poteva catturare: ~{good_mfe_bad_exit['mfe_pct'].sum():.1f}% totale")

# MC pattern analysis
print(f"\n--- PATTERN MARGIN CALL ---")
print(f"  I MC hanno sempre qty piccola ({mc['qty'].min():.1f}-{mc['qty'].max():.1f})")
print(f"  Escursione avversa media MC: {mc['mae_pct'].mean():.2f}%")
print(f"  Sono causati da default_qty_value=100 (100% equity)")
print(f"  TradingView splitta l'ordine: qty piccola → MC immediato")
print(f"  FIX: ridurre default_qty_value da 100 a 90")
