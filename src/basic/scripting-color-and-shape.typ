#import "mod.typ": *

#show: book.page.with(title: "色彩与图表")

== 颜色类型

Typst只有一种颜色类型，其由两部分组成。

#figure([
  #block(
    width: 200pt,
    align(left)[
      ```typ
      #color.rgb(87, 127, 230)
       --------- ------------
           |           +-- 色坐标
           +-- 色彩空间对应的构造函数
      ```
    ],
  )
  #text(todo-color)[这里有个图注解]
])


「色彩空间」（color space）是人们主观确定的色彩模型。Typst为不同的色彩空间提供了专门的构造函数。

「色坐标」（chromaticity coordinate）是客观颜色在「色彩空间」中的坐标。给定一个色彩空间，如果某种颜色*在空间内*，那么颜色能分解到不同坐标分量上，并确定每个坐标分量上的数值。反之，选择一个构造函数，并提供坐标分量上的数值，就能构造出这个颜色。

#todo-box[
  chromaticity coordinate这个名词是对的吗，每种色彩空间中的坐标都是这个名字吗？
]

习惯上，颜色的坐标分量又称为颜色的「通道」。从物理角度，Typst使用`f32`存储颜色每通道的值，这允许你对颜色进行较复杂的计算，且计算结果仍然保证较好的误差。

== 色彩空间

RGB是我们使用最多的色彩空间，对应Typst的`color.rgb`函数或`rgb`函数：

#code(```typ
#box(square(fill: color.rgb("#b1f2eb")))
#box(square(fill: rgb(87, 127, 230)))
#box(square(fill: rgb(25%, 13%, 65%)))
```)

除此之外，还支持HSL（`hsl`）、CMYK（`cmyk`）、Luma（`luma`）、Oklab（`oklab`）、Oklch（`oklch`）、Linear RGB（`color.linear-rgb`）、HSV（`color.hsv`）等色彩空间。感兴趣的可以自行搜索并使用。

#pro-tip[
  尽管你可以随意使用这些构造器，但是可能会导致PDF阅读器或浏览器的兼容性问题。它们可能不支持某些色彩空间（或色彩模式）。
]

== 预定义颜色

除此之外，你还可以使用一些预定义的颜色，详见#link("https://typst.app/docs/reference/visualize/color/#predefined-colors")[《Typst Docs: Predefined colors》。]

#code(```typ
#box(square(fill: red, size: 7pt))
#box(square(fill: blue, size: 7pt))
```)

== 颜色计算

Typst较LaTeX的一个有趣的特色是内置了很多方法对颜色进行计算。这允许你基于某个颜色主题（Theme）配置更丰富的颜色方案。这里给出几个常用的函数：

- `lighten/darken`：增减颜色的亮度，参数为绝对的百分比。
- `saturate/desaturate`：增减颜色的饱和度，参数为绝对的百分比。
- `mix`：参数为两个待混合的颜色。

#code(```typ
#show square: box
#set square(size: 15pt)
#square(fill: red.lighten(20%))
#square(fill: red.darken(20%)) \
#square(fill: red.saturate(20%))
#square(fill: red.desaturate(20%)) \
#square(fill: blue.mix(green))
```)

还有一些其他不太常见的颜色计算，详见#link("https://typst.app/docs/reference/visualize/color/#definitions-lighten")[《Typst Docs: Color operations》]。

== 渐变色

你可以以某种方式对Typst中的元素进行渐变填充。这有时候对科学作图很有帮助。

有三种渐变色的构造函数，可以分别构造出线性渐变（Linear Gradient），径向渐变（Radial Gradient），锥形渐变（Conic Gradient）。他们都接受一组颜色，对元素进行颜色填充。

#code(```typ
#let sqr(f) = square(fill: f(
    ..color.map.rainbow))
#stack(
  dir: ltr, spacing: 10pt,
  sqr(gradient.linear),
  sqr(gradient.radial),
  sqr(gradient.conic ))
