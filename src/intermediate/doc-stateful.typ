#import "mod.typ": *

#import "/typ/embedded-typst/lib.typ": svg-doc, default-fonts, default-cjk-fonts

#show: book.page.with(title: [文档状态与文档查询])

在上一节中我们理解了作用域，也知道如何简单把「`show`」规则应用于文档中的部分内容。

它看起来似乎已经足够强大。但还有一种可能，Typst可以给你更强大的原语。

我是说有一种可能，Typst对文档内容的理解至少是二维的。这二维，有一维可以比作空间，另一维可以比作时间。你可以从文档的任意位置，
+ 空间维度（From Space to Space）：查询文档任意部分的状态（这里的内容和那里的内容）。
+ 时间维度（From TimeLoc to TimeLoc）：查询脚本执行到文档任意位置的状态（过去的状态和未来的状态）。

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
  [a]; set text(fill: blue); [b]
})
```)

「`show`」是什么，`repr`一下：

#code(```typ
#repr({
  [b]; show raw: set text(fill: red)
  [a]
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

本节我们讲解制作页眉标题的第一种方法，即通过查询文档状态直接估计当前页眉应当填入的内容。

// #locate(loc => query(heading, loc))
// #locate(loc => query(heading.where(level: 2), loc))

== 「here」<grammar-here>

#todo-box[
  修改以适配全面 context 化的 0.12+ 语法
]

有的时候我们会需要获取当前位置的「位置」信息。

在Typst中，获取当前「位置」的唯一方法是使用「#typst-func("here")」函数。

我们来`repr`一下试试看：

#code(```typ
当前位置的相关信息：#context repr(here())
```)

由于「位置」太过复杂了，`repr`放弃了思考并在这里为我们放了两个点。

我们来简单学习一下Typst为我们提供了哪些位置信息：

#code(```typ
当前位置的坐标：#context here().position()

当前位置的页码：#context here().page()
```)

一个常见的问题是：为什么Typst提供给我的页码信息是「内容」，我无法在内容上做条件判断和计算！<grammar-here-calc>

// #code(```typ
// #repr(context here().page()) \
// #type(context here().page())
// ```)

// 上面输出的内容告诉我们#typst-func("here")不仅是一个函数，而且更是一个元素的构造函数。#typst-func("here")构造出一个`locate`内容。

这其中的关系比较复杂。一个比较好理解的原因是：Typst会调用你的函数多次，因此你理应将所有使用「位置」信息的脚本放在一个上下文块中，这样Typst才能更好地合成内容。

#code(```typ
#context [ 当前位置的页码是偶数：#calc.even(here().page()) ]
//  根据位置信息  计算得到  我们想要的内容
```)

// #pro-tip[
//   这与Typst的缓存原理相关。由于#typst-func("locate")函数接收的闭包```typc loc => ..```是一个函数，且在Typst中它被认定为*纯函数*，Typst只会针对特定的参数执行一次函数。为了强制让用户书写的函数保持纯性，Typst规定用户必须在函数内部使用「位置」信息。

//   因此，例如我们希望在偶数页下让内容为“甲”，否则让内容为“乙”，应当这样书写：

//   #code(```typ
//   #context if calc.even(here().page()) [“甲”] else [“乙”]
//   ```)
// ]

== 「query」<grammar-query>

使用「#typst-func("query")」函数你可以获得当前文档状态。

#code(
  ```typ
  #context query(heading)
  ```,
  res: raw(
    ```typc
    (
      heading(body: [雨滴书 v0.1.2], level: 2, ..),
      ..,
    )
    ```.text,
    lang: "typc",
    block: false,
  ),
)

「#typst-func("query")」函数的唯一参数是「选择器」，很好理解。它接受一个选择器，并返回被选中的所有元素的列表。

#code(
  ```typ
  #context query(heading)
  ```,
  res: raw(
    ```typc
    (
      heading(body: [雨滴书 v0.1.2], level: 2, ..),
      heading(body: [KiraKira 样式改进], level: 3, ..),
      heading(body: [FuwaFuwa 脚本改进], level: 3, ..),
      heading(body: [雨滴书 v0.1.1], level: 2, ..),
      heading(body: [雨滴书 v0.1.0], level: 2, ..),
    )
    ```.text,
    lang: "typc",
    block: false,
  ),
)

