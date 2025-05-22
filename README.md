# README

> 📅 It's super easy [to forget](https://www.azquotes.com/quote/585801) so aim to practice once per week!

This is the killer. If I step away from programming for a few weeks, you really feel the rust gathering. This repository is a testing ground for all things Elm, and it's a year-long learning curve to get building.

There's plenty of [javascript guides](https://eloquentjavascript.net/) out there, so here the focus is on a statically typed functional style that turns you into a good programmer. For a study aid, you can use [Anki flashcards](https://github.com/badlydrawnrob/anki) and [these handy guides](https://github.com/badlydrawnrob/anki/discussions/123) to get you started. It's great for revision, but no substitute for _building_ things.

## 🔰 Beginners

> Elm is great for learning how to engineer.

Start with [How To Design Programs](https://htdp.org/) and follow that up with Elm. It's **better designed**, more **consistent**, with **better compiler error messages** than [Python](https://github.com/badlydrawnrob/python-playground).

After these two languages you'll have a decent grounding in Computer Science theory, and they're not too academic. I'm rubbish at maths, and am mostly focused on rapid prototyping, so I like to avoid deep academic learning. An artist ships!


## 🚀 Getting started

> My goals are not the same as yours; have a clear vision! This can change as you go.
> — [#! Here would be a great place for a book!]

**Here are my goals:**

1. Prototyping a business model
2. Write as little code as possible[^1]
3. Teaching beginners

**If I were to start over and learn again, I would:**

1. Start with [HTDP](https://github.com/badlydrawnrob/racket-playground/tree/master/htdp) and then [Elm](https://www.manning.com/books/elm-in-action)
2. Learn only a subset of CompSci[^2] (first two chapters of HTDP, for example)
3. Learn the best practices for `http` servers, `json` and `REST` APIs
4. Learn how to use Ai as a teacher, or for pair-programming
5. Learn from a mentor (good habits and what _not_ to do)
6. Learn how to frame and structure your learning (fail fast, just build!)

### Basic commands

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

### ⭐ Why Elm, then?

#### Types and inference

> Why do we need types? It's best illustrated by the old joke ...

A programmer's wife told him "Go to the store and buy milk and if they have eggs, get a dozen." He came back a while later with 12 cartons of milk!

#### Beautiful error messages

This is where Elm really shines, everything is easy to install and just works! Unlike Python, where there's many ways to manage packages, the error messages are cryptic, and so on.

#### How to document your code

- Here's [how packages are documented](https://package.elm-lang.org/help/documentation-format)
- Elm package [design guidelines](https://package.elm-lang.org/help/design-guidelines)

#### Testing

> I'm lazy, and rarely test, but it's good practice to.

This mindset will land you in trouble if you're using Python, or a language that doesn't have strict typing. It's always wise to test your functions somehow, as typing only [gets you so far](https://discourse.elm-lang.org/t/what-not-to-unit-test/3511). For example, I use [Bruno](https://www.usebruno.com/) when testing my APIs, but I don't write unit tests. Remember, Elm only checks for data types; it won't make sure your inputs and outputs are what you'd expect.

My goal is prototyping, so I'm a little lax, but for large programs with bigger teams, a lot can go wrong without tests! Always check your programs as your visitors would use them.


## Learning Elm

### 📚 Some useful docs

> See your offline books in `Library/code/elm`!

- [Official Elm guide](https://guide.elm-lang.org/)
- [Elm syntax](https://elm-lang.org/docs/syntax) (quick overview of syntax)
- [Learn you an Elm](https://learnyouanelm.github.io/) (based on Haskell book)
- [Beginning Elm](https://elmprogramming.com/)

### 🧑‍🏫 Online courses

- [Welcome to Elm](https://www.youtube.com/playlist?list=PLuGpJqnV9DXq_ItwwUoJOGk_uCr72Yvzb) (nice walkthrough)
- [Richard Feldman's](https://frontendmasters.com/teachers/richard-feldman/) intro and advanced Elm
- [Exercism](https://exercism.org/tracks/elm)'s Elm track
- [7 GUIs](https://eugenkiss.github.io/7guis/tasks/) for practice
- [Elm Workshop](https://sporto.github.io/elm-workshop/) (e.g: [stopwatch](https://sporto.github.io/elm-workshop/05-effects/02-start.html))

### 🎞️ Helpful talks

1. [Life of a file](https://www.youtube.com/watch?v=XpDsk374LDE)
2. [Teaching Elm to beginners](https://www.youtube.com/watch?v=G-GhUxeYc1U)
3. [Scaling Elm apps](https://www.youtube.com/watch?v=DoA4Txr4GUs)
4. [Making impossible states impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8)[^3]
5. [Make data structures](https://www.youtube.com/watch?v=x1FU3e0sT1I)
6. [From Rails to Elm and Haskell](https://www.youtube.com/watch?v=5CYeZ2kEiOI&list=PLfc1FQC2AVoO5pibnlTz2Qj-UJ1DQXuSo)

### 📖 Books

- [Elm in Action](https://www.manning.com/books/elm-in-action)
- [Learn you an Elm](https://learnyouanelm.github.io)
- [Learn Elm](https://elmcraft.org/learn/) (Elm Craft)

### 🛠️ Some tools

- [Minification](https://discourse.elm-lang.org/t/elm-minification-benchmarks/9968)
- [Hot reload](https://www.youtube.com/watch?v=eVsgBJqTOIE) or [`elm-watch`](https://github.com/lydell/elm-watch) / [`elm-live`](https://github.com/wking-io/elm-live)
- [Elm Doc Preview](https://github.com/dmy/elm-doc-preview) (great for offline documentation)
- [Elm land](https://elm.land) (or the older [elm-spa](https://www.elm-spa.dev/)
- [Everything else](https://github.com/sporto/awesome-elm) (massive list)

### ❓ Some helpful FAQs

- [Elm community FAQs](https://faq.elm-community.org)
- [Why large records are OK](https://elm-lang.org/docs/records#large-records)
- [Why do I have to use Json decoders?](https://gist.github.com/evancz/1c5f2cf34939336ecb79b97bb89d9da6)
- [What, exactly, is a `Msg` for?](https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5) (no state please!)
- [Avoiding import cycles](https://tinyurl.com/import-cycles-normalisation) and normalising records

## Some nice examples

- [Andy Balaam's](https://www.artificialworlds.net/blog/category/elm/) Elm examples
- [Built with Elm](https://www.builtwithelm.co)
- [Elm Patterns](https://sporto.github.io/elm-patterns/index.html) (might be a little outdated)
- [Fuzz tests in Elm](https://freecontent.manning.com/writing-fuzz-tests-in-elm/)[^4]
- [Sorting comparables](https://stacktracehq.com/blog/comparing-and-sorting-in-elm/) (record)

### Larger programs

- [Elm Spa](https://github.com/rtfeldman/elm-spa-example) example (by @rtfeldman)[^5]
- [Elk Herd](https://github.com/mzero/elk-herd) (by @mzero)


[^1]: Meaning efficient with my time, not lazy (ok, a little lazy). A simple route with less code and complexity? I'll take it. Take this [carousel](https://github.com/erkal/erkal.github.io/blob/main/pages/Carousel/Carousel.elm) in Elm, for example. Want to be a great programmer? Go ahead, take your time! Prefer the easy route? Use [`scroll-snap`](https://css-tricks.com/css-only-carousel/) with CSS. It all depends on your vision: I'd rather have more time to pursue other things, keep things simple.

[^2]: A lot of programming books can be highly academic, and although [books like these](https://leanpub.com/fp-made-easier) can be very thorough (and suit some learning styles), for me that was the wrong approach. For example, learning how to code recursively can be intellectually stimulating and it teaches you a lot, but after a certain point, it provides diminishing returns. It's hard to know _exactly_ what you need to learn, but if your goal is to build things, aim for industry knowledge and pragmatic goals, rather than academic ones. Learn the basics well and start building things. You'll learn a lot along the way (with help from mentors), and you can do the heavier academic texts later if you enjoy that kind of thing!

[^3]: All (or most) of [Richard Feldmans talks](https://www.youtube.com/playlist?list=PL1u6QhVvC9FX1EZeIfIbG2VgVHWEyFofw)

[^4]: I'm being a little lazy here. I don't consider myself a "proper" computer scientist (and I don't code that often); more a pragmatic programmer. My goal is prototyping, so I rarely write unit tests. This isn't the _correct_ way, but Elm types give a lot of guarantees: testing the program as a regular user (like a QA) might be enough. If any bugs arise, a visitor can raise a ticket and tests can be written.

[^5]: There's an alternative by Dwayne called [Elm Conduit](https://discourse.elm-lang.org/t/announcing-dwayne-elm-conduit-a-replacement-for-rtfeldman-elm-spa-example/9758)
