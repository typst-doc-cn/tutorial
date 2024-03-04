#import "mod.typ": *

#show: book.page.with(title: "字面量、变量与函数")

Typst很快，并不是因为它的#term("parser")和#term("interpreter")具有惊世的性能，而是因为在Typst脚本的世界一切都是纯的，没有几乎。

本节与下一节从Typst的底层原理出发，带你反推和破魅Typst脚本执行逻辑。

== 代码表示的自省函数 <grammar-repr>

在开始学习之前，先学习几个与排版无关但非常实用的函数。

#typst-func("repr")是一个#term("introspection function")，可以帮你获得任意值的代码表示。

#code(```typ
#[ 一段文本 ]

#repr([ 一段文本 ])
```)

#pro-tip[
  #term("introspection function")是指那些为你获取解释器内部状态的函数。它们往往接受一类值，而返回存储在解释器内部的相关信息。

  在这里，#typst-func("repr")强大到接受任意值，而返回对应的代码表示。
]

#typst-func("repr")的特点是可以接受任意值，因此很适合用来在调试代码的时候输出内容。

== 类型的自省函数 <grammar-type>

与#typst-func("repr")类似，一个特殊的函数#typst-func("type")可以获得任意值的#term("type")。

#code(```typ
#type("一个字符串")

#type([一段文本])

#type(() => { "一个函数" })
```)

所谓#term("type")，就是这个值归属的分类。例如：
- `1`是整数数字，类型就对应于整数类型（integer）。
  #code(```typ
  #type(1)
  ```)
- `一段内容`是文本内容，类型就对应于内容类型（content）。
  #code(```typ
  #type([一段内容])
  ```)

一个值只会属于一种类型，而类别是精确的。因此，类型是可以比较的：

#code(```typ
#(str == str) \
#(type("一个字符串") == type("另一个字符串")) \
#(type("一个字符串") == str) \
#([一段文本] == str)
```)

类型的类型是类型（它自身）：

#code(```typ
#(type(str)) \
#(type(str) == type) \
#(type(type(str)) == type) \
#(type(type(type(str))) == type)
```)

== 求值函数 <grammar-eval>

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

== 基本字面量

```typ
#("Hello " + "world!!")
```

为了完全掌握上面的代码，你首先需要了解Typst中已有的基本字面量。

如果你学过Python等语言，那么这将对你来说不是问题。在Typst中，常用的字面量并不多，它们是：
+ #term("none literal", postfix: "。")
+ #term("boolean literal", postfix: "。")
+ #term("integer literal", postfix: "。")
+ #term("floating-Point literal", postfix: "。")
+ #term("string literal", postfix: "。")

=== 空字面量 <grammar-none-literal>

空字面量是纯粹抽象的概念，这意味着你在现实中很难找到对应的实体。就像是数学中的零与负数，空字面量自然产生于运算过程中。

#code(```typ
#repr((0, 1).find((_) => false)), 
#repr(if false [啊？])
```)

上例第一行，当在「数组」中查找一个不存在的元素时，“没有”就是```typc none```。

上例第二行，当条件不满足，且没有`false`分支时，“没有内容”就是```typc none```。

这些例子都蕴含较复杂的脚本逻辑，会在下一节详细介绍。

#pro-tip[
  空字面量自然产生于运算过程中。以下是所有会产生```typc none```的自然场景：
  - 当变量未初始化时。
  #code(```typ
  #let x; #type(x)
  ```)
  - 当`if`语句条件不满足，且没有`false`（`else`）分支时，`if`语句的值为```typc none```。
  #code(```typ
  #type(if false {})
  ```)
  - 当`for`语句、`while`语句、函数没有产生任何值时，函数返回值为```typc none```。
  #code(```typ
  #let f() = {}; #type(f())
  ```)
  - 当函数显式`return`且未写明返回值时，函数返回值为```typc none```。
  #code(```typ
  #let f() = return; #type(f())
  ```)
]

`none`不产生任何内容：

#code(```typ
#none
```)

`none`的类型是`none`类型：

#code(```typ
#type(none)
```)

`none`值不等于`none`类型，因为一个是值而另一个是类型：

#code(```typ
#(type(none) == none), #type(none), #type(type(none))
```)

使用以下方法将`none`转化为布尔类型：

#code(```typ
#let some-x = none
#(some-x == none)
#((some-x != none) and (1 < 2))
```)

=== 布尔字面量

一个布尔字面量表示逻辑的确否。它要么为`false`（真）<grammar-true-literal>要么为`true`（假）<grammar-false-literal>。

#code(```typ
两个值 #false 和 #true 偷偷混入了我们内容之中。
```)

一般来说，我们不直接使用布尔值。当代码做逻辑判断的时候，会自然产生布尔值。

#code(```typ
$1 < 2$的结果为：#(1 < 2) \
$1 > 2$的结果为：#(1 > 2)
```)

布尔值的类型是布尔类型：

#code(```typ
#type(false), #type(true)
```)

=== 整数字面量 <grammar-integer-literal>

一个整数字面量代表一个整数。相信你一定知道整数的含义。Typst中的整数默认为十进制：

#code(```typ
三个值 #(-1)、#0 和 #1 偷偷混入了我们内容之中。
```)

#pro-tip[
  有的时候Typst不支持在#mark("#")后直接跟一个值。这个时候无论值有多么复杂，都可以将值用一对圆括号包裹起来，从而允许Typst轻松解析该值。例如，Typst无法处理#mark("#")后直接跟随一个#mark("hyphen")的情况：

  #code(```typ
  #(-1), #(0), #(1)
  ```)
]

Typst允许十进制数存在前导零：

#code(```typ
#009009
```)

有些数字使用其他进制表示更为方便。你可以分别使用`0x`、`0o`和`0b`前缀加上进制内容表示十六进制数、八进制数和二进制数：<grammar-n-adecimal-literal>

#code(```typ
十六进制数：#(0xdeadbeef)、#(-0xdeadbeef) \
八进制数：#(0o755)、#(-0o644) \
二进制数：#(0b1001)、#(-0b1001)
```)

上例中，当数字被输出到文档时，Typst将数字都转换成了十进制表示。

以十六进制数为例介绍其与十进制数之间的关系。将一个十六进制数转换成一个十进制数，计算方式是：从十六进制数的低位（右边）开始，逐步向高位（左边），取每位的字符对应十进制数值，与 $16$ 的 $n$ 次幂相乘（这里的 $n$ 不是固定的，它等于该字符所在的位序 $-1$ ，位序指从低位到高位的排序），最后将每位的计算结果相加，即可获得对应十进制的值。

十六进制数字与十进制数字对应关系如下：

#{
  set align(center)
  table(
    columns: 10,
    [十六进制],[...],[8],[9],[a/A],[b/B],[c/C],[d/D],[e/E],[f/F],
    [十进制],[...],[8],[9],[10],[11],[12],[13],[14],[15]
  )
}


举个例子：十进制的1324相当于十六进制的0x52C。

+ 计算“C”：
  因为“C”对应的十进制值是12，它所在的位序是1，即它是右边第1位，所以它的值为：$12 dot (16^(1-1)) = 12$
+ 计算“2”：
  因为“2”对应的十进制值是2，它所在的位序是2，即它是右边第2位，所以它的值为：$2 dot (16^(2-1)) = 32$
+ 计算“5”：
  因为“5”对应的十进制值是5，它所在的位序是3，即它是右边第3位，所以它的值为：$5 dot (16^(3-1)) = 1280$
+ 将每位结果相加：
  $ 12 + 32 + 1280 = 1324 $

检验：
#code(```typ
#1324, #0x52c, #(0x52c == 1324)
```)

整数的类型是整数类型：

#code(```typ
#type(0), #type(0x0), #type(0o0), #type(0b0)
```)

整数的有效取值范围是$[-2^63,2^63)$，其中$2^63=9223372036854775808$。

=== 浮点数字面量 <grammar-float-literal>

浮点数与整数非常类似。最常见的浮点数由至少一个整数部分或小数部分组成：

#code(```typ
三个值 #(0.001)、#(.1) 和 #(2.) 偷偷混入了我们内容之中。
```)

浮点数的类型是浮点数类型：

#code(```typ
#type(2.)
```)

可见```typc 2.```与```typc 2```类型并不相同。

当数字过大时，其会被隐式转换为浮点数存储：

#code(```typ
#type(9000000000000000000000000000000)
```)

整数相除时会被转换为浮点数：

#code(```typ
#(10 / 4), #type(10 / 4) \
#(12 / 4), #type(12 / 4) \
```)

为了转换类型，可以使用`int`，但有可能产生精度损失（就近取整）：

#code(```typ
#int(10 / 4),
#int(12 / 4),
#int(9000000000000000000000000000000)
```)

有些数字使用#term("exponential notation")更为方便。你可以使用标准的#term("exponential notation")创建浮点数：<grammar-exp-repr-float>

#code(```typ
#(1e2)、#(1.926e3)、#(-1e-3)
```)

Typst还为你内置了一些特殊的数值，它们都是浮点数：

#code(```typ
$pi$=#calc.pi \
$tau$=#calc.tau \
$inf$=#calc.inf \
NaN=#calc.nan \
```)

=== 字符串字面量 <grammar-string-literal>

Typst中所有字符串都是`utf-8`编码的，因此使用时不存在编码问题。字符串由一对「英文双引号」定界：

#code(```typ
#"Hello world!!"
```)

字符串的类型是字符串类型：

#code(```typ
#type("Hello world!!")
```)

有些字符无法置于双引号之内，例如双引号本身。这时候你需要嵌入字符的转义序列：

#code(```typ
#"Hello \"world\"!!"
```)

字符串中的转义序列与「标记模式」中的转义序列语法相同，但内容不同。Typst允许的字符串中的转义序列如下：

#{
  set align(center)
  table(
    columns: 7,
    [代码], [`\\`],[`\"`],[`\n`],[`\r`],[`\t`],[`\u{2665}`],
    [效果], "\\", "\"", [(换行)], [(回车)], [(制表)], "\u{2665}",
  )
}

