#import "mod.typ": *

#show: book.page.with(title: "编写一篇中文文档")

建议结合#link("https://typst-doc-cn.github.io/docs/chinese/")[《Typst中文文档：中文用户指南》]食用。

== 中文排版 —— 字体

== 设置中文字体

如果中文字体不符合 typst 要求，那么它不会选择你声明的字体，例如字体的变体数量不够，参考更详细的 issue。

+ typst fonts 查看系统字体，确保字体名字没有错误。
+ typst fonts --font-path path/to/your-fonts 指定字体目录。
+ typst fonts --variants 查看字体变体。
+ 检查中文字体是否已经完全安装。

== 设置语言和区域

如果字体与 ```typc text(lang: .., region: ..)``` 不匹配，可能会导致连续标点的挤压。例如字体不是中国大陆的，标点压缩会出错；反之亦然。

=== 伪粗体

=== 伪斜体

=== 同时设置中西字体（以宋体和Times New Roman为例）

== 中文排版 —— 间距

=== 首行缩进

#let fake-par = style(styles => {
  let b = par[#box()]
  let t = measure(b + b, styles);

  b
  v(-t.height)
})

=== 代码片段与中文文本之间的间距

=== 数学公式与中文文本之间的间距

== 中文排版 —— 特殊排版

=== 使用中文编号

=== 为汉字和词组注音

=== 为汉字添加着重号

=== 竖排文本

=== 使用国标文献格式

== Typst v0.10.0为止的已知问题及补丁

=== 源码换行导致linebreak

=== 标点字体fallback

== 模板参考

#link("https://github.com/typst-doc-cn/tutorial/blob/b452e6ec436aa150a6429becb8cf046d08360f63/typ/templates/page.typ")[本书各章节使用的模板]

todo: 内嵌和超链接可直接食用的模板

== 进一步阅读

+ 参考#link("https://typst-doc-cn.github.io/docs/chinese/")[《Typst中文文档：中文用户指南》]，包含中文用户常见问题。
+ 参考#(refs.scripting-modules)[《模块、外部库与多文件文档》]，在你的电脑上共享中文文档模板。
+ 推荐使用的外部库列表
