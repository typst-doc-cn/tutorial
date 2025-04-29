#import "mod.typ": *

#show: book.page.with(title: [查询文档状态])

#import "/typ/embedded-typst/lib.typ": svg-doc, default-fonts, default-cjk-fonts

本节我们讲解制作页眉标题的第一种方法，即通过查询文档状态直接估计当前页眉应当填入的内容。

// #locate(loc => query(heading, loc))
// #locate(loc => query(heading.where(level: 2), loc))

== 「here」<grammar-here>

#todo-box[
  修改以适配全面 context 化的 0.12+ 语法
]

有的时候我们会需要获取当前位置的「位置」信息。

在Typst中，获取当前「位置」的唯一方法是使用「#typst-func("here")」函数。

我们来`repr`一下试试看：

#code(```typ
当前位置的相关信息：#context repr(here())
```)

由于「位置」太过复杂了，`repr`放弃了思考并在这里为我们放了两个点。

我们来简单学习一下Typst为我们提供了哪些位置信息：

#code(```typ
当前位置的坐标：#context here().position()

当前位置的页码：#context here().page()
```)

一个常见的问题是：为什么Typst提供给我的页码信息是「内容」，我无法在内容上做条件判断和计算！<grammar-here-calc>

// #code(```typ
// #repr(context here().page()) \
// #type(context here().page())
// ```)

// 上面输出的内容告诉我们#typst-func("here")不仅是一个函数，而且更是一个元素的构造函数。#typst-func("here")构造出一个`locate`内容。

这其中的关系比较复杂。一个比较好理解的原因是：Typst会调用你的函数多次，因此你理应将所有使用「位置」信息的脚本放在一个上下文块中，这样Typst才能更好地合成内容。

#code(```typ
#context [ 当前位置的页码是偶数：#calc.even(here().page()) ]
//  根据位置信息  计算得到  我们想要的内容
```)

// #pro-tip[
//   这与Typst的缓存原理相关。由于#typst-func("locate")函数接收的闭包```typc loc => ..```是一个函数，且在Typst中它被认定为*纯函数*，Typst只会针对特定的参数执行一次函数。为了强制让用户书写的函数保持纯性，Typst规定用户必须在函数内部使用「位置」信息。

//   因此，例如我们希望在偶数页下让内容为“甲”，否则让内容为“乙”，应当这样书写：

//   #code(```typ
//   #context if calc.even(here().page()) [“甲”] else [“乙”]
//   ```)
// ]

== 「query」<grammar-query>

使用「#typst-func("query")」函数你可以获得当前文档状态。

#code(
  ```typ
  #context query(heading)
  ```,
  res: raw(
    ```typc
    (
      heading(body: [雨滴书 v0.1.2], level: 2, ..),
      ..,
    )
    ```.text,
    lang: "typc",
    block: false,
  ),
)

「#typst-func("query")」函数的唯一参数是「选择器」，很好理解。它接受一个选择器，并返回被选中的所有元素的列表。

#code(
  ```typ
  #context query(heading)
  ```,
  res: raw(
    ```typc
    (
      heading(body: [雨滴书 v0.1.2], level: 2, ..),
      heading(body: [KiraKira 样式改进], level: 3, ..),
      heading(body: [FuwaFuwa 脚本改进], level: 3, ..),
      heading(body: [雨滴书 v0.1.1], level: 2, ..),
      heading(body: [雨滴书 v0.1.0], level: 2, ..),
    )
    ```.text,
    lang: "typc",
    block: false,
  ),
)

我们记得，选择器允许继续指定`where`条件过滤内容：

#code(
  ```typ
  #context query(heading.where(level: 2))
  ```,
  res: raw(
    ```typc
    (
      heading(body: [雨滴书 v0.1.2], level: 2, ..),
      heading(body: [雨滴书 v0.1.1], level: 2, ..),
      heading(body: [雨滴书 v0.1.0], level: 2, ..),
    )
    ```.text,
    lang: "typc",
    block: false,
  ),
)