与《基础文档》中的转义序列相同，你可以使用`\u{unicode}`格式直接嵌入Unicode字符。

#code(```typ
#"香辣牛肉粉好吃\u{2665}"
```)


除了使用简单字面量构造，可以使用以下方法从代码块获得字符串：

#code(```typ
#repr(`包含换行符和双引号的

"内容"`.text)
```)

== 变量 <grammar-var-decl>

如下语法，「变量声明」表示使得`x`的内容与`"Hello world!!"`相等。我们对语法一一翻译：

#code(```typ
   #let    x     =  "Hello world!!"
// ^^^^    ^     ^  ^^^^^^^^^^^^^^^^ 
//  令    变量名  为    初始值表达式
```)

同时我们看见输出的文档为空，这是因为「变量声明」并不产生任何内容。

「变量声明」一共分为4个部分，`let`关键字、#term("variable identifier")、#mark("=")和#term("initialization expression")。其中`let`关键字和#mark("=")是你每次都必须固定书写的部分。

`let`关键字告诉Typst接下来即将开启一段「声明」。

`let`关键字后紧接着跟随一个#term("variable identifier")。标识符是变量的“名称”。「变量声明」后续的位置都可以通过标识符引用该变量。

+ 标识符以Unicode字母、Unicode数字和#mark("_")开头。以下是示例的合法变量名：
  ```typ
  // 以英文字母开头，是Unicode字母
  #let a; #let z; #let A; #let Z;
  // 以汉字开头，是Unicode字母
  #let 这;
  // 以下划线开头
  #let _;
  ```
+ 标识符后接有限个Unicode字母、Unicode数字、#mark("hyphen")和#mark("_")。以下是示例的合法变量名：
  ```typ
  // 纯英文变量名，带连字号
  #let alpha-test; #let alpha--test;
  // 纯中文变量名
  #let 这个变量; #let 这个_变量; #let 这个-变量;
  // 连字号、下划线在多种位置
  #let alpha-; // 连字号不能在变量名开头位置
  #let _alpha; #let alpha_; 
  ```
+ 特殊规则：标识符仅为#mark("_")时，不允许在后续位置继续使用。
  #code(```typ
  #let _ = 1;
  // 不能编译：#_
  ```)
  该标识符被称为#term("placeholder")。
+ 特殊规则：标识符不允许为`let`、`set`、`show`等关键字。
  #code(```typ
  // 不能编译：
  // #let let = 1;
  ```)

建议标识符简短且具有描述性。同时建议标识符中仅含英文与#mark("hyphen")。

#mark("=")告诉Typst变量初始等于一个表达式的值。该表达式在编译领域有一个专业术语，称为#term("initialization expression")。这里，#term("initialization expression")可以为任意表达式，请参阅#link(<scripting-expression>)[表达式小节]。

「变量声明」可以没有初始值表达式：

#code(```typ
#let x
#repr(x)
```)

事实上，它等价于将`x`初始化为`none`。

#code(```typ
#let x = none
#repr(x)
```)

尽管Typst允许你不写初始值表达式，本书还是建议你让所有的「变量声明」都具有初始值表达式。因为初始值表达式还告诉阅读你代码的人这个变量可能具有什么样的类型。

「变量声明」后续的位置都可以继续使用该变量，取决于「作用域」。

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
#let y = [一段文本]
#y \
// 重新赋值为一个整数
#(y = 1)
#y \
```)

任意时刻都可以重复定义相同变量名的变量，但是之前被定义的变量将无法再被使用：

#code(```typ
#let y = [一段文本]
#y \
// 重新声明为一个整数
#let y = 1
#y \
```)

== 简单函数 <grammar-func-decl>

在Typst中，变量和简单函数有着类似的语法。

如下语法，「函数声明」表示使得`f(x, y)`的内容与右侧表达式的值相等。我们对语法一一翻译：

#code(```typ
   #let    f(x, y)      = [两个值#(x)和#(y)偷偷混入了我们内容之中。]
// ^^^^    ^^^^^^^      ^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
//  令  函数名(参数列表)  为               一段内容
```)

同样我们看见输出的文档为空，这是因为「函数声明」也并不产生任何内容。

「函数声明」一共分为5个部分，`let`关键字、#term("function identifier")、参数列表、#mark("=")和#term("function body expression")。其中`let`和#mark("=")是你每次都必须固定书写的部分。

「函数声明」与「变量声明」有很多部分是完全一致的。`let`关键字与#mark("=")自不必说。#term("function identifier")的规则与功能与#term("variable identifier")相似，可用于后续使用该函数时引用。

参数列表的个数可以有零个，一个，至任意多个，由逗号分隔。每个参数都是一个单独的#term("parameter identifier")。

#(```typ
// 零个参数
#f()
// 一个参数
#f(x)
// 两个参数
#f(x, y)
// ..
```)

我想你应该已经会抢答了，#term("parameter identifier")的规则与功能与#term("variable identifier")相似，可用于后续使用该参数时引用。

视角挪到等号右侧。#term("function body expression")的规则与功能则与#term("initialization expression")相似。#term("function body expression")可以任意使用参数列表中的“变量”，并组合出一个表达式。组合出的表达式的值就是函数调用的结果。

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
#f(repr("Hello world!!"), y) // 转变为
#f([\"Hello world!!\"], y) // 转变为
#f([\"Hello world!!\"], [一段文本])
```

