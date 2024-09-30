// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}


#let script-size = 8pt
#let footnote-size = 9pt
#let small-size = 10pt
#let normal-size = 11pt
#let large-size = 12pt

// This function gets your whole document as its `body` and formats
// it as an article in the style of the American Mathematical Society.
#let ams-article(
  // The article's title.
  title: "Paper title",

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // Your article's abstract. Can be omitted if you don't have one.
  abstract: none,

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography-file: none,

  // The document's content.
  body,
) = {
  // Formats the author's names in a list with commas and a
  // final "and".
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: ", and ")
  }

  // Set document metadata.
  set document(title: title, author: names)

  // Set the body font. AMS uses the LaTeX font.
  set text(size: normal-size, font: "New Computer Modern")

  // Configure the page.
  set page(
    paper: paper-size,
    // The margins depend on the paper size.
    margin: if paper-size != "a4" {
      (
        top: (116pt / 279mm) * 100%,
        left: (96pt / 216mm) * 100%,
        right: (98pt / 216mm) * 100%,
        bottom: (94pt / 279mm) * 100%,
      )
    } else {
      (
        top: 117pt,
        left: 118pt,
        right: 119pt,
        bottom: 96pt,
      )
    },

    // The page header should show the page number and list of
    // authors, except on the first page. The page number is on
    // the left for even pages and on the right for odd pages.
    header-ascent: 14pt,
    header: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 { return }
      set text(size: script-size)
      grid(
        columns: (6em, 1fr, 6em),
        if calc.even(i) [#i],
        align(center, upper(
          if calc.odd(i) { title } else { author-string }
        )),
        if calc.odd(i) { align(right)[#i] }
      )
    }),

    // On the first page, the footer should contain the page number.
    footer-descent: 12pt,
    footer: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 {
        align(center, text(size: script-size, [#i]))
      }
    })
  )

  // Configure headings.
  set heading(numbering: "1.")
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    // Level 1 headings are centered and smallcaps.
    // The other ones are run-in.
    set text(size: normal-size, weight: 400)
    if it.level == 1 {
      v(15pt) // Ajoute un espace avant le titre de niveau 1
      set align(center)
      set text(size: normal-size)
      smallcaps[
        #v(15pt, weak: true)
        #number
        #it.body
        #v(normal-size, weak: true)
      ]
      v(5pt)
      counter(figure.where(kind: "theorem")).update(0)
    } else {
      v(15pt) // Ajoute un espace avant les sous-titres
      v(11pt, weak: true)
      number
      let styled = if it.level == 2 { strong } else { emph }
      styled(it.body + [. ])
      h(7pt, weak: true)
      v(5pt)
    }
  }

  // Configure lists and links.
  set list(indent: 24pt, body-indent: 5pt)
  set enum(indent: 24pt, body-indent: 5pt)
  show link: set text(font: "New Computer Modern Mono")

  // Configure equations.
  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(weight: 400)

  // Configure citation and bibliography styles.
  // Cette ligne fait bugguer le template. Arguments deprecated?
  // set cite(style: "numerical", brackets: true)
  set cite(style: "apa", form: "prose")
  set bibliography(style: "apa", title: "References")

  // show figure: it => {
  //   show: pad.with(x: 0pt)
  //   set align(center)

  //   v(12.5pt, weak: true)

  //   // Display the figure's caption.
  //   if it.has("caption") {
  //     smallcaps[Figure]
  //     if it.numbering != none {
  //       [ #counter(figure).display(it.numbering)]
  //     }
  //     [. ]
  //     it.caption
  //     // Gap defaults to 17pt.
  //     v(if it.has("gap") { it.gap } else { 17pt }, weak: true)
  //   }

  //   // Display the figure's body.
  //   it.body

  //   v(15pt, weak: true)
  // }

  // Theorems.
  show figure.where(kind: "theorem"): it => block(above: 11.5pt, below: 11.5pt, {
    strong({
      it.supplement
      if it.numbering != none {
        [ ]
        counter(heading).display()
        it.counter.display(it.numbering)
      }
      [.]
    })
    emph(it.body)
  })

  // Display the title and authors.
  v(35pt, weak: true)
  align(center, upper({
    text(size: large-size, weight: 700, title)
    v(25pt, weak: true)
    text(size: footnote-size, author-string)
  }))

  // Configure paragraph properties.
  set par(first-line-indent: 1.2em, justify: true, leading: 0.8em) // (interligne) previously:0.58em
  show par: set block(spacing: 1.2em) // (space between paragraphs) previously:0.58em

  // Display the abstract
  if abstract != none {
    v(20pt, weak: true)
    set text(script-size)
    show: pad.with(x: 35pt)
    smallcaps[Abstract. ]
    abstract
  }

  // Display the article's contents.
  v(29pt, weak: true)
  body

  // Display the bibliography, if any is given.
  if bibliography-file != none {
    show bibliography: set text(8.5pt)
    show bibliography: pad.with(x: 0.5pt)
    bibliography(bibliography-file)
  }

  // The thing ends with details about the authors.
  show: pad.with(x: 11.5pt)
  set par(first-line-indent: 0pt)
  set text(7.97224pt)

  for author in authors {
    let keys = ("department", "organization", "location")

    let dept-str = keys
      .filter(key => key in author)
      .map(key => author.at(key))
      .join(", ")

    smallcaps(dept-str)
    linebreak()

    if "email" in author [
      _Email address:_ #link("mailto:" + author.email) \
    ]

    if "url" in author [
      _URL:_ #link(author.url)
    ]

    v(12pt, weak: true)
  }
}

