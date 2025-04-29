#import "mod.typ": *

#show: book.page.with(title: "变量与函数")

== 变量声明 <grammar-var-decl>

变量是存储“字面量”的一个个容器。它相当于为一个个字面量取名，以方便在脚本中使用。

如下语法，「变量声明」表示使得`x`的内容与`"Hello world!!"`相等。我们对语法一一翻译：

#code(```typ
   #let    x     =  "Hello world!!"
// ^^^^    ^     ^  ^^^^^^^^^^^^^^^^
//  令    变量名  为    初始值表达式
```)

#pro-tip[
  同时我们看见输出的文档为空，这是因为「变量声明」本身的值是`none`。
]

「变量声明」一共分为3个有效部分。

+ `let`关键字：告诉Typst接下来即将开启一段「声明」。在英语中let是"令"的意思。
+ #term("variable identifier")、#mark("=")：标识符是变量的“名称”。「变量声明」后续的位置都可以通过标识符引用该变量。
+ #term("initialization expression")：#mark("=")告诉Typst变量初始等于一个表达式的值。该表达式在编译领域有一个专业术语，称为#term("initialization expression")。这里，#term("initialization expression")可以为任意表达式，请参阅

建议标识符简短且具有描述性。尽管标识符中可以包含中文等unicode字符，但仍建议标识符中仅含英文与#mark("hyphen")。

// #link(<scripting-expression>)[表达式小节]。

// 「变量声明」可以没有初始值表达式：

// #code(```typ
// #let x
// #repr(x)
// ```)

// 事实上，它等价于将`x`初始化为`none`。

// #code(```typ
// #let x = none
// #repr(x)
// ```)

// 尽管Typst允许你不写初始值表达式，本书还是建议你让所有的「变量声明」都具有初始值表达式。因为初始值表达式还告诉阅读你代码的人这个变量可能具有什么样的类型。

「变量声明」后续的位置都可以继续使用该变量，取决于「作用域」。
// + 标识符以Unicode字母、Unicode数字和#mark("_")开头。以下是示例的合法变量名：
//   ```typ
//   // 以英文字母开头，是Unicode字母
//   #let a; #let z; #let A; #let Z;
//   // 以汉字开头，是Unicode字母
//   #let 这;
//   // 以下划线开头
//   #let _;
//   ```
// + 标识符后接有限个Unicode字母、Unicode数字、#mark("hyphen")和#mark("_")。以下是示例的合法变量名：
//   ```typ
//   // 纯英文变量名，带连字号
//   #let alpha-test; #let alpha--test;
//   // 纯中文变量名
//   #let 这个变量; #let 这个_变量; #let 这个-变量;
//   // 连字号、下划线在多种位置
//   #let alpha-; // 连字号不能在变量名开头位置
//   #let _alpha; #let alpha_;
//   ```
// + 特殊规则：标识符仅为#mark("_")时，不允许在后续位置继续使用。
//   #code(```typ
//   #let _ = 1;
//   // 不能编译：#_
//   ```)
//   该标识符被称为#term("placeholder")。
// + 特殊规则：标识符不允许为`let`、`set`、`show`等关键字。
//   #code(```typ
//   // 不能编译：
//   // #let let = 1;
//   ```)

#pro-tip[
  关于作用域，你可以参考#(refs.content-scope-style)[《内容、作用域与样式》]。
]

变量可以重复输出到文档中：

#code(```typ
#let x = "阿吧"
#x#x，#x#x
```)

任意时刻都可以将任意类型的值赋给一个变量。上一节所提到的「内容块」也可以赋值给一个变量。

#code(```typ
#let y = [一段文本]; #y \
#(y = 1) /* 重新赋值为一个整数 */ #y \
```)

任意时刻都可以重复定义相同变量名的变量，但是之前被定义的变量将无法再被使用：

#code(```typ
#let y = [一段文本]; #y \
#let y = 1; /* 重新声明为一个整数 */ #y \
```)

=== 函数声明 <grammar-func-decl>

「函数声明」也由`let`关键字开始。如果你仔细对比，可以发现它们在语法上是一致的。

如下语法，「函数声明」表示使得`f(x, y)`的内容与右侧表达式的值相等。我们对语法一一翻译：

```typ
   #let    f(x, y)      = [两个值#(x)和#(y)偷偷混入了我们内容之中。]
