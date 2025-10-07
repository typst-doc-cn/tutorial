#import "mod.typ": *

#show: book.page.with(title: "长度与布局")

#todo-box[本节处于校对阶段，所以可能存在不完整或错误。]

本章我们再度回到排版专题，拓宽制作文档的能力。

#let absent(content) = underline(offset: 1.5pt, underline(offset: 3pt, text(red, content)))
#let ng(content) = underline(offset: 1.5pt, text(blue, content))

== 长度类型

#show quote: it => {
  box(
    stroke: (
      left: 2pt + main-color,
    ),
    inset: (
      left: 12pt,
      y: 8pt,
    ),
    {
      stack(
        {
          set text(style: "italic")
          it.body
        },
        if "attribution" in it.fields() {
          1em
        },
        if "attribution" in it.fields() {
          align(right, [——] + it.attribution)
        },
      )
    },
  )
}

Typst有三种长度单位，它们是：绝对长度（absolute length）、相对长度（relative length）与上下文有关长度（context-sensitive length）。

+ 绝对长度：人们最熟知的长度单位。例如，```typc 1cm```恰等于真实的一厘米。
+ 相对长度：与父元素长度相关联的长度单位，例如```typc 70%```恰等于父元素高度或宽度的70%。
+ 上下文有关长度：与样式等上下文有关的长度单位，例如```typc 1em```恰等于当前位置设定的字体长度。

掌握不同种类的长度单位对构建期望的布局非常重要。它们是相辅相成的。

== 绝对长度

目前Typst一共提供四种绝对长度。除了公制长度单位```typc 1cm```与```typc 1mm```与英制长度单位```typc 1in```，Typst还提供排版专用的长度单位“点”，即```typc 1pt```。

#quote(attribution: link("https://zh.wikipedia.org/wiki/%E9%BB%9E_(%E5%8D%B0%E5%88%B7)")[维基百科：点 (印刷)])[
  点（英语：point），pt，是印刷所使用的长度单位，用于表示字型的大小，也用于余白（字距、行距）等其他版面构成要素的长度。作为铸字行业内部的一个专用单位，1 点的长度在世界各地、各个时代曾经有过不同定义，并不统一。当代最通行的是广泛应用于桌面排版软件的 DTP 点，72 点等于 1英寸（1 point = 127⁄360 mm = 0.352777... mm）。中国传统字体排印上的字号单位是号，而后采用“点”“号”兼容的体制。
]

Typst会将你提供的任意长度单位都统一成点单位，以便进行长度运算。

#{
  set align(center)
  let units = ((1pt, "pt"), (1mm, "mm"), (1cm, "cm"), (1in, "in"))
  let methods = (length.pt, length.mm, length.cm, length.inches)
  table(
    columns: 5,
    "",
    ..("pt", "mm", "cm", "in").map(e => raw("=?" + e)),
    ..units
      .map(((l, u)) => {
        (raw("1" + u, lang: "typc"),) + methods.map(method => [#calc.round(method(l), digits: 2)])
      })
      .flatten(),
  )
}

== 绝对长度的运算

长度单位可以参与任意多个浮点值的运算。一个长度表达式是合法的当且仅当运算结果*保持长度量纲*。请观察下列算式，它们都可以编译：

#code(```typ
#(1cm * 3), #(1cm / 3), #(2 * 1cm * 3 / 2), #(1cm + 3in)
```)

请观察下列算式，它们都不能编译：

#(
  ```typ
  #(1cm + 3), #(3 / 1cm), #(1cm * 1cm)
  ```
)

所谓*保持长度量纲*，即它存在一系列判别规则：

- 由于`1cm`与`3in`量纲均为长度量纲（`m`），它们之间*可以*进行*加减*运算。
- 由于`3`无量纲，`1cm`与`3`之间*不能*进行*加减*运算。

进一步，通过量纲运算，可以判断一个长度算术表达式是否合法：

#{
  set align(center)
  table(
    columns: 4,
    [长度表达式],
    [量纲运算],
    [检查合法性],
    [判断结果],
    ```typc 1cm * 3```,
    $bold(sans(m dot 1 = m))$,
    $bold(sans(m = m))$,
    table.cell(rowspan: 2, align: horizon)[合法],
    ```typc 1cm / 3```,
    $bold(sans(m op(slash) 1 = m))$,
    $bold(sans(m = m))$,
    ```typc 3 / 1cm```,
    $bold(sans(1 op(slash) m = m^(-1)))$,
    $bold(sans(m^(-1) = m))$,
    table.cell(rowspan: 2, align: horizon)[非法],
    ```typc 1cm * 1cm```,
    $bold(sans(m dot m = m^2))$,
    $bold(sans(m^2 = m))$,
  )
}

== 绝对长度的转换

你可以使用`length`类型上的「方法」实现不同单位到浮点数的转换：

#code(```typ
#1cm 是 #1cm.pt() 点 \
#1cm 是 #1cm.inches() 英尺
```)

你可以使用乘法实现浮点数到长度上的转换，例如```typc 28.3465 * 1pt```：

#code(```typ
#1cm 是 #(28.3465 * 1pt).cm() 厘米
```)

== 相对长度

有两种相对长度（Relative Length），一是百分比（Ratio），一是分数比（Fraction）。

=== 百分比 <reference-type-ratio>

#let p(w, f, ..args) = box(
  width: w,
  height: 10pt,
  fill: f,
  ..args,
)
#let code = code.with(scope: (p: p))

当「百分比」用作长度时，其实际值取决于父容器宽度：

#code(```typ
#let p(w, f, ..args) = box(
  width: w, height: 10pt, fill: f, ..args)
