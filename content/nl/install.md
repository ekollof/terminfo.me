---
title: "Installatiescript"
description: "Hoe het bijbehorende installatiescript install.sh werkt en hoe je het veilig gebruikt."
---

## install.sh

We bieden een goed becommentarieerd en idempotent script dat je `$TERM`-variabele detecteert, het bijbehorende `.ti`-bestand downloadt, het compileert met `tic -x` en installeert in `~/.terminfo`.

### Snel gebruik

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### Met expliciete terminalnaam

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### Controlesommen verifiëren

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### Wat het script doet

1. **Zelfcontrole**: Downloadt een verse kopie van zichzelf en `install.json`, controleert zijn eigen SHA-256 en voert de geverifieerde kopie opnieuw uit (tenzij je `--skip-self-check` gebruikt).
2. Detecteert je omgevingsvariabele `$TERM`.
3. Koppelt deze aan een `.ti`-bestand uit deze collectie.
4. Downloadt het bronbestand via HTTPS.
5. Controleert optioneel de SHA-256-controlesom van het terminfo-bestand.
6. Voert `tic -x -o ~/.terminfo <bestand.ti>` uit.
7. Slaat herinstallatie over als de vermelding al aanwezig en up-to-date is.

### Zelfcontrole

Voordat het iets anders doet, voert het script een zelfcontrole uit:

- Het downloadt een verse kopie van `install.sh` en `install.json` van de server.
- Het controleert of de SHA-256 van het gedownloade script overeenkomt met de waarde die is gepubliceerd in `install.json`.
- Als ze overeenkomen, voert het de geverifieerde kopie opnieuw uit en gaat verder.
- Als ze niet overeenkomen (of de download mislukt), stopt het script met een foutmelding.

Dit beschermt je als het `install.sh`-bestand op de server (of in de cache) is aangepast.

Je kunt de zelfcontrole overslaan met `--skip-self-check` (niet aanbevolen).

### Veiligheid

- Het script voert `tic` **nooit** uit met `sudo` of verhoogde rechten.
- Het schrijft alleen naar `~/.terminfo` in je thuismap.
- Het faalt netjes met duidelijke foutmeldingen als een terminfo-vermelding ontbreekt.
- Je kunt het script op elk moment inspecteren voordat je het doorgeeft aan `sh`.

[Bekijk de broncode van install.sh op GitHub](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
