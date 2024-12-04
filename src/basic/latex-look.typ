#let latex-look(content) = {
  // #set page(margin: 1.75in)
  set par(
    leading: 0.55em,
    first-line-indent: 0em,
    justify: true,
  )
  set text(font: "New Computer Modern")
  show raw: set text(font: "New Computer Modern Mono")
  show par: set block(spacing: 0.55em)
  show heading: set block(
    above: 1.4em,
    below: 1em,
  )

  content
}