我们记得，选择器允许继续指定`where`条件过滤内容：

#code(
  ```typ
  #context query(heading.where(level: 2))
  ```,
  res: raw(
    ```typc
    (
      heading(body: [雨滴书 v0.1.2], level: 2, ..),
      heading(body: [雨滴书 v0.1.1], level: 2, ..),
      heading(body: [雨滴书 v0.1.0], level: 2, ..),
    )
    ```.text,
    lang: "typc",
    block: false,
  ),
)

// 第二个参数是「位置」，就比较难以理解了。首先说明，`loc`并没有任何作用，即它是一个「哑参数」（Dummy Parameter）。

// 如果你学过C++，以下两个方法分别匹配到前缀自增操作函数和后缀自增操作函数。

// ```cpp
// class Integer {
//   Integer& operator++();   // 前缀自增操作函数
//   Integer operator++(int); // 后缀自增操作函数
// };
// ```

// ```cpp class Integer```类中的`int`就是一个所谓的哑参数。

// 「哑参数」在实际函数执行中并未被使用，而仅仅作为标记以区分函数调用。我们知道以下两点：其一，只有#typst-func("locate")函数会返回「位置」信息；其二，#typst-func("query")函数需要我们传入「位置」信息。

// 有了：那么Typst就是在告诉我们，#typst-func("query")函数只能在#typst-func("locate")函数内部调用。正如示例中的那样：

// ```typ
// #locate(loc => query(heading.where(level: 2), loc))
// ```

// 这个规则有些隐晦，并且Typst的设计者也已经注意到了这一点，所以他们正在计划改进这一点。当然在这之前，你只需要记住：#typst-func("query")函数的第二个「位置」参数用于限制该函数仅在#typst-func("locate")函数内部使用。

// #pro-tip[
//   这与Typst的缓存原理相关。为了加速#typst-func("query")函数，Typst需要对其缓存。Typst合理做出以下假设：在文档每处的查询（`loc`），都单独缓存对应选择器的查询结果。

//   更细致地描述如下：将```typc query(selector, loc)```的参数为「键」，执行结果为「值」构造一个哈希映射表。若使用`(selector, loc)`作为「键」，查询该表：
//   + 未对应结果，则执行查询，缓存并返回结果。
//   + 已经存在对应结果，则不会重新执行查询，而是使用表中的值作为结果。
// ]

== 回顾其二

页眉的设置方法是创建一条```typc set page(header)```规则：

#frames-cjk(
  read("./stateful/q0.typ"),
  code-as: ```typ
  #set page(header: [这是页眉])
  ```,
)

既然如此，只需要将`[这是页眉]`替换成一个`context`表达式，就能通过#typst-func("query")函数完成与「位置」相关的页眉设定：

```typ
#set page(header: context emph(get-heading-at-page()))
```

现在让我们来编写`get-heading-at-page`函数。

首先，通过`query`函数查询得到整个文档的*所有二级标题*：

```typc
let headings = query(heading).
  filter(it => it.level == 2)
```

如果你熟记`where`方法，你可以更高效地做到这件事。以下函数调用也可以得到整个文档的*所有二级标题*：

```typc
let headings = query(heading.where(level: 2))
```

很好，Typst文档可以很高效，但有些人写出的Typst代码天生更高效，而我们正在向他们靠近。

接着，考虑构建这样一个`fold-headings`函数，它返回一个数组，数组的内容是每个页面页眉应当显示的内容，即每页的第一个标题。

```typ
#let fold-headings(headings) = {
  ..
}
```

我们可以对其直接调用以测试：

