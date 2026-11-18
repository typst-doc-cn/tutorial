#import "/src/book.typ"
#import "/typ/templates/page.typ"
#import "/typ/templates/term.typ": _term
#import "/typ/templates/side-notes.typ": side-note, side-attrs
#import "/typ/templates/page.typ": main-color, get-page-width, plain-text
#import "/typ/templates/template-link.typ": enable-heading-hash

#import "/typ/typst-meta/docs.typ": typst-v11

#let refs = {
  let cl = book.cross-link
  (
    writing-markup: cl.with("/tutorial/writing-markup.typ"),
    writing-scripting: cl.with("/tutorial/writing-scripting.typ"),
    scripting-base: cl.with("/tutorial/scripting-literal.typ"),
    scripting-literal: cl.with("/tutorial/scripting-literal.typ"),
    scripting-variable: cl.with("/tutorial/scripting-variable.typ"),
    scripting-composite: cl.with("/tutorial/scripting-composite.typ"),
    scripting-complex: cl.with("/tutorial/scripting-block-and-expression.typ"),
    scripting-control-flow: cl.with("/tutorial/scripting-control-flow.typ"),
    scripting-modules: cl.with("/tutorial/doc-modulize.typ"),
    scripting-main: cl.with("/tutorial/scripting-main.typ"),
    content-scope-style: cl.with("/tutorial/scripting-style.typ"),
    content-stateful: cl.with("/tutorial/doc-stateful.typ"),
    writing-chinese: cl.with("/tutorial/writing-chinese.typ"),
    writing-math: cl.with("/tutorial/writing-math.typ"),
    scripting-shape: cl.with("/tutorial/scripting-shape.typ"),
    scripting-layout: cl.with("/tutorial/scripting-layout.typ"),
    scripting-content: cl.with("/tutorial/scripting-content.typ"),
    ref-typebase: cl.with("/tutorial/reference-typebase.typ"),
    ref-type-builtin: cl.with("/tutorial/reference-type-builtin.typ"),
    ref-color: cl.with("/tutorial/reference-color.typ"),
    ref-visualization: cl.with("/tutorial/reference-visualization.typ"),
    ref-bibliography: cl.with("/tutorial/reference-bibliography.typ"),
    ref-datetime: cl.with("/tutorial/reference-date.typ"),
    ref-calculation: cl.with("/tutorial/reference-calculation.typ"),
    ref-math-mode: cl.with("/tutorial/reference-math-mode.typ"),
    ref-math-symbols: cl.with("/tutorial/reference-math-symbols.typ"),
    ref-data-process: cl.with("/tutorial/reference-data-process.typ"),
    ref-wasm-plugin: cl.with("/tutorial/reference-wasm-plugin.typ"),
    ref-grammar: cl.with("/tutorial/reference-grammar.typ"),
    ref-layout: cl.with("/tutorial/reference-layout.typ"),
    ref-length: cl.with("/tutorial/reference-length.typ"),
    misc-font-setting: cl.with("/misc/font-setting.typ"),
  )
}

