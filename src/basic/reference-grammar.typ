#import "mod.typ": *

#show: book.page.with(title: [参考：语法检索表])

#let table-lnk(name, ref, it, scope: (:), res: none, ..args) = (
  align(center + horizon, ref(name)), 
  it,
  align(horizon, {
    set heading(bookmarked: false, outlined: false)
    eval(it.text, mode: "markup", scope: scope)
  }),
)

#let ref-table(items) = table(
  columns: (1fr, 1fr, 1fr),
  align(center)[「名称/术语」], align(center)[语法], align(center)[渲染结果],
  ..items.map(args => table-lnk(..args)).flatten()
)

点击下面每行名称都可以跳转到对应章节的对应小节。

== 分类：功能性语义 <grammar-table:func>

#ref-table((
  ([段落], refs.writing-markup.with(reference: <grammar-paragraph>), ```typ
  writing-markup
  ```),
  ([标题], refs.writing-markup.with(reference: <grammar-heading>), ```typ
  = Heading
  ```),
  ([二级标题], refs.writing-markup.with(reference: <grammar-heading>), ```typ
  == Heading
  ```),
  ([着重标记], refs.writing-markup.with(reference: <grammar-strong>), ```typ
  *Strong*
  ```),
  ([强调标记], refs.writing-markup.with(reference: <grammar-emph>), ```typ
  _emphasis_
  ```),
  ([着重且强调标记], refs.writing-markup.with(reference: <grammar-emph>), ```typ
  *_emphasis_*
  ```),
  ([有序列表], refs.writing-markup.with(reference: <grammar-list>), ```typ
  + List 1
  + List 2
  ```),
  ([有序列表（重新开始标号）], refs.writing-markup.with(reference: <grammar-list>), ```typ
  4. List 1
  + List 2
  ```),
  ([无序列表], refs.writing-markup.with(reference: <grammar-emum>), ```typ
  - Enum 1
  - Enum 2
  ```),
  ([交替有序与无序列表], refs.writing-markup.with(reference: <grammar-emum>), ```typ
  - Enum 1
    + Item 1
  - Enum 2
  ```),
  ([短代码片段], refs.writing-markup.with(reference: <grammar-raw>), ````typ
  `code`
  ````),
  ([长代码片段], refs.writing-markup.with(reference: <grammar-long-raw>), ````typ
  ``` code```
  ````),
  ([语法高亮], refs.writing-markup.with(reference: <grammar-long-raw>), ````typ
  ```rs  trait World```
  ````),
  ([块代码片段], refs.writing-markup.with(reference: <grammar-blocky-raw>), ````typ
  ```typ
  = Heading
  ```
  ````),
  ([图像], refs.writing-markup.with(reference: <grammar-image>), ````typ
  #image("/assets/files/香風とうふ店.jpg", width: 50pt)
  ````),
  ([拉伸图像], refs.writing-markup.with(reference: <grammar-image-stretch>), ````typ
  #image("/assets/files/香風とうふ店.jpg", width: 50pt, height: 50pt, fit: "stretch")
  ````),
  ([内联图像（盒子法）], refs.writing-markup.with(reference: <grammar-image-inline>), ````typ
  在一段话中插入一个#box(baseline: 0.15em, image("/assets/files/info-icon.svg", width: 1em))图片。
  ````),
  ([外部链接], refs.writing-markup.with(reference: <grammar->), ````typ
  #link("https://zh.wikipedia.org")[维基百科]
  ````),
  ([HTTP(S)链接], refs.writing-markup.with(reference: <grammar->), ````typ
  https://zh.wikipedia.org
  ````),
  ([内部链接], refs.writing-markup.with(reference: <grammar->), ````typ
  == 某个标题 <ref-internal-link>
  #link(<ref-internal-link>)[链接到某个标题]
  ````),
  ([表格], refs.writing-markup.with(reference: <grammar->), ````typ
  #table(columns: 2, [111], [2], [3])
  ````),
  ([对齐表格], refs.writing-markup.with(reference: <grammar->), ````typ
  #table(columns: 2, align: center, [111], [2], [3])
  ````),
  ([行内数学公式], refs.writing-markup.with(reference: <grammar->), ````typ
  $sum_x$
  ````),
  ([行间数学公式], refs.writing-markup.with(reference: <grammar->), ````typ
  $ sum_x $
  ````),
  ([标记转义序列], refs.writing-markup.with(reference: <grammar-escape-sequences>), ````typ
  >\_<
  ````),
  ([标记的Unicode转义序列], refs.writing-markup.with(reference: <grammar-unicode-escape-sequences>), ````typ
  \u{9999}
  ````),
  ([换行符（转义序列）], refs.writing-markup.with(reference: <grammar-newline-by-space>), ````typ
  A \ B
  ````),
  ([换行符情形二], refs.writing-markup.with(reference: <grammar-newline>), ````typ
  A \
  B
  ````),
  ([速记符], refs.writing-markup.with(reference: <grammar-shorthand>), ````typ
  北京--上海
  ````),
  ([空格（速记符）], refs.writing-markup.with(reference: <grammar-shorthand-space>), ````typ
  A~B
  ````),
  ([行内注释], refs.writing-markup.with(reference: <grammar-inline-comment>), ````typ
  // 行内注释
  ````),
  ([行间注释], refs.writing-markup.with(reference: <grammar-cross-line-comment>), ````typ
  /* 行间注释
    */
  ````),
  ([行内盒子], refs.writing-markup.with(reference: <grammar-box>), ````typ
  在一段话中插入一个#box(baseline: 0.15em, image("/assets/files/info-icon.svg", width: 1em))图片。
  ````),
))

