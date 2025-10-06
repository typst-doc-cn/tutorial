#import "mod.typ": *

#show: book.page.with(title: [标记模式])

Typst是一门简明但强大的现代排版语言，你可以使用简洁直观的语法排版出好看的文档。

Typst希望你总是尽可能少的配置样式，就获得一个排版精良的文档。多数情况下，你只需要专心撰写文档，而不需要在文档内部对排版做任何更复杂的调整。

得益于此设计目标，为了使你可以用Typst编写一篇基本文档，本节仍只需涉及最基本的语法。哪怕只依靠这些语法，你已经可以编写满足很多场合需求的文档。

== 段落 <grammar-paragraph>

普通文本默认组成一个个段落。

#code(```typ
我是一段文本
```)

另起一行文本不会产生新的段落。为了创建新的段落，你需要空至少一行。

#code(```typ
轻轻的我走了，
正如我轻轻的来；

我轻轻的招手，
作别西天的云彩。
```)

缩进并不会产生新的空格：

#code(```typ
  轻轻的我走了，
      正如我轻轻的来；

  我轻轻的招手，
      作别西天的云彩。
```)

注意：如下图的蓝框高亮所示，另起一行会引入一个小的空格。该问题会在未来修复。

#code(
  ```typ
  轻轻的我走了，#box(fill: blue, outset: (right: 0.2em), sym.space)
  正如我轻轻的来；

  轻轻的我走了，正如我轻轻的来；
  ```,
  code-as: ```typ
  轻轻的我走了，
  正如我轻轻的来；

  轻轻的我走了，正如我轻轻的来；
  ```,
)

== 标题 <grammar-heading>

你可以使用一个或多个*连续*的#mark("=")开启一个标题。

#code(```typ
= 一级标题
我走了。
== 二级标题
我来了。
=== 三级标题
我走了又来了。
```)

等于号的数量恰好对应了标题的级别。一级标题由一个#mark("=")开启，二级标题由两个#mark("=")开启，以此类推。

注意：正如你所见，标题会强制划分新的段落。

#pro-tip[
  使用show规则可以改变“标题会强制划分新的段落”这个默认规则。

  #code(```typ
  #show heading.where(level: 3): box
  = 一级标题
  我走了。

  === 三级标题
  我走了又来了。
  ```)
]

== 着重和强调语义

有许多与#mark("=")类似的语法标记。当你以相应的语法标记文本内容时，相应的文本就被赋予了特别的语义和样式。

#pro-tip[
  与HTML一样，Typst总是希望语义先行。所谓语义先行，就是在编写文档时总是首先考虑标记语义。所有样式都是附加到语义上的。

  例如在英文排版中，#typst-func("strong")的样式是加粗，#typst-func("emph")的样式是倾斜。你完全可以在中文排版中为它们更换样式。

  #if is-web-target {
    code(```typ
    #show strong: content => {
      show regex("\p{Hani}"): it => box(place(text("·", size: 0.8em), dx: 0.1em, dy: 0.75em) + it)
      content.body
    }
    *中文排版的着重语义用加点表示。*
    ```)
  } else {
    code(```typ
    #show strong: content => {
      show regex("\p{Hani}"): it => box(place(text("·", size: 1.3em), dx: 0.3em, dy: 0.5em) + it)
      content.body
    }
    *中文排版的着重语义用加点表示。*
    ```)
  }
]

与许多标记语言相同，Typst中使用一系列#term("delimiter")规则确定一段语义的开始和结束。为赋予语义，需要将一个#term("delimiter")置于文本*之前*，表示某语义的开始；同时将另一个#term("delimiter")置于文本*之后*，表示该语义的结束。

例如，#mark("*")作为定界符赋予所包裹的一段文本以#term("strong semantics")。 <grammar-strong>

#code(```typ
着重语义：这里有一个*重点！*
```)

与#term("strong semantics")类似，#mark("_")作为定界符将赋予#term("emphasis semantics")： <grammar-emph>

#code(```typ
强调语义：_emphasis_
```)

着重语义一般比强调语义语气更重。着重和强调语义可以相互嵌套：

#code(```typ
着重且强调：*_strong emph_* 或 _*strong emph*_
```)

注意：中文排版一般不使用斜体表示着重或强调。

== （计算机）代码片段 <grammar-raw>

Typst的#term("raw block")标记语法与Markdown完全相同。

配对的#mark("`")包裹一段内容，表示内容为#term("raw block")。

#code(````typ
短代码片段：`code`
````)

有时候你希望允许代码内容包含换行或#mark("`")。这时候，你需要使用*至少连续*三个#mark("`")组成定界符标记#term("raw block")：<grammar-long-raw>

