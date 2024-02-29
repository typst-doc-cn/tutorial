#import "mod.typ": *

#show: book.ref-page.with(title: [参考：基本类型])

#let glue-block = block.with(breakable: false)

Typst的基本类型设计大量参考Python和Rust。Typst基本类型的特点是半纯的API设计。其基本类型的方法倾向于保持纯度，但如果影响到了使用的方便性，Typst会适当牺牲纯度。

如下所示，`array.push`就是带有副作用的：

#code(```typ
#let t = (1, 2)
#t.push(3)
#t
```)

== 布尔类型 <reference-type-bool>

Typst的布尔值是只有两个实例的类型。#ref-bookmark[`type:bool`]

#code(```
#false, #true
```)

布尔值一般用来表示逻辑的确否。

#code(```
#(1 < 2), #(1 > 2)
```)

== 整数 <reference-type-int>

Typst的整数是64位宽度的有符号整数。#ref-bookmark[`type:int`]

*有符号*整数的意思是，你可以使用正整数、负整数或零作为整数对象的内容。

#code(```typ
正数：#1；负数：#(-1)；零：#0。
```)

*64位宽度*整数的意思是，Typst允许你使用的整数是有限大的。正数、负数与整数均分$2^64$个数字。因此：
- 最大的正整数是$2^63-1$。

  #code(```typ
  #int(9223372036854775807)
  ```)
- 最小的负整数是$-2^63$。

  #code(```typ
  #int(-9223372036854775808)
  ```)

Typst还允许你使用其他#term("representation")表示整数。借鉴了其他编程语言，使用`0x`、`0o`和`0b`分别可以指定十六进制、八进制和二进制整数：

#code(```typ
#0xffff, #0o755, #0b101010
```)

#ref-cons-signature("int")

除了#term("literal")构造整数，#ref-bookmark[`func:int`]你还能使用构造器#typst-func("int")将其他值转换为整数。

- 将布尔值转换为$0$或$1$：
  #code(```typ
  #int(false), #int(true)
  ```)
- 将浮点数向零取整为整数：
  #code(```typ
  #int(-1.1), #int(1.1), #int(-0.1), #int(-1.9)
  ```)
- 将字符串依照十进制表示转换为整数：
  #code(```typ
  #int("42"), #int("0"), #int("-17")
  ```)

你可以使用各种操作符进行整数运算：

#code(```typ
#(1 + 2) \
#(2 - 5) \
#(3 + 4 < 8)
```)

详见#(refs.scripting-base)[《基本字面量、变量和简单函数》]中的表达式类型。

整数类型上没有任何方法，但是Typst正计划将`calc`上的方法移动到整数类型和浮点数类型上。

== 浮点数 <reference-type-float>

Typst的浮点数是64位宽度的有符号浮点数。#ref-bookmark[`type:float`]

*有符号*浮点数的意思是，你可以使用正数、负数或零作为浮点数数对象的内容。*64位宽度*浮点数的意思是，Typst允许你使用的浮点数是有限大的。正数、负数与浮点数均分$2^64$个浮点数。

Typst的浮点数遵守#link("https://standards.ieee.org/ieee/754/6210/")[IEEE-754浮点数标准]。因此：
- 最大的正数为 $f_max = 2^1023 dot (2 - 2^(-52))$。
- 最小的正数为 $f_min = 2^(-1022) dot 2^(-52)$。
- 最大的负数为 $-f_min$。
- 最小的负数为 $-f_max$。

Typst还允许你使用#term("exponential notation")表示浮点数。Typst允许你使用`{x}e{y}`格式表示$x dot 10^y$的浮点数：

#code(```typ
#1e1, #1e-1, #(-1e1), #(-1e-1), #(1.1e1)
```)

#ref-cons-signature("float")

除了#term("literal")构造浮点数，#ref-bookmark[`func:float`]你还能使用构造器#typst-func("float")将其他值转换为浮点数。

- 将布尔值转换为$0.0$或$1.0$：
  #code(```typ
  #float(false), #float(true)
  ```)
- 将整数转换成#term("nearest")的浮点数：
  #code(```typ
  #float(0), #float(-0), #float(10000000000)
  ```)
- 将百分比数字转换成#term("nearest")的浮点数：
  #code(```typ
  #float(100%), #float(1150%), #float(1%)
  ```)
- 将字符串依照十进制或#term("exponential notation")表示转换为浮点数：
  #code(```typ
  #float("42.2"), #float("0"), #float("-17"), #float("1e5")
  ```)

你可以使用各种操作符进行浮点数运算，且浮点数允许与整数混合运算：

#code(```typ
#(10 / 4) \
#(3.5 + 4.6 < 8)
```)

详见#(refs.scripting-base)[《基本字面量、变量和简单函数》]中的表达式类型。

浮点数类型上没有任何方法，但是Typst正计划将`calc`上的方法移动到整数类型和浮点数类型上。

== 字符串 <reference-type-str>

Typst的字符串是#term("utf-8 encoding")的字节序列。#ref-bookmark[`type:str`]

#link("https://en.wikipedia.org/wiki/UTF-8", "UTF-8编码")是一个广泛使用的变长编码规范。这意味着当你使用“abc123”字符串时，实际存储了这样的字节数据：

#code(```typ
#let f(x) = range(x.len()).map(
  i => x.at(i))
