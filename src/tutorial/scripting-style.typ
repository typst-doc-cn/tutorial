#import "mod.typ": *

#show: book.page.with(title: "样式模型")

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

== 「样式化」内容

当我们有一个`repr`玩具的时候，总想着对着各种各样的对象使用`repr`。我们在上一节讲解了「`set`」和「`show`」语法。现在让我们稍微深挖一些。

「`set`」是什么？先`repr`一下：

#code(```typ
#repr({
  [a]; set text(fill: blue); [b]
})
```)

「`show`」是什么？也`repr`一下：

#code(```typ
#repr({
  [b]; show raw: set text(fill: red)
  [a]
})
```)

我们知道`set text(fill: blue)`近似于`show: set text(fill: blue)`的简写，因此「`set`」语法和「`show`」语法都可以统合到第二个例子来理解。

对于第二个例子，我们发现`show`语句之后的内容都被重新包裹在`styled`元素中。虽然我们不知道`styled`做了什么事情，但是简单的事实是：
观察第二个例子的输出，可以发现`show`语句之后的内容被重新包裹在`styled`元素中。暂时不必深究`styled`内部到底做了什么，一个简单事实：

#code(```typ
该元素的类型是：#type({show: set text(fill: blue)}) \
该元素的构造函数是：#({show: set text(fill: blue)}).func()
```)

原来样式规则本身也会变成内容结构的一部分。被`show`影响过的内容会被封装为「样式化」内容，也就是这里构造函数为`styled`的内容。

上一节已经从编译流程解释过`styled`为什么需要延迟到排版阶段处理。这里不再展开底层架构，只借这个观察引出本节关心的问题：样式从哪里来，又会影响哪些内容？

// == 「可定位」的内容

// 在过去的章节中，我们了解了评估结果的具体结构，也大致了解了排版引擎的工作方式。

// 接下来，我们介绍一类内容的「可定位」（Locatable）特征。你可以与前文中的「可折叠」（Foldable）特征对照理解。

// 一个内容是可定位的，如果它可以以某种方式被索引得到。

// 如果一个内容在代码块中，并未被使用，那么显然这种内容是不可定位的。

// ```typ
// #{ let unused-content = [一段不可定位的内容]; }
// ```

// 理论上文档中所有内容都是可定位的，但由于*性能限制*，Typst无法允许你定位文档中的所有内容。

// 我们已经学习过元素函数可以用来定位内容。如下：

// #code(````typ
// #show heading: set text(fill: blue)
// = 蓝色标题
// 段落中的内容保持为原色。
// ````)

// 接下来我们继续学习更多选择器。

== 内容的「样式」

我们先从最简单的文本样式开始。

文本是段落的重要组成部分，与之对应的内容函数是`text`。

一个函数可以有各种参数。从函数视角看，内容的样式由创建该内容时传入的参数决定。例如，要获得一段蓝色文本，可以直接调用`text`函数：

#code(```typ
#text("一段文本", fill: blue)
```)

`fill: blue`是函数的参数，指定了文本的样式。

这个视角有助于我们更好地将「样式需求」转换为「函数调用」。例如，可以使用函数的`with`方法，获得一个固定样式的文本函数：

#code(```typ
#let warning = text.with(fill: orange)
#warning[警告，你做个人吧]
```)

== 上下文有关表达式

// contextual expression

但样式并不总是写死在函数调用里的。有些样式需要等到内容落入具体位置时才能确定。例如，当前字号可能由文档开头的规则、局部代码块里的规则，甚至模板共同决定。

这类值需要借助「上下文有关表达式」读取。`context`会在当前排版上下文中求出表达式的值：

#code(```typ
#context text.size
```)

如果改变当前作用域中的文本大小，同一个表达式也会得到不同结果：

#code(```typ
默认字号：#context text.size \
#set text(size: 18pt)
新的字号：#context text.size
```)

这说明样式元素并不固定，而是取决于样式在文档中所处的位置，即它所处的「上下文」。

== 「`set`」语法 <grammar-set>

一个段落通常不是单个文本，而是一串内容。哪怕看起来只是一句话，内部也可能包含多个文本片段：

#code(```typ
#repr([不止包含......一个文本！])
```)

假设我们想要让一整个段落都显示成蓝色，显然不能把每个文本片段都用`text.with(fill: blue)`构造一遍再组装起来。这个时候就需要「`set`」语法。

「`set`」关键字后可以跟随一个函数调用。它不会立刻创建某个内容，而是为影响范围内对应元素的内容设置默认参数：

#code(```typ
#set text(fill: blue)
一段很长的话可能不止包含......一个文本！
- 似乎，列表中也有文本。
```)

这里的`set text(fill: blue)`会影响后续所有`text`元素。因此段落文本会变蓝，列表项里的文本也会变蓝。

不过，`set`并不是从出现位置一路影响到文档结束的位置。它的影响范围是其所在「作用域」内的后续内容。

== 「内容」是一棵树

为了理解作用域，需要换一个视角看内容：Typst文档并非简单地将内容拍平成一个序列，而是保持了内容的结构，形成一棵不断嵌套形成的树。

花括号代码块会创建新的作用域，内容块、标题、列表等结构也会组织出层级。样式沿着这些层级向内传递；离开某个作用域后，局部设置也随之结束。

#code(```typ
#{
  set text(fill: blue)
  [这段是蓝色。]
}
这段恢复默认颜色。
```)

一个`main.typ`文件本身就是一棵内容树。即便不使用标记语法，你也可以直接用函数和代码块创建一篇文档：

#code.with(al: top)(```typ
#let main-typ() = {
  heading("生活在Content树上")
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  } + parbreak()
  [...] + parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#main-typ()