#code(`````typ
使用三个反引号包裹：``` ` ```

使用四个反引号包裹：```` ``` ````
`````)

对于长代码片段，你还可以在起始定界符后*紧接着*指定该代码的语言类别，以便Typst据此完成语法高亮。<grammar-lang-raw>

#code(`````typ
一段有高亮的代码片段：```javascript function uninstallLaTeX {}```

另一段有高亮的代码片段：````typst 包含反引号的长代码片段：``` ` ``` ````
`````)

除了定界符的长短，代码片段还有是否成块的区分。如果代码片段符合以下两点，那么它就是一个#term("blocky raw block")： <grammar-blocky-raw>
+ 使用*至少连续*三个#mark("`")，即其需为长代码片段。
+ 内容包含至少一个#term("line break")。

#code(`````typ
非块代码片段：```rust trait World```

块代码片段：```js
function fibnacci(n) {
  return n <= 1 ?: `...`;
}
```
`````)

// typ
// typc

== 列表

Typst的列表语法与Markdown非常类似，但*不完全相同*。

一行以#mark("-")开头即开启一个无编号列表项： <grammar-enum>

#code(```typ
- 一级列表项1
```)

与之相对，#mark("+")开启一个有编号列表项。 <grammar-list>

#code(```typ
+ 一级列表项1
```)

利用缩进控制列表项等级：

#code(```typ
- 一级列表项1
  - 二级列表项1.1
    - 三级列表项1.1.1
  - 二级列表项1.2
- 一级列表项2
  - 二级列表项2.1
```)

有编号列表项可以与无编号列表项相混合。<grammar-mix-list-emum>

#code(```typ
+ 一级列表项1
  - 二级列表项1.1
    + 三级列表项1.1.1
  - 二级列表项1.2
+ 一级列表项2
  - 二级列表项2.1
```)

和Markdown相同，Typst同样允许使用显式的编号`1.`开启列表。这方便对列表继续编号。<grammar-continue-list>

#code(```typ
1. 列表项1
1. 列表项2
```)

#code(```typ
1. 列表项1
+  列表项2

列表间插入一段描述。

3. 列表项3
+  列表项4
+  列表项5
```)

== 转义序列 <grammar-escape-sequences>

你有时希望直接展示标记符号本身。例如，你可能想直接展示一个#mark("_")，而非使用强调语义。这时你需要利用#term("escape sequences")语法：

#code(````typ
在段落中直接使用下划线 >\_<！
````)

遵从许多编程语言的习惯，Typst使用#mark("\\")转义特殊标记。下表给出了部分可以转义的字符：

#let escaped-sequences = (
  (`\\`, [\\]),
  (`\/`, [\/]),
  (`\[`, [\[]),
  (`\]`, [\]]),
  (`\{`, [\{]),
  (`\}`, [\}]),
  (`\<`, [\<]),
  (`\>`, [\>]),
  (`\(`, [\(]),
  (`\)`, [\)]),
  (`\#`, [\#]),
  (`\*`, [\*]),
  (`\_`, [\_]),
  (`\+`, [\+]),
  (`\=`, [\=]),
  (`\~`, [\~]),
  // @typstyle off
  (```\` ```, [\`]),
  (`\$`, [\$]),
  (`\"`, [\"]),
  (`\'`, [\']),
  (`\@`, [\@]),
  (`\a`, [\a]),
  (`\A`, [\A]),
)

#let mk-tab(seq) = {
  set align(center)
  let u = it => raw(it.at(0).text, lang: "typ")
  let ovo = it => it.at(1)
  let w = 8
  table(
    columns: w + 2,
    [代码],
    ..seq.slice(w * 0, w * 1).map(u),
    u((`\u{cccc}`, [\u{cccc}])),
    [效果],
    ..seq.slice(w * 0, w * 1).map(ovo),
    [\u{cccc}],
    [代码],
    ..seq.slice(w * 1, w * 2).map(u),
    u((`\u{cCCc}`, [\u{cCCc}])),
    [效果],
    ..seq.slice(w * 1, w * 2).map(ovo),
    [\u{cCCc}],
    [代码],
    ..seq.slice(w * 2).map(u),
    [],
    u((`\u{2665}`, [\u{2665}])),
    [效果],
    ..seq.slice(w * 2).map(ovo),
    [],
    [\u{2665}],
  )
}

#mk-tab(escaped-sequences)

以上大部分#term("escape sequences")都紧跟单个字符，除了表中的最后一列。 <grammar-unicode-escape-sequences>

表中的最后一列所展示的`\u{unicode}`语法被称为Unicode转义序列，也常见于各种语言。你可以通过将`unicode`替换为#link("https://zh.wikipedia.org/zh-cn/%E7%A0%81%E4%BD%8D")[Unicode码位]的值，以输出该特定字符，而无需*输入法支持*。例如，你可以这样输出一句话：

#code(
  ````typ
  \u{9999}\u{8FA3}\u{725B}\u{8089}\u{7C89}\u{597D}\u{5403}\u{2665}
  ````,
  code-as: ````typ
  \u{9999}\u{8FA3}\u{725B}\u{8089}\u{7C89}
  \u{597D}\u{5403}\u{2665}
  ````,
)

诸多#term("escape sequences")无需死记硬背，你只需要记住：
+ 如果其在Typst中已经被赋予含义，请尝试在字符前添加一个#mark("\\")。
+ 如果其不可见或难以使用输入法获得，请考虑使用`\u{unicode}`。

== 输出换行符 <grammar-newline>

输出换行符是一种特殊的#term("escape sequences")，它使得文档输出换行。

#mark("\\")后紧接一个任意#term("whitespace")，表示在此处主动插入一个段落内的换行符： <grammar-newline-by-space>

#code(````typ
转义空格可以换行 \ 转义回车也可以换行 \
换行！
````)

