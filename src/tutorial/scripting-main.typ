#import "mod.typ": *

#show: book.page.with(title: "编译流程")

#todo-box[本节处于校对阶段，所以可能存在不完整或错误。]

经过几节稍显枯燥的脚本教程，我们继续回到排版本身。

在#(refs.writing-markup)[《初识标记模式》]中，我们学到了很多各式各样的内容。我们学到了段落、标题、代码片段......

接着我们又花费了三节的篇幅，讲授了各式各样的脚本技巧。我们学到了字面量、变量、闭包......

但是它们之间似乎隔有一层厚障壁，阻止了我们进行更高级的排版。是了，如果「内容」也是一种值，那么我们应该也可以更随心所欲地使用脚本操控它们。Typst以排版为核心，应当也对「内容类型」有着精心设计。

本节主要介绍如何使用脚本排版内容。这也是Typst的核心功能，并在语法上*与很多其他语言有着不同之处*。不用担心，在我们已经学了很多Typst语言的知识的基础上，本节也仅仅更进一步，教你如何真正以脚本视角看待一篇文档。

纵览Typst的编译流程，其大致分为4个阶段，解析、求值、排版和导出。

// todo: 介绍Typst的多种概念

// Source Code
// Value
// Type
// Content

// todo: 简化下面的的图片
#import "../figures.typ": figure-typst-arch
#align(center + horizon, figure-typst-arch())

// ，层层有缓存

为了方便排版，Typst首先使用了一个函数“解析和评估”你的代码。有趣地是，我们之前已经学过了这个函数。事实上，它就是#typst-func("eval")。

