
#let curr-heading = state("curr-heading", ())

#set text(size: 8pt)

#let first-heading = state("first-heading", (:))
#let last-heading = state("last-heading", (:))

#let find-headings(headings, page-num) = if page-num > 0 {
  headings.at(str(page-num), default: find-headings(headings, page-num - 1))
}

#let get-heading-at-page() = {
  let first-headings = first-heading.final()
  let last-headings = last-heading.at(here())
  let page-num = here().page()

  first-headings.at(str(page-num), default: find-headings(last-headings, page-num))
}

#let update-heading-at-page(h) = context {
  let k = str(here().page())
  last-heading.update(it => {
    it.insert(k, h)
    it
  })
  first-heading.update(it => {
    if k not in it {
      it.insert(k, h)
    }
    it
  })
}

#let set-heading(content) = {
  show heading.where(level: 2): it => {
    it
    update-heading-at-page(it.body)
  }
  show heading.where(level: 3): it => {
    show regex("[\p{hani}\s]+"): underline
    it
  }
  show heading: it => {
    show regex("KiraKira"): box("★", baseline: -20%)
    show regex("FuwaFuwa"): box("✎", baseline: -20%)
    it
  }

  set page(
    header: context {
      set text(size: 5pt)
      emph(get-heading-at-page())
    },
  )

  content
}

#let set-text(content) = {
  show regex("feat|refactor"): emph
  content
}

#show: set-heading
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

