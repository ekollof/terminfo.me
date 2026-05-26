---
title: "インストールスクリプト"
description: "install.sh コンパニオンスクリプトの仕組みと安全な使い方について。"
---

## install.sh

私たちは、`$TERM` を検出し、対応する `.ti` ソースをダウンロードし、`tic -x` でコンパイルして `~/.terminfo` にインストールする、よくコメントされた冪等なスクリプトを提供しています。

### 簡単な使い方

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### 端末名を明示的に指定する場合

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### チェックサムの検証

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### スクリプトの動作

1. **自己検証**: 自身と `install.json` の最新コピーをダウンロードし、自分の SHA-256 を検証してから検証済みコピーを再実行します（`--skip-self-check` を指定しない場合）。
2. `$TERM` 環境変数を検出します。
3. このコレクション内の `.ti` ファイルにマッピングします。
4. HTTPS でソースをダウンロードします。
5. 必要に応じて terminfo ファイルの SHA-256 チェックサムを検証します。
6. `tic -x -o ~/.terminfo <file.ti>` を実行します。
7. エントリがすでに存在して最新の場合は再インストールをスキップします。

### 自己検証

スクリプトは他の処理を行う前に自己検証を行います：

- サーバーから `install.sh` と `install.json` の最新コピーをダウンロードします。
- ダウンロードしたスクリプトの SHA-256 が `install.json` に公開されている値と一致することを確認します。
- 一致すれば検証済みコピーを再実行して続行します。
- 一致しない場合（またはダウンロードに失敗した場合）はエラーで中止します。

これはサーバー上の `install.sh`（またはキャッシュ）が改ざんされている場合にあなたを守るためのものです。

`--skip-self-check` で自己検証をスキップできます（非推奨）。

### 安全性

- スクリプトは **絶対に** `sudo` や昇格した権限で `tic` を実行しません。
- ホームディレクトリの `~/.terminfo` にのみ書き込みます。
- terminfo エントリが見つからない場合は明確なエラーメッセージで安全に失敗します。
- `sh` にパイプする前にいつでもスクリプトを確認できます。

[GitHub で install.sh のソースを表示](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
