#import "mod.typ": *

#show: book.page.with(title: "内容、作用域与样式")

经历了三节入门教程，我们进入进阶教程。

在#(refs.writing-markup)[《编写一篇基本文档》]中，我们学到了很多各式各样的内容。我们学到了段落、标题、代码片段......

在#(refs.scripting-base)[《脚本基础》]和#(refs.scripting-complex)[《脚本进阶》]中我们学习了各式各样的脚本技巧。我们学到了字面量、变量、函数、控制流、闭包......

但是它们之间似乎隔有一层厚障壁，阻止了我们进行更高级的排版。是了，如果「内容」也是一种值，那么我们应该也可以使用脚本操控它们。Typst以排版为核心，应当也对「内容类型」有着精心设计。

本节主要介绍如何使用脚本排版内容。这也是Typst的核心功能，并在语法上*与很多其他语言有着不同之处*。

不用担心，在我们已经学了很多Typst语言的知识的基础上，本节也仅仅更进一步，教你如何以脚本视角看待一篇文档。

== 字数统计

从一个典型程序开始，这个程序基本解决我们一个需求：完成一段内容的字数统计。按照惯例，这一个程序涉及了本节所有的知识点。

```typ
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
    if it.double { "\"" } else { "'" }
  } else {
    " "
  }
}
```

以及基于其上实现一个字数统计函数：

```typ
#let word-count(it) = {
  plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
}
```

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
    if it.double { "\"" } else { "'" }
  } else {
    " "
  }
}
#let word-count(it) = {
  plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
}
#let code-scope = (plain-text: plain-text, word-count: word-count)

以下是该函数的表现：

#code(```typ
#let show-me-the(it) = {
  repr(plain-text(it))
  [ 的字数统计为 ]
  repr(word-count(it))
}
#show-me-the([])\
#show-me-the([一段文本]) \
#show-me-the([A bc]) \
#show-me-the([
  - 列表项1
  - 列表项2
])
```, scope: code-scope)

== 内容类型的特性 <content-type-feature>

我们已经学过很多内容：段落、标题、代码片段。

我们也知道所有的内容语法都可以使用相应的函数构造。例如标题：

#code(```typ
// 用语法构造标题
#repr([= 123]) \
// 用函数构造标题
#repr(heading(level: 1)[123])
// 展示
#heading(level: 1)[123]
```)

例如列表：

#code(```typ
// 用语法构造列表
#repr([- 1
- 2]) \
// 用函数构造列表
#repr(([1], [2]).map(list.item).join([ ]))
// 展示
#([1], [2]).map(list.item).join([ ])
```)

=== 特性一：所有内容函数构造出的值都被包装成「内容类型」

一个常见的误区是，使用以下方法判断一个内容是否为标题元素：

#code(```typ
标题是heading类型（伪）？#(type([= 123]) == heading)
```)

这引出了一个重要的理念，Typst中一切皆组合。Typst中目前没有继承概念，一切功能都是组合出来的，这类似于Rust语言的概念。你可能没有学过Rust语言，但这里有一个冷知识：

#align(center, [Typst $<=>$ Typ(setting Ru)st $<=>$ Typesetting Rust])

即Typst是以Rust语言特性为基础设计出的一个排版（Typesetting）语言。

当各式各样的内容函数接受参数时，它们会构造出「元素」，然后将元素包装成一个共同的类型：「内容类型」。

`heading`是函数而不是类型。与其他语言不同，没有一个`heading`类型继承`content`。因此不能使用`type([= 123]) == heading`判断一个内容是否为标题元素：

#code(```typ
标题函数的类型：#(type(heading)) \
标题的类型：#type([= 123])

内容类型与heading函数相等？#(type([= 123]) == heading)
```)

=== 特性二：内容类型的`func`方法

所有内容都允许使用`func`得到构造这个内容所使用的函数。因此，可以使用以下方法判断一个内容是否为标题元素：

#code(```typ
标题所使用的构造函数：#([= 123]).func()

标题的构造函数是`heading`？#(([= 123]).func() == heading)
```)

// 这一段不要了
// === 特性二点五：内容类型的`func`方法可以直接拿来用

// `func`方法返回的就是函数本身，自然也可以拿来使用：

// #code(```typ
// 重新构造标题：#(([= 123]).func())([456])
// ```)

