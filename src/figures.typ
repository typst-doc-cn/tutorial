#import "@preview/fletcher:0.5.7" as fletcher: node, edge
#import "/typ/templates/page.typ": main-color, is-light-theme, page-width
#import "mod.typ": typst-func

#let figure-typst-arch(
  stroke-color: main-color,
  light-theme: is-light-theme,
) = {
  let node = node.with(stroke: main-color + 0.5pt)
  let xd = align.with(center)

  fletcher.diagram(
    node-outset: 2pt,
    axes: (ltr, btt),
    // nodes
    node((0, 0), xd[文件解析\ （Parsing）]),
    node((1.5, 0), xd[表达式求值\ （Evaluation）]),
    node((3, 0), xd[内容排版\ （Typesetting）]),
    node((3, -1), xd[结构导出\ （Exporting）]),
    // edges
    edge((0, 0), (1.5, 0), "..}>", bend: 25deg),
    edge((1.5, 0), (0, 0), xd[`import`或\ `include`], "..}>", bend: 25deg),
    edge((1.5, 0), (3, 0), "..}>", bend: 25deg),
    edge((3, 0), (1.5, 0), xd[`styled`等], "..}>", bend: 25deg),
    edge((3, 0), (3, -1), "..}>", bend: 25deg),
  )
}

#let figure-content-decoration(
  stroke-color: main-color,
  light-theme: is-light-theme,
  width: page-width,
) = {
  // let node = node.with(stroke: main-color + 0.5pt)
  let node-text = align.with(center)

  // todo: 消除重复
  if width < 500pt {
    let node-rect-text(content) = rect(node-text(content), width: 125pt)
    fletcher.diagram(
      node-outset: 2pt,
      axes: (ltr, btt),
      // nodes
      node((0, 0), node-rect-text[```typ 左#[一段文本]右```]),
      node((0, -1.5), node-rect-text(```typc text(blue)```)),
      node((0, -3), node-rect-text([左] + text(blue)[一段文本] + [右])),

      node((0, -0.5 + 0), node-text[选中内容]),
      node((0, -0.5 + -1.5), node-text[对内容块应用#typst-func("text")函数]),
      node((0, -0.5 + -3), node-text[最终效果]),

      // edges
      edge((0, -0.5 + 0), (0, -1.5), "..}>"),
      edge((0, -0.5 + -1.5), (0, -3), "..}>"),
    )
  } else {
    fletcher.diagram(
      node-outset: 2pt,
      axes: (ltr, btt),
      // nodes
      node((0, 0), node-text[```typ 左#[一段文本]右```]),
      node((1.5, 0), node-text(```typc text(blue)```)),
      node((3, 0), node-text([左] + text(blue)[一段文本] + [右])),
      node((0, -0.5), node-text[选中内容]),
      node((1.5, -0.5), node-text[对内容块应用#typst-func("text")函数]),
      node((3, -0.5), node-text[最终效果]),
      // edges
      edge((0, 0), (1.5, 0), "..}>"),
      edge((1.5, 0), (3, 0), "..}>"),
    )
  }
}
