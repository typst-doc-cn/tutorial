#import "mod.typ": *

#show: book.page.with(title: "维护和查询文档状态")

在上一节中我们理解了作用域，也知道如何简单把「`show`」规则应用于文档中的部分内容。

它看起来似乎已经足够强大。但还有一种可能，Typst可以给你更强大的原语。

我是说有一种可能，Typst对文档内容的理解至少是二维的。这二维，有一维可以比作空间，另一维可以比作时间。你可以从文档的任意位置，
+ 空间维度（From Space to Space）：查询文档任意部分的状态（这里的内容和那里的内容）。
+ 时间维度（From TimeLoc to TimeLoc）：查询文档任意脚本位置的状态（过去的状态和未来的状态）。

这里有一个示意图，红色线段表示Typst脚本的执行方向。最后我们形成了一个由S1到S4的“时间线”。

你可以选择文档中的任意位置，例如你可以在文档的某个位置（蓝色弧线的起始位置），从该处开始查询文档过去某处或未来某处（蓝色弧线的终止位置）。

// I mean, Typst maintains states with at least two dimensions. The one resembles a space dimension, and the other one resembles a time dimension. You can create a state that spans:

// 1. From space to space: You can locate content at here and there by selectors.
// 2. From time to time: You can query a state in past or future by locations.

// The following figure shows how a state is arranged. First, Typst executes the document with scripting from S1 to S4, as #text(fill: red, "red lines") shown. Then, you can locate some content in the document (at the _start position_ of #text(fill: blue, "blue arcs")) and query the past state or future state (at the _end position_ of #text(fill: blue, "blue arcs")).

#import "./figure-time-travel.typ": figure-time-travel
#align(center + horizon, figure-time-travel())

// This section mainly talks about `selector` and `state` step by step, to teach how to locate content, create and manipulate states.

本节教你使用选择器（selector）定位到文档的任意部分；也教你创建与查询二维文档状态（state）。

== 自定义标题样式

本节讲解的程序是如何在Typst中设置标题样式。我们的目标是：
+ 为每级标题单独设置样式。
+ 设置标题为内容的页眉：
  + 如果当前页眉有二级标题，则是当前页面的第一个二级标题。
  + 否则是之前所有页面的最后一个二级标题。

效果如下：

#frames-cjk(
  read("./stateful/s1.typ"),
  code-as: ```typ
  #show: set-heading

  == 雨滴书v0.1.2
  === KiraKira 样式改进
  feat: 改进了样式。
  === FuwaFuwa 脚本改进
  feat: 改进了脚本。

  == 雨滴书v0.1.1
  refactor: 移除了LaTeX。

  feat: 删除了一个多余的文件夹。

  == 雨滴书v0.1.0
  feat: 新建了两个文件夹。
  ```,
)

== 「样式化」内容

当我们有一个`repr`玩具的时候，总想着对着各种各样的对象使用`repr`。我们在上一节讲解了「`set`」和「`show`」语法。现在让我们稍微深挖一些。

「`set`」是什么，`repr`一下：

