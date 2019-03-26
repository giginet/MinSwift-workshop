# Practice 6 IRの生成

そろそろ飽きてきませんか？
このワークショップはSwiftパーサーワークショップではありませんからね。

この章では生成したASTからLLVM IRを生成してみましょう。

LLVM IRの生成はとても簡単です。LLVMが生成のためのAPIを用意してくれているからです。
ある意味ではパーサーの実装より退屈かもしれません。

## ModuleとIRBuilder

`Module`は関数や変数を保持するLLVMの状態に相当します。
`IRBuilder`はLLVM IRを生成するためのヘルパークラスです。`Module`はここから取り出すことができます。

MinSwiftでは、`BuildContext`がこの2つを保持しています。

```swift
let context = BuildContext()
context.builder.module
```

`generateIRValue` は`Node`と`BuildContext`を受け取って`LLVM.IRValue`を取り出すトップレベルの関数です。

この中では、渡ってきた`node`の型を見て、`IRValue`に変換しています。任意の`Node`を`IRValue`に変換したいときはこれを使います。

```swift
let value: IRValue = generateIRValue(from: node, with: context)
```

ここから`Node`の型ごとに`IRValue`を生成していきます。

## 6-1. NumberNodeの生成

まずは定数からLLVM IRを生成してみましょう。`NumberNode`です。

MinSwiftの`GeneratorProtocol` は`node`と`context`を受け取って`IRValue`を返す`generate`メソッドを持っています。
そこで、Protocol Extensionで`node`の型によってそれぞれ異なった`generate`を実装していきましょう。

```swift
extension Generator where NodeType == NumberNode {
    func generate(with context: BuildContext) -> IRValue {
        fatalError("Not implemented")
    }
}
```

doubleの生成は以下のAPIで行えます。

```swift
FloatType.double.constant(node.value)
```

```llvm
double 1.420000e+02
```

MinSwiftでは今のところ`Double`型しかサポートしていません。

### FileCheck

ところで、テストケース中に記述されているコメントが気になったでしょうか。

これはFileCheckというLLVMが提供するテスト用ユーティリティを用いて、ソースコード中のコメントでマッチャーを記述しています。
http://www.hogbergs.org/localdoc/llvm37/llvm/html/CommandGuide/FileCheck.html


LLVMはIRの生成結果を標準エラーとして出力します。そのため、出力の比較にはこのような仕組みが必要になるのです。


Swiftの世界からすると不思議な挙動に感じるかもしれませんが、LLVMSwiftのテストにも使用されています。
https://github.com/llvm-swift/LLVMSwift/blob/master/Tests/LLVMTests/IRBuilderSpec.swift

コメントを変更するとテスト結果が変わることが確認できると思います。

## 6-2. VariableNodeの生成

変数型を実装してみましょう。

ところで`BuildContext`は`namedValues`という辞書を保持しています。
これは現在のスコープで保持されている変数を管理します。
関数の引数として変数が渡ってきたとき、`namedValues`に保持します。（詳しくは6-5で説明します）

```swift
guard let variable = context.namedValues["a"] else {
    fatalError("Undefined variable named a")
}
return variable
```

今回は、変数が呼び出されたときに`namedValues`の値を参照しています。

## 6-3. BinaryExpressionNodeの生成

次に四則演算をサポートしましょう。

少し工夫が必要なのは、オペレーターの左辺、右辺からそれぞれ再帰的に`IRValue`を取り出す必要があることです。

```swift
context.builder.buildAdd(lhs, rhs, name: "addtmp")
```

これは以下のようなIRを生成します。
最後の引数は生成されるIRの変数名に相当し、この引数に指定した変数名としてLLVM IRに出力されます。

```llvm
%addtmp = fadd double %lhs %rhs
```

同様に`buildSub`, `buildMul`, `buildDiv`があります。
`name`の値は、テストケースを良く見て、生成されるIRが一致するように正しく設定してみましょう。

`lessThan`については、次のPractice 7で実装しますので、今は`fatalError`などで仮実装にしておきましょう。

