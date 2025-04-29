
#import "lib.typ": *

#let doc = svg-doc(```
#set page(header: [
  #set text(size: 20pt)
  The book compiled by embedded typst
])
#set text(size: 30pt)

#v(1em)
= The first section <embedded-typst>
#lorem(120)
= The second section
#lorem(120)
```)

#let query-result = doc.header.at(0)

The selected element is:
#query-result.func#[[#[#query-result.body.text]]]

#grid(columns: (1fr, 1fr), column-gutter: 0.6em, row-gutter: 1em, ..doc.pages.map(data => image(bytes(data))).map(rect))
