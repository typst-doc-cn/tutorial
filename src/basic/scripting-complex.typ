#import "mod.typ": *

#show: book.page.with(title: "复合字面量、控制流和复杂函数")

== Hello World程序改

有的时候，我们想要访问字面量、变量与函数中存储的“信息”。例如，给定一个字符串```typc "Hello World"```，我们想要截取其中的第二个单词。

单词`World`就在那里，但仅凭我们有限的脚本知识，却没有方法得到它。这是因为字符串本身是一个整体，虽然它具备单词信息，我们却缺乏了*访问*信息的方法。

Typst为我们提供了「成员」和「方法」两种概念访问这些信息。使用「方法」，可以使用以下脚本完成目标：

#code(```typ
#"Hello World".split(" ").at(1)
```)

为了方便讲解，我们改写出6行脚本。除了第二行，每一行都输出一段内容：

#code(```typ
#let x = "Hello World"; #x \
#let split = str.split
#split(x, " ") \
#str.split(x, " ") \
#x.split(" ") \
#x.split(" ").at(1)
```)

从```typ #x.split(" ").at(1)```的输出可以看出，这一行帮助我们实现了“截取其中的第二个单词”的目标。我们虽然隐隐约约能揣测出其中的意思：

```typ
#(       x .split(" ")           .at(1)          )
// 将字符串 根据字符串拆分  取出其中的第2个单词（字符串）
```

但至少我们对#mark(".")仍是一无所知。

本节我们就来讲解Typst中较为高级的脚本语法。这些脚本语法与大部分编程语言的语法相同，但是我们假设你并不知道这些语法。

== 成员 <grammar-member-exp>

Typst提供了一系列「成员」和「方法」访问字面量、变量与函数中存储的“信息”。

其实在上一节（甚至是第二节），你就已经见过了「成员」语法。你可以通过「点号」，即```typc `OvO`.text ```，获得代码块的“text”（文本内容）：

#code(```typ
这是一个代码块内容：#repr(`OvO`)

这是一段文本：#repr(`OvO`.text)
```)

每个类型有哪些「成员」是由Typst决定的。你需要逐渐积累经验以知晓这些「成员」的分布，才能更快地通过访问成员快速编写出收集和处理信息的脚本。(todo: 建议阅读)

当然，为防你不知道，大家不都是死记硬背的：有软件手段帮助你使用这些「成员」。本人在此提醒你：可以安装一个带LSP的编辑器，例如VSCode。当你对某个对象后接一个点号时，编辑器会自动为你做代码补全。(todo：搭建环境)

#figure(image("./IDE-autocomplete.png", width: 120pt), caption: [作者使用编辑器作代码补全的精彩瞬间。])

从图中可以看出来，该代码片段对象上有七个「成员」。特别是“text”成员赫然立于其中，就是它了。除了「成员」列表，编辑器还会告诉你每个「成员」的作用，以及如何使用。这时候只需要选择一个「成员」作为补全结果即可。

== 方法 <grammar-method-exp>

「方法」是一种特殊的「成员」。准确来说，如果一个「成员」是一个对象的函数，那么它就被称为该对象的「方法」。

统一来看Hello World程序的第三行、第四行与第五行脚本。它们输出了相同的内容，事实上，它们是*同一*「函数调用」的不同写法：

#code(```typ
#let x = "Hello World"
#let str-split = str.split
#str-split(x, " ") \
#str.split(x, " ") \
#x.split(" ")
```)

第三行脚本含义对照如下。之前已经学过，这正是「函数调用」的语法：

```typ
#(        str-split(         x,  " "   ))
// 调用  字符串拆分函数，参数为 变量x和空格
```

观察第三行与第四行脚本：

#(```typ
#str-split(x, " ") \
#str.split(x, " ") \
```)

从`str-split`的「变量声明」可以推断：第四行脚本仍然是在做「函数调用」，只不过在语法上更为紧凑。

第五行脚本的写法则更加简明。

#(```typ
#x.split(" ")
```)

约定`str.split(x, y)`可以简写为`x.split(y)`，如果：
+ 对象`x`是`str`类型，且方法`split`是`str`类型的「成员」。
+ 对象`x`用作`str.split`调用的第一个参数。

这种写法可以进一步推及其他类型和类型的方法，被称为「方法调用」，即一种特殊的「函数调用」，是一个在各编程语言中广泛存在的简写规则。

「方法调用」大大简化了脚本。当然你也可以选择不用「方法调用」，毕竟你可以看到「函数调用」一样可以完成所有任务。

#pro-tip[
  这里有一个问题：为什么Typst要引入「方法」的概念呢？主要有以下几点考量。

  其一，为了引入「方法调用」的语法，这种语法相对要更为方便和易读。对比以下两行，它们都完成了获取`"Hello World"`字符串的第二个单词的第一个字母的功能：

  #code(```typ
  #"Hello World".split(" ").at(1).split("").at(1)

  #array.at(str.split(array.at(
    str.split("Hello World", " "), 1), ""), 1)
  ```)

  可以明显看见，第一行脚本全部写在一行还能很方便地阅读，但第二行语句的参数已经散落在括号的里里外外，很难理解到底做了什么事情。

  其二，相比「函数调用」，「方法调用」更有利于现代IDE补全脚本。如果你使用了带脚本自动补全的编辑器，当你在`"Hello World"`字符串后敲下一个「点号」时，IDE会自动联想你接下来可能需要与“字符串”相关的函数，你便可以通过`.split`很快定位到“字符串拆分”这个函数。

  与之相对，「函数调用」的“筛选效率”更低。若想调用`str-split`或`str.split`，你首先需要敲下一个`s`字符，很快编辑器就会把所有以`s`开头的函数都告诉你了，这可就有点头疼了。

  其三，方便用户管理相似功能的函数。你很快就可以联想到，不仅仅是字符串可以拆分，似乎内容也可以拆分。不仅如此，将来可能还有各种各样的拆分。如果需要为他们都取不同的名字，那可就太头疼了。相比`str.split`就简单多了。要知道，程序员最讨厌给变量和函数想命名这种东西了。
]

接下来只需要理解最后一行脚本，就能彻底搞懂这个Hello World程序了。看起来，它也是某种类型上的某个「方法」。

#code(```typ
#let x = "Hello World".split(" ")
#x.at(1)
```)

若需要理解最后一行，则需引入「数组」的概念。

== 数组字面量 <grammar-array-literal>

脚本模式中有非常重要的复合字面量，它们是「数组」和「字典」。

「数组」是按照顺序存储的一些「值」，你可以在「数组」中存放*任意内容*而不拘泥于类型。你可以使用圆括号与一个逗号分隔的列表创建一个*数组字面量*：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x
```)