```)

// == 「样式链」

// 理解「作用域」对

== 「`show`」语法 <grammar-show>

「`set`」语法是「`show set`」语法的简写。反过来讲，「`show`」语法显然比`set`更强大。<grammar-show-set>

#code(```typ
#show: set text(fill: blue)
wink!
```)

我们可以看到「`show`」语法由两部分组成，由冒号分隔。

`show`的右半部分是一个函数，表示如何修改被选中的内容。

#pro-tip[
  你可能会问，先姑且不问函数要怎么写，难道`set text(fill: blue)`也能算一个函数吗？

  事实上，`set`规则是「内容类型」，它接受一个样式和一个内容，返回一个`styled`内容：

  #code(```typ
  #let x = [#set text(fill: blue)]
  #x.func()
  ```)

  以下写法偏底层，请最好不要在你的文档中包含这种代码。它仅用于理解`styled`怎样把内容和样式放在一起：

  #code(```typ
  #let styled = [#set text(blue)].func()
  #let styles = text("", red).styles
  #styled([Red Text], styles)
  ```)

  1. 第一行代码，我们说`func`方法返回内容函数本身，这里便返回了一个内部的函数`styled`。
  2. 第二行代码，这里我们从`text`内容上找到了它关于设置红色文本的样式（参数）。
  3. 第三行代码，把一个内容及一个无论如何从某处得到了的样式传递给`styled`函数。
  4. 最终我们构造出了一个真实的红色文本。

]

`show`的左半部分是选择器，表示要选择文档中的哪一部分。它作用于「作用域」内的*后续*所有*被选择器选中*的内容。

如果选择器为空，则默认选择*后续所有*内容。这也是「`set`」语法可以写成上面那种形式的原因。

如果选择器不为空，`show`就只会修改被选中的内容。最容易理解的一类选择器是内容函数：把内容函数放在冒号左侧，就会选中对应元素。

以下脚本设置所有代码片段的颜色：

#code(```typ
#show raw: set text(fill: blue)
被秀了的`代码片段`！
```)

以下脚本分别设置代码片段和数学公式的颜色。注意，公式中临时嵌入的代码片段仍然会受到`raw`规则影响：

#code(```typ
#show raw: set text(red)
#show math.equation: set text(blue)
#let dif2(x) = math.op(math.Delta + $x$)
一个公式：$ sum_(f in S(x))
  #`refl`;(f) dif2(x) $
```)

既然`show`的右半部分是函数，那么它当然不只能写`set`。这个函数接受一个参数，即被选中的内容；它可以返回任意内容。

对于代码片段，`show`回调拿到的参数还保留了`lines`等可访问字段。下面的规则只取代码片段的第二行：

#code(````typ
#show raw: it => it.lines.at(1)
获取代码片段第二行内容：```typ
#{
set text(fill: true)
}
```
````)

这也是`show`规则很强大的地方：它匹配所有待修改的内容，并返回你想要返回的任意内容。

以下示例进一步说明它可以返回*任意*内容。这里我们选择语言为`my-calc`的代码片段，执行其中的表达式，并返回一个*非代码片段*：

#code(````typ
#show raw.where(lang: "my-calc"): it => eval(it.text)
嵌入一个计算器语言，计算`1*2+2*(2+3)`：```my-calc 1*2+2*(2+3)```
````)

由于`show`的右半部分只要求接受内容并返回内容，我们可以使用一些天然满足要求的函数，写出非常短的规则。

以下规则将每个代码片段用方框修饰：

#code(````typ
#show raw: rect
``` QwQ ```
````)

以下规则将每个代码片段用蓝色方框修饰：

#code(````typ
#show raw: rect.with(stroke: blue)
``` QwQ ```
````)

// == 内容的「实例化过程」

// 通过`query`我们获得同一个内容上更多的信息，即「样式」属性，即内容上的那些可选函数参数。

// 根据上述例子，我们来理解为什么它只提供了语法属性。假设只看`= 123`这5个字符，显然我们从*语法*上只能获得两个信息：
// + 它是一级标题。
// + 它的内容是`123`。

// 与之相对，当一个标题真正被放置到一个具体的「上下文」中时，才能真正关联与之相关的样式属性。例如，标题的`numbering`字段是与上下文相关的。

// - location()

// == import/include/styled

// == 「`include`」语法 <grammar-include>

// 介绍`read`，`eval(mode)`。

// 路径分为相对路径和绝对路径。如果是相对路径，`read("other-file.typ")`相当于在*当前*文件夹寻找对对应的文件。

// `include`的本质就是`eval(read("other-file.typ", mode: "markup"))`，获得一个「内容」，*插入到原地*。

// 假设我们有一个文件：

// #code(```typ
// // 以下是other-file.typ文件的内容
// 一段文本
// #set text(fill: red)
// 另一段文本
// ```)

