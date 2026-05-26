---
title: "Script d'Installation"
description: "Comment fonctionne le script d'installation complémentaire install.sh et comment l'utiliser en toute sécurité."
---

## install.sh

Nous fournissons un script bien commenté et idempotent qui détecte votre `$TERM`, télécharge l'entrée `.ti` correspondante, la compile avec `tic -x` et l'installe dans `~/.terminfo`.

### Utilisation rapide

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### Avec un nom de terminal explicite

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### Vérifier les sommes de contrôle

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### Ce que fait le script

1. **Auto-vérification** : Télécharge une copie fraîche de lui-même et de `install.json`, vérifie son propre SHA-256 et ré-exécute la copie vérifiée (sauf si `--skip-self-check` est utilisé).
2. Détecte votre variable d'environnement `$TERM`.
3. La mappe vers un fichier `.ti` de cette collection.
4. Télécharge le fichier source via HTTPS.
5. Vérifie éventuellement la somme de contrôle SHA-256 du fichier terminfo.
6. Exécute `tic -x -o ~/.terminfo <fichier.ti>`.
7. Ignore la réinstallation si l'entrée est déjà présente et à jour.

### Auto-vérification

Avant toute autre chose, le script effectue une auto-vérification :

- Il télécharge une copie fraîche de `install.sh` et `install.json` depuis le serveur.
- Il vérifie que le SHA-256 du script téléchargé correspond à la valeur publiée dans `install.json`.
- S'ils correspondent, il ré-exécute la copie vérifiée et continue.
- S'ils ne correspondent pas (ou si le téléchargement échoue), le script s'arrête avec une erreur.

Cela vous protège au cas où le fichier `install.sh` sur le serveur (ou dans un cache) aurait été altéré.

Vous pouvez contourner l'auto-vérification avec `--skip-self-check` (non recommandé).

### Sécurité

- Le script **n'exécute jamais** `tic` avec `sudo` ou des privilèges élevés.
- Il n'écrit que dans `~/.terminfo` dans votre répertoire personnel.
- Il échoue proprement avec des messages d'erreur clairs si une entrée terminfo est manquante.
- Vous pouvez inspecter le script à tout moment avant de le rediriger vers `sh`.

[Voir le code source de install.sh sur GitHub](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
