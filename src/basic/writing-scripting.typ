#import "mod.typ": *

#show: book.page.with(title: [初识脚本模式])

从现在开始，示例将会逐渐开始出现脚本。不要担心，它们都仅涉及脚本的简单用法。

== 内容块 <grammar-content-block>

有时，文档中会出现连续大段的标记文本。

#code(````typ
*从前有座山，山会讲故事，故事讲的是*

*从前有座山，山会讲故事，故事讲的是*

*...*

````)

这可行，但稍显麻烦。如下代码则显得更为整洁，它不必为每段都打上着重标记：

#code(````typ
#strong[
  从前有座山，山会讲故事，故事讲的是

  从前有座山，山会讲故事，故事讲的是

  ...
]
````)

例中，```typ #strong[]```这个内容的语法包含三个部分：
+ `#`使解释器进入#term("code mode")。
+ #typst-func("strong")是赋予#term("strong semantics")函数。
+ `[]`作为#term("content block")标记一段内容，供`strong`使用。

本小节首先讲解第三点，即#term("content block")语法。

#term("content block")的内容使用中括号包裹，如下所示：

#code(```typ
#[一段文本]#[两段文本] #[三段文本]
```)

#term("content block")不会影响包裹的内容——Typst仅仅是解析内部代码作为#term("content block")的内容。#term("content block")也*几乎不影响内容的书写*。

#pro-tip[
  唯一的影响是你需要在内容块内部转义右中括号。

  #code(```typ
  #[x\]y]
  ```)
]

#term("content block")的唯一作用是“界定内容”。它收集一个或多个#term("content")，以待后续使用。有了#term("content block")，你可以*准确指定*一段内容，并用#term("scripting")加工。

#import "../figures.typ": figure-content-decoration
#align(center + horizon, figure-content-decoration())

#v(1em)

所谓#term("scripting")，就是对原始内容增删查改，进而形成文档的过程描述。因为有了#term("scripting")，Typst才能有远超Markdown的排版能力，在许多情况下不逊于LaTeX排版，将来有望全面超越LaTeX排版。

在接下来两小节你将看到Typst作为一门*编程语言*的核心设计，也是进行更高级排版必须要掌握的知识点。由于我们的目标首先仅是*编写一篇基本文档*，我们将会尽可能减少引入更多知识点，仅仅介绍其中最简单常用的语法。

== 解释模式 <grammar-enter-script>

```typ #strong[]```语法第一点提及：`#`使解释器进入#term("code mode")。

