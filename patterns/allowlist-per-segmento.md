# allowlist-per-segmento
**Àncora**: night-shift/lib.sh:gate_allowlist_ok · **Nato**: 2026-08-21 (bypass di dev-critic)
Eseguire comandi generati da LLM: la blacklist è bucabile (`find -delete`, `git reset --hard`), il primo token non basta (`bash -c` è un interprete). Difesa in profondità provata: (1) allowlist per OGNI segmento (split su && || ; | CONSAPEVOLE delle virgolette — `grep -c "a;b"` è legittimo), niente interpreti general-purpose, git readonly; (2) sandbox seatbelt: rete negata + scritture solo nella copia disposabile + letture negate sui sensibili; (3) watchdog. Testato dal vivo: i 6 bypass storici bloccati, token gh illeggibile in sandbox.


**Vedi anche**: `lock-per-risorsa`
