#import "mod.typ": *

#show: book.ref-page.with(title: [参考：语法检索表])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, link("todo", name)), 
  it,
  align(horizon, {
    set heading(bookmarked: false, outlined: false)
    eval(it.text, mode: "markup", scope: scope)
  }),
)

点击下面每行名称都可以跳转到对应章节的对应小节：

#table(
  columns: (1fr, 1fr, 1fr),
  align(center)[「名称/术语」], align(center)[语法], align(center)[渲染结果],
  ..(
    ([段落], refs.writing-markup, ```typ
    writing-markup
    ```),
    ([标题], refs.writing-markup, ```typ
    = Heading
    ```),
    ([二级标题], refs.writing-markup, ```typ
    == Heading
    ```),
    ([着重标记], refs.writing-markup, ```typ
    *Strong*
    ```),
    ([强调标记], refs.writing-markup, ```typ
    _emphasis_
    ```),
    ([有序列表], refs.writing-markup, ```typ
    + Item 1
    + Item 2
    ```),
    ([无序列表], refs.writing-markup, ```typ
    - Item 1
    - Item 2
    ```),
    ([短代码片段], refs.writing-markup, ````typ
    `code`
    ````),
    ([长代码片段], refs.writing-markup, ````typ
    ```code```
    ````),
    ([代码块], refs.writing-markup, ````typ
    ```typ
    = Heading
    ```
    ````),
  ).map(args => table-lnk(..args)).flatten()
)