注意，此时我们进入右侧表达式。

```typ
#let x = [\"Hello world!!\"]
#let y = [一段文本]
#[两个值#(x)和#(y)偷偷混入了我们内容之中。] // 转变为
#[两个值#([\"Hello world!!\"])和#([一段文本])偷偷混入了我们内容之中。]
```

最后整理式子得到：

```typ
// 转变为
#[两个值\"Hello world!!\"和一段文本偷偷混入了我们内容之中。] // 转变为
两个值\"Hello world!!\"和一段文本偷偷混入了我们内容之中。
```

请体会我们在介绍「变量声明」时的特殊措辞，并与「函数声明」的语法描述相对应。

- 以下「变量声明」表示使得`x`的内容与`"Hello world!!"`相等。

  ```typ
  #let x = "Hello world!!"
  ```

- 以下「函数声明」表示使得`f(x, y)`的内容与经过计算后的`[两个值#(x)和#(y)偷偷混入了我们内容之中。]`相等。

  ```typ
  #let f(x, y) = [两个值#(x)和#(y)偷偷混入了我们内容之中。]
  ```

== 表达式 <scripting-expression>

表达式从感性地理解上就是检验执行一段代码是否对应产生一个值。精确来说，表达式是以下对象的集合：
+ 前述的各种「字面量」是表达式：
  #code(```typ
  // 这些是表达式
  #none, #true, #1, #.2, #"s"
  ```)
+ 「变量」是表达式：
  #code(```typ
  #let a = 1;
  // 这是表达式
  #a
  ```)
+ 「括号表达式」（parenthesized expression）是表达式：
  #code(```typ
  // 这些是表达式
  #(0), #(1+2), #((((((((1))))))))
  ```)
+ 「函数调用」是表达式：
  #code(```typ
  #let add(a, b) = a + b
  #let a = 1;
  // 这是表达式
  #add(a, 2)
  ```)
+ 特别地，Typst中的「代码块」和「内容块」是表达式：
  #code(```typ
  // 这些是表达式
  #repr({ 1 }), #repr([ 1 ]), 
  ```)
+ 特别地，Typst中的「if语句」、「for语句」和「while语句」等都是表达式：
  #code(```typ
  // 这些是表达式
  #repr(if false [啊？]), 
  #repr(for _ in range(0) {}), 
  #repr(while false {}), 
  #repr(let _ = 1), 
  ```)
  这些将在后文中介绍。
+ 情形1至情形7的所有对象作为项，任意项之间的「运算」也是表达式。

其中，情形1至情形3被称为「初始表达式」（primary expression），它们就像是表达式的种子，由其他操作继续组合生成更多表达式。

情形4至情形6本身都是经典意义上的「语句」（statement），它们由一个或多个子表达式组成，形成一个有新含义的表达式。在Typst中它们都被赋予了「值」的语义，因此它们也都是表达式。我们将会在后续文章中继续学习。

#pro-tip[
  Typst借鉴了Rust。遵从「面向表达式编程」（expression-oriented programming）的哲学，它将所有的语句都根据可折叠规则（见后文）转为了表达式。
  + 如果一个语句能产生值，那么该语句的结果是所有值的折叠。
  + 否则，如果一个语句不能产生值，那么该语句的结果是```typc none```。
  特别地，许多类型的折叠符合规则：类型 $T$ 的值 $v$ 与`none`折叠仍然是值本身。
  $ forall v in T union {"none"}, op("fold")_T (v, "none") = v $
]

仅有少量的语句不是表达式。

#pro-tip[
  `show`语句和`set`语句不是表达式。
]

本节主要讲解情形7。由于情形1至情形6都可以作为情形7的项，不失一般性，我们仍然可以仅以「字面量」作为项讲解所有情形7的情况。

=== 逻辑比较表达式 <grammar-logical-cmp-exp>

数字之间可以相互（算术逻辑）比较，并产生布尔类型的表达式：

- 小于：
  #code(```typ
  #(1 < 0), #(1 < 1), #(1 < 2)
  ```)
- 小于等于：
  #code(```typ
  #(1 <= 0), #(1 <= 1), #(1 <= 2)
  ```)
- 大于：
  #code(```typ
  #(1 > 0), #(1 > 1), #(1 > 2)
  ```)
- 大于等于：
  #code(```typ
  #(1 >= 0), #(1 >= 1), #(1 >= 2)
  ```)
- 等于：
  #code(```typ
  #(1 == 0), #(1 == 1), #(1 == 2)
  ```)
- 不等于：
  #code(```typ
  #(1 != 0), #(1 != 1), #(1 != 2)
  ```)

不仅整数与整数之间、浮点数与浮点数之间可以做比较，而且整数与浮点数之间也可以做比较。当整数与浮点数相互比较时，整数会转换为浮点数再参与比较。
#code(```typ
#(1 != 0.), #(1 != 1.), #(1 != 2.)
```)

注意：不推荐将整数与浮点数相互比较，这有可能产生意料之外的浮点误差。
#code(```typ
#(9/1e160*1e160), #(9/1e160*1e160 == 9) \
// 理论上为true，实际运算结果为false
#(9/1e160/1e160*1e160*1e160), #(9/1e160/1e160*1e160*1e160 == 9)
```)

=== 逻辑运算表达式 <grammar-logical-calc-exp>

布尔值之间可以做逻辑运算，并产生布尔类型的表达式：
- 非运算：
  #code(```typ
  #(not false), #(not true)
  ```)
- 或运算：
  #code(```typ
  #(false or false), #(false or true), #(true or false), #(true or true)
  ```)
- 且运算：
  #code(```typ
  #(false and false), #(false and true), #(true and false), #(true and true)
  ```)

真值表如下：

#{
  set align(center)
  table(columns: 5, stroke: 0.5pt, 
    $p$, $q$, $not p$, $p or q$, $p and q$,
    $0$, $0$, $1$, $0$, $0$,
    $0$, $1$, $1$, $1$, $0$,
    $1$, $0$, $0$, $1$, $0$,
    $1$, $1$, $0$, $1$, $1$,
  )
}

逻辑运算使用起来很简单，建议入门的同学找一些专题阅读，例如#link("https://zhuanlan.zhihu.com/p/82986019")[数理逻辑（1）——命题逻辑的基本概念]。

一旦涉及到对复杂事物的逻辑讨论，你就可能陷入了知识的海洋。关于逻辑运算已经形成一门学科，如有兴趣建议后续找一些书籍阅读，例如#link("https://www.xuetangx.com/course/THU12011001060/19316572")[逻辑学概论]。

本书自然不负责教你逻辑学。

=== 算术运算表达式 <grammar-arith-exp>

数字之间可以做算术运算，并产生数字结果的表达式：

- 取正运算：<grammar-plus-exp>
  #code(```typ
  #(+1), #(+0), #(++1)
  ```)
- 取负运算：<grammar-minus-exp>
  #code(```typ
  #(-1), #(-0), #(--1), #(-+-1)
  ```)
- 加运算：
  #code(```typ
  #(1 + 2), #(1 + 1), #(1 + -1), #(1 + -2)
  ```)
- 减运算：
  #code(```typ
  #(1 - 2), #(1 - 1), #(1 - -1), #(1 - -2)
  ```)
- 乘运算：
  #code(```typ
  #(1 * 2), #(2 * 2), #(2 * -2)
  ```)
- 除运算：
  #code(```typ
  #(1 / 2), #(2 / 2), #(2 / -2)
  ```)

值得注意的是$-2^63$在Typst中是浮点数，这可能是Typst的bug：

#code(```typ
#type(-9223372036854775808)
```)

为了正常使用该整数值你需要强制转换：

#code(```typ
#int(-9223372036854775808), #type(int(-9223372036854775808))
```)

在日常生活中，我们还常用整除，如下方法实现了整除：

#code(```typ
#let fdiv(x, y) = int(x / y)
#fdiv(3, 2), #fdiv(-12, 2), #fdiv(-12, 5) \
// 或
#int(3 / 2), #int(-12 / 2), #int(-12 / 5)
```)

#pro-tip[
  `calc.rem`函数帮你求解整除的余数：
  #code(```typ
  #let fdiv(x, y) = int(x / y)
  $ 3 div & 2 = & #fdiv(  3, 2) & ...... & #calc.rem(  3, 2). \
  -12 div & 2 = & #fdiv(-12, 2) & ...... & #calc.rem(-12, 2). \
  -12 div & 5 = & #fdiv(-12, 5) & ...... & #calc.rem(-12, 5). $
  ```)
]

=== 赋值表达式 <grammar-assign-exp>

变量可以被赋予一个表达式的值，所有的赋值表达式都产生`none`值而非返回变量的值。

- 赋值及先加（减、乘或除）后赋值：
  #code(```typ
  #let a = 1
  #repr(a = 10), #a, #repr(a += 2), #a, #repr(a -= 2), #a, #repr(a *= 2), #a, #repr(a /= 2), #a
  ```)

=== 字符串相关的表达式

字符串相加表示字符串的连接：<grammar-string-concat-exp>

#code(```typ
#("a" + "b")
```)

字符串与数字相乘表示将该字符串重复$n$次后再连接：<grammar-string-mul-exp>

#code(```typ
#("a" * 4), #(4 * "ab")
```)

字符串之间的比较遵从#link("https://en.wikipedia.org/wiki/Lexicographic_order")[#term("lexicographical order")]。<grammar-string-cmp-exp>

等于和不等于的比较，比较每个字符是否相等：

#code(```typ
#("a" == "a"), #("a" != "a") \
#("a" == "b"), #("a" != "b") \
```)

大于和小于的比较，从第一个字符开始依次比较，比较每个字符是否相等。直到第一个不相等的字符时作以下判断，字符的Unicode值较小的字符串则x相应更“小”：

#code(```typ
#("a" < "b"), #("a" > "a"),  \
#("a" < "ba"), #("ac" < "ba"), #("aac" < "aba")
```)

若一直比到了其中一个字符串的尽头，则较短的字符串更“小”：

#code(```typ
#("a" < "ab")
```)

大于等于和小于等于的比较则将「相等性」纳入考虑：

#code(```typ
#("a" >= "a"), #("a" <= "a") \
```)

== 类型转换

整数转浮点数：<grammar-int-to-float>

#code(```typ
#float(1), #(type(float(1)))
```)

布尔值转整数：<grammar-bool-to-int>

#code(```typ
#int(false), #(type(int(false))) \
#int(true), #(type(int(true)))
```)

浮点数转整数：<grammar-float-to-int>

#code(```typ
#int(1), #(type(int(1)))
```)

该方法是就近取整，并有精度损失（根据规范，超出精度范围时，如何选择较近的值舍入是「与实现相关」）：

#code(```typ
#int(1.5), #int(1.99),
// 超出浮点精度范围会就近舍入再转换成整数
#int(1.9999999999999999)
```)

为了向下或向上取整，你可以同时使用`calc.floor`或`calc.ceil`函数（有精度损失）：

#code(```typ
#int(calc.floor(1.9)), #int(calc.ceil(1.9))
```)

十进制字符串转整数：<grammar-dec-str-to-int>

#code(```typ
#int("1"), #(type(int("1")))
```)

十六进制/八进制/二进制字符串转整数：<grammar-nadec-str-to-int>

#code(```typ
#let safe-to-int(x) = {
  let res = eval(x)
  assert(type(res) == int, message: "should be integer")
  res
}
#safe-to-int("0xf"), #(type(safe-to-int("0xf"))) \
#safe-to-int("0o755"), #(type(safe-to-int("0o755"))) \
#safe-to-int("0b1011"), #(type(safe-to-int("0b1011"))) \
```)

注意：`assert(type(res) == int)`是必须的，否则是不安全的。

数字转字符串：<grammar-num-to-str>

#code(```typ
#repr(str(1)), #(type(str(1)))
#repr(str(.5)), #(type(str(.5)))
```)

整数转 $N$ 进制字符串：<grammar-int-to-nadec-str>

#code(```typ
#str(501, base:16), #str(0xdeadbeef, base:36)
```)

布尔值转字符串：<grammar-bool-to-str>

#code(```typ
#repr(false), #(type(repr(false)))
```)

数字转布尔值：<grammar-int-to-bool>

#code(```typ
#let to-bool(x) = x != 0
#repr(to-bool(0)), #(type(to-bool(0))) \
#repr(to-bool(1)), #(type(to-bool(1)))
```)

== 计算标准库

由于该库即将废弃（本文将介绍新的计算API），如有希望使用的朋友，请参见#link("https://typst.app/docs/reference/foundations/calc")[Typst Reference - Calculation]。

== 代码块和内容块 <grammar-code-block>

在上一节中，我们介绍了「内容块」，但我们并未对内容块做过多描述。在这里我们将与「代码块」一起详细介绍内容块。
- 代码块：按顺序包含一系列语句，内部为#term("code mode")。
- 内容块：按顺序包含一系列内容，内部为#term("markup mode")。

内容块（标记模式）内部没有语句的概念，一个个内容或元素按顺序排列。但你可以通过#mark("#")将解释器的「解释模式」从「标记模式」*临时*改为「脚本模式」。当执行完脚本后，将脚本结果转换成内容，并放置在「井号」处。

相比，代码块内部则有语句概念。每个语句可以是换行分隔，也可以是#mark(";")分隔。

#code(```typ
#{
  "a"
  "b"
} \ // 与下表达式等同：
#{ "a"; "b" }
```)

在Typst中，代码块和内容块是等同的。甚至，内容块和文档文件本身是等同的。

内容块的值从感性理解，最终可以形成一个内容。那么代码块的值要如何理解？这就引入了「可折叠」的值（Foldable）的概念。

== 「可折叠」的值（Foldable）

先来看代码块。代码块其实就是一个脚本。既然是脚本，Typst就可以按照语句顺序依次执行「语句」。

#pro-tip[
  准确地来说，按照控制流顺序。
]

Typst按控制流顺序执行代码，将所有结果*折叠*成一个值。所谓折叠，就是将所有数值“连接”在一起。这样讲还是太抽象了，来看一个具体的例子。

=== 字符串折叠

Typst实际上不限制代码块的每个语句将会产生什么结果，只要是结果之间可以*折叠*即可。

我们说字符串是可以折叠的：

#code(```typ
#{"Hello"; " "; "World"}
```)

实际上折叠操作基本就是#mark("+")操作。那么字符串的折叠就是在做字符串连接操作：

#code(```typ
#("Hello" + " " + "World")
```)

再看一个例子：

#code(```typ
#{
  let hello = "Hello";
  let space = " ";
  let world = "World";
  hello; space; world;
  let destroy = ", Destroy"
  destroy; space; world; "."
}
```)

如何理解将「变量声明」与表达式混写？

回忆前文。对了，「变量声明」表达式的结果为```typc none```。
#code(```typ
#type(let hello = "Hello")
```)

并且还有一个重点是，字符串与`none`相加是字符串本身，`none`加`none`还是`none`：

#code(```typ
#("Hello" + none), #(none + "Hello"), #repr(none + none)
```)

现在可以重新体会这句话了：Typst按控制流顺序执行代码，将所有结果*折叠*成一个值。对于上例，每句话的执行结果分别是：

```typc
#{
  none; // let hello = "Hello";
  none; // let space = " ";
  none; // let world = "World";
  "Hello"; " "; "World"; // hello; space; world;
  none; // let destroy = ", Destroy"
  ", Destroy"; " "; "Wrold"; "." // destroy; space; world; "."
}
```

将结果收集并“折叠”，得到结果：

#code(```typc
#(none + none + none + "Hello" + " " + "World" + none + ", Destroy" + " " + "Wrold" + ".")
```)

=== 其他基本类型的情况

那么为什么说折叠操作基本就是#mark("+")操作。那么就是说有的“#mark("+")操作”并非是折叠操作。

布尔值、整数和浮点数都不能相互折叠：

```typ
// 不能编译
#{ false; true }; #{ 1; 2 }; #{ 1.; 2. }
```

还有其他可以折叠的值，我们将会在将来学到。

#pro-tip[
  数组与字典是可以折叠的：

  #code(```typ
  #for i in range(1, 5) { (i, i * 10) }
  ```)

  #code(```typ
  #for i in range(1, 5) { let d = (:); d.insert(str(i), i * 10); d }
  ```)
]

那么是否说布尔值、整数和浮点数都不能折叠呢。答案又是否认的，它们都可以与```typc none```折叠（把下面的加号看成折叠操作）：

#code(```typ
#(1 + none)
```)

所以你可以保证一个代码块中只有一个「语句」产生布尔值、整数或浮点数结果，这样的代码块就又是能编译的了。让我们利用`let _ = `来实现这一点：

#code(```typ
#{ let _ = false; true }, #{ 1; let _ = 2 }, #{ let _ = 1.; 2. }
```)

回忆之前所讲的特殊规则：#term("placeholder")用作标识符的作用是“忽略不必要的语句结果”。

=== 内容折叠

Typst脚本的核心重点就在本段。

内容也可以作为代码块的语句结果，这时候内容块的结果是每个语句内容的“折叠”。

#code(```typ
#{
  [= 生活在Content树上]
  [现代社会以海德格尔的一句“一切实践传统都已经瓦解完了”为嚆矢。]
  [滥觞于家庭与社会传统的期望正失去它们的借鉴意义。]
  [但面对看似无垠的未来天空，我想循卡尔维诺“树上的男爵”的生活好过过早地振翮。]
}
```)

是不是感觉很熟悉？实际上内容块就是上述代码块的“糖”。所谓糖就是同一事物更方便书写的语法。上述代码块与下述内容块等价：

#code(```typ
#[
= 生活在Content树上
现代社会以海德格尔的一句“一切实践传统都已经瓦解完了”为嚆矢。滥觞于家庭与社会传统的期望正失去它们的借鉴意义。但面对看似无垠的未来天空，我想循卡尔维诺“树上的男爵”的生活好过过早地振翮。
]
```)

由于Typst默认以「标记模式」开始解释你的文档，这又与省略`#[]`的写法等价：

