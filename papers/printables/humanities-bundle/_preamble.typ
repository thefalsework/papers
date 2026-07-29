// FalseWork humanities-bundle print stylesheet (Typst)
#set page(
  paper: "us-letter",
  margin: (top: 0.9in, bottom: 0.95in, left: 1in, right: 1in),
  numbering: "1",
  number-align: center,
)
#set text(
  font: ("Georgia", "Times New Roman"),
  size: 11pt,
  lang: "en",
)
#set par(justify: true, leading: 0.65em, first-line-indent: 0pt)
#set heading(numbering: none)
#show heading.where(level: 1): it => {
  set text(font: ("Segoe UI", "Calibri", "Arial"), weight: "bold", size: 18pt)
  v(0.6em)
  it
  v(0.35em)
  line(length: 100%, stroke: 0.4pt + rgb("#888888"))
  v(0.5em)
}
#show heading.where(level: 2): it => {
  set text(font: ("Segoe UI", "Calibri", "Arial"), weight: "semibold", size: 13pt)
  v(0.85em)
  it
  v(0.25em)
}
#show heading.where(level: 3): it => {
  set text(font: ("Segoe UI", "Calibri", "Arial"), weight: "semibold", size: 11.5pt)
  v(0.6em)
  it
  v(0.15em)
}
#show link: it => underline(stroke: 0.4pt + rgb("#555555"), offset: 1.5pt, it)
#show raw: set text(font: ("Consolas", "Courier New"), size: 9pt)
#show quote.where(block: true): it => {
  set text(style: "italic", size: 10.5pt)
  pad(left: 1em, right: 0.5em, {
    block(
      stroke: (left: 2pt + rgb("#aaaaaa")),
      inset: (left: 0.85em, y: 0.4em),
      width: 100%,
      it.body,
    )
  })
}
#show table: set text(size: 9.5pt)
#set table(
  stroke: 0.4pt + rgb("#cccccc"),
  inset: 6pt,
)

#let horizontalrule = line(length: 40%, stroke: 0.4pt + rgb("#bbbbbb"))

#align(center)[
  #text(size: 9pt, fill: rgb("#666666"), tracking: 0.12em, upper[FalseWork · Humanities Bundle])
  #v(0.35em)
]
