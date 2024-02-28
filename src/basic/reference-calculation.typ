#import "mod.typ": *

#show: book.ref-page.with(title: [参考：数值计算])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, link("todo", name)), 
  it,
  align(horizon, {
    set heading(bookmarked: false, outlined: false)
    eval(it.text, mode: "markup", scope: scope)
  }),
)

// calc.*
