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
    // basic content grammar
    - #chapter("basic/writing.typ")[编写一篇基本文档]
    // integer, float, strings
    // let x = expression
    // let f(x) = expression
    - #chapter("basic/scripting-base.typ")[基本字面量、变量和简单函数]
    // array, dict, arguments
    // if c { x } else { y }
    // loop
    // let f = (..args) => expression
    // let f(..args) = expression
    - #chapter("basic/scripting-complex.typ")[复合字面量、控制流和复杂函数]
    // scope
    // include
    // mutable variables in scope
    // show: rule
    // set rule if c
    // scope about import
    // scope about include
    - #chapter("basic/scripting-scope.typ")[作用域、内容与样式]
    // selector, query
    // show.where
    // state
    // CLI: typst query
    - #chapter("basic/stateful-content.typ")[文档状态的维护与查询]
    // CLI: typst compile --root
    // local package
    // local module
    // import file/module
    // @preview pacakges
    - #chapter("basic/scripting-modules.typ")[脚本：多文件文档、模块与外部库]
    - #chapter("basic/layout.typ")[控制页面结构]
    - #chapter("basic/chinese-writing.typ")[编写一篇中文文档]
    = 专题
    = 功能用例
    = 图表
    = 模板
  ]
)

#build-meta(
  dest-dir: "../dist",
)

// #get-book-meta()

// re-export page template
#import "/typ/templates/page.typ": project, heading-reference
#let page = project
#let cross-link = cross-link
#let heading-reference = heading-reference
