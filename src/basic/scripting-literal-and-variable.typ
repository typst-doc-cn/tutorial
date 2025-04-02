#import "mod.typ": *

#show: book.page.with(title: "常量与变量")

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

== 类型的自省函数 <grammar-type>

与#typst-func("repr")类似，一个特殊的函数#typst-func("type")可以获得任意值的#term("type")。所谓#term("type")，就是这个值归属的分类。例如：
- `1`是整数数字，类型就对应于整数类型（integer）。
  #code(```typ
  #type(1)
  ```)
- `一段内容`是文本内容，类型就对应于内容类型（content）。
  #code(```typ
  #type([一段内容])
  ```)

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

本小节我们将具体介绍所有基本字面量，这是脚本的“一加一”。其实在上一节，我们已经见过了一部分字面量，但皆凭直觉使用：```typc 1```不就是数字吗，那么在Typst中，它就是数字。（PS：与之相对，TeX根本没有数字和字符串的概念。）

如果你学过Python等语言，那么这将对你来说不是问题。在Typst中，常用的字面量并不多，它们是：
+ #term("none literal")。
+ #term("boolean literal")。
+ #term("integer literal")。
+ #term("floating-point literal")。
+ #term("string literal")。

=== 空字面量 <grammar-none-literal>

空字面量是纯粹抽象的概念，这意味着你在现实中很难找到对应的实体。就像是数学中的零与负数，空字面量自然产生于运算过程中。

#code(```typ
#repr((0, 1).find((_) => false)),
#repr(if false [啊？])
```)

上例第一行，当在「数组」中查找一个不存在的元素时，“没有”就是```typc none```。

上例第二行，当条件不满足，且没有`false`分支时，“没有内容”就是```typc none```。

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

一个布尔字面量表示逻辑的确否。它要么为`false`（真）<grammar-true-literal>要么为`true`（假）<grammar-false-literal>。

#code(```typ
假设 #false 那么一切为 #true。
```)

一般来说，我们不直接使用布尔值。当代码做逻辑判断的时候，会自然产生布尔值。

#code(```typ
$1 < 2$的结果为：#(1 < 2)
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

有些数字使用其他进制表示更为方便。你可以分别使用`0x`、`0o`和`0b`前缀加上进制内容表示十六进制数、八进制数和二进制数：<grammar-n-adecimal-literal>

#code(```typ
十六进制数：#(0xdeadbeef)、#(-0xdeadbeef) \
八进制数：#(0o755)、#(-0o644) \
二进制数：#(0b1001)、#(-0b1001)
```)

上例中，当数字被输出到文档时，Typst将数字都转换成了十进制表示。

整数的有效取值范围是$[-2^63,2^63)$，其中$2^63=9223372036854775808$。

=== 浮点数字面量 <grammar-float-literal>

浮点数与整数非常类似。最常见的浮点数由至少一个整数部分或小数部分组成：

#code(```typ
三个值 #(0.001)、#(.1) 和 #(2.) 偷偷混入了我们内容之中。
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
// NaN=#calc.nan \
```)

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

== 计算标准库
#todo-box[写完]
请参见#link("https://typst.app/docs/reference/foundations/calc")[Typst Reference - Calculation]。

== 浮点数陷阱

浮点数陷阱是指由于浮点转换或浮点精度问题导致的一系列逻辑问题。

// todo: 把基本字面量的运算和表达式挪过来

+ 类型比较陷阱。在运行期切记同时考虑到`float`和`int`两种类型：

  #code(```typ
  #type(2), #type(2.), #(type(2.) == int)
  ```)

  可见```typc 2.```与```typc 2```类型并不相同。```typc 2.```在数学上是整数，但以浮点数存储。

+ 大数类型陷阱。当数字过大时，其会被隐式转换为浮点数存储：

  #code(```typ
  #type(9000000000000000000000000000000)
  ```)

+ 整数运算陷阱。整数相除时会被转换为浮点数：

  #code(```typ
  #(10 / 4), #type(10 / 4) \
  #(12 / 4), #type(12 / 4) \
  ```)

+ 浮点误差陷阱。哪怕你的运算在数学上理论是可逆的，由于浮点数精度有限，也会误判结果：

  #code(```typ
  #(1000000 / 9e21 * 9e21), #((1000000 / 9e21 * 9e21) == 1000000)
  ```)

  这提示我们，正确的浮点比较需要考虑误差。例如以上两数在允许`1e-6`误差前提下是相等的：

  #code(```typ
  #(calc.abs((1000000 / 9e21 * 9e21) - 1000000) < 1e-6)
  ```)

+ 整数转换陷阱。为了转换类型，可以使用`int`，但有可能产生精度损失（就近取整）：

  #code(```typ
  #int(10 / 4),
  #int(12 / 4)
  ```)

  或有可能产生「截断」。（todo: typst v0.12.0已经不适用）

// #code(```typ
// #int(9000000000000000000000000000000)
// ```)

