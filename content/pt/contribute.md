---
title: "Contribuir"
description: "Como submeter uma nova entrada terminfo à coleção via GitHub."
---

## Como Contribuir com uma Nova Entrada Terminfo

Recebemos com prazer arquivos fonte de terminfo de alta qualidade para terminais que faltam na base de dados ncurses do sistema ou que têm definições melhores/mais completas.

**Nota sobre o idioma:** Por favor, escreva as descrições de issues, pull requests e comentários em inglês. Isso ajuda os mantenedores a rever as contribuições de forma eficiente.

### Início Rápido (Recomendado)

A forma mais fácil de contribuir é **abrir primeiro um issue**:

→ **[Submeter um novo terminfo via GitHub Issue](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

Isto dá-nos a oportunidade de rever a entrada e dar feedback antes de abrir um pull request.

---

### Processo Manual (para contribuidores experientes)

Se preferir abrir um PR diretamente, siga estes passos:

#### 1. Crie o ficheiro `.ti`

Crie um novo ficheiro em `static/terminfo/<nome-do-terminal>.ti` com este formato de cabeçalho:

```text
# -----------------------------------------------------------------------------
# Terminal: <nome-do-terminal>
# Source:   <URL para a fonte oficial ou documentação>
# License:  <ex.: MIT, Public Domain, GPL-2.0>
# Notes:    <quaisquer capacidades especiais ou avisos>
# -----------------------------------------------------------------------------
```

Exemplo:

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Emulador de terminal Ghostty (2025+)
# -----------------------------------------------------------------------------
ghostty|Ghostty terminal emulator,
    ...
```

#### 2. Valide o ficheiro localmente

```bash
# Verificar sintaxe
tic -x static/terminfo/seu-terminal.ti

# Executar o conjunto completo de validações
contrib/run-all-checks.sh
```

#### 3. Atualize as somas de verificação

```bash
sha256sum static/terminfo/seu-terminal.ti >> static/terminfo/checksums.txt
```

Ou deixe o pre-commit hook fazê-lo por si (recomendado):

```bash
# Configuração única
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Abra um Pull Request

- Crie um ramo: `git checkout -b add-seu-terminal`
- Faça commit das alterações (o pre-commit hook ajudará)
- Abra um PR com uma descrição clara

---

### O Que Torna uma Boa Contribuição?

- A entrada **deve** compilar limpa com `tic -x`
- Prefira entradas que sejam **autoritárias** (do próprio projeto do terminal)
- Inclua o máximo possível de capacidades modernas (`XT`, `Tc`, `Su`, protocolo de teclado kitty, etc.)
- Documente a fonte claramente no cabeçalho

### Código de Conduta

Seja respeitoso e construtivo. Os emuladores de terminal evoluem rapidamente — estamos todos a tentar melhorar a vida com terminais remotos.

Dúvidas? Abra um issue ou mencione-nos no PR.
