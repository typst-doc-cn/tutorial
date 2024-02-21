#import "/src/book.typ"
#import "/typ/templates/page.typ"

#let refs = {
  let cl = book.cross-link;
  (
    writing: cl.with("/basic/writing.typ"),
    scripting-base: cl.with("/basic/scripting-base.typ"),
    scripting-complex: cl.with("/basic/scripting-complex.typ"),
    scripting-modules: cl.with("/intermediate/scripting-modules.typ"),
    ref-math-symbols: cl.with("/basic/reference-math-symbols.typ"),
    ref-layout: cl.with("/intermediate/reference-layout.typ"),
    ref-length: cl.with("/intermediate/reference-length.typ"),
  )
}

#let exec-code(cc, res: none, scope: (:), eval: eval) = {
  // Don't corrupt normal headings
  set heading(outlined: false)

  rect(width: 100%, inset: 10pt, if res != none {
    res
  } else {
    eval(cc.text, mode: "markup", scope: scope)
  })
}

#let code(cc, show-cc: true, res: none, scope: (:), eval: eval, exec-code: exec-code) = {
  if show-cc {
    cc
  }
  exec-code(cc, res: res, scope: scope, eval: eval)
}
