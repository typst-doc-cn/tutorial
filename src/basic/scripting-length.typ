#import "mod.typ": *

#show: book.page.with(title: "度量")

本章我们再度回到排版专题，拓宽制作文档的能力。

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