构造数组字面量时，允许尾随一个多余的逗号而不造成影响。

#code(```typ
#let x = (1, "OvO", [一段内容] , )
//          这里有一个多余的逗号^^^
#x
```)

为了访问数组，你可以使用`at`方法。“at”在中文里是“在”的意思，它表示对「数组」使用「索引」操作。在数组中，第0个值就是字面量声明中的第一个值，第1个值就是字面量声明中的第二个值，以此类推。如下所示：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x.at(0) \
#x.at(1) \
#x.at(2)
```)

至于为什么「索引」从零开始，这只是一个约定俗成。相信等你习惯了，你也会变成计数从零开始的好程序员。

与数组相关的另一个重要语法是`in`，`x in (...)`，表示判断`x`是否在某个数组中：<grammar-array-in>

#code(```typ
#(1 in (1, "OvO", [一段内容])) \
#([一段内容] in (1, "OvO", [一段内容])) \
#([另一段内容] in (1, "OvO", [一段内容]))
```)

同时，你还可以使用语法`not in`判断`x`是否*不在*某个数组中：<grammar-array-not-in>

#code(```typ
#(1 not in (1, "OvO", [一段内容])) \
#([另一段内容] not in (1, "OvO", [一段内容]))
```)

== 回顾示例

回顾Hello World程序：

#code(```typ
#let x = "Hello World".split(" ")
#x \
#x.at(1)
```)

含义不言而喻：使用空格拆分字符串可以得到两个单词，使用`at`方法，当「索引」参数为1的时候，就取出了其中的第二个元素，即`"Hello World"`字符串中的第二个单词。

== 字典字面量 <grammar-dict-literal>

与「数组」同理，你可以使用圆括号与一个逗号分隔的列表创建一个*字典字面量*。与数组略微不同的是，列表的每一项是由冒号分隔的「键值对」。

所谓「字典」即是「键值对」的集合。如下例所示，“neco-mimi”、“utterance”和“attribute”是字典的「键」，它们必须是字符串。而`2`、`"喵喵喵"`和`[kawaii\~]`分别是对应的「值」。

#code(```typ
#let cat = (
  neko-mimi: 2,
  "utterance": "喵喵喵",
  attribute: [kawaii\~]
)
#cat
```)

构造字典字面量时，允许尾随一个多余的逗号而不造成影响。

#code(```typ
#let cat = (
  neko-mimi: 2,
  "utterance": "喵喵喵",
  attribute: [kawaii\~] ,