#code(```typ
#repr(eval("#[一段内容]", mode: "markup"))
```)

流程图展现了编译阶段间的关系，也包含了本节「块」与「表达式」两个概念之间的关系。

- #typst-func("eval")输入：在文件解析阶段，*代码字符串*被解析成一个语法结构，即「表达式」。古人云，世界是一个巨大的表达式。作为世界的一部分，Typst文档本身也是一个巨大的表达式。事实上，它就是我们在上一章提及的「内容块」。文档的本身是一个内容块，其由一个个标记串联形成。

- #typst-func("eval")输出：在内容排版阶段，排版引擎事实不作任何计算。用TeX黑话来说，文档被“解析和评估”完了之后，就成为了一个个「材料」（material）。排版引擎将材料。

在求值阶段。「表达式」被计算成一个方便排版引擎操作的值，即「材料」。一般来说，我们所谓的表达式是诸如`1+1`的算式，而对其求值则是做算数。

#code(```typ
#eval("1+1")
```)

显然，如果意图是让排版引擎输出计算结果，让排版引擎直接排版2要比排版“1+1”更简单。

但是对于整个文档，要如何理解对内容块的求值？这就引入了「可折叠」的值（Foldable）的概念。「可折叠」成为块作为表达式的基础。

== Typst的主函数

在Typst的源代码中，有一个Rust函数直接对应整个编译流程，其内容非常简短，便是调用了两个阶段对应的函数。“求值”阶段（`eval`阶段）对应执行一个Rust函数，它的名称为`typst::eval`；“内容排版”阶段（`typeset`阶段）对应执行另一个Rust函数，它的名称为`typst::typeset`。

```rs
pub fn compile(world: &dyn World) -> SourceResult<Document> {
    // Try to evaluate the source file into a module.
    let module = crate::eval::eval(world, &world.main())?;
    // Typeset the module's content, relayouting until convergence.
    typeset(world, &module.content())
}
```

从代码逻辑上来看，它有明显的先后顺序，似乎与我们所展示的架构略有不同。其`typst::eval`的输出为一个文件模块`module`；其`typst::typeset`仅接受文件的内容`module.content()`并产生一个已经排版好的文档对象`typst::Document`。

== 「`eval`阶段」与「`typeset`阶段」

现在我们介绍Typst的完整架构。

当Typst接受到一个编译请求时，他会使用「解析器」（Parser）从`main`文件开始解析整个项目；对于每个文件，Typst使用「评估器」（Evaluator）执行脚本并得到「内容」；对于每个「内容」，Typst使用「排版引擎」（Typesetting Engine）计算布局与合成样式。

当一切布局与样式都计算好后，Typst将最终结果导出为各种格式的文件，例如PDF格式。

我们回忆上一节讲过的内容，Typst大致上分为四个执行阶段。这四个执行阶段并不完全相互独立，但有明显的先后顺序：

#import "../figures.typ": figure-typst-arch
#align(center + horizon, figure-typst-arch())

我们在上一节着重讲解了前两个阶段。这里，我们着重讲解“表达式求值”阶段与“内容排版”阶段。

事实上，Typst直接在脚本中提供了对应“求值”阶段的函数，它就是我们之前已经介绍过的函数`eval`。你可以使用`eval`函数，将一个字符串对象「评估」为「内容」：

#code(```typ
以代码模式评估：#eval("repr(str(1 + 1))") \
以标记模式评估：#eval("repr(str(1 + 1))", mode: "markup") \
以标记模式评估2：#eval("#show: it => [c] + it + [t];a", mode: "markup")
```)

由于技术原因，Typst并不提供对应“内容排版”阶段的函数，如果有的话这个函数的名称应该为`typeset`。已经有很多地方介绍了潜在的`typeset`函数：
+ #link("https://github.com/andreasKroepelin/polylux")[Polylux], #link("https://github.com/touying-typ/touying")[Touying]等演示文档（PPT）框架需要将一部分内容固定为特定结果的能力。
+ Typst的作者在其博客中提及#link("https://laurmaedje.github.io/posts/frozen-state/")[Frozen State
  ]的可能性。
  + 他提及数学公式的编号在演示文档框架。
  + 即便不涉及用户需求，Typst的排版引擎已经自然存在Frozen State的需求。
+ 本文档也需要`typeset`的能力为你展示特定页面的最终结果而不影响全局状态。

== 延迟执行

架构图中还有两个关键的反向箭头，疑问顿生：这两个反向箭头是如何产生的？

我们首先关注与本节直接相关的「样式化」内容。当`eval`阶段结束时，「`show`」语法将会对应产生一个`styled`元素，其包含了被设置样式的内容，以及设置样式的「回调」：

#code(```typ
内容是：#repr({show: set text(fill: blue); [abc]}) \
样式无法描述，但它在这里：#repr({show: set text(fill: blue); [abc]}.styles)
```)

也就是说`eval`并不具备任何排版能力，它只能为排版准备好各种“素材”，并把素材交给排版引擎完成排版。

这里的「回调」术语很关键：它是一个计算机术语。所谓「回调函数」就是一个临时的函数，它会在后续执行过程的合适时机“回过头来被调用”。例如，我们写了一个这样的「`show`」规则：

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

这里`parent.width > 100pt`是说当且仅当父元素的宽度大于`100pt`时，才为该代码片段设置红色字体样式。其中，`parent.width`与排版相关。那么，自然`eval`也不知道该如何评估该条件的真正结果。*计算因此被停滞*。

于是，`eval`干脆将整个`show`右侧的函数都作为“素材”交给了排版引擎。当排版引擎计算好了相关内容，才回到评估阶段，执行这一小部分“素材”函数中的脚本，得到为正确的内容。我们可以看出，`show`右侧的函数*被延后执行*可。

这种被延后执行零次、一次或多次的函数便被称为「回调函数」。相关的计算方法也有对应的术语，被称为「延迟执行」。

我们对每个术语咬文嚼字一番，它们都很准确：

1. *「表达式求值」*阶段仅仅“评估”出*「内容排版」*阶段所需的素材.*「评估器」*并不具备排版能力。
2. 对于依赖排版产生的内容，「表达式求值」产生包含*「回调函数」*的内容，让「排版引擎」在合适的时机“回过头来调用”。
3. 相关的计算方法又被称为*「延迟执行」*。因为现在不具备执行条件，所以延迟到条件满足时才继续执行。

现在我们可以理解两个反向箭头是如何产生的了。它们是下一阶段的回调，用于完成阶段之间复杂的协作。评估阶段可能会`import`或`include`文件，这时候会重新让解析器解析文件的字符串内容。排版阶段也可能会继续根据`styled`等元素产生复杂的内容，这时候依靠评估器执行脚本并产生或改变内容。

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

此时`parent`即为`box(width: 50pt)`。排版引擎将这个`parent`的具体内容交给「评估器」，待执行的代码如下：

```typc
if box(width: 50pt).width < 100pt {
  set text(fill: red); `a`
} else {
  `a`
}
```

由于此时父元素（`box`元素）宽度只有`50pt`，评估器进入了`then`分支，其为代码片段设置了红色样式。内容变为：

```typ
#(box(width: 50pt, {set text(fill: red); `a`}), styled((`b`, ), styles: content => ..))
```

待执行的代码如下：

```typc
set text(fill: red); text("a", font: "monospace")
```

排版引擎遇到``` `a` ```中的`text`元素。由于其是`text`元素，「回调」了`text`元素的「`show`」规则。记得我们之前说过`set`是一种特殊的`show`，于是排版器执行了`set text(fill: red)`。

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

  这种优化告诉你前面手动描述的过程仅作理解。一旦涉及更复杂的环境，Typst的实际执行过程就会产生诸多变化。因此，你不应该依赖以上某步中排版引擎的瞬间状态。这些瞬间状态将产生「未注明特性」(undocumented details)，并随时有可能在未来被打破。
]
