---
title: "Installationsskript"
description: "Wie das ergänzende Installationsskript install.sh funktioniert und wie man es sicher verwendet."
---

## install.sh

Wir stellen ein gut kommentiertes, idempotentes Skript bereit, das Ihre `$TERM`-Variable erkennt, den passenden `.ti`-Eintrag herunterlädt, ihn mit `tic -x` kompiliert und in `~/.terminfo` installiert.

### Schnelle Verwendung

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### Mit explizitem Terminalnamen

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### Prüfsummen verifizieren

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### Was das Skript macht

1. **Selbstprüfung**: Lädt eine frische Kopie von sich selbst und `install.json` herunter, überprüft seinen eigenen SHA-256 und führt die verifizierte Kopie erneut aus (außer bei `--skip-self-check`).
2. Erkennt Ihre Umgebungsvariable `$TERM`.
3. Ordnet sie einer `.ti`-Datei in dieser Sammlung zu.
4. Lädt die Quelldatei über HTTPS herunter.
5. Überprüft optional die SHA-256-Prüfsumme der Terminfo-Datei.
6. Führt `tic -x -o ~/.terminfo <datei.ti>` aus.
7. Überspringt die Neuinstallation, wenn der Eintrag bereits vorhanden und aktuell ist.

### Selbstprüfung

Bevor es etwas anderes tut, führt das Skript eine Selbstprüfung durch:

- Es lädt eine frische Kopie von `install.sh` und `install.json` vom Server herunter.
- Es überprüft, ob der SHA-256 des heruntergeladenen Skripts mit dem in `install.json` veröffentlichten Wert übereinstimmt.
- Stimmen sie überein, führt es die verifizierte Kopie erneut aus und fährt fort.
- Stimmen sie nicht überein (oder schlägt der Download fehl), bricht das Skript mit einem Fehler ab.

Dies schützt Sie, falls die `install.sh`-Datei auf dem Server (oder in einem Cache) manipuliert wurde.

Sie können die Selbstprüfung mit `--skip-self-check` umgehen (nicht empfohlen).

### Sicherheit

- Das Skript führt `tic` **niemals** mit `sudo` oder erhöhten Rechten aus.
- Es schreibt nur in `~/.terminfo` in Ihrem Home-Verzeichnis.
- Es schlägt sauber mit klaren Fehlermeldungen fehl, wenn ein Terminfo-Eintrag fehlt.
- Sie können das Skript jederzeit einsehen, bevor Sie es an `sh` weiterleiten.

[Quellcode von install.sh auf GitHub ansehen](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