ここで面白いのは、定数値同士の加算を行ったときにコンパイラが最適化を施してくれることです。

例えば`21 * 2`の生成結果は、以下のようにはならず、自動的に演算済みの結果が生成されます。

```llvm
%multmp = fmul double 2.100000e+01 2.000000e+00
retval multmp
```

```llvm
retval double 4.200000e+01
```

この最適化の仕組みが気になる人は、Kaleidoscopeの第4章を見てみてください。
https://llvm.org/docs/tutorial/LangImpl04.html

## 6-4. FunctionNodeの生成

お次は関数定義の生成です。少し複雑に見えますが、単純です。

`doSomething(Double) -> Double`という関数からIRを生成してみましょう。

```swift
let argumentTypes: [IRType] = [FloatType.double]
let returnType: IRType = FloatType.double
let functionType = FunctionType(argTypes: argumentTypes,
                                returnType: returnType)
let function = context.builder.addFunction("doSomething", type: functionType)

let entryBasicBlock = function.appendBasicBlock(named: "entry")
context.builder.positionAtEnd(of: entryBasicBlock)

// Register arguments to namedValues
context.namedValues.removeAll()
context.namedValues["myVariable"] = function.parameters[0]

let functionBody: IRValue
context.builder.buildRet(functionBody)
return functionBody
```

まずは`FunctionType`の生成です。ここでは`(Double) -> Double`を表しています。

`FunctionType`には、引数の型の配列と、戻り値の型をそれぞれ`IRType`で渡します。
繰り返しになりますが、MinSwiftでは`Double`しか考慮していないため、`FloatType.double`を使います。
`argumentTypes`は、サンプルでは1つ固定なので、`FunctionNode`を見て、引数の数にあうように設定しましょう。


そこから`Function`を追加しています。この値は、関数呼び出しを実装するときに使います。

`BasicBlock`はいわばネスト構造です。
6-2で登場した`namedValues`が再登場します。ここで引数に渡された変数を全て`namedValues`に登録しています。

当然ですが、任意長の引数に対応させる必要があります。うまい具合に考えてみましょう。

以下のような関数が生成できます。

```llvm
define double @doSomething(double) {
    entry:
    %addtmp = fmul double %0, %0
    ret double %addtmp
}
```

## 6-5. CallExpressionNodeの生成

最後に関数呼び出しです。これもそれほど難しくありません。

```swift
let function = module.function(named: "functionName")!
let arguments: [IRValue] = []
return context.builder.buildCall(function, args: arguments, name: "calltmp")
```

関数を定義した際に、Moduleに`Function`を登録しました。
ここでは呼び出す関数を名前から取り出しています。当然宣言されていない関数を取り出すことはできないので、戻り値は`LLVM.Function?`です。

引数は`IRValue`の配列を受け取ります。もう説明はいりませんよね。

## 6-6. まとめ

おめでとうございます！
ここまで実装できていれば、簡単な関数をSwiftで実装してバイナリを生成することができます。

テストコードを良く見て、Swiftのコードを書いてみましょう。

MinSwiftでは`Engine`というエンドポイントを用意しています。
`Module`から`Function`を取得し、関数ポインタにキャストしています。

```swift
let engine = Engine()
try! engine.load(from: source)
typealias FunctionType = @convention(c) () -> Double
try! engine.run("calculateAnswer", of: FunctionType.self) { calculateAnswer in
    print(calculateAnswer())
}
```

数々の難しい処理を経て、全ての答えを得ることができました。

実際に正しく動いているか試してみたい場合は、以下のように実行できます。

```console
$ ./build
$ swift run minswift Examples/calculation.swift 2> main.ll
$ lli main.ll; echo $?
42
```

あるいは簡単な再帰関数を書くこともできるかもしれません。とはいえ、条件分岐が書けないので止められませんが。

```swift
func increment(n: Double) {
    return increment(n + 1)
}
increment(10)
```

大丈夫、捕まったりしませんよ！