4比6：#p(100pt, blue, p(40%, red))
```)

Typst还支持以「分数比」作长度单位。当分数比作长度单位时，Typst按比例分配长度。

#code(```typ
4比6：#p(100pt, blue,
  p(4fr, red) + p(6fr, blue))
```)

结合代码与图例理解，`N fr`代表：在总的比例中，这个元素应当占有其中`N`份长度。

当同级元素既有分数比长度元素，又有其他长度单位元素时，优先将空间分配给其他长度单位元素。

#code(```typ
绿色先占60%: #p(100pt, blue, p(1fr, red) + p(2fr, blue) + p(60%, green)) \
绿色先占110%: #p(100pt, blue, p(1fr, red) + p(1fr, blue) + p(110%, green)) \
红色先占30pt: #p(100pt, blue, p(30pt, red) + p(1fr, blue) + p(110%, green))
```)

建议结合下文中grid布局关于长度的使用，加深对相对长度的理解。

== 上下文有关长度

目前Typst仅提供一种上下文有关长度，即当前上下文中的字体大小。历史上，定义该字体中大写字母`M`的宽度为`1em`，但是现代排版中，`1em`可以比`M`的宽度要更窄或者更宽。

上下文有关长度是与相对长度相区分的。区别是上下文有关长度的取值从「样式链」获取，而相对长度相对于父元素宽度。事实上`1em`的具体值可以通过上下文有关表达式获取：

#code(```typ
#let _1em = context measure(
  line(length: 1em)).width
#text(size: 10pt, [1em等于] + _1em) \
#text(size: 20pt, [1em等于] + _1em) \
```)

相比较，`1em`更好用一点，因为`text.size`只允许在上下文有关表达式内部使用。

== 混合长度

以上所介绍的各种长度可以通过「加号」任意混合成单个长度的值，其长度的值为每个分量总和：

#code(```typ
#(1pt + 1em + 100%)
```)

== 长度的内省或评估

你可以通过`measure`获取一个长度在当前位置的具体值：

#let length-of(l) = (measure(line(length: l)).width)
#let code = code.with(scope: (length-of: length-of))

#code(```typ
#let length-of(l) = measure(
  line(length: l)).width
#context [长度等于#length-of(1em+1pt)。]
```)

但是该方式是不被推荐的，因为一个长度值中的相对长度分量会被评估为`0pt`，从而导致计算失真：

#code(```typ
长度等于 #context length-of(1em+1pt+100%)。
```)

这是因为在评估的时候，`measure`没有为内容锚定一个“父元素”。

一种更为鲁棒的方法是使用`layout`函数获取`layout`位置的宽度和高度信息：

#code(```typ
长度等于#box(width: 1em+1pt+100%,
  layout(l => l.width))
