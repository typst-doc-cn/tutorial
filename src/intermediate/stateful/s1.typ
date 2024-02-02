
#let curr-heading = state("curr-heading", ())

#set text(size: 8pt)

#let last-or(arr) = if arr.len() > 0 {
  arr.last()
}

#let get-heading-at-page(loc) = {
  let headings = curr-heading.final(loc)
  let page-num = loc.page() - 1

  headings.at(page-num, default:last-or(headings))
}

#let update-heading-at-page(it) = {
  locate(loc =>
    curr-heading.update(headings => {
      let page-num = loc.page() - 1

      if page-num < headings.len() {
        return headings
      }
      
      let t = last-or(headings)
      headings
      calc.max(0, page-num - 1 - headings.len()) * (t, )
      (it.body, )
    })
  )
}

#let set-heading(content) = {
  show heading.where(level: 2): it => {
    update-heading-at-page(it)
    it
  }
  show heading.where(level: 3): it => {
    show regex("[\p{hani}\s]+"): underline
    it
  }
  show heading: it => {
    show regex("KiraKira"): box("★", baseline: -20%)
    show regex("FuwaFuwa"): box(text("🪄", size: 0.5em), baseline: -50%)
    it
  }

  set page(header: locate(loc => {
    set text(size: 5pt);
    emph(get-heading-at-page(loc))
  }))

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

