#import "mod.typ": *

#show: book.page.with(title: "编译流程")

经过几节稍显枯燥的脚本教程，我们继续回到排版本身。

在#(refs.writing-markup)[《初识标记模式》]中，我们学到了段落、标题、代码片段等各式各样的内容。

接着我们又花费了几节的篇幅，讲授了各式各样的脚本技巧。我们学到了字面量、变量、闭包......

但是它们之间似乎隔着一层厚障壁，阻止了我们进行更高级的排版。是了，如果「内容」也是一种值，那么我们应该也可以更随心所欲地使用脚本操控它们。Typst以排版为核心，应当也对「内容类型」有着精心设计。

本节主要介绍如何使用脚本排版内容。这也是Typst的核心功能，并在语法上*与很多其他语言有着不同之处*。不用担心，在我们已经学了很多Typst语言的知识的基础上，本节也仅仅更进一步，教你如何真正以脚本视角看待一篇文档。

纵览Typst的编译流程，其大致分为4个阶段：解析、求值、排版和导出。

// todo: 介绍Typst的多种概念

// Source Code
// Value
// Type
// Content

// todo: 简化下面的图片
#import "../figures.typ": figure-typst-arch
#align(center + horizon, figure-typst-arch())

// todo: 补充说明各阶段层层缓存。

为了把源码变成可排版的内容，Typst会先解析并求值你的代码。有趣的是，我们之前已经学过这个函数。它就是#typst-func("eval")。