#code(```typ
#let fold-headings(headings) = {
  (none, none)
}
#fold-headings((
  (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
))
```)

很好，这样我们就可以很方便地进行测试了。

该函数首先创建一个数组，数组的长度为页面的数量。

#code(```typ
#let fold-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.page))
  (none, ) * max-page-num
}
#fold-headings((
  (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
))
```)

这里，```typc headings.map(it => it.page)```意即对每个标题获取对应位置的页码；```typc calc.max(..numbers)```意即取页码的最大值。

由于示例中页码的最大值为`2`，`fold-headings`针对示例会返回一个长度为2的数组，数组的每一项都是`none`。

接着，该函数遍历给定的`headings`，对每个页码，都首先获取第一个标题元素：

#code(
  ```typc
  for h in headings {
    if first-headings.at(h.page - 1) == none {
      first-headings.at(h.page - 1) = h
    }
  }
  ```,
  res: eval(
    ```typ
    #let fold-headings(headings) = {
      let max-page-num = calc.max(..headings.map(it => it.page))
      let first-headings = (none, ) * max-page-num

      for h in headings {
        if first-headings.at(h.page - 1) == none {
          first-headings.at(h.page - 1) = h
        }
      }

      first-headings
    }
    #fold-headings((
      (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
    ))
    ```.text,
    mode: "markup",
  ),
)

这里，```typc first-headings.at(h.page - 1)```意即获取当前页码对应在数组中的元素；`if`语句，如果对应页码对应的元素仍是```typc none```，那么就将当前的标题元素填入对应的位置中。

同理，可以获得`last-headings`，存储每页的最后一个标题：

#code(
  ```typc
  let last-headings = (none, ) * max-page-num
  for h in headings {
    last-headings.at(h.page - 1) = h
  }
  ```,
  res: eval(
    ```typ
    #let fold-headings(headings) = {
      let max-page-num = calc.max(..headings.map(it => it.page))
      let last-headings = (none, ) * max-page-num

      for h in headings {
        last-headings.at(h.page - 1) = h
      }

      last-headings
    }
    #fold-headings((
      (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
    ))
    ```.text,
    mode: "markup",
  ),
)

这里`for`语句意即：无论如何，都将当前的标题元素存入数组中。那么每页的最后一个标题总是能被存入到数组中。

但是我们还没有考虑相邻情况。如果我们希望如果当前页面没有标题元素，则显示之前的标题。接下来我们来根据这个思路，组装正确的结果：

#code(
  ```typc
  let res-headings = (none, ) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1), default: none)
      last-headings.at(i)
    }
  }
  ```,
  res: eval(
    ```typ
    #let fold-headings(headings) = {
      let max-page-num = calc.max(..headings.map(it => it.page))
      let first-headings = (none, ) * max-page-num
      let last-headings = (none, ) * max-page-num

      for h in headings {
        if first-headings.at(h.page - 1) == none {
          first-headings.at(h.page - 1) = h
        }
        last-headings.at(h.page - 1) = h
      }

      let res-headings = (none, ) * max-page-num
      for i in range(res-headings.len()) {
        res-headings.at(i) = if first-headings.at(i) != none {
          first-headings.at(i)
        } else {
          last-headings.at(i) = last-headings.at(
            calc.max(0, i - 1), default: none)
          last-headings.at(i)
        }
      }

      res-headings
    }
    #fold-headings((
      (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
    ))
    ```.text,
    mode: "markup",
  ),
)

`res-headings`就是我们想要得到的结果。

#let fold-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.page))
  let first-headings = (none,) * max-page-num
  let last-headings = (none,) * max-page-num

  for h in headings {
    if first-headings.at(h.page - 1) == none {
      first-headings.at(h.page - 1) = h
    }
    last-headings.at(h.page - 1) = h
  }

  let res-headings = (none,) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1),
        default: none,
      )
      last-headings.at(i)
    }
  }

  res-headings
}

由于`res-headings`的计算比较复杂，我们先来一些测试用例来理解：

情形一：假设文档的前段没有标题，该函数会将对应下标的结果置空：

#code(
  ```typ
  情形一：#fold-headings((
    (body:"v2",page:3),(body:"v1",page:3),(body:"v0",page: 3),
  ))
  ```,
  scope: (fold-headings: fold-headings),
)

情形二：假设一页有多个标题，那么，对应下表的结果为该页面的首个标题：

#code(
  ```typ
  情形二：#fold-headings((
    (body:"v2",page:2),(body:"v1",page:2),(body:"v0",page: 3),
  ))
  ```,
  scope: (fold-headings: fold-headings),
)

情形三：假设中间有页空缺，则对应下表的结果为前页的最后一个标题。

#code(
  ```typ
  情形三：#fold-headings((
    (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 3),
  ))
  ```,
  scope: (fold-headings: fold-headings),
)

其中，情形一其实是情形三的特例：假设某一页没有标题，则对应下表的结果为前页的最后一个标题。如果不存在前页包含标题，则对应下表的结果为```typc none```。

于是我们可以给代码加上注释：

```typc
let res-headings = (none, ) * max-page-num
// 对于每一页，我们迭代下标
for i in range(res-headings.len()) {
  // 让对应下标的结果等于：
  res-headings.at(i) = {
    // 如果该页包含标题，则其等于该页的第一个标题
    if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      // 否则，我们积累`last-headings`的结果
      last-headings.at(i) = last-headings.at(
        // 始终至少等于前一页的结果
        calc.max(0, i - 1),
        // 默认没有结果
        default: none)
      // 其等于前页的最后一个标题
      last-headings.at(i)
    }
  }
}
```

最后，我们将`query`与`fold-headings`结合起来，便得到了目标函数：

```typ
#let get-heading-at-page() = {
  let headings = fold-headings(query(
    heading.where(level: 2)))
  headings.at(here().page() - 1)
}
```

这里有一个问题，那便是`fold-headings`没有考虑标题的最后一页仍然存在内容的情况。例如第二页有最后一个标题，但是我们文档一共有三页。

重新改造一下：

#let calc-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.page))
  let first-headings = (none,) * max-page-num
  let last-headings = (none,) * max-page-num

  for h in headings {
    if first-headings.at(h.page - 1) == none {
      first-headings.at(h.page - 1) = h
    }
    last-headings.at(h.page - 1) = h
  }

  let res-headings = (none,) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1),
        default: none,
      )
      last-headings.at(i)
    }
  }

  (
    res-headings,
    if max-page-num > 0 {
      last-headings.at(-1)
    },
  )
}

```typ
#let calc-headings(headings) = {
  // 计算res-headings和last-headings
  ..

  // 同时返回最后一个标题
  (res-headings, if max-page-num > 0 {
    last-headings.at(-1)
  })
}
```

我们来简单测试一下：

#code(
  ```typ
  情形一：#calc-headings((
    (body:"v2",page:3),(body:"v1",page:3),(body:"v0",page: 3),
  )).at(1) \
  情形二：#calc-headings((
    (body:"v2",page:2),(body:"v1",page:2),(body:"v0",page: 3),
  )).at(1) \
  情形三：#calc-headings((
    (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 3),
  )).at(1)
  ```,
  scope: (calc-headings: calc-headings),
)

很好，这样，下面的实现就完全正确了：

```typ
#let get-heading-at-page() = {
  let (headings, last-heading) = calc-headings(
    query(heading.where(level: 2)))
  headings.at(here().page() - 1, default: last-heading)
}
```

#pro-tip[
  将`calc-headings`与`get-heading-at-page`分离可以改进脚本性能。这是因为Typst是以函数为粒度缓存你的计算。在最后的实现：

  + ```typc query(heading.where(level: 2))```会被缓存，如果二级标题的结果不变，则#typst-func("query")函数不会重新执行（不会重新查询文档状态）。
  + ```typc calc-headings(..)```会被缓存。如果查询的结果不变。则其不会重新执行。
]

最后，让我们适配`calc-headings`到真实场景，并应用到页眉规则：

#frames-cjk(
  read("./stateful/q1.typ"),
  code-as: ```typ
  // 这里有get-heading-at-page的实现..

  #set page(header: context emph(get-heading-at-page()))
  ```,
)

在上一节（法一）中，我们仅靠「#typst-func("query")」函数就完成制作所要求页眉的功能。

思考下面函数：

```typ
#let get-heading-at-page(loc) = {
  let (headings, last-heading) = calc-headings(
    query(heading.where(level: 2), loc))
  headings.at(loc.page() - 1, default: last-heading)
}
```

对于每个页面，它都运行```typc query(heading.where(level: 2), loc)```。显然每页的「位置」信息，即`loc`对应不相同。因此：
1. 它会*每页*都重新执行一遍`heading.where(level: 2)`查询。
2. 同时，每次`query`都是对*全文档的线性扫描*。

夸张来讲，假设你有一千页文档，文档中包含上千个二级标题；那么他将会使得你的每次标题更新都触发上百万次迭代。虽然Typst很快，但这上百万次迭代将会使得包含这种页眉的文档难以*实时预览*。

那么有没有一种方法避免这种全文档扫描呢？

本节将介绍法二，它基于「#typst-func("state")」函数，持续维护页眉状态。

Typst文档可以很高效，但有些人写出的Typst代码更高效。本节所介绍的法二，让我们变得更接近这种人。

== 「state」函数<grammar-state>

`state`接收一个名称，并创建该名称对应*全局*唯一的状态变量。

#code(```typ
#state("my-state", 1)
```)

你可以使用```typc context state.get()```函数展示其「内容」：

#code(```typ
#let s1 = state("my-state", 1)
s1: #context s1.get()
```)

你可以使用```typc state.update()```方法更新其状态。`update`函数接收一个「回调函数」，该回调函数接收`state`在某时刻的状态，并返回对应下一时刻的状态：

#let s = state("my-state", 1)

#code(```typ
#let s1 = state("my-state", 1)
s1: #context s1.get() \
#s1.update(it => it + 1)
s1: #context s1.get()
```)

#s.update(it => 1)

所有的相同名称的内容将会共享更新：

#code(```typ
#let s1 = state("my-state", 1)
s1: #context s1.get() \
#let s2 = state("my-state", 1)
s1: #context s1.get(), s2: #context s2.get() \
#s2.update(it => it + 1)
s1: #context s1.get(), s2: #context s2.get()
```)

同时，请注意状态的*全局*特性，即便处于不同文件、不同库的状态，只要字符串对应相同，那么其都会共享更新。

这提示我们需要在不同的文件之间维护全局状态的名称唯一性。

另一个需要注意的是，`state`允许指定一个默认值，但是一个良好的状态设置必须保持不同文件之间的默认值相同。如下所示：

#s.update(it => 1)

#code(```typ
#let s1 = state("my-state", 1)
s1: #context s1.get() \
#let s2 = state("my-state", 2)
s1: #context s1.get(), s2: #context s2.get() \
#s2.update(it => it + 1)
s1: #context s1.get(), s2: #context s2.get()
```)

尽管`s2`指定了状态的默认值为`2`，因为之前已经在文档中创建了该状态，默认值并不会应用。请注意：你不应该利用这个特性，该特性是Typst中的「未定义行为」。

== 「state.update」也是「内容」

#todo-box[
  不再有 `locate` 了, 此处需要修正
]
一个值得注意的地方是，似乎与#typst-func("locate")函数相似，#typst-func("state.update")也接收一个闭包。

事实上，与#typst-func("locate")函数相同，#typst-func("state.update")也具备延迟执行的特性。

让我们检查下列脚本的输出结果：

#s.update(it => 1)

#code(```typ
#let s1 = state("my-state", 1)
#((s1.update(it => it + 1), ) * 3).join()
s1: #context s1.get()
```)

这告诉我们下面一件事情，当`eval`阶段结束时，其对应产生下面的一段内容：

```typc
(
  state("my-state", 1),
  state("my-state").update(it => it + 1),
  state("my-state").update(it => it + 1),
  state("my-state").update(it => it + 1),
)
```

排版引擎会按照*深度优先的顺序*遍历你的内容，从文档的开始位置逐渐*积累*状态。

这将帮助我们在多文件之间协助完成状态的更新与计算。

假设我们有两个文件`s1.typ`和`s2.typ`，文件的内容分别是：
```typ
// s1.typ
#let s1 = state("my-state", (1, ))
#s1.update(it => it + (3, ))
// s2.typ
#let s1 = state("my-state", (2, ))
#s1.update(it => it + (4, ))
#s1.update(it => it + (5, ))
```

并且我们在`main.typ`中引入了上述两个文件：

```typc
#include "s1.typ"
#include "s2.typ"
```

那么根据我们的经验，主文件内容其实对应为：

```typ
// 省略部分内容
#({ state("my-state", (1, )), .. } + { state("my-state", (2, )), .. })
```

我们按照顺序执行状态更新，则状态依次变为：

```typ
#{ (1, ); (1, 3, ); }
#{ (1, 3, ); (1, 3, 4, ); (1, 3, 4, 5, ); }
```

== 查询特定时间点的「状态」


#todo-box[
  `state.final` 不再需要 `loc` 了
]

Typst提供两个方法查询特定时间点的「状态」：

一个方法是```typc state.at(loc)```方法，其接收一个「位置」，返回在该位置对应的状态「值」。

另一个方法是```typc state.final()```方法，返回在文档结束一切排版时对应的状态「值」。

熟悉的剧情再次发生了。让我们回想之前介绍#typst-func("query")时讲述的知识点。


这两个方法都只能在#typst-func("context")内部调用。对于#typst-func("state.at")方法，其「位置」参数是有用的/*；对于#typst-func("state.final")方法，其「位置」参数仅仅作为「哑参数」*/。

我们回想上一小节，由于文档的每个位置「状态」都会存有对应的值，而且当你使用状态的时候至少会指定一个默认值，我们可以知道在我们文档的任意位置使用文档的任意其他位置的状态的内容。

这就是允许我们进行时光回溯的基础。

== 「`typeset`」阶段的迭代收敛

一个容易值得思考的问题是，如果我在文档的开始位置调用了#typst-func("state.final")方法，那么Typst要如何做才能把文档的最终状态返回给我呢？

容易推测出，原来Typst并不会只对内容执行一遍「`typeset`」。仅考虑我们使用#typst-func("state.final")方法的情况。初始情况下#typst-func("state.final")方法会返回状态默认值，并完成一次布局。接下来的迭代，#typst-func("state.final")方法会返回上一次迭代布局完成时的。直到布局的内容不再发生变化。#typst-func("state.at")会导致相似的布局迭代，只不过情况更为复杂，这里便不再展开细节。

所有对文档的查询都会导致布局的迭代：`query`函数可能会导致布局的迭代；`state.at`函数可能会导致布局的迭代；`state.final`函数一定会导致布局的迭代。

== 回顾其三

本节使用递归的方法完成状态的构建，其更为巧妙。

首先，我们声明两个与法一类似的状态，只不过这次我们将状态定义在全局。

```typ
#let first-heading = state("first-heading", ())
#let last-heading = state("last-heading", ())
```

然后，我们在每个二级标题后紧接着触发一个更新：

```typc
show heading.where(level: 2): curr-heading => {
  curr-heading
  context ..
}
```

对于`last-heading`状态，我们可以非常简单地如此更新内容：

```typc
context last-heading.update(headings => {
  headings.insert(str(here().page()), curr-heading.body)
  headings
})
```

每页的最后一个标题总能最后触发状态更新，所以`str(here().page())`总是能对应到每页的最后一个标题的内容。

对于`first-heading`状态，稍微复杂但也好理解：

```typc
context first-heading.update(headings => {
  let k = str(here().page())
  if k not in headings {
    headings.insert(k, curr-heading.body)
  }
  headings
})
```

对于每页靠后的一级标题，都不能使`if`条件成立。所以`str(here().page())`总是能对应到每页的第一个一级标题的内容。

接下来便是简单的查询了，我们回忆之前`get-heading-at-page`的逻辑，它首先判断是否存在本页的第一个标题，否则取前页的最后一个标题。以下函数完成了前半部分：

```typc
let get-heading-at-page() = {
  let page-num = here().page()
  let first-headings = first-heading.final(here())

  first-headings.at(str(page-num))
}
```

我们为`at`函数添加`default`函数，其取前页的最后一个标题。

```typc
let get-heading-at-page() = {
  ..
  let last-headings = last-heading.at(here())

  first-headings.at(str(page-num), default: find-headings(last-headings, page-num))
}
```

我们使用递归的方法实现`find-headings`：

```typc
let find-headings(headings, page-num) = if page-num > 0 {
  headings.at(str(page-num), default: find-headings(headings, page-num - 1))
}
```

递归有两个分支：递归的基是，若一直找到文档最前页都找不到相应的标题，则返回`none`。否则检查`headings`中是否有对应页的标题：若有则直接返回其内容，否则继续往前页迭代。

一个细节值得注意，我们对`first-heading`使用了`final`方法，但对`last-heading`使用了`at`方法。这是因为：
+ `first-heading`需要我们支持后向查找，因此需要直接获取文档最终的状态。
+ `last-heading`仅仅需要前向查找，因此使用`at`方法可以改进迭代效率。

这个递归函数是高性能的，因为Typst会对`find-headings`缓存，并且Typst对于后一页的内容，都总是能命中前一页的缓存。

与之相反，基于#typst-func("query")的实现没有那么好命。它没法很好利用递归完成标题信息的构建。这是因为#typst-func("query")的实现中，`calc-headings`的首次执行就被要求计算文档的所有标题。

最后让我们设置页眉：

#frames-cjk(
  read("./stateful/s1.typ"),
  code-as: ```typ
  // 这里有get-heading-at-page的实现..

  #set page(header: emph(get-heading-at-page()))
  ```,
)