#code(```typ
#repr({
  [a]
  set text(fill: blue)
  [b]
})
```)

「`show`」是什么，`repr`一下：

#code(```typ
#repr({
  [d]
  show raw: content => {
    [c]
    set text(fill: red)
    content
  }
  [a]
  `b`
})
```)

我们知道`set text(fill: blue)`是`show: set text(fill: blue)`的简写，因此「`set`」语法和「`show`」语法都可以统合到第二个例子来理解。

对于第二个例子，我们发现`show`语句之后的内容都被重新包裹在`styled`元素中。虽然我们不知道`styled`做了什么事情，但是简单的事实是：

#code(```typ
该元素的类型是：#type({show: set text(fill: blue)}) \
该元素的构造函数是：#({show: set text(fill: blue)}).func()
```)

原来，你也是内容。从图中，我们可以看到被`show`过的内容会被封装成「样式化」内容，即图中构造函数为`styled`的内容。

关于`styled`的知识便涉及到Typst的核心架构。

== 「`eval`阶段」与「`typeset`阶段」

现在我们介绍Typst的完整架构。

当Typst接受到一个编译请求时，他会使用「解析器」（Parser）从`main`文件开始解析整个项目；对于每个文件，Typst使用「评估器」（Evaluator）执行脚本并得到「内容」；对于每个「内容」，Typst使用「排版引擎」（Typesetting Engine）计算布局与合成样式。

当一切布局与样式都计算好后，Typst将最终结果导出为各种格式的文件，例如PDF格式。

如下图所示，Typst大致上分为四个执行阶段。这四个执行阶段并不完全相互独立，但有明显的先后顺序：

#import "../figures.typ": figure-typst-arch
#align(center + horizon, figure-typst-arch())

这里，我们着重讲解“内容评估”阶段与“内容排版”阶段。

事实上，Typst直接在脚本中提供了对应“内容评估”阶段的函数，它就是我们之前已经介绍过的函数`eval`。你可以使用`eval`函数，将一个字符串对象「评估」为「内容」：

#code(```typ
以代码模式评估：#eval("repr(str(1 + 1))") \
以标记模式评估：#eval("repr(str(1 + 1))", mode: "markup") \
以标记模式评估2：#eval("#show: it => [c] + it + [t];a", mode: "markup")
```)

由于技术原因，Typst并不提供对应“内容排版”阶段的函数，如果有的话这个函数的名称应该为`typeset`。已经有很多迹象表明`typeset`可能产生：
+ #link("https://github.com/andreasKroepelin/polylux")[Polylux], #link("https://github.com/touying-typ/touying")[Touying]等演示文档（PPT）框架需要将一部分内容固定为特定结果的能力。
+ Typst的作者在其博客中提及#link("https://laurmaedje.github.io/posts/frozen-state/")[Frozen State
]的可能性。
  + 他提及数学公式的编号在演示文档框架。
  + 即便不涉及用户需求，Typst的排版引擎已经自然存在Frozen State的需求。
+ 本文档也需要`typeset`的能力为你展示特定页面的最终结果而不影响全局状态。

在Typst的源代码中，有一个Rust函数直接对应整个编译流程，其内容非常简短，便是调用了两个阶段对应的函数。“内容评估”阶段（`eval`阶段）对应执行一个Rust函数，它的名称为`typst::eval`；“内容排版”阶段（`typeset`阶段）对应执行另一个Rust函数，它的名称为`typst::typeset`。

```rs
pub fn compile(world: &dyn World) -> SourceResult<Document> {
    // Try to evaluate the source file into a module.
    let module = crate::eval::eval(world, &world.main())?;
    // Typeset the module's content, relayouting until convergence.
    typeset(world, &module.content())
}
```

从代码逻辑上来看，它有明显的先后顺序，似乎与我们所展示的架构略有不同。其`typst::eval`的输出为一个文件模块`module`；其`typst::typeset`仅接受文件的内容`module.content()`并产生一个已经排版好的文档对象`typst::Document`。

与架构图对比来看，架构图中还有两个关键的反向箭头，疑问顿生：这两个反向箭头是如何产生的？

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

1. *「内容评估」*阶段仅仅“评估”出*「内容排版」*阶段所需的素材.*「评估器」*并不具备排版能力。
2. 对于依赖排版产生的内容，「内容评估」产生包含*「回调函数」*的内容，让「排版引擎」在合适的时机“回过头来调用”。
3. 相关的计算方法又被称为*「延迟执行」*。因为现在不具备执行条件，所以延迟到条件满足时才继续执行。

现在我们可以理解两个反向箭头是如何产生的了。它们是下一阶段的回调，用于完成阶段之间复杂的协作。评估阶段可能会`import`或`include`文件，这时候会重新让解析器解析文件的字符串内容。排版阶段也可能会继续根据`styled`等元素产生复杂的内容，这时候依靠评估器执行脚本并产生或改变内容。

我们来手动描述一遍上述示例的执行过程，以加深理解：

#code(```typ
#show raw: content => layout(parent => if parent.width < 100pt {
  set text(fill: red); content
} else {
  content
})
#box(width: 50pt, `a`)
`b`
```)

首先进行内容评估得到：

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

== 「样式化」内容的补充

有时候`show`规则会原地执行，这属于一种细节上的优化，例如：

#code(```typ
#repr({ show: it => it; [a] }) \
#repr({ show: it => [c] + it + [d]; [a] })
```)

这个时候`show`规则不会对应一个`styled`元素。

这种优化告诉你前面手动描述的过程仅作理解。一旦涉及更复杂的环境，Typst的实际执行过程就会产生诸多变化。因此，你不应该依赖以上某步中排版引擎的瞬间状态。这些瞬间状态将产生「未注明特性」(undocumented details)，并随时有可能在未来被打破。

== 「可定位」的内容

在过去的章节中，我们了解了评估结果的具体结构，也大致了解了排版引擎的工作方式。

接下来，我们介绍一类内容的「可定位」（Locatable）特征。你可以与前文中的「可折叠」（Foldable）特征对照理解。

一个内容是可定位的，如果它可以以某种方式被索引得到。

如果一个内容在代码块中，并未被使用，那么显然这种内容是不可定位的。

```typ
#{ let unused-content = [一段不可定位的内容]; }
```

理论上文档中所有内容都是可定位的，但由于*性能限制*，Typst无法允许你定位文档中的所有内容。

我们已经学习过元素函数可以用来定位内容。如下：

#code(````typ
#show heading: set text(fill: blue)
= 蓝色标题
段落中的内容保持为原色。
````)

接下来我们继续学习更多选择器。

== 文本选择器 <grammar-text-selector>

你可以使用「字符串」或「正则表达式」（`regex`）匹配文本中的特定内容，例如为`c++`文本特别设置样式：

#code(````typ
#show "cpp": strong(emph(box("C++")))
在古代，cpp是一门常用语言。
````)

这与使用正则表达式的效果相同：<grammar-regex-selector>

#code(````typ
#show regex("cp{2}"): strong(emph(box("C++")))
在古代，cpp是一门常用语言。
````)

关于正则表达式的知识，推荐在#link("https://regex101.com")[Regex 101]中继续学习。

这里讲述一个关于`regex`选择器的重要知识。当文本被元素选中时，会创建一个不可见的分界，导致分界之间无法继续被正则匹配：

#code(````typ
#show "ab": set text(fill: blue)
#show "a": set text(fill: red)
ababababababa
````)

因为`"a"`规则比`"ab"`规则更早应用，每个`a`都被单独分隔，所以`"ab"`规则无法匹配到任何本文。

#code(````typ
#show "a": set text(fill: red)
#show "ab": set text(fill: blue)
ababababababa
````)

虽然每个`ab`都被单独分隔，但是`"a"`规则可以继续在分界内继续匹配文本。

这个特征在设置文本的字体时需要特别注意：

为引号单独设置字体会导致错误的排版结果。因为句号与双引号之间产生了分界，使得Typst无法应用标点挤压规则：

#code(````typ
#show "”": it => {
  set text(font: "KaiTi")
  highlight(it, fill: yellow)
}
“无名，万物之始也；有名，万物之母也。”
````)

以下正则匹配也会导致句号与双引号之间产生分界，因为没有对两个标点进行贪婪匹配：

#code(````typ
#show regex("[”。]"): it => {
  set text(font: "KaiTi")
  highlight(it, fill: yellow)
}
“无名，万物之始也；有名，万物之母也。”
````)

以下正则匹配没有在句号与双引号之间创建分界。考虑两个标点的字体设置规则，Typst能排版出这句话的正确结果：

#code(````typ
#show regex("[”。]+"): it => {
  set text(font: "KaiTi")
  highlight(it, fill: yellow)
}
“无名，万物之始也；有名，万物之母也。”
````)

== 标签选择器 <grammar-label-selector>

基本上，任何元素都包含文本。这使得你很难对一段话针对性排版应用排版规则。「标签」有助于改善这一点。标签是「内容」，由一对「尖括号」（`<`和`>`）包裹：

#code(````typ
一句话 <some-label>
````)

「标签」可以选中恰好在它*之前*的一个内容。示例中，`<some-label>`选中了文本内容`一句话`。

也就是说，「标签」无法选中在它*之前*的多个内容。以下选择器选中了`#[]`后的一句话：

