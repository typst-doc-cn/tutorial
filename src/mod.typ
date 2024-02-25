#import "/src/book.typ"
#import "/typ/templates/page.typ"
#import "/typ/templates/term.typ": _term
#import "/typ/templates/page.typ": main-color

#let refs = {
  let cl = book.cross-link;
  (
    writing: cl.with("/basic/writing.typ"),
    scripting-base: cl.with("/basic/scripting-base.typ"),
    scripting-complex: cl.with("/basic/scripting-complex.typ"),
    scripting-modules: cl.with("/intermediate/scripting-modules.typ"),
    content-scope-style: cl.with("/intermediate/content-scope-and-style.typ"),
    content-stateful: cl.with("/intermediate/content-stateful.typ"),
    ref-color: cl.with("/basic/reference-color.typ"),
    ref-math-symbols: cl.with("/basic/reference-math-symbols.typ"),
    ref-layout: cl.with("/intermediate/reference-layout.typ"),
    ref-length: cl.with("/intermediate/reference-length.typ"),
    misc-font-setting: cl.with("/misc/font-setting.typ"),
  )
}

#let term-list = (
  "parser": "解析器",
  "interpreter": "解释器",
  "interpreting mode": "解释模式",
  "introspection function": "自省函数",
  "markup mode": "标记模式",
  "code mode": "脚本模式",
  "delimiter": "定界符",
  "strong semantics": "着重语义",
  "emphasis semantics": "强调语义",
  "code block": "代码片段",
  "blocky code block": "块代码片段",
  "line break": "换行符",
  "shorthand": "速记符号",
  "comment": "注释",
  "escape sequences": "转义序列",
  "type": "类型",
  "none literal": "空字面量",
  "boolean literal": "布尔字面量",
  "integer literal": "整数字面量",
  "floating-Point literal": "浮点数字面量",
  "string literal": "字符串字面量",
  "expression": "表达式",
  "lexicographical order": "字典序",
  "function body expression": "函数体表达式",
  "initialization expression": "初始值表达式",
  "variable identifier": "变量名标识符",
  "function identifier": "函数名标识符",
  "parameter identifier": "参数标识符",
  "placeholder": "占位符",
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
  // Don't corrupt normal headings
  set heading(outlined: false)

  rect(width: 100%, inset: 10pt, if res != none {
    res
  } else {
    eval(cc.text, mode: "markup", scope: scope)
  })
}

#let code(cc, show-cc: true, res: none, scope: (:), eval: eval, exec-code: exec-code) = {
  if show-cc {
    cc
  }
  exec-code(cc, res: res, scope: scope, eval: eval)
}

#let fg-blue = main-color.mix(rgb("#0074d9"))
#let pro-tip(content) = rect(
  width: 100%,
  inset: (x: 0.65em, y: 0.65em, left: 0.65em * 0.6),
  radius: 4pt,
  fill: rgb("#0074d920"), {
  set text(fill: fg-blue)
  stack(
    dir: ltr,
    image("/assets/files/info-icon.svg", width: 1em),
    0.2em,
    box(width: 100% - 1.2em, v(0.2em) + content)
  )
})

#let typst-func(it) = [
  #raw(it + "()", lang: "typc") <typst-raw-func>
]

#let show-answer = false
// #let show-answer = true

#let exercise(c1, c2) = {
  enum.item(c1 + if show-answer {
    parbreak() + [答：] + c2
  })
}

#let term(term, postfix: none, en: none) = _term(term-list, term, en: en, postfix: postfix)
#let mark(mark, postfix: none) = _term(mark-list, mark, en: if mark == "hyphen" {
  raw("-")
} else {
  raw(mark)
}, postfix: postfix)
