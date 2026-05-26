---
title: "Contribuer"
description: "Comment soumettre une nouvelle entrée terminfo à la collection via GitHub."
---

## Comment Contribuer une Nouvelle Entrée Terminfo

Nous accueillons favorablement les fichiers sources terminfo de haute qualité pour les terminaux absents de la base de données ncurses du système ou qui disposent de définitions meilleures ou plus complètes.

**Note sur la langue :** Veuillez rédiger les descriptions d'issues, les pull requests et les commentaires en anglais. Cela aide les mainteneurs à examiner les contributions plus efficacement.

### Démarrage Rapide (Recommandé)

La façon la plus simple de contribuer est d'**ouvrir d'abord une issue** :

→ **[Soumettre un nouveau terminfo via une Issue GitHub](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

Cela nous donne l'occasion d'examiner l'entrée et de fournir des retours avant que vous n'ouvriez une pull request.

---

### Processus Manuel (pour les contributeurs expérimentés)

Si vous préférez ouvrir directement une PR, suivez ces étapes :

#### 1. Créez le fichier `.ti`

Créez un nouveau fichier dans `static/terminfo/<nom-du-terminal>.ti` avec cet en-tête :

```text
# -----------------------------------------------------------------------------
# Terminal: <nom-du-terminal>
# Source:   <URL vers la source officielle ou la documentation>
# License:  <ex: MIT, Public Domain, GPL-2.0>
# Notes:    <toute considération spéciale ou avertissement>
# -----------------------------------------------------------------------------
```

Exemple :

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Émulateur de terminal Ghostty (2025+)
# -----------------------------------------------------------------------------
ghostty|Émulateur de terminal Ghostty,
    ...
```

#### 2. Validez le fichier localement

```bash
# Vérifier la syntaxe
tic -x static/terminfo/votre-terminal.ti

# Exécuter la suite complète de validation
contrib/run-all-checks.sh
```

#### 3. Mettez à jour les sommes de contrôle

```bash
sha256sum static/terminfo/votre-terminal.ti >> static/terminfo/checksums.txt
```

Ou laissez le hook de pre-commit le faire pour vous (recommandé) :

```bash
# Configuration unique
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Ouvrez une Pull Request

- Créez une branche : `git checkout -b add-votre-terminal`
- Committez vos changements (le hook de pre-commit vous aidera)
- Ouvrez une PR avec une description claire

---

### Qu'est-ce qui fait une bonne contribution ?

- L'entrée **doit** compiler proprement avec `tic -x`
- Préférez les entrées **autoritatives** (provenant du projet du terminal lui-même)
- Incluez autant de capacités modernes que possible (`XT`, `Tc`, `Su`, protocole clavier kitty, etc.)
- Documentez clairement la source dans l'en-tête

### Code de Conduite

Soyez respectueux et constructif. Les émulateurs de terminal évoluent rapidement — nous essayons tous de rendre la vie avec les terminaux distants meilleure pour tout le monde.

Des questions ? Ouvrez une issue ou mentionnez-nous dans la PR.