// 第二个参数是「位置」，就比较难以理解了。首先说明，`loc`并没有任何作用，即它是一个「哑参数」（Dummy Parameter）。

// 如果你学过C++，以下两个方法分别匹配到前缀自增操作函数和后缀自增操作函数。

// ```cpp
// class Integer {
//   Integer& operator++();   // 前缀自增操作函数
//   Integer operator++(int); // 后缀自增操作函数
// };
// ```

// ```cpp class Integer```类中的`int`就是一个所谓的哑参数。

// 「哑参数」在实际函数执行中并未被使用，而仅仅作为标记以区分函数调用。我们知道以下两点：其一，只有#typst-func("locate")函数会返回「位置」信息；其二，#typst-func("query")函数需要我们传入「位置」信息。

// 有了：那么Typst就是在告诉我们，#typst-func("query")函数只能在#typst-func("locate")函数内部调用。正如示例中的那样：

// ```typ
// #locate(loc => query(heading.where(level: 2), loc))
// ```

// 这个规则有些隐晦，并且Typst的设计者也已经注意到了这一点，所以他们正在计划改进这一点。当然在这之前，你只需要记住：#typst-func("query")函数的第二个「位置」参数用于限制该函数仅在#typst-func("locate")函数内部使用。

// #pro-tip[
//   这与Typst的缓存原理相关。为了加速#typst-func("query")函数，Typst需要对其缓存。Typst合理做出以下假设：在文档每处的查询（`loc`），都单独缓存对应选择器的查询结果。

//   更细致地描述如下：将```typc query(selector, loc)```的参数为「键」，执行结果为「值」构造一个哈希映射表。若使用`(selector, loc)`作为「键」，查询该表：
//   + 未对应结果，则执行查询，缓存并返回结果。
//   + 已经存在对应结果，则不会重新执行查询，而是使用表中的值作为结果。
// ]

== 回顾其二

页眉的设置方法是创建一条```typc set page(header)```规则：

#frames-cjk(
  read("./stateful/q0.typ"),
  code-as: ```typ
  #set page(header: [这是页眉])
  ```,
)

既然如此，只需要将`[这是页眉]`替换成一个`context`表达式，就能通过#typst-func("query")函数完成与「位置」相关的页眉设定：

```typ
#set page(header: context emph(get-heading-at-page()))
```

现在让我们来编写`get-heading-at-page`函数。

首先，通过`query`函数查询得到整个文档的*所有二级标题*：

```typc
let headings = query(heading).
  filter(it => it.level == 2)
```

如果你熟记`where`方法，你可以更高效地做到这件事。以下函数调用也可以得到整个文档的*所有二级标题*：

```typc
let headings = query(heading.where(level: 2))
```

很好，Typst文档可以很高效，但有些人写出的Typst代码天生更高效，而我们正在向他们靠近。

接着，考虑构建这样一个`fold-headings`函数，它返回一个数组，数组的内容是每个页面页眉应当显示的内容，即每页的第一个标题。

```typ
#let fold-headings(headings) = {
  ..
}
```

我们可以对其直接调用以测试：

