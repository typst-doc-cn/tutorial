#import "mod.typ": *

#show: book.page.with(title: "样式链")

== 内容的「样式」

我们接下来循着文本样式的脉络学习排版内容的语法。

重点1：文本是段落的重要组成部分，与之对应的内容函数是`text`。

我们知道一个函数可以有各种参数。那么我们从函数视角来看，内容的样式便由创建时参数的内容决定。例如，我们想要获得一段蓝色的文本：

#code(```typ
#text("一段文本", fill: blue)
```)

`fill: blue`是函数的参数，指定了文本的样式。

这个视角有助于我们更好的将对「样式」的需求转换为对函数的操控。例如，我们可以使用函数的`with`方法，获得一个固定样式的文本函数：

#code(```typ
#let warning = text.with(fill: orange)
#warning[警告，你做个人吧]
```)

== 上下文有关表达式

// contextual expression

在介绍重要语法之前，我们先来一道开胃菜。

#code(```typ
#context text.size
```)

== 「`set`」语法 <grammar-set>

重点2：一个段落主要是一个内容序列，其中有可能很多个文本。

#code(```typ
#repr([不止包含......一个文本！])
```)

假设我们想要让一整个段落都显示成蓝色，显然不能将文本一个个用`text.with(fill: blue)`构造好再组装起来。这个时候「`set`」语法出手了。「`set`」关键字后可以跟随一个函数调用，为影响范围内所有函数关联的对应内容设置对应参数。

#code(```typ
#set text(fill: blue)
一段很长的话可能不止包含......一个文本！
- 似乎，列表中也有文本。
```)

重点：「`set`」的影响范围是其所在「作用域」内的后续内容。

我们紧接着来讲与之相关的，Typst中最重要的概念之一：「作用域」。

== 「内容」是一棵树

重点3：「内容」是一棵树，这意味着你可以“攀树而行”。

Typst对代码块有着的一系列语法设计，让代码块非常适合描述内容。又由于作用域的性质，最终代码块让「内容」形成为一颗树。

「内容」是一棵树。一个`main.typ`就是「内容」的一再嵌套。即便不使用任何标记语法，你也可以创建一个文档：

#code.with(al: top)(```typ
#let main-typ() = {
  heading("生活在Content树上")
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  } + parbreak()
  [...] + parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#main-typ()
