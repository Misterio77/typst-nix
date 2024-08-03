#import "@preview/gentle-clues:0.9.0": tip

#tip[
    Hi there!

    #lorem(30)
]

#set text(font: "Fira Sans")

I like Fira.

#image("tux.png", width: 50%)

#let info(data) = [Nix is #data.nix, Guix is #data.guix]
#info(json("data.json"))
