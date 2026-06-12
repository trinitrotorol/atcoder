# AtCoder C++23 / GCC Environment

AtCoder の C++23 (GCC 15.2.0) に寄せた、WSL + micromamba の隔離環境です。

- C++ 標準: `-std=gnu++23`
- コンパイラ: `gxx_linux-64=15.2.0` from conda-forge
- ACL: `atcoder/ac-library` v1.6
- Boost headers: `libboost-headers=1.88.0`
- `import std;` は初回ビルド時に `gcm.cache/std.gcm` を自動生成します。

## 初回セットアップ

Windows の PowerShell から実行します。

```powershell
.\scripts\setup-wsl.ps1
```

作成されるもの:

- `.tools/micromamba/bin/micromamba`
- `.micromamba/envs/atcoder-cpp23`
- `third_party/ac-library`

## ビルドと実行

PowerShell から短く使う場合:

```powershell
.\m c
```

これは `contests` の中で名前順が最後のコンテスト、たとえば `contests/abc461/c.cpp` をコンパイルして実行します。

コンテストを明示する場合:

```powershell
.\m c -C abc461
```

入力ファイルを渡す場合:

```powershell
.\m c -i contests/abc461/sample/c_2.in
```

AtCoder のコンテストページから全問題のサンプルを取得する場合:

```powershell
.\m -s
```

これは AtCoder 用の micromamba 環境内の Python で動き、`https://atcoder.jp/contests/<CONTEST>/tasks` から各問題ページを見つけてサンプルを取得します。保存先は `contests/<CONTEST>/sample/` です。

特定の問題だけ取得する場合:

```powershell
.\m -s c
```

URL を直接指定する場合:

```powershell
.\m -s -U https://atcoder.jp/contests/abc461/tasks/abc461_c
```

保存されるファイル:

```text
c_1.in     # 入力例1
c_1.out
c_2.in     # 入力例2
c_2.out
...
```

`.\m c` は入力指定がない場合、`c_1.in` のような最初のサンプル入力を自動で使います。

全サンプルを期待出力と比較する場合:

```powershell
.\m -t c
```

パスの確認やビルドだけを行う場合:

```powershell
.\m -l c
.\m -b c
```

よく使う短縮コマンド:

```text
.\m c                 # c.cpp をビルドして最初のサンプルで実行
.\m -r c              # c.cpp を実行
.\m -b c              # c.cpp をビルド
.\m -t c              # c の全サンプルをテスト
.\m -s                # 現在のコンテストの全サンプルを取得
.\m -s c              # c のサンプルだけ取得
.\m -l c              # 使われるファイルパスを確認
.\m -u                # 初回セットアップ
.\m -x                # ビルド成果物を削除
```

主なオプションは `-p/--problem`, `-C/--contest`, `-i/--input`, `-o/--out`, `-U/--url` です。従来通り `PROBLEM=c` や `CONTEST=abc461` のような Makefile 変数も渡せます。

PowerShell から:

```powershell
wsl -d Ubuntu -- bash -lc "cd /mnt/c/workspace/atcoder && ./scripts/run.sh"
```

WSL のシェルから:

```bash
./scripts/run.sh
```

入力ファイルを渡す場合:

```bash
./scripts/run.sh Main.cpp sample/input.txt
```

追加のリンクオプションが必要な場合:

```bash
ATCODER_EXTRA_FLAGS="-lgmpxx -lgmp" ./scripts/run.sh
```

`oj` が必要な場合は、環境作成後に次で追加できます。

```bash
.tools/micromamba/bin/micromamba run -n atcoder-cpp23 python -m pip install online-judge-tools
```

## VS Code

`Terminal > Run Task...` から以下を使えます。

- `AtCoder: setup WSL env`
- `AtCoder: build`
- `AtCoder: run`

IntelliSense は WSL 側でワークスペースを開くと一番安定します。

## Dev Container

Docker Desktop を入れている場合は、Dev Containers でも使えます。ベースは Docker Official Image の `gcc:15.2.0` です。

## 参考

- AtCoder: https://atcoder.jp/posts/1579?lang=ja
- Language list: https://img.atcoder.jp/file/language-update/2025-10/language-list.html
- conda-forge gcc_linux-64: https://prefix.dev/channels/conda-forge/packages/gcc_linux-64
- Docker Official Image for GCC: https://hub.docker.com/_/gcc
