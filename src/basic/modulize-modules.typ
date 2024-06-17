#import "mod.typ": *

#show: book.page.with(title: "模块")

正如我们在《基础文档》中所说的，Typst为我们提供了脚本的便捷性。但是事实上，不写或少写脚本便能完成排版才是最大的便捷。无论我们会不会自己用脚本解决某个问题，我们总是希望Typst能够允许我们以一种优雅的方式#strike[复制粘贴]引入这些代码。理想情况下，当某位前辈为我们准备好了模板，我们可以只用两行代码便可完成排版的配置：

#```typ
#import "@preview/senpai-no-awesome-template.typ:0.x.x": *
#show: template.with(..)
```

模块便是为此而诞生的。Typst的模块（module）机制非常简单：每个文件都是一个模块并可以被导入。Typst模块将允许你：
+ 在本地工作区内，在多个文档之间共享你爱用的排版函数。
+ 将一份文档分作多个文件编写。
+ 通过本地注册或网络共享，使用外部模板或库。

本节将告诉你有关Typst的模块机制的一切。由于Typst的模块机制过于简单，本节将不会涉及很多需要理解的地方。故而，本节主要伴随讲解一些日常使用模块机制时所遇到的问题。

== 根目录

根目录的概念是Typst自0.1.0开始就引入的。
+ 当你使用`typst-cli`程序时，根目录默认为你文件的父目录。你也可以通过`--root`命令行参数手动指定一个根目录。例如你可以指定当前工作目录的父文件夹作为编译程序的根目录：

  ```bash
  typst c --root ..
  ```
+ 当你使用VSCode的tinymist或typst-preview程序时，为了方便多文件的编写，根目录默认为你所打开的文件夹。如果你打开一个VSCode工作区，则根目录相对于离你所编辑文件最近的工作目录。

在早期，Typst就禁止访问*根目录以外的内容*。尽管扩大可访问的文件数量在某种程度上增进了便捷性，也意味着降低了执行Typst脚本的安全性。这是因为，根目录下所有的子文件夹和子文件都有机会被*你编写的或其他人编写（外部库）的Typst脚本访问*。

一个常见的错误做法是，为了共享本地代码或模板，在使用`typst-cli`的时候将根目录指定为系统的根目录。
- 如果你是Windows用户，则以下使用方法将有可能导致个人隐私泄露：

  ```bash
  typst c --root C:\
  ```

  并访问你系统中的某处文件。

  ```typ
  #import "/Users/me/templates/book.typ": book-template
  ```
- 如果你是Linux或macOS用户，则以下使用方法将有可能导致个人隐私泄露：

  ```bash
  typst c --root /
  ```

  并访问你系统中的某处文件。

  ```typ
  #import "/home/me/templates/book.typ": book-template
  ```

本节将介绍另外一种方式——通过在注册本地包在你的多个Typst项目之间共享代码。

== 绝对路径与相对路径

我们已经讲解过`read`函数和`include`语法，其中都有路径的概念。

如果路径以字符`/`开头，则其为「绝对路径」。绝对路径相对于根目录解析。若设置了根目录为#text(red, `/OwO/`)，则路径`/a/b/c`对应路径#text(red, `/OwO/`)`a/b/c`。

#code(
  ```typ
  #include "/src/intermediate/chapter1.typ"
  ```,
  res: [我是`/OwO/src/intermediate/chapter1.typ`文件！],
)

否则，路径不以字符`/`开头，则其「相对路径」。相对路径相对于当前文件的父文件夹解析。若我们正在编辑#text(red, `/OwO/src/intermediate/`)`main.typ`文件，则路径`d/e/f`对应路径#text(red, `/OwO/src/intermediate/`)`d/e/f`。

#code(
  ```typ
  #include "chapter2.typ"
  ```,
  res: [我是`/OwO/src/intermediate/chapter2.typ`文件！],
)

== 「import」语法与「模块」

Typst中的模块概念相当简单，你只需记住：每个文件都是一个模块。

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

在Typst内部，当解析完一个文件时，文件将被分为顶层作用域中的「内容」和「变量声明」，组成一个文件模块。

例如对于`packages/m1.typ`文件：

#m1-code

其「内容」是除了「变量声明」以外的文件内容，连接起来为：

```typ
一段内容

// #let add(x, y) = x + y

另一段内容

// #let sub = ..
```

其导出所有在文件顶层作用域中的「变量声明」：

```typ
// 一段内容
//
#let add(x, y) = x + y
//
// 另一段内容
//
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
