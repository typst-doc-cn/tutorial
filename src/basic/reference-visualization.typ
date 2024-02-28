#import "mod.typ": *

#show: book.ref-page.with(title: [参考：图形与几何元素])

== 直线

A line from one point to another. #ref-bookmark[`line`]

#code(```typ
#line(length: 100%)
#line(end: (50%, 50%))
#line(
  length: 4cm,
  stroke: 2pt + maroon,
)
```)

== 线条样式

Defines how to draw a line. #ref-bookmark[`stroke`]

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

A path through a list of points, connected by Bezier curves. #ref-bookmark[`path`]

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

A circle with optional content. #ref-bookmark[`circle`]

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

An ellipse with optional content. #ref-bookmark[`ellipse`]

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

A square with optional content. #ref-bookmark[`square`]

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

A rectangle with optional content. #ref-bookmark[`rect`]

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

A closed polygon. #ref-bookmark[`ellipse`]

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
