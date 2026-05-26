---
title: "Script de Instalación"
description: "Cómo funciona el script install.sh complementario y cómo usarlo de forma segura."
---

## install.sh

Ofrecemos un script bien comentado e idempotente que detecta tu `$TERM`, descarga la entrada `.ti` correspondiente, la compila con `tic -x` y la instala en `~/.terminfo`.

### Uso rápido

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### Con nombre de terminal explícito

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### Verificar sumas de verificación

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### Qué hace el script

1. **Autoverificación**: Descarga una copia fresca de sí mismo e `install.json`, verifica su propia suma SHA-256 y vuelve a ejecutar la copia verificada (a menos que se use `--skip-self-check`).
2. Detecta tu variable de entorno `$TERM`.
3. La asocia a un archivo `.ti` de esta colección.
4. Descarga el archivo fuente a través de HTTPS.
5. Opcionalmente verifica la suma de verificación SHA-256 del archivo de terminfo.
6. Ejecuta `tic -x -o ~/.terminfo <archivo.ti>`.
7. Omite la reinstalación si la entrada ya está presente y actualizada.

### Autoverificación

Antes de hacer cualquier otra cosa, el script realiza una autoverificación:

- Descarga una copia fresca de `install.sh` e `install.json` desde el servidor.
- Verifica que la suma SHA-256 del script descargado coincida con el valor publicado en `install.json`.
- Si coinciden, vuelve a ejecutar la copia verificada y continúa.
- Si no coinciden (o falla la descarga), el script se detiene con un error.

Esto te protege en caso de que el archivo `install.sh` en el servidor (o en una caché) haya sido manipulado.

Puedes omitir la autoverificación con `--skip-self-check` (no recomendado).

### Seguridad

- El script **nunca** ejecuta `tic` con `sudo` ni privilegios elevados.
- Solo escribe en `~/.terminfo` dentro de tu directorio personal.
- Falla de forma elegante con mensajes de error claros si falta una entrada de terminfo.
- Puedes inspeccionar el script en cualquier momento antes de redirigirlo a `sh`.

[Ver el código fuente de install.sh en GitHub](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
