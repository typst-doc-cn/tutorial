#import "mod.typ": *

#show: book.page.with(title: "多文件架构")

尽管本书提倡你尽可能将所有文档内容放在单个文件中，本书给出构建一个多文件架构的合理方案。
- 工作区中包含多个主文件
- 每个主文件可以`include`多个子文件

```
typ/packages
├── util.typ
└── util2.typ
typ/templates
├── book-template.typ
└── note-template.typ
documents/
└── my-book/
    ├── main.typ
    ├── mod.typ
    ├── part1/
    │   ├── mod.typ
    │   └── chap1.typ
    └── part2/
        ├── mod.typ
        ├── chap2.typ
        └── chap3.typ
```

=== 工作区内的模板与库

使用绝对路径方便引入工作区内的模板与库：

```typ
#import "/typ/templates/ebook.typ": project as ebook
```

=== 主文件和主库文件

`main.typ`文件中仅仅包含模板配置与`include`多个子文件。

```typ
// 在mod.typ文件中：
// #import "/typ/templates/ebook.typ": project as ebook
#import "mod.typ": *

#show: ebook.with(title: "My Book")

#include "part1/chap1.typ"
#include "part2/chap2.typ"
#include "part2/chap3.typ"
```

对于每个子文件，你可以都`import`一个主库文件`mod.typ`，以减少冗余。例如在`documents/my-book/part1/chap1.typ`中：

```typ
#import "mod.typ": *
```

=== 重导出文件

示例文件结构中的`mod.typ`与编写库时的`lib.typ`很类似，都重新导出了大量函数。例如当你希望同时在`chap2.typ`和`chap3.typ`中使用相似的函数时，你可以在`mod.typ`中原地实现该函数或者从外部库中重导出对应函数：

```typ
#import "@preview/example:0.1.0": add
// 或者原地实现`add`
#let add(x, y) = x + y
```

这时你可以同时在`chap2.typ`和`chap3.typ`中直接使用该`add`函数。

=== 依赖管理

你可以不在`main.typ`或者`chap{N}.typ`文件中直接引入外部库，而在`my-book/mod.typ`中引入外部库。由于级联的`mod.typ`，相关函数会传递给每个`main.typ`或者`chap{N}.typ`使用。