// 这一般没什么用，但是有的时候可以用于得到一些Typst没有暴露出来的内容函数，例如`styled`。

// #code(```typ
// #let type_styled = text(fill: red, "").func()
// #let st = text(fill: blue, "").styles
// #text([abc], st)
// ```)

=== 特性三：内容类型的`fields`方法

Typst中一切皆组合，它将所有内容打包成「内容类型」的值以完成类型上的统一，而非类型继承。

但是这也有坏处，坏处是无法“透明”访问内部内容。例如，我们可能希望知道`heading`的级别。如果不提供任何方法访问标题的级别，那么我们就无法编程完成与之相关的排版。

为了解决这个问题，Typst提供一个`fields`方法提供一个content的部分信息：

#code(```typ
#([= 123]).fields()
```)

`fields()`将部分信息组成字典并返回。如上图所示，我们可以通过这个字典对象进一步访问标题的内容和级别。

#code(```typ
标题有`level`：#("level" in ([= 123]).fields()) \
标题的`level`是：#([= 123]).fields().at("level") \
```)

#pro-tip[
  这里的“部分信息”描述稍显模糊。具体来说，Typst只允许你直接访问内容中不受样式影响的信息，至少包含语法属性。如下：

  #code(al: top, ````typ
  #let x = [= 123]
  #rect([#x <the-heading>])
  #x.fields() \
  #locate(loc => query(<the-heading>, loc))
  ````)
]

通过`query`我们获得同一个内容上更多的信息，即「样式」属性，即内容上的那些可选函数参数。

根据上述例子，我们来理解为什么它只提供了语法属性。假设只看`= 123`这5个字符，显然我们从*语法*上只能获得两个信息：
+ 它是一级标题。
+ 它的内容是`123`。

与之相对，当一个标题真正被放置到一个具体的「上下文」中时，才能真正关联与之相关的样式属性。例如，标题的`numbering`字段是与上下文相关的。

=== 特性四：内容类型与`fields`相关的方法糖 <grammar-content-member-exp>

由于我们经常需要与`fields`交互，Typst提供了`has`方法帮助我们判断一个内容的`fields`是否有相关的「键」。

#code(```typ
使用`... in x.fields()`判断：#("text" in `x`.fields()) \
等同于使用`has`方法判断：#(`x`.has("text"))
```)

Typst提供了`at`方法帮助我们访问一个内容的`fields`中键对应的值。

#code(```typ
使用`x.fields().at()`获取值：#(`www`.fields().at("text")) \
等同于使用`at`方法：#(`www`.at("text"))
```)

特别地，内容的成员包含`fields`的键，我们可以直接通过成员访问相关信息：

#code(```typ
使用`at`方法：#(`www`.at("text")) \
等同于访问`text`成员：#(`www`.text)
```)

// - location()

== 内容的 「样式」

文本是段落的重要组成部分，与之对应的内容函数是`text`。

我们知道一个函数可以有各种参数。那么我们从函数视角来看，内容的样式便由这些函数参数决定。

例如，我们想要获得一段蓝色的文本：

#code(```typ
#text("一段文本", fill: blue)
```)

`fill: blue`是函数的参数，指定了文本的样式。

这个视角有助于我们更好的将对「样式」的需求转换为对函数的操控。

例如，我们可以使用函数的`with`方法，获得一个固定样式的文本函数：

#code(```typ
#let warning = text.with(fill: orange)
#warning[警告，你做个人吧]
```)

== 「`set`」语法 <grammar-set>

一个段落主要是一个内容序列，其中有可能很多个文本。

#code(```typ
#repr([一段很长的话可能不止包含......一个文本！])
```)

假设我们想要让一整个段落都显示成蓝色，显然不能将文本一个个用`text.with(fill: blue)`构造好再组装起来。

这个时候「`set`」语法出手了。「`set`」关键字后可以跟随一个函数调用，为影响范围内所有函数关联的对应内容设置对应参数。

#code(```typ
#set text(fill: blue)
一段很长的话可能不止包含......一个文本！
- 似乎，列表中也有文本。
```)

重点：「`set`」的影响范围是其所在「作用域」内的后续内容。

我们紧接着来讲与之相关的，Typst中最重要的概念之一：「作用域」。

== 内容块与代码块的「作用域」 <grammar-scope>

// 内容块与代码块没有什么不同。

「作用域」是一个非常抽象的概念。但是理解他也并不困难。我们需要记住一件事，那就是每个「代码块」创建了一个单独的「作用域」：

#code(```typ
两只#{
  [兔]
  set text(fill: rgb("#ffd1dc").darken(15%))
  {
    [兔白]
    set text(fill: orange)
    [又白]
  }
  [，真可爱]
}
```)

从上面的染色结果来看，粉色规则可以染色到`[兔白]`、`[又白]`和`[真可爱]`，橘色规则可以染色到`[又白]`但不能染色到[，真可爱]。以内容的视角来看：
1. `[兔]`不是相对粉色规则的后续内容，更不是相对橘色规则的后续内容，所以它默认是黑色。
2. `[兔白]`是相对粉色规则的后续内容，所以它是粉色。
3. `[又白]`同时被两个规则影响，但是根据「执行顺序」，橘色规则被优先使用。
4. `[真可爱]`虽然从代码先后顺序来看在橘色规则后面，但不在橘色规则所在作用域内，不满足「`set`」影响范围的设定。

我们说「`set`」的影响范围是其所在「作用域」内的后续内容，意思是：对于每个「代码块」，「`set`」规则只影响到从它自身语句开始，到该「代码块」的结束位置。

接下来，我们回忆：「内容块」和「代码块」没有什么不同。上述例子还可以以「内容块」的语法改写成：

#code(```typ
两只#[兔#set text(fill: rgb("#ffd1dc").darken(15%))
  #[兔白#set text(fill: orange)
  又白]，真可爱
]
```)

由于断行问题，这不方便阅读，但从结果来看，它们确实是等价的。

针对「内容块」，我们重申一遍「`set`」的影响范围。其影响等价于：对于每个「内容块」，「`set`」规则只影响到从它自身语句开始，到该「内容块」的结束位置。

最后我们再回忆：文件本身是一个「内容块」。

#code(```typ
两小只，#set text(fill: orange)
真可爱
```)

针对文件，我们仍重申一遍「`set`」的影响范围。其影响等价于：对于文件本身，*顶层*「`set`」规则影响到该文件的结束位置。

== 「`set if`」语法 <grammar-set-if>

假设我们脚本中设置了当前文档是否处于暗黑主题，并希望使用「`set`」规则感知这个设定，你可能会写：

#code(```typ
#let is-dark-theme = true
#if is-dark-theme {
  set rect(fill: black)
  set text(fill: white)
}

