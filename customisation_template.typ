/* ---------------------------------------------------------
   Settings for equations
--------------------------------------------------------- */


#set math.equation(
numbering: "(1)",
supplement: none
)

/* ---------------------------------------------------------
   Settings for figures
--------------------------------------------------------- */

// Position of caption
#show figure: set figure.caption(position: top)

#show figure.where(kind: "quarto-float-fig"): set figure.caption(position: top)


// Figure caption should be bold
#show figure.caption: it => {
  set text(weight: "bold")
  it
}

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

/* ---------------------------------------------------------
   Spacing around headings
--------------------------------------------------------- */

#show heading: set block(above: 1.4em, below: 1em)

/* ---------------------------------------------------------
   Insert pagebreak before header 1
--------------------------------------------------------- */

// Add a page break before all level 1 headings
#show heading.where(depth: 1): it => {
  if it.supplement != [Outline] {
    pagebreak(weak: true)
  }
  it
}

 #show figure.where(kind: "chapter"): it => {
  if it.supplement != [Outline] {
    pagebreak(weak: true)
  }
  it
  }


/* ---------------------------------------------------------
   General settings
--------------------------------------------------------- */

// use French support
#set text(lang: "fr")

// La police principale
#set text(font: "New Computer Modern")

// Define default text size
#set text(11pt)

// Define font for code
#show raw: it => {
  set text(
    font: "DejaVu Sans Mono", 
    10pt
  )
  it
  // highlight(
  //   fill: luma(230),
  //   extent: 2pt,
  //   bottom-edge: "descender", 
  //   top-edge: "ascender",
  //   it,
  // )
}

// Put all links in blue
#show link: it => [
  #set text(fill: rgb("#0000FF"))
  #block(it.body)
]

#set page(margin: 1.25in)

// Define paragraph settings
#set text(top-edge: 0.7em, bottom-edge: -0.3em)
#set par(leading: 0.5em, first-line-indent: 1.8em, justify: true)

// Define paragraph settings: https://typst.app/blog/2024/typst-0.12/
#show par: set block(spacing: 0.5em)
