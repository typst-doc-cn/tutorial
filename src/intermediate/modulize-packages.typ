#import "mod.typ": *

#show: book.page.with(title: "使用外部库")

除此之外，可以从特殊的路径从网络导入外部「模块」，即外部「库」（packages）。Typst的外部库机制可能不是世界上最精简的，但是我所见过当中最精简的。它可能更稍显简陋，但已经有上百个外部库通过官方渠道发布，并足以满足我们日常生活的使用。

你只需要`import`特定的路径就能访问其内部的变量声明。例如，导入一个用于绘画自动机的外部库：

#code(```typ
#import "@preview/fletcher:0.5.7" as fletcher: node, edge

#align(center, fletcher.diagram(
  node((0, 0), $S_1$),
  node((1, 0), $S_2$),

  edge((1, 0), (0, 0), $g$, "..}>", bend: 25deg),
  edge((0, 0), (1, 0), $f$, "..}>", bend: 25deg),
))
```)

其中，以下一行代码完成了导入外部库的所有工作。我们注意到其完全为`import`语法，唯一陌生的是其中的路径格式：

```typ
#import "@preview/fletcher:0.5.7" as fletcher: node, edge
```

解读路径#text(red, `@preview`)`/`#text(eastern, `fletcher`)`:`#text(orange, `0.5.7`)的格式，它由三部分组成。

=== 「命名空间」，#text(red, `@preview`)

以`@`字符开头。目前仅允许使用两个命名空间：
- #text(red, `@preview`)：Typst仅开放`beta`版本的包管理机制。所有`beta`版本的都在`preview`命名空间下。
- #text(red, `@local`)：Typst建议的本地库命名空间。

=== 「库名」，#text(eastern, `fletcher`)

必须符合变量命名规范：
+ 以ASCII英文字符（`a-z`或`A-Z`）开头；
+ 跟随任意多个ASCII英文或数字字符（`a-z`或`A-Z`或`0-9`）或下划线（`_`）或中划线（`-`）。

例如`OvO`、`O_O`、`O-O`都是合法的库名。但是`0v0`不是合法库名，因为其以数字零开头。

=== 「版本号」，#text(orange, `0.5.7`)

必须符合#link("https://semver.org/")[SemVer]规范。

如果你不能很好地阅读和理解#link("https://semver.org/")[SemVer]规范，仅记住合法的版本号由三个递增的数字组成，并用「点号」（`.`）分隔；版本号之间可以相互比较，且比较版本时按顺序比较数字。例如`0.0.0`、`0.10.0`、`1.5.11`、`1.24.1`是合法且递增的版本号。
+ #text(red, `1`)`.0.11`比#text(red, `0`)`.10.0`大，因为#text(red, `1`)大于#text(red, `0`)；
+ `1.`#text(red, `24`)`.1`比`1.`#text(red, `5`)`.11`大，因为#text(red, `24`)大于#text(red, `5`)；
+ `1.24.0`与`1.24.0`相等。

== 下载外部库

一般来说，使用外部库与导入本地模块一样简单。当你尝试导入一个外部库时，Typst会立即启动下载线程为你从网络下载外部库代码：

```typ
#import "@preview/fletcher:0.5.7" as fletcher: node, edge
```

一般情况下，从网络下载外部库的时间不会超过十秒钟，并且不需要任何额外配置。但由于不可描述的原因，你有可能需要为下载线程配置代理。当你希望通过网络代理下载外部库时，请检查全局环境变量`HTTP_PROXY`和`HTTPS_PROXY`是否成功设置。
+ 如果你的网络代理软件包含环境变量设置，请*优先*在你的网络代理环境中配置。
+ 否则如果你是Linux用户，请检查启动`typst-cli`或`vscode`的shell中，使用`echo $HTTP_PROXY`检查是否包含该环境变量。
+ 否则如果你是Windows用户，请使用`Win + R`快捷键呼出运行窗口，执行`system`#sym.zws`properties`#sym.zws`advanced`，调出「环境变量」窗口，并检查是否包含该环境变量。
  #figure(align(center, image("./systempropertiesadvanced.png", width: 50%)))

== 库文件夹

上一小节中的「命名空间」对应本地的一个或多个文件夹。

首先，Typst会感知你系统上的“数据文件夹”和“缓存文件夹”并在其中存储库代码。

Typst将会检查`{data-dir}/`#text(green, `typst/packages`)中是否包含相应的库，*随后*会在`{cache-dir}/`#text(green, `typst/packages`)中检查和缓存从网络下载的库代码。其中数据文件夹（`{data-dir}`）和缓存文件夹（`{cache-dir}`）在不同的操作系统上：

#{
  set align(center)
  table(
    columns: 3,
    [操作系统], [数据文件夹], [缓存文件夹],
    [Linux], [`$XDG_DATA_HOME`或`~/.local/share`], [`$XDG_CACHE_HOME`或`~/.cache`],
    [macOS], [`~/Library/Application Support`], [`~/Library/Caches`],
    [Windows], [`%APPDATA%`], [`%LOCALAPPDATA%`],
  )
}


#let breakable-path(..contents) = contents.pos().join([#sym.zws`/`#sym.zws])

例如，当引入外部库#breakable-path(
  text(red, `@preview`),
  [#text(eastern, `fletcher`)`:`#text(orange, `0.5.7`)],
)时，Typst会严格*按顺序*检查并解析路径：数据文件夹中的#breakable-path(
  `{data-dir}`,
  text(green, `typst/packages`),
  text(red, `preview`),
  text(eastern, `fletcher`),
  text(orange, `0.5.7`)
)和缓存文件夹中的#breakable-path(
  `{cache-dir}`,
  text(green, `typst/packages`),
  text(red, `preview`),
  text(eastern, `fletcher`),
  text(orange, `0.5.7`)
)。Typst会将库路径映射到你数据文件夹或缓存文件夹，优先按顺序使用已经存在的库代码，并按需从网络下载外部库。

这意味着你可以拥有以下几条特性。

- 若你已经下载了网络库到本地，再次访问将不会再产生网络请求和检查远程库代码的状态。
- 你可以将本地库存储到数据文件夹。特别地，你可以在数据文件夹中的`preview`文件夹中存储库，以*覆盖*缓存文件夹中已经下载的库。这有利于你调试或临时使用即将发布的外部库。
- 你可以在本地随意创建新的命名空间，对于#breakable-path(
  text(red, `@my-namespace`),
  [#text(eastern, `my-package`)`:`#text(orange, `version`)],
)，Typst将检查并使用你位于#breakable-path(
  `{data-dir}`,
  text(green, `typst/packages`),
  text(red, `my-namespace`),
  text(eastern, `my-package`),
  text(orange, `version`)
)的库代码。尽管Typst对命名空间没有限制，但建议你使用 #text(red, `@local`)作为所有本地库的命名空间。

== 构建和注册本地库

本小节教你如何构建和注册本地库。

=== 元数据文件

在库的*根目录*下必须有一个名称为`typst.toml`的元数据文件，这是对代码库的描述。内容示例如下：

```toml
[package]
name = "example"
version = "0.1.0"
entrypoint = "lib.typ"
```

最低限度你仅需要填入以上三个字段，分别对应其名字、版本号和入口文件的路径。

=== 入口文件

一般来说，该文件对应为库的根目录下的`lib.typ`文件。你可以使用本节提及的《变量导出的三种方式》编写该文件。当导入该库时，其中的「变量声明」将提供给文档使用。

=== 示例库的文件组织

假设你希望构建一个`@local/example:0.1.0`的外部库供本地使用。你应该将`example`库的文件夹*拷贝或链接*到#breakable-path(
  `{data-dir}`,
  text(green, `typst/packages`),
  text(red, `local`),
  text(eastern, `example`),
  text(orange, `0.1.0`)
)路径。

创建#breakable-path(
  `{data-dir}`,
  text(green, `typst/packages`),
  text(red, `local`),
  text(eastern, `example`),
  text(orange, `0.1.0`),
  `typst.toml`
)文件，并包含前文所述内容。

创建#breakable-path(
  `{data-dir}`,
  text(green, `typst/packages`),
  text(red, `local`),
  text(eastern, `example`),
  text(orange, `0.1.0`),
  `lib.typ`
)文件，并包含以下内容：

```typ
#import "add.typ": add
#import "sub.typ": sub
```

这样你就可以在本地的任意文档中使用库中的`add`或`sub`函数了：

```typ
#import "@local/example:0.1.0" as example: add
```

== 发布库到官方源

略

== 再谈「根目录」

出于安全考虑，每个库都*默认*只能访问其专属的「根目录」，即`typst.toml`文件所在的目录。这意味着，库中的绝对路径或相对路径依其专属的「根目录」解析。请回忆《绝对路径与相对路径》小节内容。例如在文件夹`@local/example:0.1.0`的内部，设使内部文件#breakable-path(
  `{data-dir}`,
  text(eastern, `{example-lib}`),
  `src/add-simd.typ`
)中包含这样的代码。

```typ
#read("/typst.toml")
#read("../typst.toml")
```

则「根目录」被解析为#breakable-path(
  `{data-dir}`,
  text(eastern, `{example-lib}`),
)，绝对路径`/typst.toml`被解析为#breakable-path(
  `{data-dir}`,
  text(eastern, `{example-lib}`),
  `typst.toml`
)，相对路径`../typst.toml`被解析为#breakable-path(
  `{data-dir}`,
  text(eastern, `{example-lib}`),
  `src`,
  `..`,
  `typst.toml`
)

== 函数与闭包中的路径解析

这里有一个微妙的问题。在函数或闭包中请求解析一个绝对路径或相对路径，Typst会如何做？答案是，任何路径解析都依附于路径解析代码所在文件。这句话有些晦涩，但例子却容易懂。这里举两个例子。

假设函数在文档相对于根目录的#breakable-path(
  text(eastern, `{example-lib}`),
  `src`,
  `m1.typ`
)中有这样一个函数：

```typ
#let parse-code(path) = parse-text(read(path))
```

那么无论我们在哪个文件引入了`parse-code`函数，其`read(path)`的路径解析都是固定的，其绝对路径相对于文档根目录，其相对路径相对于#breakable-path(
  text(eastern, `{example-lib}`),
  `src`,
  `m1.typ`
)所在目录。例如调用`parse-code("../def.typ")`时，其始终读取#breakable-path(
  text(eastern, `{example-lib}`),
  `src/../def.typ`
)文件。

我们上一小节说过，每个库都*默认*只能访问其专属的「根目录」。这种行为在有的时候不是你期望的，但你可以同样通过传递一个来自文档的闭包绕过该限制。例如，`parse-code`改写为：

```typ
#let parse-code(path, read-file: read) = parse-text(read-file(path))
```

并且在调用时传入一个读取文件的「回调函数」

```typ
#parse-code("../def.typ", read-file: (p) => read(p))
```
