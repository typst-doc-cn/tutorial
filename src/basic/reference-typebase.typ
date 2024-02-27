#import "mod.typ": *

#show: book.ref-page.with(title: [参考：基本类型])

Typst的基本类型设计大量参考Python和Rust。Typst基本类型的特点是半纯的API设计。其基本类型的方法倾向于保持纯度，但如果影响到了使用的方便性，Typst会适当牺牲纯度。

如下所示，`array.push`就是带有副作用的：

#code(```typ
#let t = (1, 2)
#t.push(3)
#t
```)

== 整数

A whole number. #ref-bookmark[`integer`]

The number can be negative, zero, or positive. As Typst uses 64 bits to store integers, integers cannot be smaller than $-2^63$ or larger than $2^63-1$.

The number can also be specified as hexadecimal, octal, or binary by starting it with a zero followed by either x, o, or b.

You can convert a value to an integer with this type's constructor.

#code(```typ
#(1 + 2) \
#(2 - 5) \
#(3 + 4 < 8)

#0xff \
#0o10 \
#0b1001
```)

Converts a value to an integer. #ref-bookmark[`#/constructor`]

- Booleans are converted to $0$ or $1$.
- Floats are floored to the next $64$-bit integer.
- Strings are parsed in base $10$.

#code(```typ
#int(false) \
#int(true) \
#int(2.7) \
#(int("27") + int("4"))
```)

等待calculation函数refactor

== 浮点数

A floating-point number. #ref-bookmark[float]

A limited-precision representation of a real number. Typst uses 64 bits to store floats. Wherever a float is expected, you can also pass an integer.

You can convert a value to a float with this type's constructor.

#code(```typ
#3.14 \
#1e4 \
#(10 / 4)
```)

Converts a value to a float.

- Booleans are converted to 0.0 or 1.0.
- Integers are converted to the closest 64-bit float.
- Ratios are divided by 100%.
- Strings are parsed in base 10 to the closest 64-bit float. Exponential notation is supported.

#code(```typ
#float(false) \
#float(true) \
#float(4) \
#float(40%) \
#float("2.7") \
#float("1e5")
```)

等待calculation函数refactor

== 字符串

#code(```typ
#"hello world!" \
#"\"hello\n  world\"!" \
#"1 2 3".split() \
#"1,2;3".split(regex("[,;]")) \
#(regex("\d+") in "ten euros") \
#(regex("\d+") in "10 euros")
```)

str.len, str.first, str.last, str.at, str.slice

str.trim, str.split, str.rev, str.to-unicode, str.from-unicode

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
