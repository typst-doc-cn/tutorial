#import "mod.typ": *

#show: book.page.with(title: "数学排版")

建议结合#link("https://typst-doc-cn.github.io/guide/FAQ.html")[《Typst中文社区导航：FAQ》]和#link("https://sitandr.github.io/typst-examples-book/book/basics/math/index.html")[`Typst Examples Book`的数学章节]食用。

读完这一章，你应该能够编写常见数学文档。

== 数学模式

Typst有三种解释模式：标记模式、脚本模式和数学模式。数学模式用一对`$`进入。

=== 行内公式和行间公式

`$`内部两侧如果都有空白那么就是行间公式，否则是行内公式：

#code(```typ
行内公式：设$lim_(n -> oo) F_n$收敛到$F$。

行间公式：
$ A = {x | x in NN and x < 10} $
```)

行内公式适合短变量、短表达式；行间公式适合需要独占一行、需要编号、需要多行对齐的公式。行间公式默认有行间样式，但你可以强行让行内公式使用行间样式：

#code(```typ
行内公式：设$display(lim_(n -> oo) F_n)$收敛到$F$。
```)

#pro-tip[
  不建议用全局规则把所有行内公式都变成`display`，因为这导致行间距不均匀。
]

=== 多字母文本

数学模式有一条很重要的规则：单字母通常被当作文本，多字母标识符被直接当作变量。

#code(```typ
$ a + b = c $

$ alpha in RR $
```)

这里的`a`、`b`、`c`是文本；`alpha`和`RR`是已定义的数学符号（变量）。

如果你想写普通文字，使用引号：

#code(```typ
$ a " equals " 2 $

$ f(x) = 0 "，其中 " x in RR $
```)

// 如果你想写正体函数名或正体运算符，不要用普通字符串凑空格，而应使用内置运算符或`op`：

// #code(```typ
// #let arcsinh = math.op("arcsinh")

// $ lim_(x -> oo) f(x) $

// $ arcsinh x $
// ```)

=== 数学模式里回到脚本模式

数学模式中可以用`#`临时回到脚本模式。例如把脚本变量插入公式：

#code(```typ
#let n = 5

