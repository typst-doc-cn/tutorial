#import "mod.typ": *

#show: book.page.with(title: [导引])

本书面向所有Typst用户，按三种方式讲解Typst知识。《教程》等章节循序渐进，讲述了Typst的排版方式和原理；《参考》等章节拓展广度；《专题》等则专注解决具体问题。本书希望缓解Typst相关资料严重缺失的问题，与官方文档相互补充，帮助大家入门和学习Typst。

本教程的首要定位是，即便你没有学习过任何编程语言，也能通过在本教程中学到的知识上手使用Typst，在日常生活中使用Typst编写各式各样的文档。同时，本教程也会总结在使用Typst编写文档的过程中遇到的一系列问题。

== 为什么学习Typst？

在开始之前，让我们考虑一下 Typst 到底是什么，以及我们在什么时候应该使用它。 Typst 是一种用于排版文档的标记语言，它旨在易于学习、快速且用途广泛。 Typst 输入带有标记的文本文件，并将其输出为 PDF 格式。

Typst 是撰写长篇文本（如论文、文章、书籍、报告和作业）的极佳选择。 并且，Typst 非常适合书写包含数学公式的文档，例如数学、物理和工程领域的论文。 此外，由于其强大的样式和自动化功能，它是编写具有相同样式的一系列文档（例如丛书）的绝佳选择。

== 阅读本教程前，您需要了解的知识

你不需要了解任何前置知识，所需的仅仅是安装Typst，并跟着本教程的在线示例一步步学习。

== 其他参考资料

- #link("https://typst-doc-cn.github.io/docs/tutorial/")[官方文档翻译 - 入门教程]
- #link("https://typst-doc-cn.github.io/docs/chinese/")[非官方中文用户指南]
- #link("https://typst-doc-cn.github.io/docs/reference/")[官方文档翻译 - 参考]
- #link("https://sitandr.github.io/typst-examples-book/book/about.html")[Typst Example Books]

= 配置Typst运行环境

== 使用官方的webapp（推荐）

官方提供了*在线且免费*的多人协作编辑器。该编辑器会从远程下载WASM编译器，并在你的浏览器内运行编辑器，为你提供预览服务。

#figure(image("/assets/files/editor-webapp.png"), caption: [本书作者在网页中打开webapp的瞬间])

该编辑器的速度相比许多LaTeX编辑器都有显著优势。这是因为：
- 你的大部分编辑操作不会导致阻塞的网络请求。
- 所有计算都在本地浏览器中运行。
- 编译器本身性能极其优越。

你可以注册一个账户并开箱即用该编辑器。

*注意：你需要检测你的网络环境，如有必要请使用科学上网工具（VPN等）。*

== 使用VSCode编辑（推荐）

打开扩展界面，搜索并安装 tinymist 插件。它会为你提供语法高亮，代码补全，代码格式化，即时预览等功能。

#figure(image("/assets/files/editor-vscode.png"), caption: [本书作者在VSCode中预览并编辑本文的瞬间])

该编辑器的速度相比webapp略慢。这是因为：
- 编译器与预览程序是两个不同的进程，有通信开销。
- 用户事件和文件IO有可能增加E2E延时。

但是：
- 大部分时间下，你感受不到和webapp之间的性能差异。Typst真的非常快。
- 你可以离线编辑Typst文档，无需任何网络连接，例如本书的部分章节是在飞机上完成的。
- 你可以在文件系统中管理你所有的源代码，实施包括但不限于使用git等源码管理软件等操作。

== 使用neovim编辑

细节可以问群友。

自去年年底，该编辑器与VSCode一样，已经可以有很好的Typst编辑体验。

== 使用Emacs编辑

可以问群友。

自今年年初，该编辑器与VSCode一样，已经可以有很好的Typst编辑体验。

== 使用typst-cli与PDF阅读器

Typst 的 CLI 可从不同的来源获得：

- 你可以获得最新版本的 Typst 的源代码和预构建的二进制文件来自#link("https://github.com/typst/typst/releases/")[发布页面]。下载适合你平台的存档并将其放在“ PATH ” 中的目录中。及时了解未来发布后，你只需运行```bash typst update```即可。
- 你可以通过不同的包管理器安装Typst。请注意，包管理器中的版本可能落后于最新版本。
  - Linux：查看#link("https://repology.org/project/typst/versions")[Typst on Repology]。
  - macOS：```bash brew install typst```。
  - Windows：```bash winget install --id Typst.Typst ```。
- 如果您安装了#link("https://rustup.rs/")[Rust]工具链，您还可以安装最新开发版本```bash cargo --git https://github.com/typst/typst --locked typst-cli```。请注意，这将是一个“夜间”版本，可能已损坏或尚未正确记录。
- Nix用户可以将`typst`包与```bash nix-shell -p typst```一起使用，或者构建并使用```bash nix run github:typst/typst -- --version```运行前沿版本。
- Docker用户可以运行预构建的镜像```bash docker run -it ghcr.io/typst/typst:latest ```.

