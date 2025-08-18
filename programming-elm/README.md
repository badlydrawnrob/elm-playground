# README

> Have a clear learning frame and concrete outcomes in mind ...

**"Programming Elm" is for the beginner to intermediate** and packs a lot in (quite densely worded and wordy), so don't rewrite it (as a notebook) unless absolutely necessary. Some books are easier to come back to later; I don't think "Programming Elm" is quite that book. The working examples are very handy to look back on though.

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
- Consuming too many books, articles, videos (stick to one at a time!)[^1]
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

Previously I used subfolders for working files:

```elm
module FolderName.FileName exposing (main) element
```

Which in the `html` file needed to be written like so:

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

1. Sometimes we can temporarily [disable some features](https://tinyurl.com/elm-playground-e752160) when updating our `Model` (now a `List Photo` feed) so that we can load it.

2. `List.map` on a function:
    - [Updating minimally, with fewer arguments](https://tinyurl.com/elm-playground-f54b4f6) is BETTER (see the `Msg` branches update functions)
    - You MUST lift the `Maybe Feed`, hence why the `Id` mapping function is placed there.
3. When you decide on a type for `List a` you must stick to it:
    - `List.filter` and `List.map` expect the `List` to hold the same types
    - If they don't you get an error.
    - You can use different types in a record, but if you have `List record` each record must hold the same types. Same goes for `Result`.
    - You can create a custom function with `Result.map2` that maps three valid (but different types) into a structure.
    - But if you wanted different result types within a list, they'd need to be a custom type.


3. **Sketch out how the [Http command works](https://github.com/badlydrawnrob/elm-playground/blob/cfe1c7a39d4829c35552ec4252c97dd5975dde2b/programming-elm/src/WebSockets/RealTime.elm#L249):** It's actually quite hard to describe as the [`Http.expectJson`](https://elmprogramming.com/decoding-json-part-1.html#replacing-expectstring-with-expectjson) type signature isn't very easy to understand. **The [simple version in the Elm Guide](https://guide.elm-lang.org/effects/json), however is much easier to understand**
    - Visualise the flow of information ...
    - Initial fetch (or click a button and send a `Cmd`)
    - `Result` is returned with an `Http.Error` or `Ok`
    - We pass the `Ok data` or `Err error` in `Msg`
    - We handle it in the update function
    - We also handle the `view` function if either:
        - Http error
        - No json data (no `Feed`)
4. How do subscriptions and commands differ?
    - commands tell the Elm Architecture to do something to the outside world
    - subscriptions tell the Elm Architecture to receive information from the outside world.
5. Using `let` and a `_` to temporarily print out `Debug.log String data` for testing.


#### Maybe add

1. How to reduce empty `div`s?
2. Parse a URL segment `/:uuid`, `/#tag`
3. Go over the two ways to use `Random` (array, uniform)


### Chapter 6

> Reformatting a program is quite helpful. It shows how to simplify down a program by creating helper functions, union types rather than `bool` fields, and narrowing types. Storify it! Simple examples!
>
> However, some of the sections are hard to explain and I'm not sure the writer does a great job in parts.
>
> Remember: the simplest thing possible. Splitting out some of the `type_ "radio"` buttons into reusable functions (in my mind) made it **harder** to understand the code rather than easier. `List.map` would be easier to use with `(Set String)` too. There's more improvements to be made there.
>
> If you have a simple form then some of these refactors are not necessary.

1. **`Set` -vs- a `List String`**
    - Set's API removes need for add/remove/check-already-added functions that would need to be created.
    - Set prevents duplicate values. It automatically sorts values. It let's you look up values.
    - All values in `Set` need to be _comparable_ (and must be same type?)
    - Look at the way we're using a `Msg` for every `model.toppings` insert. Isn't there an easier way?
2. **Give an example of a simplified `Model` view function.** Bugs can be avoided by splitting out the view. If a bug is in one part of your view, you can narrow it down quicker:
    - A main `view` which takes a `model`
    - A `viewError` helper function which takes _part_ of a `model` (`model.error`) which is a `Maybe` type.
    - Find some good examples of `view` functions with **narrowed down types**?
    - Watch "scaling Elm apps" again for narrow types.
3. **Simplify `onCheck` checkboxes.** It's a curried function that will add a `bool`, so your message would be:
    - `ClickedCheckbox Option Bool`
    - `onCheck (ClickedCheckbox Option)`
4. **Readup on `Set` and `how-to-elm` examples:**
    - What about **very large sets** such as tags?
    - Is it better to use custom types?
    - Or just stick to `"string"` list?
    - Converting loads of types to strings seems a bit of an arse on.
5. **`ToggleTopping` has to continuously "delete" the `Set.remove` if the boolean is false.** Is this the only way to manage this?
    - Either way, show [the refactored version](https://tinyurl.com/programming-elm-commit-efd9ed5) in Anki
6. **Make a note somewhere about the benefits of narrowing types** — use a Draw! card to show reducing responsibilities of the update function.
    - [Nested messages](https://tinyurl.com/salad-builder-update-salad) and [this](https://tinyurl.com/salad-builder-msg-f99ba12)
    - `<<` rather than parenthesis
    - [Extensible record types](https://tinyurl.com/salad-builder-extensible) rather than nested records (pg 118-120)
    - Explain that flatter model is better!
7. We've separated concerns for our `SaladMsg`, but our `view` functions are still lumped together. We need to reach into nested `model.salad.toppings` values.
    - That can get annoying
    - You don't want heavily nested records
    - **His advice is to AVOID nesting state**, or use it very sparingly (like @rtfeldman's Elm Spa `model.form`)
8. **Quickly show some examples of lists in HTML:**
    - For example `[ H1 [] [ text "Title" ] ]` is a singleton
    - `[ H1 [] [ text "Title" ]
       , H2 [] [ text "Secondary" ] ]` is two list
    - **Write a `viewHeaders h1 otherHeaders` function, where you have `(H1 [] [ text "title" ] :: rest)`**
    - See commit `cd1b22a`
9. **Again! Sets**
    - See also the `msg` and the only function that has a `Msg` is the secondary helper functions. Their wrappers have a `Html msg` type annotation.
    - Sets must hold comparables, it doesn't seem to accept Union Types (like `Toppings`)
    - List.map (viewToppings model.salad.toppings) [Tomatoes, Cucumbers, Onions] should work here, but you'd need to convert `model.salad.toppings` to a `type alias ToppingSet = (Set String)` — I'm not sure how this might affect things, as we're binding our strings to a limited set of `Topping` here.
    - Create a simple demo and ask the community. Can you restrict the range of `ToppingSet` to a proper set of strings? Then you can't accidentally create the function with the wrong string. Or maybe it doesn't matter.
    - **pg. 122 and onwards isn't very well explained**
10. Reusable radio buttons (problem)
    - I'm not a huge fan of this refactoring (see commit #4d80b94)
    - I would say **_unless it makes things much simpler, or you have LOTS of inputs_ DON'T Bother refactoring.** It looks pretty ugly and makes it harder to read in my mind.
    - See "life of a file" for more info.
11. Explore `Regex.contains` function for validating emails
12. **Explain "impossible states" with a link to the video.** This is basically getting into trouble with boolean fields and replacing with a Union Type (sum type)
    - Draw! a simplified version of `building`, `sending`, `success`, `error`
    - Possibly link to the same authors blog posts on booleans and their downfalls.
13. Write a checkbox and radio button group where you're using custom types, rather than boolean values.
    - See "Sets" above (4), (9): you can condense all these down into ONE example file.
    - **If it's a really big set, for example many-to-many tags** from database, json, or whatever, should you stick to strings or convert to types?


### Chapter 7

> 1-3 just write a few basic `Debug` examples. One file is probably enough.

1. Give a few basic examples of `Debug.log` (pg. 132). It seems useful for when you're uncertain how things work, but ideally you just treat the function like a black box and test the input/output.
    - A single call
    - A piped call
    - Inspect `Json.Decode`r results (you can use within a case statement)
2. Somewhere mention `Json.errorToString` as an option (just unwrap the `Err` value and wrap it in this)
3. What are the essential tests you need to write and which ones are safe enough to leave off? I'm lazy and don't want to write them.
    - How much coverage is enough for typed functional?
4. Give a basic explanation of `Json.succeed` and see what alternatives (if any) for `Json.string |> Json.andThen decodeBreed`
    - Search for "decoding custom types" and ask @sebastian what other methods are there (how he keeps his custom types in sync)
    - See [here](https://stackoverflow.com/a/57248663) and [here](https://thoughtbot.com/blog/5-common-json-decoders)


```
this =
  list
    |> List.map (\n -> n * 2)
    |> Debug.log "doubled"
    |> List.filter (\n -> n > 6)
    |> Debug.log "filtered"
    |> List.map (\n -> n * n)
```


[^1]: Remember that any new language, factoid, or method can either be incremental (scaffolded learning) or tangental. You want to avoid at all costs tangental learning that's not directly impacting your goals, or within your chosen learning frame. Think of it like learning a new language: learning french and chinese at the same time will cause you pain — there's very little overlap between the two! The same goes for Elm and Go. However interesting it might be, they're very different (Elm and Python is hard enough!) and you've got to weigh up the benefits compared to the opportunity costs. SQLite and Postgres are by far more compatible, but SQLite is way easier to setup and migrate. The benefits must be (something like) 10x the opportunity cost of moving from one to the other; How many months will it take you to shift gears, get to production level? It's probably longer than you think! Is that microsecond of performance increase really worth 3 months of your time?