#code(```typ
= 生活在Content树上
现代社会以海德格尔的一句“一切实践传统都已经瓦解完了”为嚆矢。滥觞于家庭与社会传统的期望正失去它们的借鉴意义。但面对看似无垠的未来天空，我想循卡尔维诺“树上的男爵”的生活好过过早地振翮。
```)

== Hello World程序

有的时候，我们想要访问字面量、变量与函数中存储的“信息”。例如，给定一个字符串```typc "Hello World"```，我们想要截取其中的第二个单词。

单词`World`就在那里，但仅凭我们有限的脚本知识，却没有方法得到它。这是因为字符串本身是一个整体，虽然它具备单词信息，我们却缺乏了*访问*信息的方法。

Typst为我们提供了「成员」和「方法」两种概念访问这些信息。使用「方法」，可以使用以下脚本完成目标：

#code(```typ
#"Hello World".split(" ").at(1)
```)

为了方便讲解，我们改写出6行脚本。除了第二行，每一行都输出一段内容：

#code(```typ
#let x = "Hello World"; #x \
#let split = str.split
#split(x, " ") \
#str.split(x, " ") \
#x.split(" ") \
#x.split(" ").at(1)
```)

从```typ #x.split(" ").at(1)```的输出可以看出，这一行帮助我们实现了“截取其中的第二个单词”的目标。我们虽然隐隐约约能揣测出其中的意思：

