#import "mod.typ": *

#show: book.page.with(title: [参考：常用数学符号])

#set table(
  stroke: none,
  align: horizon + left,
  row-gutter: 0.45em,
)

推荐阅读：
+ #link("https://github.com/johanvx/typst-undergradmath/releases/download/v1.4.0/undergradmath.pdf")[本科生Typst数学英文版，适用于Typst 0.11.1]
+ #link("https://github.com/brynne8/typst-undergradmath-zh/blob/6a1028bc13c525f29f6445e92fc6af3246b3c3cb/undergradmath.pdf")[本科生Typst数学中文版，适用于Typst 0.9.0]

以下表格列出了*数学模式*中的常用符号。

#figure(
  table(
    columns: 8,
    [$hat(a)$], [`hat(a)`], [$caron(a)$], [`caron(a)`], [$tilde(a)$], [`tilde(a)`], [$grave(a)$], [`grave(a)`],
    [$dot(a)$],
    [`dot(a)`],
    [$dot.double(a)$],
    [dot.double(a)],
    [$macron(a)$],
    [`macron(a)`],
    [$arrow(a)$],
    [`arrow(a)`],

    [$acute(a)$], [`acute(a)`], [$breve(a)$], [`breve(a)`],
  ),
  caption: [数学模式重音符号],
)

#figure(
  table(
    columns: 8,
    [$alpha$], [`alpha`], [$theta$], [`theta`], [$o$], [`o`], [$upsilon$], [`upsilon`],
    [$beta$], [`beta`], [$theta.alt$], [`theta.alt`], [$pi$], [`pi`], [$phi$], [`phi`],
    [$gamma$], [`gamma`], [$iota$], [`iota`], [$pi.alt$], [`pi.alt`], [$phi$], [`phi`],
    [$delta$], [`delta`], [$kappa$], [`kappa`], [$rho$], [`rho`], [$chi$], [`chi`],
    [$epsilon.alt$], [`epsilon.alt`], [$lambda$], [`lambda`], [$rho.alt$], [`rho.alt`], [$psi$], [`psi`],
    [$epsilon$], [`epsilon`], [$mu$], [`mu`], [$sigma$], [`sigma`], [$omega$], [`omega`],
    [$zeta$], [`zeta`], [$nu$], [`nu`], [$sigma.alt$], [`sigma.alt`], [$$], [``],
    [$eta$], [`eta`], [$xi$], [`xi`], [$tau$], [`tau`], [$$], [``],
    [$Gamma$], [`Gamma`], [$Lambda$], [`Lambda`], [$Sigma$], [`Sigma`], [$Psi$], [`Psi`],
    [$Delta$], [`Delta`], [$Xi$], [`Xi`], [$Upsilon$], [`Upsilon`], [$Omega$], [`Omega`],
    [$Theta$], [`Theta`], [$Pi$], [`Pi`], [$Phi$], [`Phi`],
  ),
  caption: [希腊字母],
)

#figure(
  table(
    columns: 6,
    [$<$], [`<, lt`], [$>$], [`>, gt`], [$=$], [`=`],
    [$<=$], [`<=, lt.eq`], [$>=$], [`>=, gt.eq`], [$equiv$], [`equiv`],
    [$<<$], [`<<, lt.double`], [$>>$], [`>>, gt.double`], [$$], [``],
    [$prec$], [`prec`], [$succ$], [`succ`], [$tilde$], [`tilde`],
    [$prec.eq$], [`prec.eq`], [$succ.eq$], [`succ.eq`], [$tilde.eq$], [`tilde.eq`],
    [$subset$], [`subset`], [$supset$], [`supset`], [$approx$], [`approx`],
    [$subset.eq$], [`subset.eq`], [$supset.eq$], [`supset.eq`], [$tilde.equiv$], [`tilde.equiv`],
    [$subset.sq$], [`subset.sq`], [$supset.sq$], [`supset.sq`], [$join$], [`join`],
    [$subset.eq.sq$], [`subset.eq.sq`], [$supset.eq.sq$], [`supset.eq.sq`], [$$], [``],
    [$in$], [`in`], [$in.rev$], [`in.rev`], [$prop$], [`prop`],
    [$tack.r$], [`tack.r`], [$tack.l$], [`tack.l`], [$tack.r.double$], [`tack.r.double`],
    [$divides$], [`divides`], [$parallel$], [`parallel`], [$tack.t$], [`tack.t`],
    [$:$], [`:`], [$in.not$], [`in.not`], [$!=$], [`!=, eq.not`],
  ),
  caption: [二元关系],
)