#f(bytes("abc123"))
```)

这意味着当你使用“ふ店”字符串时，实际存储了这样的字节数据：

#code(```typ
#let f(x) = range(x.len()).map(
  i => x.at(i))
#f(bytes("ふ店"))
```)

在绝大部分情况下，你不需要关心字符串的编码问题，因为在Typst脚本中只有#term("utf-8 encoding")的字符串。

但是这不意味着你不需要了解#term("utf-8 encoding")。Typst的字符串API与底层编码息息相关，因此你需要尽可能多地掌握与#term("utf-8 encoding")有关的知识。

在编码体系中，与Typst相关的主要有三层，它们在原始字节数据视角下的边界并不一样：

+ 字节表示：按字节寻址时，每个偏移量都索引到一个字节。
+ #term("codepoint")表示：#term("utf-8 encoding")是变长编码。在#term("utf-8 encoding")中，很多#term("codepoint")都由多个字节组成。UTF-8字符串中#term("codepoint")数据按照顺序存放，自然有些字节偏移量在#term("codepoint")寻址中不是合法的。
+ #term("grapheme cluster")表示：#term("grapheme cluster")就是人类视觉效果上的“最小字符单位”。在码位之上，Unicode规范还规定了多个码位组成一个#term("grapheme cluster")的情况。在这种情况下，自然有些码位（字节）偏移量在#term("grapheme cluster")寻址中不是合法的。

下表说明了\u{0061}\u{0303}在字节表示下的合法偏移量。

#let to-bytes-array(x) = range(x.len()).map(
  i => x.at(i))

#{
  set align(center)
  let i = text(red, [非法])
  table(
  columns: (50pt, 95pt, 130pt, 80pt, ),
  ..(
    [数据], ..to-bytes-array(bytes("\u{0061}\u{0303}")).map(it => [0x#str(it, base: 16)]),
    [字节], [第1个字节], [第2个字节], [第3个字节]
  ).map(it => align(center, it)),
  [码位], [英文字母a], [#term("tilde diacritical marks")], i,
  [字素簇], [波浪变音的英文字母a], i, i
)
}


#pro-tip[
  关于#term("grapheme cluster")的定义，请参考#link("https://unicode.org/reports/tr29/")[《Unicode规范：文本分段》]。
]


字符串的字面量由双引号包裹。你可以在字符串字面量中使用与字符串相关的转义序列。

#code(```typ
#"hello world!" \
#"\"hello\n  world\"!" \
```)

详见#(refs.scripting-base)[《基本字面量、变量和简单函数》]中关于字符串类型的描述。

你可以使用`in`关键字检查一个字符串是否是另一个字符串的子串：#ref-bookmark[`operator:in`\ of  `str`]

#code(```typ
#("fox" in "lazy fox"),
#(" fox" in "lazy fox"),
#("fox " in "lazy fox"),
#("dog" in "lazy fox")
```)

`in`关键字左侧值还可以是一个正则表达式类型，以检查#term("pattern")是否匹配字符串：

#code(```typ
#(regex("\d+") in "ten euros") \
#(regex("\d+") in "10 euros")
```)

`in`关键字是以#term("codepoint")为粒度检查文本的：

#code(```typ
#("\u{0303}" in "ã")
```)

#ref-cons-signature("str")

除了#term("literal")构造字符串，#ref-bookmark[`func:str`]你还能使用构造器#typst-func("str")将其他值转换为字符串。

- 将整数和浮点数转换为十进制格式字符串：
  #code(```typ
  #str(0), #str(199),
  #str(0.1), #str(9.1)
  ```)
- 将标签转换为其名称：
  #code(```typ
  #str(<owo:this-label>)
  ```)
- 将字节数组依照#term("utf-8 encoding")编码：
  #code(```typ
  #str(bytes((72, 0x69, 33)))
  ```)

特别地，你可以使用`base`参数，#ref-bookmark[`param:base`\ of `str`]将整数依照$N (2 lt.slant N lt.slant 36)$进制格式转换为字符串：

#code(```typ
#str(15, base: 16),
#str(14, base: 14),
#str(0xdeadbeef, base: 36)
```)

借鉴Python和JavaScript，Typst不提供字符类型。相应的，仅具备单个#term("codepoint")的字符串就被视作一个#term("character")。也就是说，Typst认定#term("character")与#term("codepoint")等同。这是符合主流观念的。

- “a”、“我”是字符。

- “ã”不是字符。

#glue-block[
  #ref-method-signature("str.to-unicode")

  你可以使用#typst-func("str.to-unicode")#ref-bookmark[`method:to-unicode`\ `of str`]函数获得一个字符的#term("codepoint")表示：

  #code(```typ
  #"a".to-unicode(),
  #"我".to-unicode()
  ```)

  #pro-tip[
    显然，不是所有的“字符”都可以应用`to-unicode`方法。

    #```typ
    #"ã".to-unicode() /* 不能编译 */
    ```
    
    这是因为视觉上为单个字符的ã是一个#term("grapheme cluster")，包含多个码位。
  ]
]

#ref-method-signature("str.from-unicode")

你可以使用#typst-func("str.from-unicode")#ref-bookmark[`method:from-unicode`\ `of str`]函数将一个数字的#term("codepoint")表示转换成字符（串）：

#code(```typ
#str.from-unicode(97),
#str.from-unicode(25105)
```)

#ref-method-signature("str.len")

你可以使用#typst-func("str.len")#ref-bookmark[`method:len`\ `of str`]函数获得一个字符串的*字节表示的长度*：

#code(```typ
#"abc".len(), 
#"香風とうふ店".len(), 
#"ã".len()
```)

你可能希望得到一个字符串的#term("codepoint width")，这时你可以组合以下方法：
#code(```typ
#"abc".codepoints().len(), 
#"香風とうふ店".codepoints().len(), 
#"ã".codepoints().len()
```)

你可能希望得到一个字符串的#term("grapheme cluster width")，这时你可以组合以下方法：
#code(```typ
#"abc".clusters().len(), 
#"香風とうふ店".clusters().len(), 
#"ã".clusters().len()
```)

#glue-block[
  #ref-method-signature("str.first")

  你可以使用#typst-func("str.first")#ref-bookmark[`method:first`\ `of str`]函数获得一个字符串的第一个#term("grapheme cluster")：

  #code(```typ
  #"Wee".first(), 
  #"我 们 俩".first(), 
  #"\u{0061}\u{0303}\u{0061}".first()
  ```)
]
#ref-method-signature("str.last")

你可以使用#typst-func("str.last")#ref-bookmark[`method:last`\ `of str`]函数获得一个字符串的最后一个#term("grapheme cluster")：

#code(```typ
#"Wee".last(), 
#"我 们 俩".last(), 
#"\u{0061}\u{0303}\u{0061}".last(), 
#"\u{0061}\u{0061}\u{0303}".last()
```)

#ref-method-signature("str.at")

你可以使用#typst-func("str.at")#ref-bookmark[`method:at`\ `of str`]函数获得一个字符串位于*字节偏移量*为`offset`的#term("grapheme cluster")：

#code(```typ
#"我 们 俩".at(0), 
#"我 们 俩".at(3),
#"我 们 俩".at(4), 
#"我 们 俩".at(8)
```)

上例中，第一个空格的字节偏移量为 $3$，“俩”的字节偏移量为 $8$ 。

#ref-method-signature("str.slice")

你可以使用#typst-func("str.slice")#ref-bookmark[`method:slice`\ `of str`]函数截取字节偏移量从`start`到`end`的子串：

#code(```typ
#repr("我 们 俩".slice(0, 11)), 
#repr("我 们 俩".slice(4, 8)),
```)

`end`参数可以省略：#ref-bookmark[`param:end`\ of `str.slice`]

#code(```typ
#repr("我 们 俩".slice(0)), 
#repr("我 们 俩".slice(4)),
```)

#ref-method-signature("str.trim")

你可以使用#typst-func("str.trim")#ref-bookmark[`method:trim`\ `of str`]去除字符串的首尾空白字符：

#code(```typ
#repr("  A  ".trim())
```)

#typst-func("str.trim")可以指定`pattern`参数。#ref-bookmark[`param:pattern`\ of `str.trim`]

#code(```typ
#repr("wwAww".trim("w"))
```)

`pattern`可以是`none`、字符串或正则表达式。当不指定`pattern`时，Typst会指定一个模式*贪婪地*去除首尾空格。

#code(```typ
#repr("  A  ".trim()),
#repr("  A  ".trim(none)),
#repr("wwAww".trim("w")),
#repr("abAde".trim(regex("[a-z]+"))),
```)

#pro-tip[
  当`pattern`参数为`none`时，Typst直接调用Rust的`trim_start`或`trim_end`方法，以默认获得更高的性能。
]

`at`参数可以为`start`或`end`，#ref-bookmark[`param:at`\ of `str.trim`]分别指定则只清除起始位置或结束位置的字符。

#code(```typ
#repr("  A  ".trim(" ", at: start)),
#repr("  A  ".trim(" ", at: end))
```)


`repeat`参数为false时，#ref-bookmark[`param:repeat`\ of `str.trim`]不会重复运行`pattern`；否则会重复运行。默认`repeat`为`true`。

#code(```typ
#repr("  A  ".trim(" ")),
#repr("  A  ".trim(" ", repeat: false))
```)

`pattern`会在起始位置或结束位置执行至少一次。

#code(```typ
#repr("  A  ".trim(" ", at: start, repeat: false)),
#repr("abAde".trim(
  regex("[a-z]"), repeat: false)),
