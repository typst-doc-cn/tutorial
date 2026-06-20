#import "mod.typ": *

#show: book.page.with(title: "中文排版")

建议结合#link("https://typst-doc-cn.github.io/guide/")[《Typst中文社区导航：FAQ》]和#link("https://github.com/typst-doc-cn/guide")[FAQ源码仓库]食用。

从社区FAQ看，中文用户最常遇到的问题大致分为五类：

+ 字体问题：中文字体没有指定、字体名称写错、粗斜体变体缺失、中西字体混排时标点宽度不对。
+ 空白问题：源码换行多出空格、首段不缩进、公式和中文之间没有空白、代码块被两端对齐拉开。
+ 语义问题：中文一般不用西文斜体表达强调，着重、强调、伪粗体、伪斜体需要分清场景。
+ 特殊排版问题：中文编号、注音、着重号、填空线、均排和竖排等都能做，但难以处理复杂情况。
+ 参考文献问题：Typst内置了国标样式，但仍需处理中文文献的特殊情况，例如作者姓名、出版社、期刊名等。

下面按这些问题展开。

== 最小可用中文配置

如果你只想先写一篇中文文档，可以从下面的配置开始：

```typ
#set text(
  font: (
    (name: "New Computer Modern", covers: "latin-in-cjk"),
    "Source Han Serif SC",
  ),
  lang: "zh",
  region: "cn",
)
#set text(top-edge: "ascender", bottom-edge: "descender")
#set par(
  justify: true,
  leading: 0.75em,
  first-line-indent: (amount: 2em, all: true),
)
#show raw: set text(font: (
  (name: "DejaVu Sans Mono", covers: "latin-in-cjk"),
  "Noto Sans CJK SC",
))
```

这段配置做了四件事：

+ 西文使用`New Computer Modern`，中文回退到`Source Han Serif SC`。
+ `covers: "latin-in-cjk"`让西文字体只处理CJK语境里的拉丁字符，避免中文引号、破折号、省略号等共用标点误用西文字体。
+ `lang: "zh", region: "cn"`告诉Typst这是中国大陆中文文档。
+ 行距、文字外框和首行缩进按中文文档习惯略作调整。

== 中文排版 —— 字体

=== 设置中文字体

Typst默认没有预设任何系统中文字体。此时，中文很容易fallback到奇怪的字体上。例如，windows上常见正文使用楷体、代码片段使用隶书。稳妥的做法是直接设置中文字体：

#code(```typ
#set text(font: "Source Han Serif SC", lang: "zh", region: "cn")
这是一段使用思源宋体的中文。
```)

如果字体没有生效，一般按以下顺序排查：

+ 在VSCode/Tinymist中打开字体预览，查看服务器能识别的所有字体。
+ 使用`typst fonts`查看字体名称。
+ 在typst.app中首先点击`Ag`按钮查看可用字体。如果字体不在列表里，就要上传字体文件到根目录或根目录下的`fonts`文件夹。

有的时候遇到“字体存在但粗体不可用”的情况，这个时候要注意`typst fonts --variants`的输出，看对应字体是否有对应的字重。后文会讲在粗体或斜体不可用时，如何制作“伪粗体”或“伪斜体”。

=== 设置语言和区域

`lang`和`region`会影响语言相关的排版行为，所以强烈中文文档或中西混排文档设置这两个选项。若按大陆习惯排版，建议设置：

```typ
#set text(lang: "zh", region: "cn")
```

涉及影响的排版行为包括：列表数字的格式、日期的格式、智能引号的行为和标点挤压等行为。

=== 同时设置中西字体

中西混排最常用的做法是把西文字体放在前面，中文字体放在后面。

#code(```typ
#set text(font: (
  (name: "New Computer Modern", covers: "latin-in-cjk"),
  "Source Han Serif SC",
), lang: "zh", region: "cn")

分别设置“中文”和English字体。
```)

新版Typst的`covers`选项考虑到了一些unicode同时存在于西文字体和中文字体中的情况。当设置为`"latin-in-cjk"`时，选取`“”`、`——`、`……`等标点所用字体就会跳过`"New Computer Modern"`，进而选择使用`"Source Han Serif SC"`。

=== 引号与共用标点

当你已经分开设置了中西字体，建议中文使用unicode引号，而智能引号全部遵守西文规范：

#code(```typ
#set text(font: (
  (name: "New Computer Modern", covers: "latin-in-cjk"),
  "Source Han Serif SC",
))
#show smartquote: set text(font: "New Computer Modern")