#rect([wink!])
```)

根据我们的知识，这应该不起作用，因为`if`后的代码块创建了一个新的作用域，而「`set`」规则只能影响到该代码块内后续的代码。但是`if`的`then`和`else`一定需要创建一个新的作用域，这有点难办了。

`set if`语法出手了，它允许你在当前作用域设置规则。

#code(```typ
#let is-dark-theme = true
#set rect(fill: black) if is-dark-theme
#set text(fill: white) if is-dark-theme
#rect([wink!])
```)

解读`#set rect(fill: black) if is-dark-theme`。它的意思是，如果满足`is-dark-theme`条件，那么设置相关规则。这其实与下面代码“感觉”一样。

#code(```typ
#let is-dark-theme = true
#if is-dark-theme {
  set rect(fill: black)
}
#rect([wink!])
```)

区别仅仅在`set if`语法确实从语法上没有新建一个作用域。这就好像一个“规则怪谈”：如果你想要让「`set`」规则影响到对应的内容，就想方设法满足「`set`」影响范围的要求。

== 「内容」是一棵树

Typst对代码块有着的一系列语法设计，让代码块非常适合描述内容。又由于作用域的性质，最终代码块让「内容」形成为一颗树。

「内容」是一棵树。一个`main.typ`就是「内容」的一再嵌套。

#code(al: top, ```typ
#let main-typ() = {
  [= 生活在Content树上]
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  }
  [滥觞于家庭与社会传统的期望正失去它们的借鉴意义。]
  {
    [但面对看似无垠的未来天空，我想循卡尔维诺]
    [“树上的男爵”]
    [的生活好过过早地振翮。]
  }
  parbreak()
  [...]
  parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#main-typ()
