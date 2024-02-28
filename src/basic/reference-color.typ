#import "mod.typ": *

#show: book.ref-page.with(title: [参考：颜色、色彩渐变与模式])

== RGB

Create an RGB(A) color. #ref-bookmark[`color.rgb`]

The color is specified in the sRGB color space.

An RGB(A) color is represented internally by an array of four components:

#code(```typ
#square(fill: rgb("#b1f2eb"))
#square(fill: rgb(87, 127, 230))
#square(fill: rgb(25%, 13%, 65%))
```)

== HSL

Create an HSL color. #ref-bookmark[`color.hsl`]

This color space is useful for specifying colors by hue, saturation and lightness. It is also useful for color manipulation, such as saturating while keeping perceived hue.

An HSL color is represented internally by an array of four components:
- hue (angle)
- saturation (ratio)
- lightness (ratio)
- alpha (ratio)

These components are also available using the components method.

#code(```typ
#square(
  fill: color.hsl(30deg, 50%, 60%)
)
```)

== CMYK

Create a CMYK color. #ref-bookmark[`color.cmyk`]

This is useful if you want to target a specific printer. The conversion to RGB for display preview might differ from how your printer reproduces the color.

// todo: typo in reference
An CMYK color is represented internally by an array of four components:
- cyan (ratio)
- magenta (ratio)
- yellow (ratio)
- key (ratio)

These components are also available using the components method.

#code(```typ
#square(
  fill: cmyk(27%, 0%, 3%, 5%)
)
```)

== Luma

== Oklab

== Oklch

== Linear RGB

== HSV

== 色彩空间

Returns the constructor function for this color's space. #ref-bookmark[`color.space`]

== 十六进制表示（RGB）

Returns the color's RGB(A) hex representation. #ref-bookmark[`color.to-hex`]

Hex such as `#ffaa32` or `#020304fe`. The alpha component (last two digits in `#020304fe`) is omitted if it is equal to ff (255 / 100%).

== 颜色计算

=== lighten

Lightens a color by a given factor. #ref-bookmark[`color.lighten`]

=== darken

Darkens a color by a given factor. #ref-bookmark[`color.darken`]

=== saturate

Increases the saturation of a color by a given factor. #ref-bookmark[`color.saturate`]

=== negate

Produces the negative of the color. #ref-bookmark[`color.negate`]

=== rotate

Rotates the hue of the color by a given angle. #ref-bookmark[`color.rotate`]

=== mix

Create a color by mixing two or more colors. #ref-bookmark[`color.mix`]

== 色彩渐变

A color gradient. #ref-bookmark[`gradient`]

Typst supports linear gradients through the gradient.linear function, radial gradients through the gradient.radial function, and conic gradients through the gradient.conic function.

A gradient can be used for the following purposes:

- As a fill to paint the interior of a shape: ```typc rect(fill: gradient.linear(..))```
- As a stroke to paint the outline of a shape: ```typc rect(stroke: 1pt + gradient.linear(..))```
- As the fill of text: ```typc set text(fill: gradient.linear(..))```
- As a color map you can sample from: ```typc gradient.linear(..).sample(0.5)```

#code(```typ
#stack(
  dir: ltr,
  spacing: 1fr,
  square(fill: gradient.linear(
    ..color.map.rainbow)),
  square(fill: gradient.radial(
    ..color.map.rainbow)),
  square(fill: gradient.conic(
    ..color.map.rainbow)),
)
```)

== 填充模式

A repeating pattern fill. #ref-bookmark[`pattern`]

Typst supports the most common pattern type of tiled patterns, where a pattern is repeated in a grid-like fashion, covering the entire area of an element that is filled or stroked. The pattern is defined by a tile size and a body defining the content of each cell. You can also add horizontal or vertical spacing between the cells of the patterng.

#code(```typ
#let pat = pattern(size: (30pt, 30pt))[
  #place(line(start: (0%, 0%), end: (100%, 100%)))
  #place(line(start: (0%, 100%), end: (100%, 0%)))
]

#rect(fill: pat, width: 100%, height: 60pt, stroke: 1pt)
```)
