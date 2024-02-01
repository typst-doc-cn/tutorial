
#let typst = plugin("/assets/artifacts/embedded_typst.wasm")

#let separator = "\n\n\n\n\n\n\n\n"

#let allocate-fonts(data) = (
  kind: "font",
  hash: none,
  data: data,
)

#let default-fonts = (
    "/assets/fonts/SourceHanSerifSC-Regular.otf",
    "/assets/fonts/SourceHanSerifSC-Bold.otf",
    // Embed default fonts.
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
).map(t => {
  let data = read(t, encoding: none);
  let fg = typst.allocate_data(bytes("font"), data);
  let data = str(typst.encode_base64(data));

  (
    kind: "font",
    hash: str(fg),
    data: data,
  )
})

#let resolve-context(fonts) = {
  bytes(json.encode((
    data: (..fonts),
  )))
}

#let make-partial-ref(fonts) = {
  (fonts.map(e => (
    kind: e.kind,
    hash: e.hash,
  )),)
}

#let _svg-doc(code, fonts) = {
  // Pass only hash references at first time
  let partial-ctx = resolve-context(..make-partial-ref(fonts))
  let (header, ..pages) = str(typst.svg(partial-ctx, code)).split(separator)

  // In case of cache miss
  if not header.starts-with("code-trapped") {
    return (header, pages)
  }

  // Pass full data
  let full-ctx = resolve-context(fonts);
  let (header, ..pages) = str(typst.svg(full-ctx, code)).split(separator)
  (header, pages)
}

#let svg-doc(code, fonts: default-fonts) = {
  let code = bytes(if type(code) == str {
    code
  } else {
    code.text
  })
  let (header, pages) = _svg-doc(code, fonts)
  (header: json.decode(header), pages: pages)
}

