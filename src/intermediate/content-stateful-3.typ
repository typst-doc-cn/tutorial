#import "mod.typ": *

#show: book.page.with(title: "维护文档状态 —— 制作页眉标题法二")

在上一节（法一）中，我们仅靠「#typst-func("query")」函数就完成制作所要求页眉的功能。

思考下面函数：

```typ
#let get-heading-at-page(loc) = {
  let (headings, last-heading) = calc-headings(
    query(heading.where(level: 2), loc))
  headings.at(loc.page() - 1, default: last-heading)
}
```

对于每个页面，它都运行```typc query(heading.where(level: 2), loc)```。显然每页的「位置」信息，即`loc`对应不相同。因此：
1. 它会*每页*都重新执行一遍`heading.where(level: 2)`查询。
2. 同时，每次`query`都是对*全文档的线性扫描*。

夸张来讲，假设你有一千页文档，文档中包含上千个二级标题；那么他将会使得你的每次标题更新都触发上百万次迭代。虽然Typst很快，但这上百万次迭代将会使得包含这种页眉的文档难以*实时预览*。

那么有没有一种方法避免这种全文档扫描呢？

本节将介绍法二，它基于「#typst-func("state")」函数，持续维护页眉状态。

Typst文档可以很高效，但有些人写出的Typst代码更高效。本节所介绍的法二，让我们变得更接近这种人。

== 「state」函数<grammar-state>

`state`接收一个名称，并创建该名称对应*全局*唯一的状态变量。

