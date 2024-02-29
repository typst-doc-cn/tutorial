#import "mod.typ": *
#import "/typ/typst-meta/docs.typ": typst-v11
#import "@preview/cmarker:0.1.0": render as md

#show: book.page.with(title: [参考：函数表（字典序）])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, link("todo", name)), 
  it,
  align(horizon, {
    set heading(bookmarked: false, outlined: false)
    eval(it.text, mode: "markup", scope: scope)
  }),
)

#let table-item(c, mp, featured) = {
  let item = mp.at(c)

  (typst-func(c), item.title, ..featured(item))
}

#let table-items(mp, featured) = mp.keys().sorted().map(
  it => table-item(it, mp, featured)).flatten()

#let featured-func(item) = {
  return (md(item.body.content.oneliner), )
}

#let featured-scope-item(item) = {
  return (md(item.oneliner), )
}

== 分类：函数

#table(
  columns: (1fr, 1fr, 2fr),
  [函数], [名称], [描述],
  ..table-items(typst-v11.funcs, featured-func)
)

== 分类：方法

#table(
  columns: (1fr, 1fr, 2fr),
  [方法], [名称], [描述],
  ..table-items(typst-v11.scoped-items, featured-scope-item)
)
