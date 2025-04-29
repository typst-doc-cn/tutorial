#import "mod.typ": *

#show: book.page.with(title: [文件与模块])

#set page(height: auto)

正如我们在《初识脚本模式》中所说的，Typst提供了脚本语言方便排版。但事实上，写作时若能少写甚至不写脚本，这才算真正的便捷。我们总希望Typst能够允许我们以一种优雅的方式#strike[复制粘贴]引入已有代码。理想情况下，只需两行代码便可引入前辈写好的模板：

#```typ
#import "@preview/senpai-no-awesome-template.typ:0.x.x": *
#show: template.with(..)
```

模块便是为复制而生。


Typst的模块（module）机制非常简单：每个文件都是一个独立的模块。它允许你：
+ 将一份文档分作多个文件编写。
+ 使用本机器或网上的模板或库。

由于Typst的模块机制过于简单，本节主要伴随讲解一些日常使用模块机制时所遇到的问题，而不会涉及很多需要理解的地方。

== 根目录

根目录是一个重要的编译参数。Typst早在v0.1.0时就禁止访问*根目录以外的内容*，以保证安全执行代码。最坏情况下，*其他人编写的Typst脚本（来自互联网）*可以访问根目录下所有的文件。

你所使用的工具可能会为你自动配置*根目录*。

#pro-tip[
  + 当你使用`typst-cli`程序时，根目录默认为文档所在目录。你也可以通过`--root`命令行参数手动指定一个根目录。例如你可以指定当前工作目录的父文件夹作为编译程序的根目录：

    ```bash
    typst c --root ..
    ```
  + 当你使用VSCode的tinymist程序时，为了方便多文件的编写，根目录默认为你所打开的文件夹。如果你打开一个VSCode工作区，则根目录相对于离你所编辑文件最近的工作目录。
]

一个常见的错误做法是，为了共享本地代码或模板，在使用`typst-cli`的时候将根目录指定为系统的根目录。以下使用方法将有可能导致个人隐私泄露：

```bash
typst c --root "C:\\" # Windows
typst c --root / # Linux或macOS
```

并访问你系统中的某处文件。

```typ
#import "/Users/me/templates/book.typ": book-template
```

本节将介绍另外一种创建本地「库」（package）的方式以在Typst项目之间安全地共享代码和资源。

== 绝对路径与相对路径

我们已经讲解过`read`函数和`include`语法，其中都有路径的概念。

如果路径以字符`/`开头，则其为「绝对路径」。绝对路径相对于「根目录」解析。若设置了根目录为#text(red, `/OwO/`)，则路径`/src/chapter1.typ`对应文件系统中的#text(red, `/OwO/`)`src/chapter1.typ`。

#code(
  ```typ
  #include "/src/chapter1.typ"
  ```,
  res: [我是#text(red, `/OwO/`)`src/chapter1.typ`文件！],
)

否则，路径不以字符`/`开头，则其「相对路径」。相对路径相对于当前文件的父文件夹解析。若我们正在编辑#text(red, `/OwO/`)#text(blue, `src/`)`main.typ`文件，则路径`chapter2.typ`对应文件系统中的#text(red, `/OwO/`)#text(blue, `src/`)`chapter2.typ`。

#code(
  ```typ
  #include "chapter2.typ"
  ```,
  res: [我是#text(red, `/OwO/`)#text(blue, `src/`)`chapter2.typ`文件！],
)

== 「import」语法与「模块」

Typst中的模块概念相当简单。你只需记住：每个文件都是一个模块。

#let m1-code = raw(read("packages/m1.typ").trim().replace("\r", ""), lang: "typ", block: true)

假设有一个文件位于`packages/m1.typ`：

#m1-code

此时文件名就是所引入模块的名称，那么`packages/`#text(red, `m1`)`.typ`就对应#text(red, `m1`)模块。

你可以简单通过绝对路径或相对路径引入一个文件模块：

#code(```typ
#import "packages/m1.typ"
#repr(m1)
```)

你可以通过这个「模块」对象访问到文件顶层作用域的变量或函数。例如在`m1`文件中，你可以访问到其顶层作用域中的`add`或`sub`函数。

#code(```typ
#import "packages/m1.typ"
#m1.add \
#m1.sub
```)

你可以在引入模块名的同时将其更名为你想要的名称：

#code(```typ
#{
  import "packages/m1.typ" as m2
  repr(m2)
} \
// 等价于
#{
  import "packages/m1.typ"
  let m2 = m1
  repr(m2)
}
```)

你可以在冒号后添加一个星号表示直接引入模块中所有的函数：

#code(```typ
// 引入所有函数
#import "packages/m1.typ": *
#type(add), #type(sub)
```)

你也可以在冒号后追加一个逗号分隔的名称列表，部分引入来自其他文件的变量或函数：

#code(```typ
// 仅仅引入`sub`函数
#import "packages/m1.typ": sub
#type(sub) \
// 引入`add`和`sub`函数
#import "packages/m1.typ": add, sub
#type(add), #type(sub) \
```)

注意，本地的变量声明与`import`进来的变量声明都会覆盖Typst内置的变量声明。例如Typst内置的`sub`函数实际上为取下标函数。你可以在引入外部变量的同时更名以避免可能的名称冲突：

#code(```typ
1#sub[2]
#import "packages/m1.typ": sub as subtract
#repr(subtract(10, 1))#sub[3]
```)

== 「include」语法与「import」语法的关系

在Typst内部，当解析完一个文件时，文件将被分为顶层作用域中的「内容」和「变量声明」，共同组成一个文件模块。`include`取其「内容」，`import`则取其「变量声明」。

仍然以前文中的`packages/m1.typ`为例：

其「内容」是除了「变量声明」以外的文件内容，连接起来为：

```typ
XXX
// #let add(x, y) = x + y
YYY
// #let sub = ..
```

其导出所有在文件顶层作用域中的「变量声明」：

```typ
// XXX
#let add(x, y) = x + y
// YYY
#let sub(x, y) = x - y
```

因此`include`和`import`分别得到以下结果。

使用`include`得到：

#code(```typ
#repr(include "packages/m1.typ")
```)

使用`import`得到：

#code(```typ
#import "packages/m1.typ"
#repr(m1.add), #repr(m1.sub)
```)

你可以同时使用`include`和`import`获得同一个文件的内容和变量声明。

== 控制变量导出的三种方式

有的时候你不希望将一些变量暴露出去，这个时候你可以让这些变量的名称以「下划线」（`_`）开头：

```typ
#let _factor = 1;
#let add2(x, y) = _factor * (x + y)
```

这样`import`的时候就不会轻易访问到这些变量。

还有一种方法是在非顶层作用域中构造闭包，这样`import`中就不会包含`factor`，因为`factor`不在顶层：

```typ
#let add2 = {
  let factor = 1;
  (x, y) => factor * (x + y)
}
```

值得注意的是，`import`进来的变量也可以被重新导出，只要他们也在顶层作用域。这允许你以更优雅的第三种方式为使用者屏蔽内部变量，例如你可以在子文件夹中完成实现并重新导出：

```typ
// 仅从packages/m1/add.typ文件中重新导出`add`函数。
#import "m1/add.typ": add
// 重新导出packages/m1/sub.typ文件中所有的函数
#import "m1/sub.typ": *
```