#figure(
  table(
    columns: 6,
    [$+$], [`+, plus`], [$-$], [`-, minus`], [$$], [``],
    [$plus.minus$], [`plus.minus`], [$minus.plus$], [`minus.plus`], [$lt.tri$], [`lt.tri`],
    [$dot$], [`dot`], [$div$], [`div`], [$gt.tri$], [`gt.tri`],
    [$times$], [`times`], [$without$], [`without`], [$star$], [`star`],
    [$union$], [`union`], [$inter$], [`inter`], [$*$], [`*`],
    [$union.sq$], [`union.sq`], [$inter.sq$], [`inter.sq`], [$circle.stroked.tiny$], [`circle.stroked.tiny`],
    [$or$], [`or`], [$and$], [`and`], [$bullet$], [`bullet`],
    [$xor$], [`xor`], [$minus.circle$], [`minus.circle`], [$dot.circle$], [`dot.circle`],
    [$union.plus$], [`union.plus`], [$times.circle$], [`times.circle`], [$circle.big$], [`circle.big`],
    [$product.co$],
    [`product.co`],
    [$triangle.stroked.t$],
    [`triangle.stroked.t`],
    [$triangle.stroked.b$],
    [`triangle.stroked.b`],

    [$dagger$], [`dagger`], [$lt.tri$], [`lt.tri`], [$gt.tri$], [`gt.tri`],
    [$dagger.double$], [`dagger.double`], [$lt.tri.eq$], [`lt.tri.eq`], [$gt.tri.eq$], [`gt.tri.eq`],
    [$wreath$], [`wreath`],
  ),
  caption: [二元运算符],
)

#figure(
  table(
    columns: 6,
    [$sum$], [`sum`], [$union.big$], [`union.big`], [$or.big$], [`or.big`],
    [$product$], [`product`], [$inter.big$], [`inter.big`], [$and.big$], [`and.big`],
    [$product.co$], [`product.co`], [$union.sq.big$], [`union.sq.big`], [$union.plus.big$], [`union.plus.big`],
    [$integral$], [`integral`], [$integral.cont$], [`integral.cont`], [$dot.circle.big$], [`dot.circle.big`],
    [$plus.circle.big$], [`plus.circle.big`], [$times.circle.big$], [`times.circle.big`],
  ),
  caption: [「大」运算符],
)

#figure(
  table(
    columns: 4,
    [$arrow.l$], [`arrow.l`], [$arrow.l.long$], [`arrow.l.long`],
    [$arrow.r$], [`arrow.r`], [$arrow.r.long$], [`arrow.r.long`],
    [$arrow.l.r$], [`arrow.l.r`], [$arrow.l.r.long$], [`arrow.l.r.long`],
    [$arrow.l.double$], [`arrow.l.double`], [$arrow.l.double.long$], [`arrow.l.double.long`],
    [$arrow.r.double$], [`arrow.r.double`], [$arrow.r.double.long$], [`arrow.r.double.long`],
    [$arrow.l.r.double$], [`arrow.l.r.double`], [$arrow.l.r.double.long$], [`arrow.l.r.double.long`],
    [$arrow.r.bar$], [`arrow.r.bar`], [$arrow.r.long.bar$], [`arrow.r.long.bar`],
    [$arrow.l.hook$], [`arrow.l.hook`], [$arrow.r.hook$], [`arrow.r.hook`],
    [$harpoon.lt$], [`harpoon.lt`], [$harpoon.rt$], [`harpoon.rt`],
    [$harpoon.lb$], [`harpoon.lb`], [$harpoon.rb$], [`harpoon.rb`],
    [$harpoons.ltrb$], [`harpoons.ltrb`], [$arrow.t$], [`arrow.t`],
    [$arrow.b$], [`arrow.b`], [$arrow.t.b$], [`arrow.t.b`],
    [$arrow.t.double$], [`arrow.t.double`], [$arrow.b.double$], [`arrow.b.double`],
    [$arrow.t.b.double$], [`arrow.t.b.double`], [$arrow.tr$], [`arrow.tr`],
    [$arrow.br$], [`arrow.br`], [$arrow.bl$], [`arrow.bl`],
    [$arrow.tl$], [`arrow.tl`], [$arrow.r.squiggly$], [`arrow.r.squiggly`],
  ),
  caption: [箭头],
)

#figure(
  table(
    columns: 6,
    [$dots$], [`dots`], [$dots.c$], [`dots.c`], [$dots.v$], [`dots.v`],
    [$dots.down$], [`dots.down`], [$planck.reduce$], [`planck.reduce`], [$dotless.i$], [`dotless.i`],
    [$dotless.j$], [`dotless.j`], [$ell$], [`ell`], [$Re$], [`Re`],
    [$Im$], [`Im`], [$aleph$], [`aleph`], [$forall$], [`forall`],
    [$exists$], [`exists`], [$Omega.inv$], [`Omega.inv`], [$partial$], [`partial`],
    [$prime$], [`', prime`], [$emptyset$], [`emptyset`], [$infinity$], [`infinity`],
    [$nabla$], [`nabla`], [$triangle.stroked.t$], [`triangle.stroked.t`], [$square.stroked$], [`square.stroked`],
    [$diamond.stroked$], [`diamond.stroked`], [$bot$], [`bot`], [$top$], [`top`],
    [$angle$], [`angle`], [$suit.club$], [`suit.club`], [$suit.spade$], [`suit.spade`],
    [$not$], [`not`],
  ),
  caption: [其他符号],
)