```)

== 回顾`plain-text`，以及递归函数

回想`plain-text`，它正是在树上递归遍历：

```typ
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
    if it.double { "\"" } else { "'" }
  } else {
    " "
  }
}
```

所谓递归，就是函数体中包含它自身的函数调用。例如这里，`plain-text(it.body)`便再度调用了`plain-text`函数。

首先它使用了`has`函数，以及`fields`中对应键的值做了三件事情：

如果一个内容有孩子，那么对其每个孩子都继续调用`plain-text`函数并组合在一起：

```typ
#if it.has("children") {
  ("", ..it.children.map(plain-text)).join()
}
```

否则如果一个内容有子内容，那么访问其子内容：

```typ
#if it.has("child") {
  plain-text(it.child)
} else if it.has("body") {
  plain-text(it.body)
}
```

否则如果一个内容有字符串内容，那么返回其字符串内容：

```typ
#if it.has("text") {
  it.text
}
```

这里值得注意的是，`it.text`具有多态行为。即便没有继承，这里通过一定动态特性，允许我们同时访问「代码片段」的`text`和「文本」的text。例如：

#code(```typ
#let plain-text-mini(it) = if it.has("text") {
  it.text
}
#repr(plain-text-mini(`代码片段中的text`)) \
#repr(plain-text-mini([文本中的text]))
```)

紧接着我们还使用了`func`方法，对一些特殊的内容做了特殊处理。

```typ
#if it.func() == smartquote {
  if it.double { "\"" } else { "'" }
} 
```

至此，我们已经完全讲明了`plain-text`的实现。

#pro-tip[
  利用「内容」与「树」的特性，我们可以在Typst中设计出更多优雅的脚本功能。
]

=== CeTZ的「树」

CeTZ利用内容树制作“内嵌的DSL”。CeTZ的`canvas`函数接收的不完全是内容，而是内容与其IR的混合。

例如它的`line`函数的返回值，就完全不是一个内容，而是一个无法窥视的函数。

#code(```typ
#import "@preview/cetz:0.2.0"
#repr(cetz.draw.line((0, 0), (1, 1), fill: blue))
```)

当你产生一个“混合”的内容并将其传递给`cetz.canvas`，CeTZ就会像`plain-text`一样遍历你的混合内容，并加以区分和处理。如果遇到了他自己特定的IR，例如`cetz.draw.line`，便将其以特殊的方式转换为真正的「内容」。

使用混合语言，在Typst中可以很优雅地画多面体：

#code(al: top, ```typ
#import "@preview/cetz:0.2.0"
#align(center, cetz.canvas({
  // 导入cetz的draw方言
  import cetz.draw: *
  let neg(u) = if u == 0 { 1 } else { -1 }
  for (p, c) in (
    ((0, 0, 0), black), ((1, 1, 0), red),
    ((1, 0, 1), blue), ((0, 1, 1), green),
  ) {
    line(cetz.vector.add(p, (0, 0, neg(p.at(2)))), p, stroke: c)
    line(cetz.vector.add(p, (0, neg(p.at(1)), 0)), p, stroke: c)
    line(cetz.vector.add(p, (neg(p.at(0)), 0, 0)), p, stroke: c)
  }
}))
```)

=== PNG.typ的树

我们知道「内容块」与「代码块」没有什么本质区别。

如果我们可以基于「代码块」描述一棵「内容」的树，那么一张PNG格式的图片似乎也可以被描述为一棵「字节」的树。

通过代码块语法，你可以在Typst中拼接字节，依像素地创建一张PNG格式的图片：

#code(al: top, ```typ
// Origin: https://typst.app/project/r0SkRmsZYIYNxjs6Q712aP
#import "png.typ": *
#let prelude = (0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
#let ihdr(w, h) = chunk("IHDR", be32(w) + be32(h) + (8, 2, 0, 0, 0))
#let idat(lines) = chunk("IDAT", {
    (0x08, 0x1D, 0x01)
    let data = lines.map(line => (0x00,) + line).flatten()
    let len = le32(data.len()).slice(0, 2)
    len
    len.map(xor.with(0xFF))
    data
    be32(adler32(data))
})
#align(center, box(width: 25%, image.decode(bytes({
  let (w, h) = (8, 8)
  prelude
  ihdr(w, h)
  idat(for y in range(h) {
    let line = for x in range(w) {
      (calc.floor(256 * x / w), 128, calc.floor(256 * y / h))
    }
    (line,)
  })
  chunk("IEND", ())
}))))
```)

== 「`show`」语法 <grammar-show>

「`set`」语法是「`show set`」语法的简写。因此显然，相比`set`，「`show`」语法可以更强大。<grammar-show-set>

#code(```typ
#show: set text(fill: blue)
wink!
```)

我们可以看到「`show`」语法由两部分组成，由冒号分隔。

`show`的右半部分是一个函数，表示选择文档的一部分以作修改。你可能会问，先姑且不问函数要怎么写，难道`set text(fill: blue)`也能算一个函数吗？

事实上，`set`规则是「内容类型」，它接受一个样式和一个内容，返回一个`styled`内容：

#code(```typ
#let x = [#set text(fill: blue)]
#x.func()
```)

以下使用方法非常黑客，请最好不要在你的文档中包含这种代码。仅用于理解：

#code(```typ
#let styled = [#set text(fill: blue)].func()
#let styles = text("", fill: red).styles
#styled([Red Text], styles)
```)

1. 第一行代码，我们说`func`方法返回内容函数本身，这里便返回了一个内部的函数`styled`。
2. 第二行代码，这里我们从`text`内容上找到了它关于设置红色文本的样式（参数）。
3. 第三行代码，把一个内容及一个无论如何从某处得到了的样式传递给`styled`函数。
4. 最终我们构造出了一个真实的红色文本。

`show`的左半部分是选择器，表示选择文档的一部分以作修改。它作用于「作用域」内的*后续*所有*被选择器选中*的内容。

如果选择器为空，则默认选择*后续所有*内容。这也是「`set`」语法对应规则的原理。如果选择器不为空，那么因为我们还没讲解选择器，所以这里不作过多讲解。

但有一种选择器比较简单易懂。我们可以将内容函数作为选择器，选择相应内容作影响。

以下脚本设置所有代码片段的颜色：

#code(```typ
#show raw: set text(fill: blue)
被秀了的`代码片段`！
```)

以下脚本设置所有数学公式的颜色，但同时也修改代码片段的颜色：

#code(```typ
#show raw: set text(fill: red)
#show math.equation: set text(fill: blue)
#let dif2(x) = math.op(math.Delta + $x$)
一个公式：$ sum_(f in S(x)) #[`refl`]\(f) dif2(x) $
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

