#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Simple slides],
)

#title-slide[
  = Sample title
  #v(2em)
]

== First slide

#lorem(20)

#focus-slide[
  _Focus!_

  This is very important.
]

== Second slide

hi
