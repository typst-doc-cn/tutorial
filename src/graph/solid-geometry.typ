#import "mod.typ": *
#import "@preview/cetz:0.3.4": *

#show: book.page.with(title: "立体几何")

== 变换「坐标系」

在绘制立体图形（以及其他抽象图形）时，最重要的思路是变换「坐标系」（Viewport），以方便绘制。

#code(```typ
#import "@preview/cetz:0.3.4": *
#canvas({
  import draw: *
  let axis-line(p) = {
    line((0, 0), (x: 1.5), stroke: red)
    line((0, 0), (y: 1.5), stroke: blue)
    line((0, 0), (z: 1.5), stroke: green)
    circle((0, 0, 0), fill: black, radius: 0.05)
    content((-0.4, 0.1, -0.2), p)
  }
  set-viewport((0, 0, 0), (4, 4, -4), bounds: (4, 4, 4))
  axis-line("A")
  set-viewport((4, 4, 4), (0, 0, 0), bounds: (4, 4, 4))
  axis-line("B")
})
```)

== 使用「空间变换」

由于「空间变换」（Transformation）的存在，你可以先绘制基本图形，再使用变换完成图形的绘制：

```typ
#let 六面体 = {
  import draw: *
  let neg(u) = if u == 0 { 1 } else { -1 }
  for (p, c) in (
    ((0, 0, 0), black), ((1, 1, 0), red),
    ((1, 0, 1), blue), ((0, 1, 1), green),
  ) {
    line(vector.add(p, (0, 0, neg(p.at(2)))), p, stroke: c)
    line(vector.add(p, (0, neg(p.at(1)), 0)), p, stroke: c)
    line(vector.add(p, (neg(p.at(0)), 0, 0)), p, stroke: c)
  }
}
```

#let 六面体 = {
  import draw: *
  let neg(u) = if u == 0 {
    1
  } else {
    -1
  }
  for (p, c) in (
    ((0, 0, 0), black),
    ((1, 1, 0), red),
    ((1, 0, 1), blue),
    ((0, 1, 1), green),
  ) {
    line(vector.add(p, (0, 0, neg(p.at(2)))), p, stroke: c)
    line(vector.add(p, (0, neg(p.at(1)), 0)), p, stroke: c)
    line(vector.add(p, (neg(p.at(0)), 0, 0)), p, stroke: c)
  }
}

运行以下代码你将获得：

#code(
  ```typ
  #import "@preview/cetz:0.3.4": *
  #align(center, canvas(六面体))
  ```,
  scope: (六面体: 六面体),
)

#pagebreak(weak: true)

== 六面体

#code(
  ```typ
  #import "@preview/cetz:0.3.4": *
  #align(center, canvas({
    import draw: *
    set-viewport((0, 0, 0), (4, 4, -4), bounds: (1, 1, 1))
    group(name: "S", translate((0, 0, 0)) + {
      anchor("O", (0, 0, 0))
      六面体
    })
    group(name: "T", translate((1.4, 0, 0)) + scale(x: 120%, y: 80%) + {
      line((0, 0, 0.5), (0.5, 0, 0), stroke: black)
      anchor("A", (0, 0, 0.5))
      anchor("B", (0.5, 0, 0))
      六面体
    })
    circle("S.O", fill: black, radius: 0.05 / 4)
    content((rel: (-0.08, 0.04, 0), to: "S.O"), [O])
    circle("T.A", fill: black, radius: 0.05 / 4)
    content((rel: (0.02, -0.08, 0), to: "T.A"), [A])
    circle("T.B", fill: black, radius: 0.05 / 4)
    content((rel: (0, 0.1, 0), to: "T.B"), [B])
  }))
  ```,
  scope: (六面体: 六面体),
)
