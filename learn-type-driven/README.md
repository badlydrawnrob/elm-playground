# Learn Type-Driven Development

> Code examples have been translated to Elm lang.

- Updated to latest [ReasonML](https://reasonml.github.io/en/).
- Differences to [Elm](https://monkeyjunglejuice.github.io/blog/best-programming-language-for-beginner.essay.html#org1b145a8) and [Ocaml](https://gist.github.com/jplew/bbe5ce7f4f6f13bd8fb366e64341ac97)
- Why [OCaml](https://www2.lib.uchicago.edu/keith/ocaml-class/why.html)?

My main issue with a great number of programming literature is its academic nature and low-level of readability. Sometimes this is unavoidable, but I feel code doesn't need to be so hard to understand (classifications, terminology, cleverness). Some passages feel poorly written and not so clear as to what they're referring to.

## Learning frame

Type-driven design books are hard to come by, and most far too academic. The goal is to understand the difference between Elm and OCaml (ReasonML) and their similarities. I'm not concerned about "heavy lifting" programming tasks and am generally happy with Elm (client) and Python (server).

1. I want to understand working with types better (and when to use them)
2. I don't want to learn OCaml deeply (my focus is Elm applications)
3. I'll replace OCaml-specific theory with Elm-compatible ones.
4. If I _do_ decide to use OCaml in future, I'd keep code Elm-like.

To learn ReasonML or OCaml I espect to take weeks or months of time I don't have. ReasonML code examples from the book can be found [here](https://github.com/PacktPublishing/Learn-Type-Driven-Development). Here's some other things I avoid:

- If it's academic language, I'm out.
- If it's hard to prototype, I'm out.
- If it's not [boring](https://rubenerd.com/boring-tech-is-mature-not-old/), I'm out.
- If it's game development, I'm out.
- If it's text processing, I'm out.
- If it's nebulous (not specific), I'm out![^1]

I don't need to learn flippin' [category theory](https://cekrem.github.io/posts/functors-applicatives-monads-elm/) to build an app, thank you very much. I've got sales to do.[^2]


## Similarities to Elm

> Elm has a smaller footprint than OCaml and is more strict.

But a lot of the things Elm does can also be achieved within OCaml (see examples of [Elm features](https://github.com/badlydrawnrob/elm-playground?tab=readme-ov-file#-why-elm-then)).


## Differences to Elm

> A rough guide to how they differ

1. Elm is easy to install and use
    - OCaml is harder to setup and use
    - OCaml has a ton of dependencies to install
2. Elm feels easier to read and less academic
    - ReasonML syntax and theory takes longer to learn
3. Elm modules are files
    - ReasonML can create modules _within_ files
4. Elm type signatures are written _above_ functions
    - ReasonML generally uses _interfaces_ in `.rli` files
5. Elm types are named within their module
    - ReasonML namespaces types as `File.Namespace.t`
6. Elm feels terse and concise
    - ReasonML feels like quite a bit of repetition


## Tooling

1. https://ocaml.org/install (location `~/.local/bin` for Monterey)
2. https://ocaml.org/docs/opam-switch-introduction
3. https://github.com/jaredly/reason-language-server
4. https://melange.re/v6.0.1/getting-started.html[^3]


[^1]: As in predictable, sensible, pointed, and not a years long adventure to figure out (like Rust). More Pandoc than Javascript.

[^2]: It may be that Ai takes over the bulk of hand-coded tasks, and other languages such as [Roc](https://www.roc-lang.org/) lang look appealing. Alternatively, use third-party tools or GUIs. Basically as minimal code as possible.

[^3]: The latest version of ReasonML now uses [Melange](https://melange.re/). The book uses (the old) Bucklescript compiler to render javascript.

