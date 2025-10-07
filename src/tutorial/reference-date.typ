#import "mod.typ": *

#show: book.ref-page.with(title: [参考：时间类型])

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

== 日期

日期表示时间长河中的一个具体的时间戳。#ref-bookmark[`datetime`]

#code(```typ
一个值 #datetime(year: 2023, month: 4, day: 19).display() 偷偷混入了我们内容之中。
```)

== 时间间隔

时间间隔表示两个时间戳之间的时间差。#ref-bookmark[`duration`]

#code(```typ
一个值 #duration(days: 3, hours: 10).seconds()s 偷偷混入了我们内容之中。
```)

== typst-pdf时间戳

```typ
set document(date: auto)
```