// ^^^^    ^^^^^^^      ^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  令  函数名(参数列表)  为               一段内容
```

「函数声明」一共分为4个部分，相较于「变量声明」，多了一个参数列表。

参数列表中参数的个数可以有零个，一个，至任意多个，由逗号分隔。每个参数都是一个单独的#term("parameter identifier")。

```typ
// 零个参数，一个参数，两个参数，..
    #f(),   #f(x), #f(x, y)
```

#term("parameter identifier")的规则与功能与#term("variable identifier")相似。为参数取名是为其能在函数体中使用。

视角挪到等号右侧。#term("function body expression")的规则与功能与#term("initialization expression")相似。#term("function body expression")可以任意使用参数列表中的“变量”，并组合出一个表达式。组合出的表达式的值就是函数调用的结果。

结合例子理解函数的作用。将对应参数应用于函数可以取得对应的结果：

#code(```typ
#let f(x, y) = [两个值#(x)和#(y)偷偷混入了我们内容之中。]

#let x = "Hello world!!"
#let y = [一段文本]
#f(repr(x), y)
```)

其中```typ #f(repr(x), y)```的执行过程是这样的：

```typ
#f(repr(x), y) // 转变为
#f([\"Hello world!!\"], [一段文本])
```

注意，此时我们进入右侧表达式。

```typ
#[两个值#(x)和#(y)偷偷混入了我们内容之中。] // 转变为
#[两个值#([\"Hello world!!\"])和#([一段文本])偷偷混入了我们内容之中。]
```

最后整理式子得到，也即是我们看到的输出：

```typ
两个值\"Hello world!!\"和一段文本偷偷混入了我们内容之中。
```

// 请体会我们在介绍「变量声明」时的特殊措辞，并与「函数声明」的语法描述相对应。

// - 以下「变量声明」表示使得`x`的内容与`"Hello world!!"`相等。

//   ```typ
//   #let x = "Hello world!!"
//   ```

// - 以下「函数声明」表示使得`f(x, y)`的内容与经过计算后的`[两个值#(x)和#(y)偷偷混入了我们内容之中。]`相等。

//   ```typ
//   #let f(x, y) = [两个值#(x)和#(y)偷偷混入了我们内容之中。]
//   ```

== 函数闭包 <grammar-closure>

「闭包」是一类特殊的函数，又称为匿名函数。一个简单的闭包如下：

#code(```typ
#let f = (x, y) => [#(x)和#(y)。]
#f("我", "你")
```)

我们可以看到其以箭头为体，两侧为参数列表和函数体。不像「函数声明」，它不需要取名。

闭包以其匿名特征，很适合就地使用，让我们不必为一个暂时使用的函数起名，例如作为「回调」函数。我们将会在下一章经常使用「回调」函数。例如，Typst提供了「`show`」语法，其可以接收一个选择器和一个函数，并将其作用范围内被选择器选中的内容都使用给定函数处理：

#code(```typ
#let style(body) = text(blue, underline(body))
#show heading.where(level: 3): style
=== 标题
```)

但是，等价地，此时「函数声明」不如「闭包声明」优美：

#code(```typ
#show heading.where(level: 3): it => text(blue, underline(it))
=== 标题
```)

// #let x = 1;

// #let f() = x

// #f()
// #(x = 2)
// #f()

== 高级参数语法

学会了「数组」和「字典」，我们可以学习更加高级的参数语法。这些高级语法让参数声明更灵活。

=== 具名参数声明 <grammar-named-param>

以上两种函数都允许包含「具名参数」，其看起来就像字典的一项，冒号右侧则是参数的*默认值*：

#code(```typ
#let g(name: "？") = [你是#name]
#g(/* 不传就是问号 */); #g(name: "OwO。")
```)

=== 变长参数 <grammar-variadic-param>

「函数声明」和「闭包声明」都允许包含「变长参数」。

#code(```typ
#let g(..args) = [很多个值，#args.pos().join([、])，偷偷混入了我们内容之中。]
#g([一个俩个], [仨个四个], [五六七八个])
```)

```typc args```的类型是`arguments`。
+ 使用`args.pos()`得到传入的位置参数数组；使用`args.named()`得到传入的具名参数字典。
+ 使用`args.at(i)`访问索引为整数`i`的位置参数；使用`args.at(name)`访问名称为字符串`name`的具名参数。

== 总结

// Typst如何保证一个简单函数甚至是一个闭包是“纯函数”？

// 答：1. 禁止修改外部变量，则捕获的变量的值是“纯的”或不可变的；2. 折叠的对象是纯的，且「折叠」操作是纯的。

// Typst的多文件特性从何而来？

// 答：1. import函数产生一个模块对象，而模块其实是文件顶层的scope。2. include函数即执行该文件，获得该文件对应的内容块。

// 基于以上两个特性，Typst为什么快？

// + Typst支持增量解析文件。
// + Typst所有由*用户声明*的函数都是纯的，在其上的调用都是纯的。例如Typst天生支持快速计算递归实现的fibnacci函数：

//   #code(```typ
//   #let fib(n) = if n <= 1 { n } else { fib(n - 1) + fib(n - 2) }
//   #fib(42)
//   ```)
// + Typst使用`include`导入其他文件的顶层「内容块」。当其他文件内容未改变时，内容块一定不变，而所有使用到对应内容块的函数的结果也一定不会因此改变。

