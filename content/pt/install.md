---
title: "Script de Instalação"
description: "Como o script complementar de instalação install.sh funciona e como usá-lo com segurança."
---

## install.sh

Fornecemos um script bem comentado e idempotente que detecta sua variável `$TERM`, baixa a entrada `.ti` correspondente, compila com `tic -x` e instala em `~/.terminfo`.

### Uso rápido

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### Com nome de terminal explícito

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### Verificar checksums

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### O que o script faz

1. **Auto-verificação**: Baixa uma cópia fresca de si mesmo e do `install.json`, verifica seu próprio SHA-256 e re-executa a cópia verificada (a menos que use `--skip-self-check`).
2. Detecta sua variável de ambiente `$TERM`.
3. Mapeia para um arquivo `.ti` nesta coleção.
4. Baixa o arquivo fonte via HTTPS.
5. Opcionalmente verifica o checksum SHA-256 do arquivo terminfo.
6. Executa `tic -x -o ~/.terminfo <arquivo.ti>`.
7. Pula a reinstalação se a entrada já estiver presente e atualizada.

### Auto-verificação

Antes de fazer qualquer outra coisa, o script realiza uma auto-verificação:

- Baixa uma cópia fresca de `install.sh` e `install.json` do servidor.
- Verifica se o SHA-256 do script baixado corresponde ao valor publicado em `install.json`.
- Se corresponderem, re-executa a cópia verificada e continua.
- Se não corresponderem (ou o download falhar), o script aborta com erro.

Isso o protege caso o arquivo `install.sh` no servidor (ou em cache) tenha sido adulterado.

Você pode pular a auto-verificação com `--skip-self-check` (não recomendado).

### Segurança

- O script **nunca** executa `tic` com `sudo` ou privilégios elevados.
- Escreve apenas em `~/.terminfo` no seu diretório home.
- Falha de forma limpa com mensagens de erro claras se uma entrada terminfo estiver faltando.
- Você pode inspecionar o script a qualquer momento antes de redirecioná-lo para `sh`.

[Ver código-fonte do install.sh no GitHub](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
