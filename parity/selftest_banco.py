"""Banco del banco: compare.py sa dire VERDE quando deve, e ROSSO quando deve?

Un banco che non puo' diventare rosso non e' una verifica, e' una decorazione. Qui si
fabbricano due export finti nel formato di TradingView — uno coerente col porting,
uno con un'entrata tolta — e si pretende che il verdetto cambi.

ATTENZIONE su cosa NON prova: l'oracolo di questi due casi e' il porting stesso, quindi
qui si verifica solo l'impianto (lettura CSV, allineamento barre, maschera in-posizione,
verdetto). Che il porting sia FEDELE al Pine lo puo' dire solo un export vero di
TradingView: e' esattamente il compito di compare.py con i dati di Luca.

Uso: python3 parity/selftest_banco.py   ·   0 se entrambi i casi si comportano
"""

import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parent))

import pine_entry as pe

QUI = Path(__file__).parent


def mercato_in_discesa(giorni: int = 900, per_giorno: int = 6, seed: int = 5):
    """Serie giornaliera + operativa 4H con un ribasso vero: senza bear market

    il filtro non si accende e nessun segnale puo' scattare (isBearMarket, :110).
    """
    rng = np.random.default_rng(seed)
    n = giorni * per_giorno
    deriva = np.linspace(0, -0.55, n)
    rumore = np.cumsum(rng.normal(0, 0.004, n))
    close = 20000 * np.exp(deriva + rumore)
    span = close * np.abs(rng.normal(0, 0.004, n)) + close * 0.0008
    open_ = close * (1 + rng.normal(0, 0.003, n))
    vol = np.abs(rng.normal(1e6, 5e5, n)) + rng.choice([0, 3e6], n, p=[0.94, 0.06])
    idx = pd.date_range("2022-01-03", periods=n, freq="4h")
    op = pd.DataFrame(
        {
            "Open": open_,
            "High": np.maximum(open_, close) + span,
            "Low": np.minimum(open_, close) - span,
            "Close": close,
            "Volume": vol,
        },
        index=idx,
    )
    day = op.resample("1D").agg(
        {"Open": "first", "High": "max", "Low": "min", "Close": "last", "Volume": "sum"}
    ).dropna()
    return op, day


def scrivi_barre(df: pd.DataFrame, percorso: Path) -> None:
    fuori = df.reset_index(names="time")
    fuori["time"] = fuori["time"].dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    fuori.rename(columns=str.lower).to_csv(percorso, index=False)


def scrivi_trade(entrate, uscite, percorso: Path) -> None:
    """Formato 'List of Trades': una riga entrata e una uscita per operazione."""
    righe = []
    for i, (e, u) in enumerate(zip(entrate, uscite), start=1):
        righe.append({"Trade #": i, "Type": "Entry short", "Signal": "Short", "Date/Time": e})
        righe.append({"Trade #": i, "Type": "Exit short", "Signal": "TP/SL", "Date/Time": u})
    pd.DataFrame(righe).to_csv(percorso, index=False)


def segnali_e_uscite(op: pd.DataFrame, day: pd.DataFrame, tieni_ogni: int = 1):
    """Entrate simulando `not inShort`: dopo una entrata si resta dentro 5 barre."""
    comp = pe.short_ok(op, day)
    candidate = list(comp.index[comp["short_ok"]])
    entrate, uscite, libero_da = [], [], None
    for t in candidate:
        if libero_da is not None and t <= libero_da:
            continue
        pos = op.index.get_loc(t)
        fine = op.index[min(pos + 5, len(op) - 1)]
        entrate.append(t)
        uscite.append(fine)
        libero_da = fine
    return entrate[::tieni_ogni], uscite[::tieni_ogni], comp


def esegui(bars: Path, daily: Path, trades: Path):
    r = subprocess.run(
        [sys.executable, str(QUI / "compare.py"), "--bars", str(bars),
         "--daily", str(daily), "--trades", str(trades)],
        capture_output=True, text=True, cwd=QUI,
    )
    return r.returncode, r.stdout + r.stderr


def main() -> int:
    op, day = mercato_in_discesa()
    entrate, uscite, comp = segnali_e_uscite(op, day)
    print(f"mercato sintetico: {len(op)} barre 4H, {len(day)} giornaliere")
    print(f"  filtro bear pronto da barra {int(comp['htf_pronto'].argmax())}")
    print(f"  barre in bear market: {int(comp['is_bear'].sum())}")
    print(f"  entrate generate: {len(entrate)}\n")
    if len(entrate) < 5:
        print("ROSSO: il mercato sintetico non produce abbastanza entrate per provare il banco")
        return 1

    esiti = []
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        scrivi_barre(op, d / "4h.csv")
        scrivi_barre(day, d / "day.csv")

        scrivi_trade(entrate, uscite, d / "uguali.csv")
        code, out = esegui(d / "4h.csv", d / "day.csv", d / "uguali.csv")
        ok = code == 0 and "VERDE" in out
        esiti.append(ok)
        print(f"  [{'OK ' if ok else 'ROSSO'}] caso coerente -> atteso VERDE, esito {out.strip().splitlines()[-1]}")

        scrivi_trade(entrate[:-1], uscite[:-1], d / "una_meno.csv")
        code, out = esegui(d / "4h.csv", d / "day.csv", d / "una_meno.csv")
        ultima = out.strip().splitlines()[-1]
        ok = code == 1 and "ROSSA" in ultima and " 1 barre divergenti" in ultima
        esiti.append(ok)
        print(f"  [{'OK ' if ok else 'ROSSO'}] un'entrata tolta -> attesa 1 divergenza, esito {ultima}")

        spostate = list(entrate)
        pos = op.index.get_loc(spostate[3])
        spostate[3] = op.index[pos + 1]
        scrivi_trade(spostate, uscite, d / "spostata.csv")
        code, out = esegui(d / "4h.csv", d / "day.csv", d / "spostata.csv")
        ultima = out.strip().splitlines()[-1]
        ok = code == 1 and " 2 barre divergenti" in ultima
        esiti.append(ok)
        print(f"  [{'OK ' if ok else 'ROSSO'}] un'entrata spostata di una barra -> attese 2 divergenze, esito {ultima}")

    rossi = esiti.count(False)
    print(f"\nbanco del banco: {len(esiti) - rossi}/{len(esiti)} verdi")
    return 1 if rossi else 0


if __name__ == "__main__":
    sys.exit(main())
