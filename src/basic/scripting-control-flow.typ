#import "mod.typ": *

#show: book.page.with(title: "控制流")

#pro-tip[
  Typst借鉴了Rust，遵从「面向表达式编程」（expression-oriented programming）的哲学。它将所有的语句都根据可折叠规则（见后文）设计为表达式。
  + 如果一个语句能产生值，那么该语句的结果是按*控制流*顺序所产生所有值的折叠。
  + 否则，如果一个语句不能产生值，那么该语句的结果是```typc none```。
  + 特别地，任意类型 $T$ 的值 $v$ 与```typc none```折叠仍然是值本身。
  $ forall v in T union {"none"}, op("fold")_T (v, "none") = v $
]

== `none`类型和`if`语句 <grammar-if>

默认情况下，在逻辑上，Typst按照顺序执行执行你的代码，即先执行前面的语句，再执行后面的语句。开发者如果想要控制程序执行的流程，就必须使用流程控制的语法结构，主要是条件执行和循环执行。

`if`语句用于条件判断，满足条件时，就执行指定的语句。

```typ
#if expression { then-block } else { else-block }
#if expression { then-block }
```

上面式子中，表达式`expression`为真（值为布尔值`true`）时，就执行`then-block`代码块，否则执行`else-block`代码块。特别地，`else`可以省略。

如下所示：

#code(```typ
#if (1 < 2) { "确实" } else { "啊？" }
```)

因为`1 < 2`表达式为真，所以脚本仅执行了`then-block`代码块，于是最后文档的内容为“确实”。

`if`语句还可以无限串联下去，你可以自行类比推理更长的`if`语句的语义：<grammar-if-if>

```typ
#if expression { .. } else if expression { .. } else { .. }
#if expression { .. } else if expression { .. }
#if expression { .. } else if expression { .. } else if ..
```
如果只写了`then`代码块，而没写`else`代码块，但偏偏表达式不为真，最终脚本会报错吗？请看：

#code(```typ
#repr(if (1 > 2) { "啊？" })
```)

当`if`表达式没写`else`代码块而条件为假时，结果为`none`。“none”在中文里意思是“无”，表示“什么都没有”。同时再次强调`none`在「可折叠」的值中很重要的一个性质：`none`在折叠过程中被忽略。

见下程序，其根据数组所包含的值输出特定字符串：

#code(```typ
#let 查成分(成分数组) = {
  "是个"
  if "A" in 成分数组 or "C" in 成分数组 or "G" in 成分数组 { "萌萌" }
  if "T" in 成分数组 { "工具" }
  "人"
}

#查成分(()) \
#查成分(("A","T",)) \
```)

由于`if`也是表达式，你可以直接将`if`作为函数体，例如fibnacci函数的递归可以非常简单：

#code(```typ
#let fib(n) = if n <= 1 { n } else {
  fib(n - 1) + fib(n - 2)
}
#fib(46)
```)

== `while`语句 <grammar-while>

// if condition {..}
// if condition [..]
// if condition [..] else {..}
// if condition [..] else if condition {..} else [..]

`while`语句用于循环结构，满足条件时，不断执行循环体。

```typ
#while expression { cont-block }
```

上面代码中，如果表达式`expression`为真，就会执行`cont-block`代码块，然后再次判断`expression`是否为假；如果`expression`为假就跳出循环，不再执行循环体。

#code(```typ
#let i = 0;
#while i < 10 { (i * 2, ); i += 1 }
```)

上面代码中，循环体会执行`10`次，每次将`i`增加`1`，直到等于`10`才退出循环。

== `for`语句 <grammar-for>

`for`语句也是常用的循环结构，它迭代访问某个对象的每一项。

```typ
#for X in A { cont-block }
```

上面代码中，对于`A`的每一项，都执行`cont-block`代码块。在执行`cont-block`时，项的内容是`X`。例如以下代码做了与之前循环相同的事情：

#code(```typ
#for i in range(10) { (i * 2, ) }
```)

其中`range(10)`创建了一个内容为`(0, 1, 2, .., 9)`一共10个值的数组。

== 使用内容块替代代码块

所有可以使用代码块的地方都可以使用内容块作为替代。

#code(```typ
#for i in range(4) [阿巴]......
```)

== 使用`for`遍历字典

与数组相同，同理所有字典也都可以使用`for`遍历。此时，在执行`cont-block`时，Typst将每个键值对以数组的形式交给你。键值对数组的第0项是键，键值对数组的第1项是对应的值。

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#for i in cat {
  [猫猫的 #i.at(0) 是 #i.at(1)\ ]
}
```)

你可以同时使用「解构赋值」让代码变得更容易阅读：<grammar-for-destruct>

```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#for (特色, 这个) in cat [猫猫的 #特色 是 #这个\ ]
```

== `break`语句和`continue`语句 <grammar-break>

无论是`while`还是`for`，都可以使用`break`跳出循环，或`continue`直接进入下一次执行。

基于以下`for`循环，我们探索`break`和`continue`语句的作用。

#code(```typ
#for i in range(10) { (i, ) }
```)

在第一次执行时，如果我们直接使用`break`跳出循环，但是在break之前就已经产生了一些值，那么`for`的结果是`break`前的那些值的「折叠」。

#code(```typ
#for i in range(10) { (i, ); (i + 1926, ); break }
```)

特别地，如果我们直接使用`break`跳出循环，那么`for`的结果是*`none`*。

#code(```typ
#for i in range(10) { break }
```)

在`break`之后的那些值将会被忽略：

#code(```typ
#for i in range(10) { break; (i, ); (i + 1926, ); }
```)

以下代码将收集迭代的所有结果，直到`i >= 5`：
#code(```typ
#for i in range(10) {
  if i >= 5 { break }
  (i, )
}
```)

// #for 方位 in ("东", "南", "西", "北", "中", "间", "东北", "西北", "东南", "西南") [鱼戏莲叶#方位，]

`continue`有相似的规则，便不再赘述。我们举一个例子，以下程序输出在`range(10)`中不是偶数的数字：<grammar-continue>

#code(```typ
#let 是偶数(i) = calc.even(i)
#for i in range(10) {
  if 是偶数(i) { continue }
  (i, )
}
```)

事实上`break`语句和`continue`语句还可以在参数列表中使用，但本书非常不推荐这些写法，因此也不多做介绍：

#code(```typ
#let add(a, b, c) = a + b + c
#while true { add(1, break, 2) }
```)

== 控制函数返回值

你可以通过多种方法控制函数返回值。

=== 占位符 <grammar-placeholder>

早在上节我们就学习过了占位符，这在编写函数体表达式的时候尤为有用。你可以通过占位符忽略不需要的函数返回值。

以下函数获取数组的倒数第二个元素：

#code(```typ
#let last-two(t) = {
  let _ = t.pop()
  t.pop()
}
#last-two((1, 2, 3, 4))
```)

=== `return`语句 <grammar-return>

你可以通过`return`语句忽略表达式其余*所有语句*的结果，而使用`return`语句返回特定的值。

以下函数获取数组的倒数第二个元素：

#code(```typ
#let last-two(t) = {
  t.pop()
  return t.pop()
}
#last-two((1, 2, 3, 4))
```)