```)

从字面意思理解`color.map.rainbow`是Typst为你预定义的一个颜色数组，按顺序给出了彩虹渐变的颜色。还有一些其他预定义的颜色数组，详见#link("https://typst.app/docs/reference/visualize/color/#predefined-color-maps")[《Typst Docs: Predefined color maps》]。

== 填充模式

Typst不仅支持颜色填充，还支持按照固定的模式将其他图形对元素进行填充。例如下面的pat定义了一个长为`61.8pt`，宽为`50pt`的图形。将其填充进一个矩形中，填充图形从左至右，从上至下布满矩形内容中。

#code(```typ
#let pat = pattern(size: (61.8pt, 50pt))[
  #place(line(start: (0%, 0%), end: (100%, 100%)))
  #place(line(start: (0%, 100%), end: (100%, 0%)))
]

#rect(fill: pat, width: 100%, height: 60pt, stroke: 1pt)
```)

== 线条

我们学习的第一个图形元素是直线。

`line`函数创建一个直线元素。这个函数接受一系列参数，包括线条的长度、起始点、终止点、颜色、粗细等。

#code(```typ
#line(length: 100%)
#line(end: (50%, 50%))
#line(
  length: 30%, stroke: 2pt + maroon)
```)

除了直线，Typst还支持二次、三次贝塞尔曲线，以及它们和直线的组合。贝塞尔曲线是一种光滑的曲线，由一系列点和控制点组成。

#code(```typ
#curve(
  stroke: blue,
  curve.move((0pt, 20pt)),
  curve.quad((40%, 0pt), (100%, 0pt)),
  curve.line((100%, 20pt)),
  curve.close()
)
```)

== 线条样式

与各类图形紧密联系的类型是「线条样式」（stroke）。线条样式可以是一个简单的「字典」，包含样式数据：

#code(```typ
#set line(length: 100%)
#let rainbow = gradient.linear(
  ..color.map.rainbow)
#stack(
  spacing: 1em,
  line(stroke: 2pt + red),
  line(stroke: (paint: blue, thickness: 4pt, cap: "round")),
  line(stroke: (paint: blue, thickness: 1pt, dash: "dashed")),
  line(stroke: 2pt + rainbow),
)
```)

你也可以使用`stroke`函数来设置线条样式：

#code(```typ
#set line(length: 100%)
#let blue-line-style = stroke(
  paint: blue, thickness: 2pt)
#line(stroke: blue-line-style)
```)

== 填充样式

填充样式（fill）是另一个重要的图形属性。如果一个路径是闭合的，那么它可以被填充。

#code(```typ
#curve(
  fill: blue.lighten(80%),
  stroke: blue,
  curve.move((0pt, 50pt)),
  curve.line((100pt, 50pt)),
  curve.cubic(none, (90pt, 0pt), (50pt, 0pt)),
  curve.close(),
)
```)

== 闭合图形

Typst为你预定义了一些基于贝塞尔曲线的闭合图形元素。下例子中，`#circle`、`#ellipse`、`#square`、`#rect`、`#polygon`分别展示了圆、椭圆、正方形、矩形、多边形的构造方法。

#code(```typ
#box(circle(radius: 12.5pt, fill: blue))
#box(ellipse(width: 50pt, height: 25pt))
#box(square(size: 25pt, stroke: red))
#box(rect(width: 50pt, height: 25pt))
```)

值得注意的是，这些图形元素都允许自适应一个内嵌的内容。例如矩形作为最常用的边框图形：

#code(```typ
#rect[
  Automatically sized \
  to fit the content.
]
```)

== 多边形

多边形是仅使用直线组合而成的闭合图形。你可以使用`polygon`函数构造一个多边形。

#code(```typ
#polygon(
  fill: blue.lighten(80%),
  stroke: blue,
  (20%, 0pt),
  (60%, 0pt),
  (80%, 2cm),
  (0%,  2cm),
)
```)

`polygon`不允许内嵌内容。

== 外部图形库

很多时候我们只需要在文档中插入分割线（直线）和文本框（带文本的矩形）。但是，若有需求，一些外部图形库可以帮助你绘制更复杂的图形：

+ 树形图：#link("https://typst.app/universe/package/syntree")[typst-syntree]
+ 拓扑图：#link("https://typst.app/universe/package/fletcher")[typst-fletcher]
+ Canvas通用图形库：#link("https://typst.app/universe/package/cetz")[cetz]

这些库也是很好的参考资料，你可以通过查看源代码来学习如何绘制复杂的图形。
