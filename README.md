# README

> I'd strongly encourage starting with Elm if you're learning how to program.
> It's better designed, more consistent, with better compiler error messages than Python.

A testing ground for all things Elm. There's plenty of javascript guides out there, so this only covers functional programming in the style of Elm. Also see ["Lazy Loading of Anki Cards"](https://github.com/badlydrawnrob/anki/issues/91) for revision with Anki.

You might like to read the first couple of chapters of "[How to Design Programs](https://htdp.org/)" before diving in to Elm for a grounding in CompSci theory (it's not too academic).


## Types and inference

> Why do we need types? It's best illustrated by the old joke ...

A programmer's wife told him "Go to the store and buy milk and if they have eggs, get a dozen." He came back a while later with 12 cartons of milk!


## Basic commands

```terminal
# Initialise an Elm project
elm init

# Install a package
elm install elm/<package>

# Make a HTML file from an Elm one
elm make src/Main.elm

# Compile to javascript file
elm make src/Main.elm --output=app.js

# View in the browser
elm reactor
```

## Some useful docs

- [Official Elm guide](https://guide.elm-lang.org/)
- [Elm syntax](https://elm-lang.org/docs/syntax) (quick overview of syntax)
- [Learn you an Elm](https://learnyouanelm.github.io/) (based on Haskell book)
- [Beginning Elm](https://elmprogramming.com/)

## Online courses

- [Welcome to Elm](https://www.youtube.com/playlist?list=PLuGpJqnV9DXq_ItwwUoJOGk_uCr72Yvzb) (nice walkthrough)
- [Richard Feldman's](https://frontendmasters.com/teachers/richard-feldman/) intro and advanced Elm
- [Exercism](https://exercism.org/tracks/elm)'s Elm track
- [7 GUIs](https://eugenkiss.github.io/7guis/tasks/) for practice
- [Elm Workshop](https://sporto.github.io/elm-workshop/) (e.g: [stopwatch](https://sporto.github.io/elm-workshop/05-effects/02-start.html))

## Helpful talks

1. [Life of a file](https://www.youtube.com/watch?v=XpDsk374LDE)
2. [Teaching Elm to beginners](https://www.youtube.com/watch?v=G-GhUxeYc1U)
3. [Scaling Elm apps](https://www.youtube.com/watch?v=DoA4Txr4GUs)
4. [Making impossible states impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8)[^1]
5. [Make data structures](https://www.youtube.com/watch?v=x1FU3e0sT1I)
6. [From Rails to Elm and Haskell](https://www.youtube.com/watch?v=5CYeZ2kEiOI&list=PLfc1FQC2AVoO5pibnlTz2Qj-UJ1DQXuSo)

## Books

- [Elm in Action](https://www.manning.com/books/elm-in-action)
- [Learn you an Elm](https://learnyouanelm.github.io)
- [Learn Elm](https://elmcraft.org/learn/) (Elm Craft)

## Some tools

- [Elm Doc Preview](https://github.com/dmy/elm-doc-preview) (great for offline documentation)
- [Elm land](https://elm.land)
- [Everything else](https://github.com/sporto/awesome-elm) (massive list)

## Some helpful FAQs

- [Elm community FAQs](https://faq.elm-community.org)
- [Why large records are OK](https://elm-lang.org/docs/records#large-records)
- [Why do I have to use Json decoders?](https://gist.github.com/evancz/1c5f2cf34939336ecb79b97bb89d9da6)
- [What, exactly, is a `Msg` for?](https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5) (no state please!)
- [Avoiding import cycles](https://tinyurl.com/import-cycles-normalisation) and normalising records

## Some nice examples

- [Andy Balaam's](https://www.artificialworlds.net/blog/category/elm/) Elm examples
- [Built with Elm](https://www.builtwithelm.co)
- [Elm Patterns](https://sporto.github.io/elm-patterns/index.html) (Might be a little outdated)
- [Fuzz tests in Elm](https://freecontent.manning.com/writing-fuzz-tests-in-elm/)
- [Sorting comparables](https://stacktracehq.com/blog/comparing-and-sorting-in-elm/) (record)

## Documentation

- Here's [how packages are documented](https://package.elm-lang.org/help/documentation-format)
- Elm package [design guidelines](https://package.elm-lang.org/help/design-guidelines)


[^1]: All (or most) of [Richard Feldmans talks](https://www.youtube.com/playlist?list=PL1u6QhVvC9FX1EZeIfIbG2VgVHWEyFofw)
