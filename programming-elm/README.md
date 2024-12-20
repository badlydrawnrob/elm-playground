# README

## Elm Commands

```terminal
> elm --help

> elm init

> elm install elm/json

> elm make src/Folder/ModuleName.elm --output=00-folder-module-name.js

> elm reactor
```

## The best way to learn (redux)

> It really depends on how _deep_ you want the learning to be. Is it something I can look up in the documentation later? Will that be clear enough for me to do the job? Do I need proper examples to help me in the future?

1. Lazy loading of cards, then chunk/consolidate learning points
    - This is more time consuming with intermediate learning.
2. Isolate the learning point into a single file or module
3. Show it working _within_ the program (with comments in-place)
4. For _some_ learning points, add Anki Cards
5. It's sometimes helpful to write a summary book too.
6. Create some drawings, perhaps storify the learning point
    - Add some memorable examples that are your own.
7. Now, from time to time, refresh your knowledge
    - Watch a video, write an example, read an article, or another book on the subject. You've always got the documentation to fall back on too.
8. It's really all about practice. Memory will only get you so far.

There's often a lot packed in to a book, and you don't want to be rewriting the damn thing too much, as that's time consuming, but for _deep_ learning, this seems to be the way to go. You've got Anki to drill your memory, you've got summary notes (or a book) for reference, and you've practiced a few examples to consolidate your learning.

The problem with Elm is sometimes there's documentation but not enough tutorials or examples of how to _use_ these tools.

## Do the simplest thing first!

> Got a narly piece of `json` to decode? Start "as if" you've already imported it. Do the simple things first and leave the difficult stuff to the end (like catching errors).
>
> **<u>Whiteboard that shit out first:</u> Spend 80% of your time thinking about how to code, then code with confidence!**

- Harcode your `Model`. Decide how data should look.
- Do you _really_ need all that data? Can you simplify?
- Do we _really_ need a `Maybe` type?
- Is `type Custom` a better choice?

Build out your functions "as-if" the data is already there. Once you're happy with the `Model` and the data it consumes, work backwords and test out the bits of the `json` you'll need.

- Is it always in the same shape?
- Are there some bits of data missing sometimes?
- Is there a better source for the data?

Someone says to put off things like `Maybe.withDefault` to the very end, and start with the data so that you get saner results. Do you need a `non-empty List`? Are some `json` objects fields optional? How are you going to validate the data that's coming from, or sending to the server?


## The sad (but real) truth

> **Do what you're good at.** I'll repeat. Do what you're good at!!! **You've got one life, so don't waste time.**
>
> Learning to program (properly) is such a _huge_ investment in time — just look how much one chapter covers!!! I only really want to be able to use it for simple prototypes, proof-of-concepts, until they're turning over a profit and I can find someone better than me to work with.
>
> **Remind yourself of that, and don't get bogged down with research for CompSci.** Only do it for fun or necessity (or for quick brain training).

I've forgotten at least 60% of what I learned during HTDP (the college-level course) and recursive algorithms would probably take a good deal of rejigging in my mindbox to get right (they can get very difficult!). I don't think I have that kind of time at my disposal. There's lots of other things I'd rather be doing; high-level thought, a bit of design, learning the piano, writing a book; all of which are a considerable investments in time themselves.

- Some people make great developers
- Some people's mind is a finely-tuned logic machine
- Some people really _love_ it

I'm not one of those people. Purely practical, or good to keep the grey matter alive. And that's OK. I'm happy to do simple forms, simple json, spreadsheets for a bit of data, AI for help, and GUI tools to do the rest.

**No data base admin, no heavy lifting, no racking my brains for maths or difficult algorithms. Fuck that.** I'll learn enough to teach, enough to get by, enough to make some money. I can follow documentation and tutorials, cobble together some basic websites, and that's enough.

- Some light `sql` would be fine but ...
- Setting up a `postgres` db with a linux server is an effort ...
- Learning the ropes of even light DBA stuff is time consuming.

The Structure and Interpretation of Computer Programs is a nice _theoretical_ dream to complete, and is intellectually stimulating, but it's _such_ an investment in time that would have diminishing returns. Furthermore, learning one language is a challenge but in most jobs you'll have to master multiple languages and _keep on learning_ which can be trying. Things move especially fast in the javascript world.

It's a little like learning Mandarin — Don't do it!!! _Admire_ the caligraphy, learn a few characters and stock phrases; move on to saner, better pursuits (for me!).


## Timesinks

> Get better at focusing on the essentials, and speeding up these tasks:

- Writing notes on books or adding issues to Github
- Asking questions and figuring things out on forums
- Adding unecessary complexity ...
- ... Which I always end up simplifying anyway!
- Flip-flopping between tasks or learning goals
- Consuming too many books, articles, videos
    - Often trying to flip between them when I should full-ass one thing.


## Things for Anki

> Avoid recursion (unless simple)
> Start with the simplest thing possible
> Dedicate [hours] per day (you'll lose it)
> If not, you'll only get to [level]. Be ok with it.
> I care about teaching, simple features, data.


## To-Dos (chapter 5)

### Definitely add

> 1. Learn some things _passively_ (don't add cards)
> 2. Where there's a LOT to pack in ... REDUCE
> 3. Isolate each part of the program to revise
> 4. Have the full program available online
> 5. Create a small summary note book
> 6. Let the documentation handle it
> 7. Interleave learning
>     - Learn some things lightly
>     - Reinforce them with a project
>     - Reinforce with videos, exercises, tuts, etc

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



## Maybe add

1. How to reduce empty `div`s?
2. Parse a URL segment `/:uuid`, `/#tag`
3. Go over the two ways to use `Random` (array, uniform)


## To-Dos (chapter 6)

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


## To-dos (chapter 7)

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



## Renaming files, folders, script

**Be careful of naming conventions and refactoring the model names.** Currently I'm using the chapter names for filenames, and storing each chapter's files in it's own `src/ChapterName/..` folder.

```elm
// So this ...
module FileName exposing (main)
// Becomes this ...
module FolderName.FileName exposing (main) element
```

You'll also need to rename the script calling the Elm module in the `index.html` file. Something like this:

```html
<script>
// The name of the module
Elm.FolderName.FileName.init({
    node: document.getElementById('selector') // the HTML element
});
<!/script>
```