这是“中文引号”。
This is "smart quote" and cha'DIch.
```)

=== 协调中西字号

有些中文字体和西文字体放在一起时，视觉大小并不协调。可以用正则表达式单独调整一类字符，但这属于模板层面的微调。

```typ
#show regex("[0-9\p{Latin}]+"): set text(size: 1.05em, baseline: 0.02em)
```

注意这里要用`+`一次匹配连续一串西文。若逐字符匹配，会破坏西文字体的字偶间距。

反过来，也可以匹配汉字：

```typ
#show regex("\p{Han}+"): set text(size: 0.95em)
```

这种办法不容易覆盖所有中文标点和特殊符号。

=== 伪粗体

如果中文没有加粗，首先值得怀疑的是你想用的字体是否真的自带粗体。思源宋体、思源黑体这类字体有较完整的字重：

#code(```typ
#set text(font: "Source Han Serif SC")
现在用的是*自带的粗体*。
```)

如果学校或单位要求必须使用宋体，而该字体没有粗体字形，可以考虑用`cuti`模拟Word式伪粗体：

#code(```typ
#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold
#set text(font: (
  (name: "New Computer Modern", covers: "latin-in-cjk"),
  "SimSun",
))

现在用的是*伪粗体*。
```)

伪粗体的原理是typst使用几何变换加粗了字形的线条，实际上不是作者本人设计，有的时候会看起来怪异。因此为了保持美观，所以还是优先使用自带粗体的中文字体。

=== 伪斜体

中文排版一般不用斜体表达强调。更常见的做法是用楷体、黑体、着重号或其它约定样式表达语义。

例如，你可以把强调语义改为楷体：

#code(```typ
#show emph: set text(font: (
  (name: "New Computer Modern", covers: "latin-in-cjk"),
  "Kaiti",
))

孔乙己_上大人_。
```)

`skew`强行倾斜可得到伪斜体，但是这只适合短语，因为`box`强制不换行：

#code(```typ
现在用的是#box(skew(ax: -12deg)[伪斜体])。
```)

=== 代码片段里的中文字体

正文的字体设置不影响代码片段。通常还需要单独设置等宽字体和CJK字体：

#code(```typ
#show raw: set text(font: (
  (name: "DejaVu Sans Mono", covers: "latin-in-cjk"),
  "Noto Sans CJK SC",
))

`printf("这是%d段代码", 1)`
```)

=== 公式里的中文字体

中文字体一般不支持用于显示数学公式。Typst 0.14中，较保守的写法是先给数学字体，再给中文字体：

#code(```typ
#show math.equation: set text(font: (
  "New Computer Modern Math",
  "Source Han Serif SC",
))

$ f(alpha) = "中文说明" $
```)

== 中文排版 —— 间距

=== 源码换行导致空格

Typst目前会把源码中的普通换行解释成一个小空格。如果在源码里的中文长段落手动换行，就会出现肉眼可见的空白。

#code(
  ```typ
  这是一句中文，
  这里源码换行会产生空格。

  这是一句中文，这里不中断源码行。
  ```,
  code-as: ```typ
  这是一句中文，
  这里源码换行会产生空格。

  这是一句中文，这里不中断源码行。
  ```,
)

最稳妥的办法是：正文段落不要手动换行，改用编辑器提供的“soft wrap”特性。若你确实需要源码按句断行，可以使用社区包清理CJK断行空格：

#code(```typ
#import "@preview/cjk-unbreak:0.2.1": remove-cjk-break-space
这是一句中文，
这里源码换行会产生空格。
#show: remove-cjk-break-space
这是一句中文，
空格被规则清除了。
```)

=== 首行缩进

Typst 0.13起，`par.first-line-indent`支持`all`选项，可以让标题后的第一段也缩进：

#code(```typ
#set par(first-line-indent: (amount: 2em, all: true))

首段也缩进。

之后段落同样缩进。
```)

但这也意味着公式、图表、列表后面的新段落可能被强制缩进。

如果行间公式后紧跟“其中，……”这类说明，通常不希望缩进，可以手动抵消：

```typ
#set par(first-line-indent: (amount: 2em, all: true))
#let noindent = context h(-par.first-line-indent.amount)

$ E = m c^2 $
#noindent 其中，$c$表示光速。
```

=== 行距和文字外框

Typst中，`par.leading`设置的是行与行之间额外的空隙。这与Word里“固定值22磅”的行高模型有所不同。可以考虑设置`text`的box模型改善差异，但仍然做不到一一对应：

#code(```typ
#let king = [Typst国王 \ Typst国王]

#set par(leading: 0.75em)
#king

#set text(top-edge: "ascender", bottom-edge: "descender")
#king
```)

复现Word模板时，实际只能是写完内容后手调`leading`，从而符合Word模板要求。

=== 非中文与中文文本之间的间距

英文文本与中文文本之间默认就有间距，而行内代码和数学公式没有这样的规则。

为了解决行内代码问题，可以统一给行内`raw`两侧加弱空白：

#code(```typ
#show raw.where(block: false): it => h(0.2em, weak: true) + it + h(0.2em, weak: true)

中文`code`中文
```)

`weak: true`表示这个空白在行首、行尾等位置可以被丢弃。数学公式可使用相同的方法处理。

#code(```typ
#show math.equation.where(block: false): it => h(0.25em, weak: true) + it + h(0.25em, weak: true)