#code(```typ
#[一段文本]
```)

这个#mark("#")不属于内容块的语法一部分，而是Typst中关于「脚本模式」的定界符。

这涉及到Typst的编译原理。Typst程序包含一个解释器，用其从头到尾查看并#term("interpret")你的文档。

其特殊之处在于，解释器还具备多种#term("interpreting mode")。借鉴了LaTeX的文本和数学模式，在不同的#term("interpreting mode")下，解释器以不同的语法规则解释你的文档。Typst中，标记模式的语法更适合你组织文本，代码模式更适合你书写脚本，而数学模式则最适合输入复杂的公式。

// todo 三种解释模式的visualization

=== 标记模式

当解释器从头开始解释文档时，其处于#term("markup mode")，在这个模式下，你可以使用各种记号创建标题、列表、段落......在这个模式下，Typst语法几乎就和Markdown一样。

当其处于「标记模式」，且遇到一个「井号」时，Typst会立即将后续的一段代码认作「脚本」并执行，即它进入了「脚本模式」（scripting mode）。

=== 脚本模式

在「脚本模式」下，你可以转而*主要*计算各种内容。例如，你可以计算一个算式的「内容」：

#code(```typ
#(1024*1024*8*7*17+1)是一个常见素数。
```)

当处于「脚本模式」时，解释器在*适当*的时候从「脚本模式」退回为「标记模式」。如下所示，在「脚本模式」下解析到数字```typc 2```后解释器回到了「标记模式」：

#code(```typ
#2是一个常见素数。
```)

Typst总是倾向于更快地退出脚本模式。

#pro-tip[
  具体来说，你几乎可以认为解释器至多只会解释一个*完整的表达式*，之后就会*立即*退出「脚本模式」。
]

=== 以另一个视角看待内容块

「内容块」的内容遵从标记语法。这意味着，当处于「脚本模式」时，你还可以通过「内容块」语法临时返回「标记模式」，以嵌套复杂的逻辑：

#code(```typ
#([== 脚本模式下创建一个标题] + strong[后接一段文本])
```)

如此反复，Typst就同时具备了方便文档创作与脚本编写的能力。

#pro-tip[
  能否直接像使用「星号」那样，让#term("markup mode")直接将中括号包裹的一段作为内容块的内容？

  这是可以的，但是存在一些问题。例如，人们也常常在正文中使用中括号等标记：

  #code(```typ
  区间[1, ∞)上几乎所有有理数都可以表示为$x^x$，其中$x$是无理数。
  ```)

  如此，「标记模式」下默认将中括号解析为普通文本看起来更为合理。
]

== 数学模式

Typst解释器一共有三种模式，其中两种我们之前已经介绍。这剩下的最后一种被称为#term("math mode")。很多人认为Typst针对LaTeX的核心竞争点之一就是优美的#term("math mode")。

Typst的数学模式如下：<grammar-inline-math> ~ <grammar-display-math>

#code(````typ
行内数学公式：$sum_x$

行间数学公式：$ sum_x $
````)

由于使用#term("math mode")有很多值得注意的地方，且#term("math mode")是一个较为独立的模式，本书将其单列为一章参考，可选阅读。有需要在文档中插入数学公式的同学请移步#(refs.ref-math-mode)[《参考：数学模式》]。

== 函数和函数调用 <grammar-func-call>

这里仅作最基础的介绍。#(refs.scripting-base)[《基本字面量、变量和简单函数》]和#(refs.scripting-complex)[《复合字面量、控制流和复杂函数》]中有对函数和函数调用更详细的介绍。

在Typst中，函数与函数调用同样归属#term("code mode")，所以在调用函数前，你需要先使用#mark("#")让Typst先进入#term("code mode")。

与大部分语言相同的是，在调用Typst函数时，你可以向其传递以逗号分隔的#term("value")，这些#term("value")被称为参数。

#code(```typ
四的三次方为#calc.pow(4, 3)。
```)

这里#typst-func("calc.pow")是内置的幂计算函数，其接受两个参数：
+ 一为```typc 4```，为幂的底
+ 一为```typc 3```，为幂的指数。

你可以使用函数修饰#term("content block")。例如，你可以使用着重函数 #typst-func("strong") 标记一整段内容：

#code(```typ
#strong([
  And every _fair from fair_ sometime declines,

  By chance, or nature's changing course untrimm'd;

  But thy _eternal summer_ shall not fade,

  Nor lose possession of that fair thou ow'st;
])
```)

虽然示例很长，但请认真观察，它很简单。首先，中括号包裹的是一大段内容。在之前已经学到，这是一个#term("content block")。然后#term("content block")在参数列表中，说明它是#typst-func("strong")的参数。#typst-func("strong")与幂函数没有什么不同，无非是接受了一个#term("content block")作为参数。

类似地，#typst-func("emph")可以标记一整段内容为强调语义：

#code(```typ
#emph([
  And every *fair from fair* sometime declines,

  ......
])
```)

Typst强调#term("consistency")，因此无论是通过标记还是通过函数，最终效果都必定是一样的。你可以根据实际情况任意组合方式。

== 内容参数的糖 <grammar-content-param>

在许多的语言中，所有函数参数必须包裹在函数调用参数列表的「圆括号」之内。

#code(```typ
着重语义：这里有一个#strong([重点！])
```)

但在Typst中，如果将内容块作为参数，内容块可以紧贴在参数列表的「圆括号」之后。

#code(```typ
着重语义：这里有一个#strong()[重点！]
```)

特别地，如果参数列表为空，Typst允许省略多余的参数列表。

#code(```typ
着重语义：这里有一个#strong[重点！]
```)

所以，示例也可以写为：

#code(```typ
#strong[
  And every _fair from fair_ sometime declines,
]

