---
title: "Contribuir"
description: "Cómo enviar una nueva entrada de terminfo a la colección a través de GitHub."
---

## Cómo Contribuir una Nueva Entrada de Terminfo

Damos la bienvenida a archivos fuente de terminfo de alta calidad para terminales que faltan en la base de datos de ncurses del sistema o que tienen definiciones mejores o más completas.

**Nota sobre el idioma:** Por favor, escribe las descripciones de issues, pull requests y comentarios en inglés. Esto ayuda a los mantenedores a revisar las contribuciones de forma eficiente.

### Inicio Rápido (Recomendado)

La forma más fácil de contribuir es **abrir primero un issue**:

→ **[Enviar un nuevo terminfo mediante un Issue de GitHub](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

Esto nos da la oportunidad de revisar la entrada y dar retroalimentación antes de que abras un pull request.

---

### Proceso Manual (para colaboradores experimentados)

Si prefieres abrir un PR directamente, sigue estos pasos:

#### 1. Crea el archivo `.ti`

Crea un nuevo archivo en `static/terminfo/<nombre-del-terminal>.ti` con este formato de encabezado:

```text
# -----------------------------------------------------------------------------
# Terminal: <nombre-del-terminal>
# Source:   <URL a la fuente oficial o documentación>
# License:  <por ejemplo MIT, Public Domain, GPL-2.0>
# Notes:    <cualquier consideración especial o advertencia>
# -----------------------------------------------------------------------------
```

Ejemplo:

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Emulador de terminal Ghostty (2025+)
# -----------------------------------------------------------------------------
ghostty|Emulador de terminal Ghostty,
    ...
```

#### 2. Valida el archivo localmente

```bash
# Verificar sintaxis
tic -x static/terminfo/tu-terminal.ti

# Ejecutar el conjunto completo de validación
contrib/run-all-checks.sh
```

#### 3. Actualiza las sumas de verificación

```bash
sha256sum static/terminfo/tu-terminal.ti >> static/terminfo/checksums.txt
```

O deja que el hook de pre-commit lo haga por ti (recomendado):

```bash
# Configuración única
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Abre un Pull Request

- Crea una rama: `git checkout -b add-tu-terminal`
- Haz commit de tus cambios (el hook de pre-commit ayudará)
- Abre un PR con una descripción clara

---

### ¿Qué Hace una Buena Contribución?

- La entrada **debe** compilar limpiamente con `tic -x`
- Prefiere entradas que sean **autoritativas** (del propio proyecto del terminal)
- Incluye tantas capacidades modernas como sea posible (`XT`, `Tc`, `Su`, protocolo de teclado kitty, etc.)
- Documenta claramente la fuente en el encabezado

### Código de Conducta

Sé respetuoso y constructivo. Los emuladores de terminal evolucionan rápidamente — todos estamos tratando de hacer que la vida con terminales remotos sea mejor para todos.

¿Preguntas? Abre un issue o menciónanos en el PR.
