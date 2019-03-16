# Practice 1 Parserの基本

SwiftのコードをASTに変換するパーサーを実装していきましょう。

パーサーを1から書くのは非常に大変です。今回はSwiftSyntaxというライブラリを利用します。
https://github.com/apple/swift-syntax

SwiftSyntaxは、Appleが提供するSwiftのソースコードをパースするライブラリです。
静的解析ツールなどにも使われています。

まずは軽い肩慣らしに、パーサーを書くための簡単なユーティリティを準備しましょう。

## SwiftSyntax

## 1-1. `TokenSyntax`の取得

SwiftSyntaxで簡単なSwiftのコードをパースしてみましょう。

```swift
func sayHello() {
    print("Welcome to Cookpad 🍳")
}
```

ソースコードは解析され、キーワードごとにトークン(`TokenSyntax`)として分離されます。

このソースコードの解析結果は以下になります。トークンの種類は`tokenKind`プロパティで取得できます。

|token|TokenKind|
|-----|---------|
|func|funcKeyword|
|sayHello|identifier("sayHello")|
|(|leftParen|
|)|rightParen|
|{|leftBrace|
|print|identifier("print")|
|(|leftParen|
|"Welcome to Cookpad 🍳"|stringLiteral("\"Welcome to Cookpad 🍳\"")|
|)|rightParen|
|}|rightBrace|
|<EOF>|eof|

`Parser`は`SwiftSyntax.SyntaxVisitor`を継承していて、新しいトークンが来る度に`visit`が呼ばれます。
（ビジターパターンについて思い出したいときは、大学の教科書を読み返してみてください)

`Parser`は最初に全てのトークンを読み取り、扱いやすいように`tokens`に配列として保持します。

手始めに最初のテストケースを通してみましょう。

## 1-2. `seek()`の実装

多くのパーサーは状態としてカーソルを持っており、トークンを1つずつ頭から読んでいきます。
先頭のトークンを読んで返却するメソッド、`seek()`を作りましょう。

```swift
// currentToken = nil
seek()
// currentToken = funcKeyword
seek()
// currentToken = .identifier("sayHello")
seek()

// ...
```

## 1-3. `peek()`の実装

`peek()`は現在のカーソル位置を動かさずに、先のトークンを知るためのメソッドです。

```swift
seek()
// currentToken = funcKeyword
peek() // .identifier("sayHello")
peek(1) // .leftParen
peek(2) // .rightParen
```

ウォーミングアップはできましたか？
