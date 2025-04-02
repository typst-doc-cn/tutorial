
#let separator = "\n\n\n\n\n\n\n\n"

#let allocate-fonts(data) = (kind: "font", hash: none, data: data)

#let create-font-ref(data) = {
  let data = read(data, encoding: none)

  (kind: "font", data: data)
}

#let default-fonts() = (
  "/assets/typst-fonts/LinLibertine_R.ttf",
  "/assets/typst-fonts/LinLibertine_RB.ttf",
  "/assets/typst-fonts/LinLibertine_RBI.ttf",
  "/assets/typst-fonts/LinLibertine_RI.ttf",
  "/assets/typst-fonts/NewCMMath-Book.otf",
  "/assets/typst-fonts/NewCMMath-Regular.otf",
  "/assets/typst-fonts/NewCM10-Regular.otf",
  "/assets/typst-fonts/NewCM10-Bold.otf",
  "/assets/typst-fonts/NewCM10-Italic.otf",
  "/assets/typst-fonts/NewCM10-BoldItalic.otf",
  "/assets/typst-fonts/DejaVuSansMono.ttf",
  "/assets/typst-fonts/DejaVuSansMono-Bold.ttf",
  "/assets/typst-fonts/DejaVuSansMono-Oblique.ttf",
  "/assets/typst-fonts/DejaVuSansMono-BoldOblique.ttf",
)

#let default-cjk-fonts() = (
  "/assets/fonts/SourceHanSerifSC-Regular.otf",
  "/assets/fonts/SourceHanSerifSC-Bold.otf",
)

#let create-world(fonts) = {
  let base = plugin("/assets/artifacts/embedded_typst.wasm")
  let with-fonts = fonts.fold(
    base,
    (pre, path) => {
      let data = read(path, encoding: none)
      plugin.transition(pre.allocate_data, bytes("font"), data)
    },
  )

  plugin.transition(with-fonts.resolve_world)
}

#let _svg-doc(code, fonts) = {
  let typst-with-fonts = create-world(fonts)
  let (header, ..pages) = str(typst-with-fonts.svg(code)).split(separator)
  (header, pages)
}

#let svg-doc(code, fonts: none) = {
  let code = bytes(if type(code) == str {
    code
  } else {
    code.text
  })
  if fonts == none {
    fonts = default-fonts()
  }
  let (header, pages) = _svg-doc(code, fonts)
  (header: json(bytes(header)), pages: pages)
}