汉字$A$汉字
```)

=== 固定宽度汉字与均排

表单、词典或合同里常见“姓名”“身份证”“详细地址”这类词组等宽均排。可以把词组放入定宽容器，并在末尾强制两端对齐：

#code(```typ
#let distr(width: 5em, body) = block(
  width: width,
  body + linebreak(justify: true),
)

#distr[姓名]
#distr[身份证]
#distr[详细地址]
```)

== 中文排版 —— 特殊排版

=== 使用中文编号

Typst内置的`numbering`已经支持不少中文编号格式。标题按“第一章”编号的规则如下：

#code(```typ
#set heading(numbering: "第一章")

= 背景
= 方法
```)

有时需要“一、”这样的编号，也可以这样写，但是有一段```typc h(0.3em)```的固定空白：

#code(```typ
#text(22pt)[三、背景]

#set heading(numbering: "一、")

= 背景
```)

虽然有些“脏”，但是可以使用`h`抵消空白：

```typ
#set heading(numbering: n => numbering("一、", n) + h(-0.3em))
```

如果各级标题编号规则差别很大，例如一级是“第1章”，二级是“1.1”，三级是“(a)”，建议使用`numbly`：

```typ
#import "@preview/numbly:0.1.0": numbly
#set heading(numbering: numbly(
  "第{1}章",
  "{1}.{2}",
  "({3:a})",
))
```

=== 为汉字和词组注音

Typst没有内置完整的中文注音系统。短文档可以使用`rubby`包：

```typ
#import "@preview/rubby:0.10.2": get-ruby
#let ruby = get-ruby(size: 0.5em, delimiter: "|")

#ruby[zhù|yīn][注|音]
#ruby[zhōng|wén][中|文]
```

`rubby`的参数顺序是先写注音，再写正文。词组注音时，用同一个分隔符把注音和正文切成相同数量的片段。

=== 为汉字添加着重号

中文的着重语义不一定要显示成粗体。你可以把`strong`改成汉字上方或下方的着重号：

#pro-tip[
  以下例子只演示思路。正式模板里还需要微调圆点大小、位置和中西混排边界。

  #code(```typ
  #show strong: content => {
    show regex("\p{Hani}"): it => box(
      place(text("·", size: 0.8em), dx: 0.375em, dy: 0.75em) + it
    )
    content.body
  }

  *中文排版的着重语义可以用加点表示。*
  ```)
]

这个例子也说明了本书前面反复强调的原则：先标记语义，再决定样式。你仍然写`*重点*`，只是把它在中文模板里的显示方式换掉。

=== 下划线和填空线

下划线是文本修饰，填空线是表单结构。二者最好分开处理。

普通下划线可以直接使用`underline`：

#code(```typ
#underline[这是一段下划线文本]
```)

如果中英文下划线位置看起来不一致，可以微调`offset`和`stroke`：

```typ
#set underline(offset: 0.1em, stroke: 0.05em, evade: false)
```

但如果你要的是试卷、合同里的空白填线，更稳妥的是用`box`指定长度：

#code(```typ
#let uline(width, body) = box(
  align(center, body),
  width: width,
  stroke: (bottom: 0.5pt),
  outset: (bottom: 2pt),
)

日期：#uline(3em)[2026]年#uline(1em)[6]月
```)

=== 竖排文本

Typst目前没有完整的官方竖排支持。简单短句可以用`stack`把字符竖着排出来：

```typ
#let vertical(s) = stack(
  dir: ttb,
  spacing: 0.1em,
  ..s.clusters().map(ch => [#ch]),
)

#vertical("春眠不觉晓")
```

这只适合标题、印章、装饰性短文本。还没有办法在Typst里支持真正的中文竖排。

=== 使用国标文献格式

#todo-box[本书作者没使用过中文参考文献。]

更多参考文献细节见#(refs.ref-bibliography)[《参考文献》]。

== 旧版本与兼容性

中文排版相关问题随Typst版本变化很快。许多问题都已得到内置实现改善：

+ 首段缩进：Typst 0.13起可用```typc first-line-indent: (amount: 2em, all: true)```。
+ 代码块两端对齐：Typst 0.13起块级`raw`默认不再继承正文两端对齐。
+ 代码块中西文额外间距：Typst 0.13起`raw`中的相关默认行为已改进。
+ 公式里的中文字体：Typst 0.13起`covers`让分字符选择字体更可控；Typst 0.14又调整了数学基准字体的选择规则。
+ 引用上标：Typst 0.14已修复部分字体导致数字和括号高度不一致的问题。

如果想要使用某个旧模板，应先确认你使用的Typst版本，再考虑删除这些补丁。盲目复制旧补丁，反而可能制造新的问题。

== 进一步阅读

+ 参考#link("https://typst-doc-cn.github.io/guide/")[《Typst中文社区导航：FAQ》]，其中包含大量中文用户常见问题。
+ 参考#link("https://typst-doc-cn.github.io/clreq/")[`clreq-gap for typst`]，了解Typst与中文排版需求之间的差距。
+ 参考#link("https://typst.app/universe/")[Typst Universe]，查找`rubby`、`cuti`、`numbly`等社区包。
