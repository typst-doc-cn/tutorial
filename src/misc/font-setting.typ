#import "mod.typ": *

#show: book.page.with(title: [字体设置])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, link("todo", name)),
  it,
  align(
    horizon,
    {
      set heading(bookmarked: false, outlined: false)
      eval(it.text, mode: "markup", scope: scope)
    },
  ),
)
