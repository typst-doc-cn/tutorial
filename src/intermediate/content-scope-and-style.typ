#import "mod.typ": *

#show: book.page.with(title: "内容、作用域与样式")

经历了三节入门教程，本章也已经到达中段。

在#(refs.writing)[《编写一篇基本文档》]中，我们学到了很多各式各样的内容。我们学到了段落、标题、代码片段......

在#(refs.scriping-base)[《脚本基础》]和#(refs.scriping-complex)[《脚本进阶》]中我们学习了各式各样的脚本技巧。我们学到了字面量、变量、函数、控制流、闭包......

但是它们之间似乎隔有一层厚障壁，阻止了我们进行更高级的排版。是了，如果「内容」也是一种值，那么我们应该也可以使用脚本操控它们。那么，Typst以排版为核心，应当也对「内容类型」有着精心设计。

本节主要介绍如何使用脚本排版内容。这也是Typst的核心功能，并在语法上*与很多其他语言有着不同之处*。

不用担心，在我们已经学了很多Typst语言的知识的基础上，本节也仅仅更进一步，教你如何以脚本视角看待一篇文档。

== 字数统计

从一个典型程序开始，这个程序基本解决我们一个需求：完成一段内容的字数统计。按照惯例，这一个程序涉及了本节所有的知识点。

```typ
#let plain-text(it) = {
  if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
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
```

注意：你不应该在日常生活中使用`plain-text`字数统计，因为它并不能将一个内容有效转换成文本。当然，本节同样也会告诉你为什么它不是有效的。

#let plain-text(it) = {
  if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
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

测试：

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

== 类型自省

todo: repr, type

#code(```typ
#type(heading[123]) \
#type(raw("456")) \
#type(list("456")) \
#type(([123 []])) \

#type(heading[].func())
```)

== 内容类型的特性

// #repr(plain-text("Hello World"))

// #repr(plain-text([一段内容]))

// #repr(plain-text([一段内容]))

#code(```typ
#repr(heading[123]) \
#repr(raw("456")) \
#repr(list("456")) \
#repr(([123 []])) \

#repr(heading[].func())
```)

- func()
- has()
- at()
- fields()
- location()

略

== 内容的 「样式」

`text(fill: blue)`中，函数的参数就是样式。

略

== 「`with`」方法

`text.with(fill: blue)`是样式为蓝色的文本。

略

== 「`set`」语法

`set text(fill: blue)`将作用域之后所有的文本样式设置为蓝色。

略

== 内容块与代码块的作用域

介绍什么是作用域。内容块与代码块本质是一回事。set只能影响块内后续的内容。

略

== 「内容」是一棵树

「内容」是一棵树。一个`main.typ`就是「内容」的一再嵌套。

#code(```typ
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

== 递归函数

回想`plain-text`，它正是在树上递归遍历：

```typ
#let plain-text(it) = {
  if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
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
```

== 利用「内容」与「树」的特性

=== CeTZ的「树」

CeTZ利用内容树制作“内嵌的DSL”。

#code(```typ
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

你可以在Typst中依像素地创建一张PNG格式的图片：

#code(```typ
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

== 「`show`」语法

略

== 「`include`」语法

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

`include`自带一个作用域。
