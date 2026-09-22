# doppio-livello-escaping
**Àncora**: REPO-K (dashboard SD) Scripts.html escapeHtml/escapeJsAttr —
report: docs/campo/2026-08-28-repo-k-dal-dossier-a-tutti-i-fix.md §2 · **Nato**: 2026-08-28

Quando una stringa JS viene interpolata dentro un attributo HTML onclick, ci
sono DUE livelli di parsing: il parser HTML decodifica le entita dell'attributo
PRIMA che il motore JS legga il codice. Quindi entity-encodare l'apice come
&#39; SEMBRA la cura ovvia — ma NON lo e: il parser HTML lo riduce ad apice
vero e la stringa JS si rompe comunque. Servono DUE funzioni distinte:
backslash-escape per il livello JS, entity-escape per il livello HTML.
La cura ovvia e quella sbagliata: facile da ripetere perche sembra gia risolto.

**Vedi anche**: `guardia-nel-ponte-non-nella-condivisa` · `estensione-testata-non-distruttiva` · `contenitore-che-riscrive` (il confine che trasforma il dato in LETTURA: coercizione di tipo e formula injection)
