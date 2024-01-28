#import "mod.typ": *

#show: book.page.with(title: "维护文档内容与样式")

== 内容类型的特性

略

== `import`和`include`

略

== 生活在Content树上

#code(```typ
#let hello-world() = {
  "H"; "e"; "l"; "l"; "o"; " "
  "w"; "o"; "r"; "l"; "d"; "!"; "!"; "!"
}
#hello-world()
```)

#code(```typ
#let hello-world() = {
  [= 生活在Content树上]
  [现代社会以海德格尔的一句“一切实践传统都已经瓦解完了”为嚆矢。]
  [滥觞于家庭与社会传统的期望正失去它们的借鉴意义。]
  [但面对看似无垠的未来天空，我想循卡尔维诺“树上的男爵”的生活好过过早地振翮。]
  parbreak()
  [...]
  parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#hello-world()
```)

== CeTZ的树

#code(```typ
#let canvas(x) = {}
#canvas({
  // line()
  // content()
  // ...
})
```)

== PNG的树

#code(```typ
#let canvas(x) = {}
#canvas({
  // line()
  // content()
  // ...
})
```)
