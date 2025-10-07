#import "@preview/cetz:0.3.4"
#import "/typ/templates/page.typ": main-color, is-light-theme

#let std-scale = scale

#let figure-time-travel(
  stroke-color: main-color,
  light-theme: is-light-theme,
) = {
  import cetz.draw: *

  let stroke-factor = if light-theme {
    1
  } else {
    0.8
  }

  let line-width = 0.5pt * stroke-factor
  let rect = rect.with(stroke: line-width + stroke-color)
  let circle = circle.with(stroke: line-width + stroke-color)
  let line = line.with(stroke: line-width + stroke-color)
  let light-line = line.with(stroke: (0.3pt * stroke-factor) + stroke-color)
  let exlight-line = line.with(stroke: (0.2pt * stroke-factor) + stroke-color)

  let preview-img-fill = if light-theme {
    green.lighten(80%)
  } else {
    green.darken(20%)
  }

  let preview-img-fill2 = if light-theme {
    green.lighten(80%)
  } else {
    green.darken(20%)
  }

  let state-background-fill = rgb("#2983bb80")
  let preview-background-fill = rgb("#baccd980")

  let preview-content0 = {
    translate((0.05, 1 - 0.2))
    // title
    light-line((0.15, 0), (0.55, 0))
    translate((0, -0.08))
    exlight-line((0.05, 0), (0.7, 0))
    translate((0, -0.03))
    exlight-line((0.00, 0), (0.7, 0))
    translate((0, -0.03))
    exlight-line((0.00, 0), (0.7, 0))
    translate((0, -0.03))
    exlight-line((0.00, 0), (0.4, 0))
  }

  let preview-content1 = {
    translate((0, -0.06))
    rect((0.05, 0), (0.65, -0.24), stroke: 0pt, fill: preview-img-fill, name: "picture")
    content("picture", std-scale(20%)[$lambda x = integral.double x dif x$])
    translate((0, -0.24))
  }
  let doc-state(prev-name, name, checkpoint: 0) = {
    let arrow-line(pos) = {
      line((rel: (-0.01, 0.025), to: pos), pos)
      line((rel: (0.01, 0.025), to: pos), pos)
    }

    rect((0, 0), (0.2, 1), stroke: 0pt, fill: state-background-fill)

    if checkpoint == 0 {
      line(prev-name + "-S2", name + "-S1", stroke: line-width + red)
    }
    if checkpoint == 1 {
      line(prev-name + "-S3", name + "-S2", stroke: line-width + red)
    }
    if checkpoint == 2 {
      line(prev-name + "-S4", name + "-S3", stroke: line-width + red)
    }

    circle(name + "-S1", fill: blue, stroke: 0pt, radius: 0.01)
    content((rel: (-0.04, 0), to: name + "-S1"), std-scale(40%, [S1]))
    if checkpoint <= 0 {
      return
    }
    circle(name + "-S2", fill: blue, stroke: 0pt, radius: 0.01)
    content((rel: (-0.04, -0.03), to: name + "-S2"), std-scale(40%, [S2]))
    line(name + "-S1", name + "-S2")
    arrow-line(name + "-S2")
    if checkpoint <= 1 {
      return
    }
    circle(name + "-S3", fill: blue, stroke: 0pt, radius: 0.01)
    content((rel: (-0.04, -0.02), to: name + "-S3"), std-scale(40%, [S3]))
    line(name + "-S2", name + "-S3")
    arrow-line(name + "-S3")

    if checkpoint == 2 {
      circle(name + "-R1", fill: blue, stroke: 0pt, radius: 0.01)
      arc-through(name + "-R1", (rel: (0.02, -0.03), to: name + "-R1"), name + "-S3", stroke: line-width + blue)
      line((rel: (50deg, 0.02), to: name + "-S3"), name + "-S3", stroke: line-width + blue)
      line((rel: (10deg, 0.02), to: name + "-S3"), name + "-S3", stroke: line-width + blue)
    }

    if checkpoint <= 2 {
      return
    }


    circle(name + "-S4", fill: blue, stroke: 0pt, radius: 0.01)
    content((rel: (-0.04, -0.01), to: name + "-S4"), std-scale(40%, [S4]))
    line(name + "-S3", name + "-S4")
    if checkpoint == 3 {
      circle(name + "-R2", fill: blue, stroke: 0pt, radius: 0.01)
    }
    arrow-line(name + "-S4")


    if checkpoint == 3 {
      arc-through(name + "-R2", (rel: (0.05, 0.33, 0), to: name + "-R2"), name + "-S2", stroke: line-width + blue)
      line((rel: (-110deg, 0.02), to: name + "-S2"), name + "-S2", stroke: line-width + blue)
      line((rel: (-20deg, 0.02), to: name + "-S2"), name + "-S2", stroke: line-width + blue)
    }
  }
  let doc(name, checkpoint: 0) = {
    group(
      name: name,
      {
        // line((0, 0), (0.707, 0))
        // line((0.707, 0), (0.707, 1))
        // line((0.707, 1), (0, 1))
        // line((0, 0), (0, 1))
        rect((0, 0), (0.707, 1), stroke: 0pt, fill: preview-background-fill)

        let margin = 0.05

        translate((margin, 1 - 0.1))
        scale(x: (0.707 - margin * 2))
        let lm = (-margin) / (0.707 - margin * 2)

        anchor("title", (0.5, 0))
        content("title", std-scale(30%)[关于吃睡玩自动机的形式化研究])
        // content("title", std-scale(30%)[#align(center, [A formal study on eat-sleep-\ play automating cats])])

        translate((0, -0.07))
        light-line((0.1, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))

        translate((0, -0.025))
        if checkpoint <= 0 {
          light-line((0.05, 0), (0.45, 0))
          anchor("P", (0.45, 0))
          anchor("Q", (lm, 0))
          return
        }

        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.75, 0))

        translate((0, -0.03))
        anchor("P", (0.59, -0.072))
        anchor("Q", (lm, -0.072))
        rect((0.1, 0), (0.9, -0.10), stroke: 0pt, fill: preview-img-fill, name: "picture")
        content("picture", std-scale(30%)[$lambda x = integral.double x dif x$])
        if checkpoint <= 1 {
          return
        }

        translate((0, -0.03 - 0.10))

        light-line((0.1, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.85, 0))

        translate((0, -0.03))

        light-line((0.1, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        if checkpoint == 2 {
          anchor("R", (0.75, 0))
          anchor("R2", (lm, 0))
        }
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        anchor("P", (0.85, 0))
        anchor("Q", (lm, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.35, 0))

        if checkpoint <= 2 {
          return
        }

        translate((0, -0.03))

        light-line((0.1, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.35, 0))

        translate((0, -0.03))

        light-line((0.1, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        if checkpoint == 3 {
          anchor("R", (0.75, 0))
          anchor("R2", (lm, 0))
        }
        translate((0, -0.025))
        light-line((0.05, 0), (0.95, 0))
        anchor("P", (0.6, 0))
        anchor("Q", (lm, 0))
        translate((0, -0.025))
        light-line((0.05, 0), (0.35, 0))
      },
    )
  }

  cetz.canvas({
    // 导入cetz的draw方言
    import cetz.draw: *
    set-viewport((0, 0, 0), (4, 4, -4), bounds: (1, 1, 1))

    group(
      name: "doc",
      {
        let x = 0.25
        let z = 0.22
        translate((x, 0, -z))
        translate((x, 0, -z))
        translate((x, 0, -z))
        doc("D1", checkpoint: 3)
        circle("D1.P", fill: red, stroke: 0pt, radius: 0.01)
        translate((-x, 0, z))
        doc("D2", checkpoint: 2)
        circle("D2.P", fill: red, stroke: 0pt, radius: 0.01)
        translate((-x, 0, z))
        doc("D3", checkpoint: 1)
        circle("D3.P", fill: red, stroke: 0pt, radius: 0.01)
        translate((-x, 0, z))
        doc("D4", checkpoint: 0)
        circle("D4.P", fill: red, stroke: 0pt, radius: 0.01)

        circle("D2.R", fill: blue, stroke: 0pt, radius: 0.01)
        circle("D1.R", fill: blue, stroke: 0pt, radius: 0.01)

        let blue-light-line = line.with(stroke: (0.3pt * stroke-factor) + blue)
        let red-light-line = line.with(stroke: (0.3pt * stroke-factor) + red)
        red-light-line("D4.P", "D3.P")
        red-light-line("D3.P", "D2.P")
        red-light-line("D2.P", "D1.P")

        blue-light-line("D2.R", "D2.P")
        blue-light-line("D1.R", "D3.P")

        let round-z-axis = ((x, y, z)) => (x, y, calc.round(z, digits: 10))
        anchor("S1", (round-z-axis, (rel: (-x * 0, 0, z * 0), to: "D4.Q")))
        anchor("S2", (round-z-axis, (rel: (-x * 1, 0, z * 1), to: "D3.Q")))
        anchor("S3", (round-z-axis, (rel: (-x * 2, 0, z * 2), to: "D2.Q")))
        anchor("S4", (round-z-axis, (rel: (-x * 3, 0, z * 3), to: "D1.Q")))
        anchor("R1", (round-z-axis, (rel: (-x * 2, 0, z * 2), to: "D2.R2")))
        anchor("R2", (round-z-axis, (rel: (-x * 3, 0, z * 3), to: "D1.R2")))
      },
    )

    let anchor-s(prefix, p) = {
      anchor(prefix + "-S1", (rel: p, to: "doc.S1"))
      anchor(prefix + "-S2", (rel: p, to: "doc.S2"))
      anchor(prefix + "-S3", (rel: p, to: "doc.S3"))
      anchor(prefix + "-S4", (rel: p, to: "doc.S4"))
      anchor(prefix + "-R1", (rel: p, to: "doc.R1"))
      anchor(prefix + "-R2", (rel: p, to: "doc.R2"))
    }

    translate((-1, 0, 0))

    group({
      let x = 0.12
      let z = 0.22
      translate((x, 0, -z))
      translate((x, 0, -z))
      translate((x, 0, -z))
      anchor-s("T1", (-1 + 0.2 / 2 + x * 3, 0, -z * 3))
      doc-state("T0", "T1", checkpoint: 3)
      translate((-x, 0, z))
      anchor-s("T2", (-1 + 0.2 / 2 + x * 2, 0, -z * 2))
      doc-state("T1", "T2", checkpoint: 2)
      translate((-x, 0, z))
      anchor-s("T3", (-1 + 0.2 / 2 + x * 1, 0, -z * 1))
      doc-state("T2", "T3", checkpoint: 1)
      translate((-x, 0, z))
      anchor-s("T4", (-1 + 0.2 / 2 + x * 0, 0, -z * 0))
      doc-state("T3", "T4", checkpoint: 0)
    })

    translate((-0.7, 0, 0))
    line((0, 0), (0, 1), stroke: 0pt, fill: none)
  })
}
