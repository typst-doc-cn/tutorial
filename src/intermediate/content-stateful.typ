#import "mod.typ": *

#show: book.page.with(title: "维护和查询文档状态")

#import "/typ/embedded-typst/lib.typ": svg-doc, default-fonts, default-cjk-fonts

#let frames(code, cjk-fonts: false, code-as: none) = {
  if code-as != none {
    code-as
  } else {
    code
  }

  let fonts = if cjk-fonts {
    (..default-cjk-fonts(), ..default-fonts())
  }

  grid(columns: (1fr, 1fr), ..svg-doc(code, fonts: fonts).pages.map(data => image.decode(data)).map(rect))
}
#let frames = frames.with(cjk-fonts: true)

在上一节中我们理解了作用域，也知道如何简单把「`show`」规则应用于文档中的部分内容。

它看起来似乎已经足够强大，但有一种可能，Typst可以给你更强大的原语。

我是说有一种可能，Typst对文档内容的理解至少是二维的。一维是空间，另一维是时间。你可以从文档的任意位置，
1. 空间维度（From Space to Space）：查询文档任意部分的状态（这里的内容和那里的内容）。
1. 时间维度（From TimeLoc to TimeLoc）：查询文档任意脚本位置的状态（过去的状态和未来的状态）。

这里有一个示意图，红色线段表示Typst脚本的执行方向。最后我们形成了一个由S1到S4的“时间线”。

我们可以任意选中文档中的位置，例如我们可以选中其中起点（蓝色弧线的起始位置），从该处开始查询文档过去某处或未来某处（蓝色弧线的终止位置）。

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
1. 为每级标题单独设置样式。
2. 

效果如下：

