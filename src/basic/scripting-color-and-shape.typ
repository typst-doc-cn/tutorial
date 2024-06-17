#import "mod.typ": *

#show: book.page.with(title: "色彩与图表")

== 颜色类型

Typst只有一种颜色类型，但是有很多颜色构造函数。用术语讲，Typst允许你在不同的「色彩空间」中构造颜色。RGB是我们最使用的色彩空间，对应Typst的`color.rgb`函数或`rgb`函数：

#code(```typ
#box(square(fill: color.rgb("#b1f2eb")))
#box(square(fill: rgb(87, 127, 230)))
#box(square(fill: rgb(25%, 13%, 65%)))
```)

除此之外，还支持HSL（`hsl`）、CMYK（`cmyk`）、Luma（`luma`）、Oklab（`oklab`）、Oklch（`oklch`）、Linear RGB（`color.linear-rgb`）、HSV（`color.hsv`）等色彩空间。感兴趣的可以自行搜索并使用。

#pro-tip[
  尽管你可以随意使用这些构造器，但是可能会导致PDF阅读器或浏览器的兼容性问题。它们可能不支持某些色彩空间（或色彩模式）。
]

除此之外，你还可以使用一些预定义的颜色，详见《》。

#code(```typ
#box(square(fill: red, size: 7pt))
#box(square(fill: blue, size: 7pt))
```)

== 颜色操作

=== lighten

Lightens a color by a given factor.

=== darken

Darkens a color by a given factor.

=== saturate

Increases the saturation of a color by a given factor.

=== negate

Produces the negative of the color.

=== rotate

Rotates the hue of the color by a given angle.

=== mix

Create a color by mixing two or more colors.

== 渐变色和模式

A color gradient. #ref-bookmark[`gradient`]

Typst supports linear gradients through the gradient.linear function, radial gradients through the gradient.radial function, and conic gradients through the gradient.conic function.

A gradient can be used for the following purposes:

- As a fill to paint the interior of a shape: ```typc rect(fill: gradient.linear(..))```
- As a stroke to paint the outline of a shape: ```typc rect(stroke: 1pt + gradient.linear(..))```
- As the fill of text: ```typc set text(fill: gradient.linear(..))```
- As a color map you can sample from: ```typc gradient.linear(..).sample(0.5)```

#code(```typ
#stack(
  dir: ltr,
  spacing: 1fr,
  square(fill: gradient.linear(
    ..color.map.rainbow)),
  square(fill: gradient.radial(
    ..color.map.rainbow)),
  square(fill: gradient.conic(
    ..color.map.rainbow)),
)
```)

== 填充模式

A repeating pattern fill. #ref-bookmark[`pattern`]

Typst supports the most common pattern type of tiled patterns, where a pattern is repeated in a grid-like fashion, covering the entire area of an element that is filled or stroked. The pattern is defined by a tile size and a body defining the content of each cell. You can also add horizontal or vertical spacing between the cells of the patterng.

#code(```typ
#let pat = pattern(size: (30pt, 30pt))[
  #place(line(start: (0%, 0%), end: (100%, 100%)))
  #place(line(start: (0%, 100%), end: (100%, 0%)))
]

#rect(fill: pat, width: 100%, height: 60pt, stroke: 1pt)
```)

== 直线

A line from one point to another.

#code(```typ
#line(length: 100%)
#line(end: (50%, 50%))
#line(
  length: 4cm,
  stroke: 2pt + maroon,
)
```)

== 线条样式

Defines how to draw a line.

A stroke has a paint (a solid color or gradient), a thickness, a line cap, a line join, a miter limit, and a dash pattern. All of these values are optional and have sensible defaults.

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

== 贝塞尔路径（曲线）

A path through a list of points, connected by Bezier curves.

#code(```typ
#path(
  fill: blue.lighten(80%),
  stroke: blue,
  closed: true,
  (0pt, 50pt),
  (100%, 50pt),
  ((50%, 0pt), (40pt, 0pt)),
)
```)

== 圆形

A circle with optional content.

#code(```typ
// Without content.
#circle(radius: 25pt)

// With content.
#circle[
  #set align(center + horizon)
  Automatically \
  sized to fit.
]
```)

== 椭圆

An ellipse with optional content.

#code(```typ
// Without content.
#ellipse(width: 35%, height: 30pt)

// With content.
#ellipse[
  #set align(center)
  Automatically sized \
  to fit the content.
]
```)

== 正方形

A square with optional content.

#code(```typ
// Without content.
#square(size: 40pt)

// With content.
#square[
  Automatically \
  sized to fit.
]
```)

== 矩形

A rectangle with optional content.

#code(```typ
// Without content.
#rect(width: 35%, height: 30pt)

// With content.
#rect[
  Automatically sized \
  to fit the content.
]
```)

== 多边形

A closed polygon.

The polygon is defined by its corner points and is closed automatically.

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

== 图形库

+ typst-fletcher
+ typst-syntree
+ cetz

// #table()
