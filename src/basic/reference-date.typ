#import "mod.typ": *

#show: book.ref-page.with(title: [参考：时间类型])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, link("todo", name)), 
  it,
  align(horizon, {
    set heading(bookmarked: false, outlined: false)
    eval(it.text, mode: "markup", scope: scope)
  }),
)

+ 「日期类型」（`datetime`）

  #code(```typ
  一个值 #datetime(year: 2023, month: 4, day: 19).display() 偷偷混入了我们内容之中。
  ```)

+ 「时间长度类型」（`duration`）

  #code(```typ
  一个值 #duration(days: 3, hours: 10).seconds()s 偷偷混入了我们内容之中。
  ```)
