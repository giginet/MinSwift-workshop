# 事前準備

LLVMのインストールには時間がかかります。事前にセットアップを行いましょう。

## 1. Xcode 10.1のインストール

Mac App Storeからで大丈夫です

## 2. Command Line Toolsのインストール

Xcode 10.1を起動して、GUIからインストールしてください

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

```
$ brew install llvm
```

## 4. プロジェクトのセットアップ

```console
$ export PATH="$PATH:`brew --prefix llvm`/bin"
$ which llvm-config
/usr/local/Cellar/llvm/7.0.1/bin/llvm-config
$ git clone https://github.com/giginet/MinSwift-workshop.git
$ cd MinSwift-workshop
$ ./bootstrap
```

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

Cmd + Rでビルドが通ることを確認してください。