```typ
#(       x .split(" ")           .at(1)          )
// 将字符串 根据字符串拆分  取出其中的第2个单词（字符串）
```

但至少我们对#mark(".")仍是一无所知。

本节我们就来讲解Typst中较为高级的脚本语法。这些脚本语法与大部分编程语言的语法相同，但是我们假设你并不知道这些语法。

== 成员 <grammar-member-exp>

Typst提供了一系列「成员」和「方法」访问字面量、变量与函数中存储的“信息”。

其实在上一节（甚至是第二节），你就已经见过了「成员」语法。你可以通过「点号」，即```typc `OvO`.text ```，获得代码块的“text”（文本内容）：

#code(```typ
这是一个代码块内容：#repr(`OvO`)

这是一段文本：#repr(`OvO`.text)
```)

每个类型有哪些「成员」是由Typst决定的。你需要逐渐积累经验以知晓这些「成员」的分布，才能更快地通过访问成员快速编写出收集和处理信息的脚本。(todo: 建议阅读)

当然，为防你不知道，大家不都是死记硬背的：有软件手段帮助你使用这些「成员」。本人在此提醒你：可以安装一个带LSP的编辑器，例如VSCode。当你对某个对象后接一个点号时，编辑器会自动为你做代码补全。(todo：搭建环境)

#figure(image("./IDE-autocomplete.png", width: 120pt), caption: [作者使用编辑器作代码补全的精彩瞬间。])

从图中可以看出来，该代码片段对象上有七个「成员」。特别是“text”成员赫然立于其中，就是它了。除了「成员」列表，编辑器还会告诉你每个「成员」的作用，以及如何使用。这时候只需要选择一个「成员」作为补全结果即可。

== 方法 <grammar-method-exp>

「方法」是一种特殊的「成员」。准确来说，如果一个「成员」是一个对象的函数，那么它就被称为该对象的「方法」。

统一来看Hello World程序的第三行、第四行与第五行脚本。它们输出了相同的内容，事实上，它们是*同一*「函数调用」的不同写法：

#code(```typ
#let x = "Hello World"
#let str-split = str.split
#str-split(x, " ") \
#str.split(x, " ") \
#x.split(" ")
```)

第三行脚本含义对照如下。之前已经学过，这正是「函数调用」的语法：

```typ
#(        str-split(         x,  " "   ))
// 调用  字符串拆分函数，参数为 变量x和空格
```

观察第三行与第四行脚本：

#(```typ
#str-split(x, " ") \
#str.split(x, " ") \
```)

从`str-split`的「变量声明」可以推断：第四行脚本仍然是在做「函数调用」，只不过在语法上更为紧凑。

第五行脚本的写法则更加简明。

#(```typ
#x.split(" ")
```)

约定`str.split(x, y)`可以简写为`x.split(y)`，如果：
+ 对象`x`是`str`类型，且方法`split`是`str`类型的「成员」。
+ 对象`x`用作`str.split`调用的第一个参数。

这种写法可以进一步推及其他类型和类型的方法，被称为「方法调用」，即一种特殊的「函数调用」，是一个在各编程语言中广泛存在的简写规则。

「方法调用」大大简化了脚本。当然你也可以选择不用「方法调用」，毕竟你可以看到「函数调用」一样可以完成所有任务。

#pro-tip[
  这里有一个问题：为什么Typst要引入「方法」的概念呢？主要有以下几点考量。

  其一，为了引入「方法调用」的语法，这种语法相对要更为方便和易读。对比以下两行，它们都完成了获取`"Hello World"`字符串的第二个单词的第一个字母的功能：

  #code(```typ
  #"Hello World".split(" ").at(1).split("").at(1)

  #array.at(str.split(array.at(
    str.split("Hello World", " "), 1), ""), 1)
  ```)

  可以明显看见，第一行脚本全部写在一行还能很方便地阅读，但第二行语句的参数已经散落在括号的里里外外，很难理解到底做了什么事情。

  其二，相比「函数调用」，「方法调用」更有利于现代IDE补全脚本。如果你使用了带脚本自动补全的编辑器，当你在`"Hello World"`字符串后敲下一个「点号」时，IDE会自动联想你接下来可能需要与“字符串”相关的函数，你便可以通过`.split`很快定位到“字符串拆分”这个函数。

  与之相对，「函数调用」的“筛选效率”更低。若想调用`str-split`或`str.split`，你首先需要敲下一个`s`字符，很快编辑器就会把所有以`s`开头的函数都告诉你了，这可就有点头疼了。

  其三，方便用户管理相似功能的函数。你很快就可以联想到，不仅仅是字符串可以拆分，似乎内容也可以拆分。不仅如此，将来可能还有各种各样的拆分。如果需要为他们都取不同的名字，那可就太头疼了。相比`str.split`就简单多了。要知道，程序员最讨厌给变量和函数想命名这种东西了。
]

接下来只需要理解最后一行脚本，就能彻底搞懂这个Hello World程序了。看起来，它也是某种类型上的某个「方法」。

#code(```typ
#let x = "Hello World".split(" ")
#x.at(1)
```)

若需要理解最后一行，则需引入「数组」的概念。

== 数组字面量 <grammar-array-literal>

脚本模式中有非常重要的复合字面量，它们是「数组」和「字典」。

「数组」是按照顺序存储的一些「值」，你可以在「数组」中存放*任意内容*而不拘泥于类型。你可以使用圆括号与一个逗号分隔的列表创建一个*数组字面量*：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x
```)

