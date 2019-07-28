# 事前準備

LLVMのインストールには時間がかかります。事前にセットアップを行いましょう。

## 0. 環境構築

Homebrewがインストールされていない場合、[公式の手順](https://brew.sh/index_ja)に従ってインストールしてください。
`pkg-config` がインストールされていない場合、 インストールしてください。

```console
$ brew install pkg-config`
```

## 1. Xcodeのインストール

- Mojaveの場合: Mac App Store からインストールできる Xcode 10.3 で大丈夫です
- Catalina betaの場合: Developer Center から Xcode 11 を利用する必要があります

## 2. Command Line Toolsのインストール

Xcode 10.3を起動して、GUIからインストールしてください

インストール完了後、Terminalから以下を実行してバージョンを確認してください。

```console
$ swift --version
Apple Swift version 4.2 (swiftlang-1000.11.37.1 clang-1000.11.45.1)
Target: x86_64-apple-darwin18.2.0
$ clang --version
Apple LLVM version 10.0.0 (clang-1000.11.45.5)
Target: x86_64-apple-darwin18.2.0
Thread model: posix
InstalledDir: /Applications/Xcode-10.1.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

## 3. LLVMのインストール

```console
$ brew install llvm@7
```

LLVMをインストールしたらパスを通してください。以後、パスが通ってることを前提としています。

```console
$ export PATH="$PATH:`brew --prefix llvm@7`/bin"
```

インストールされたLLVMのバージョンが7.0.1であることを確認してください。

```console
$ lli --version
LLVM (http://llvm.org/):
  LLVM version 7.0.1
  Optimized build.
  Default target: x86_64-apple-darwin18.2.0
  Host CPU: skylake-avx512
```

## 4. プロジェクトのセットアップ

```console
$ which llvm-config
/usr/local/opt/llvm@7/7.0.1/bin/llvm-config
$ git clone https://github.com/giginet/MinSwift-workshop.git
$ cd MinSwift-workshop
$ ./bootstrap
```

この操作で`MinSwift.xcodeproj`が自動生成されます。

<details><summary>`xcrun: error: unable to find utility "xctest", not a developer tool or in PATH` というエラーが出た場合は…</summary>
<p>

`xcode-select` でdeveloper directoryへのpathが通っていない可能性があります。

```console
$ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
$ xcode-select -p
/Applications/Xcode.app/Contents/Developer
```

Xcode betaのユーザーはpathを読み替えてください。

</p>
</details>

## 5. CLIからのビルド

```console
$ swift run -Xlinker -L`llvm-config --libdir` -Xcc -I`llvm-config --includedir` -Xlinker -lLLVM
; ModuleID = 'main'
source_filename = "main"

define [32 x i8] @sayGreeting() {
entry:
  ret [32 x i8] c"Welcome to the Underground \F0\9F\98\88\00"
}
Welcome to the Underground 😈
```

## 6. Xcodeからのビルド

```
$ open MinSwift.xcodeproj
```

ビルドターゲットを`minswift`に変更してCmd + Rでビルドが通ることを確認してください。

コンソールに5と同様の出力がされたら成功です。

## 7. graphvizのインストール

プロジェクトのビルドには用いませんが、ワークショップの中で生成したLLVM IRの可視化に利用します。

```console
$ brew install graphviz
$ which dot
/usr/local/bin/dot
```