#code(```typ
#repr(eval("#[一段内容]", mode: "markup"))
```)

流程图展现了编译阶段间的关系，也包含了「表达式」与「内容」两个概念之间的关系。

- #typst-func("eval")输入：在解析阶段，*代码字符串*被解析成一个语法结构，即「表达式」。古人云，世界是一个巨大的表达式。作为世界的一部分，Typst文档本身也是一个巨大的表达式。事实上，它就是我们前面提及的「内容块」。文档本身是一个内容块，由一个个标记串联形成。

- #typst-func("eval")输出：在求值阶段，「表达式」被计算成方便排版引擎操作的值，即「材料」（material）。用TeX黑话来说，文档被“解析和评估”完了之后，就成为了一个个材料；排版引擎再接过这些材料，计算布局、合成样式并生成页面。

一般来说，我们所谓的表达式是诸如`1+1`的算式，而对其求值则是做算术。

#code(```typ
#eval("1+1")
```)

显然，如果意图是让排版引擎输出计算结果，让排版引擎直接排版`2`要比排版“1+1”更简单。

但是对于整个文档，要如何理解对内容块的求值？这就引入了「可折叠」的值（Foldable）的概念。「可折叠」正是块能够作为表达式的基础。

== Typst的主函数

在Typst的源代码中，有一个Rust函数直接对应整个编译流程，其内容非常简短，主要便是调用两个阶段对应的函数。“求值”阶段（`eval`阶段）对应执行一个Rust函数，它的名称为`typst::eval`；“内容排版”阶段（`typeset`阶段）对应执行另一个Rust函数，它的名称为`typst::typeset`。

```rs
pub fn compile(world: &dyn World) -> SourceResult<Document> {
    // Try to evaluate the source file into a module.
    let module = crate::eval::eval(world, &world.main())?;
    // Typeset the module's content, relayouting until convergence.
    typeset(world, &module.content())
}
```

从代码逻辑上来看，它有明显的先后顺序，似乎与我们所展示的架构略有不同：`typst::eval`的输出为一个文件模块`module`；`typst::typeset`仅接受文件的内容`module.content()`，并产生一个已经排版好的文档对象`typst::Document`。

== 「`eval`阶段」与「`typeset`阶段」

现在我们介绍Typst的完整架构。

当Typst接收到一个编译请求时，它会使用「解析器」（Parser）从`main`文件开始解析整个项目；对于每个文件，Typst使用「评估器」（Evaluator）执行脚本并得到「内容」；对于这些「内容」，Typst再使用「排版引擎」（Typesetting Engine）计算布局与合成样式。

当一切布局与样式都计算好后，Typst将最终结果导出为各种格式的文件，例如PDF格式。

这个主函数只展示了最核心的先后顺序。回看前面的流程图，若把解析、求值、排版和导出都展开，Typst大致上分为四个执行阶段。这四个执行阶段并不完全相互独立，但有明显的先后顺序。

接下来，我们着重讲解“表达式求值”阶段与“内容排版”阶段。

“求值”阶段，`eval`函数将一个字符串对象「评估」为「内容」：

#code(```typ
以代码模式评估：#eval("repr(str(1 + 1))") \
以标记模式评估：#eval("repr(str(1 + 1))", mode: "markup") \
以标记模式评估2：#eval("#show: it => [c] + it + [t];a", mode: "markup")
```)

#todo-box[根本没讲“内容排版”]

由于技术原因，Typst并不提供对应“内容排版”阶段的函数。如果有的话，这个函数的名称大概会是`typeset`。已经有很多地方介绍了潜在的`typeset`函数：
+ #link("https://github.com/andreasKroepelin/polylux")[Polylux]、#link("https://github.com/touying-typ/touying")[Touying]等演示文档（PPT）框架需要将一部分内容固定为已经排版好的结果。
+ Typst的作者在其博客中提及#link("https://laurmaedje.github.io/posts/frozen-state/")[Frozen State]的可能性。
  + 其中一个例子就是演示文档框架中的数学公式编号。
  + 即便不涉及用户需求，Typst的排版引擎也已经天然存在Frozen State的需求。
+ 本文档也有类似需求：展示特定页面的最终结果，而不影响全局状态。

== 延迟执行

架构图中还有两个关键的反向箭头，疑问顿生：这两个反向箭头是如何产生的？

我们首先关注与本节直接相关的「样式化」内容。当`eval`阶段结束时，「`show`」语法将会对应产生一个`styled`元素，其包含了被设置样式的内容，以及设置样式的「回调」：

#code(```typ
内容是：#repr({show: set text(fill: blue); [abc]}) \
样式无法描述，但它在这里：#repr({show: set text(fill: blue); [abc]}.styles)
```)

也就是说`eval`并不具备任何排版能力，它只能为排版准备好各种“素材”，并把素材交给排版引擎完成排版。

这里的「回调」术语很关键：它是一个计算机术语。所谓「回调函数」就是一个被暂存起来的计算（“即函数右侧的表达式”），它会在后续执行过程的合适时机“回过头来被计算”。例如，我们写了一个这样的「`show`」规则：

#code(```typ
#repr({
  show raw: content => layout(parent => if parent.width > 100pt {
    set text(fill: red); content
  } else {
    content
  })
  `a`
})
```)

这里`parent.width > 100pt`是说当且仅当父元素的宽度大于`100pt`时，才为该代码片段设置红色字体样式。其中，`parent.width`与排版相关。因此，`eval`自然也不知道该如何评估该条件的真正结果。*计算因此被停滞*。

于是，`eval`干脆将整个`show`右侧的函数都作为“素材”交给了排版引擎。当排版引擎计算好了相关布局信息，才回头调用评估器，执行这一小部分“素材”函数中的脚本，得到正确的内容。我们可以看出，`show`右侧的函数*被延后执行*。

这种被延后执行零次、一次或多次的函数便被称为「回调函数」。相关的计算方法也有对应的术语，被称为「延迟执行」。

我们对每个术语咬文嚼字一番，它们都很准确：

1. *「表达式求值」*阶段仅仅“评估”出*「内容排版」*阶段所需的素材。*「评估器」*并不具备排版能力。
2. 对于依赖排版产生的内容，「表达式求值」产生包含*「回调函数」*的内容，让「排版引擎」在合适的时机“回过头来调用”。
3. 相关的计算方法又被称为*「延迟执行」*。因为现在不具备执行条件，所以延迟到条件满足时才继续执行。

现在我们可以理解两个反向箭头是如何产生的了。它们来自下一阶段对上一阶段的回调，用于完成阶段之间复杂的协作。评估阶段可能会`import`或`include`文件，这时会重新让解析器解析文件的字符串内容。排版阶段也可能会继续根据`styled`等元素产生复杂的内容，这时则依靠评估器执行脚本并产生或改变内容。

== 模拟Typst的执行

我们来模拟一遍上述示例的执行，以加深理解：

#code(```typ
#show raw: content => layout(parent => if parent.width < 100pt {
  set text(fill: red); content
} else {
  content
})
#box(width: 50pt, `a`)
`b`
```)

首先进行表达式求值得到：

```typ
#styled((box(width: 50pt, `a`), `b`), styles: content => ..)
```

排版引擎遇到``` `a` ```。由于``` `a` ```是`raw`元素，它「回调」了对应`show`规则右侧的函数。待执行的代码如下：

```typc
layout(parent => if parent.width < 100pt {
  set text(fill: red); `a`
} else {
  `a`
})
```

此时`parent`即为`box(width: 50pt)`。排版引擎将这个`parent`的具体信息交给「评估器」，待执行的代码如下：

```typc
if box(width: 50pt).width < 100pt {
  set text(fill: red); `a`
} else {
  `a`
}
```

由于此时父元素（`box`元素）宽度只有`50pt`，评估器进入了`then`分支，并为代码片段设置了红色样式。内容变为：

```typ
#(box(width: 50pt, {set text(fill: red); `a`}), styled((`b`, ), styles: content => ..))
```

待执行的代码如下：

```typc
set text(fill: red); text("a", font: "monospace")
```

排版引擎遇到``` `a` ```中的`text`元素。由于其是`text`元素，「回调」了`text`元素的「`show`」规则。记得我们之前说过`set`是一种特殊的`show`，于是排版引擎执行了`set text(fill: red)`。

```typ
#(box(width: 50pt, text(fill: red, "a", ..)), styled((`b`, ), styles: content => ..))
```

排版引擎离开了`show`规则右侧的函数，该函数调用由``` `a` ```触发。同时`set text(fill: red)`规则也被解除，因为离开了相关作用域。

回到文档顶层，待执行的代码如下：

```typc
#show raw: ...
`b`
```

排版引擎遇到``` `b` ```，再度「回调」了对应`show`规则右侧的函数。由于此时父元素（`page`元素，即整个页面）宽度有`500pt`，我们没有为代码片段设置样式。

```typ
#(box(width: 50pt, text(fill: red, "a", ..)), text("b", ..))
```

至此，文档的内容已经准备好「导出」（Export）了。

#pro-tip[
  有时候`show`规则会原地执行，这属于一种细节上的优化，例如：

  #code(```typ
  #repr({ show: it => it; [a] }) \
  #repr({ show: it => [c] + it + [d]; [a] })
  ```)

  这个时候`show`规则不会对应一个`styled`元素。

  这种优化告诉你前面手动描述的过程仅作理解。一旦涉及更复杂的环境，Typst的实际执行过程就会产生诸多变化。因此，你不应该依赖以上某步中排版引擎的瞬间状态。这些瞬间状态属于「未文档化细节」(undocumented details)，并随时有可能在未来被破坏。
]