```)

// == 「样式链」

// 理解「作用域」对

== `plain-text`，以及递归函数

如果我们想要实现一个函数`plain-text`，它将一段文本转换为字符串。它便可以在树上递归遍历：

```typ
#let plain-text(it) = if it.has("text") {
  it.text
} else if it.has("children") {
  ("", ..it.children.map(plain-text)).join()
} else if it.has("child") {
  plain-text(it.child)
} else { ... }
```

所谓递归是一种特殊的函数实现技巧：
- 递归总有一个不调用其自身的分支，称其为递归基。这里递归基就是返回`it.text`的分支。
- 函数体中包含它自身的函数调用。例如，`plain-text(it.child)`便再度调用了自身。

这个函数充分利用了内容类型的特性实现了遍历。首先它使用了`has`函数检查内容的成员。

如果一个内容有孩子，那么对其每个孩子都继续调用`plain-text`函数并组合在一起：

```typ
#if it.has("children") { ("", ..it.children.map(plain-text)).join() }
#if it.has("child") { plain-text(it.child) }
```

限于篇幅，我们没有提供`plain-text`的完整实现，你可以试着在课后完成。

== 鸭子类型

这里值得注意的是，`it.text`具有多态行为。即便没有继承，这里通过一定动态特性，允许我们同时访问「代码片段」的`text`和「文本」的text。例如：

#code(```typ
#let plain-mini(it) = if it.has("text") { it.text }
#repr(plain-mini(`代码片段中的text`)) \
#repr(plain-mini([文本中的text]))
```)

这也便是我们在「内容类型」小节所述的鸭子类型特性。如果「内容」长得像文本（鸭子），那么它就是文本。

== 「内容」是一棵树（Cont.）

#pro-tip[
  利用「内容」与「树」的特性，我们可以在Typst中设计出更多优雅的脚本功能。
]

=== CeTZ的「树」

CeTZ利用内容树制作“内嵌的DSL”。CeTZ的`canvas`函数接收的不完全是内容，而是内容与其IR的混合。

例如它的`line`函数的返回值，就完全不是一个内容，而是一个无法窥视的函数。

#code(```typ
#import "@preview/cetz:0.3.4"
#repr(cetz.draw.line((0, 0), (1, 1), fill: blue))
```)

当你产生一个“混合”的内容并将其传递给`cetz.canvas`，CeTZ就会像`plain-text`一样遍历你的混合内容，并加以区分和处理。如果遇到了他自己特定的IR，例如`cetz.draw.line`，便将其以特殊的方式转换为真正的「内容」。

使用混合语言，在Typst中可以很优雅地画多面体：

#code.with(al: top)(```typ
#import "@preview/cetz:0.3.4"
#align(center, cetz.canvas({
  // 导入cetz的draw方言
  import cetz.draw: *; import cetz.vector: add
  let neg(u) = if u == 0 { 1 } else { -1 }
  for (p, c) in (
    ((0, 0, 0), black), ((1, 1, 0), red), ((1, 0, 1), blue), ((0, 1, 1), green),
  ) {
    line(add(p, (0, 0, neg(p.at(2)))), p, stroke: c)
    line(add(p, (0, neg(p.at(1)), 0)), p, stroke: c)
    line(add(p, (neg(p.at(0)), 0, 0)), p, stroke: c)
  }
}))
```)

=== curryst的「树」

我们知道「内容块」与「代码块」没有什么本质区别。

如果我们可以基于「代码块」描述一棵「内容」的树，那么逻辑推理的过程也可以被描述为条件、规则、结论的树。

#link("https://typst.app/universe/package/curryst/")[curryst]包提供了接收条件、规则、结论参数的`rule`函数，其返回一个包含传入信息的`dict`，并且允许把`rule`函数返回的`dict`作为`rule`的部分参数。于是我们可以通过嵌套`rule`函数建立描述推理过程的树，并通过该包提供的`prooftree`函数把包含推理过程的`dict`树画出来：

#code(```typ
#import "@preview/curryst:0.5.0": rule, prooftree
#let tree-dict = rule(
  name: $R$,
  $C_1 or C_2 or C_3$,
  rule(
    name: $A$,
    $C_1 or C_2 or L$,
    rule(
      $C_1 or L$,
      $Pi_1$,
    ),
  ),
  rule(
    $C_2 or overline(L)$,
    $Pi_2$,
  ),
)
`tree-dict`的类型：#type(tree-dict) \
`tree-dict`代表的树：#prooftree(tree-dict)
```)

== 「`show`」语法 <grammar-show>

「`set`」语法是「`show set`」语法的简写。因此，「`show`」语法显然可以比`set`更强大。<grammar-show-set>

#code(```typ
#show: set text(fill: blue)
wink!
```)

我们可以看到「`show`」语法由两部分组成，由冒号分隔。

`show`的右半部分是一个函数，表示选择文档的一部分以作修改。

#pro-tip[
  你可能会问，先姑且不问函数要怎么写，难道`set text(fill: blue)`也能算一个函数吗？

  事实上，`set`规则是「内容类型」，它接受一个样式和一个内容，返回一个`styled`内容：

  #code(```typ
  #let x = [#set text(fill: blue)]
  #x.func()
  ```)

  以下使用方法非常黑客，请最好不要在你的文档中包含这种代码。仅用于理解：

  #code(```typ
  #let styled = [#set text(blue)].func()
  #let styles = text("", red).styles
  #styled([Red Text], styles)
  ```)

  1. 第一行代码，我们说`func`方法返回内容函数本身，这里便返回了一个内部的函数`styled`。
  2. 第二行代码，这里我们从`text`内容上找到了它关于设置红色文本的样式（参数）。
  3. 第三行代码，把一个内容及一个无论如何从某处得到了的样式传递给`styled`函数。
  4. 最终我们构造出了一个真实的红色文本。

]

`show`的左半部分是选择器，表示选择文档的一部分以作修改。它作用于「作用域」内的*后续*所有*被选择器选中*的内容。

如果选择器为空，则默认选择*后续所有*内容。这也是「`set`」语法对应规则的原理。如果选择器不为空，那么因为我们还没讲解选择器，所以这里不作过多讲解。

但有一种选择器比较简单易懂。我们可以将内容函数作为选择器，选择相应内容作影响。

以下脚本设置所有代码片段的颜色：

#code(```typ
#show raw: set text(fill: blue)
被秀了的`代码片段`！
```)

以下脚本设置所有数学公式的颜色，但同时也修改代码片段的颜色：

// todo: ugly code
#code(```typ
#show raw: set text(red)
#show math.equation: set text(blue)
#let dif2(x) = math.op(math.Delta + $x$)
一个公式：$ sum_(f in S(x))
  #`refl`;(f) dif2(x) $
