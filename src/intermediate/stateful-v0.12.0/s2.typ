
#let curr-heading = state("curr-heading", ())

#set text(size: 8pt)

#let set-heading(content) = {
  show heading.where(level: 3): it => {
    show regex("[\p{hani}\s]+"): underline
    it
  }
  show heading: it => {
    show regex("KiraKira"): box("★", baseline: -20%)
    show regex("FuwaFuwa"): box("✎", baseline: -20%)
    it
  }

  content
}

#let set-text(content) = {
  show regex("feat|refactor"): emph
  content
}

#show: set-text

#set page(width: 120pt, height: 120pt, margin: (top: 12pt, bottom: 10pt, x: 5pt))

== 雨滴书v0.1.2
=== KiraKira 样式改进
feat: 改进了样式。
=== FuwaFuwa 脚本改进
feat: 改进了脚本。

== 雨滴书v0.1.1
refactor: 移除了LaTeX。

feat: 删除了一个多余的文件夹。

== 雨滴书v0.1.0
feat: 新建了两个文件夹。

