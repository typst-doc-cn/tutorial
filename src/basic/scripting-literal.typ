#import "mod.typ": *

#show: book.page.with(title: "基本类型")

Typst很快，并非因为它的#term("parser")和#term("interpreter")具有惊世的执行性能，而是语言特性本身适合缓存优化。

自本节起，本教程将进入第二阶段，希望不仅让你了解如何使用脚本，还一并讲解Typst的执行原理。当然，我们不会陷入Typst的细节。所有在教程中出现的原理都是为了更好地了解语言本身。

// 什么是自省
// 程序不会自己自省，这是给你看的

== 代码表示的自省函数 <grammar-repr>

在开始学习之前，先学习几个与排版无关但非常实用的函数。

#typst-func("repr")是一个#term("introspection function")，可以帮你获得任意值的代码表示，很适合用来在调试代码的时候输出内容。

#code(```typ
#[ 一段文本 ]

#repr([ 一段文本 ])
```)

#pro-tip[
  #term("introspection function")是指那些为你获取解释器内部状态的函数。它们往往接受一些语言对象，而返回存储在解释器内部的相关信息。在这里，#typst-func("repr")接受任意值，而返回对应的代码表示。
]

== `type`函数 <grammar-type>

与#typst-func("repr")类似，一个特殊的函数#typst-func("type")可以获得任意值的#term("type")。所谓#term("type")，就是这个值归属的分类。例如：
- `1`是整数数字，类型就对应于整数类型（integer）。
  #code(```typ
  #type(1)
  ```)
- `一段内容`是文本内容，类型就对应于内容类型（content）。
  #code(```typ
  #type[一段内容]
  ```)

=== 类型 <type-type>

一个值只会属于一种类型，因此类型是可以比较的：

#code(```typ
#(str == str) \
#(type("X") == type("Y")) \
#(type("X") == str) \
#([一段内容] == str)
```)

类型的类型是类型（它自身）：

#code(```typ
#(type(str)) \
#(type(type(str))) \
#(type(type(str)) == type) \
```)

== `eval`函数 <grammar-eval>

`eval`函数接受一个字符串，把字符串当作代码执行并求出结果：

#code(```typ
#eval("1"), #type(eval("1")) \
#eval("[一段内容]"), #type(eval("[一段内容]"))
```)

从```typc eval("[一段内容]")```的中括号被解释为「内容块」可以得知，`eval`默认以#term("code mode")解释你的代码。

你可以使用`mode`参数修改`eval`的「解释模式」。`code`对应为#term("code mode")，`markup`对应为#term("markup mode")：<grammar-eval-markup-mode>

#code(```typ
代码模式eval：#eval("[一段内容]", mode: "code") \
标记模式eval：#eval("[一段内容]", mode: "markup")
```)

// #let x = 1;

// #let f() = x

// #f()
// #(x = 2)
// #f()

== 基本字面量

我们将介绍所有基本字面量，这是脚本的“一加一”。其实在上一节，我们已经见过了一部分字面量，但皆凭直觉使用：```typc 1```不就是数字吗，那么在Typst中，它就是数字。与之相对，TeX底层没有数字和字符串的概念。

如果你学过Python等语言，那么这将对你来说不是问题。在Typst中，常用的字面量并不多，它们是：
+ #term("none literal")。
+ #term("boolean literal")。
+ #term("integer literal")。
+ #term("floating-point literal")。
+ #term("string literal")。

=== 空字面量 <grammar-none-literal>

就像是数学中的零与负数，空字面量自然产生于运算过程中。

#code(```typ
#repr((0, 1).find((_) => false)),
#repr(if false [啊？])
```)

上例第一行，当在「数组」中查找一个不存在的元素时，“没有”就是```typc none```。第二行，当条件不满足，且没有`false`分支时，“没有内容”就是```typc none```。

空字面量是纯粹抽象的概念，这意味着你在现实中很难找到对应的实体。

// #pro-tip[
//   空字面量自然产生于运算过程中。除上所述，以下是其他会产生```typc none```的自然场景：
//   - 当变量未初始化时。
//   #code(```typ
//   #let x; #type(x)
//   ```)
//   - 当`for`语句、`while`语句、函数没有产生任何值时，函数返回值为```typc none```。
//   #code(```typ
//   #let f() = {}; #type(f())
//   ```)
//   - 当函数显式`return`且未写明返回值时，函数返回值为```typc none```。
//   #code(```typ
//   #let f() = return; #type(f())
//   ```)
// ]

