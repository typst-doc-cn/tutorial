#import "mod.typ": *

#show: book.ref-page.with(title: [参考：长度单位])

#show quote: it => {
  box(stroke: (
    left: 2pt + main-color,
  ), inset: (
    left: 12pt,
    y: 8pt,
  ), {
    stack(
      {
        set text(style: "italic")
        it.body
      },
      if "attribution" in it.fields() {
        1em
      },
      if "attribution" in it.fields() {
        align(right, [——]+it.attribution)
      }
    )
  })
}

在Typst中有三种不同种类的长度单位，它们是：绝对长度（absolute length）、相对长度（relative length）与上下文有关长度（context-sensitive length）。

+ 绝对长度：人们最熟知的长度单位。例如，```typc 1cm```恰等于真实的一厘米。
  
  #code(```typ
  1cm等于#1cm
  ```)

+ 相对长度：与父元素长度相关联的长度单位，例如```typc 100%```恰等于父元素高度或宽度的100%。下例即获得一个`box(width: 70%)`的实际宽度，其等于父元素`box(width: 123pt)`的`70%`：
  
  #code(```typ
  123pt \* 70%等于#(123pt * 70%) \
  子box宽度等于#box(width: 123pt, box(width: 70%, layout(l => l.width)))
  ```)

+ 上下文有关长度：与样式等上下文有关的长度单位，例如```typc 1em```恰等于当前位置设定的字体长度。
  
  #code(```typ
  #let measured-length = style(styles => measure(line(length: 1em), styles).width)
  #{
    set text(size: 10pt)
    [1em等于] + measured-length
    set text(size: 20pt)
    [\ 1em等于] + measured-length
  }
  ```)

== 绝对长度

目前Typst一共提供四种绝对长度。除了公制长度单位```typc 1cm```与```typc 1mm```与英制长度单位```typc 1in```，Typst还提供排版专用的长度单位“点”，即```typc 1pt```。

#quote(attribution: link("https://zh.wikipedia.org/wiki/%E9%BB%9E_(%E5%8D%B0%E5%88%B7)")[维基百科：点 (印刷)])[
  点（英语：point），pt，是印刷所使用的长度单位，用于表示字型的大小，也用于余白（字距、行距）等其他版面构成要素的长度。作为铸字行业内部的一个专用单位，1 点的长度在世界各地、各个时代曾经有过不同定义，并不统一。当代最通行的是广泛应用于桌面排版软件的 DTP 点，72 点等于 1英寸（1 point = 127⁄360 mm = 0.352777... mm）。中国传统字体排印上的字号单位是号，而后采用“点”“号”兼容的体制。
]

Typst会将你提供的任意长度单位都统一成点单位，以便进行长度运算。

#code(```typ
#set align(center)
#let units = ((1pt, "pt"), (1mm, "mm"), (1cm, "cm"), (1in, "in"))
#let methods = (length.pt, length.mm, length.cm, length.inches)
#table(
  columns: 5,
  "", ..("pt", "mm", "cm", "in").map(e => raw("=?" + e)),
  ..units.map(((l, u)) => {
    (raw("1" + u, lang: "typc"), ) + methods.map(
        method => [#calc.round(method(l), digits: 2)])
  }).flatten()
)
```)

== 绝对长度的运算

长度单位可以参与任意多个浮点值的运算。一个长度表达式是合法的当且仅当运算结果*保持长度量纲*。请观察下列算式，它们都可以编译：

#code(```typ
#(1cm * 3), #(1cm / 3), #(2 * 1cm * 3 / 2), #(1cm + 3in)
```)

请观察下列算式，它们都不能编译：

#(```typ
#(1cm + 3), #(3 / 1cm), #(1cm * 1cm)
```)

所谓*保持长度量纲*，即：

- 由于`1cm`与`3in`量纲均为长度量纲（`m`），它们之间*可以*进行*加减*运算。
- 由于`3`无量纲，`1cm`与`3`之间*不能*进行*加减*运算。

进一步，通过量纲运算，可以判断一个长度算术表达式是否合法：

#{
  set align(center)
  table(columns: 4,
[长度表达式],[量纲运算],[检查合法性],[判断结果],
```typc 1cm * 3```, $bold(sans(m dot 1 = m))$, $bold(sans(m = m))$, [合法],

```typc 1cm / 3```, $ bold(sans(m op(slash) 1 = m))$, $bold(sans(m = m))$, [合法],

```typc 3 / 1cm```, $ bold(sans(1 op(slash) m = m^(-1)))$, $bold(sans(m^(-1) = m))$, [非法],

```typc 1cm * 1cm```, $ bold(sans(m dot m = m^2))$, $bold(sans(m^2 = m))$, [非法]
)
}

== 绝对长度的转换

你可以使用`length`类型上的「方法」实现不同单位到浮点数的转换：

#code(```typ
#1cm 是 #1cm.pt() 点 \
#1cm 是 #1cm.mm() 毫米 \
#1cm 是 #1cm.cm() 厘米 \
#1cm 是 #1cm.inches() 英尺
```)

你可以使用乘法实现浮点数到长度上的转换：

#code(```typ
#(28.3465 * 1pt) 是 #(28.3465 * 1pt).cm() 厘米
```)

== 相对长度

有两种相对长度（Relative Length），一是百分比（Ratio），一是分数比（Fraction）。

=== 百分比 <reference-type-ratio>

当「百分比」用作长度时，其实际值取决于父容器宽度：

#code(```typ
#box(width: 100pt, fill: blue, box(width: 66.66%, height: 10pt, fill: red) + box(width: 33.34%, height: 10pt, fill: blue))
```)

Typst还支持以「分数比」作长度单位。当分数比作长度单位时，Typst按比例分配长度。

#code(```typ
#let p(w, f) = box(width: w, height: 10pt, fill: f)
1比1比1宽度: #box(width: 100pt, fill: blue, p(1fr, red) + p(1fr, blue) + p(1fr, green))
1比2宽度: #box(width: 100pt, fill: blue, p(1fr, red) + p(2fr, blue))
```)

结合代码与图例理解，`N fr`代表：在总的比例中，这个元素应当占有其中`N`份长度。

当同级元素既有分数比长度元素，又有其他长度单位元素时，优先将空间分配给其他长度单位元素。

#code(```typ
#let p(w, f) = box(width: w, height: 10pt, fill: f)
绿色占60%，其余元素瓜分余下40%空间: #box(width: 100pt, fill: blue, p(1fr, red) + p(2fr, blue) + p(60%, green)) \
绿色占110%，其余元素已无空间可以瓜分: #box(width: 100pt, fill: blue, p(1fr, red) + p(1fr, blue) + p(110%, green))
```)

建议结合#(refs.ref-layout)[《布局函数》]中grid布局关于长度的使用，加深对相对长度的理解。

== 上下文有关长度

目前Typst仅提供一种上下文有关长度，即当前上下文中的字体大小。历史上，定义该字体中大写字母`M`的宽度为`1em`，但是现代排版中，`1em`可以比`M`的宽度要更窄或者更宽：

#code(```typ
#let bm = [#box(move(box(height: 1em, width: 1em, fill: blue), dx: 1em))M]
#bm
#set text(size: 20pt)
#bm
```)

通过`repr`，可以发现`1em`不会像绝对长度那样被直接转化为“点”：

#code(```typ
#repr(1em)
```)

== 混合长度

以上所介绍的各种长度可以通过「加号」任意混合成单个长度的值，其长度的值为每个分量总和：

#code(```typ
#(1pt + 1em + 100%)
```)

== 长度的内省或评估

你可以通过`measure`获取`1em`在当前位置的具体值：

#code(```typ
#let measured-length(l) = style(styles => measure(line(length: l), styles).width)
1em等于 #measured-length(1em)。1em+1pt等于 #measured-length(1em+1pt)。
```)

但是该方式是不被推荐的，因为一个长度值中的相对长度分量会被评估为`0pt`，从而导致计算失真：

#code(```typ
#let measured-length(l) = style(styles => measure(line(length: l), styles).width)
1em+1pt+100%等于 #measured-length(1em+1pt+100%)。
```)

这是因为提供给`measure`的内容在评估的时候没有锚定一个“父元素”。

一种更为鲁棒的方法是使用`layout`函数获取`layout`位置的宽度和高度信息：

#code(```typ
1em+1pt+100%等于#box(width: 1em+1pt+100%, layout(l => l.width))
```)

但是使用`layout`会导致布局的多轮迭代，有可能*严重*降低编译性能。