```)

我们说，`show`的右半部分是一个函数，表示选择文档的一部分以作修改。除了直接应用`set`，应该可以有很多其他操作。现在是时候解锁Typst强大能力了。

这个函数接受一个参数：参数是*未打包*（unpacked）的内容；这个函数返回一个*任意*内容。

以下示例说明它接受一个*未打包*的内容。对于代码片段，我们使用「`show`」语法择区其中第二行：

#code(````typ
#show raw: it => it.lines.at(1)
获取代码片段第二行内容：```typ
#{
set text(fill: true)
}
```
````)

在《内容类型的特性》中，我们所接触到的*已经打包*（packed）的代码片段并不包含`lines`字段。在打包后，内部大部分信息已经被屏蔽了。

以下示例说明它可以返回*任意*内容。这里我们选择语言为`my-calc`的代码片段，执行并返回一个*非代码片段*：

#code(````typ
#show raw.where(lang: "my-calc"): it => eval(it.text)
嵌入一个计算器语言，计算`1*2+2*(2+3)`：```my-calc 1*2+2*(2+3)```
````)

由于`show`的右半部分只要求接受内容并返回内容，我们可以有非常优雅的写法，使用一些天然满足要求的函数。

以下规则将每个代码片段用方框修饰：

#code(````typ
#show raw: rect
``` QwQ ```
````)

以下规则将每个代码片段用蓝色方框修饰：

#code(````typ
#show raw: rect.with(stroke: blue)
``` QwQ ```
````)

// == 内容的「实例化过程」

// 通过`query`我们获得同一个内容上更多的信息，即「样式」属性，即内容上的那些可选函数参数。

// 根据上述例子，我们来理解为什么它只提供了语法属性。假设只看`= 123`这5个字符，显然我们从*语法*上只能获得两个信息：
// + 它是一级标题。
// + 它的内容是`123`。

// 与之相对，当一个标题真正被放置到一个具体的「上下文」中时，才能真正关联与之相关的样式属性。例如，标题的`numbering`字段是与上下文相关的。

// - location()

// == import/include/styled

// == 「`include`」语法 <grammar-include>

// 介绍`read`，`eval(mode)`。

// 路径分为相对路径和绝对路径。如果是相对路径，`read("other-file.typ")`相当于在*当前*文件夹寻找对对应的文件。

// `include`的本质就是`eval(read("other-file.typ", mode: "markup"))`，获得一个「内容」，*插入到原地*。

// 假设我们有一个文件：

// #code(```typ
// // 以下是other-file.typ文件的内容
// 一段文本
// #set text(fill: red)
// 另一段文本
// ```)

// 那么```typ #include "other-file.typ"```将获得该文件的「内容」，*插入到原地*。

// #code(```typ
// #{
//   set text(fill: blue)
//   include "other-file.typ"
// }
// #include "other-file.typ"
// ```)

// `include`的文件是一个「内容块」，自带一个作用域。

== 总结

本节仅以文本、代码块和内容块为例讲清楚了文件、作用域、「set」语法和「show」语法。为了拓展广度，你还需要查看《基本参考》中各种元素的用法，这样才能随心所欲排版任何「内容」。

== 习题

// == 字数统计

// 从一个典型程序开始，这个程序基本解决我们一个需求：完成一段内容的字数统计。按照惯例，这一个程序涉及了本节所有的知识点。

// ```typ
// #let plain-text(it) = {
//   if it.has("children") {
//     ("", ..it.children.map(plain-text)).join()
//   } else if it.has("child") {
//     plain-text(it.child)
//   } else if it.has("body") {
//     plain-text(it.body)
//   } else if it.has("text") {
//     it.text
//   } else if it.func() == smartquote {
//     if it.double { "\"" } else { "'" }
//   } else {
//     " "
//   }
// }
// ```

// 以及基于其上实现一个字数统计函数：

// ```typ
// #let word-count(it) = {
//   plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
// }
// ```

// 以下是该函数的表现：

// #code.with(scope: code-scope)(```typ
// #let show-me-the(it) = {
//   repr(plain-text(it))
//   [ 的字数统计为 ]
//   repr(word-count(it))
// }
// #show-me-the([])\
// #show-me-the([一段文本]) \
// #show-me-the([A bc]) \
// #show-me-the([
//   - 列表项1
//   - 列表项2
// ])
// ```)

#let plain-text(it) = {
  if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else if it.has("body") {
    plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else if it.func() == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else {
    " "
  }
}
#let word-count(it) = {
  plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
}

#let code-scope = (plain-text: plain-text, word-count: word-count)

#let q1 = ````typ
#let plain-text(it) = {
  if type(it) == str {
    it
  } else if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else if it.has("body") {
    plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else if it.func() == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else {
    " "
  }
}
#let main-typ() = {
  heading("生活在Content树上")
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  } + parbreak()
  [...] + parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#plain-text(main-typ())
````

#exercise[
  实现内容到字符串的转换`plain-text`：对于文中出现的`main-typ()`内容，它输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#let plain-text(it) = {
  if type(it) == str {
    it
  } else if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else if it.has("body") {
    plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else if it.func() == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else {
    " "
  }
}
#let word-count(it) = {
  plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
}
#let main-typ() = {
  heading("生活在Content树上")
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  } + parbreak()
  [...] + parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#word-count(main-typ())
````

#exercise[
  实现字数统计`word-count`：对于文中出现的`main-typ()`内容，它输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#exercise[
  思考题：`plain-text`有何局限性？为什么在`show`规则影响下，`word-count`输出分别为4和5？

  #code.with(scope: code-scope)(```typ
  #let show-me-the(it) = {
    it + [ 的字数统计为#word-count(it) ]
  }
  #show-me-the([#show raw: it => {"123"; it}; `一段文本`]) \
  #show-me-the([#show: it => {"123"; it}; 一段文本])
  ```)
][
  #q1
]
