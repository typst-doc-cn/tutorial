#import "/typ/book/lib.typ": *

#import "/typ/templates/ebook.typ"

#show: ebook.project.with(title: "typst-tutorial-cn", spec: "book.typ")

// set a resolver for inclusion
#ebook.resolve-inclusion(it => include it)
