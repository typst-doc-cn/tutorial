#import "/src/book.typ"
#import "/typ/templates/page.typ"
#import "../mod.typ": code as _code, exec-code as _exec-code

#let refs = {
  let cl = book.cross-link;
  (
    writing: cl.with("/basic/writing.typ"),
    scriping-base: cl.with("/basic/scripting-base.typ"),
    scriping-complex: cl.with("/basic/scripting-complex.typ"),
    
    reference-math-symbols: cl.with("/basic/reference-math-symbols.typ"),
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
