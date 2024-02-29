#import "mod.typ": *

#show: book.page.with(title: [参考：语法示例检索表])

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
  ([有序列表（重新开始标号）], refs.writing-markup.with(reference: <grammar-continue-list>), ```typ
  4. List 1
  + List 2
  ```),
  ([无序列表], refs.writing-markup.with(reference: <grammar-emum>), ```typ
  - Enum 1
  - Enum 2
  ```),
  ([交替有序与无序列表], refs.writing-markup.with(reference: <grammar-mix-list-emum>), ```typ
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
  ([语法高亮], refs.writing-markup.with(reference: <grammar-lang-raw>), ````typ
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
  ([图像标题], refs.writing-markup.with(reference: <grammar-figure>), ````typ
  #figure(```typ 
  #image("/assets/files/香風とうふ店.jpg")
  ```, caption: [用于加载香風とうふ店送外卖的宝贵影像的代码])
  ````),
  ([链接], refs.writing-markup.with(reference: <grammar-link>), ````typ
  #link("https://zh.wikipedia.org")[维基百科]
  ````),
  ([HTTP(S)链接], refs.writing-markup.with(reference: <grammar-http-link>), ````typ
  https://zh.wikipedia.org
  ````),
  ([内部链接], refs.writing-markup.with(reference: <grammar-internal-link>), ````typ
  == 某个标题 <ref-internal-link>
  #link(<ref-internal-link>)[链接到某个标题]
  ````),
  ([表格], refs.writing-markup.with(reference: <grammar-table>), ````typ
  #table(columns: 2, [111], [2], [3])
  ````),
  ([对齐表格], refs.writing-markup.with(reference: <grammar-table-align>), ````typ
  #table(columns: 2, align: center, [111], [2], [3])
  ````),
  ([行内数学公式], refs.writing-markup.with(reference: <grammar-inline-math>), ````typ
  $sum_x$
  ````),
  ([行间数学公式], refs.writing-markup.with(reference: <grammar-display-math>), ````typ
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
  ([无驱逐效果的下划线], refs.writing-markup.with(reference: <grammar-underline-evade>), ````typ
  #underline(evade: false)[Language]
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
  ([代码块], refs.writing-markup.with(reference: <grammar-code-block>), ````typ
  #{"a"; "b"}
  ````),
  ([内容块], refs.writing-markup.with(reference: <grammar-content-block>), ````typ
  #[内容块]
  ````),
  ([代码表示的自省函数], refs.content-scope-style.with(reference: <grammar-repr>), ````typ
  #repr([ 一段文本 ])
  ````),
  ([类型的自省函数], refs.content-scope-style.with(reference: <grammar-type>), ````typ
  #type([一段文本])
  ````),
  ([求值函数], refs.content-scope-style.with(reference: <grammar-eval>), ````typ
  #type(eval("1"))
  ````),
  ([求值函数（标记模式）], refs.content-scope-style.with(reference: <grammar-eval-markup-mode>), ````typ
  #eval("== 一个标题", mode: "markup")
  ````),
  ([空字面量], refs.content-scope-style.with(reference: <grammar-none-literal>), ````typ
  #type(none)
  ````),
  ([假（布尔值）], refs.content-scope-style.with(reference: <grammar-false-literal>), ````typ
  #false
  ````),
  ([真（布尔值）], refs.content-scope-style.with(reference: <grammar-true-literal>), ````typ
  #true
  ````),
  ([整数字面量], refs.content-scope-style.with(reference: <grammar-integer-literal>), ````typ
  #(-1), #(0), #(1)
  ````),
  ([进制数字面量], refs.content-scope-style.with(reference: <grammar-n-adecimal-literal>), ````typ
  #(-0xdeadbeef), #(-0o644), #(-0b1001)
  ````),
  ([浮点数字面量], refs.content-scope-style.with(reference: <grammar-float-literal>), ````typ
  #(0.001), #(.1), #(2.)
  ````),
  ([指数表示法], refs.content-scope-style.with(reference: <grammar-exp-repr-float>), ````typ
  #(1e2), #(1.926e3), #(-1e-3)
  ````),
  ([字符串字面量], refs.content-scope-style.with(reference: <grammar-string-literal>), ````typ
  #"Hello world!!"
  ````),
  ([字符串转义序列], refs.scripting-base.with(reference: <grammar-str-escape-sequences>), ````typ
  #"\""
  ````),
  ([字符串的Unicode转义序列], refs.scripting-base.with(reference: <grammar-str-unicode-escape-sequences>), ````typ
  #"\u{9999}"
  ````),
  ([变量声明], refs.content-scope-style.with(reference: <grammar-var-decl>), ````typ
  #let x = 1;
  ````),
  ([函数声明], refs.content-scope-style.with(reference: <grammar-func-decl>), ````typ
  #let f(x) = x * 2;
  ````),
  ([逻辑比较表达式], refs.content-scope-style.with(reference: <grammar-logical-cmp-exp>), ````typ
  #(1 < 0), #(1 >= 2), #(1 == 2), #(1 != 2)
  ````),
  ([逻辑运算表达式], refs.content-scope-style.with(reference: <grammar-logical-calc-exp>), ````typ
  #(not false), #(false or true), #(true and false)
  ````),
  ([取正运算], refs.content-scope-style.with(reference: <grammar-plus-exp>), ````typ
  #(+1), #(+0), #(1), #(++1)
  ````),
  ([取负运算], refs.content-scope-style.with(reference: <grammar-minus-exp>), ````typ
  #(-1), #(-0), #(--1), #(-+-1)
  ````),
  ([算术运算表达式], refs.content-scope-style.with(reference: <grammar-arith-exp>), ````typ
  #(1 + 1), #(1 + -1), #(1 - 1), #(1 - -1)
  ````),
  ([赋值表达式], refs.content-scope-style.with(reference: <grammar-assign-exp>), ````typ
  #let a = 1; #repr(a = 10), #a, #repr(a += 2), #a
  ````),
  ([字符串连接], refs.content-scope-style.with(reference: <grammar-string-concat-exp>), ````typ
  #("a" + "b")
  ````),
  ([重复连接字符串], refs.content-scope-style.with(reference: <grammar-string-mul-exp>), ````typ
  #("a" * 4), #(4 * "ab")
  ````),
  ([字符串比较], refs.content-scope-style.with(reference: <grammar-string-cmp-exp>), ````typ
  #("a" == "b"), #("a" != "b"), #("a" < "ab"), #("a" >= "a")
  ````),
  ([整数转浮点数], refs.content-scope-style.with(reference: <grammar-int-to-float>), ````typ
  #float(1), #(type(float(1)))
  ````),
  ([布尔值转整数], refs.content-scope-style.with(reference: <grammar-bool-to-int>), ````typ
  #int(true), #(type(int(true)))
  ````),
  ([浮点数转整数], refs.content-scope-style.with(reference: <grammar-float-to-int>), ````typ
  #int(1), #(type(int(1)))
  ````),
  ([十进制字符串转整数], refs.content-scope-style.with(reference: <grammar-dec-str-to-int>), ````typ
  #int("1"), #(type(int("1")))
  ````),
  ([十六进制/八进制/二进制字符串转整数], refs.content-scope-style.with(reference: <grammar-nadec-str-to-int>), ````typ
  #let safe-to-int(x) = {
    let res = eval(x)
    assert(type(res) == int, message: "should be integer")
    res
  }
  #safe-to-int("0xf"), #(type(safe-to-int("0xf"))) \
  #safe-to-int("0o755"), #(type(safe-to-int("0o755"))) \
  #safe-to-int("0b1011"), #(type(safe-to-int("0b1011"))) \
  ````),
  ([数字转字符串], refs.content-scope-style.with(reference: <grammar-num-to-str>), ````typ
  #repr(str(1)), #repr(str(.5))
  ````),
  ([整数转十六进制字符串], refs.content-scope-style.with(reference: <grammar-int-to-nadec-str>), ````typ
  #str(501, base:16), #str(0xdeadbeef, base:36)
  ````),
  ([布尔值转字符串], refs.content-scope-style.with(reference: <grammar-bool-to-str>), ````typ
  #repr(false)
  ````),
  ([数字转布尔值], refs.content-scope-style.with(reference: <grammar-int-to-bool>), ````typ
  #let to-bool(x) = x != 0
  #repr(to-bool(0)), #repr(to-bool(1))
  ````),
  ([函数调用], refs.writing-markup.with(reference: <grammar-func-call>), ````typ
  #calc.pow(4, 3)
  ````),
  ([内容参数], refs.writing-markup.with(reference: <grammar-content-param>), ````typ
  #emph[emphasis]
  ````),
  ([成员], refs.content-scope-style.with(reference: <grammar-member-exp>), ````typ
  #`OvO`.text
  ````),
  ([方法], refs.content-scope-style.with(reference: <grammar-method-exp>), ````typ
  #"Hello World".split(" ")
  ````),
  ([数组字面量], refs.content-scope-style.with(reference: <grammar-array-literal>), ````typ
  #(1, "OvO", [一段内容])
  ````),
  ([判断数组内容], refs.content-scope-style.with(reference: <grammar-array-in>), ````typ
  #(1 in (1, "OvO", [一段内容]))
  ````),
  ([判断数组内容不在], refs.content-scope-style.with(reference: <grammar-array-not-in>), ````typ
  #([另一段内容] not in (1, "OvO", [一段内容]))
  ````),
  ([字典字面量], refs.content-scope-style.with(reference: <grammar-dict-literal>), ````typ
  #(neko-mimi: 2, "utterance": "喵喵喵")
  ````),
  ([字典成员], refs.content-scope-style.with(reference: <grammar-dict-member-exp>), ````typ
  #let cat = (neko-mimi: 2)
  #cat.neko-mimi
  ````),
  ([判断字典内容], refs.content-scope-style.with(reference: <grammar-dict-in>), ````typ
  #let cat = (neko-mimi: 2)
  #("neko-mimi" in cat)
  ````),
  ([空数组], refs.content-scope-style.with(reference: <grammar-empty-array>), ````typ
  #()
  ````),
  ([空字典], refs.content-scope-style.with(reference: <grammar-empty-dict>), ````typ
  #(:)
  ````),
  ([被括号包裹的空数组], refs.content-scope-style.with(reference: <grammar-paren-empty-array>), ````typ
  #(())
  ````),
  ([含有一个元素的数组], refs.content-scope-style.with(reference: <grammar-single-member-array>), ````typ
  #(1,)
  ````),
  ([数组解构赋值], refs.content-scope-style.with(reference: <grammar-destruct-array>), ````typ
  #let x = (1, "Hello, World", [一段内容])
  #let (one, hello-world, a-content) = x
  ````),
  ([数组解构赋值情形二], refs.content-scope-style.with(reference: <grammar-destruct-array-eliminate>), ````typ
  #let (_, second, ..) = (1, "Hello, World", [一段内容]); #second
  ````),
  ([字典解构赋值], refs.content-scope-style.with(reference: <grammar-destruct-dict>), ````typ
  #let cat = (neko-mimi: 2, "utterance": "喵喵喵")
  #let (utterance: u) = cat; #u
  ````),
  ([数组内容重映射], refs.content-scope-style.with(reference: <grammar-array-remapping>), ````typ
  #let a = 1; #let b = 2; #let c = 3
  #let (b, c, a) = (a, b, c)
  #a, #b, #c
  ````),
  ([数组内容交换], refs.content-scope-style.with(reference: <grammar-array-swap>), ````typ
  #let a = 1; #let b = 2
  #((a, b) = (b, a))
  #a, #b
  ````),
  ([`if`语句], refs.content-scope-style.with(reference: <grammar-if>), ````typ
  #if true { 1 },
  #if false { 1 } else { 0 }
  ````),
  ([串联`if`语句], refs.content-scope-style.with(reference: <grammar-if-if>), ````typ
  #if false { 0 } else if true { 1 },
  #if false { 2 } else if false { 1 } else { 0 }
  ````),
  ([`while`语句], refs.content-scope-style.with(reference: <grammar-while>), ````typ
  #{
    let i = 0;
    while i < 10 {
      (i * 2, )
      i += 1;
    }
  }
  ````),
  ([`for`语句], refs.content-scope-style.with(reference: <grammar-for>), ````typ
  #for i in range(10) {
    (i * 2, )
  }
  ````),
  ([`for`语句解构赋值], refs.content-scope-style.with(reference: <grammar-for-destruct>), ````typ
  #for (特色, 这个) in (neko-mimi: 2) [猫猫的 #特色 是 #这个\ ]
  ````),
  ([`break`语句], refs.content-scope-style.with(reference: <grammar-break>), ````typ
  #for i in range(10) { (i, ); (i + 1926, ); break }
  ````),
  ([`continue`语句], refs.content-scope-style.with(reference: <grammar-continue>), ````typ
  #for i in range(10) {
    if calc.even(i) { continue }
    (i, )
  }
  ````),
  ([占位符（`let _ = ..`）], refs.content-scope-style.with(reference: <grammar-placeholder>), ````typ
  #let last-two(t) = {
    let _ = t.pop()
    t.pop()
  }
  #last-two((1, 2, 3, 4))
  ````),
  ([`return`语句], refs.content-scope-style.with(reference: <grammar-return>), ````typ
  #let never(..args) = return
  #type(never(1, 2))
  ````),
  ([函数闭包], refs.content-scope-style.with(reference: <grammar-closure>), ````typ
  #let f = (x, y) => [两个值#(x)和#(y)偷偷混入了我们内容之中。]
  #f("a", "b")
  ````),
  ([具名参数声明], refs.content-scope-style.with(reference: <grammar-named-param>), ````typ
  #let g(some-arg: none) = [很多个值，#some-arg，偷偷混入了我们内容之中。]
  #g()
  #g(some-arg: "OwO")
  ````),
  ([含变参函数], refs.content-scope-style.with(reference: <grammar-variadic-param>), ````typ
  #let g(..args) = [很多个值，#args.pos().join([、])，偷偷混入了我们内容之中。]
  #g([一个俩个], [仨个四个], [五六七八个])
  ````),
  ````),
))