#emph[
  And every *fair from fair* sometime declines,
]
```)

#pro-tip[
  函数调用可以后接不止一个内容参数。例如下面的例子后接了两个内容参数：

  #code(```typ
  #let exercise(question, answer) = strong(question) + parbreak() + answer

  #exercise[
    Question: _turing complete_？
  ][
    Answer: Yes, Typst is.
  ]
  ```)
]

== 文字修饰

现在你可以使用更多的文本函数来丰富你的文档效果。

=== 背景高亮 <grammar-highlight>

你可以使用`highlight`高亮一段内容：

#code(```typ
#highlight[高亮一段内容]
```)

你可以传入`fill`参数以改变高亮颜色。

#code(```typ
#highlight(fill: orange)[高亮一段内容]
//         ^^^^^^^^^^^^ 具名传参
```)

这种传参方式被称为#(refs.scripting-base)[「具名传参」]。

=== 修饰线

你可以分别使用#typst-func("underline")、#typst-func("overline")、或#typst-func("strike")为一段内容添加下划线<grammar-underline>、上划线<grammar-overline>或中划线（删除线）<grammar-strike>：

#{
  set text(font: "Source Han Serif SC")
  code(```typ
  平地翻滚：#underline[ጿኈቼዽጿኈቼዽ] \
  施展轻功：#overline[ጿኈቼዽጿኈቼዽ] \
  泥地打滚：#strike[ጿኈቼዽጿኈቼዽ] \
  ```)
}

值得注意地是，被划线内容需要保持相同字体才能保证线段同时处于同一水平高度。

#code(```typ
#set text(font: ("Linux Libertine", "Source Han Serif SC"))
下划线效果：#underline[空格 字体不一致] \
#set text(font: "Source Han Serif SC")
下划线效果：#underline[空格 字体一致] \
```)

该限制可能会在将来被解除。

#typst-func("underline")有一个很有用的`offset`参数，通过它你可以修改下划线相对于「基线」的偏移量：

#code(```typ
#underline(offset: 1.5pt, underline(offset: 3pt, [双下划线]))
```)

如果你更喜欢连贯的下划线，你可以设置`evade`参数，以解除驱逐效果。<grammar-underline-evade>

#code(```typ
带驱逐效果：#underline[Language] \
不带驱逐效果：#underline(evade: false)[Language]
```)

=== 上下标

你可以分别使用#typst-func("sub")<grammar-subscript>或#typst-func("super")<grammar-superscript>将一段文本调整至下标位置或上标位置：

#code(```typ
下标：威严满满#sub[抱头蹲防] \
上标：香風とうふ店#super[TM] \
```)

你可以为上下标设置特定的字体大小：

#code(```typ
上标：香風とうふ店#super(size: 0.8em)[™] \
```)

你可以为上下标设置相对基线的合适高度：

#code(```typ
上标：香風とうふ店#super(size: 1em, baseline: -0.1em)[™] \
```)

== 文字属性

文本本身也可以设置一些「具名参数」。与#typst-func("strong")和#typst-func("emph")类似，文本也有一个对应的元素函数#typst-func("text")。#typst-func("text")接受任意内容，返回一个影响内部文本的结果。

当输入是单个文本时很好理解，返回的就是一个文本元素：

#code(````typ
#text("一段内容")
````)

当输入是一段内容时，返回的是该内容本身，但是对于内容的中的每一个文本元素，都作相应文本属性的修改。下例修改了「代码片段」元素中的文本元素为红色：

#code(````typ
#text(fill: red)[```
影响块元素的内容
```]
````)

进一步，我们强调，其实际修改了*缺省*的文本属性。对比以下两个情形：

#code(````typ
#text[```typ #strong[一段内容] #emph[一段内容]```] \
#text(fill: red)[```typ #strong[一段内容] #emph[一段内容]```] \
````)

