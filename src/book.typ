#import "/typ/book/lib.typ": *

#show: book

#let book-info = json("/meta.json")

#book-meta(
  title: "Typst Tutorial CN",
  description: "Typst中文教程",
  repository: "https://github.com/typst-doc-cn/tutorial",
  repository-edit: "https://github.com/typst-doc-cn/tutorial/edit/main/github-pages/docs/{path}",
  authors: book-info.contributors,
  language: "zh-cn",
  summary: [
    #prefix-chapter("introduction.typ")[导引]
    = 基本教程
    - #chapter("basic/writing.typ")[编写一篇基本文档]
    - #chapter("basic/scripting-base.typ")[脚本：类型、变量和函数]
    - #chapter("basic/content-and-style.typ")[维护文档内容与样式]
    - #chapter("basic/scripting-scope.typ")[脚本：控制流、作用域和闭包]
    - #chapter("basic/stateful-content.typ")[维护和查询文档状态]
    - #chapter("basic/scripting-modules.typ")[脚本：多文件文档、模块与外部库]
    - #chapter("basic/layout.typ")[控制页面结构]
    - #chapter("basic/chinese-writing.typ")[编写一篇中文文档]
  ]
)

#build-meta(
  dest-dir: "../dist",
)

#get-book-meta()

// re-export page template
#import "/typ/templates/page.typ": project, heading-reference
#let page = project
#let cross-link = cross-link
#let heading-reference = heading-reference
