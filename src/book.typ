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
    - #chapter("basic/scripting.typ")[脚本入门]
    - #chapter("basic/copy-and-paste.typ")[库与模板]
    - #chapter("basic/chinese-faq.typ")[中文用户FAQ]
  ]
)

#build-meta(
  dest-dir: "../dist",
)

#get-book-meta()

// re-export page template
#import "/typ/templates/page.typ": project, heading-reference
#let book-page = project
#let cross-link = cross-link
#let heading-reference = heading-reference