可以看见“红色”的设置仅对代码片段中的“默认颜色”的文本生效。对于那些已经被语法高亮的文本，“红色”的设置不再生效。

这说明了为什么下列情形输出了蓝色的文本：

#code(````typ
#text(fill: red, text(fill: blue, "一段内容"))
````)

=== 设置大小 <grammar-text-size>

通过`size`参数，可以设置文本大小。

#code(```typ
#text(size: 12pt)[一斤鸭梨]
#text(size: 24pt)[四斤鸭梨]
```)

其中`pt`是点单位。中文排版中常见的#link("https://ccjktype.fonts.adobe.com/2009/04/post_1.html")[号单位]与点单位有直接换算关系：

#let owo = (
  [初号],
  [小初],
  [一号],
  [二号],
  [小二],
  [三号],
  [小三],
  [四号],
  [小四],
  [五号],
  [小五],
  [六号],
  [小六],
  [七号],
  [八号],
)
#let owo2 = ([42], [36], [26], [22], [18], [16], [15], [14], [12], [10.5], [9], [7.5], [6.5], [5.5], [5])
#let owo3 = ([42], [–], [27.5], [21], [–], [16], [–], [13.75], [–], [10.5], [–], [8], [–], [5.25], [4])
#{
  set align(center)
  table(
    columns: 9,
    [字号],
    ..owo.slice(0, 8),
    [中国（单位：点）],
    ..owo2.slice(0, 8),
    [日本（单位：点）],
    ..owo3.slice(0, 8),
    [字号],
    ..owo.slice(8),
    [],
    [中国（单位：点）],
    ..owo2.slice(8),
    [],
    [日本（单位：点）],
    ..owo3.slice(8),
  )
}

另一个常见单位是`em`：

#code(```typ
#text(size: 1em)[一斤鸭梨]
#text(size: 2em)[四斤鸭梨]
```)

```typc 1em```是当前设置的文字大小。

关于Typst中长度单位的详细介绍，可以挪步#(refs.ref-length)[《参考：长度单位》]。

=== 设置颜色 <grammar-text-fill>

你可以通过`fill`参数为文字配置各种颜色：

#code(```typ
#text(fill: red)[红色鸭梨]
#text(fill: blue)[蓝色鸭梨]
```)

你还可以通过颜色函数创建自定义颜色：

#code(```typ
#text(fill: rgb("ef475d"))[茉莉红色鸭梨]
#text(fill: color.hsl(200deg, 100%, 70%))[天依蓝色鸭梨]
```)

关于Typst中色彩系统的详细介绍，详见#(refs.ref-color)[《参考：颜色、渐变填充与模式填充》]。

=== 设置字体 <grammar-text-font>

你可以通过`font`参数为文字配置字体：

#code(```typ
#text(font: "FangSong")[北京鸭梨]
#text(font: "Microsoft YaHei")[板正鸭梨]
```)

你可以用逗号分隔的「列表」同时为文本设置多个字体。Typst按顺序优先使用靠前字体。例如可以同时设置西文为Times New Roman字体，中文为仿宋字体：

#code(```typ
#text(font: ("Times New Roman", "FangSong"))[中西Pear]
```)

关于如何在不同系统上配置中文、西文、数学等多种字体，详见#(refs.misc-font-setting)[《字体设置》]。

== 「`set`」语法

Typst允许你为元素的「具名参数」设置新的「默认值」，这个特性由「`set`」语法实现。

例如，你可以这样设置文本字体：

#code(```typ
#set text(fill: red)
红色鸭梨
```)

`set`关键字后跟随一个与函数调用相同语法的表达式，表示此后所有的元素都具有新的默认值。这比```typ #text(fill: red)[红色鸭梨]```要更易读。

默认情况下文本元素的`fill`参数为黑色，即文本默认为黑色。经过`set`规则，其往后的文本都默认为红色。

