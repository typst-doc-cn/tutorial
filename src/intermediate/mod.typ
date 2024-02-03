#import "/src/book.typ"
#import "/typ/templates/page.typ"
#import "../mod.typ": code as _code, exec-code as _exec-code
#import "/typ/embedded-typst/lib.typ": svg-doc, default-fonts, default-cjk-fonts

#let refs = {
  let cl = book.cross-link;
  (
    writing: cl.with("/basic/writing.typ"),
    scriping-base: cl.with("/basic/scripting-base.typ"),
    scriping-complex: cl.with("/basic/scripting-complex.typ"),
  )
}

#let eval-local(it, scope, res) = if res != none {
  res
} else {
  eval(it.text, mode: "markup", scope: scope)
}
#let exec-code(it, scope: (:), res: none, ..args) = _exec-code(
  it, res: eval-local(it, scope, res),  ..args)
#let code(it, scope: (:), res: none, ..args) = _code(
  it, res: eval-local(it, scope, res), ..args)

#let frames(code, cjk-fonts: false, code-as: none) = {
  if code-as != none {
    code-as
  } else {
    code
  }

  let fonts = if cjk-fonts {
    (..default-cjk-fonts(), ..default-fonts())
  }

  grid(columns: (1fr, 1fr), ..svg-doc(code, fonts: fonts).pages.map(data => image.decode(data)).map(rect))
}
#let frames = frames.with(cjk-fonts: true)

#let typst-func(it) = [
  #raw(it + "()", lang: "typc") <typst-raw-func>
]