构造数组字面量时，允许尾随一个多余的逗号而不造成影响。

#code(```typ
#let x = (1, "OvO", [一段内容] , )
//          这里有一个多余的逗号^^^
#x
```)

为了访问数组，你可以使用`at`方法。“at”在中文里是“在”的意思，它表示对「数组」使用「索引」操作。在数组中，第0个值就是字面量声明中的第一个值，第1个值就是字面量声明中的第二个值，以此类推。如下所示：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x.at(0) \
#x.at(1) \
#x.at(2)
```)

至于为什么「索引」从零开始，这只是一个约定俗成。相信等你习惯了，你也会变成计数从零开始的好程序员。

与数组相关的另一个重要语法是`in`，`x in (...)`，表示判断`x`是否在某个数组中：<grammar-array-in>

#code(```typ
#(1 in (1, "OvO", [一段内容])) \
#([一段内容] in (1, "OvO", [一段内容])) \
#([另一段内容] in (1, "OvO", [一段内容]))
```)

同时，你还可以使用语法`not in`判断`x`是否*不在*某个数组中：<grammar-array-not-in>

#code(```typ
#(1 not in (1, "OvO", [一段内容])) \
#([另一段内容] not in (1, "OvO", [一段内容]))
```)

== 回顾示例

回顾Hello World程序：

#code(```typ
#let x = "Hello World".split(" ")
#x \
#x.at(1)
```)

含义不言而喻：使用空格拆分字符串可以得到两个单词，使用`at`方法，当「索引」参数为1的时候，就取出了其中的第二个元素，即`"Hello World"`字符串中的第二个单词。

== 字典字面量 <grammar-dict-literal>

与「数组」同理，你可以使用圆括号与一个逗号分隔的列表创建一个*字典字面量*。与数组略微不同的是，列表的每一项是由冒号分隔的「键值对」。

所谓「字典」即是「键值对」的集合。如下例所示，“neco-mimi”、“utterance”和“attribute”是字典的「键」，它们必须是字符串。而`2`、`"喵喵喵"`和`[kawaii\~]`分别是对应的「值」。

#code(```typ
#let cat = (
  neko-mimi: 2,
  "utterance": "喵喵喵",
  attribute: [kawaii\~]
)
#cat
```)

构造字典字面量时，允许尾随一个多余的逗号而不造成影响。

#code(```typ
#let cat = (
  neko-mimi: 2,
  "utterance": "喵喵喵",
  attribute: [kawaii\~] ,
//   这里有一个尾随的小逗号^^^
)
#cat
```)

为了访问字典，你可以使用`at`方法。但由于「键」都是字符串，你需要使用字符串作为字典的「索引」。

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#cat.at("neko-mimi") \
#cat.at("utterance") \
#cat.at("attribute")
```)