```)

但是使用`layout`会导致布局的多轮迭代，有可能*严重*降低编译性能。

== 布局概览与布局模型

Typst的布局引擎仍未完成，其主要#absent[缺失]或#ng[不足]的内容为：
+ 修饰段落容器的#absent[行]或#ng[字符]的能力。
+ 将段落容器的接口#ng[暴露]给用户的能力。
+ #ng[浮动布局]的能力。
+ #ng[更灵活]的Layout Splitter。目前仅支持`columns`（多栏布局）的能力。

Typst的布局代码风格是用一系列容器函数包装的内容，再将整个内容交给布局引擎反复*迭代*求解。容器就是一类特殊的「元素」，它并不真正具备具体的内容，而仅仅容纳一个或多个「内容」，*以便布局*。这与JSX有些相似。

针对PDF页面模型，Typst构建了完整的容器层次。Todo：用cetz绘制层次：
#todo-box[在0.13.0之后, 情况有所改变]

1. page，一个PDF有很多页。
2. par，一个文档中有很多段。
3. block，一页/段中有很多块。
4. box，一个块中有很多行内元素。
5. sequence，很多个元素可以组成一个元素序列。
6. 各种基础元素。

=== page

每个`page`都单独产生一个单独的页面。并且若你希望将Typst文档导出为PDF，其恰好为PDF中单独的一页。

任何内容都会至少产生新的一页：

```typ
// 第一页
A
```

每个`pagebreak`函数（分页函数）将会产生新的一页：

```typ
// 第一页
A
#pagebreak()
// 第二页
B
```

```typ
// 第一页
A
#pagebreak()
// 第二页
#pagebreak()
// 第三页
B
```

你可以使用`#pagebreak(weak: true)`产生弱的分页。这里弱的意思是：假设当前页面并没有包含任何内容，`pagebreak(weak: true)`就不会创建新的页面。你可以理解为弱的分页意即非必要不分页。

```typ
// 第一页
A
#pagebreak(weak: true)
#pagebreak(weak: true)
// 第二页
B
```

每个`page`函数都会单列新的一页：

```typ
// 第一页
A
#page[
  // 第二页
  A
]
// 第三页
B
```

如果`page`的前后已经是空页，则`page`不会导致前后产生空页。

```typ
// 这里不分页
#page[
  // 第一页
  A
] // 这里不分页
#page[
  // 第二页
  A
] // 这里不分页
```

你可以理解为`page`前后自动产生弱的分页，其前后*非必要不分页*，上例相当于：

```typ
#pagebreak(weak: true)
// 第一页
A
#pagebreak(weak: true)
#pagebreak(weak: true)
// 第二页
A
#pagebreak(weak: true)
```

所以`page`与`pagebreak`是互通的，你可以随意使用你喜欢的风格创建新的页面。

*注意*：设置`page`样式将导致新的弱分页：

```typ
// 第一页
A
#set page(..)
// 第二页
B
```

等价于：

```typ
A
#pagebreak(weak: true)
#set page(..)
#pagebreak(weak: true)
B
```

=== par

每个`par`都单独产生一个单独的段落。

`par`的特性与`page`完全相同，其前后非必要不分段。

