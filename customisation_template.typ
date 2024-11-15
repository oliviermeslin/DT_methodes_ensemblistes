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

#show heading.where(depth: 1): set text(blue)

/* ---------------------------------------------------------
   Add a chapter class
--------------------------------------------------------- */

// https://sitandr.github.io/typst-examples-book/book/typstonomicon/chapters.html

#let chapter = figure.with(
  kind: "chapter",
  // same as heading
  numbering: none,
  // this cannot use auto to translate this automatically as headings can, auto also means something different for figures
  supplement: "Chapter",
  // empty caption required to be included in outline
  caption: [],
)

// emulate element function by creating show rule
#show figure.where(kind: "chapter"): it => {
  set text(22pt)
  counter(heading).update(0)
  if it.numbering != none { strong(it.counter.display(it.numbering)) } + [ ] + strong(it.body)
}

// no access to element in outline(indent: it => ...), so we must do indentation in here instead of outline
#show outline.entry: it => {
  if it.element.func() == figure {
    // we're configuring chapter printing here, effectively recreating the default show impl with slight tweaks
    let res = link(it.element.location(), 
      // we must recreate part of the show rule from above once again
      if it.element.numbering != none {
        numbering(it.element.numbering, ..it.element.counter.at(it.element.location()))
      } + [ ] + it.element.body
    )

    if it.fill != none {
      res += [ ] + box(width: 1fr, it.fill) + [ ] 
    } else {
      res += h(1fr)
    }

    res += link(it.element.location(), it.page)
    strong(res)
  } else {
    // we're doing indenting here
    h(1em * it.level) + it
  }
}

// new target selector for default outline
#let chapters-and-headings = figure.where(kind: "chapter", outlined: true).or(heading.where(outlined: true))

//
// start of actual doc prelude
//

#set heading(numbering: "1.")

// can't use set, so we reassign with default args
#let chapter = chapter.with(numbering: "I")

// an example of a "show rule" for a chapter
// can't use chapter because it's not an element after using .with() anymore
#show figure.where(kind: "chapter"): set text(red)