为了方便，Typst允许你直接通过成员方法访问字典对应「键」的值： <grammar-dict-member-exp>

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵")
// 等价于cat.at("neko-mimi")
#cat.neko-mimi \ 
// 等价于cat.at("utterance")
#cat.utterance
```)

与数组类似，字典也可以使用相关的另一个重要语法是`in`，`x in (...)`，表示判断`x`是否是字典的一个「键」：<grammar-dict-in>

#code(```typ
#let cat = (neko-mimi: 2)
#("neko-mimi" in cat)
```)

注意：`x in (...)`与`"x" in (...)`是不同的。例如`neko-mimi in cat`将检查`neko-mimi`变量的内容是否是字典变量`cat`的一个「键」，而`"neko-mimi"`检查对应字符串是否在其中。

== 数组和字典字面量典例

讲解一些关于数组与字典字面量相关的典例：

#code(```typ
#() \ // 是空的数组
#(:) \ // 是空的字典
#(1) \ // 被括号包裹的整数1
#(()) \ // 被括号包裹的空数组
#((())) \ // 被括号包裹的被括号包裹的空数组
#(1,) \ // 是含有一个元素的数组
```)

`()`是空的数组<grammar-empty-array>，不含任何值；如果你想构建空的字典，需要中置一个冒号，`(:)`是空的字典<grammar-empty-dict>，不含任何键值对。

如果括号内含了一个值，而无法与数组区分，例如`(1)`，那么它仅仅是被括号包裹的整数1，仍然是整数1本身。

类似的，`(())`是被括号包裹的空数组<grammar-paren-empty-array>，`((()))`是被括号包裹的被括号包裹的空数组。

如果你想构建含有一个元素的数组，需要在列表末尾放置一个额外的逗号以区分括号语法，例如`(1,)`。<grammar-single-member-array>

== 数组和字典的「解构赋值」

除了使用字面量「构造」元素，Typst还支持「构造」的反向操作：「解构赋值」。顾名思义，你可以在左侧用相似的语法从数组<grammar-destruct-array>或字典中获取值并赋值到*对应*的变量上。<grammar-destruct-dict>

#code(```typ
#let x = (1, "Hello, World", [一段内容])
#let (one, hello-world, a-content) = x
#one \
#hello-world \
#a-content
```)

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#let (utterance: u, attribute: a) = cat
#u \
#a
```)

数组的「解构赋值」必须一一解构，如果数组包含10项，则你必须解构出10个变量。否则，如果只想解构其中一部分值，可以尾随一个「延展符」（`..`），以示省略：<grammar-destruct-array-eliminate>

#code(```typ
#let (first, ..) = (1, "Hello, World", [一段内容])
#first \
#let (_, second, ..) = (1, "Hello, World!!!", [一段内容])
#second \
#let (attribute: a, ..) = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#a
```)

数组的「解构赋值」有一个妙用，那就是重映射内容。<grammar-array-remapping>

#code(```typ
#let a = 1; #let b = 2; #let c = 3
#let (b, c, a) = (a, b, c)
#a, #b, #c
```)

特别地，如果两个变量相互重映射，这种操作被称为「交换」：<grammar-array-swap>

#code(```typ
#let a = 1; #let b = 2
#((a, b) = (b, a))
#a, #b
```)

从如下脚本，你可以更好地体会到「构造」与「解构赋值」互为相反操作的含义：

#code(```typ
#let (one, hello-world,    a-content) = {
     (1,   "Hello, World", [一段内容])
}
#one \
#hello-world \
#a-content
```)

// field access
// - dictionary
// - symbol
// - module
// - content

== `none`类型和`if`语句 <grammar-if>

默认情况下，在逻辑上，Typst按照顺序执行执行你的代码，即先执行前面的语句，再执行后面的语句。开发者如果想要控制程序执行的流程，就必须使用流程控制的语法结构，主要是条件执行和循环执行。

`if`语句用于条件判断，满足条件时，就执行指定的语句。

```typ
#if expression { then-block } else { else-block }
#if expression { then-block }
```

上面式子中，表达式`expression`为真（值为布尔值`true`）时，就执行`then-block`代码块，否则执行`else-block`代码块。特别地，`else`可以省略。

如下所示：

#code(```typ
#(1 < 2) \
#if (1 < 2) { "确实" } else { "啊？" }
```)

因为`1 < 2`表达式为真，所以脚本执行了`then-block`代码块，而忽略了`else-block`代码块，于是最后文档的内容为“确实”。

`if`语句还可以无限串联下去，你可以自行类比推理更长的`if`语句的语义：<grammar-if-if>

```typ
#if expression { .. } else if expression { .. } else { .. }
#if expression { .. } else if expression { .. }
#if expression { .. } else if expression { .. } else if ..
```

这里有一个疑问，如果只写了`then`代码块，而没写`else`代码块，但偏偏表达式不为真，最终脚本会报错吗？请看：

#code(```typ
#if (1 > 2) { "啊？" }
```)

虽然很合理，但是为了学到更多知识，我们用`repr`一探究竟：

#code(```typ
#repr(if (1 > 2) { "啊？" })
```)

当`if`表达式没写`else`代码块而条件为假时，结果为`none`。“none”在中文里意思是“无”，“什么都没有”。同时再次强调`none`在「可折叠」的值中很重要的一个性质：`none`在折叠过程中被忽略。

见下程序，其根据数组所包含的值输出特定字符串：

#code(```typ
#let 查成分(成分数组) = {
  "是个"
  if "A" in 成分数组 { "萌萌" }
  if "C" in 成分数组 { "萌萌" }
  if "G" in 成分数组 { "萌萌" }
  if "T" in 成分数组 { "工具" }
  "人"
}

#查成分(())

#查成分(("A","C",))

#查成分(("A","T",))
```)

由于`if`也是表达式，你可以直接将`if`作为函数体，例如fibnacci函数的递归可以非常简单：

#code(```typ
#let fib(n) = if n <= 1 {
  n
} else {
  fib(n - 1) + fib(n - 2)
}

#fib(46)
```)

== `while`语句 <grammar-while>

// if condition {..}
// if condition [..]
// if condition [..] else {..}
// if condition [..] else if condition {..} else [..]

`while`语句用于循环结构，满足条件时，不断执行循环体。

```typ
#while expression { CONT }
```

上面代码中，如果表达式`expression`为真，就会执行`CONT`代码块，然后再次判断`expression`是否为假；如果`expression`为假就跳出循环，不再执行循环体。

#code(```typ
#{
  let i = 0;
  while i < 10 {
    (i * 2, )
    i += 1;
  }
}
```)

上面代码中，循环体会执行`10`次，每次将`i`增加`1`，直到等于`10`才退出循环。

== `for`语句 <grammar-for>

`for`语句也是常用的循环结构，它迭代访问某个对象的每一项。

```typ
#for X in A { CONT }
```

上面代码中，对于`A`的每一项，都执行`CONT`代码块。在执行`CONT`时，项的内容是`X`。例如以下代码做了与之前循环相同的事情：

#code(```typ
#for i in range(10) {
  (i * 2, )
}
```)

其中`range(10)`创建了一个内容为`(0, 1, 2, ..., 9)`一共10个值的的数组。

所有的数组都可以使用`for`遍历，同理所有字典也都可以使用`for`遍历。在执行`CONT`时，项的内容是键值对，而Typst将用一个数组代表这个键值对，交给你。键值对数组的第0项是键，键值对数组的第1项是对应的值。

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#for i in cat {
  [猫猫的 #i.at(0) 是 #i.at(1)\ ]
}
```)