#code(```typ
#par[
  // 第一段
  A
]
```)

`parbreak`与`pagebreak`也是除了同理，除了`parbreak`一定是弱分段，并且没有可以指定的`weak`参数：

#code(```typ
// 第一段
A
#parbreak()
#parbreak()
// 第二段
B
```)

很多元素都会在其前后自动产生新的段落，例如`figure`和`heading`。

=== block

`block`是布局中的块状元素。块状元素会在布局中自成一行。你几乎可以将`block`理解为某种程度上的分段：

#code(```typ
// 第一段
#block(fill: blue)[A]
#block(fill: blue)[B]
```)

事实上`par`本来就由`block`组成。你可以通过对`block`设置规则影响到段间距：

#code(```typ
#set block(spacing: 0.5em)
A
#parbreak()
#parbreak()
B
```)

=== box

`box`是布局中的行内块元素。行内块元素会在布局中自成一行。所谓行内块即其自成一块但不会立即导致换行。如下所示：

#code(```typ
#rect(width: 100pt)[a a a #box(fill: blue)[A A A A A]a a a]
```)

`box`并不意味着不换行。`box`的宽度默认占满父元素内宽度的```typc 100%```。`box`内部的文本在其内部继续换行。如下所示，当文字太多时，将导致其在`box`内部换行：

#code(```typ
#rect(width: 100pt)[#box(fill: blue)[A A A A A A A A A A A A A]]
```)

`box`整体必须处于段落中的同一行：

#code(```typ
#rect(width: 100pt)[a a a a#box(fill: blue, width: 50%)[A A A A A A A A A]a a a]
#rect(width: 100pt)[a a a a a#box(fill: blue, width: 50%)[A A A A A A A A A]a a a]
```)

一个妙用是，你可以将“块元素”包裹一层`box`，使得这些块元素位于段落中的同一行：

#code(```typ
我们之中混入了
#box(rect(width: 100pt)[a a a a#box(fill: blue, width: 50%)[A A A A A A A A A]a a a])
两个矩形
#box(rect(width: 100pt)[a a a a a#box(fill: blue, width: 50%)[A A A A A A A A A]a a a])
```)

=== sequence

`sequence`是布局中最松散的组织。事实上，它正是我们在《基础文档》中就学过的「内容块」。它起不到任何效果，仅仅容纳一系列其他内容。

#code(```typ
#rect(width: 100pt)[#[a a a a a a] #[a a a a a a a a] ]
```)

我们来温习一下。`sequence`主要的作用是可以储存一段内容供函数使用。使用`sequence`的一个好处是允许「标签」准确地选中一段内容。例如，以下代码自制了`highlight`效果：

#code(```typ
#show <fill-blue>: it => {
  show regex("[\w]"): it => {
    box(place(dx: -0.1em, dy: -0.15em, box(fill: blue, width: 0.85em, height: 0.95em)) + it)
  }
  it
}
#rect(width: 100pt)[#[a a a a a a] #[a a a a a a a ab] <fill-blue> ]
```)

== 「布局分割及其断点」

「布局分割器」（Splitter）将所持有内容分成多段并放置于页面上。

目前Typst唯一提供的分割器是`columns`，其实现了多栏布局。因为缺乏好用的分割器，有很多布局都*难以*在Typst中实现，例如浮动布局。但注意，这不代表现在的Typst不支持各种特殊布局。已经有外部库帮助你实现了首字母下沉，浮动布局等特殊布局。

你可以使用`columns`在任意容器内创建多栏布局，并用`colbreak`分割每栏。

#code(```typ
#columns(2)[
  #lorem(13)
  #colbreak()
  #lorem(10)
]
```)

尽管还不是很完善，在与页面的结合中，Typst为`page`提供了一个`columns`参数。该`columns`允许你设置跨页的多栏布局。

// #frames(
//   ```typ
//   #set page(columns: 2)
//   #set text(size: 5pt)
//   #lorem(130)
//   ```,
//   prelude: ```typ
//   #set page(width: 120pt, height: 120pt)
//   ```,
// )

== 「布局编排」

「布局编排器」（Arranger）将多个内容组成一个新的带有布局的整体。目前，Typst提供了两种零维布局`pad`和`align`，一种一维布局`stack`，以及一种二维布局`grid`。

== pad

你可以使用`pad`函数为内部元素设置outer padding。`pad`接受一个内容，返回一个添加padding的新内容。默认情况下，`pad`函数不添加任何padding。

