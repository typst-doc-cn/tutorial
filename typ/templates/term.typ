
#let term-state = state("term", (:))
#let reset-term-state = term-state.update(it => (:))

#let _term(term-list, term, en: none) = (
  context {
    let s = term-state.get()
    if term in s {
      [「#term-list.at(term)#("」")]
    } else {
      let en-term = term
      if en != none {
        en-term = en
      }
      [「#term-list.at(term)」（#en-term#("）")]
    }
  }
    + term-state.update(it => {
      it.insert(term, "")
      it
    })
)
