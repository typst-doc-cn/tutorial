#import "mod.typ": *

#show: book.page.with(title: "文档树")

#todo-box[本节处于校对阶段，所以可能存在不完整或错误。]

== 「可折叠」的值（Foldable）

先来看代码块。代码块其实就是一个脚本。既然是脚本，Typst就可以按照语句顺序依次执行「语句」。

#pro-tip[
  准确地来说，按照控制流顺序。
]

Typst按控制流顺序执行代码，将所有结果*折叠*成一个值。所谓折叠，就是将所有数值“连接”在一起。这样讲还是太抽象了，来看一些具体的例子。

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
  ", Destroy"; " "; "World"; "." // destroy; space; world; "."
}
```

将结果收集并“折叠”，得到结果：

#code(```typc
#(none + none + none + "Hello" + " " + "World" + none + ", Destroy" + " " + "World" + ".")
```)

#pro-tip[
  还有其他可以折叠的值，例如，数组与字典也是可以折叠的：

  #code(```typ
  #for i in range(1, 5) { (i, i * 10) }
  ```)

  #code(```typ
  #for i in range(1, 5) { let d = (:); d.insert(str(i), i * 10); d }
  ```)
]

=== 其他基本类型的情况

那么为什么说折叠操作基本就是#mark("+")操作。那么就是说有的“#mark("+")操作”并非是折叠操作。

布尔值、整数和浮点数都不能相互折叠：

```typ
// 不能编译
#{ false; true }; #{ 1; 2 }; #{ 1.; 2. }
```

那么是否说布尔值、整数和浮点数都不能折叠呢。答案又是否认的，它们都可以与```typc none```折叠（把下面的加号看成折叠操作）：

#code(```typ
#(1 + none)
```)

所以你可以保证一个代码块中只有一个「语句」产生布尔值、整数或浮点数结果，这样的代码块就又是能编译的了。让我们利用`let _ = `来实现这一点：

#code(```typ
#{ let _ = 1; true },
#{ let _ = false; 2. }
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

```typ
#[
  = 生活在Content树上
  现代社会以海德格尔的一句“一切实践传统都已经瓦解完了”为嚆矢。滥觞于家庭与社会传统的期望正失去它们的借鉴意义。但面对看似无垠的未来天空，我想循卡尔维诺“树上的男爵”的生活好过过早地振翮。
]
```

由于Typst默认以「标记模式」开始解释你的文档，这又与省略`#[]`的写法等价：

```typ
= 生活在Content树上
现代社会以海德格尔的一句“一切实践传统都已经瓦解完了”为嚆矢。滥觞于家庭与社会传统的期望正失去它们的借鉴意义。但面对看似无垠的未来天空，我想循卡尔维诺“树上的男爵”的生活好过过早地振翮。
```

#pro-tip[
  实际上有区别，由于多两个换行和缩进，前后各多一个Space Element。
]

// == Hello World程序

// 有的时候，我们想要访问字面量、变量与函数中存储的“信息”。例如，给定一个字符串```typc "Hello World"```，我们想要截取其中的第二个单词。

// 单词`World`就在那里，但仅凭我们有限的脚本知识，却没有方法得到它。这是因为字符串本身是一个整体，虽然它具备单词信息，我们却缺乏了*访问*信息的方法。

// Typst为我们提供了「成员」和「方法」两种概念访问这些信息。使用「方法」，可以使用以下脚本完成目标：

// #code(```typ
// #"Hello World".split(" ").at(1)
// ```)

// 为了方便讲解，我们改写出6行脚本。除了第二行，每一行都输出一段内容：

// #code(```typ
// #let x = "Hello World"; #x \
// #let split = str.split
// #split(x, " ") \
// #str.split(x, " ") \
// #x.split(" ") \
// #x.split(" ").at(1)
// ```)

// 从```typ #x.split(" ").at(1)```的输出可以看出，这一行帮助我们实现了“截取其中的第二个单词”的目标。我们虽然隐隐约约能揣测出其中的意思：

// ```typ
// #(       x .split(" ")           .at(1)          )
// // 将字符串 根据字符串拆分  取出其中的第2个单词（字符串）
// ```

// 但至少我们对#mark(".")仍是一无所知。

// 本节我们就来讲解Typst中较为高级的脚本语法。这些脚本语法与大部分编程语言的语法相同，但是我们假设你并不知道这些语法。

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

== 内容类型 <content-type-feature>

我们已经学过很多元素：段落、标题、代码片段等。这些元素在被创建后都会被包装成为一种被称为「内容」的值。这些值所具有的类型便被称为「内容类型」。同时「内容类型」提供了一组公共方法访问元素本身。

乍一听，内容就像是一个“容器”将元素包裹。但内容又不太像是之前所学过的数组或字典那样的复合字面量，或者说这样不方便理解。事实上，每个元素都有各自的特点，但仅仅为了保持动态性，所有的元素都被硬凑在一起，共享一种类型。有两种理解这种类型的视角：从表象论，「内容类型」是一种鸭子类型；从原理论，「内容类型」提供了操控内容的公共方法，即它是一种接口，或称特征（Trait）。

=== 特性一：元素包装于「内容」

我们知道所有的元素语法都可以等价使用相应的函数构造。例如标题：

#code(```typ
#repr([= 123]) \ // 语法构造
#repr(heading(depth: 1)[123]) // 函数构造

```)

一个常见的误区是误认为元素继承自「内容类型」，进而使用以下方法判断一个内容是否为标题元素：

#code(```typ
标题是heading类型（伪）？#(type([= 123]) == heading)
```)

但两者类型并不一样。事实上，元素是「函数类型」，元素函数的返回值为「内容类型」。

#code(```typ
标题函数的类型：#(type(heading)) \
标题的类型：#type([= 123])
```)

这引出了一个重要的理念，Typst中一切皆组合。Typst中目前没有继承概念，一切功能都是组合出来的，这类似于Rust语言的概念。你可能没有学过Rust语言，但这里有一个冷知识：

#align(center, [Typst $<=>$ Typ(setting Ru)st $<=>$ Typesetting Rust])

即Typst是以Rust语言特性为基础设计出的一个排版（Typesetting）语言。

当各式各样的元素函数接受参数时，它们会构造出「元素」，然后将元素包装成一个共同的类型：「内容类型」。`heading`是函数而不是类型。与其他语言不同，没有一个`heading`类型继承`content`。因此不能使用`type([= 123]) == heading`判断一个内容是否为标题元素。

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
#([= 123]).fields().at("depth")
```)

#pro-tip[
  这里的“部分信息”描述稍显模糊。具体来说，Typst只允许你直接访问元素中不受样式影响的信息，至少包含语法属性，而不允许你*直接*访问元素的样式。

  // 如下：

  // #code.with(al: top)(````typ
  // #let x = [= 123]
  // #rect([#x <the-heading>])
  // #x.fields() \
  // #locate(loc => query(<the-heading>, loc))
  // ````)
]

=== 特性四：内容类型与`fields`相关的糖 <grammar-content-member-exp>

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