#code(```typ
#let square = rect(fill: blue, width: 15pt, height: 15pt)
#box(fill: red, square)
#box(fill: red, pad(square))
```)

与CSS的`padding`属性一样，你可以使用`left`、`top`、`right`、`bottom`设置四个方向的padding：

#code(```typ
#let square = rect(fill: blue, width: 15pt, height: 15pt)
#box(fill: red, pad(left: 5pt, square))
#box(fill: red, pad(top: 5pt, square))
#box(fill: red, pad(right: 5pt, square))
#box(fill: red, baseline: 5pt, pad(bottom: 5pt, square))
#box(fill: red, pad(left: 5pt, top: 5pt, square))
#box(fill: red, pad(left: 5pt, right: 5pt, square))
```)

特别地，你可以使用`x`同时设置`left`和`right`方向的padding，`y`同时设置`top`和`bottom`方向的padding，以及`rest`设置“其余”方向的padding。

#code(```typ
#let square = rect(fill: blue, width: 15pt, height: 15pt)
#box(fill: red, pad(x: 5pt, square))
#box(fill: red, baseline: 5pt, pad(y: 5pt, square))
#box(fill: red, baseline: 2pt, pad(left: 5pt, rest: 2pt, square))
```)

== align

你可以使用`align`函数为内部元素设置相对于父元素的对齐方式。默认情况下，`align`函数使用默认对齐方式（`start+top`）。

#let square = rect(fill: rgb("c45a65c0"), width: 15pt, height: 15pt)
#let abox = box.with(fill: gradient.radial(..color.map.mako), width: 20pt, height: 20pt)

#let align-scope = (
  square: square,
  abox: abox,
  red: rgb("c45a65c0"),
)

#code(
  ```typ
  #let square = rect(fill: red, width: 15pt, height: 15pt)
  #let abox = box.with(fill: gradient.radial(..color.map.mako), width: 20pt, height: 20pt)
  #abox(square)
  #abox(align(square))
  ```,
  scope: align-scope,
)

与上一节介绍的`pad`类似，你可以使用`left`、`top`、`right`、`bottom`设置四个方向的alignment，并任意使用加号（`+`）组合出你想要的二维对齐方式：

#code(
  ```typ
  #abox(align(left + top, square))
  #abox(align(right + top, square)) \
  #abox(align(left + bottom, square))
  #abox(align(right + bottom, square))
  ```,
  scope: align-scope,
)

除了以上四种基础对齐，Typst还额外提供两套对齐方式。第一套是居中对齐，你可以使用`center`实现水平居中对齐，以及`horizon`实现垂直居中对齐。

#code(
  ```typ
  #abox(align(center, square))
  #abox(align(horizon, square))
  #abox(align(center + horizon, square))
  ```,
  scope: align-scope,
)

第二套与文本流相关。你可以使用`start`实现与文本流方向一致的对齐，以及`end`实现与文本流方向相反的对齐。

#code(
  ```typ
  #let se = abox(align(start, square)) + abox(align(end, square))
  #se \
  #set text(dir: rtl)
  #se
  ```,
  scope: align-scope,
)

=== stack

与HTML中的`flex`容器类似，`stack`可以帮你实现各种一维布局。顾名思义，`stack`将其内部元素在页面上按顺序按方向排列。

#let rects = (rect(fill: red)[1], rect(fill: blue)[2], rect(fill: green)[3])

#code(
  ```typ
  #let rects = (rect(fill: red)[1], rect(fill: blue)[2], rect(fill: green)[3])
  #stack(dir: ltr, ..rects)
  ```,
  scope: (rects: rects),
)

`stack`主要只有两个可以控制的参数。

其一是排列的方向，参数对应为`dir`。一共有四种方向可以选择，分别是：
- `ltr`: 即left to right，从左至右。
- `rtl`: 即right to left，从右至左。
- `ttb`: 即top to bottom，从上至下。
- `btt`: 即bottom to top，从下至上。

方向默认为`ttb`。

#code(
  ```typ
  #columns(2)[
    `ltr`: #box(stack(dir: ltr, ..rects)) \ `rtl`: #box(stack(dir: rtl, ..rects))
    #colbreak()
    `ttb`: #box(stack(/* 默认值为：dir: ttb, */ ..rects)) #h(1em) `btt`: #box(stack(dir: btt, ..rects))
  ]
  ```,
  scope: (rects: rects, box: box.with(baseline: 50% - 0.25em)),
)

其二是排列的间距，参数对应为`spacing`。你可以使用各种长度为`stack`内部元素制定合适的间距。

#code(
  ```typ
  #let stack = stack.with(dir: ltr)
  #let example(s) = box(width: 100pt, stack(spacing: s, ..rects))
  `5pt    `: #example(5pt    ) \
  `10%    `: #example(10%    ) \
  `5pt+10%`: #example(5pt+10%) \
  `1fr    `: #example(1fr    ) \
  ```,
  scope: (rects: rects, box: box.with(baseline: 50% - 0.25em)),
)

你也可以直接将长度作为参数传入，为每一个元素前后微调间距。

#code(
  ```typ
  #let stack = stack.with(dir: ltr)
  #let r = rect(fill: blue)[ ]
  `1fr,0pt`: #box(width: 100pt, stack(r, 1fr, r, r)) \
  `1fr,2fr`: #box(width: 100pt, stack(r, 1fr, r, 2fr, r)) \
  `10%,40%`: #box(width: 100pt, stack(r, 10%, r, 40%, r)) \
  ```,
  scope: (rects: rects, box: box.with(baseline: 50% - 0.25em)),
)

当同时声明`spacing`参数和长度参数时，长度参数会覆盖`spacing`设置：

#code(
  ```typ
  #show stack: box.with(width: 100pt, stroke: green)
  #let stack = stack.with(dir: ltr)
  #let r = rect(fill: blue)[ ]
  `         `: #stack(spacing: 5pt, r, r, r, r, r) \
  ` 0pt     `: #stack(spacing: 5pt, r, r, r, r,  0pt, r) \
  `10pt     `: #stack(spacing: 5pt, r, r, r, r, 10pt, r) \
  `10pt+10pt`: #stack(spacing: 5pt, r, r, r, r, 10pt, 10pt, r) \
  ```,
  scope: (box: box.with(baseline: 50% - 0.25em)),
)

=== stack+align/pad

你可以将`stack`与`align/pad`相结合，实现更多一维布局。以下例子对应CSS相关属性：

#code(
  ```typ
  #let box = box.with(width: 100pt, stroke: green)
  #let stack = stack.with(dir: ltr, spacing: 1fr)
  #let r = rect(fill: blue)[ ]
  `space-around 5pt`: #box(stack(5pt, r, r, 5pt)) \
  `space-around 5pt`: #box(pad(x: 5pt, stack(r, r))) \
  `justify-content end`: #box(align(end, box(width: 60pt, stack(r, r)))) \
  `justify-content center`: #box(align(center, box(width: 60pt, stack(r, r)))) \
  ```,
  scope: (box: box.with(baseline: 50% - 0.25em)),
)

上例提示我们可以组合多种布局容器实现特定的布局效果。

=== grid

与HTML中的`flex`容器类似，`grid`可以帮你实现各种二维布局。如下：

#code(```typ
#show grid: box.with(stroke: green)
#let r = rect(fill: blue, width: 10pt, height: 10pt)
#grid(columns: 3, gutter: 5pt, r, r, r, r, r)
```)

与`stack`相比，`grid`要复杂得多。

其一，`grid`的前$N - 1$行可容纳的元素是有限的，而最后一行与`stack`一样容纳其余所有元素。你可以通过`columns`参数控制这一特性。

#let g-scope = (
  r: (n, width: 10pt, height: 10pt) => range(n).map(i => rect(
    fill: color.map.rainbow.at(calc.rem(i * 16, 80)),
    width: width,
    height: height,
  )),
)

`columns`要求你给定一个数组，该数组表示一行中每列的宽度。

#code(
  ```typ
  #let r(n, width: 10pt, height: 10pt) = range(n).map(i => rect(fill: color.map.rainbow.at(calc.rem(i * 16, 80)), width: width, height: height))
  #grid(columns: (auto, ) * 10, gutter: 5pt, ..r(10)) #h(1em)
  #grid(columns: (auto, ) * 8, gutter: 5pt, ..r(10)) #h(1em)
  #grid(columns: (auto, ) * 4, gutter: 5pt, ..r(10)) #h(1em)
  #grid(columns: (auto, ) * 2, gutter: 5pt, ..r(10))
  ```,
  scope: (..g-scope, grid: (..args) => box(stroke: green, grid(..args))),
)

上例中，当`columns`数组的长度为`N`时，表示每行允许容纳`N`个元素，每列的*最大宽度*为`auto`。长度设定为`auto`，则表示每列宽度始终和该行该列内部元素宽度相等。

每列宽度不仅可以为`auto`，而且可以指定为具体长度：

#code(
  ```typ
  #show grid: box.with(stroke: green, width: 100pt)
  #let grid = grid.with(gutter: 5pt, ..r(5, width: auto))
  1: #grid(columns: (10pt, 20pt, 30pt)) #h(1em)
  2: #grid(columns: (10%, 20%, 30%)) #h(1em)
  3: #grid(columns: (1fr, 2fr, 3fr)) #h(1em) \
  4: #grid(columns: (10pt, 1fr, 1fr)) #h(1em)
  5: #grid(columns: (10pt, 1fr, 2fr)) #h(1em)
  ```,
  scope: g-scope,
)

Typst允许你使用更简便的参数表示。特别地，如果`columns`数组内容恰为$N$个`auto`，那么可以直接传入一个数字。以下两种写法是等价的：

#code(
  ```typ
  #grid(columns: 4, gutter: 5pt, ..r(10)) #h(1em)
  #grid(columns: (auto, ) * 4, gutter: 5pt, ..r(10)) #h(1em)
  ```,
  scope: (..g-scope, grid: (..args) => box(stroke: green, grid(..args))),
)

特别地，如果期望`grid`只有一列，`columns`参数允许不传入数组而是单列的长度：

#code(
  ```typ
  #show grid: box.with(stroke: green, width: 20pt)
  #let grid = grid.with(gutter: 5pt, ..r(3, width: auto))
  #grid(columns: (10pt, )) #h(1em)
  #grid(columns: 10pt) #h(1em)
  #grid(columns: 50%) #h(1em)
  #grid(columns: 80%) #h(1em)
  ```,
  scope: g-scope,
)

特别地，columns的默认值可以理解为`auto`。

其二，`grid`不再允许混杂内容与长度来控制某行或某列元素之间的间隔。取而代之的是三个更为复杂的参数：`gutter`、`row-gutter`和`column-gutter`。这是因为“混杂的gutter”在二维布局中有歧义。

`gutter`参数事实上是`spacing`参数的加强版。它允许通过传入一个长度数组为*每行每列依次*设置间隔：

#code(
  ```typ
  #let grid = grid.with(columns: (auto, ) * 4, ..r(15))
  #grid(gutter: 5pt) #h(1em)
  #grid(gutter: (5pt, 10pt, 15pt)) #h(1em)
  ```,
  scope: (..g-scope, grid: (..args) => box(stroke: green, grid(..args))),
)

特别地，如果`gutter`参数数组比`rows`参数数组或者`columns`参数数组更短，其余行或列的的间隔以`gutter`参数数组的最后一个长度为准：

#code(
  ```typ
  #let grid = grid.with(columns: (auto, ) * 5, ..r(9))
  // 等价为`5pt, 5pt, 5pt, ..`, 一直5pt下去
  #grid(gutter: 5pt) #h(1em)
  // 等价为`5pt, 5pt, 5pt, ..`, 一直5pt下去
  #grid(gutter: (5pt,)) #h(1em)
  // 等价为`5pt, 10pt, 10pt, ..`, 一直10pt下去
  #grid(gutter: (5pt, 10pt)) #h(1em)
  ```,
  scope: (..g-scope, grid: (..args) => box(stroke: green, grid(..args))),
)

你可以指定`column-gutter`而非`gutter`，从而单独为*每列*设置间隔。`column-gutter`参数的优先级比`gutter`参数要高。

#code(
  ```typ
  #let grid = grid.with(columns: (auto, ) * 4, ..r(15))
  #grid(gutter: (5pt, 10pt, 15pt)) #h(1em)
  #grid(gutter: 5pt, column-gutter: (5pt, 10pt, 15pt)) #h(1em)
  #grid(column-gutter: (5pt, 10pt, 15pt)) #h(1em)
  ```,
  scope: (..g-scope, grid: (..args) => box(stroke: green, grid(..args))),
)

与`column-gutter`同理，你也可以指定`row-gutter`而非`gutter`，从而单独为*每行*设置间隔。

与`columns`同理，你可以指定`rows`从而为每行设置高度。但是请注意，Typst对`rows`参数数组的解释方式与`columns`不同，而与`gutter`相同：

#code(
  ```typ
  #show grid: box.with(stroke: green, height: 120pt)
  #let grid = grid.with(columns: 2, gutter: 5pt, ..r(7, height: auto))
  // 等价为`10pt, 10pt, 10pt, ..`, 一直10pt下去
  1: #grid(rows: (10pt, )) #h(1em)
  // 等价为`10pt, 20pt, 20pt, ..`, 一直20pt下去
  2: #grid(rows: (10pt, 20pt)) #h(1em)
  // 等价为`1fr, 2fr, 2fr, ..`, 一直2fr下去
  3: #grid(rows: (1fr, 2fr)) #h(1em)
  ```,
  scope: g-scope,
)

// #grid(gutter: (5pt, 10pt)) #h(1em)

== 「间距」

此类函数的概念引自LaTeX，又称胶水函数。一共有两个方向的间距，分别是水平间距与竖直间距。

水平间距（`h`，horizon）不包含内容，而仅仅在布局中占据一定宽度：

#code(```typ
两句话之间间隔`0pt`#h(0pt)两句话之间间隔`0pt` \
两句话之间间隔`5pt`#h(5pt)两句话之间间隔`5pt` \
两句话之间间隔`1em`#h(1em)两句话之间间隔`1em` \
间隔`1fr`#h(1fr)间隔`1fr` \
间隔`1fr`#h(1fr)间隔`...`#h(2fr)间隔`2fr` \
#h(1fr)夹心的`1fr``...`#h(1fr) \
```)

同理竖直间距（`v`，vertical）不包含内容，而仅仅在布局中占据一定高度。插入竖直间距将会导致强制换行。

#code(```typ
1 2 \
1 \ 2 \
1 #v(-1em) 2
```)

== 「空间变换」

一共有三种类型的空间变换，分别是：
- `move`：移动元素。
- `scale`：拉伸元素。
- `rotate`：旋转元素。

它们都*不会影响布局*，且都会*导致强制换行*。

`move`相对于当前位置移动一段距离。

#code(```typ
#rect(inset: 0pt, move(
  dx: 6pt, dy: 6pt,
  rect(
    inset: 8pt,
    fill: white,
    stroke: black,
    [Abra cadabra]
  )
))
```)

你可以使用`box`将其改为行内元素行为：

#code(```typ
#let TeX(width) = {
  set text(font: "New Computer Modern", weight: "regular")
  box(width: width, {
    [T]
    box(stroke: red, move(dx: -0.2em, dy: 0.22em)[E])
    box(stroke: green, move(dx: -0.4em)[X])
  })
}
#TeX(2.2em) is a digital typographical systems. \
#TeX(2.1em) is a digital typographical systems.
```)

`scale`可以拉伸元素，且`scale`会导致强制换行：

#code(```typ
#scale(x: 110%)[This is mirrored.]
#box(scale(x: 100%)[This is scaled.]) 1 \
#box(scale(x: 115%)[This is scaled.]) 1
```)

特别地，你可以指定负长度以反转元素：

#code(```typ
#scale(x: -100%)[This is mirrored.]
```)

`rotate`可以旋转元素：

#code(```typ
#rotate(5deg)[This is rotated.]
```)

== 让「空间变换」函数影响布局

虽然内置的`move`等函数不会影响布局，但是你可以通过`box`模拟子元素对父元素的布局影响：

#code(```typ
#let ac(a) = calc.abs(calc.cos(a))
#let ax(a) = calc.abs(calc.sin(a))
#let rot(x,y,a) = .5*(x*(ac(a)-1)+y*ax(a))
#let rotx(body, angle) = context {
let sz = measure(body)
box(stroke: green, inset: (
  x: rot(sz.width, sz.height, angle),
  y: rot(sz.height, sz.width, angle)),
  rotate(body, angle))
}
#lorem(7) This is a #rotx([Vertical],-90deg) word, and #rotx([this],-7deg) is #rotx([skew.],7deg) It also works with #rotx($e^(-x)$,-95deg). #lorem(20)
```)

例子使用了`measure`函数评估子元素的大小，并强行改变子元素的边界框（bounding box）。

== 「绝对定位布局」

你可以使用`place`完成「绝对定位布局」（absolute positioning）。`place`相对于父元素移动一段距离，其接受一个`alignment`参数，将元素放置在相对于父元素`alignment`的绝对位置。例如下例相对于父元素的右上角放置了一个矩形框：

#code(```typ
#box(height: 30pt, width: 100%)[
  Hello, world!
  #place(
    top + right,
    square(
      width: 20pt,
      stroke: 2pt + blue
    ),
  )
]
```)

`place`会使得子元素脱离父元素布局。对比两例：

#code(```typ
#let TeX(width: 2.2em) = {
  set text(font: "New Computer Modern", weight: "regular")
  box(width: width, {
    [T]
    box(stroke: red, move(dx: -0.2em, dy: 0.22em)[E])
    box(stroke: green, move(dx: -0.4em)[X])
  })
}
#TeX() is a digital typographical systems. \
#let TeX = {
  set text(font: "New Computer Modern", weight: "regular")
  box(width: 1.7em, {
    [T]
    place(top, dx: 0.56em, dy: 0.22em, box(stroke: red, [E]))
    place(top, dx: 1.1em, box(stroke: green, [X]))
  })
}
#TeX is a digital typographical systems.
```)

你可以使用`place(float: true)`以创建相对于父元素的浮动布局。（todo）

== 杂项
+ hide
+ repeat