#code(```typ
黑色鸭梨
#set text(fill: red)
红色鸭梨
```)

之所以说它是默认值，是因为仍然可以在创建元素的时候指定参数值以覆盖默认值：

#code(```typ
#set text(fill: red)
#text(fill: blue)[蓝色鸭梨]
```)

本节前面讲述的所有「具名参数」都可以如是设置，例如文本大小、字体等。

关于对「`set`」语法更详细的介绍，详见#(refs.content-scope-style)[《内容、作用域与样式》]。

== 图像 <grammar-image>

图像对应元素函数#typst-func("image")。

你可以通过#(refs.scripting-modules)[绝对路径或相对路径]加载一个图片文件：

#{
  show image: set align(center)
  set image(width: 40%)
  code(```typ
  #image("/assets/files/香風とうふ店.jpg")
  ```)
}

#typst-func("image")有一个很有用的`width`参数，用于限制图片的宽度：

#{
  show image: set align(center)
  code(```typ
  #image("/assets/files/香風とうふ店.jpg", width: 100pt)
  ```)
}

你还可以相对于父元素设置宽度，例如设置为父元素宽度的`50%`：

#{
  show image: set align(center)
  code(```typ
  #image("/assets/files/香風とうふ店.jpg", width: 50%)
  ```)
}

同理，你也可以用`height`参数限制图片的高度。

#{
  show image: set align(center)
  code(```typ
  #image("/assets/files/香風とうふ店.jpg", height: 100pt)
  ```)
}

当同时设置了图片的宽度和高度时，图片默认会被裁剪：

#{
  show image: set align(center)
  code(```typ
  #image("/assets/files/香風とうふ店.jpg", width: 100pt, height: 100pt)
  ```)
}

如果想要拉伸图片而非裁剪图片，可以同时使用`fit`参数：<grammar-image-stretch>

#{
  show image: set align(center)
  code(```typ
  #image("/assets/files/香風とうふ店.jpg", width: 100pt, height: 100pt, fit: "stretch")
  ```)
}

“stretch”在英文中是拉伸的意思。

== 图形 <grammar-figure>

你可以通过#typst-func("figure")函数为图像设置标题：

#{
  show image: set align(center)
  set image(width: 40%)
  code(```typ
  #figure(image("/assets/files/香風とうふ店.jpg"), caption: [上世纪90年代，香風とうふ店送外卖的宝贵影像])
  ```)
}

#typst-func("figure")不仅仅可以接受#typst-func("image")作为内容，而是可以接受任意内容：

#{
  show raw: set align(left)
  code(````typ
  #figure(```typ
  #image("/assets/files/香風とうふ店.jpg")
  ```, caption: [用于加载香風とうふ店送外卖的宝贵影像的代码])
  ````)
}

// == 标签与引用

// #code(```typ
// #set heading(numbering: "1.")
// == 一个神秘标题 <myst>

// @myst 讲述了一个神秘标题。
// ```)

== 行内盒子 <grammar-box>

todo：本节添加box的基础使用。<grammar-image-inline>

#code(```typ
在一段话中插入一个#box(baseline: 0.15em, image("/assets/files/info-icon.svg", width: 1em))图片。
```)

== 链接 <grammar-link>

链接可以分为外链与内链。最简单情况下，你只需要使用#typst-func("link")函数即可创建一个链接：<grammar-http-link>

#code(```typ
#link("https://zh.wikipedia.org")
```)

特别地，Typst会自动识别文中的HTTPS和HTTP链接文本并创建链接：

#code(```typ
https://zh.wikipedia.org
```)

无论是内链还是外链，你都可以额外传入一段*任意*内容作为链接标题：

#code(```typ
不基于比较方法，#link("https://zh.wikipedia.org/zh-hans/%E5%9F%BA%E6%95%B0%E6%8E%92%E5%BA%8F")[排序]可以做到 $op(upright(O)) (n)$ 时间复杂度。
```)

请回忆，这其实等价于调用函数：

#code(```typ
#link("...")[链接] 等价于 #link("...", [链接])
```)

=== 内部链接 <grammar-internal-link>

你可以通过创建标签，标记*任意*内容：

#code(```typ
== 一个神秘标题 <myst>
```)

上例中`myst`是该标签的名字。每个标签都会附加到恰在其之前的内容，这里内容即为该标题。

#pro-tip[
  在脚本模式中，标签无法附加到之前的内容。

  #code(```typ
  #show <awa>: set text(fill: red)
  #{[a]; [<awa>]}
  #[b] <awa>
  ```)

  对比上例，具体来说，标签附加到它的#term("syntactic predecessor")。

  这不是问题，但是易用性有可能在将来得到改善。
]

你可以通过#typst-func("link")函数在文档中的任意位置链接到该内容：

#code(```typ
== 一个神秘标题 <mystery>