#frames(read("./stateful/s1.typ"), code-as: ```typ
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
```)

== 「样式化」内容

当我们有一个`repr`玩具的时候，总想着对着各种各样的对象使用`repr`。这是什么，`repr`一下：

#code(```typ
#repr({
  [a]
  set text(fill: blue)
  [b]
})
```)

这是什么，`repr`一下：

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

原来，你也是内容。从图中，我们可以看到被`show`过的内容会被封装成「样式化」内容。

== 「`eval`阶段」与「`typeset`阶段」

现在我们介绍Typst的完整架构。

当Typst接受到一个编译请求时，他会使用「解析器」（Parser）从`main`文件开始解析整个项目；对于每个文件，Typst使用「评估器」（Evaluator）执行脚本并得到「内容」；对于每个「内容」，Typst使用「排版引擎」（Typesetting Engine）计算布局与合成样式。

当一切布局与样式都计算好后，Typst将最终结果导出为各种格式的文件，例如PDF格式。

如下图所示，Typst大致上分为四个执行阶段。这四个执行阶段并不完全相互独立，但有明显的先后顺序：

#import "./figure-typst-arch.typ": figure-typst-arch
#align(center + horizon, figure-typst-arch())

这里，我们着重讲解“内容评估”阶段与“内容排版”阶段。

事实上，Typst提供了对应“内容评估”阶段的函数，它就是我们之前已经介绍过的函数`eval`。你可以使用`eval`函数，将一个字符串对象「评估」为「内容」：

#code(```typ
以代码模式评估：#eval("repr(str(1 + 1))") \
以标记模式评估：#eval("repr(str(1 + 1))", mode: "markup") \
以标记模式评估2：#eval("#show: it => [c] + it + [t];a", mode: "markup")
```)

由于技术原因，Typst并不提供对应“内容排版”阶段的函数，如果有的话这个函数的名称应该为`typeset`。

在Typst的源代码中，有一个Rust函数直接对应整个编译流程，其内容非常简短，便是调用了两个阶段对应的函数。“内容评估”阶段（`eval`阶段）对应执行一个Rust函数，它的名称为`typst::eval`；“内容排版”阶段（`typeset`阶段）对应执行另一个Rust函数，它的名称为`typst::typeset`。

```rs
pub fn compile(world: &dyn World) -> SourceResult<Document> {
    // Try to evaluate the source file into a module.
    let module = crate::eval::eval(world, &world.main())?;
    // Typeset the module's content, relayouting until convergence.
    typeset(world, &module.content())
}
```

从代码逻辑上来看，它有明显的先后顺序，似乎与我们所展示的架构略有不同。其`typst::eval`的输出为一个文件模块；其`typst::typeset`仅接受文件的内容并产生一个已经排版好的文档对象`typst::Document`。

与架构图对比来看，架构图中还有两个关键的反向箭头，疑问顿生：这两个反向箭头是如何产生的？

我们首先关注与本节直接相关的「样式化」内容。当`eval`阶段结束时，「`show`」语法将会对应产生一个`styled`元素，其包含了被设置样式的内容，以及设置样式的「回调」：

#code(```typ
内容是：#repr({show: set text(fill: blue); [abc]}) \
样式无法描述，但它在这里：#repr({show: set text(fill: blue); [abc]}.styles)
```)

也就是说`eval`并不具备任何排版能力，它只能为排版准备好各种“素材”，并把素材交给排版引擎完成排版。

这里有一个术语很关键：「回调」是一个计算机术语。所谓「回调函数」就是一个临时的函数，它会在后续执行过程的合适时机“回过头来被调用”。例如，我们写了一个这样的「`show`」规则：

#code(```typ
#repr({
  show raw: content => layout(parent => if parent.width > 1000pt {
    set text(fill: red); content
  } else {
    content
  })
  `a`
})
```)

这里`parent.width > 1000pt`是说当且仅当父元素的宽度大于`1000pt`时，才为该代码片段设置红色字体样式。其中，父元素宽度与排版相关，自然`eval`也不知道父元素宽度等于多少。那么，自然`eval`也不知道该如何评估。

于是，`eval`干脆将整个`show`右侧的函数都作为“素材”交给了排版引擎。当排版引擎计算好了相关内容，才回到评估阶段，执行这一小部分“素材”函数中的脚本，得到为正确的内容。

这种延迟执行的函数便被称为「回调函数」。相关的计算方法也有对应的术语，被称为「延迟执行」。

我们对每个术语咬文嚼字一番，它们都很准确：

1. *「内容评估」*仅仅“评估”好素材，并不具备排版能力。
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

排版引擎遇到`a`，继续执行`show`规则的「回调」，由于此时父元素（`box`元素）宽度只有`50pt`，我们为代码片段设置了红色样式。内容变为：

```typ
#(box(width: 50pt, {set text(fill: red); `a`}), styled((`b`, ), styles: content => ..))
```

排版引擎遇到`a`中的`text`元素，执行`set text(fill: red)`的「回调」。记得我们之前说过`set`是一种特殊的`show`。

```typ
#(box(width: 50pt, text(fill: red, "a", ..)), styled((`b`, ), styles: content => ..))
```

排版引擎遇到`b`，再度执行`show`规则的「回调」，由于此时父元素（`page`元素，即整个页面）宽度有`500pt`，我们没有为代码片段设置样式。

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

这个时候`show`规则不会对应一个`styled`元素。这种优化警戒你不要太过依赖「未注明特性」(undocumented details)。这些特性随时有可能在未来被打破。

== 「可定位」的内容

在过去的章节中，我们了解了评估结果的具体结构，也大致了解了排版引擎的工作方式。

接下来，我们介绍一类内容的「可定位」（Locatable）特性。可以与前文中的「可折叠」（Foldable）特性对照理解。

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

== 文本选择器

你可以使用「字符串」或「正则表达式」（`regex`）匹配文本中的特定内容，例如为`c++`文本特别设置样式：

#code(````typ
#show "cpp": strong(emph(box("C++")))
在古代，cpp是一门常用语言。
````)

这与使用正则表达式的效果相同：

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
#show "”": set text(font: "KaiTi")
“无名，万物之始也；有名，万物之母也。”
````)

以下正则匹配也会导致句号与双引号之间产生分界：

#code(````typ
#show regex("[”。]"): set text(font: "KaiTi")
“无名，万物之始也；有名，万物之母也。”
````)

以下正则匹配没有在句号与双引号之间创建分界。考虑两个标点的字体设置规则，Typst能排版出这句话的正确结果：

#code(````typ
#show regex("[”。]+"): set text(font: "KaiTi")
“无名，万物之始也；有名，万物之母也。”
````)

== 「标签」选择器

一些元素无法被直接选中，但是我们可以通过「标签」选中它们。「标签」选择器允许我们选中特定的元素。

基本任何元素都包含文本，这使得我们很难对一段话针对性排版应用排版规则。「标签」有助于改善这一点。标签是「内容」，由一对「尖括号」（`<`和`>`）包裹：

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

== 选择器表达式

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

#frames(read("./stateful/s2.typ"), code-as: ```typ
#show regex("feat|refactor"): emph
```)

对于三级标题，我们将中文文本用下划线标记，同时将特定文本替换成emoji：

#frames(read("./stateful/s3.typ"), code-as: ```typ
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
```)

== 制作页眉标题的两种方法

制作页眉标题有两种方法。

== 「query」

略

== 「状态」

略

== 「状态」的更新

略

== 查询特定时间点的「状态」

略

== 「`typeset`」阶段的迭代收敛

略

自定义页眉的方法是`set page(header)`，，且页眉的内容是本页中第一个标题的内容。


todo: selector

todo: label

todo: regex

todo: query

todo: state

todo: numbering

todo: reference
