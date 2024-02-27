#import "mod.typ": *

#show: book.ref-page.with(title: [参考：颜色、渐变填充与模式填充])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, link("todo", name)), 
  it,
  align(horizon, {
    set heading(bookmarked: false, outlined: false)
    eval(it.text, mode: "markup", scope: scope)
  }),
)
