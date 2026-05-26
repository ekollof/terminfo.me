---
title: "Beitragen"
description: "Wie man einen neuen Terminfo-Eintrag über GitHub zur Sammlung beiträgt."
---

## So tragen Sie einen neuen Terminfo-Eintrag bei

Wir freuen uns über hochwertige Terminfo-Quelldateien für Terminals, die in der ncurses-Datenbank des Systems fehlen oder die bessere/kompletttere Definitionen haben.

**Hinweis zur Sprache:** Bitte verfasse Issues, Pull Requests und Kommentare auf Englisch. Das erleichtert den Maintainern die Überprüfung von Beiträgen.

### Schnellstart (Empfohlen)

Der einfachste Weg beizutragen ist, **zuerst ein Issue zu öffnen**:

→ **[Neuen Terminfo-Eintrag über ein GitHub-Issue einreichen](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

Das gibt uns die Möglichkeit, den Eintrag zu prüfen und Feedback zu geben, bevor Sie einen Pull Request öffnen.

---

### Manueller Prozess (für erfahrene Mitwirkende)

Wenn Sie lieber direkt einen PR öffnen möchten, folgen Sie diesen Schritten:

#### 1. Erstellen Sie die `.ti`-Datei

Erstellen Sie eine neue Datei in `static/terminfo/<terminal-name>.ti` mit diesem Header-Format:

```text
# -----------------------------------------------------------------------------
# Terminal: <terminal-name>
# Source:   <URL zur offiziellen Quelle oder Dokumentation>
# License:  <z. B. MIT, Public Domain, GPL-2.0>
# Notes:    <besondere Hinweise oder Einschränkungen>
# -----------------------------------------------------------------------------
```

Beispiel:

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Ghostty Terminal-Emulator (2025+)
# -----------------------------------------------------------------------------
ghostty|Ghostty Terminal-Emulator,
    ...
```

#### 2. Validieren Sie die Datei lokal

```bash
# Syntax prüfen
tic -x static/terminfo/ihr-terminal.ti

# Vollständige Validierungssuite ausführen
contrib/run-all-checks.sh
```

#### 3. Aktualisieren Sie die Prüfsummen

```bash
sha256sum static/terminfo/ihr-terminal.ti >> static/terminfo/checksums.txt
```

Oder lassen Sie den Pre-Commit-Hook das für Sie erledigen (empfohlen):

```bash
# Einmalige Einrichtung
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Öffnen Sie einen Pull Request

- Erstellen Sie einen Branch: `git checkout -b add-ihr-terminal`
- Committen Sie Ihre Änderungen (der Pre-Commit-Hook wird helfen)
- Öffnen Sie einen PR mit einer klaren Beschreibung

---

### Was macht eine gute Contribution aus?

- Der Eintrag **muss** sauber mit `tic -x` kompilieren
- Bevorzugen Sie Einträge, die **autoritativ** sind (vom Terminal-Projekt selbst)
- Fügen Sie so viele moderne Capabilities wie möglich hinzu (`XT`, `Tc`, `Su`, Kitty-Keyboard-Protokoll usw.)
- Dokumentieren Sie die Quelle klar im Header

### Verhaltenskodex

Seien Sie respektvoll und konstruktiv. Terminal-Emulatoren entwickeln sich schnell — wir versuchen alle, das Leben mit Remote-Terminals für alle besser zu machen.

Fragen? Öffnen Sie ein Issue oder erwähnen Sie uns im PR.
