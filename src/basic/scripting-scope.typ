#import "mod.typ": *

#show: book.page.with(title: "脚本：控制流、作用域和闭包")

= 脚本：控制流、作用域和闭包

== 控制流

#code(```typ
#if true {
  1
} else {
  0
}
```)

#code(```typ
#let fib(n) = if n <= 1 {
  n
} else {
  fib(n - 1) + fib(n - 2)
}

#fib(46)
```)

#code(```typ
#{
  let i = 0;
  let j = 0;
  while i < 10 {
    j += i;
    i += 1;
  }
  j
}
```)
