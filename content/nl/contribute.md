---
title: "Bijdragen"
description: "Hoe je een nieuw terminfo-item via GitHub aan de collectie toevoegt."
---

## Een nieuw terminfo-item bijdragen

We verwelkomen hoogwaardige terminfo-bronbestanden voor terminals die ontbreken in de systeem-ncurses-database of die betere/volledigere definities hebben.

**Taalopmerking:** Schrijf issue-beschrijvingen, pull requests en opmerkingen in het Engels. Dit helpt de beheerders om bijdragen efficiënter te beoordelen.

### Snelle start (aanbevolen)

De eenvoudigste manier om bij te dragen is om **eerst een issue te openen**:

→ **[Dien een nieuwe terminfo in via een GitHub-issue](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

Dit geeft ons de kans om het item te beoordelen en feedback te geven voordat je een pull request opent.

---

### Handmatig proces (voor ervaren bijdragers)

Als je liever direct een PR opent, volg dan deze stappen:

#### 1. Maak het `.ti`-bestand

Maak een nieuw bestand aan in `static/terminfo/<terminal-naam>.ti` met dit koptekstformaat:

```text
# -----------------------------------------------------------------------------
# Terminal: <terminal-naam>
# Source:   <URL naar officiële bron of documentatie>
# License:  <bijv. MIT, Public Domain, GPL-2.0>
# Notes:    <eventuele speciale mogelijkheden of aandachtspunten>
# -----------------------------------------------------------------------------
```

Voorbeeld:

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Ghostty terminalemulator (2025+)
# -----------------------------------------------------------------------------
ghostty|Ghostty terminal emulator,
    ...
```

#### 2. Valideer het bestand lokaal

```bash
# Controleer de syntax
tic -x static/terminfo/jouw-terminal.ti

# Voer de volledige validatiesuite uit
contrib/run-all-checks.sh
```

#### 3. Werk de controlesommen bij

```bash
sha256sum static/terminfo/jouw-terminal.ti >> static/terminfo/checksums.txt
```

Of laat de pre-commit hook het voor je doen (aanbevolen):

```bash
# Eenmalige instelling
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Open een Pull Request

- Maak een branch: `git checkout -b add-jouw-terminal`
- Commit je wijzigingen (de pre-commit hook helpt)
- Open een PR met een duidelijke beschrijving

---

### Wat maakt een goede bijdrage?

- Het item **moet** schoon compileren met `tic -x`
- Geef de voorkeur aan items die **autoritatief** zijn (van het terminalproject zelf)
- Neem zoveel mogelijk moderne mogelijkheden op (`XT`, `Tc`, `Su`, kitty-toetsenbordprotocol, etc.)
- Documenteer de bron duidelijk in de koptekst

### Gedragsregels

Wees respectvol en constructief. Terminalemulators ontwikkelen zich snel — we proberen allemaal het leven met externe terminals beter te maken.

Vragen? Open een issue of ping ons in de PR.
