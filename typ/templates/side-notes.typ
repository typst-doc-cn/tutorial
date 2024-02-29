
#let side-attrs = state("tuturial-side-note-attrs", (:))

#let side-note(dy: -0.65em, content) = locate(loc => {
  let attr = side-attrs.at(loc)
  // side-notes.update(it => {
  //   let p = str(loc.page())
  //   let arr = it.at(p, default: ())
  //   arr.push((loc.position().y, content))
  //   it.insert(p, arr)
  //   it
  // })
  box(width: 0pt, box(width: attr.width, place(left, dy: dy, dx: attr.left - loc.position().x, {
    set text(size: 10.5pt)
    content
  })))
})

