// This is important for typst-book to produce a responsive layout
// and multiple targets.
#import "@preview/shiroa:0.1.0": get-page-width, target, is-web-target, is-pdf-target, plain-text, templates
#import templates: *
#import "/typ/templates/side-notes.typ": side-attrs

// Metadata
#let page-width = get-page-width()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target()

// Theme (Colors)
#let (
  style: theme-style,
  is-dark: is-dark-theme,
  is-light: is-light-theme,
  main-color: main-color,
  dash-color: dash-color,
  code-extra-colors: code-extra-colors,
) = book-theme-from(toml("theme-style.toml"), xml: it => xml(it))

// Sizes
#let main-size = if is-web-target {
  16pt
} else {
  10.5pt
}
#let heading-sizes = (26pt, 22pt, 14pt, 12pt, main-size)
#let list-indent = 0.5em

// Fonts
#let use-fandol-fonts = false
#let main-font-cn = {
  if is-web-target {
    ("Noto Sans CJK SC",)
  } else if use-fandol-fonts {
    ("FandolSong",)
  }
  ("Source Han Serif SC", "Source Han Serif TC")
}

#let code-font-cn = ("Noto Sans CJK SC",)

#let main-font = if use-fandol-fonts {
  ("New Computer Modern", ..main-font-cn)
} else {
  (
    // "Charter",
    // typst-book's embedded font
    "Linux Libertine",
    ..main-font-cn,
  )
}

#let code-font = (
  "BlexMono Nerd Font Mono",
  // typst-book's embedded font
  "DejaVu Sans Mono",
  ..code-font-cn,
)

// todo: move code theme parser to another lib file
#let code-theme-file = theme-style.at("code-theme")

#let code-extra-colors = if code-theme-file.len() > 0 {
  let data = xml(theme-style.at("code-theme")).first()

  let find-child(elem, tag) = {
    elem.children.find(e => "tag" in e and e.tag == tag)
  }

  let find-kv(elem, key, tag) = {
    let idx = elem.children.position(e => "tag" in e and e.tag == "key" and e.children.first() == key)
    elem.children.slice(idx).find(e => "tag" in e and e.tag == tag)
  }

  let plist-dict = find-child(data, "dict")
  let plist-array = find-child(plist-dict, "array")
  let theme-setting = find-child(plist-array, "dict")
  let theme-setting-items = find-kv(theme-setting, "settings", "dict")
  let background-setting = find-kv(theme-setting-items, "background", "string")
  let foreground-setting = find-kv(theme-setting-items, "foreground", "string")
  (bg: rgb(background-setting.children.first()), fg: rgb(foreground-setting.children.first()))
} else {
  (bg: rgb(239, 241, 243), fg: none)
}

#let make-unique-label(it, disambiguator: 1) = label({
  let k = plain-text(it).trim()
  if disambiguator > 1 {
    k + "_d" + str(disambiguator)
  } else {
    k
  }
})

#let heading-reference(it, d: 1) = make-unique-label(it.body, disambiguator: d)

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "Typst中文教程", authors: (), kind: "page", body) = {
  let is-ref-page = kind == "reference-page"
  let is-page = kind == "page"
  let heading-sizes = (26pt, 22pt, 14pt, 12pt, main-size)

  // set basic document metadata
  set document(
    author: authors,
    title: title,
  ) if not is-pdf-target

  // set web/pdf page properties
  set page(numbering: if is-pdf-target {
    "1"
  })

  // set web/pdf page properties
  set page(
    number-align: center,
    width: page-width,
  )

  // remove margins for web target
  set page(
    margin: (
      // reserved beautiful top margin
      top: 20pt,
      // reserved for our heading style.
      // If you apply a different heading style, you may remove it.
      left: 20pt,
      // Typst is setting the page's bottom to the baseline of the last line of text. So bad :(.
      bottom: 0.5em,
      // remove rest margins.
      rest: 0pt,
    ),
    height: auto,
  ) if is-web-target

  // set text style
  set text(
    font: main-font,
    size: main-size,
    fill: main-color,
    lang: "zh",
    region: "cn",
  )

  let ld = state("label-disambiguator", (:))
  let update-ld(k) = ld.update(it => {
    it.insert(k, it.at(k, default: 0) + 1)
    it
  })
  let get-ld(loc, k) = make-unique-label(k, disambiguator: ld.at(loc).at(k))

  // show regex("[A-Za-z]+"): set text(font: main-font-en)
  let cjk-markers = regex("[“”‘’．，。、？！：；（）｛｝［］〔〕〖〗《》〈〉「」【】『』─—＿·…\u{30FC}]+")
  show cjk-markers: set text(font: main-font-cn)
  show raw: it => {
    show cjk-markers: set text(font: code-font-cn)
    it
  }
  // show regex("[a-zA-Z\s\#\[\]]+"): set text(baseline: -0.05em)
  // show regex("[“”]+"): set text(font: main-font-cn)

  // Set text, spacing for headings
  // Render a hash to hint headings instead of bolding it as well if it's for web.
  show heading: set text(weight: "regular") if is-web-target
  show heading: it => {
    let it = {
      set text(size: heading-sizes.at(it.level))
      if is-web-target {
        heading-hash(it, hash-color: dash-color)
      }
      it
    }

    block(
      spacing: 0.7em * 1.5 * 1.2,
      below: 0.7em * 1.2,
      it,
    )
  }

  // link setting
  show link: set text(fill: dash-color)

  // math setting
  show math.equation: set text(weight: 400)

  // code block setting
  show raw: it => {
    if "block" in it.fields() and it.block {
      rect(
        width: 100%,
        inset: (x: 4pt, y: 5pt),
        radius: 2pt,
        fill: code-extra-colors.at("bg"),
        [
          #set text(font: code-font)
          #set text(fill: code-extra-colors.at("fg")) if code-extra-colors.at("fg") != none
          #set par(justify: false)
          #it
        ],
      )
    } else {
      set text(
        font: code-font,
        baseline: -0.08em,
      )
      it
    }
  }


  show <typst-raw-func>: it => {
    it.lines.at(0).body.children.slice(0, -2).join()
  }


  if title != none {
    if is-web-target {
      [= #title]
    } else {
      v(0.5em)
      align(center, [= #title])
      v(1em)
    }
  }

  // Main body.
  set par(justify: true)

  if is-ref-page {
    let side-space = 4 * main-size
    let side-overflow = 2 * main-size
    let gutter = 1 * main-size
    grid(
      columns: (side-space, 100% - side-space - gutter),
      column-gutter: gutter,
      place(
        dx: -side-overflow,
        block(
          breakable: true,
          width: side-space + side-overflow,
          locate(loc => side-attrs.update(it => {
            it.insert("left", loc.position().x)
            it.insert("width", side-space + side-overflow)
            it.insert("gutter", gutter)
            it
          })),
        ),
      ),
      body,
    )
  } else if is-page {
    locate(loc => side-attrs.update(it => {
      it.insert("left", 0pt)
      it.insert("width", 0pt)
      it.insert("gutter", 0pt)
      it
    }))
    body
  } else {
    body
  }
}

#let part-style = heading