#let term-list = (
  "array literal": "数组字面量",
  "blocky raw block": "块代码片段",
  "boolean literal": "布尔字面量",
  "code mode": "脚本模式",
  "codepoint": "码位",
  "codepoint width": "码位宽度",
  "character": "字符",
  "comment": "注释",
  "content": "内容",
  "consistency": "一致性",
  "content block": "内容块",
  "delimiter": "定界符",
  "dictionary literal": "字典字面量",
  "floating-point literal": "浮点数字面量",
  "function identifier": "函数名标识符",
  "emphasis semantics": "强调语义",
  "escape sequences": "转义序列",
  "exponential notation": "指数表示法",
  "expression": "表达式",
  "field": "域成员",
  "field access": "访问域成员",
  "function body expression": "函数体表达式",
  // https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/String
  "grapheme cluster": "字素簇",
  "grapheme cluster width": "字素簇宽度",
  "initialization expression": "初始值表达式",
  "integer literal": "整数字面量",
  "interpret": "解释",
  "interpreter": "解释器",
  "interpreting mode": "解释模式",
  "introspection function": "自省函数",
  "lexicographical order": "字典序",
  "line break": "换行符",
  "literal": "字面量",
  "markup mode": "标记模式",
  "math mode": "数学模式",
  "none literal": "空字面量",
  "nearest": "最近",
  "raw block": "代码片段",
  "representation": "表示法",
  "parameter identifier": "参数标识符",
  "parser": "解析器",
  "pattern": "模式串",
  "placeholder": "占位符",
  "shorthand": "速记符号",
  "scripting": "脚本",
  "string literal": "字符串字面量",
  "strong semantics": "着重语义",
  "syntactic predecessor": "语法前驱",
  "tilde diacritical marks": "波浪变音符号",
  "type": "类型",
  "utf-8 encoding": "UTF-8编码",
  "value": "值",
  "variable identifier": "变量名标识符",
  "whitespace": "空白字符",
)

#let mark-list = (
  "=": "等于号",
  "*": "星号",
  "#": "井号",
  "_": "下划线",
  "`": "反引号",
  "hyphen": "连字号",
  "-": "减号",
  "+": "加号",
  "\\": "反斜杠",
  "/": "斜杠",
  "~": "波浪号",
  ".": "点号",
  ";": "分号",
)

#let exec-code(cc, res: none, scope: (:), eval: eval) = {
  rect(
    width: 100%,
    inset: 10pt,
    context {
      // Don't corrupt normal headings
      set heading(outlined: false)

      let prev = enable-heading-hash.get()
      enable-heading-hash.update(false)

      if res != none {
        res
      } else {
        eval(cc.text, mode: "markup", scope: scope)
      }

      enable-heading-hash.update(prev)
    },
  )
}

#let _code-al = if get-page-width() >= 500pt {
  left
} else {
  top
}

// al: alignment
#let code(cc, code-as: none, res: none, scope: (:), eval: eval, exec-code: exec-code, al: _code-al) = {
  let code-as = if code-as == none {
    cc
  } else {
    code-as
  }

  let vv = exec-code(cc, res: res, scope: scope, eval: eval)
  if al == left {
    layout(lw => context {
      let width = lw.width * 0.5 - 0.5em
      let u = box(width: width, code-as)
      let v = box(width: width, vv)

      let u-box = measure(u)
      let v-box = measure(v)

      let height = calc.max(u-box.height, v-box.height)
      stack(
        dir: ltr,
        {
          set rect(height: height)
          u
        },
        1em,
        {
          rect(height: height, width: width, inset: 10pt, vv.body)
        },
      )
    })
  } else {
    code-as
    vv
  }
}

#let fg-blue = main-color.mix(rgb("#0074d9"))
#let pro-tip(content) = context {
  let attr = side-attrs.get()
  let ext = attr.width + attr.gutter
  move(
    dx: -ext,
    block(
      width: 100% + ext,
      breakable: false,
      inset: (x: 0.65em, y: 0.65em, left: 0.65em * 0.6),
      radius: 4pt,
      fill: rgb("#0074d920"),
      {
        set text(fill: fg-blue)
        stack(
          dir: ltr,
          move(dy: 0.1em, image("/assets/files/info-icon.svg", width: 1em)),
          0.2em,
          box(width: 100% - 1.2em, v(0.2em) + content),
        )
      },
    ),
  )
}

#let fg-red = main-color.mix(red)
#let todo-color = fg-red
#let todo-box(content) = context {
  let attr = side-attrs.get()
  let ext = attr.width + attr.gutter
  move(
    dx: -ext,
    block(
      width: 100% + ext,
      breakable: false,
      inset: (x: 0.65em, y: 0.65em, left: 0.65em * 0.6),
      radius: 4pt,
      fill: fg-red.transparentize(80%),
      {
        set text(fill: fg-red)
        stack(
          dir: ltr,
          move(dy: 0.4em, text(size: 0.5em)[todo]),
          0.2em,
          box(width: 100% - 1.2em, v(0.2em) + content),
        )
      },
    ),
  )
}

