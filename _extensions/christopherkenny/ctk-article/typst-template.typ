#let titled-raw-block(body, filename: none) = {
  if (filename != none) {
    block(
      inset: 0em,
      fill: luma(200),
      radius: 8pt,
      outset: 0.75em,
      width: 100%,
      spacing: 2em,
      [
      #text(font: "DejaVu Sans Mono")[#filename]
      #block(
        fill: luma(230),
        inset: 0em,
        above: 1.2em,
        outset: 0.75em,
        radius: (bottom-left: 8pt, bottom-right: 8pt),
        width: 100%,
        body
      )
    ]
    )
  } else {
    body
  }
}

// better way to avoid escape characters, rather than doing a regex for \\@
#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// ctk-article definition starts here
// everything above is inserted by Quarto

#let ctk-article(
  title: none,
  subtitle: none,
  runningtitle: none,
  //runningauth: none,
  authors: none,
  date: none,
  abstract: none,
  thanks: none,
  keywords: none,
  cols: 1,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  mathfont: "New Computer Modern Math",
  codefont: "DejaVu Sans Mono",
  sectionnumbering: "1.1.",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  linestretch: 1,
  linkcolor: "#800000",
  title-page: false,
  blind: false,
  doc,
) = {

  let runningauth = if authors == none {
    none
  } else if authors.len() == 2 {
    authors.map(author => author.last).join(" and ")
  } else if authors.len() < 5 {
    authors.map(author => author.last).join(", ", last: ", and ")
  } else {
    authors.first().last + " et al."
  }

  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
    header: locate(
      loc => {
      let pg = counter(page).at(loc).first()
        if pg == 1 {
          return
        } else if (calc.odd(pg)) [
            #align(right, runningtitle)
          ] else [
            #if blind [
              #align(right)[
                #text(runningtitle)
              ]
            ] else [
              #align(left)[
                #text(runningauth)
              ]
            ]
          ]
          v(-8pt)
          line(length: 100%)
      }
    )
  )

  set page(
    numbering: none
    ) if title-page

  set par(
    justify: true,
    first-line-indent: 1em,
    leading: linestretch * 0.65em
  )
  // Font stuff
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize
  )
  show math.equation: set text(font: mathfont)
  show raw: set text(font: codefont)


  // show figure.caption: it => [
  //   #v(-1em)
  //   #align(left)[
  //     #block(inset: 1em)[
  //       #text(weight: "bold")[
  //         #it.supplement
  //         #context it.counter.display(it.numbering)
  //       ]
  //       #it.separator
  //       #it.body
  //     ]
  //   ]
  // ]


  set heading(numbering: sectionnumbering)

  // metadata
  set document(
    title: title,
    author: to-string(runningauth),
    date: auto,
    keywords: keywords.join(", ")
  )

  // show rules
  // show figure.where(kind: "quarto-float-fig"): set figure.caption(position: top)

  set footnote.entry(indent: 0em, gap: 0.75em)

  show link: this => {
    if type(this.dest) != label {
      text(this, fill: rgb(linkcolor.replace("\\#", "#")))
    } else {
      text(this, fill: rgb("#0000CC"))
    }
  }

  show ref: this => {
    text(this, fill: rgb("#640872"))
  }

  show cite.where(form: "prose"): this => {
    text(this, fill: rgb("#640872"))
  }

  set list(indent: 2em)
  set enum(indent: 2em)

  // start article content
  if title != none {
    align(center)[
      #block(inset: 2em)[
        #text(weight: "bold", size: 30pt)[
          #title #if thanks != none {
            footnote(thanks, numbering: "*")
            counter(footnote).update(n => n - 1)
          }
        ]
        #if subtitle != none {
          linebreak()
          text(subtitle, size: 18pt, weight: "semibold")
        }
      ]
    ]
  }


// author spacing based on Quarto ieee licenced CC0 1.0 Universal
// https://github.com/quarto-ext/typst-templates/blob/main/ieee/_extensions/ieee/typst-template.typ
  if not blind {
    for i in range(calc.ceil(authors.len() / 3)) {
      let end = calc.min((i + 1) * 3, authors.len())
      let slice = authors.slice(i * 3, end)
      grid(
        columns: slice.len() * (1fr,),
        gutter: 12pt,
        ..slice.map(author => align(center, {
              text(weight: "bold", author.name)
              if "orcid" in author [
                #link("https://orcid.org/" + author.orcid)[
                  #box(height: 9pt, image("ORCIDiD.svg"))
                ]
              ]
              if author.department != none [
              \ #author.department
              ]
              if author.university != none [
              \ #author.university
              ]
              if author.location != [] [
              \ #author.location
              ]
              if "email" in author [
              \ #link("mailto:" + to-string(author.email))
              ]
        }))
      )

      v(20pt, weak: true)
    }
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    align(center)[#block(width: 85%)[
      #set par(
        justify: true,
        first-line-indent: 0em,
        leading: linestretch * 0.65em * .85
      )
      *Abstract* \
      #align(left)[#abstract]
    ]]
  }

  if keywords != none {
    align(left)[#block(inset: 1em)[
      *Keywords*: #keywords.join(" • ")
    ]]
  }

  if title-page {
    // set page(numbering: none)
    // pagebreak()
    counter(page).update(n => n - 1)
  }
  set page(numbering: "1",
        header: locate(
      loc => {
      let pg = counter(page).at(loc).first()
        if (calc.odd(pg)) [
          #align(right, runningtitle)
        ] else [
          #if blind [
            #align(right, runningtitle)
          ] else [
            #align(left, runningauth)
          ]
        ]
      }
    )) if title-page


  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#let appendix(body) = {
  set heading(
    numbering: "A.1.",
    supplement: [Appendix]
    )
  set figure(
    numbering: (..nums) => {
      "A" + numbering("1", ..nums.pos())
    },
    supplement: [Appendix Figure]
  )
  counter(heading).update(0)
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)

  body
}
#set table(
  inset: 6pt,
  stroke: none
)