空白字符可以取短空格（`U+0020`）、长空格（`U+3000`）、回车（`U+000D`）等。

== 速记符号 <grammar-shorthand>

在#term("markup mode")下，一些符号需要用特殊的符号组合打出，这种符号组合被称为#term("shorthand")。它们是：

空格（`U+0020`）的#term("shorthand")是#mark("~")： <grammar-shorthand-space>

#code(```typ
AB v.s. A~B
```)

连接号（en dash, `U+2013`）的#term("shorthand")由两个连续的#mark("hyphen")组成：

#code(```typ
北京--上海路线的列车正在到站。
```)

// 破折号的#term("shorthand")由三个连续的#mark("hyphen")组成（有问题，毋用，请直接使用em dash，`—`）：

// #code(```typ
// 你的生日------四月十八日------每年我总记得。\
// 你的生日——四月十八日——每年我总记得。
// ```)

省略号的#term("shorthand")由三个连续的#mark(".")组成：

#code(```typ
真的假的......
```)

// - minusi
// -? soft-hyphen

完整的速记符号列表参考#link("https://typst.app/docs/reference/symbols/")[Typst Symbols]。

== 注释 <grammar-inline-comment>

Typst的#term("comment")直接采用C语言风格的注释语法，有两种表示方法。

第一种写法是将注释内容放在两个连续的#mark("/")后面，从双斜杠到行尾都属于#term("comment")。

#code(````typ
// 这是一行注释
一行文本 // 这也是注释
````)

与代码片段的情形类似，Typst也提供了另外一种可以跨行的#term("comment")，形如`/*...*/`。<grammar-cross-line-comment>

#code(````typ
你没有看见/* 混入其中 */注释
````)

值得注意的是，Typst会将#term("comment")从源码中剔除后再解释你的文档，因此它们对文档没有影响。

以下两个段落等价：

#code(````typ
注释不会
// 这是一行注释 // 注释内的注释还是注释
插入换行 // 这也是注释

注释不会
插入换行
````)

以下三个段落等价：

#code(````typ
注释不会/* 混入其中 */插入空格

注释不会/*
混入其中
*/插入空格

注释不会插入空格
````)

== 总结

基于《初识标记模式》掌握的知识，你应该编写一些非常简单的文档。

== 习题

#let q1 = ````typ
欲穷千里目，/*
*/更上一层楼。
````

#exercise[
  使源码至少有两行，第一行包含“欲穷千里目，”，第二行包含“更上一层楼。”，但是输出不换行不空格：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#exercise[
  输出一个#mark("*")，期望的输出：#rect(width: 100%)[\*]
][
  ```typ
  \*
  ```
]

#let q1 = ````typ
```
`
```
````

#exercise[
  插入代码片段使其包含一个反引号，期望的输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ```typ

```

#let q1 = `````typ
````
```
````
`````

#exercise[
  插入代码片段使其包含三个反引号，期望的输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
你可以在Typst内通过插件 ```typc plugin("typst.wasm")``` 调用Typst编译器。
````

#exercise[
  插入行内的“typc”代码，期望的输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q2 = ```typ
约法五章。
1. 其一。
+ 其二。

前两条不算。

3. 其三。
+ 其四。
+ 其五。
```

#exercise[
  在有序列表间插入描述，期望的输出：#rect(width: 100%, eval(q2.text, mode: "markup"))
][
  #q2
]