// 那么```typ #include "other-file.typ"```将获得该文件的「内容」，*插入到原地*。

// #code(```typ
// #{
//   set text(fill: blue)
//   include "other-file.typ"
// }
// #include "other-file.typ"
// ```)

// `include`的文件是一个「内容块」，自带一个作用域。

== 文本选择器 <grammar-text-selector>

你可以使用「字符串」或「正则表达式」（`regex`）匹配文本中的特定内容。例如，下面的规则会把正文里的`cpp`替换并设置为「强调」样式：

#code(````typ
#show "cpp": strong(emph(box("C++")))
在古代，cpp是一门常用语言。
````)

这与使用正则表达式的效果相同：<grammar-regex-selector>

#code(````typ
#show regex("cp{2}"): strong(emph(box("C++")))
在古代，cpp是一门常用语言。
````)

关于正则表达式的知识，推荐在#link("https://regex101.com")[Regex 101]中继续学习。

这里讲述一个关于文本选择器的重要知识：当一段文本被选择器选中时，Typst会在这里创建一个不可见的分界。后续文本选择器不能跨过这个分界继续匹配。

#code(````typ
#show "ab": set text(fill: blue)
#show "a": set text(fill: red)
ababababababa
````)

第一个例子中，`"ab"`规则先应用，每个`ab`被分隔出来；之后`"a"`规则仍然可以在这些分界内部继续匹配。

#code(````typ
#show "a": set text(fill: red)
#show "ab": set text(fill: blue)
ababababababa
````)

第二个例子中，`"a"`规则先应用，每个`a`都被单独分隔，所以后续的`"ab"`规则无法再跨过分界匹配到完整的`ab`。

这个特征在设置文本的字体时需要特别注意：

为引号单独设置字体会导致错误的排版结果。因为句号与双引号之间产生了分界，使得Typst无法应用标点挤压规则：

#code(````typ
#show "”": it => {
  set text(font: "KaiTi")
  highlight(it, fill: yellow)
}
“无名，万物之始也；有名，万物之母也。”
````)

以下正则匹配也会导致句号与双引号之间产生分界，因为没有对两个标点进行贪婪匹配：

#code(````typ
#show regex("[”。]"): it => {
  set text(font: "KaiTi")
  highlight(it, fill: yellow)
}
“无名，万物之始也；有名，万物之母也。”
````)

以下正则匹配没有在句号与双引号之间创建分界。由于两个标点被一起选中，Typst能排版出这句话的正确结果：

#code(````typ
#show regex("[”。]+"): it => {
  set text(font: "KaiTi")
  highlight(it, fill: yellow)
}
“无名，万物之始也；有名，万物之母也。”
````)

== 标签选择器 <grammar-label-selector>

许多元素内部都可能包含文本。只靠文本选择器，很难准确地对某一整段话应用排版规则。「标签」有助于改善这一点。标签是「内容」，由一对「尖括号」（`<`和`>`）包裹：

#code(````typ
一句话 <some-label>
````)

「标签」可以选中恰好在它*之前*的一个内容。示例中，`<some-label>`选中了文本内容`一句话`。

也就是说，「标签」无法选中在它*之前*的多个内容。以下选择器选中了`#[]`后的一句话：

#code(````typ
#show <一句话>: set text(fill: blue)
#[一句话。]还是一句话。 <一句话>

另一句话。
````)

这是因为`#[一句话。]`被分隔为了单独的内容。

我们很难判断一段话中有多少个内容。因此为了可控性，我们可以使用内容块将一段话括起来，然后使用标签准确选中这一整段话：

#code(````typ
#show <一整段话>: set text(fill: blue)
#[
  $lambda$语言是世界上最好的语言。#[]还是一句话。
] <一整段话>

