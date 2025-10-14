#import "@preview/shiroa:0.2.3": *

#show: book

#let book-info = json("/meta.json")

#book-meta(
  title: "The Raindrop-Blue Book (Typst中文教程)",
  description: "Typst中文教程",
  repository: "https://github.com/typst-doc-cn/tutorial",
  repository-edit: "https://github.com/typst-doc-cn/tutorial/edit/main/src/{path}",
  authors: book-info.contributors,
  language: "zh-cn",
  summary: [
    #prefix-chapter("introduction.typ")[导引]
    = 模式
    - #chapter("tutorial/writing-markup.typ")[标记模式]
    - #chapter("tutorial/writing-scripting.typ")[脚本模式]
    = 脚本
    - #chapter("tutorial/scripting-literal.typ")[基本类型]
    - #chapter("tutorial/scripting-variable.typ")[变量与函数]
    - #chapter("tutorial/scripting-composite.typ")[复合类型]
    - #chapter("tutorial/doc-modulize.typ")[模块化（多文件）]
    - #chapter("tutorial/scripting-block-and-expression.typ")[表达式]
    - #chapter("tutorial/scripting-control-flow.typ")[控制流]
    - #chapter("tutorial/doc-stateful.typ")[状态化]
    = 中文排版
    - #chapter("tutorial/scripting-main.typ")[编译流程]
    - #chapter("tutorial/writing-chinese.typ")[中文排版]
    - #chapter("tutorial/scripting-style.typ")[样式模型]
    = 科技排版
    - #chapter("tutorial/writing-math.typ")[数学排版]
    - #chapter("tutorial/scripting-shape.typ")[图形排版]
    - #chapter("tutorial/scripting-layout.typ")[布局模型]
    - #chapter("tutorial/scripting-content.typ")[文档模型]
    = 附录
    // - #chapter("tutorial/reference-grammar.typ")[语法示例检索表]
    - #chapter("tutorial/reference-utils.typ")[常用函数表]
    - #chapter("tutorial/reference-math-symbols.typ")[常用数学符号]
    - #chapter(none)[特殊Unicode字符]
    = 参考
    - #chapter("tutorial/reference-typebase.typ")[基本类型]
    - #chapter("tutorial/reference-type-builtin.typ")[内置类型]
    - #chapter("tutorial/reference-date.typ")[时间类型]
    // - #chapter("tutorial/reference-visualization.typ")[图形与几何元素]
    // - #chapter("tutorial/reference-color.typ")[颜色、色彩渐变与模式]
    - #chapter("tutorial/reference-data-process.typ")[数据读写]
    - #chapter("tutorial/reference-data-process.typ")[数据处理]
    - #chapter("tutorial/reference-calculation.typ")[数值计算]
    - #chapter("tutorial/reference-math-mode.typ")[数学模式]
    - #chapter("tutorial/reference-bibliography.typ")[参考文献]
    - #chapter("tutorial/reference-wasm-plugin.typ")[WASM插件]
    // = 进阶教程 — 排版Ⅳ
    // 6. 脚本Ⅱ
    // - IO与数据处理
    // - 内置类型
    // - 数值计算
    // - WASM插件
    // 7. 排版Ⅱ
    // - 代码高亮
    // - 参考文献
    // - 文档大纲
    // 8. 科技排版
    // - 数学模式
    // - 数学公式和定理
    // - 物理公式
    // - 化学方程式
    // 9. 图表
    // - 立体几何
    // - 统计图
    // - 状态机
    // - 电路图
    // 10. 模板
    // 11. 参考Ⅰ
    // - 基本类型
    // - 内置类型
    // - 时间
    // - 高级颜色
    // - 长度单位
    // 12. 参考Ⅱ
    // - 图形
    = 专题
    - #chapter("topics/writing-math.typ")[编写一篇数学文档]
    // https://github.com/PgBiel/typst-oxifmt/blob/main/oxifmt.typ
    // - #chapter("topics/format-lib.typ")[制作一个格式化库]
    // https://github.com/Pablo-Gonzalez-Calderon/showybox-package/blob/main/showy.typ
    - #chapter("topics/writing-component-lib.typ")[制作一个组件库]
    - #chapter("topics/writing-plugin-lib.typ")[制作一个外部插件]
    - #chapter("topics/call-externals.typ")[在Typst内执行Js、Python、Typst等]
    // https://github.com/frugal-10191/frugal-typst
    - #chapter("topics/template-book.typ")[制作一个书籍模板]
    // chicv
    - #chapter("topics/template-cv.typ")[制作一个CV模板]
    // official template
    - #chapter("topics/template-paper.typ")[制作一个IEEE模板]
    = 专题 — 公式和定理
    - #chapter("science/chemical.typ")[化学方程式]
    - #chapter("science/algorithm.typ")[伪算法]
    - #chapter("science/theorem.typ")[定理环境]
    = 专题 — 杂项
    - #chapter("misc/font-setting.typ")[字体设置]
    // - #chapter("misc/font-style.typ")[伪粗体、伪斜体]
    - #chapter("misc/code-syntax.typ")[自定义代码高亮规则]
    - #chapter("misc/code-theme.typ")[自定义代码主题]
    - #chapter("misc/text-processing.typ")[读取外部文件和文本处理]
    = 专题 — 绘制图表
    - #chapter("graph/table.typ")[制表]
    - #chapter("graph/solid-geometry.typ")[立体几何]
    - #chapter("graph/digraph.typ")[拓扑图]
    - #chapter("graph/statistics.typ")[统计图]
    - #chapter("graph/state-machine.typ")[状态机]
    - #chapter("graph/electronics.typ")[电路图]
    = 专题 — 附录Ⅱ
    - #chapter("tutorial/reference-grammar.typ")[语法示例检索表Ⅱ]
    - #chapter("template/slides.typ")[演示文稿（PPT）]
    - #chapter("template/paper.typ")[论文模板]
    - #chapter("template/book.typ")[书籍模板]
    = 专题参考
    - #chapter("tutorial/reference-counter-state.typ")[计数器和状态]
    - #chapter("tutorial/reference-length.typ")[长度单位]
    - #chapter("tutorial/reference-layout.typ")[布局函数]
    - #chapter("tutorial/reference-table.typ")[表格]
    - #chapter("tutorial/reference-outline.typ")[文档大纲]
  ],
)

#build-meta(dest-dir: "../dist")

// #get-book-meta()

// re-export page template
#import "/typ/templates/page.typ": heading-reference, project
#let page = project
#let ref-page = project.with(kind: "reference-page")
#let cross-link = cross-link
#let heading-reference = heading-reference
