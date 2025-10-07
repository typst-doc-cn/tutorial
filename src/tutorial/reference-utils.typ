#import "mod.typ": *
#import "/typ/typst-meta/docs.typ": typst-v11
#import "@preview/cmarker:0.1.0": render as md

#show: book.page.with(title: [参考：函数表（字典序）])

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

#let table-item(c, mp, featured) = {
  let item = mp.at(c)

  (typst-func(c), item.title, ..featured(item))
}

#let table-items(mp, featured) = mp.keys().sorted().map(it => table-item(it, mp, featured)).flatten()

#let featured-func(item) = {
  return (md(item.body.content.oneliner),)
}

#let featured-scope-item(item) = {
  return (md(item.oneliner),)
}

== 分类：函数

#table(
  columns: (1fr, 1fr, 2fr),
  [函数], [名称], [描述],
  ..table-items(typst-v11.funcs, featured-func),
)

== 分类：方法

#table(
  columns: (1fr, 1fr, 2fr),
  [方法], [名称], [描述],
  ..table-items(typst-v11.scoped-items, featured-scope-item),
)

#if false [
  == `plain-text`，以及递归函数

  如果我们想要实现一个函数`plain-text`，它将一段文本转换为字符串。它便可以在树上递归遍历：

  ```typ
  #let plain-text(it) = if it.has("text") {
    it.text
  } else if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else { ... }
  ```

  所谓递归是一种特殊的函数实现技巧：
  - 递归总有一个不调用其自身的分支，称其为递归基。这里递归基就是返回`it.text`的分支。
  - 函数体中包含它自身的函数调用。例如，`plain-text(it.child)`便再度调用了自身。

  这个函数充分利用了内容类型的特性实现了遍历。首先它使用了`has`函数检查内容的成员。

  如果一个内容有孩子，那么对其每个孩子都继续调用`plain-text`函数并组合在一起：

  ```typ
  #if it.has("children") { ("", ..it.children.map(plain-text)).join() }
  #if it.has("child") { plain-text(it.child) }
  ```

  限于篇幅，我们没有提供`plain-text`的完整实现，你可以试着在课后完成。

  == 鸭子类型

  这里值得注意的是，`it.text`具有多态行为。即便没有继承，这里通过一定动态特性，允许我们同时访问「代码片段」的`text`和「文本」的text。例如：

  #code(```typ
  #let plain-mini(it) = if it.has("text") { it.text }
  #repr(plain-mini(`代码片段中的text`)) \
  #repr(plain-mini([文本中的text]))
  ```)

  这也便是我们在「内容类型」小节所述的鸭子类型特性。如果「内容」长得像文本（鸭子），那么它就是文本。
]
