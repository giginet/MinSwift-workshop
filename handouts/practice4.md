# Practice 4 ASTの生成3 関数宣言

関数宣言をパースしていきます。ここからネスト構造が登場します。

## 4-1. 引数のパース

まず引数をパースするための簡単なユーティリティ、`parseFunctionDefinitionArgument`を実装してみましょう。

この関数は、`a: Double`という文字列から`FunctionNode.Argument`を生成します。

まずは`func foo(a: Double)`という関数定義の`a: Double`という部分をパースすることのみを考えましょう。

`parseFunctionDefinitionArgument`は`identifier("a"), colon, .identifier("Double")`というトークン列を受け取って適切な引数を生成します。

このノードは、ラベルと変数名を持ちますが、ラベルを省略した場合は変数名と同じものとして扱います。（この場合は両方とも`a`）

Swiftでは、ラベルを省略したり（`_ a: Double`）、ラベルと変数名に別名を付けたりできます（`label variableName: Double`）
今回はこのようなケースは省略しましょう。（物足りない方向けに応用課題を用意しておきました）

## 4-2〜4-4. 関数宣言のパース

いよいよ関数宣言をパースしていきます。`FunctionNode`です。

難しそうに見えますが、頭から順番に読んでいけば恐るるに足りません！

何個かポイントを紹介しておきます。

### 引数のパース

引数のパースは`parseFunctionDefinitionArgument`を使います。`,`(`.comma`)が来る度に次々と読んでいき、`)`(`.rightParen`)が現れたら終了します。

### 関数ブロックのパース

関数本体の表現として、`FunctionNode.body`はさらに`Node`を保持します。
ちょっと怯んでしまいませんでしたか？

実は`{`が現れたあとに再帰的に`parseExpression`を呼び出すだけで良いのです。驚きました？

### 戻り値の型のパース

MinSwiftでは戻り値の型は何の意味も成しません。常に`Double`を返す関数として扱われています。
よって、`-> Double`はただ消費して、捨てています。

あとで拡張できるよう、`FunctionNode`は`returnType`プロパティも持っています。全ての課題が終わったら挑戦してみてください。

### `return`の扱い

`return`の扱いも悩ましいです。

MinSwiftでは簡単のため、`return`が現れたら`ReturnNode`としてラップしています。
このノードはほぼ何もしません。

実装した覚えがない？`parseExpression`で扱えるようにしておきました。

## 応用課題

Swiftの関数においては、引数宣言の方法が複数あることは最初に述べました。
余裕のある人は、ラベルと変数名が違うケース、ラベルを持たないケースも考えてみましょう。

実際に実装してみたところ、面白かったので応用課題にしました。


```swift
func doSomething(_ a: Double) -> Double { return 42 }
func doSomething(label a: Double) -> Double { return 42 }
```

`_test`から始まるテストケースを有効にするとテストすることができます。

### ヒント

1. `parseFunctionDefinitionArgument`の実装を拡張すれば、それで済むはずです
2. `_`は`wildcardKeyword`として扱われます
3. ときには先を見通す力が必要かもしれません