// 这意味着，如果你发现了Typst中与一般语言的不同之处，可以思考以上种种优势对用户脚本的增强或限制。

基于《字面量、变量和函数》掌握的知识你应该可以：
+ 查看#(refs.ref-type-builtin)[《参考：内置类型》]，以掌握内置类型的使用方法。
+ 查看#(refs.ref-visualization)[《参考：图形与几何元素》]，以掌握图形和几何元素的使用方法。
+ 查看#(refs.ref-wasm-plugin)[《参考：WASM插件》]，以掌握在Typst中使用Rust、JavaScript、Python等语言编写插件库。
+ 阅读#(refs.ref-grammar)[《参考：语法示例检索表》]，以检查自己的语法掌握程度。
+ 查看#(refs.ref-typebase)[《参考：基本类型》]，以掌握基本类型的使用方法。
+ 查看#(refs.ref-color)[《参考：颜色、色彩渐变与模式》]，以掌握色彩的高级管理方法。
+ 查看#(refs.ref-data-process)[《参考：数据读写与数据处理》]，以助你从外部读取数据或将文档数据输出到文件。
+ 查看#(refs.ref-bibliography)[《参考：导入和使用参考文献》]，以助你导入和使用参考文献。
+ 阅读基本参考部分中的所有内容。

== 习题

#let q1 = ````typ
#let a0 = 2
#let a1 = a0 * a0
#let a2 = a1 * a1
#let a3 = a2 * a2
#let a4 = a3 * a3
#let a5 = a4 * a4
#a5
````

#exercise[
  使用本节所讲述的语法，计算$2^32$的值：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#let a = [一]
#let b = [渔]
#let c = [江]
#let f(x, y) = a + x + a + y
#let g(x, y, z, u, v) = [#f(x, y + a + z)，#f(u, v)。]
#g([帆], [桨], [#(b)舟], [个#(b)翁], [钓钩]) \
#g([俯], [仰], [场笑], [#(c)明月], [#(c)秋])
````

#exercise[
  输出下面的诗句，但你的代码中至多只能出现17个汉字：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#let calc-fib() = {
  let res = range(2).map(float)
  for i in range(2, 201) {
    res.push(res.at(i - 1) + res.at(i - 2))
  }

  res
}
#let fib(n) = calc-fib().at(n)

#fib(75)
````

#exercise[
  已知斐波那契数列的递推式为$F_n = F_(n-1) + F_(n-2)$，且$F_0 = 0, F_1 = 1$。使用本节所讲述的语法，计算$F_75$的值：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#set align(center)
#let matrix-fmt(..args) = table(
  columns: args.at(0).len(),
  ..args.pos().flatten().flatten().map(str)
)
#matrix-fmt(
  (1, 2, 3),
  (4, 5, 6),
  (7, 8, 9),
)
````

#exercise[
  编写函数，使用`table`（表格）元素打印任意$N times M$矩阵，例如：

  ```typ
  #matrix-fmt(
    (1, 2, 3),
    (4, 5, 6),
    (7, 8, 9),
  )
  ```

  #rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

