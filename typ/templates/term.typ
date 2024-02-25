
#let term-state = state("term", (:))
#let reset-term-state = term-state.update(it => (:))

#let _term(term-list, term, postfix: none, en: none) = locate(loc => {
  let s = term-state.at(loc)
  if term in s {
    [「#term-list.at(term)#("」"+postfix)]
  } else {
    let en-term = term
    if en != none {
      en-term = en
    }
    [「#term-list.at(term)」（#en-term#("）"+postfix)]
  }
}) + term-state.update(it => {
  it.insert(term, "")
  it
})
