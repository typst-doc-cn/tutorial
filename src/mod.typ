#import "/src/book.typ"
#import "/typ/templates/page.typ"
#import "/typ/templates/term.typ": _term
#import "/typ/templates/side-notes.typ": side-note
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
  "blocky raw block": "块代码片段",
  "boolean literal": "布尔字面量",
  "code mode": "脚本模式",
  "comment": "注释",
  "content": "内容",
  "consistency": "一致性",
  "content block": "内容块",
  "delimiter": "定界符",
  "floating-Point literal": "浮点数字面量",
  "function identifier": "函数名标识符",
  "emphasis semantics": "强调语义",
  "escape sequences": "转义序列",
  "expression": "表达式",
  "field": "域成员",
  "field access": "访问域成员",
  "function body expression": "函数体表达式",
  "initialization expression": "初始值表达式",
  "integer literal": "整数字面量",
  "interpret": "解释",
  "interpreter": "解释器",
  "interpreting mode": "解释模式",
  "introspection function": "自省函数",
  "lexicographical order": "字典序",
  "line break": "换行符",
  "markup mode": "标记模式",
  "none literal": "空字面量",
  "raw block": "代码片段",
  "parameter identifier": "参数标识符",
  "parser": "解析器",
  "placeholder": "占位符",
  "shorthand": "速记符号",
  "scripting": "脚本",
  "string literal": "字符串字面量",
  "strong semantics": "着重语义",
  "type": "类型",
  "value": "值",
  "variable identifier": "变量名标识符",
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

  rect(width: 100%, inset: 10pt, {
    // Don't corrupt normal headings
    set heading(outlined: false)

    if res != none {
      res
    } else {
      eval(cc.text, mode: "markup", scope: scope)
    }
  })
}

#let code(cc, code-as: none, res: none, scope: (:), eval: eval, exec-code: exec-code) = {
  let code-as = if code-as == none {
    cc
  } else {
    code-as
  }

  layout(lw => style(styles => {
    let width = lw.width * 0.5 - 0.5em
    let u = box(width: width, code-as)
    let vv = exec-code(cc, res: res, scope: scope, eval: eval)
    let v = box(width: width, vv)

    let u-box = measure(u, styles);
    let v-box = measure(v, styles);

    let height = calc.max(u-box.height, v-box.height)
    stack(
      dir: ltr,
      {
        set rect(height: height)
        u
      }, 1em, {
        rect(height: height, width: width, inset: 10pt, vv.body)
      }
    )
  }))
}

#let fg-blue = main-color.mix(rgb("#0074d9"))
#let pro-tip(content) = block(
  width: 100%,
  breakable: false,
  inset: (x: 0.65em, y: 0.65em, left: 0.65em * 0.6),
  radius: 4pt,
  fill: rgb("#0074d920"), {
  set text(fill: fg-blue)
  stack(
    dir: ltr,
    move(dy: 0.1em, image("/assets/files/info-icon.svg", width: 1em)),
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

#let ref-bookmark = side-note