#repr("abAde".trim(
  regex("[a-z]+"), repeat: false))
```)

#ref-method-signature("str.split")

你可以使用#typst-func("str.split")#ref-bookmark[`method:split`\ `of str`]函数将一个字符串依照空白字符拆分：

#code(```typ
#"我 们仨".split(), 
```)

#glue-block[
  #ref-method-signature("str.rev")

  你可以使用#typst-func("str.rev")#ref-bookmark[`method:rev`\ `of str`]函数将一个字符串逆转：

  #code(```typ
  #"abcdedfg".rev()
  ```)

  逆转时Typst会为你考虑#term("grapheme cluster")。

  #code(```typ
  #"ãb".rev()
  ```)
]

str.clusters, str.codepoints

str.contains, str.starts-with, str.ends-with

str.find, str.position, str.match, str.matches, str.replace

== 字典

#code(```typ
#let dict = (
  name: "Typst",
  born: 2019,
)

#dict.name \
#(dict.launch = 20)
#dict.len() \
#dict.keys() \
#dict.values() \
#dict.at("born") \
#dict.insert("city", "Berlin ")
#("name" in dict)
```)

dict.len, dict.at

dict.insert, dict.remove

dict.keys, dict.values, dict.pairs

== 数组

#code(```typ
#let values = (1, 7, 4, -3, 2)

#values.at(0) \
#(values.at(0) = 3)
#values.at(-1) \
#values.find(calc.even) \
#values.filter(calc.odd) \
#values.map(calc.abs) \
#values.rev() \
#(1, (2, 3)).flatten() \
#(("A", "B", "C")
    .join(", ", last: " and "))
```)

array.range

array.len

array.first, array.last, array.slice

array.push, array.pop, array.insert, array.remove

array.contains, array.find, array.position, array.filter

array.map, array.enumerate, array.zip, array.fold, array.sum, array.product, array.any, array.all, array.flatten, array.rev, array.split, array.join, array.intersperse, array.sorted, array.dedup
