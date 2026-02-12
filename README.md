# README

> 📅 "If I miss one day of practice, I notice it. If I miss two days, the critics notice it. If I miss three days, the audience notices it." — Ignacy Jan Paderewski

**It's super easy to forget so aim to practice once per week!** This is the killer. If I step away from programming for a few weeks, you really feel the rust gathering. This repository is a testing ground for all things Elm, and it's a year-long learning curve to build bigger.

There's plenty of [javascript guides](https://eloquentjavascript.net/) out there, so the focus is squarely on a statically typed functional style, good habits, and shaping a good programmer. For a study aid, use [Anki flashcards](https://github.com/badlydrawnrob/anki) and a clear learning frame.[^1] They're great for revision, but no substitute for _building_ things.

## 🔰 Beginners

> Elm is great for learning how to engineer.

Start with [How To Design Programs](https://htdp.org/) and follow that up with [Elm](https://elm-lang.org). It's **better designed**, more **consistent**, with **better compiler error messages** than [Python](https://github.com/badlydrawnrob/python-playground).

After these two languages you'll have a decent grounding in Computer Science theory, and they're not too academic. I'm rubbish at maths, and am mostly focused on rapid prototyping, so I like to avoid deep academic learning. An artist ships!


## 🚀 Getting started

> 📖 I think the first and most important thing is that you've got to [have a goal and a vision](https://www.audible.co.uk/author/Arnold-Schwarzenegger/B000AP7VZW) — Arnie

**Here are my goals:**

1. Prototyping and validating a business idea
2. Writing as little code as possible[^2]
3. Teaching beginners (kids and adults)

**If I were to start over and learn again, I would:**

1. Start with [HTDP](https://github.com/badlydrawnrob/racket-playground/tree/master/htdp) and then [Elm](https://www.manning.com/books/elm-in-action)
2. Learn only a subset of CompSci[^3] (first two chapters of HTDP, for example)
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

# Has `elm.json` file but no `elm-stuff` folder
# re-install packages (from local cache)
elm make [file]

# View in the browser
elm reactor
```

### Useful commands

```terminal
# Try Elm in terminal
elm repl

# Check package changes
elm diff elm/http 1.0.0 2.0.0
```

### ⭐ Why Elm, then?

#### Types and inference

> Why do we need types? It's best illustrated by the old joke ...
>
> A programmer's wife told him "Go to the store and buy milk and if they have eggs, get a dozen." He came back a while later with 12 cartons of milk!

Computer Science is specific, it requires some discipline. If you've used a language like Python before, you'll know that runtime errors can be frustrating and opaque. Elm's compiler solves this problem by inferring (or reading) types. An example below:

```elm
shopping : List String
shopping = ["oat milk", "chocolate", "marshmallows"]

checkout : List String -> List Float
checkout list =
    List.map (\item -> (priceCheck item)) list

priceCheck : String -> Float
priceCheck item =
    if item == "oat milk" then
        2.50
    else
        1.50
```
```terminal
>> checkout shopping
[2.5, 1.5, 1.5] : List Float
```

#### Beautiful error messages

This is where Elm really shines, everything is easy to install and just works! The error messages are clear and helpful, guiding you towards a correct solution, and everything is built in (unlike Python with it's cryptic error messages, `None` values, and [many](https://typing.python.org/en/latest/#typing-related-tools) type checking packages).

```elm
checkout ["oat milk", 2, "marshmallows"]
```
```terminal
-- TYPE MISMATCH ---------------------------------------------------------- REPL

The 2nd element of this list does not match all the previous elements:

16|   checkout ["oat milk", 2, "marshmallows"]
                            ^
The 2nd element is a number of type:

    number

But all the previous elements in the list are:

    String

Hint: Everything in a list must be the same type of value. This way, we never
run into unexpected values partway through a List.map, List.foldl, etc. Read
<https://elm-lang.org/0.19.1/custom-types> to learn how to “mix” types.

Hint: Try using String.fromInt to convert it to a string?
```

#### Documenting your code

- Here's [how packages are documented](https://package.elm-lang.org/help/documentation-format)
- Elm package [design guidelines](https://package.elm-lang.org/help/design-guidelines)

#### Testing your code

> 😌 I'm lazy, and rarely test, but it's good practice to.

This mindset will land you in trouble if you're using Python, or any language without strict typing. It's always wise to test your programs as your visitors would use them, as typing only [gets you so far](https://discourse.elm-lang.org/t/what-not-to-unit-test/3511). For example, I use [Bruno](https://www.usebruno.com/) to test my APIs, Hotjar for user testing, manual tests, ocassionally logs, but I generally don't write unit tests. Remember, Elm only checks data types; it won't guarantee your inputs and outputs are what you'd expect.

My goal is prototyping; not testing is a calculated risk, as it (1) speeds up development, and (2) makes life easier for a one-man-show. Forgive me for being a little lax. For mission-critical production projects, finance, larger programs, or working in bigger teams, a lot can go wrong without tests!


## Learning Elm

> It's also helpful to keep an offline library/docs when your wifi breaks (or the internet rots)
> — there's an [app](https://ricks-apps.com/osx/sitesucker/index.html) for that.

**Here's a wealth of resources for getting started with [Elm](https://elm-lang.org).** Each list is ordered by difficulty (beginners and easiest first). I'd suggest starting with "Beginning Elm" or "Welcome to Elm" to get a taste, move onto the books (or online courses), peruse the helpful talks, check out some real world examples, then it's up to you! You can also run Elm in the browser with [Ellie](https://ellie-app.com/) and [Elm.run](https://elm.run/repl/).

### 📖 Books

- [Beginning Elm](https://elmprogramming.com/)
- [Elm in Action](https://www.manning.com/books/elm-in-action) (chapter [files](https://github.com/badlydrawnrob/elm-playground/tree/master/elm-in-action) in this repo)
- [Programming Elm](https://pragprog.com/titles/jfelm/programming-elm/) (chapter [files](https://github.com/badlydrawnrob/elm-playground/tree/master/programming-elm) on this repo)
- [Learn Elm](https://elmcraft.org/learn/) (Elm Craft)

### 📚 Useful documentation

- [Official Elm guide](https://guide.elm-lang.org/)
- [Elm syntax](https://elm-lang.org/docs/syntax) (quick overview of syntax)
- [Elm packages](https://package.elm-lang.org)

### 🧑‍🏫 Online courses

- [Welcome to Elm](https://www.youtube.com/playlist?list=PLuGpJqnV9DXq_ItwwUoJOGk_uCr72Yvzb) (nice walkthrough)
- [Introduction to Elm](https://frontendmasters.com/courses/intro-elm/) (Richard Feldman, [tutorial files](https://github.com/badlydrawnrob/elm-playground/tree/master/frontend-masters/introduction-to-elm) in this repo)
- [Exercism](https://exercism.org/tracks/elm)'s Elm track
- [7 GUIs](https://eugenkiss.github.io/7guis/tasks/) for practice
- [Elm Workshop](https://sporto.github.io/elm-workshop/) (e.g: [stopwatch](https://sporto.github.io/elm-workshop/05-effects/02-start.html))
- [Advanced Elm](https://frontendmasters.com/courses/advanced-elm/) (Richard Feldman)
- [Other courses](https://www.classcentral.com/report/best-elm-courses/)

### 🎞️ Helpful talks

1. [Let's be mainstream!](https://www.youtube.com/watch?v=oYk8CKH7OhE)
2. [Life of a file](https://www.youtube.com/watch?v=XpDsk374LDE)
3. [Teaching Elm to beginners](https://www.youtube.com/watch?v=G-GhUxeYc1U) (good for teams)
4. [Scaling Elm apps](https://www.youtube.com/watch?v=DoA4Txr4GUs)
5. [Making impossible states impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8)[^4]
6. [Make data structures](https://www.youtube.com/watch?v=x1FU3e0sT1I)
7. [From Rails to Elm and Haskell](https://www.youtube.com/watch?v=5CYeZ2kEiOI&list=PLfc1FQC2AVoO5pibnlTz2Qj-UJ1DQXuSo)


### 🗺️ Real world examples

- [How to Elm](https://github.com/badlydrawnrob/elm-playground/tree/master/how-to-elm) (this repo, grouped by package type)
- [Andy Balaam's](https://www.artificialworlds.net/blog/category/elm/) Elm examples
- [Built with Elm](https://www.builtwithelm.co)
- [Elm Patterns](https://sporto.github.io/elm-patterns/index.html) (might be a little outdated)
- [Elm destructuring](https://gist.github.com/yang-wei/4f563fbf81ff843e8b1e)
- [Fuzz tests in Elm](https://freecontent.manning.com/writing-fuzz-tests-in-elm/)[^5]
- [Sorting comparables](https://stacktracehq.com/blog/comparing-and-sorting-in-elm/) (record)

### ❓ Some helpful FAQs

- [Elm community FAQs](https://faq.elm-community.org)
- [Why large records are OK](https://elm-lang.org/docs/records#large-records)
- [Why do I have to use Json decoders?](https://gist.github.com/evancz/1c5f2cf34939336ecb79b97bb89d9da6)
- [What, exactly, is a `Msg` for?](https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5) (no state please!)
- [Avoiding import cycles](https://tinyurl.com/import-cycles-normalisation) and normalising records

### 🛠️ Tooling

- [Hot live reloading](https://github.com/lydell/elm-watch) with `elm-watch` (or [`elm-live`](https://github.com/wking-io/elm-live)/[Parcel](https://www.youtube.com/watch?v=I7a96HHfsME)/[Vite](https://www.youtube.com/watch?v=eVsgBJqTOIE))
- [Elm land](https://elm.land) web app framework (or older [elm-spa](https://www.elm-spa.dev/)
- [Minify and optimise](https://discourse.elm-lang.org/t/elm-minification-benchmarks/9968)
- [Elm Doc Preview](https://github.com/dmy/elm-doc-preview) (great for offline documentation)
- [Everything else](https://github.com/sporto/awesome-elm) (massive list)

### 🚧 Larger programs

- [Elm Spa #1](https://github.com/rtfeldman/elm-spa-example) (by @rtfeldman)[^6]
- [Elm Spa #2](https://github.com/elm-land/realworld-app) (Elm Land version)
- [Elm Spa #3](https://github.com/dwayne/elm-conduit) (@dwayne's [version](https://discourse.elm-lang.org/t/announcing-dwayne-elm-conduit-a-replacement-for-rtfeldman-elm-spa-example/9758))
- [Elk Herd](https://github.com/mzero/elk-herd) (by @mzero but it's complex)


[^1]: A learning frame is what you are, and are not, prepared to learn. It's helpful to sketch this out upfront and stick to it. It can change over time, but setting goals and limits keeps you focused. What is it you need to learn, exactly? Here's [an example](https://github.com/badlydrawnrob/elm-playground/tree/master/programming-elm) of a learning frame.

[^2]: Meaning efficient with my time, not lazy (ok, a little lazy). A simple route with less code and complexity? I'll take it. Take this [carousel](https://github.com/erkal/erkal.github.io/blob/main/pages/Carousel/Carousel.elm) in Elm, for example. Want to be a great programmer? Go ahead, take your time! Prefer the easy route? Use [`scroll-snap`](https://css-tricks.com/css-only-carousel/) with CSS. It all depends on your vision: I'd rather have more time to pursue other things, keep things simple.

[^3]: A lot of programming books can be highly academic, and although [books like these](https://leanpub.com/fp-made-easier) can be very thorough (and suit some learning styles), for me that was the wrong approach. For example, learning how to code recursively can be intellectually stimulating and it teaches you a lot, but after a certain point, it provides diminishing returns. It's hard to know _exactly_ what you need to learn, but if your goal is to build things, aim for industry knowledge and pragmatic goals, rather than academic ones. Learn the basics well and start building things. You'll learn a lot along the way (with help from mentors), and you can do the heavier academic texts later if you enjoy that kind of thing!

[^4]: All (or most) of [Richard Feldmans talks](https://www.youtube.com/playlist?list=PL1u6QhVvC9FX1EZeIfIbG2VgVHWEyFofw)

[^5]: I'm being a little lazy here. I don't consider myself a "proper" computer scientist (and I don't code that often); more a pragmatic programmer. My goal is prototyping, so I rarely write unit tests. This isn't the _correct_ way, but Elm types give a lot of guarantees: testing the program as a regular user (like a QA) might be enough. If any bugs arise, a visitor can raise a ticket and tests can be written.

[^6]: Hopefully these three examples give an understanding of how to do Elm on a larger scale. Elm without a framework like [Elm Land](https://elm.land/) needs quite a lot of plumbing, so hopefully there'll be "one way to do it" when [Elm Studio](https://elm.studio/) eventually comes out. Alas, even that's imperfect as (I've been told) it's not plain old SQL and has abstractions to make the backend work.