$ sum_(k=1)^#n k = #(n * (n + 1) / 2) $
```)

有些数学函数的参数本来就需要脚本值，例如`lr(..., size: #150%)`里的`#150%`。

== 数学符号

你可以从多个渠道了解如何输入数学符号。

=== 官方符号表

Typst符号一般有组合规律。方向、大小、否定、填充等常常写成点号后缀：

#code(```typ
$ arrow.r, arrow.l, arrow.t, arrow.b $

$ lt, lt.eq, lt.not, lt.eq.not $

$ square, square.filled, plus.o, plus.o.big $
```)

常用希腊字母也按名字输入：

#code(```typ
$ alpha, beta, gamma, Gamma, pi, pi.alt, theta, theta.alt $
```)

如果不知道符号名，首先查#link("https://typst.app/docs/reference/symbols/sym/")[官方符号表]，也可以看本书的#(refs.ref-math-symbols)[《常用数学符号》]。

=== Detypify

符号表很全，但人不一定知道应该搜索什么关键词。此时可以用#link("https://detypify.quarticcat.com/")[Detypify]：在网页里手写一个符号，它会给出可能的Typst符号名。

Tinymist也集成了这个工具。VSCode里可以打开#link("https://myriad-dreamin.github.io/tinymist/editors/vscode#symbol-view")[Tinymist的符号视图]，使用离线手写识别查找符号；它背后使用的就是Detypify。

=== 常见字母变体

黑板粗体可以直接用常见双写名称，也可以用`bb`：

#code(```typ
$ AA, BB, CC, NN, QQ, RR, ZZ $

$ bb(A), bb(1) $
```)

花体和手写体对应于`cal`和`scr`：

#code(```typ
$ cal(L) != scr(L) $
```)

不同数学字体对`cal`、`scr`、`emptyset`等符号的字形并不完全相同。如果你追求和LaTeX默认效果完全一致，可能需要换数学字体。

=== 空集符号

Typst里可以写：

#code(```typ
$ A inter B = emptyset $

$ A inter B = nothing $

$ diameter $
```)

有些人想要LaTeX里`\varnothing`那种更圆的空集字形。若数学字体支持对应OpenType特性，可以开启字符变体：

```typ
#show math.equation: set text(features: ("cv01",))

$ A inter B = emptyset $
```

== 基本结构

=== 上下标

上下标分别用`_`和`^`：

#code(```typ
$ x_i, x^2, x_i^2 $
```)

如果上下标内容不止一个简单元素，就用圆括号分组。

#code(```typ
$ x_(i + 1)^2 $
```)

=== 分数和普通斜杠

在数学模式中，`/`会尽量形成分数：

#code(```typ
$ a / b $

$ (a + b) / 2 $

$ 1 / (1 + x^n) $
```)

如果你只是想显示普通斜杠，可以转义：

#code(```typ
$ a \/ b $
```)

=== 分组和可伸缩括号

圆括号既能表示真实括号，也能用于分组。Typst会在许多成对括号上自动使用可伸缩的`lr`效果：

#code(```typ
$ ((a + b) / 2)_0 $

$ [((a + b) / 2) + 1]_0 $
```)

如果你要手动匹配不同种类的括号，使用`lr`：

#code(```typ
$ lr([ a / 2, b )) $

$ lr([ a / 2, b ), size: #150%) $
```)

绝对值和范数这类左右“括号”长得一样的标记建议直接使用对应的数学函数：

#code(```typ
$ abs(a + b), norm(v), floor(x), ceil(x), round(x) $
```)

=== 重音和修饰

常见重音函数包括`hat`、`tilde`、`dot`、`arrow`等：

#code(```typ
$ hat(f), tilde(x), dot(x), dot.double(x), arrow(v) $
```)

向量箭头常常会反复使用，可以自己起一个短名：

#code(```typ
#let arr = math.arrow

$ arr(v) = arr(a) + arr(b) $
```)

== 多行公式和对齐

=== 换行

行间公式中可以用反斜杠换行：

#code(```typ
$
a = b \
a = c
$
```)

=== 公式对齐

与LaTeX相同，Typst使用`&`对齐公式：

#code(```typ
$
f(x) &= x^2 + 2x + 1 \
     &= (x + 1)^2
$
```)

`&`会让相邻列交替右对齐和左对齐。你可以利用这一点在等号、说明文字之间排出整齐的多行公式：

#code(```typ
$
(3x + y) / 7 & = 9        && "given" \
3x + y       & = 63       &  "multiply by 7" \
3x           & = 63 - y   && "subtract y" \
x            & = 21 - y/3 &  "divide by 3"
$
```)

=== 公式整体对齐

行间公式默认居中。如果确实需要改成右对齐或左对齐，可对`math.equation`设置对齐：

#code(```typ
#show math.equation: set align(left)

$ (a + b) / 2 $
```)

也可以只调整某一个公式：

#code(```typ
#align(left, block($ x = 5 $))
```)

== 向量、矩阵和cases

=== 向量

列向量用`vec`：

#code(```typ
$ vec(a, b, c) + vec(1, 2, 3) = vec(a + 1, b + 2, c + 3) $
```)

可以设置括号样式和行距：

#code(```typ
$ vec(1, 2, 3, delim: "[") $

$ vec(1, 2, 3, delim: #none) $

$ vec(1, 2, 3, gap: #0.8em) $
```)

如果整篇文档都想用方括号向量：

#code(```typ
#set math.vec(delim: "[")

$ vec(a, b, c) $
```)

=== 矩阵

矩阵用`mat`，行与行之间用分号分隔：

#code(```typ
$ mat(
  1, 2, 3;
  4, 5, 6;
  7, 8, 9;
) $
```)

矩阵也可以设置括号和间距：

#code(```typ
#set math.mat(delim: "[")

$ mat(1, 2; 3, 4) $
```)

如果你觉得方括号离数字太近，可以局部造一个带额外空白的函数：

#code(```typ
#let mat(..args) = $lr([med #math.mat(..args, delim: none) med])$

$ mat(2, 3, 4; 5, 6, 7; 8, 9, 9) $
```)

=== 分段函数

分段函数用`cases`：

#code(```typ
$ f(x) = cases(
  x^2 & "if " x >= 0,
  -x  & "otherwise",
) $
```)

`cases`中的列默认偏左，这是有意设计。若只需要普通分段函数，保持默认即可。

如果`cases`里的分数太小，可以把每一行转成`display`：

#```typ
#let dcases(..args) = math.cases(
  ..args.pos().map(math.display),
  ..args.named(),
)
```

== 运算符和间距

=== 内置运算符

`lim`、`sin`、`log`、`det`等是内置正体运算符，他们会与其他符号间自动产生合适间距：

#code(```typ
$ lim_(x -> oo) sin x / x = 1 $

$ det(A B) = det(A) det(B) $
```)

自定义运算符使用`math.op`：

#code(```typ
#let rank = math.op("rank")

$ rank A <= min(m, n) $
```)

如果这个运算符需要像`lim`一样把上下标放在正上方和正下方，可以设置`limits`：

#code(```typ
#let liminf = math.op("liminf", limits: true)

$ liminf_(n -> oo) a_n $
```)

=== 正体、粗体和数学类

LaTeX里的`\mathrm`和`\mathbf`在Typst里可以这样写：

#code(```typ
#let mathrm(x) = math.upright(x)
#let mathbf(x) = math.bold(math.upright(x))

$ y = 3 + 4 mathrm(i) $

$ nabla times mathbf(H) $
```)

如果某个符号的前后空白不符合语义，通常是它的数学类不对。可以用`class`改变排版类别：

#code(```typ
$ *x $

$ y + class("unary", *) x $
```)

=== 上下限

行内和行间公式的上下限位置不同。可以对单个符号使用`limits`或`scripts`：

#code(```typ
$ integral_0^1 f(x) dif x $

$ limits(integral)_0^1 f(x) dif x $

$ sum_(i=1)^n i, scripts(sum)_(i=1)^n i $
```)

如果只想让行间积分默认使用上下限，而不影响行内公式：

#code(```typ
#show math.integral: math.limits.with(inline: false)

$ integral_0^1 f(x) dif x $

行内：$integral_0^1 f(x) dif x$
```)

== 编号和引用

=== 开启公式编号

公式编号属于`math.equation`的设置：

#code(```typ
#set math.equation(numbering: "(1)")

$ E = m c^2 $ <eq-energy>

见 @eq-energy。
```)

这里`<eq-energy>`是标签，`@eq-energy`会引用这个公式。实际写作中，标签名建议有意义，例如`<eq:navier-stokes>`或`<eq-energy>`。

如果整篇文档不想给所有行间公式编号，就不要全局开启编号。可以只对特定公式调用`math.equation`：

#code(```typ
#math.equation(
  $ a + b = c $,
  block: true,
  numbering: _ => "(*)",
)
```)

=== 单个公式手动编号

有时需要类似LaTeX `\tag{}`的效果，可以给单个公式传入自定义`numbering`函数：

#counter(math.equation).update(0)
#code(```typ
#set math.equation(numbering: "(1)")

$ f(x) $

#math.equation($g(x)$, block: true, numbering: _ => "(foo)")

$ h(x) $
```)

更复杂的需求，例如“默认不编号，只给带标签的公式编号”或“子公式编号”，可以用社区包或自定义`show math.equation`规则实现。那已经超出基础写作范围，建议直接参考中文FAQ的公式编号条目。

== 从LaTeX迁移

一些简单常用的规则：

+ `\alpha`写成`alpha`。
+ `\frac{a}{b}`通常写成`a / b`。
+ `\left...\right`通常由成对括号或`lr`处理。
+ `\mathrm`、`\mathbf`可用`upright`、`bold`组合。
+ `\operatorname{rank}`可用`math.op("rank")`。
+ `\tag{...}`对应单个`math.equation(..., numbering: ...)`。

如果你手头有大量LaTeX公式，可以临时使用`mitex`包转换或嵌入：

```typ
#import "@preview/mitex:0.2.6": *

#mitex(`\int_{-\infty}^\infty \hat f(\xi) e^{2\pi i \xi x}\,d\xi`)
```

== 常见排错

== 进一步阅读

+ 参考#link("https://typst-doc-cn.github.io/guide/FAQ.html")[《Typst中文社区导航：FAQ》]中的`math`、`equation`、`symbol`、`font`相关问题。
+ 参考#link("https://sitandr.github.io/typst-examples-book/book/basics/math/index.html")[`Typst Examples Book`的数学章节]，其中有更密集的公式示例。
+ 参考#link("https://typst.app/docs/reference/math/")[Typst官方数学参考]和#link("https://typst.app/docs/reference/symbols/sym/")[官方符号表]。
+ 参考#link("https://detypify.quarticcat.com/")[Detypify]，用手写方式反查符号名。
+ 在VSCode中使用Tinymist时，可以打开#link("https://myriad-dreamin.github.io/tinymist/editors/vscode#symbol-view")[符号视图]和符号补全；Tinymist的离线手写识别由Detypify提供支持。
