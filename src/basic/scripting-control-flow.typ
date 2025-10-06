#import "mod.typ": *

#show: book.page.with(title: "控制流")

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


== 「作用域」 <grammar-scope>

// 内容块与代码块没有什么不同。

「作用域」是一个非常抽象的概念。但是理解他也并不困难。我们需要记住一件事，那就是每个「代码块」创建了一个单独的「作用域」：

#code(```typ
两只#{
  [兔]
  set text(rgb("#ffd1dc").darken(15%))
  { [兔白]; set text(orange); [又白] }
  [，真可爱]
}
```)

从上面的染色结果来看，粉色规则可以染色到`[兔白]`、`[又白]`和`[真可爱]`，橘色规则可以染色到`[又白]`但不能染色到[，真可爱]。以内容的视角来看：
1. `[兔]`不是相对粉色规则的后续内容，更不是相对橘色规则的后续内容，所以它默认是黑色。
2. `[兔白]`是相对粉色规则的后续内容，所以它是粉色。
3. `[又白]`同时被两个规则影响，但是根据「执行顺序」，橘色规则被优先使用。
4. `[真可爱]`虽然从代码先后顺序来看在橘色规则后面，但不在橘色规则所在作用域内，不满足「`set`」影响范围的设定。

我们说「`set`」的影响范围是其所在「作用域」内的后续内容，意思是：对于每个「代码块」，「`set`」规则只影响到从它自身语句开始，到该「代码块」的结束位置。

接下来，我们回忆：「内容块」和「代码块」没有什么不同。上述例子还可以以「内容块」的语法改写成：

#code(```typ
两只#[兔#set text(fill: rgb("#ffd1dc").darken(15%))
  #[兔白#set text(fill: orange)
  又白]，真可爱
]
```)

由于断行问题，这不方便阅读，但从结果来看，它们确实是等价的。

最后我们再回忆：文件本身是一个「内容块」。

#code(```typ
两小只，#set text(fill: orange)
真可爱
```)

针对文件，我们仍重申一遍「`set`」的影响范围。其影响等价于：对于文件本身，*顶层*「`set`」规则影响到该文件的结束位置。

#pro-tip[
  也就是说，`include`文件内部的样式不会影响到外部的样式。
]

== 变量的可变性

理解「作用域」对理解变量的可变性有帮助。这原本是上一节的内容，但是前置知识包含「作用域」，故在此介绍。

话说Typst对内置实现的所有函数都有良好的自我管理，但总免不了用户打算写一些逆天的函数。为了保证缓存计算仍较为有效，Typst强制要求用户编写的*所有函数*都是纯函数。这允许Typst有效地缓存计算，在相当一部分文档的编译速度上，快过LaTeX等语言上百倍。

你可能不知道所谓的纯函数是为何物，本书也不打算讲解什么是纯函数。关键点是，涉及函数的*纯性*，就涉及到变量的可变性。

所谓变量的可变性是指，你可以任意改变一个变量的内容，也就是说一个变量默认是可变的：

#code(```typ
#let a = 1; #let b = 2;
#((a, b) = (b, a)); #a, #b \
#for i in range(10) { a += i }; #a, #b
```)

但是，一个函数的函数体表达式不允许涉及到函数体外的变量修改：

#code(
  ```typ
  #let a = 1;
  #let f() = (a += 1);
  #f()
  ```,
  res: [#text(red, [error]): variables from outside the function are read-only and cannot be modified],
)

这是因为纯函数不允许产生带有副作用的操作。

同时，传递进函数的数组和字典参数都会被拷贝。这将导致对参数数组或参数字典的修改不会影响外部变量的内容：

#code(```typ
#let a = (1, ); #a \ // 初始值
#let add-array(a) = (a += (2, ));
#add-array(a); #a \ // 函数调用无法修改变量
#(a += (2, )); #a \ // 实际期望的效果
```)

#pro-tip[
  准确地来说，数组和字典参数会被写时拷贝。所谓写时拷贝，即只有当你期望修改数组和字典参数时，拷贝才会随即发生。
]

为了“修改”外部变量，你必须将修改过的变量设法传出函数，并在外部更新外部变量。

#code(```typ
#let a = (1, ); #a \ // 初始值
#let add-array(a) = { a.push(2); a };
#(a = add-array(a)); #a \ // 返回值更新数组
```)

#pro-tip[
  一个函数是纯的，如果：
  + 对于所有相同参数，返回相同的结果。
  + 函数没有副作用，即局部静态变量、非局部变量、可变引用参数或输入/输出流等状态不会发生变化。

  本节所讲述的内容是对第二点要求的体现。
]

== 「`set if`」语法 <grammar-set-if>

回到「set」语法的话题。假设我们脚本中设置了当前文档是否处于暗黑主题，并希望使用「`set`」规则感知这个设定，你可能会写：

#code(```typ
#let is-dark-theme = true
#if is-dark-theme {
  set rect(fill: black)
  set text(fill: white)
}

#rect([wink!])
```)

根据我们的知识，这应该不起作用，因为`if`后的代码块创建了一个新的作用域，而「`set`」规则只能影响到该代码块内后续的代码。但是`if`的`then`和`else`一定需要创建一个新的作用域，这有点难办了。

`set if`语法出手了，它允许你在当前作用域设置规则。

#code(```typ
#let is-dark-theme = true
#set rect(fill: black) if is-dark-theme
#set text(fill: white) if is-dark-theme
#rect([wink!])
```)

解读`#set rect(fill: black) if is-dark-theme`。它的意思是，如果满足`is-dark-theme`条件，那么设置相关规则。这其实与下面代码“感觉”一样。

#code(```typ
#let is-dark-theme = true
#if is-dark-theme {
  set rect(fill: black)
}
#rect([wink!])
```)

区别仅仅在`set if`语法确实从语法上没有新建一个作用域。这就好像一个“规则怪谈”：如果你想要让「`set`」规则影响到对应的内容，就想方设法满足「`set`」影响范围的要求。