在#link(<content-type-feature>)[《内容类型的特性》]中，我们所接触到的*已经打包*（packed）的代码片段并不包含`lines`字段。在打包后，内部大部分信息已经被屏蔽了。

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

== 「`include`」语法 <grammar-include>

介绍`read`，`eval(mode)`。

路径分为相对路径和绝对路径。如果是相对路径，`read("other-file.typ")`相当于在*当前*文件夹寻找对对应的文件。

`include`的本质就是`eval(read("other-file.typ", mode: "markup"))`，获得一个「内容」，*插入到原地*。

假设我们有一个文件：

#code(```typ
// 以下是other-file.typ文件的内容
一段文本
#set text(fill: red)
另一段文本
```)

那么```typ #include "other-file.typ"```将获得该文件的「内容」，*插入到原地*。

#code(```typ
#{
  set text(fill: blue)
  include "other-file.typ"
}
#include "other-file.typ"
```)

`include`的文件是一个「内容块」，自带一个作用域。

== `plain-text`与「`show`」规则

思考题：为什么在`show`规则影响下，`plain-text`和`word-count`分别输出对应内容？

#code(```typ
#let show-me-the(it) = {
  repr(plain-text(it))
  [ 的字数统计为 ]
  repr(word-count(it))
}
#show-me-the([#show: it => {"123"; it}; 一段文本]) \
```, scope: code-scope)

