#import "mod.typ": *

#show: book.page.with(title: [参考：语法示例检索表Ⅱ])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, ref(name)),
  it,
  align(
    horizon,
    {
      set heading(bookmarked: false, outlined: false)
      eval(it.text, mode: "markup", scope: scope)
    },
  ),
)

#let ref-table(items) = table(
  columns: (120pt, 6fr, 5fr),
  align(center)[「名称/术语」], align(center)[语法], align(center)[渲染结果],
  ..items.map(args => table-lnk(..args)).flatten()
)

点击下面每行名称都可以跳转到对应章节的对应小节。
