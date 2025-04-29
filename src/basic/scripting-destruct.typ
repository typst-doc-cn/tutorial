#import "mod.typ": *

#show: book.page.with(title: "解构赋值")

== 数组和字典的「解构赋值」

除了使用字面量「构造」元素，Typst还支持「构造」的反向操作：「解构赋值」。顾名思义，你可以在左侧用相似的语法从数组<grammar-destruct-array>或字典中获取值并赋值到*对应*的变量上。<grammar-destruct-dict>

#code(```typ
#let (attr: a) = (attr: [kawaii\~])
#a
```)

「解构赋值」必须一一对应，但你也可以使用「占位符」（`_`）或「延展符」（`..`）以作*部分*解构：<grammar-destruct-array-eliminate>

#code(```typ
#let (first, ..) = (1, 2, 3)
#let (.., second-last, _) = (7, 8, 9, 10)
#first, #second-last
```)

数组的「解构赋值」有一个妙用，那就是重映射内容。<grammar-array-remapping>

#code(```typ
#let (a, b, c) = (1, 2, 3)
#let (b, c, a) = (a, b, c); #a, #b, #c
```)

特别地，如果两个变量相互重映射，这种操作被称为「交换」：<grammar-array-swap>

#code(```typ
#let (a, b) = (1, 2)
#((a, b) = (b, a)); #a, #b
```)

// field access
// - dictionary
// - symbol
// - module
// - content

=== 参数解构 <grammar-destructing-param>

#todo-box[写完]
todo参数解构。
