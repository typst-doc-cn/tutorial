#import "@preview/fletcher:0.4.0" as fletcher: node, edge
#import "/typ/templates/page.typ": main-color, is-light-theme

#let figure-typst-arch(
  stroke-color: main-color,
  light-theme: is-light-theme
) = {
  let node = node.with(stroke: main-color + 0.5pt)
  let xd = align.with(center)

  fletcher.diagram(
    node-outset: 2pt,
    axes: (ltr, btt),

    node((0, 0), xd[文件解析\ （Parsing）]),
    node((1.5, 0), xd[内容评估\ （Evaluation）]),
    node((3, 0), xd[内容排版\ （Typesetting）]),
    node((3, -1), xd[结构导出\ （Exporting）]),

    edge((0, 0), (1.5, 0), "..}>", bend: 25deg),
    edge((1.5, 0), (0, 0), xd[`import`或\ `include`], "..}>", bend: 25deg),
    edge((1.5, 0), (3, 0), "..}>", bend: 25deg),
    edge((3, 0), (1.5, 0),  xd[`styled`等], "..}>", bend: 25deg),
    edge((3, 0), (3, -1), "..}>", bend: 25deg),
  )
}
