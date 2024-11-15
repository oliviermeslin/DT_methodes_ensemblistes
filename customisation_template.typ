#set math.equation(
numbering: "(1)",
supplement: none
)

/* ---------------------------------------------------------
   Settings for tables
--------------------------------------------------------- */

// Bold titles in tables
#show table.cell.where(y: 0): set text(weight: "bold")

// Tableaux alignés à gauche, sauf première ligne centrée
#show table.cell: set align(left+horizon)
#show table.cell.where(y: 0): set align(center+horizon)

// Tableau zébré
#set table(
  fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },
  stroke: 0.5pt + rgb("666675"),
)

// Position of caption
#show figure.where(
  kind: table
): set figure.caption(position: top)

/* ---------------------------------------------------------
   Insert pagebreak before header 1
--------------------------------------------------------- */

#show outline: set heading(supplement: [Outline])
#show heading.where(depth: 1): it => {
  if it.supplement != [Outline] {
    pagebreak(weak: true)
  }
  it
}

#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)

// La police principale
#set text(font: "IBM Plex Sans")

#show heading: set block(above: 1.4em, below: 1em)

#show heading.where(depth: 1): it => {
  if it.supplement != [Outline] {
    pagebreak(weak: true)
  }
  it
}

// #show heading.where(depth: 1): set text(blue)