这些都是编程语言中的共通问题。凡是令数字保持有效精度，都会产生如上问题。

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

== 成员 <grammar-member-exp>

Typst提供了一系列「成员」和「方法」访问字面量、变量与函数中存储的“信息”。

其实在上一节（甚至是第二节），你就已经见过了「成员」语法。你可以通过「点号」，即```typc `OvO`.text ```，获得代码块的“text”（文本内容）：

#code(```typ
这是一个代码块：#repr(`OvO`)

这是一段文本：#repr(`OvO`.text)
```)

每个类型有哪些「成员」是由Typst决定的。你需要逐渐积累经验以知晓这些「成员」的分布，才能更快地通过访问成员快速编写出收集和处理信息的脚本。(todo: 建议阅读)

当然，为防你不知道，大家不都是死记硬背的：有软件手段帮助你使用这些「成员」。许多编辑器都支持LSP（Language Server Protocol，语言服务），例如VSCode安装Tinymist LSP。当你对某个对象后接一个点号时，编辑器会自动为你做代码补全。

#figure(image("./IDE-autocomplete.png", width: 120pt), caption: [作者使用编辑器作代码补全的精彩瞬间。])

从图中可以看出来，该代码片段对象上有七个「成员」。特别是“text”成员赫然立于其中，就是它了。除了「成员」列表，编辑器还会告诉你每个「成员」的作用，以及如何使用。这时候只需要选择一个「成员」作为补全结果即可。

== 方法 <grammar-method-exp>

「方法」是一种特殊的「成员」。准确来说，如果一个「成员」是一个对象的函数，那么它就被称为该对象的「方法」。

来看以下代码，它们输出了相同的内容，事实上，它们是*同一*「函数调用」的不同写法：

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

与第三行脚本相比，第四行脚本仍然是在做「函数调用」，只不过在语法上更为紧凑。

第五行脚本则更加简明，此即「方法调用」。约定`str.split(x, y)`可以简写为`x.split(y)`，如果：
+ 对象`x`是`str`类型，且方法`split`是`str`类型的「成员」。
+ 对象`x`用作`str.split`调用的第一个参数。

「方法调用」即一种特殊的「函数调用」规则（语法糖），在各编程语言中广泛存在。其大大简化了脚本。但你也可以选择不用，毕竟「函数调用」一样可以完成所有任务。

#pro-tip[
  这里有一个问题：为什么Typst要引入「方法」的概念呢？主要有以下几点考量。

  其一，为了引入「方法调用」的语法，这种语法相对要更为方便和易读。对比以下两行，它们都完成了获取`"Hello World"`字符串的第二个单词的第一个字母的功能：

  #code(
    ```typ
    #"Hello World".split(" ").at(1).split("").at(1)
    #array.at(str.split(array.at(str.split("Hello World", " "), 1), ""), 1)
    ```,
    al: top,
  )

  可以明显看见，第二行语句的参数已经散落在括号的里里外外，很难理解到底做了什么事情。

  其二，相比「函数调用」，「方法调用」更有利于现代IDE补全脚本。你可以通过`.split`很快定位到“字符串拆分”这个函数。

  其三，方便用户管理相似功能的函数。不仅仅是字符串可以拆分，似乎内容及其他许多类型也可以拆分。如果一一为它们取不同的名字，那可就太头疼了。相比，`str.split`就简单多了。要知道，很多程序员都非常头痛为不同的变量和函数取名。
]

// == 复合字面量

// ，它们是：
// + #term("array literal", postfix: "。")
// + #term("dictionary literal", postfix: "。")

== 数组字面量 <grammar-array-literal>

脚本模式中有两类核心复合字面量。

「数组」是按照顺序存储的一些「值」，你可以在「数组」中存放*任意内容*而不拘泥于类型。你可以使用圆括号与一个逗号分隔的列表创建一个*数组字面量*：

#code(```typ
#(1, "OvO", [一段内容])
```)

== 字典字面量 <grammar-dict-literal>

所谓「字典」即是「键值对」的集合，其每一项是由冒号分隔的「键值对」。如下例所示，冒号左侧，“neco-mimi”等「标识符」或「字符串」是字典的「键」，而冒号右侧分别是对应的「值」。

#code(```typ
#(neko-mimi: 2, "utterance": "喵喵喵")
```)

== 数组和字典的成员访问

为了访问数组，你可以使用`at`方法。“at”在中文里是“在”的意思，它表示对「数组」使用「索引」操作。`at(0)`索引到第1个值，`at(n)`索引到第 $n + 1$ 个值，以此类推。如下所示：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x.at(0), #x.at(1), #x.at(2)
```)