讲述了#link(<mystery>)[一个神秘标题]。
```)

== 表格基础 <grammar-table>

你可以通过#typst-func("table")函数创建表格。#typst-func("table")接受一系列内容，并根据参数将内容组装成一个表格。如下，通过`columns`参数设置表格为2列，Typst自动为你生成了一个2行2列的表格：

#code(```typ
#table(columns: 2, [111], [2], [3])
```)

你可以为表格设定对齐：<grammar-table-align>

#code(```typ
#table(columns: 2, align: center, [111], [2], [3])
```)

其他可选的对齐有`left`、`right`、`bottom`、`top`、`horizon`等，详见#(refs.ref-layout)[《参考：布局函数》]。

== 使用其他人的模板

虽然这是一片教你写基础文档的教程，但是为什么不更进一步？有赖于Typst将样式与内容分离，如果你能找到一个朋友愿意为你分享两行神秘代码，当你粘贴到文档开头时，你的文档将会变得更为美观：

#code(````typ
#import "latex-look.typ": latex-look
#show: latex-look

= 这是一篇与LaTeX样式更接近的文档

Hey there!

Here are two paragraphs. The
output is shown to the right.

Let's get started writing this
article by putting insightful
paragraphs right here!
+ following best practices
+ being aware of current results
  of other researchers
+ checking the data for biases

$
  f(x) = integral _(-oo)^oo hat(f)(xi)e^(2 pi i xi x) dif xi
$
````)

一般来说，使用他人的模板需要做两件事：
+ 将`latex-look.typ`放在你的文档文件夹中。
+ 使用以下两行代码应用模板样式：

  ```typ
  #import "latex-look.typ": latex-look
  #show: latex-look
  ```

== 总结

基于《编写一篇基本文档》掌握的知识你应该可以：
+ 像使用Markdown那样，编写一篇基本不设置样式的文档。
+ 查看#(refs.ref-math-mode)[《参考：数学模式》]和#(refs.ref-math-symbols)[《参考：常用数学符号》]，以助你编写简单的数学公式。
+ 查看#(refs.ref-datetime)[《参考：时间类型》]，以在文档中使用时间。

// todo: 术语-翻译表
// todo: 本文使用的符号-标记对照表

== 习题

#let q1 = ````typ
#underline(offset: -0.4em, evade: false)[
  吾輩は猫である。
]
````

#exercise[
  用#typst-func("underline")实现“删除线”效果，其中删除线距离baseline距离为`40%`：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#text(fill: rgb("00000001"))[I'm the flag]
````

#exercise[
  攻击者有可能读取你文件系统中的内容，并将其隐藏存储在你的PDF中。请尝试将用户密码“I'm the flag”以文本形式存放在PDF中，但不可见：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
走#text(size: 1.5em)[走#text(size: 1.5em)[走#text(size: 1.5em)[走]]]
````

#exercise[
  请仅用`em`实现以下效果，其中后一个字是前一个字大小的1.5倍：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
走#text(size: 1.5em)[走#text(size: 1.5em)[走]]
走#text(size: 1.5em)[走#text(size: 1.5em)[走]]
````

#exercise[
  请仅用`em`实现以下效果，其中后一个字是前一个字大小的1.5倍：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#set text(size: 2.25em);走#set text(size: 0.666666666em);走#set text(size: 0.666666666em);走
````

#exercise[
  请仅用`em`实现以下效果，其中前一个字是后一个字大小的1.5倍。要求代码中不允许出现中括号也不允许出现双引号：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]
