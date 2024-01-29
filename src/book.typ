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
    // + 常用函数表
    - #chapter(none)[参考：常用函数表]
    // + 数学符号表
    - #chapter(none)[参考：数学符号表]
    - #chapter("basic/scripting-base.typ")[基本字面量、变量和简单函数]
    // array, dict, arguments
    // if c { x } else { y }
    // loop
    // let f = (..args) => expression
    // let f(..args) = expression
    // calc.*
    - #chapter(none)[参考：内置计算库]
    - #chapter("basic/scripting-complex.typ")[复合字面量、控制流和复杂函数]
    // scope
    // include
    // mutable variables in scope
    // show: rule
    // set rule if c
    // scope about import
    // scope about include
    // str, number, etc.
    - #chapter(none)[参考：基本类型的方法]
    // read, json, etc.
    - #chapter(none)[参考：数据加载]
    = 进阶教程
    - #chapter("basic/content-scope-and-style.typ")[作用域、内容与样式]
    // selector, query
    // show.where
    // state
    // CLI: typst query
    // color, gradient, pattern
    - #chapter(none)[参考：颜色、渐变填充与模式填充]
    - #chapter(none)[参考：box、block、可视元素]
    - #chapter("basic/content-stateful.typ")[文档状态的维护与查询]
    // CLI: typst compile --root
    // local package
    // local module
    // import file/module
    // @preview pacakges
    - #chapter(none)[参考：正则匹配]
    - #chapter(none)[参考：元数据（metadata）]
    - #chapter("basic/scripting-modules.typ")[脚本：多文件文档、模块与外部库]
    - #chapter(none)[参考：本地文件管理]
    - #chapter("basic/content-layout.typ")[控制页面结构]
    - #chapter(none)[参考：胶水函数、空间变换函数]
    - #chapter(none)[参考：布局函数与示例]
    - #chapter("basic/writing-intermediate.typ")[编写一篇进阶文档]
    = 专题
    - #chapter("topics/writing-chinese.typ")[编写一篇中文文档]
    = 功能用例
    = 图表
    - #chapter("misc/solid-geometry.typ")[立体几何]
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
