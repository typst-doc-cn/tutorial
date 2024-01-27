#import "/src/book.typ"
#import "/typ/templates/page.typ"

#let exec-code(cc, res: none) = {
  rect(width: 100%, inset: 10pt, if res != none {
    res
  } else {
    eval(cc.text, mode: "markup")
  })
}

#let code(cc, show-cc: true, res: none) = {
  if show-cc {
    cc
  }
  exec-code(cc, res: res)
}