安装好CLI之后，你就可以在命令行里运行Typst编译器了：

```bash
# Creates `file.pdf` in working directory.
typst compile file.typ

# Creates PDF file at the desired path.
typst compile path/to/source.typ path/to/output.pdf
```

为了提供预览服务，你需要让Typst编译器运行在监视模式（watch）下：

```bash
# Watches source files and recompiles on changes.
typst watch file.typ
```

当你启动Typst编译器后，你可以使用你喜欢的编辑器编辑Typst文档，并使用你喜欢的PDF阅读器打开编译好的PDF文件。PDF阅读器推荐使用：

- 在Windows下使用#link("https://www.sumatrapdfreader.org/free-pdf-reader")[Sumatra PDF]。

== 各Typst运行环境的比较

#{
  set align(center)
  table(
    columns: if get-page-width() < 500pt {
      (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr)
    } else {
      (1fr, 1fr, 1fr, 5em, 5em, 5em, 10em)
    },
    align: horizon + center,
    [名称], [编辑器], [编译器环境], [预览方案], [是否支持即时编译], [语言服务], [备注],
    [WebAPP], [Code Mirror], [wasm], [渲染图片], [是], [优秀], align(left)[开箱即用],
    [VSCode], [VSCode], [native], [webview], [是], [良好], align(left)[简单上手，定制性差],
    [neovim], [neovim], [native], [webview], [是], [良好], align(left)[不易安装，定制性好],
    [Emacs], [Emacs], [native], [webview], [是], [良好], align(left)[难以安装],
    [typst-cli], [任意编辑器], [native], [任意PDF阅读器], [否], [无], align(left)[简单上手，灵活组合],
  )
}

= 如何阅读本书

本书主要分为三个部分：

+ 教程：介绍Typst的语法、原理和理念，以助你深度理解Typst。
+ 参考：完整介绍Typst中内置的函数和各种外部库，以助你广泛了解Typst的能力，用Typst实现各种排版需求。
+ 专题等：与参考等章节的区别是，每个专题都专注解决一类问题，而不会讲解函数的用法。

每个部分都包含大量例子，它们各有侧重：

- 教程中的例子希望切中要点，而避免冗长的全面的展示特性。
- 参考中的例子希望讲透元素和函数的使用，例子多选自过去的一年中大家常问的问题。
- 专题中的例子往往有连贯性，从前往后带你完成一系列专门的问题。专题中的例子假设你已经掌握了相关知识，只以最专业的代码解决该问题。

#pro-tip[
  本书会随时夹带一些“Pro Tip”。这些“Pro Tip”由蓝色框包裹。它们告诉你一些较难理解的知识点。

  你可以选择在初次阅读时*跳过*这些框，而不影响对正文的理解。但建议你在阅读完整本书后回头观看所不理解的那些“Pro Tip”。
]

以下是推荐的阅读方法：

+ 首先阅读《基础教程》排版Ⅰ的两篇文章，既《初识标记模式》和《初识脚本模式》。

  经过这一步，你应该可以像使用Markdown那样，编写一篇基本不设置样式的文档。同时，这一步的学习难度也与学习完整Markdown语法相当。

+ 接着，阅读《基础教程》脚本Ⅰ的三篇文章。

  经过这一步，你应该已经基本入门了Typst的标记和脚本。此时，你和进阶用户的唯一区别是，你还不太会使用高级的样式配置。推荐：
  - 如果你熟练阅读英语，推荐主要参考#link("https://typst.app/docs/")[官方文档]的内容。
  - 否则，推荐继续阅读本书剩下的内容，并参考#link("https://typst-doc-cn.github.io/docs/")[非官方中文文档]的内容。

  有什么问题？
  - 本书只有《基础教程》完成了校对和润色，后续部分还非常不完善。甚至《基础教程》部分还有待改进。
  - #link("https://typst-doc-cn.github.io/docs/")[非官方中文文档]是GPT机翻后润色的的结果，有可能错翻、漏翻，内容也可能有些许迟滞。

+ 接着，阅读《基础教程》脚本Ⅱ和排版Ⅲ的五篇文章。

  这两部分分别介绍了如何使用Typst的模块机制与状态机制。模块允许你将文档拆分为多个文件。状态则类似于其他编程语言中的全局变量的概念，可用于收集和维护数据。

+ 最后，同时阅读《基础参考》和《进阶教程》。你可以根据你的需求挑选《基础参考》的部分章节阅读。即便不阅读任何《基础参考》中的内容，你也可以继续阅读《进阶教程》。

  经过这一步，你应该已经完全学会了目前Typst的所有理念与内容。

= 许可证

*typst-tutorial-cn* 所有的源码和文档都在#link("https://www.apache.org/licenses/LICENSE-2.0")[Apache License v2.0]许可证下发布.
