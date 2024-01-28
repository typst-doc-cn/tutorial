#import "/typ/book/lib.typ": *
#import "/typ/templates/page.typ": project, part-style, dash-color

#let _page-project = project

/// Show a title page with a full page background
#let cover(project-meta) = {
    // #set text(fill: black, font: titleFont)
    // #if logo != none {
    //   place(top + center, pad(top:1cm, image(logo, width: 3cm)))
    // }
  stack(
    1fr,
    align(center + horizon, 
      block(width: 100%, fill: dash-color.lighten(70%), height: 6.2cm, 
        pad(x:2cm, y:1cm)[
          #text(size: 3em, weight: 900, project-meta.display-title)
          #v(1cm, weak: true)
          #text(size: 3em, project-meta.at("subtitle", default: none))
          #v(1cm, weak: true)
          #text(size: 1em, weight: "bold", "Myriad-Dreamin等著")
        ]
      )
    ),
    2fr,
  )
}

#let p = counter("book-part")
#let default-styles = (
  cover-image: "./rm175-noon-02.jpg",
  cover: cover,
  part: it => {
    pagebreak(weak: true)
    //set image(width: 100%, height: 100%)
    set page(margin: 0cm, header: none, background: [
      #move(dy: 3%, scale(x: -130%, y: 130%, rotate(38.2deg,
        image("./rustacean-flat-gesture.svg", width: 130%)
      )))
    ]);
    p.step()
    stack(
      1fr,
      align(right + bottom, 
        block(width: 100%, fill: dash-color.lighten(70%), height: 6.2cm, 
          pad(x:1cm, y:1cm)[
            #set text(size: 36pt)
            #v(1em)
            #heading([Part.#p.display()#h(.5em)] + it)
          ]
        )
      ),
      2fr,
    )
  },
  chapter: it => it,
)

#let project(title: "", display-title: none, authors: (), spec: "", content, styles: default-styles) = {
  let display-title = display-title;
  if display-title == none {
    display-title = title;
  }

  // inherit styles
  let styles = default-styles + styles;
  
  // set document metadata early
  set document(author: authors, title: title)

  // inherit from page setting
  show: _page-project.with(title: none)

  locate(loc => {
    let project-meta = (
      title: title,
      display-title: display-title,
      book: book-meta-state.final(loc),
      styles: styles,
    )

    // todo: abstraction
    {
      //set image(width: 100%, height: 100%)
      set page(margin: 0cm, header: none, background: [
        #place({
          set block(spacing: -0.1em)
          image("./circuit-board.svg")
          image("./circuit-board.svg")
        })
        #move(dy: 3%, scale(x: -130%, y: 130%, rotate(38.2deg,
          image("./rustacean-flat-gesture.svg", width: 130%)
        )))
      ]);

      // place book meta
      external-book(spec: (styles.inc)(spec))
      (styles.cover)(project-meta)
    }

    if project-meta.book != none {
      project-meta.book.summary.map(it => visit-summary(it, styles)).sum()
    }
  })

  content
}