//   这里有一个尾随的小逗号^^^
)
#cat
```)

为了访问字典，你可以使用`at`方法。但由于「键」都是字符串，你需要使用字符串作为字典的「索引」。

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#cat.at("neko-mimi") \
#cat.at("utterance") \
#cat.at("attribute")
```)

为了方便，Typst允许你直接通过成员方法访问字典对应「键」的值： <grammar-dict-member-exp>

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵")
// 等价于cat.at("neko-mimi")
#cat.neko-mimi \ 
// 等价于cat.at("utterance")
#cat.utterance
```)

与数组类似，字典也可以使用相关的另一个重要语法是`in`，`x in (...)`，表示判断`x`是否是字典的一个「键」：<grammar-dict-in>

#code(```typ
#let cat = (neko-mimi: 2)
#("neko-mimi" in cat)
```)

注意：`x in (...)`与`"x" in (...)`是不同的。例如`neko-mimi in cat`将检查`neko-mimi`变量的内容是否是字典变量`cat`的一个「键」，而`"neko-mimi"`检查对应字符串是否在其中。

== 数组和字典字面量典例

讲解一些关于数组与字典字面量相关的典例：

#code(```typ
#() \ // 是空的数组
#(:) \ // 是空的字典
#(1) \ // 被括号包裹的整数1
#(()) \ // 被括号包裹的空数组
#((())) \ // 被括号包裹的被括号包裹的空数组
#(1,) \ // 是含有一个元素的数组
```)

`()`是空的数组<grammar-empty-array>，不含任何值；如果你想构建空的字典，需要中置一个冒号，`(:)`是空的字典<grammar-empty-dict>，不含任何键值对。

如果括号内含了一个值，而无法与数组区分，例如`(1)`，那么它仅仅是被括号包裹的整数1，仍然是整数1本身。

类似的，`(())`是被括号包裹的空数组<grammar-paren-empty-array>，`((()))`是被括号包裹的被括号包裹的空数组。

如果你想构建含有一个元素的数组，需要在列表末尾放置一个额外的逗号以区分括号语法，例如`(1,)`。<grammar-single-member-array>

== 数组和字典的「解构赋值」

除了使用字面量「构造」元素，Typst还支持「构造」的反向操作：「解构赋值」。顾名思义，你可以在左侧用相似的语法从数组<grammar-destruct-array>或字典中获取值并赋值到*对应*的变量上。<grammar-destruct-dict>

#code(```typ
#let x = (1, "Hello, World", [一段内容])
#let (one, hello-world, a-content) = x
#one \
#hello-world \
#a-content
```)

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#let (utterance: u, attribute: a) = cat
#u \
#a
```)

数组的「解构赋值」必须一一解构，如果数组包含10项，则你必须解构出10个变量。否则，如果只想解构其中一部分值，可以尾随一个「延展符」（`..`），以示省略：<grammar-destruct-array-eliminate>

#code(```typ
#let (first, ..) = (1, "Hello, World", [一段内容])
#first \
#let (_, second, ..) = (1, "Hello, World!!!", [一段内容])
#second \
#let (attribute: a, ..) = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#a
```)

数组的「解构赋值」有一个妙用，那就是重映射内容。<grammar-array-remapping>

#code(```typ
#let a = 1; #let b = 2; #let c = 3
#let (b, c, a) = (a, b, c)
#a, #b, #c
```)

特别地，如果两个变量相互重映射，这种操作被称为「交换」：<grammar-array-swap>

#code(```typ
#let a = 1; #let b = 2
#((a, b) = (b, a))
#a, #b
```)

从如下脚本，你可以更好地体会到「构造」与「解构赋值」互为相反操作的含义：

#code(```typ
#let (one, hello-world,    a-content) = {
     (1,   "Hello, World", [一段内容])
}
#one \
#hello-world \
#a-content
```)

// field access
// - dictionary
// - symbol
// - module
// - content

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
#(1 < 2) \
#if (1 < 2) { "确实" } else { "啊？" }
```)