#code(````typ
#show <一句话>: set text(fill: blue)
#[一句话。]还是一句话。 <一句话>

另一句话。
````)

这是因为`#[一句话。]`被分隔为了单独的内容。

我们很难判断一段话中有多少个内容。因此为了可控性，我们可以使用内容块将一段话括起来，然后使用标签准确选中这一整段话：

#code(````typ
#show <一整段话>: set text(fill: blue)
#[
  $lambda$语言是世界上最好的语言。#[]还是一句话。
] <一整段话>

另一段话。
````)

== 选择器表达式 <grammar-selector-exp>

任意「内容」可以使用「`where`」方法创建选中满足条件的选择器。

例如我们可以选中二级标题：

#code(````typ
#show heading.where(level: 2): set text(fill: blue)
= 一级标题
== 二级标题
````)

这里`heading`是一个元素，`heading.where`创建一个选择器：

#code(````typ
选择器是：#repr(heading.where(level: 2)) \
类型是：#type(heading.where(level: 2))
````)

同理我们可以选中行内的代码片段而不选中代码块：

#code(````typ
#show raw.where(block:false): set text(fill: blue)
`php`是世界上最好的语言。
```
typst也是。
```
````)

// == 「`numbering`」函数

// 略

== 回顾其一

针对特定的`feat`和`refactor`文本，我们使用`emph`修饰：

#frames-cjk(
  read("./stateful/s2.typ"),
  code-as: ```typ
  #show regex("feat|refactor"): emph
  ```,
)

对于三级标题，我们将中文文本用下划线标记，同时将特定文本替换成emoji：

#frames-cjk(
  read("./stateful/s3.typ"),
  code-as: ```typ
  #let set-heading(content) = {
    show heading.where(level: 3): it => {
      show regex("[\p{hani}\s]+"): underline
      it
    }
    show heading: it => {
      show regex("KiraKira"): box("★", baseline: -20%)
      show regex("FuwaFuwa"): box(text("🪄", size: 0.5em), baseline: -50%)
      it
    }

    content
  }
  #show: set-heading
  ```,
)

== 制作页眉标题的两种方法

制作页眉标题至少有两种方法。一是直接查询文档内容；二是创建状态，利用布局迭代收敛的特性获得每个页面的首标题。

在接下来的两节中我们将分别介绍这两种方法。
