#import "/src/book.typ"
#import "/typ/templates/page.typ": is-web-target, main-color
#import "/typ/embedded-typst/lib.typ": default-cjk-fonts, default-fonts, svg-doc
#import "../mod.typ": (
  code as _code, exec-code as _exec-code, exercise, mark, pro-tip, ref-bookmark, ref-cons-signature, ref-func-signature,
  ref-method-signature, refs, term, todo-box, todo-color, typst-func,
)

#let eval-local(it, scope, res) = if res != none {
  res
} else {
  eval(it.text, mode: "markup", scope: scope)
}
#let exec-code(it, scope: (:), res: none, ..args) = _exec-code(it, res: eval-local(it, scope, res), ..args)
/// - it (content): the body of code.
#let code(it, scope: (:), res: none, ..args) = _code(it, res: eval-local(it, scope, res), ..args)

#let frames(code, cjk-fonts: false, code-as: none, prelude: none) = {
  if code-as != none {
    code-as
  } else {
    code
  }

  if prelude != none {
    code-as = if code-as == none {
      code
    }
    code = prelude.text + "\n" + code.text
  }

  let fonts = if cjk-fonts {
    (..default-cjk-fonts(), ..default-fonts())
  }

  grid(columns: (1fr, 1fr), ..svg-doc(code, fonts: fonts).pages.map(data => image(bytes(data))).map(rect))
}
#let frames-cjk = frames.with(cjk-fonts: true)
