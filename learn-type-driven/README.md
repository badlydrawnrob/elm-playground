# Learn Type-Driven Development

> I've translated code examples to Elm lang.
> Updated to latest [ReasonML](https://reasonml.github.io/en/).
> Syntax differences to [Elm](https://monkeyjunglejuice.github.io/blog/best-programming-language-for-beginner.essay.html#org1b145a8) and [Ocaml](https://gist.github.com/jplew/bbe5ce7f4f6f13bd8fb366e64341ac97).

**I'm only really interested in learning types a bit better**, and there's very few books around that teach this (that aren't super academic and difficult). OCaml is different enough from Elm to take a significant amount of time (weeks and months) to learn properly, so **I'm mostly concerned with translating examples to Elm syntax**.

I've added some basic details about ReasonML (OCaml) and it's differences to Elm, but there's no `.rei` or `.re` files here. For that, you can use the [originals](https://github.com/PacktPublishing/Learn-Type-Driven-Development) to play around with.

Yet again, the book feels verbose, a bit academic, and some sections hard to understand, but this seems to be a general problem with programming literature. You have to download, install, initialise, and create a switch (isolated environment, which downloads a ton of stuff) before you can even get started. OCaml is quite a bit harder to setup and use than Elm Lang, so read the docs.


## Coding style and learning frame

> I'm not very concerned with "heavy lifting" programming tasks.
> I'm pretty happy right now with Elm (client) and Python (API).

1. If it's text processing, I'm out.
2. If it's game development, I'm out.
3. If it's not for prototyping, I'm out.
4. If it's academic language, I'm out.
5. If it's not [boring](https://rubenerd.com/boring-tech-is-mature-not-old/) and narrow, I'm out.[^1]

So yeah, proceed with caution if there's [scary categorising](https://cekrem.github.io/posts/functors-applicatives-monads-elm/) like functors, applicative, and monads. Life is too damn short and I've got sales to do. Consider Ai, [Roc](https://www.roc-lang.org/), or GUIs instead. Your needs may be different.


## Melange

> The latest version of ReasonML now uses [Melange](https://melange.re/).

The book uses (the old) Bucklescript compiler to render javascript.


## Why OCaml?

> Some reasons to [use](https://www2.lib.uchicago.edu/keith/ocaml-class/why.html) (and not use) OCaml.

If I chose to use OCaml at some point, I think I'd aim to keep some of Elm's simplicity in coding style, as the type system, modules, and paradigms are a bit more complicated.


## Tooling

1. https://ocaml.org/install (location `~/.local/bin` for Monterey)
2. https://ocaml.org/docs/opam-switch-introduction
3. https://github.com/jaredly/reason-language-server
4. https://melange.re/v6.0.1/getting-started.html


[^1]: As in predictable, sensible, pointed, and not a years long adventure to figure out (like Rust). More Pandoc than Javascript.

