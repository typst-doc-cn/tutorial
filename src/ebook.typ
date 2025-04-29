#import "@preview/shiroa:0.2.3": *
#import "/typ/templates/ebook.typ"

#show: ebook.project.with(
  title: "typst-tutorial-cn",
  display-title: "Typst中文教程",
  spec: "book.typ",
  // set a resolver for inclusion
  styles: (
    inc: it => include it,
  ),
)