因为`1 < 2`表达式为真，所以脚本执行了`then-block`代码块，而忽略了`else-block`代码块，于是最后文档的内容为“确实”。

`if`语句还可以无限串联下去，你可以自行类比推理更长的`if`语句的语义：<grammar-if-if>

```typ
#if expression { .. } else if expression { .. } else { .. }
#if expression { .. } else if expression { .. }
#if expression { .. } else if expression { .. } else if ..
```

这里有一个疑问，如果只写了`then`代码块，而没写`else`代码块，但偏偏表达式不为真，最终脚本会报错吗？请看：

#code(```typ
#if (1 > 2) { "啊？" }
```)

虽然很合理，但是为了学到更多知识，我们用`repr`一探究竟：

#code(```typ
#repr(if (1 > 2) { "啊？" })
```)

当`if`表达式没写`else`代码块而条件为假时，结果为`none`。“none”在中文里意思是“无”，“什么都没有”。同时再次强调`none`在「可折叠」的值中很重要的一个性质：`none`在折叠过程中被忽略。

见下程序，其根据数组所包含的值输出特定字符串：

#code(```typ
#let 查成分(成分数组) = {
  "是个"
  if "A" in 成分数组 { "萌萌" }
  if "C" in 成分数组 { "萌萌" }
  if "G" in 成分数组 { "萌萌" }
  if "T" in 成分数组 { "工具" }
  "人"
}

#查成分(())

#查成分(("A","C",))

#查成分(("A","T",))
```)

由于`if`也是表达式，你可以直接将`if`作为函数体，例如fibnacci函数的递归可以非常简单：

#code(```typ
#let fib(n) = if n <= 1 {
  n
} else {
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
#while expression { CONT }
```

上面代码中，如果表达式`expression`为真，就会执行`CONT`代码块，然后再次判断`expression`是否为假；如果`expression`为假就跳出循环，不再执行循环体。

#code(```typ
#{
  let i = 0;
  while i < 10 {
    (i * 2, )
    i += 1;
  }
}
```)

上面代码中，循环体会执行`10`次，每次将`i`增加`1`，直到等于`10`才退出循环。

== `for`语句 <grammar-for>

`for`语句也是常用的循环结构，它迭代访问某个对象的每一项。

```typ
#for X in A { CONT }
```

上面代码中，对于`A`的每一项，都执行`CONT`代码块。在执行`CONT`时，项的内容是`X`。例如以下代码做了与之前循环相同的事情：

#code(```typ
#for i in range(10) {
  (i * 2, )
}
```)

其中`range(10)`创建了一个内容为`(0, 1, 2, ..., 9)`一共10个值的的数组。

所有的数组都可以使用`for`遍历，同理所有字典也都可以使用`for`遍历。在执行`CONT`时，项的内容是键值对，而Typst将用一个数组代表这个键值对，交给你。键值对数组的第0项是键，键值对数组的第1项是对应的值。

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#for i in cat {
  [猫猫的 #i.at(0) 是 #i.at(1)\ ]
}
```)

你可以同时使用「解构赋值」让代码变得更容易阅读：<grammar-for-destruct>

