
#set text(size: 8pt)

#let calc-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.location().page()))
  let first-headings = (none,) * max-page-num
  let last-headings = (none,) * max-page-num

  for h in headings {
    if first-headings.at(h.location().page() - 1) == none {
      first-headings.at(h.location().page() - 1) = h
    }
    last-headings.at(h.location().page() - 1) = h
  }

  let res-headings = (none,) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1),
        default: none,
      )
      last-headings.at(i)
    }
  }

  (
    res-headings,
    if max-page-num > 0 {
      last-headings.at(-1)
    },
  )
}

#let get-heading-at-page() = {
  let (headings, last-heading) = calc-headings(query(heading.where(level: 2)))
  headings.at(here().page() - 1, default: last-heading)
}

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
