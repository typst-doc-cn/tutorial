#import "mod.typ": *

#show: book.page.with(title: "图形排版")

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