#code(```typ
#state("my-state", 1)
```)

你可以使用```typc state.display()```函数展示其「内容」：

#code(```typ
#let s1 = state("my-state", 1)
s1: #s1.display()
```)

你可以使用```typc state.update()```方法更新其状态。`update`函数接收一个「回调函数」，该回调函数接收`state`在某时刻的状态，并返回对应下一时刻的状态：

#let s = state("my-state", 1)

#code(```typ
#let s1 = state("my-state", 1)
s1: #s1.display() \
#s1.update(it => it + 1)
s1: #s1.display()
```)

#s.update(it => 1)

所有的相同名称的内容将会共享更新：

#code(```typ
#let s1 = state("my-state", 1)
s1: #s1.display() \
#let s2 = state("my-state", 1)
s1: #s1.display(), s2: #s2.display() \
#s2.update(it => it + 1)
s1: #s1.display(), s2: #s2.display()
```)

同时，请注意状态的*全局*特性，即便处于不同文件、不同库的状态，只要字符串对应相同，那么其都会共享更新。

这提示我们需要在不同的文件之间维护全局状态的名称唯一性。

另一个需要注意的是，`state`允许指定一个默认值，但是一个良好的状态设置必须保持不同文件之间的默认值相同。如下所示：

#s.update(it => 1)

#code(```typ
#let s1 = state("my-state", 1)
s1: #s1.display() \
#let s2 = state("my-state", 2)
s1: #s1.display(), s2: #s2.display() \
#s2.update(it => it + 1)
s1: #s1.display(), s2: #s2.display()
```)

尽管`s2`指定了状态的默认值为`2`，因为之前已经在文档中创建了该状态，默认值并不会应用。请注意：你不应该利用这个特性，该特性是Typst中的「未定义行为」。

== 「state.update」也是「内容」

一个值得注意的地方是，似乎与#typst-func("locate")函数相似，#typst-func("state.update")也接收一个闭包。

事实上，与#typst-func("locate")函数相同，#typst-func("state.update")也具备延迟执行的特性。

让我们检查下列脚本的输出结果：

#s.update(it => 1)

#code(```typ
#let s1 = state("my-state", 1)
#((s1.update(it => it + 1), ) * 3).join()
s1: #s1.display()
```)

这告诉我们下面一件事情，当`eval`阶段结束时，其对应产生下面的一段内容：

```typc
(
  state("my-state", 1),
  state("my-state").update(it => it + 1),
  state("my-state").update(it => it + 1),
  state("my-state").update(it => it + 1),
)
```

排版引擎会按照*深度优先的顺序*遍历你的内容，从文档的开始位置逐渐*积累*状态。

这将帮助我们在多文件之间协助完成状态的更新与计算。

假设我们有两个文件`s1.typ`和`s2.typ`，文件的内容分别是：
```typ
// s1.typ
#let s1 = state("my-state", (1, ))
#s1.update(it => it + (3, ))
// s2.typ
#let s1 = state("my-state", (2, ))
#s1.update(it => it + (4, ))
#s1.update(it => it + (5, ))
```

并且我们在`main.typ`中引入了上述两个文件：

```typc
#include "s1.typ"
#include "s2.typ"
```

那么根据我们的经验，主文件内容其实对应为：

```typc
{
  state("my-state", (1, )),
  state("my-state", it => it + (3, )),
} +
{
  state("my-state", (2, )),
  state("my-state", it => it + (4, )),
  state("my-state", it => it + (5, )),
}
```

我们按照顺序执行状态更新，则状态依次变为：

```typc
{
  (1, );
  (1, 3, );
}
{
  (1, 3, );
  (1, 3, 4, );
  (1, 3, 4, 5, );
}
```

== 查询特定时间点的「状态」

Typst提供两个方法查询特定时间点的「状态」：

一个方法是```typc state.at(loc)```方法，其接收一个「位置」，返回在该位置对应的状态「值」。

另一个方法是```typc state.final(loc)```方法，其接收一个「位置」，返回在文档结束一切排版时对应的状态「值」。

熟悉的剧情再次发生了。让我们回想之前介绍#typst-func("query")时讲述的知识点。

这两个方法都只能在#typst-func("locate")内部调用。对于#typst-func("state.at")方法，其「位置」参数是有用的；对于#typst-func("state.final")方法，其「位置」参数仅仅作为「哑参数」。

我们回想上一小节，由于文档的每个位置「状态」都会存有对应的值，而且当你使用状态的时候至少会指定一个默认值，我们可以知道在我们文档的任意位置使用文档的任意其他位置的状态的内容。

这就是允许我们进行时光回溯的基础。

== 「`typeset`」阶段的迭代收敛

一个容易值得思考的问题是，如果我在文档的开始位置调用了#typst-func("state.final")方法，那么Typst要如何做才能把文档的最终状态返回给我呢？

容易推测出，原来Typst并不会只对内容执行一遍「`typeset`」。

仅考虑我们使用#typst-func("state.final")方法的情况。

初始情况下#typst-func("state.final")方法会返回状态默认值，并完成一次布局。接下来的迭代，#typst-func("state.final")方法会返回上一次迭代布局完成时的。直到布局的内容不再发生变化。

#typst-func("state.at")会导致相似的布局迭代，只不过情况更为复杂，这里便不再展开细节。

所有对文档的查询都会导致布局的迭代：
1. `query`函数可能会导致布局的迭代。
1. `state.at`函数可能会导致布局的迭代。
1. `state.final`函数一定会导致布局的迭代。

== 回顾其三

本节使用递归的方法完成状态的构建，其更为巧妙。

首先，我们声明两个与法一类似的状态，只不过这次我们将状态定义在全局。

```typ
#let first-heading = state("first-heading", ())
#let last-heading = state("last-heading", ())
```

然后，我们在每个二级标题后紧接着触发一个更新：

```typc
show heading.where(level: 2): curr-heading => {
  curr-heading
  locate(loc => ..)
}
```

对于`last-heading`状态，我们可以非常简单地如此更新内容：

```typc
last-heading.update(headings => {
  headings.insert(str(loc.page()), curr-heading.body)
  headings
})
```

每页的最后一个标题总能最后触发状态更新，所以`str(loc.page())`总是能对应到每页的最后一个标题的内容。

对于`first-heading`状态，稍微复杂但也好理解：

```typc
first-heading.update(headings => {
  let k = str(loc.page())
  if k not in headings {
    headings.insert(k, curr-heading.body)
  }
  headings
})
```

对于每页靠后的一级标题，都不能使`if`条件成立。所以`str(loc.page())`总是能对应到每页的第一个一级标题的内容。

接下来便是简单的查询了，我们回忆之前`get-heading-at-page`的逻辑，它首先判断是否存在本页的第一个标题，否则取前页的最后一个标题。以下函数完成了前半部分：

```typc
let get-heading-at-page(loc) = {
  let page-num = loc.page()
  let first-headings = first-heading.final(loc)

  first-headings.at(str(page-num))
}
```

我们为`at`函数添加`default`函数，其取前页的最后一个标题。

```typc
let get-heading-at-page(loc) = {
  ..
  let last-headings = last-heading.at(loc)

  first-headings.at(str(page-num), default: find-headings(last-headings, page-num))
}
```

我们使用递归的方法实现`find-headings`：

```typc
let find-headings(headings, page-num) = if page-num > 0 {
  headings.at(str(page-num), default: find-headings(headings, page-num - 1))
}
```

递归有两个分支：
+ 递归的基是，若一直找到文档最前页都找不到相应的标题，则返回`none`。
+ 否则检查`headings`中是否有对应页的标题
  + 若有则直接返回其内容
  + 否则继续往前页迭代。

一个细节值得注意，我们对`first-heading`使用了`final`方法，但对`last-heading`使用了`at`方法。这是因为：
+ `first-heading`需要我们支持后向查找，因此需要直接获取文档最终的状态。
+ `last-heading`仅仅需要前向查找，因此使用`at`方法可以改进迭代效率。

这个递归函数是高性能的，因为Typst会对`find-headings`缓存，并且Typst对于后一页的内容，都总是能命中前一页的缓存。

与之相反，基于#typst-func("query")的实现没有那么好命。它没法很好利用递归完成标题信息的构建。这是因为#typst-func("query")的实现中，`calc-headings`的首次执行就被要求计算文档的所有标题。

最后让我们设置页眉：

#frames-cjk(read("./stateful/s1.typ"), code-as: ```typ
// 这里有get-heading-at-page的实现..

#set page(header: locate(loc => emph(
  get-heading-at-page(loc))))
```)
