# README

> Have a clear learning frame and concrete outcomes in mind ...

**"Programming Elm" is for the beginner to intermediate** and packs a lot in (quite densely worded and wordy), so don't rewrite it (as a notebook) unless absolutely necessary. Some books are easier to come back to later; I don't think "Programming Elm" is quite that book. The working examples are very handy to look back on though.

**Later chapters suggest to use Vite and Create Elm App, but I think this is overkill.** I'm using [Elm Watch](https://lydell.github.io/elm-watch/) and for anything more involved, consider [Elm Land](https://elm.land).[^1] My motto is to use as few dependencies as necessary, and any dependency you do use should follow the [5 finger rule](https://github.com/badlydrawnrob/elm-playground/issues/45). You can find the book's repo [here](https://github.com/jfairbank/programming-elm.com).

**My learning frame is "Elm (no js), Python, SQLite, simple data, low state, web app prototypes".** I try to stick to that for everything I do and learn. This gives your learning shape, making it easier to say "yes" or "no" to the vast amount of learning resources (or even chapters in a book) you have at your disposal. You'll be bouncing off the walls otherwise, as there's so many resources and ways to learn how to program. As an example, simple web apps require very different learning to game design; although there's overlap at the beginning, at the intermediate level it forks into two very different learning paths.

**I have ideas for digital products and need a working prototype to validate an idea.** The goal is to do this in as _little code as possible_ — using Ai to help, reducing state and user interface (UI) complexity, utilising tools like [Tally forms](https://tally.so)) and [paper prototyping](https://www.goodreads.com/en/book/show/941372.Paper_Prototyping) to get the job done. Advanced features and fancy stuff can wait until I can afford a team, and the _really_ hard part is marketing and sales, which should be 50% of output (at least).

**Unless you code 5+ hours every single day (which I don't), building web apps will be a slow process.** Vibe coding and Ai agents are on the rise, which speed things up, but we're a long way off Ai building our businesses for us (for Elm at least). A clear learning frame for everything you do reduces wasted time and effort.


## Learning Programming Elm notes

The reality of learning is if you don't use it, you'll lose it; a little everyday goes a long way! When running through a tutorial or a book, my process is generally:

1. Make notes (this can take up a lot of time)
2. Group notes (that relate to each other)
3. Cull notes (remove anything I have flashcards for already)
4. Concrete examples (clear outcomes and well-shaped code)
5. Focused and diffuse (two modes of learning)

For niche knowledge, rarely used functions, or easy to remember stuff, lean heavily on documentation or document it yourself in project files; refer to those later if your memory slips.

### Helpful learning methods

> It really depends how deeply you want to learn: is it within my learning frame?

Elm is niche but boring and stable: unfortunately there's not enough tutorials for advanced stuff, and to be honest larger apps get hard to understand and quite low-level (not as many frameworks for web apps). When faced with a complex option and a simple one, always prefer the latter.

1. Create stories and drawings (make it fun)
2. Is this piece of information essential?
3. If not, consider leaving it out. Reduce.
4. Interleave learning (focused and diffuse)
5. Isolate code examples as well as code in context.
6. Lazy load cards. Chunk knowledge.
7. Outsource esoteric code samples.
8. Refresh and consolidate knowledge regularly.
9. Some things can be learned passively
10. Some things can be learned just-in-time
11. Understanding comes first, then revision


### Summary notebooks

You might benefit from distilling learning down to a small summary notebook (as well as, or instead of flashcards) for highly useful information. Creating and managing notes and flashcards can be very time-consuming, so decide on a learning frame, use lazy loading, and use time wisely.

### Other ways to learn

> Anki is great for short snippets of information, stories are better for complex learning points.

You can always refresh your learning with another tutorial or book. Flashcards and project files also work well together, flashcards to isolate the learning point and essential code, project files to revise code in-context. Try to group learning outcomes with different mediums: tutorials, videos, reading code, allow for focused and diffuse modes to take action and lock-in knowledge. Writing it out in your own words (comments, documentation, code examples), with memorable "stories" and examples really helps.

### Other helpful tips

1. **Act "as-if" the program already works**
    - Write the type signatures, header statement, etc
    - Hard code bits of the program first (api, function body, `json`)
2. **Create a wishlist and get the easy parts done first**
    - It's also better to write things down
3. **Use the HTDP [design recipe](https://course.ccs.neu.edu/cs2500f18/design_recipe.html) when you get stuck**
    - Use tables of inputs and outputs (a [stepper](https://www.youtube.com/watch?v=TbW1_wn2his))
    - Use `Debug.log` to understand what's happening
    - Work backwards (start with the outcome and reverse engineer)
4. **Use a whiteboard, or sketch out the problem**
    - Spend 80% of your time thinking about the problem
    - Then 20% time coding with confidence

### Avoid timesinks

> Stick to a learning frame of "will learn" and "won't learn" knowledge

- Adding needless complexity that involves new learning (YAGNI)
- Anything that takes me more than 2—4 hours per day (I have limited time)
- Anything too academic that isn't suited to intermediate level (like the SICP book)
- Anything involving complex state and interactions (conditional forms bring pain)
- Asking for help that isn't concrete enough (make it easy to help you)
- Consuming too many books, articles, videos (stick to one at a time!)[^2]
- Flip-flopping between tasks and learning goals (cognitive load)
- Learning difficult concepts that are niche (do you really need it?)
- Learning recursive functions (I've learned these before, very time consuming)
- Learning complex data types and huge programs (prefer small and lean)


## Elm commands

1. `elm --help` see help docs
2. `elm init` initialise a project
3. `elm install elm/json` install a [package](https://package.elm-lang.org)
4. `elm make src/Main.elm --output=app.js` compile project
5. `elm reactor` start the server

## Elm Watch commands

> Used in `06-build-larger-apps`

1. `npm install --save-dev elm-watch` install [elm watch](https://github.com/lydell/elm-watch)
2. `npx elm-watch init` initialise a project (may need to change `elm-watch.json`)
3. `npx elm-watch hot` live reload with errors (and change compiler options)
4. `npx elm-watch make --optimize` compile project

## File naming

If you decide to use subfolders for working files:

```elm
module FolderName.FileName exposing (main) element
```

Then initialise the app in you `html` file like so:

```html
<script>
Elm.FolderName.FileName.init({
    node: document.getElementById('selector')
});
<!/script>
```



## Lazy Loading notes to compile (and reduce)

### Chapter 5

#### Definitely add

**First run through the app** and make sure you know how all the bits are working (even if it's a vague idea).
Sketch it out, make it visual. Add in some useful videos or links that help.

1. It can be helpful to temporarily [disable some features](https://tinyurl.com/elm-playground-e752160) when refactoring ...
    - For example, from a `Just Photo` to a `Just (List Photo)` (so that we can still load it).
2. `List.map` in ONE place with fewer arguments is preffered (abstraction with different update functions)
    - You must [lift the `Maybe Feed`](https://tinyurl.com/elm-playground-f54b4f6) every time and map it to a particular ID.
3. ~~Parse a URL segment `/books/:uuid` and `/view/#tag`~~ (just use Elm Land)


### Chapter 6

> Refactoring code is very useful: Union Types (rather than `bool`s), narrowing the types, helper functions, and abstraction ... BUT unless it makes things much simpler don't bother refactoring (inputs as an eg)

1. Write a short story that covers these changes above.
    - Have a checkbox, radio button, and dropdown example for forms
2. Could you improve line `292` with a `List.map` function?
    - List.map (viewToppings model.salad.toppings) [Tomatoes, Cucumbers, Onions]
    - You could have a `Type -> String` function for the labels
3. **Write a comparison of `List String` and `Set` with a fun example**
    - Set's API removes need for add/remove/check-already-added functions that would need to be created.
    - Set prevents duplicates and automatically sorts values
    - **What about very large sets (such as tags?)** (when to use custom types -vs- stringly typed)
        - If you're pulling in from an API (and have users adding tags) how do you manage that?
        - Think about it also from an SQL point of view.
4. See line `468`. Is there an easier way to insert toppings?
5. **Add `ToggleTopping` [before and after](https://tinyurl.com/programming-elm-commit-efd9ed5) in `how-to-elm` forms**
    - See also [this commit](https://github.com/badlydrawnrob/elm-playground/commit/f99ba126c691ef5c929f1e87d28408432400ae9e)
    - Also mention the downside of nested models `model.salad.toppings` and alternative
    - Prefer flat models! (use a custom type? See @rtfeldman and life of a file)
6. pg. 122 and onwards isn't very well explained
7. Add `Regex.contains` for validating emails as a gist?



### Chapter 7

> 1-3 just write a few basic `Debug` examples. One file is probably enough.

1. Add an `--optimise` and minifier to the chapter
    - See the notes for an explanation
    - You'll want to gzip on the server
    - The book deploys to [surge](https://surge.sh) with `npm` (pg 151)
        - History of going down (currently `408` timeouts), so I wouldn't use for mission critical stuff.
        - tiiny.host is alternative
2. Give a few basic examples of `Debug.log` (pg. 132)
    - A `case (Debug.log "decoder" msg) of` to inspect a `Result`
3. Use `Json.errorToString` for debugging the `Err _` value
4. Generally I avoid testing
    - Which errors are most important to guard against?
    - What automated (GUI) ways of testing code are there?
    - How much coverage is enough for typed functional?




[^1]: Elm Land actually _does_ use Vite, and is **very** heavy on dependencies, so proceed with caution. On the flip side it's much, much, easier to get started with routing (urls) and authentication (shared models/msg) with Elm Land than it is following [Elm Spa](https://github.com/rtfeldman/elm-spa-example/blob/master/src/Route.elm)'s example.

[^2]: Remember that any new language, factoid, or method can either be incremental (scaffolded learning) or tangental. You want to avoid at all costs tangental learning that's not directly impacting your goals, or within your chosen learning frame. Think of it like learning a new language: learning french and chinese at the same time will cause you pain — there's very little overlap between the two! The same goes for Elm and Go. However interesting it might be, they're very different (Elm and Python is hard enough!) and you've got to weigh up the benefits compared to the opportunity costs. SQLite and Postgres are by far more compatible, but SQLite is way easier to setup and migrate. The benefits must be (something like) 10x the opportunity cost of moving from one to the other; How many months will it take you to shift gears, get to production level? It's probably longer than you think! Is that microsecond of performance increase really worth 3 months of your time?