至于「索引」从零开始的原因，这只是约定俗成。等你习惯了，你也会变成计数从零开始的好程序员。

为了访问字典，你可以使用`at`方法。但由于「键」都是字符串，你需要使用字符串作为字典的「索引」。

#code(```typ
#let cat = (attribute: [kawaii\~])
#cat.at("attribute")
```)

为了方便，Typst允许你直接通过成员方法访问字典对应「键」的值： <grammar-dict-member-exp>

#code(```typ
#let cat = ("attribute": [kawaii\~])
#cat.attribute
```)

== 数组和字典的「存在谓词」

与数组相关的另一个重要语法是`in`，`x in (...)`，表示判断`x`是否*存在于*某个数组中：<grammar-array-in>

#code(```typ
#([一段内容] in (1, "OvO", [一段内容])) \
#([另一段内容] in (1, "OvO", [一段内容]))
```)

字典也可以使用此语法，表示判断`x`是否是字典的一个「键」。特别地，你还可以前置一个`not`判断`x`是否*不在*某个数组或字典中：<grammar-dict-in>

#code(```typ
#let cat = (neko-mimi: 2)
#("neko-kiki" not in cat)
```)

注意：`x in (...)`与`"x" in (...)`是不同的。例如`neko-mimi in cat`将检查`neko-mimi`变量的内容是否是字典变量`cat`的一个「键」，而`"neko-mimi"`检查对应字符串是否在其中。

== 数组和字典的「解构赋值」

除了使用字面量「构造」元素，Typst还支持「构造」的反向操作：「解构赋值」。顾名思义，你可以在左侧用相似的语法从数组<grammar-destruct-array>或字典中获取值并赋值到*对应*的变量上。<grammar-destruct-dict>

#code(```typ
#let (attr: a) = (attr: [kawaii\~])
#a
```)

「解构赋值」必须一一对应，但你也可以使用「占位符」（`_`）或「延展符」（`..`）以作*部分*解构：<grammar-destruct-array-eliminate>

#code(```typ
#let (first, ..) = (1, 2, 3)
#let (.., second-last, _) = (7, 8, 9, 10)
#first, #second-last
```)

数组的「解构赋值」有一个妙用，那就是重映射内容。<grammar-array-remapping>

#code(```typ
#let (a, b, c) = (1, 2, 3)
#let (b, c, a) = (a, b, c); #a, #b, #c
```)

特别地，如果两个变量相互重映射，这种操作被称为「交换」：<grammar-array-swap>

#code(```typ
#let (a, b) = (1, 2)
#((a, b) = (b, a)); #a, #b
```)

// field access
// - dictionary
// - symbol
// - module
// - content

== 数组和字典的典型构造

特别讲解一些关于数组与字典相关的典型构造：

#code(```typ
#() \ // 是空的数组
#(:) \ // 是空的字典
#(1) \ // 被括号包裹的整数1
#(()) \ // 被括号包裹的空数组
#((())) \ // 被括号包裹的被括号包裹的空数组
#(1,) \ // 是含有一个元素的数组
```)

`()`是空的数组<grammar-empty-array>，不含任何值。`(:)`是空的字典<grammar-empty-dict>，不含任何键值对。

如果括号内含了一个值，例如`(1)`，那么它仅仅是被括号包裹的整数1，仍然是整数1本身。

类似的，`(())`是被括号包裹的空数组<grammar-paren-empty-array>，`((()))`是被括号包裹的被括号包裹的空数组。

为了构建含有一个元素的数组，需要在列表末尾额外放置一个逗号以示区分，例如`(1,)`。<grammar-single-member-array>

// https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Trailing_commas
这种逗号被称为尾后逗号。

// todo: 改进
构造数组字面量时，允许尾随一个多余的逗号而不造成影响。

#code(```typ
#let x = (1, "OvO", [一段内容] , ); #x
//          这里有一个多余的逗号^^^
```)

构造字典字面量时，允许尾随一个多余的逗号。

#code(```typ
#let cat = (attribute: [kawaii\~], ); #cat
//             这里有一个尾随的小逗号^^
```)

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

=== 参数解构 <grammar-destructing-param>

#todo-box[写完]
todo参数解构。

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