/// This function is to render a text string in monospace style and function
/// color in your defining themes.
///
/// ## Examples
///
/// ```typc
/// typst-func("list.item")
/// ```
///
/// Note: it doesn't check whether input is a valid function identifier or path.
#let typst-func(it) = [
  #raw(plain-text(it) + "()", lang: "typc") <typst-raw-func>
]

#let show-answer = false
// #let show-answer = true

/// Make an exercise item.
///
/// - question (content): The question to ask.
/// - answer (content): The answer to the question.
/// -> content
#let exercise(question, answer) = {
  enum.item(
    question
      + if show-answer {
        parbreak() + [答：] + answer
      },
  )
}

/// Make a term item.
///
/// - term (string): The name of the term.
/// - postfix (string): The postfix to conform typst bug.
/// - en (bool): Whether to show the English name.
/// -> content
#let term(term, en: none) = _term(term-list, term, en: en)

#let mark(mark) = _term(
  mark-list,
  mark,
  en: if mark == "hyphen" {
    raw("-")
  } else {
    raw(mark)
  },
)

#let ref-bookmark = side-note

#let highlighter(it, k) = {
  if k == "method" {
    set text(fill: rgb("4b69c6"))
    raw(it)
  } else if k == "keyword" {
    set text(fill: rgb("8b41b1"))
    raw(it)
  } else if k == "var" {
    set text(fill: blue.mix(main-color))
    raw(it)
  } else {
    raw(it)
  }
}

#let darkify(clr) = clr.mix(main-color.negate()).saturate(30%)

#let ref-ty-locs = (
  "int": refs.ref-typebase,
  "bool": refs.ref-typebase,
  "float": refs.ref-typebase,
  "str": refs.ref-typebase,
  "array": refs.ref-typebase,
  "dict": refs.ref-typebase,
  "none": refs.ref-typebase,
  "ratio": refs.ref-length,
  "alignment": refs.ref-layout,
  "version": refs.ref-type-builtin,
  "any": refs.ref-type-builtin,
  "bytes": refs.ref-type-builtin,
  "label": refs.ref-type-builtin,
  "type": refs.ref-type-builtin,
  "regex": refs.ref-type-builtin,
)

#let show-type(ty) = {
  h(3pt)
  ref-ty-locs.at(ty)(
    reference: label("reference-type-" + ty),
    box(fill: darkify(rgb("eff0f3")), outset: 2pt, radius: 2pt, raw(ty)),
  )
  h(3pt)
}

#let ref-signature(name, kind: "scope") = {
  let fn = if kind == "scope" {
    typst-v11.scoped-items.at(name)
  } else if kind == "cons" {
    let ty = typst-v11.types.at(name)
    ty.body.content.constructor
  } else {
    typst-v11.funcs.at(name)
  }

  context {
    let attr = side-attrs.get()
    let ext = attr.width + attr.gutter

    move(
      dx: -ext,
      block(
        fill: rgb("#add5a220"),
        radius: 2pt,
        width: 100% + ext,
        inset: (x: 1pt, y: 5pt),
        {
          set par(justify: false)
          set text(fill: main-color.mix(rgb("eff0f3").negate()))
          highlighter("fn", "keyword")
          raw(" ")
          highlighter(name, "method")
          raw("(")
          fn
            .params
            .map(param => {
              highlighter(param.name, "var")
              ": "
              param.types.map(show-type).join()
            })
            .join(raw(", "))
          raw(")")
          if fn.returns.len() > 0 {
            raw(" ")
            box(raw("->"))
            raw(" ")
            fn.returns.map(show-type).join()
          }
        },
      ),
    )
  }
}
#let ref-func-signature = ref-signature.with(kind: "func")
#let ref-cons-signature = ref-signature.with(kind: "cons")
#let ref-method-signature = ref-signature

#let f() = { }
