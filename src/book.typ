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
    - #chapter("basic/scripting-base.typ")[基本字面量、变量和简单函数]
    // array, dict, arguments
    // if c { x } else { y }
    // loop
    // let f = (..args) => expression
    // let f(..args) = expression
    // mutable variables in scope
    - #chapter("basic/scripting-complex.typ")[复合字面量、控制流和复杂函数]
    = 基本参考
    // str, number, etc.
    - #chapter(none)[基本类型]
    - #chapter(none)[常用函数表]
    // CLI: typst query
    - #chapter(none)[数据存储与处理]
    // color, gradient, pattern
    - #chapter(none)[颜色、渐变填充与模式填充]
    - #chapter(none)[可视与几何元素]
    - #chapter(none)[语法速查]
    - #chapter(none)[示例速查]
    - #chapter("basic/reference-math-symbols.typ")[常用数学符号]
    // calc.*
    - #chapter(none)[数值计算]
    = 进阶教程
    - #chapter("intermediate/content-scope-and-style.typ")[作用域、内容与样式]
    - #chapter("intermediate/content-stateful.typ")[维护和查询文档状态]
    - #chapter("intermediate/content-stateful-2.typ")[查询文档状态 —— 制作页眉标题法一]
    - #chapter("intermediate/content-stateful-3.typ")[维护文档状态 —— 制作页眉标题法二]
    - #chapter("intermediate/scripting-modules.typ")[模块、外部库与多文件文档]
    - #chapter("intermediate/writing.typ")[编写一篇进阶文档]
    = 进阶参考
    - #chapter("intermediate/reference-length.typ")[长度单位]
    - #chapter("intermediate/reference-layout.typ")[布局函数]
    - #chapter(none)[示例速查Ⅱ]
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
