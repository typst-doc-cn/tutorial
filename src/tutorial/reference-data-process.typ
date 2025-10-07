#import "mod.typ": *

#show: book.ref-page.with(title: [参考：数据读写与数据处理])

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

== read

== 数据格式

== 字节数组

== image.decode

== 字符串Unicode

== 正则匹配

== wasm插件

== metadata

== typst query