#code(```typ
#let cat = (neko-mimi: 2, "utterance": "喵喵喵", attribute: [kawaii\~])
#for (特色, 这个) in cat {
  [猫猫的 #特色 是 #这个\ ]
}
```)

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

== 变量的可变性

Typst对内置实现的所有函数都有良好的自我管理，但总免不了用户打算写一些逆天的函数。为了保证缓存计算仍较为有效，Typst强制要求用户编写的*所有函数*都是纯函数。这允许Typst有效地缓存计算，在相当一部分文档的编译速度上，快过LaTeX等语言上百倍。

你可能不知道所谓的纯函数是为何物，本书也不打算讲解什么是纯函数。关键点是，涉及函数的*纯性*，就涉及到变量的可变性。

相比纯函数，变量的可变性就要好懂多了。

你可以任意改变一个变量的内容，也就是说一个变量默认是可变的：

#code(```typ
#let a = 1; #let b = 2;
#((a, b) = (b, a))
#a, #b \
#for i in range(10) { a += i }
#a, #b
```)

但是，一个函数的函数体表达式不允许涉及到函数体外的变量修改：

#code(```typ
#let a = 1;
#let f() = (a += 1);
// 调用将会产生报错，无法修改`a`变量：
// #f()
```)

这是因为纯函数不允许产生带有副作用的操作。

同时，传递进函数的数组和字典参数都会被拷贝。这将导致对参数数组或参数字典的修改不会影响外部变量的内容：

#code(```typ
#let a = (1, );
#let add-array(a) = (a += (2, ));
#a \ // 初始值
#add-array(a);
#a \ // 函数调用后不发生任何变化
#(a += (2, ));
#a \ // 期望a += (2, )的效果
```)

#pro-tip[
  准确地来说，数组和字典参数会被写时拷贝。所谓写时拷贝，即只有当你期望修改数组和字典参数时，拷贝才会随即发生。
]

为了“修改”外部变量，你必须将修改过的变量设法传出函数，并在外部更新外部变量。

#code(```typ
#let a = (1, );
#let add-array(a) = {
  a += (2, )
  return a
};
#a \ // 初始值
#(a = add-array(a));
#a \ // 返回值更新数组
```)

#pro-tip[
  一个函数是纯的，如果：
  + 对于所有相同参数，返回相同的结果。
  + 函数没有副作用，即局部静态变量、非局部变量、可变引用参数或输入/输出流等状态不会发生变化。

  本节所讲述的内容是对第二点要求的体现。
]

== 函数闭包 <grammar-closure>

函数的闭包是一个很有用的语法。上一节我们学习了简单函数的「函数声明」。现在我们对照「函数声明」学习「闭包声明」。一个简单的「闭包」如下：

#code(```typ
#let f = (x, y) => [两个值#(x)和#(y)偷偷混入了我们内容之中。]
#f("a", "b")
```)

其中「闭包」是以下表达式：

```typc
    (x, y) => [两个值#(x)和#(y)偷偷混入了我们内容之中。]
// 参数列表     函数体表达式
```

「闭包」是一类特殊的函数。其主要特点是不需要指定函数名标识符。

「闭包」很适合用来作为参数传入其他函数，即作为「回调」函数。我们将会在下一章经常使用「回调」函数。

例如，Typst提供一个`locate`函数。其接受一个函数参数。你可以使用「函数声明」：

#code(```typ
#let f(loc) = [
  当前页面为#loc.page()。
]
#locate(f)
```)

但是，等价地，「函数声明」在这种情况下不如「闭包声明」优美：

#code(```typ
#locate(loc => [
  当前页面为#loc.page()。
])
```)

== 具名参数声明 <grammar-named-param>

「函数声明」和「闭包声明」都允许包含「具名参数」。「具名参数」需要指定默认值：

#code(```typ
#let g(some-arg: none) = [很多个值，#some-arg，偷偷混入了我们内容之中。]
#g()
#g(some-arg: "OwO")
```)

todo: 完善

== 含变参函数和Argument类型 <grammar-variadic-param>

「函数声明」和「闭包声明」都允许包含「变长参数」。

#code(```typ
#let g(..args) = [很多个值，#args.pos().join([、])，偷偷混入了我们内容之中。]
#g([一个俩个], [仨个四个], [五六七八个])
```)

```typc args.pos()```的类型是`Argument`。
+ 使用`args.pos()`得到按顺序传入的参数
+ 使用`args.at(name)`访问名称为`name`的具名参数。

todo: 完善

== 总结

Typst如何保证一个简单函数甚至是一个闭包是“纯函数”？

答：1. 禁止修改外部变量，则捕获的变量的值是“纯的”或不可变的；2. 折叠的对象是纯的，且「折叠」操作是纯的。

Typst的多文件特性从何而来？

答：1. import函数产生一个模块对象，而模块其实是文件顶层的scope。2. include函数即执行该文件，获得该文件对应的内容块。

基于以上两个特性，Typst为什么快？

+ Typst支持增量解析文件。
+ Typst所有由*用户声明*的函数都是纯的，在其上的调用都是纯的。例如Typst天生支持快速计算递归实现的fibnacci函数：

  #code(```typ
  #let fib(n) = if n <= 1 { n } else { fib(n - 1) + fib(n - 2) }
  #fib(42)
  ```)
+ Typst使用`include`导入其他文件的顶层「内容块」。当其他文件内容未改变时，内容块一定不变，而所有使用到对应内容块的函数的结果也一定不会因此改变。

这意味着，如果你发现了Typst中与一般语言的不同之处，可以思考以上种种优势对用户脚本的增强或限制。

基于《复合字面量、控制流和复杂函数》掌握的知识你应该可以：
+ 阅读基本参考部分中的所有内容
