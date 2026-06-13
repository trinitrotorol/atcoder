# Command List

PowerShell では基本的に `.\m` から使います。

## よく使う流れ

```powershell
.\m create abc462
.\m use abc462
.\m -s
.\m c
.\m -t c
```

## コンテスト

| コマンド | 内容 |
| --- | --- |
| `.\m create abc462` | `contests/abc462/a.cpp` から `g.cpp` まで作る |
| `.\m init abc462` | `create` と同じ |
| `.\m use abc462` | 現在使うコンテストを `abc462` にする |
| `.\m current` | 現在使うコンテストを表示する |

`create` / `init` は既存ファイルを上書きしません。作成後、そのコンテストが current になります。

作られる `.cpp` には `import std;`、`debug(x)` マクロ、空の `main()` が入ります。

`-c` は `-C` と紛らわしいので使いません。コンテスト作成は `create` / `init`、コンテスト指定は `-C` です。

## 実行とビルド

| コマンド | 内容 |
| --- | --- |
| `.\m a` | current contest の `a.cpp` をビルドして実行する |
| `.\m c` | current contest の `c.cpp` をビルドして実行する |
| `.\m c -C abc461` | `abc461/c.cpp` を実行する |
| `.\m -r c` | `c.cpp` を実行する |
| `.\m -b c` | `c.cpp` をビルドする |
| `.\m -l c` | 使われるパスを表示する |
| `.\m -x` | ビルド成果物を削除する |

入力ファイルを指定する場合:

```powershell
.\m c -i contests/abc462/sample/c_1.in
```

## Debug

| コマンド | 内容 |
| --- | --- |
| `.\m debug` | debug状態を表示する |
| `.\m debug on` | ローカルビルドで `-DLOCAL` を付ける |
| `.\m debug off` | `-DLOCAL` を外す |
| `.\m debug toggle` | debug on/off を切り替える |

debug on の間は、PowerShellプロンプトにも `[DEBUG]` が表示されます。

```text
PS C:\workspace\atcoder [abc462] [DEBUG]>
```

コード側では次のように使います。

```cpp
#ifdef LOCAL
std::cerr << "debug value = " << value << '\n';
#endif
```

## サンプル

| コマンド | 内容 |
| --- | --- |
| `.\m -s` | current contest の全問題サンプルを取得する |
| `.\m -s c` | `c` 問題のサンプルだけ取得する |
| `.\m -t c` | `c` 問題の全サンプルを実行して `.out` と比較する |

コンテスト中など、問題ページがログイン必須で404になる場合は、AtCoderの `REVEL_SESSION` を `.atcoder-cookie` に保存します。このファイルはGit管理外です。

```text
REVEL_SESSION=your_session_value
```

または環境変数でも指定できます。

```powershell
$env:ATCODER_REVEL_SESSION = "your_session_value"
.\m -s
```

URL を直接指定する場合:

```powershell
.\m -s -U https://atcoder.jp/contests/abc461/tasks/abc461_c
```

## セットアップとヘルプ

| コマンド | 内容 |
| --- | --- |
| `.\scripts\setup-wsl.ps1` | 初回セットアップ |
| `.\m -u` | WSL 側セットアップを実行する |
| `.\m -h` | ヘルプを表示する |

## オプション

| オプション | 内容 |
| --- | --- |
| `-p`, `--problem` | 問題を指定する |
| `-C`, `--contest` | コンテストを指定する |
| `-i`, `--input` | 入力ファイルを指定する |
| `-o`, `--out` | 出力バイナリのパスを指定する |
| `-U`, `--url` | サンプル取得URLを指定する |

Makefile 変数を直接渡す形も使えます。

```powershell
.\m test PROBLEM=c CONTEST=abc461
```

## PowerShell Prompt

PowerShell のプロンプトに current contest を表示する設定:

```powershell
.\scripts\install-atcoder-prompt.ps1
```

このリポジトリ配下では次のように表示されます。

```text
PS C:\workspace\atcoder [abc462]>
```

反映されない場合:

```powershell
. $PROFILE
```