#code(```typ
#let fold-headings(headings) = {
  (none, none)
}
#fold-headings((
  (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
))
```)

很好，这样我们就可以很方便地进行测试了。

该函数首先创建一个数组，数组的长度为页面的数量。

#code(```typ
#let fold-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.page))
  (none, ) * max-page-num
}
#fold-headings((
  (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
))
```)

这里，```typc headings.map(it => it.page)```意即对每个标题获取对应位置的页码；```typc calc.max(..numbers)```意即取页码的最大值。

由于示例中页码的最大值为`2`，`fold-headings`针对示例会返回一个长度为2的数组，数组的每一项都是`none`。

接着，该函数遍历给定的`headings`，对每个页码，都首先获取第一个标题元素：

#code(
  ```typc
  for h in headings {
    if first-headings.at(h.page - 1) == none {
      first-headings.at(h.page - 1) = h
    }
  }
  ```,
  res: eval(
    ```typ
    #let fold-headings(headings) = {
      let max-page-num = calc.max(..headings.map(it => it.page))
      let first-headings = (none, ) * max-page-num

      for h in headings {
        if first-headings.at(h.page - 1) == none {
          first-headings.at(h.page - 1) = h
        }
      }

      first-headings
    }
    #fold-headings((
      (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
    ))
    ```.text,
    mode: "markup",
  ),
)

这里，```typc first-headings.at(h.page - 1)```意即获取当前页码对应在数组中的元素；`if`语句，如果对应页码对应的元素仍是```typc none```，那么就将当前的标题元素填入对应的位置中。

同理，可以获得`last-headings`，存储每页的最后一个标题：

#code(
  ```typc
  let last-headings = (none, ) * max-page-num
  for h in headings {
    last-headings.at(h.page - 1) = h
  }
  ```,
  res: eval(
    ```typ
    #let fold-headings(headings) = {
      let max-page-num = calc.max(..headings.map(it => it.page))
      let last-headings = (none, ) * max-page-num

      for h in headings {
        last-headings.at(h.page - 1) = h
      }

      last-headings
    }
    #fold-headings((
      (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
    ))
    ```.text,
    mode: "markup",
  ),
)

这里`for`语句意即：无论如何，都将当前的标题元素存入数组中。那么每页的最后一个标题总是能被存入到数组中。

但是我们还没有考虑相邻情况。如果我们希望如果当前页面没有标题元素，则显示之前的标题。接下来我们来根据这个思路，组装正确的结果：

#code(
  ```typc
  let res-headings = (none, ) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1), default: none)
      last-headings.at(i)
    }
  }
  ```,
  res: eval(
    ```typ
    #let fold-headings(headings) = {
      let max-page-num = calc.max(..headings.map(it => it.page))
      let first-headings = (none, ) * max-page-num
      let last-headings = (none, ) * max-page-num

      for h in headings {
        if first-headings.at(h.page - 1) == none {
          first-headings.at(h.page - 1) = h
        }
        last-headings.at(h.page - 1) = h
      }

      let res-headings = (none, ) * max-page-num
      for i in range(res-headings.len()) {
        res-headings.at(i) = if first-headings.at(i) != none {
          first-headings.at(i)
        } else {
          last-headings.at(i) = last-headings.at(
            calc.max(0, i - 1), default: none)
          last-headings.at(i)
        }
      }

      res-headings
    }
    #fold-headings((
      (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 2),
    ))
    ```.text,
    mode: "markup",
  ),
)

`res-headings`就是我们想要得到的结果。

#let fold-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.page))
  let first-headings = (none,) * max-page-num
  let last-headings = (none,) * max-page-num

  for h in headings {
    if first-headings.at(h.page - 1) == none {
      first-headings.at(h.page - 1) = h
    }
    last-headings.at(h.page - 1) = h
  }

  let res-headings = (none,) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1),
        default: none,
      )
      last-headings.at(i)
    }
  }

  res-headings
}

由于`res-headings`的计算比较复杂，我们先来一些测试用例来理解：

情形一：假设文档的前段没有标题，该函数会将对应下标的结果置空：

#code(
  ```typ
  情形一：#fold-headings((
    (body:"v2",page:3),(body:"v1",page:3),(body:"v0",page: 3),
  ))
  ```,
  scope: (fold-headings: fold-headings),
)

情形二：假设一页有多个标题，那么，对应下表的结果为该页面的首个标题：

#code(
  ```typ
  情形二：#fold-headings((
    (body:"v2",page:2),(body:"v1",page:2),(body:"v0",page: 3),
  ))
  ```,
  scope: (fold-headings: fold-headings),
)

情形三：假设中间有页空缺，则对应下表的结果为前页的最后一个标题。

#code(
  ```typ
  情形三：#fold-headings((
    (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 3),
  ))
  ```,
  scope: (fold-headings: fold-headings),
)

其中，情形一其实是情形三的特例：假设某一页没有标题，则对应下表的结果为前页的最后一个标题。如果不存在前页包含标题，则对应下表的结果为```typc none```。

于是我们可以给代码加上注释：

```typc
let res-headings = (none, ) * max-page-num
// 对于每一页，我们迭代下标
for i in range(res-headings.len()) {
  // 让对应下标的结果等于：
  res-headings.at(i) = {
    // 如果该页包含标题，则其等于该页的第一个标题
    if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      // 否则，我们积累`last-headings`的结果
      last-headings.at(i) = last-headings.at(
        // 始终至少等于前一页的结果
        calc.max(0, i - 1),
        // 默认没有结果
        default: none)
      // 其等于前页的最后一个标题
      last-headings.at(i)
    }
  }
}
```

最后，我们将`query`与`fold-headings`结合起来，便得到了目标函数：

```typ
#let get-heading-at-page() = {
  let headings = fold-headings(query(
    heading.where(level: 2)))
  headings.at(here().page() - 1)
}
```

这里有一个问题，那便是`fold-headings`没有考虑标题的最后一页仍然存在内容的情况。例如第二页有最后一个标题，但是我们文档一共有三页。

重新改造一下：

#let calc-headings(headings) = {
  let max-page-num = calc.max(..headings.map(it => it.page))
  let first-headings = (none,) * max-page-num
  let last-headings = (none,) * max-page-num

  for h in headings {
    if first-headings.at(h.page - 1) == none {
      first-headings.at(h.page - 1) = h
    }
    last-headings.at(h.page - 1) = h
  }

  let res-headings = (none,) * max-page-num
  for i in range(res-headings.len()) {
    res-headings.at(i) = if first-headings.at(i) != none {
      first-headings.at(i)
    } else {
      last-headings.at(i) = last-headings.at(
        calc.max(0, i - 1),
        default: none,
      )
      last-headings.at(i)
    }
  }

  (
    res-headings,
    if max-page-num > 0 {
      last-headings.at(-1)
    },
  )
}

```typ
#let calc-headings(headings) = {
  // 计算res-headings和last-headings
  ..

  // 同时返回最后一个标题
  (res-headings, if max-page-num > 0 {
    last-headings.at(-1)
  })
}
```

我们来简单测试一下：

#code(
  ```typ
  情形一：#calc-headings((
    (body:"v2",page:3),(body:"v1",page:3),(body:"v0",page: 3),
  )).at(1) \
  情形二：#calc-headings((
    (body:"v2",page:2),(body:"v1",page:2),(body:"v0",page: 3),
  )).at(1) \
  情形三：#calc-headings((
    (body:"v2",page:1),(body:"v1",page:1),(body:"v0",page: 3),
  )).at(1)
  ```,
  scope: (calc-headings: calc-headings),
)

很好，这样，下面的实现就完全正确了：

```typ
#let get-heading-at-page() = {
  let (headings, last-heading) = calc-headings(
    query(heading.where(level: 2)))
  headings.at(here().page() - 1, default: last-heading)
}
```

#pro-tip[
  将`calc-headings`与`get-heading-at-page`分离可以改进脚本性能。这是因为Typst是以函数为粒度缓存你的计算。在最后的实现：

  + ```typc query(heading.where(level: 2))```会被缓存，如果二级标题的结果不变，则#typst-func("query")函数不会重新执行（不会重新查询文档状态）。
  + ```typc calc-headings(..)```会被缓存。如果查询的结果不变。则其不会重新执行。
]

最后，让我们适配`calc-headings`到真实场景，并应用到页眉规则：

#frames-cjk(
  read("./stateful/q1.typ"),
  code-as: ```typ
  // 这里有get-heading-at-page的实现..

  #set page(header: context emph(get-heading-at-page()))
  ```,
)