你可以同时使用「解构赋值」让代码变得更容易阅读：<grammar-for-destruct>

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#for (特色, 这个) in cat {
  [猫猫的 #特色 是 #这个\ ]
}
```)

== `break`语句和`continue`语句 <grammar-break>

无论是`while`还是`for`，都可以使用`break`跳出循环，或`continue`直接进入下一次执行。

基于以下`for`循环，我们探索`break`和`continue`语句的作用。

#code(```typ
#for i in range(10) { (i, ) }
```)

在第一次执行时，如果我们直接使用`break`跳出循环，但是在break之前就已经产生了一些值，那么`for`的结果是`break`前的那些值的「折叠」。

#code(```typ
#for i in range(10) { (i, ); (i + 1926, ); break }
```)

特别地，如果我们直接使用`break`跳出循环，那么`for`的结果是*`none`*。

#code(```typ
#for i in range(10) { break }
```)

在`break`之后的那些值将会被忽略：

#code(```typ
#for i in range(10) { break; (i, ); (i + 1926, ); }
```)

以下代码将收集迭代的所有结果，直到`i >= 5`：
#code(```typ
#for i in range(10) {
  if i >= 5 { break }
  (i, )
}
```)

// #for 方位 in ("东", "南", "西", "北", "中", "间", "东北", "西北", "东南", "西南") [鱼戏莲叶#方位，]

`continue`有相似的规则，便不再赘述。我们举一个例子，以下程序输出在`range(10)`中不是偶数的数字：<grammar-continue>

#code(```typ
#let 是偶数(i) = calc.even(i)
#for i in range(10) {
  if 是偶数(i) { continue }
  (i, )
}
```)

事实上`break`语句和`continue`语句还可以在参数列表中使用，但本书非常不推荐这些写法，因此也不多做介绍：

#code(```typ
#let add(a, b, c) = a + b + c
#while true { add(1, break, 2) }
```)

== 控制函数返回值

你可以通过多种方法控制函数返回值。

=== 占位符 <grammar-placeholder>

早在上节我们就学习过了占位符，这在编写函数体表达式的时候尤为有用。你可以通过占位符忽略不需要的函数返回值。

以下函数获取数组的倒数第二个元素：

#code(```typ
#let last-two(t) = {
  let _ = t.pop()
  t.pop()
}
#last-two((1, 2, 3, 4))
```)

=== `return`语句 <grammar-return>

你可以通过`return`语句忽略表达式其余*所有语句*的结果，而使用`return`语句返回特定的值。

以下函数获取数组的倒数第二个元素：

#code(```typ
#let last-two(t) = {
  t.pop()
  return t.pop()
}
#last-two((1, 2, 3, 4))
```)

== 变量的可变性

Typst对内置实现的所有函数都有良好的自我管理，但总免不了用户打算写一些逆天的函数。为了保证缓存计算仍较为有效，Typst强制要求用户编写的*所有函数*都是纯函数。这允许Typst有效地缓存计算，在相当一部分文档的编译速度上，快过LaTeX等语言上百倍。

你可能不知道所谓的纯函数是为何物，本书也不打算讲解什么是纯函数。关键点是，涉及函数的*纯性*，就涉及到变量的可变性。

相比纯函数，变量的可变性就要好懂多了。

你可以任意改变一个变量的内容，也就是说一个变量默认是可变的：

#code(```typ
#let a = 1; #let b = 2;
#((a, b) = (b, a))
#a, #b \
#for i in range(10) { a += i }
#a, #b
```)

但是，一个函数的函数体表达式不允许涉及到函数体外的变量修改：

#code(```typ
#let a = 1;
#let f() = (a += 1);
// 调用将会产生报错，无法修改`a`变量：
// #f()
```)

这是因为纯函数不允许产生带有副作用的操作。

同时，传递进函数的数组和字典参数都会被拷贝。这将导致对参数数组或参数字典的修改不会影响外部变量的内容：

#code(```typ
#let a = (1, );
#let add-array(a) = (a += (2, ));
#a \ // 初始值
#add-array(a);
#a \ // 函数调用后不发生任何变化
#(a += (2, ));
#a \ // 期望a += (2, )的效果
```)

#pro-tip[
  准确地来说，数组和字典参数会被写时拷贝。所谓写时拷贝，即只有当你期望修改数组和字典参数时，拷贝才会随即发生。
]

为了“修改”外部变量，你必须将修改过的变量设法传出函数，并在外部更新外部变量。

#code(```typ
#let a = (1, );
#let add-array(a) = {
  a += (2, )
  return a
};
#a \ // 初始值
#(a = add-array(a));
#a \ // 返回值更新数组
```)

#pro-tip[
  一个函数是纯的，如果：
  + 对于所有相同参数，返回相同的结果。
  + 函数没有副作用，即局部静态变量、非局部变量、可变引用参数或输入/输出流等状态不会发生变化。

  本节所讲述的内容是对第二点要求的体现。
]

== 函数闭包 <grammar-closure>

函数的闭包是一个很有用的语法。上一节我们学习了简单函数的「函数声明」。现在我们对照「函数声明」学习「闭包声明」。一个简单的「闭包」如下：

#code(```typ
#let f = (x, y) => [两个值#(x)和#(y)偷偷混入了我们内容之中。]
#f("a", "b")
```)

其中「闭包」是以下表达式：

```typc
    (x, y) => [两个值#(x)和#(y)偷偷混入了我们内容之中。]
// 参数列表     函数体表达式
```

「闭包」是一类特殊的函数。其主要特点是不需要指定函数名标识符。

「闭包」很适合用来作为参数传入其他函数，即作为「回调」函数。我们将会在下一章经常使用「回调」函数。

例如，Typst提供一个`locate`函数。其接受一个函数参数。你可以使用「函数声明」：

#code(```typ
#let f(loc) = [
  当前页面为#loc.page()。
]
#locate(f)
```)

但是，等价地，「函数声明」在这种情况下不如「闭包声明」优美：

#code(```typ
#locate(loc => [
  当前页面为#loc.page()。
])
```)

== 具名参数声明 <grammar-named-param>

「函数声明」和「闭包声明」都允许包含「具名参数」。「具名参数」需要指定默认值：

#code(```typ
#let g(some-arg: none) = [很多个值，#some-arg，偷偷混入了我们内容之中。]
#g()
#g(some-arg: "OwO")
```)

todo: 完善

== 含变参函数和Argument类型 <grammar-variadic-param>

「函数声明」和「闭包声明」都允许包含「变长参数」。

#code(```typ
#let g(..args) = [很多个值，#args.pos().join([、])，偷偷混入了我们内容之中。]
#g([一个俩个], [仨个四个], [五六七八个])
```)

```typc args.pos()```的类型是`Argument`。
+ 使用`args.pos()`得到按顺序传入的参数
+ 使用`args.at(name)`访问名称为`name`的具名参数。

todo: 完善

== 总结

Typst如何保证一个简单函数甚至是一个闭包是“纯函数”？

答：1. 禁止修改外部变量，则捕获的变量的值是“纯的”或不可变的；2. 折叠的对象是纯的，且「折叠」操作是纯的。

Typst的多文件特性从何而来？

答：1. import函数产生一个模块对象，而模块其实是文件顶层的scope。2. include函数即执行该文件，获得该文件对应的内容块。

基于以上两个特性，Typst为什么快？

+ Typst支持增量解析文件。
+ Typst所有由*用户声明*的函数都是纯的，在其上的调用都是纯的。例如Typst天生支持快速计算递归实现的fibnacci函数：

  #code(```typ
  #let fib(n) = if n <= 1 { n } else { fib(n - 1) + fib(n - 2) }
  #fib(42)
  ```)
+ Typst使用`include`导入其他文件的顶层「内容块」。当其他文件内容未改变时，内容块一定不变，而所有使用到对应内容块的函数的结果也一定不会因此改变。

这意味着，如果你发现了Typst中与一般语言的不同之处，可以思考以上种种优势对用户脚本的增强或限制。

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
#g([帆], [浆], [#(b)舟], [个#(b)翁], [钓钩]) \
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
  columns: args.pos().at(0).len(),
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