// The ASM template also provides a theorem function.
#let theorem(body, numbered: true) = figure(
  body,
  kind: "theorem",
  supplement: [Theorem],
  numbering: if numbered { "1" },
)

// And a function for a proof.
#let proof(body) = block(spacing: 11.5pt, {
  emph[Proof.]
  [ ] + body
  h(1fr)
  box(scale(160%, origin: bottom + right, sym.square.stroked))
})
#show: ams-article.with(
  title: "Le bagging",
   authors: (
    (
    name: "",
    email: "",
    url: "",
    
  ),
  ),
  bibliography-file: "references.bib",
)


#import "@preview/mitex:0.2.4": *
#set math.equation(
numbering: "(1)",
supplement: none
)
= Le bagging
<le-bagging>
Le bagging, ou "bootstrap aggregating", est une méthode ensembliste qui vise à améliorer la stabilité et la précision des algorithmes d’apprentissage automatique en réduisant la variance des prédictions (#cite(<breiman1996bagging>, form: "prose");). Elle repose sur la construction de plusieurs modèles (plusieurs versions d’un même modèle dans la plupart des cas) entraînés sur des échantillons distincts générés par des techniques de rééchantillonnage (#emph[bootstrap];). Ces modèles sont ensuite combinés pour produire une prédiction agrégée, souvent plus robuste et généralisable que celle obtenue par un modèle unique.

== Principe du bagging
<principe-du-bagging>
Le bagging comporte trois étapes principales:

- #strong[L’échantillonnage bootstrap] : L’échantillonnage bootstrap consiste à créer des échantillons distincts en tirant aléatoirement avec remise des observations du jeu de données initial. Chaque échantillon #emph[bootstrap] contient le même nombre d’observations que le jeu de données initial, mais certaines observations sont répétées (car sélectionnées plusieurs fois), tandis que d’autres sont omises.

- #strong[L’entraînement de plusieurs modèles] : Un modèle (aussi appelé #emph[apprenant de base] ou #emph[weak learner];) est entraîné sur chaque échantillon bootstrap. Les modèles peuvent être des arbres de décision, des régressions ou tout autre algorithme d’apprentissage. Le bagging est particulièrement efficace avec des modèles instables, tels que les arbres de décision non élagués.

- #strong[L’agrégation des prédictions] : Les prédictions de tous les modèles sont ensuite agrégées, en procédant généralement à la moyenne (ou à la médiane) des prédictions dans le cas de la régression, et au vote majoritaire (ou à la moyenne des probabilités prédites pour chaque classe) dans le cas de la classification, afin d’obtenir des prédictions plus précises et généralisables.

== Pourquoi (et dans quelles situations) le bagging fonctionne
<pourquoi-et-dans-quelles-situations-le-bagging-fonctionne>
Certains modèles sont très sensibles aux données d’entraînement, et leurs prédictions sont très instables d’un échantillon à l’autre. L’objectif du bagging est de construire un prédicteur plus précis en agrégeant les prédictions de plusieurs modèles entraînés sur des échantillons (légèrement) différents les uns des autres.

#cite(<breiman1996bagging>, form: "prose") montre que cette méthode est particulièrement efficace lorsqu’elle est appliquée à des modèles très instables, dont les performances sont particulièrement sensibles aux variations du jeu de données d’entraînement, et peu biaisés.

Cette section vise à mieux comprendre comment (et sous quelles conditions) l’agrégation par bagging permet de construire un prédicteur plus performant.

Dans la suite, nous notons $phi (x , L)$ un prédicteur (d’une valeur numérique dans le cas de la #emph[régression] ou d’un label dans le cas de la #emph[classification];), entraîné sur un ensemble d’apprentissage $L$, et prenant en entrée un vecteur de caractéristiques $x$.

=== La régression: réduction de l’erreur quadratique moyenne par agrégation
<la-régression-réduction-de-lerreur-quadratique-moyenne-par-agrégation>
Dans le contexte de la #strong[régression];, l’objectif est de prédire une valeur numérique $Y$ à partir d’un vecteur de caractéristiques $x$. Un modèle de régression $phi.alt (x , L)$ est construit à partir d’un ensemble d’apprentissage $L$, et produit une estimation de $Y$ pour chaque observation $x$.

==== Définition du prédicteur agrégé
<définition-du-prédicteur-agrégé>
Dans le cas de la régression, le #strong[prédicteur agrégé] est défini comme suit :

$ phi.alt_A (x) = E_L [phi.alt (x , L)] $

où $phi.alt_A (x)$ représente la prédiction agrégée, $E_L [.]$ correspond à l’espérance prise sur tous les échantillons d’apprentissage possibles $L$, chacun étant tiré selon la même distribution que le jeu de données initial, et $phi.alt (x , L)$ correspond à la prédiction du modèle construit sur l’échantillon d’apprentissage $L$.

==== La décomposition biais-variance
<la-décomposition-biais-variance>
Pour mieux comprendre comment l’agrégation améliore la performance globale d’un modèle individuel $phi.alt (x , L)$, revenons à la #strong[décomposition biais-variance] de l’erreur quadratique moyenne (il s’agit de la mesure de performance classiquement considérée dans un problème de régression):

#mitex(`
$E_L[\left(Y - \phi(x, L)\right)^2] = \underbrace{
\left(E_L\left[\phi(x, L) - Y\right]\right)^2}_{\text{Biais}^2} + \underbrace{E_L[\left(\phi(x, L) - E_L[\phi(x, L)]\right)^2]}_{\text{Variance}}$
`) <decompo_biais_variance>
- Le #strong[biais] est la différence entre la valeur observée $Y$ que l’on souhaite prédire et la prédiction moyenne $E_L [phi.alt (x , L)]$. Si le modèle est sous-ajusté, le biais sera élevé.

- La #strong[variance] est la variabilité des prédictions ($phi.alt (x , L)$) autour de leur moyenne ($E_L [phi.alt (x , L)]$). Un modèle avec une variance élevée est très sensible aux fluctuations au sein des données d’entraînement: ses prédictions varient beaucoup lorsque les données d’entraînement se modifient.

L’équation #cite(<decompo_biais_variance>, form: "prose") illustre l’#strong[arbitrage biais-variance] qui est omniprésent en #emph[machine learning];: plus la complexité d’un modèle s’accroît (exemple: la profondeur d’un arbre), plus son biais sera plus faible (car ses prédictions seront de plus en plus proches des données d’entraînement), et plus sa variance sera élevée (car ses prédictions, étant très proches des données d’entraînement, auront tendance à varier fortement d’un jeu d’entraînement à l’autre).

==== L’inégalité de Breiman (1996)
<linégalité-de-breiman-1996>
#cite(<breiman1996bagging>, form: "prose") compare l’erreur quadratique moyenne d’un modèle individuel avec celle du modèle agrégé et démontre l’inégalité suivante :

#mitex(`
$(Y - \phi_A(x))^2 \leq E_L[(Y - \phi(x, L))^2])$
`) <inegalite_breiman1996>
- Le terme $(Y - phi.alt_A (x))^2$ représente l’erreur quadratique du #strong[prédicteur agrégé] $phi.alt_A (x)$;

- Le terme $E_L [(Y - phi.alt (x , L))^2]$ est l’erreur quadratique moyenne d’un #strong[prédicteur individuel] $phi.alt (x , L)$ entraîné sur un échantillon aléatoire $L$. Cette erreur varie en fonction des données d’entraînement.

Cette inégalité montre que #strong[l’erreur quadratique moyenne du prédicteur agrégé est toujours inférieure ou égale à la moyenne des erreurs des prédicteurs individuels];. Puisque le biais du prédicteur agrégé est identique au biais du prédicteur individuel, alors l’inégalité précédente implique que la #strong[variance du modèle agrégé] $phi.alt_A (x)$ est #strong[toujours inférieure ou égale] à la variance moyenne d’un modèle individuel :

$upright("Var") (phi.alt_A (x)) = upright("Var") (E_L [phi.alt (x , L)]) lt.eq E_L [upright("Var") (phi.alt (x , L))]$

Autrement dit, le processus d’agrégation réduit l’erreur de prédiction globale en réduisant la #strong[variance] des prédictions, tout en conservant un biais constant.

Ce résultat ouvre la voie à des considérations pratiques immédiates. Lorsque le modèle individuel est instable et présente une variance élevée, l’inégalité $V a r (phi.alt_A (x)) lt.eq E_L [V a r (phi.alt (x , L))]$ est forte, ce qui signifie que l’agrégation peut améliorer significativement la performance globale du modèle. En revanche, si $phi.alt (x , L)$ varie peu d’un ensemble d’entraînement à un autre (modèle stable avec variance faible), alors $V a r (phi.alt_A (x))$ est proche de $E_L [V a r (phi.alt (x , L))]$, et la réduction de variance apportée par l’agrégation est faible. Ainsi, #strong[le bagging est particulièrement efficace pour les modèles instables];, tels que les arbres de décision, mais moins efficace pour les modèles stables tels que les méthodes des k plus proches voisins.

=== La classification: vers un classificateur presque optimal par agrégation
<la-classification-vers-un-classificateur-presque-optimal-par-agrégation>
Dans le cas de la classification, le mécanisme de réduction de la variance par le bagging permet, sous une certaine condition, d’atteindre un #strong[classificateur presque optimal] (#emph[nearly optimal classifier];). Ce concept a été introduit par #cite(<breiman1996bagging>, form: "prose") pour décrire un modèle qui tend à classer une observation dans la classe la plus probable, avec une performance approchant celle du classificateur Bayésien optimal (la meilleure performance théorique qu’un modèle de classification puisse atteindre).

Pour comprendre ce résutlat, introduisons $Q (j \| x) = E_L (1_(phi (x , L) = j)) = P (phi (x , L) = j)$, la probabilité qu’un modèle $phi (x , L)$ prédise la classe $j$ pour l’observation $x$, et $P (j \| x)$, la probabilité réelle (conditionnelle) que $x$ appartienne à la classe $j$.

==== Définition : classificateur order-correct
<définition-classificateur-order-correct>
Un classificateur $phi (x , L)$ est dit #strong[order-correct] pour une observation $x$ si, en espérance, il identifie #strong[correctement la classe la plus probable];, même s’il ne prédit pas toujours avec exactitude les probabilités associées à chaque classe $Q (j divides x)$.

Cela signifie que si l’on considérait tous les ensemble de données possibles, et que l’on évaluait les prédictions du modèle en $x$, la majorité des prédictions correspondraient à la classe à laquelle il a la plus grande probabilité vraie d’appartenir $P (j divides x)$.

Formellement, un prédicteur est dit "order-correct" pour une entrée $x$ si :

$a r g m a x_j Q (j \| x) = a r g m a x_j P (j \| x)$

où $P (j \| x)$ est la vraie probabilité que l’observation $x$ appartienne à la classe $j$, et $Q (j \| x)$ est la probabilité que $x$ appartienne à la classe $j$ prédite par le modèle $phi (x , L)$.

Un classificateur est #strong[order-correct] si, pour #strong[chaque] observation $x$, la classe qu’il prédit correspond à celle qui a la probabilité maximale $P (j \| x)$ dans la distribution vraie.

==== Prédicteur agrégé en classification: le vote majoritaire
<prédicteur-agrégé-en-classification-le-vote-majoritaire>
Dans le cas de la classification, le prédicteur agrégé est défini par le #strong[vote majoritaire];. Cela signifie que si $K$ classificateurs sont entraînés sur $K$ échantillons distincts, la classe prédite pour $x$ est celle qui reçoit #strong[le plus de votes] de la part des modèles individuels.

Formellement, le classificateur agrégé $phi A (x)$ est défini par :

$phi A (x) = upright("argmax")_j sum_L I (phi.alt (x , L) = j) = a r g m a x_j Q (j \| x)$

==== Performance globale: convergence vers un classificateur presque optimal
<performance-globale-convergence-vers-un-classificateur-presque-optimal>
#cite(<breiman1996bagging>, form: "prose") montre que si chaque prédicteur individuel $phi (x , L)$ est order-correct pour une observation $x$, alors le prédicteur agrégé $phi A (x)$, obtenu par #strong[vote majoritaire];, atteint la performance optimale pour cette observation, c’est-à-dire qu’il converge vers la classe ayant la probabilité maximale $P (j divides x)$ pour l’observation $x$ lorsque le nombre de prédicteurs individuels augmente. Le vote majoritaire permet ainsi de #strong[réduire les erreurs aléatoires] des classificateurs individuels.

Le classificateur agrégé $phi.alt A$ est optimal s’il prédit systématiquement la classe la plus probable pour l’observation $x$ dans toutes les régions de l’espace.

Cependant, dans les régions de l’espace où les classificateurs individuels ne sont pas order-corrects (c’est-à-dire qu’ils se trompent majoritairement sur la classe d’appartenance), l’agrégation par vote majoritaire n’améliore pas les performances. Elles peuvent même se détériorer par rapport aux modèles individuels si l’agrégation conduit à amplifier des erreurs systématiques (biais).

== L’échantillage par bootstrap peut détériorer les performances théoriques du modèle agrégé
<léchantillage-par-bootstrap-peut-détériorer-les-performances-théoriques-du-modèle-agrégé>
En pratique, au lieu d’utiliser tous les ensembles d’entraînement possibles $L$, le bagging repose sur un nombre limité d’échantillons bootstrap tirés avec remise à partir d’un même jeu de données initial, ce qui peut introduire des biais par rapport au prédicteur agrégé théorique.

Les échantillons bootstrap présentent les limites suivantes :

- Une #strong[taille effective réduite par rapport au jeu de données initial];: Bien que chaque échantillon bootstrap présente le même nombre d’observations que le jeu de données initial, environ 1/3 des observations (uniques) du jeu initial sont absentes de chaque échantillon bootstrap (du fait du tirage avec remise). Cela peut limiter la capacité des modèles à capturer des relations complexes au sein des données (et aboutir à des modèles individuels sous-ajustés par rapport à ce qui serait attendu théoriquement), en particulier lorsque l’échantillon initial est de taille modeste.

- Une #strong[dépendance entre échantillons] : Les échantillons bootstrap sont tirés dans le même jeu de données, ce qui génère une dépendance entre eux, qui réduit la diversité des modèles. Cela peut limiter l’efficacité de la réduction de variance dans le cas de la régression, voire acroître le biais dans le cas de la classification.

- Une #strong[couverture incomplète de l’ensemble des échantillons possibles];: Les échantillons bootstrap ne couvrent pas l’ensemble des échantillons d’entraînement possibles, ce qui peut introduire un biais supplémentaire par rapport au prédicteur agrégé théorique.

== Le bagging en pratique
<le-bagging-en-pratique>
=== Quand utiliser le bagging en pratique
<quand-utiliser-le-bagging-en-pratique>
Le bagging est particulièrement utile lorsque les modèles individuels présentent une variance élevée et sont instables. Dans de tels cas, l’agrégation des prédictions peut réduire significativement la variance globale, améliorant ainsi la performance du modèle agrégé. Les situations où le bagging est recommandé incluent typiquement:

- Les modèles instables : Les modèles tels que les arbres de décision non élagués, qui sont sensibles aux variations des données d’entraînement, bénéficient grandement du bagging. L’agrégation atténue les fluctuations des prédictions dues aux différents échantillons.

- Les modèles avec biais faibles: En classification, si les modèles individuels sont order-corrects pour la majorité des observations, le bagging peut améliorer la précision en renforçant les prédictions correctes et en réduisant les erreurs aléatoires.

Inversement, le bagging peut être moins efficace ou même néfaste dans certaines situations :

- Les modèles stables avec variance faible : Si les modèles individuels sont déjà stables et présentent une faible variance (par exemple, la régression linéaire), le bagging n’apporte que peu d’amélioration, car la réduction de variance supplémentaire est minimale.

- La présence de biais élevée : Si les modèles individuels sont biaisés, entraînant des erreurs systématiques, le bagging peut amplifier ces erreurs plutôt que de les corriger. Dans de tels cas, il est préférable de s’attaquer d’abord au biais des modèles avant de considérer l’agrégation.

- Les échantillons de petite taille : Avec des ensembles de données limités, les échantillons bootstrap peuvent ne pas être suffisamment diversifiés ou représentatifs, ce qui réduit l’efficacité du bagging et peut augmenter le biais des modèles.

#strong[Ce qui qu’il faut retenir];: le bagging peut améliorer substantiellement la performance des modèles d’apprentissage automatique lorsqu’il est appliqué dans des conditions appropriées. Il est essentiel d’évaluer la variance et le biais des modèles individuels, ainsi que la taille et la représentativité du jeu de données, pour déterminer si le bagging est une stratégie adaptée. Lorsqu’il est utilisé judicieusement, le bagging peut conduire à des modèles plus robustes et précis, exploitant efficacement la puissance de l’agrégation pour améliorer la performance des modèles individuels.

=== Comment utiliser le bagging en pratique
<comment-utiliser-le-bagging-en-pratique>
==== Combien de modèles agréger?
<combien-de-modèles-agréger>
"Optimal performance is often found by bagging 50–500 trees. Data sets that have a few strong predictors typically require less trees; whereas data sets with lots of noise or multiple strong predictors may need more. Using too many trees will not lead to overfitting. However, it’s important to realize that since multiple models are being run, the more iterations you perform the more computational and time requirements you will have. As these demands increase, performing k-fold CV can become computationally burdensome."

==== Evaluation du modèle: cross validation et échantillon Out-of-bag (OOB)
<evaluation-du-modèle-cross-validation-et-échantillon-out-of-bag-oob>
"A benefit to creating ensembles via bagging, which is based on resampling with replacement, is that it can provide its own internal estimate of predictive performance with the out-of-bag (OOB) sample (see Section 2.4.2). The OOB sample can be used to test predictive performance and the results usually compare well compared to k-fold CV assuming your data set is sufficiently large (say n≥1,000). Consequently, as your data sets become larger and your bagging iterations increase, it is common to use the OOB error estimate as a proxy for predictive performance."

== Mise en pratique (exemple avec code)
<mise-en-pratique-exemple-avec-code>
Ou bien ne commencer les mises en pratique qu’avec les random forest ?

== Interprétation
<interprétation>


