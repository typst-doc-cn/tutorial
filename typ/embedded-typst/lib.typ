
#let typst = plugin("/assets/artifacts/embedded_typst.wasm")

#let separator = "\n\n\n\n\n\n\n\n"

#let svg-doc(code) = {
  let code = bytes(code.text)
  let (header, ..pages) = str(typst.svg(code)).split(separator)
  (header: json.decode(header), pages: pages)
}


#grid(columns: (1fr, 1fr), ..svg-doc(```
#set page(header: [
  #set text(size: 5pt)
  The book compiled by embedded typst
])
#set page(width: 120pt, height: 120pt, margin: (y: 10pt, x: 5pt))
#set text(size: 10pt)
#page[
  #v(1em)
  Hello World! The first page.
]
#page[
  #v(1em)
  Hello World! The second page.
]
```).pages.map(data => image.decode(data)).map(rect))