`none`值不会对输出文档有任何影响：

#code(```typ
#none
```)

`none`的类型是`none`类型。`none`值不等于`none`类型，因为一个是值而另一个是类型：

#code(```typ
#type(none), #(type(none) == none), #type(type(none))
```)

=== 布尔字面量

一个布尔字面量表示逻辑的确否。它要么为```typc false```（真）<grammar-true-literal>要么为```typc true```（假）<grammar-false-literal>。

#code(```typ
假设 #false 那么一切为 #true。
```)

一般来说，我们不直接使用布尔值。当代码做逻辑判断的时候，会自然产生布尔值。

#code(```typ
$1 < 2$的结果为：#(1 < 2)
```)

=== 整数字面量 <grammar-integer-literal>

一个整数字面量代表一个整数。Typst中的整数默认为十进制：

#code(```typ
三个值 #(-1)、#0 和 #1 偷偷混入了我们内容之中。
```)

#pro-tip[
  有的时候Typst不支持在#mark("#")后直接跟一个值。例如，Typst无法处理#mark("#")后直接跟随一个#mark("hyphen")的情况。这个时候无论多么复杂，都可以用括号包裹值：

  #code(```typ
  #(-1), #(0), #(1)
  ```)
]

有些数字使用其他进制表示更为方便。你可以分别使用`0x`、`0o`和`0b`前缀加上进制内容表示十六进制数、八进制数和二进制数：<grammar-n-adecimal-literal>

#code(```typ
#(0xbeef)、#(0o755)、#(-0b1001)
```)

整数的有效取值范围是$[-2^63,2^63)$，其中$2^63=9223372036854775808$。

=== 浮点数字面量 <grammar-float-literal>

浮点数与整数非常类似。最常见的浮点数由至少一个整数部分或小数部分组成：

#code(```typ
浮点数#(1.001)、小数部分#(.1) 和整数部分#(2.)。
```)

有些数字使用#term("exponential notation")更为方便：<grammar-exp-repr-float>

#code(```typ
#(1e2)、#(1.926e3)、#(-1e-3)
```)

Typst还为你内置了一些特殊的数值，它们都是浮点数：

#code(```typ
$inf$=#calc.inf,
$pi$=#calc.round(calc.pi, digits: 5),
$tau$=#calc.round(calc.tau, digits: 5)
```)
// NaN=#calc.nan \

=== 字符串字面量 <grammar-string-literal>

Typst中所有字符串都是`utf-8`编码的，因此使用时不存在编码转换问题。字符串由一对「英文双引号」定界：

#code(```typ
#"Hello world!!"
```)

有些字符无法置于双引号之内，例如双引号本身。与「标记模式」中的转义序列语法类似，这时候你需要嵌入字符的转义序列：

#code(```typ
#"Hello \"world\"!!"
```)

字符串中的转义序列与「标记模式」中的转义序列语法相同，但有效转义的字符集不同。字符串中如下转义序列是有效的：

#{
  set align(center)
  table(
    columns: 7,
    [代码], [`\\`], [`\"`], [`\n`], [`\r`], [`\t`], [`\u{2665}`],
    [效果], "\\", "\"", [(换行)], [(回车)], [(制表)], "\u{2665}",
  )
}

你同样可以使用`\u{unicode}`格式直接嵌入Unicode字符。

#code(```typ
#"香辣牛肉粉好吃\u{2665}"
```)

除了使用简单字面量构造，可以使用以下方法从代码块获得字符串：

#code(```typ
#repr(`包含换行符和双引号的

"内容"`.text)
```)

== 类型转换

类型本身也是函数，例如`int`类型可以接受字符串，转换成整数。

#code(```typ
#int("11"), #int("-23")
```)

从转换的角度，`eval`可以将代码字符串转换成值。例如，你可以转换16进制数字：

#code(```typ
#eval("0x3f")
```)

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

#todo-box[重写总结]

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

