# Practice2 ASTの生成1 定数と変数

ここからパーサーを本格的に実装していきましょう！

パーサーの役目は、Swiftのソースコードを読み取って、AST(Abstract Syntax Tree)に変換することです。

ソースコードをASTの形で保持しておき、後ほどそこからLLVM IRを生成していきます。
MinSwiftでは、定数、変数や関数宣言などを扱うことができます。

## Node

MinSwiftでは、全てのASTは以下のプロトコルに適合しています。

```swift
protocol Node { }
```

`Node`は全てのASTの基底となるプロトコルですが、何も宣言を持ちません。

今回利用するノードは、`ASTNode.swift`に全て予め用意しておきました。

## 2-1. `integerLiteral`のパース

まず非常に単純なただの数値リテラルをASTに変換してみましょう。

MinSwiftでは、`42`のような数値表現は`NumberNode`として表現されます。

```swift
42 // NumberNode(value: 42)
```

SwiftSyntaxでは、整数リテラルは`.integerLiteral`という`tokenKind`で表されます。

`parseNumber`メソッドを実装して、現在のカーソルから数値（整数リテラル、または浮動小数点リテラル）を読み取り、`NumberNode`を返却してみましょう。

これから、特定のトークン列をパースし、該当するASTを返す処理は、全て`parse~`メソッドに実装していきます。
MinSwiftでは、`parse~`系のメソッドは、全て以下の処理を期待することとします。

- `parse~`は`cuttentToken`からトークン列を読み取って、AST(`Node`)を構築して返却する
- `parse~`メソッドが呼び出される時点で、`currentToken`が該当するトークンになっていることを期待している
    - 例えば、今回実装する`parseNumber`は、呼び出された時点でカーソルが整数リテラルか浮動小数点リテラルであることを期待している
- `parse~`はASTを返却したあと、該当するトークンを全て消費する
-   - すなわち、読み取りが終わった後は`parse~`内で`read()`を行って、カーソルを進めること

文章だけでパッと理解するのは難しいと思うので、サンプルのための実装を用意しておきました。`parseNumber`メソッドです。
`parseNumber`は完成されていますが、内部で、`TokenSyntax`を`Double`に変換する`extractNumberLiteral`を呼び出しています。

`extractNumberLiteral`を実装して、テストケースを通してみましょう。

## 2-2. `floatingLiteral`のパース

2-1のテストケースは整数リテラルが来た場合をテストしています。
浮動小数点リテラル(`.floatingLiteral`)が来た場合も正しくパースできるように、`extractNumberLiteral`を拡張してみましょう。

これ以上説明は必要ありませんよね？

## 2-3. `identifier`のパース

今度は変数の呼び出しを`VariableNode`で表現します。


```swift
a // VariableNode(identifier: "a")
```

今のところ、何か`tokenKind`が`.identifier`のトークンが現れたら変数呼び出しとして扱うことにしてしまいます。
`parseIdentifierExpression`を実装してみましょう。

悩ましいことに、SwiftSyntaxの世界では`.identifier`は至る所に登場します。
変数呼び出し、関数宣言における関数名、関数呼び出し、引数、ラベル、型など、ぜーんぶ`.identifier`です。

今後の実装では、この`identifier`がなんなのかを前後の文脈から判断する必要があります。
そのため、`parseIdentifierExpression`も、今後の実装が進むごとに変更が発生します。

以前までのテストケースを壊さないようにしましょう。

## まとめ

まだまだ簡単ですか？

1つ大事な補足をしておきましょう。MinSwiftでは、全ての値を`Double`として扱うことにします。
まともに型を実装するのは大変ですからね。

他にも数々の問題点があります。実は今回の実装では負数をリテラルとして扱うことができません。
Swiftでは、`-`は`.prefixOperator`として扱われるからです。

さらなるエッジケースとしては、Swiftでは`_`区切りの数字リテラルも扱えます。（`1_000`など)

そうです。Swiftの世界すべてを表現するにはあまりにも時間が足りないのです。

このような考慮漏れは今後も頻出しますが、考えないことにしてください。お腹が空いちゃいますよ！