另一段话。
````)

== 选择器表达式 <grammar-selector-exp>

元素函数可以使用「`where`」方法创建满足特定条件的选择器。

例如我们可以选中二级标题：

#code(````typ
#show heading.where(level: 2): set text(fill: blue)
= 一级标题
== 二级标题
````)

这里`heading`是一个元素，`heading.where`创建一个选择器：

#code(````typ
选择器是：#repr(heading.where(level: 2)) \
类型是：#type(heading.where(level: 2))
````)

同理我们可以选中行内的代码片段而不选中代码块：

#code(````typ
#show raw.where(block: false): set text(fill: blue)
`php`是世界上最好的语言。
```
typst也是。
```
````)

// == 「`numbering`」函数

// 略

== 总结

本节以文本、代码片段和内容块为例，介绍了样式参数、上下文、作用域、「`set`」语法、「`show`」语法，以及字符串、正则、标签和`where`几类常用选择器。为了拓展广度，你还需要查看《基本参考》中各种元素的用法，这样才能随心所欲地排版任何「内容」。

== 习题

下面几道题沿用前文的`main-typ()`例子。它们不要求你写出一个覆盖所有元素的通用文本提取器，只要求你理解内容树可以被递归遍历。

// == 字数统计

// 从一个典型程序开始，这个程序基本解决我们一个需求：完成一段内容的字数统计。按照惯例，这一个程序涉及了本节所有的知识点。

// ```typ
// #let plain-text(it) = {
//   if it.has("children") {
//     ("", ..it.children.map(plain-text)).join()
//   } else if it.has("child") {
//     plain-text(it.child)
//   } else if it.has("body") {
//     plain-text(it.body)
//   } else if it.has("text") {
//     it.text
//   } else if it.func() == smartquote {
//     if it.double { "\"" } else { "'" }
//   } else {
//     " "
//   }
// }
// ```

// 以及基于其上实现一个字数统计函数：

// ```typ
// #let word-count(it) = {
//   plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
// }
// ```

// 以下是该函数的表现：

// #code.with(scope: code-scope)(```typ
// #let show-me-the(it) = {
//   repr(plain-text(it))
//   [ 的字数统计为 ]
//   repr(word-count(it))
// }
// #show-me-the([])\
// #show-me-the([一段文本]) \
// #show-me-the([A bc]) \
// #show-me-the([
//   - 列表项1
//   - 列表项2
// ])
// ```)

#let plain-text(it) = {
  if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else if it.has("body") {
    plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else if it.func() == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else {
    " "
  }
}
#let word-count(it) = {
  plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
}

#let code-scope = (plain-text: plain-text, word-count: word-count)

#let q1 = ````typ
#let plain-text(it) = {
  if type(it) == str {
    it
  } else if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else if it.has("body") {
    plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else if it.func() == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else {
    " "
  }
}
#let main-typ() = {
  heading("生活在Content树上")
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  } + parbreak()
  [...] + parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#plain-text(main-typ())
````

#exercise[
  实现内容到字符串的转换`plain-text`：对于文中出现的`main-typ()`内容，它输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#let q1 = ````typ
#let plain-text(it) = {
  if type(it) == str {
    it
  } else if it.has("children") {
    ("", ..it.children.map(plain-text)).join()
  } else if it.has("child") {
    plain-text(it.child)
  } else if it.has("body") {
    plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else if it.func() == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else {
    " "
  }
}
#let word-count(it) = {
  plain-text(it).replace(regex("\p{hani}"), "\1 ").split().len()
}
#let main-typ() = {
  heading("生活在Content树上")
  {
    [现代社会以海德格尔的一句]
    [“一切实践传统都已经瓦解完了”]
    [为嚆矢。]
  } + parbreak()
  [...] + parbreak()
  [在孜孜矻矻以求生活意义的道路上，对自己的期望本就是在与家庭与社会对接中塑型的动态过程。]
  [而我们的底料便是对不同生活方式、不同角色的觉感与体认。]
  [...]
}
#word-count(main-typ())
````

#exercise[
  实现字数统计`word-count`：对于文中出现的`main-typ()`内容，它输出：#rect(width: 100%, eval(q1.text, mode: "markup"))
][
  #q1
]

#exercise[
  思考题：`plain-text`有何局限性？为什么在`show`规则影响下，`word-count`输出分别为4和5？

  #code.with(scope: code-scope)(```typ
  #let show-me-the(it) = {
    it + [ 的字数统计为#word-count(it) ]
  }
  #show-me-the([#show raw: it => {"123"; it}; `一段文本`]) \
  #show-me-the([#show: it => {"123"; it}; 一段文本])
  ```)
][
  #q1
]
