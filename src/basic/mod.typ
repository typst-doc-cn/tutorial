#import "/src/book.typ"
#import "/typ/templates/page.typ": main-color

#import "../mod.typ": code as _code, exec-code as _exec-code, refs, todo-box, todo-color, pro-tip, typst-func, term, mark, exercise, ref-bookmark, ref-method-signature, ref-func-signature, ref-cons-signature

#let eval-local(it, scope, res) = if res != none {
  res
} else {
  eval(it.text, mode: "markup", scope: scope)
}
#let exec-code(it, scope: (:), res: none, ..args) = _exec-code(it, res: eval-local(it, scope, res), ..args)
#let code(it, scope: (:), res: none, ..args) = _code(it, res: eval-local(it, scope, res), ..args)
