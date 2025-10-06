#import "mod.typ": *

#show: book.page.with(title: "复合类型")

学会了数组和字典，我们就解锁了各种新技能。

== 数组字面量 <grammar-array-literal>

脚本模式中有两类核心复合字面量。一曰「数组」，一曰「字典」。

「数组」是按照顺序存储的一些「值」，你可以在「数组」中存放*任意内容*而不拘泥于类型。你可以使用圆括号与一个逗号分隔的列表创建一个*数组字面量*：

#code(```typ
#(1, "OvO", [一段内容])
```)

== 字典字面量 <grammar-dict-literal>

所谓「字典」即是「键值对」的集合，其每一项是由冒号分隔的「键值对」。如下例所示，冒号左侧，“neco-mimi”等「标识符」或「字符串」是字典的「键」，而冒号右侧分别是对应的「值」。

#code(```typ
#(neko-mimi: 2, "utterance": "喵喵喵")
```)

== 数组和字典的典型构造

特别讲解一些关于数组与字典相关的典型构造：

#code(```typ
#() \ // 是空的数组
#(:) \ // 是空的字典
#(1) \ // 被括号包裹的整数1
#(()) \ // 被括号包裹的空数组
#((())) \ // 被括号包裹的被括号包裹的空数组
#(1,) \ // 是含有一个元素的数组
```)

`()`是空的数组<grammar-empty-array>，不含任何值。`(:)`是空的字典<grammar-empty-dict>，不含任何键值对。

如果括号内含了一个值，例如`(1)`，那么它仅仅是被括号包裹的整数1，仍然是整数1本身。

类似的，`(())`是被括号包裹的空数组<grammar-paren-empty-array>，`((()))`是被括号包裹的被括号包裹的空数组。

为了构建含有一个元素的数组，需要在列表末尾额外放置一个逗号以示区分，例如`(1,)`。<grammar-single-member-array>

// https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Trailing_commas
这种逗号被称为尾后逗号。

// todo: 改进
构造数组字面量时，允许尾随一个多余的逗号而不造成影响。

#code(```typ
#let x = (1, "OvO", [一段内容] , ); #x
//          这里有一个多余的逗号^^^
```)

构造字典字面量时，允许尾随一个多余的逗号。

#code(```typ
#let cat = (attribute: [kawaii\~], ); #cat
//             这里有一个尾随的小逗号^^
```)

== 数组和字典的「解构赋值」

这是本节最难的内容，非程序员朋友想要灵活运用可能有点困难。

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

== 数组和字典的成员访问

为了访问数组，你可以使用`at`方法。“at”在中文里是“在”的意思，它表示对「数组」使用「索引」操作。`at(0)`索引到第1个值，`at(n)`索引到第 $n + 1$ 个值，以此类推。如下所示：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x.at(0), #x.at(1), #x.at(2)
```)

至于「索引」从零开始的原因，这只是约定俗成。等你习惯了，你也会变成计数从零开始的好程序员。

为了访问字典，你可以使用`at`方法。但由于「键」都是字符串，你需要使用字符串作为字典的「索引」。

#code(```typ
#let cat = (attribute: [kawaii\~])
#cat.at("attribute")
```)

为了方便，Typst允许你直接通过成员方法访问字典对应「键」的值： <grammar-dict-member-exp>

#code(```typ
#let cat = ("attribute": [kawaii\~])
#cat.attribute
```)

== 数组和字典的「存在谓词」

为了访问数组，你可以使用`contains`方法。“contain”在中文里是“包含”的意思，如下所示：

#code(```typ
#let x = (1, "OvO", [一段内容])
#x.contains[一段内容]
```)

因为这太常用了，typst专门提供了`in`语法，表示判断`x`是否*存在于*某个数组中：<grammar-array-in>

#code(```typ
#([一段内容] in (1, "OvO", [一段内容])) \
#([另一段内容] in (1, "OvO", [一段内容]))
```)

字典也可以使用此语法，表示判断`x`是否是字典的一个「键」。特别地，你还可以前置一个`not`判断`x`是否*不在*某个数组或字典中：<grammar-dict-in>

#code(```typ
#let cat = (neko-mimi: 2)
#("neko-kiki" not in cat)
```)

注意：`x in (...)`与`"x" in (...)`是不同的。例如`neko-mimi in cat`将检查`neko-mimi`变量的内容是否是字典变量`cat`的一个「键」，而`"neko-mimi"`检查对应字符串是否在其中。

// field access
// - dictionary
// - symbol
// - module
// - content

== 位置参数声明 <grammar-positional-param>

typst通过数组和字典在执行时向函数传递参数。上一节我们学会了基本的函数声明，若进一步理解了数组和字典，可以定义更复杂的函数。接下来我们讲透Typst中如何声明复杂函数，以及如何调用函数。

其中最简单的是位置参数声明，我们在上节已经学过。

#code(```typ
#let f(a, b) = [两个值#(a)和#(b)偷偷混入了我们内容之中。]
#f(1, 2)
```)

在函数调用的时候，位置参数必须按照声明的顺序传递。例子中，向`f`函数传递了两个位置参数`1`和`2`，于是`a`和`b`作为变量被赋值为了`1`和`2`，接着这个函数返回一个「内容块」，其中用到了`a`和`b`变量。

== 具名参数声明 <grammar-named-param>

函数可以包含「具名参数」，其看起来就像字典的一项，冒号右侧则是参数的*默认值*：

#code(```typ
#let g(name: "？") = [你是#name]
#g(/* 不传就是问号 */); #g(name: "OwO。")
```)

== 变长参数 <grammar-variadic-param>

函数可以包含「变长参数」。

#code(```typ
#let g(..args) = [很多个值，#args.pos().join([、])，偷偷混入了我们内容之中。]
#g([一个俩个], [仨个四个], [五六七八个])
```)

```typc args```的类型是`arguments`。
+ 使用`args.pos()`得到传入的位置参数数组；使用`args.named()`得到传入的具名参数字典。
+ 使用`args.at(i)`访问索引为整数`i`的位置参数；使用`args.at(name)`访问名称为字符串`name`的具名参数。

== 参数类型 <grammar-param-literal>

什么是「参数类型」（argument type）？在typst中，你完全可以先把函数参数准备好，然后直接调用函数：

#code(```typ
#let sum(..args, init: 0) = init + args.pos().sum()
#let args = arguments(1, 2)
#sum(..args) // 3
```)

`arguments`是一个类型，`arguments(1, 2)`是一个表达式，它返回一个`arguments`类型的值。

也可以预先传递参数，然后直接调用函数：

#code(```typ
#let sum(..args, init: 0) = init + args.pos().sum()
#let args = arguments((1,), (2,), init: ())
#sum(..args) // (1, 2)
```)

=== 参数解构 <grammar-destructing-param>

#todo-box[写完]
todo参数解构。

#todo-box[引言]