== 分类：修饰文本 <grammar-table:text>

#ref-table((
  ([背景高亮], refs.writing-markup.with(reference: <grammar-highlight>), ````typ
  #highlight[高亮一段内容]
  ````),
  ([下划线], refs.writing-markup.with(reference: <grammar-underline>), ````typ
  #underline[ጿኈቼዽ]
  ````),
  ([上划线], refs.writing-markup.with(reference: <grammar-overline>), ````typ
  #overline[ጿኈቼዽ]
  ````),
  ([中划线（删除线）], refs.writing-markup.with(reference: <grammar-strike>), ````typ
  #strike[ጿኈቼዽ]
  ````),
  ([下标], refs.writing-markup.with(reference: <grammar-subscript>), ````typ
  威严满满#sub[抱头蹲防] 
  ````),
  ([上标], refs.writing-markup.with(reference: <grammar-superscript>), ````typ
  香風とうふ店#super[TM]
  ````),
  ([设置文本大小], refs.writing-markup.with(reference: <grammar-text-size>), ````typ
  #text(size: 24pt)[一斤鸭梨]
  ````),
  ([设置文本颜色], refs.writing-markup.with(reference: <grammar-text-fill>), ````typ
  #text(fill: blue)[蓝色鸭梨]
  ````),
  ([设置字体], refs.writing-markup.with(reference: <grammar-text-font>), ````typ
    #text(font: "Microsoft YaHei")[板正鸭梨]
  ````),
))

== 分类：脚本或类脚本 <grammar-table:script>

#ref-table((
  ([进入脚本模式], refs.writing-markup.with(reference: <grammar-enter-script>), ````typ
  #1
  ````),
  ([内容块], refs.writing-markup.with(reference: <grammar-content-block>), ````typ
  #[内容块]
  ````),
  ([字符串转义序列], refs.scripting-base.with(reference: <grammar-str-escape-sequences>), ````typ
  #"\""
  ````),
  ([字符串的Unicode转义序列], refs.scripting-base.with(reference: <grammar-str-unicode-escape-sequences>), ````typ
  #"\u{9999}"
  ````),
  ([函数调用], refs.writing-markup.with(reference: <grammar-func-call>), ````typ
  #calc.pow(4, 3)
  ````),
  ([内容参数], refs.writing-markup.with(reference: <grammar-content-param>), ````typ
  #emph[emphasis]
  ````),
  ([set语法], refs.writing-markup.with(reference: <grammar-set>), ````typ
    #text(font: "Microsoft YaHei")[板正鸭梨]
  ````),
))
