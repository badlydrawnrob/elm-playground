# README

## Elm Commands

```terminal
> elm --help

> elm init

> elm install elm/json

> elm make src/Folder/ModuleName.elm --output=00-folder-module-name.js

> elm reactor
```

## The reality of learning

1. You'll lose it if you don't use it. Repeat!
2. Making notes and Anki cards takes up quite a bit of time.
3. Sometimes it's better to pick a new tutorial to rediscover learning points.
4. Making a summary notebook is useful, but time consuming.
5. Lean heavily on documentation where possible.
6. Create clear examples and isolate code.
7. Focused and passive learning (tutorials, videos, reading code)

The timesinks are:

- Learning difficult concepts that are niche
- Asking wide-ranging questions that need a pair programmer
- Adding needless complexity that involves new learning
- Flip-flopping between tasks and learning goals
- Consuming too many books, articles, videos

I need a reasonable working prototype that works. It doesn't have to be perfect. It can use off-the-shelf tools. Some things can wait until a team is affordable.


## Things to avoid

- Recursive functions (fuck that)
- Complex data types and big programs
- Stuff that takes more than 2-4 hours per day
- Stuff that isn't suitable for intermediate students
- Complex state and interactions


## The best way to learn (redux)

> It really depends on how _deep_ you want the learning to be. Is it something I can look up in the documentation later? Will that be clear enough for me to do the job? Do I need proper examples to help me in the future?

1. Lazy load cards. Chunk knowledge.
2. Is this piece of information essential?
3. If not, consider leaving it out. Reduce.
4. Create stories and drawings.
5. Isolate code and code in context.
6. Refresh your knowledge regularly.
7. If you don't use it, you'll lose it.
8. Outsource esoteric code samples.
9. Some things can be learned passively
10. Interleave learning (focused and diffuse)

A book packs A LOT in. You don't want to rewrite it if it's not necessary. Some books are easier to come back to (refresh learning) than others. Anki is good for short pieces of information. Stories are better for complex learning points. Example files often work too. Only use these once you understand how they work, and consolidate your learning.

Elm is a niche language. There's not enough tutorials for the hard stuff.


## Do the simplest thing first!

> - Remember "How to Design Programs" problem solvers.
> - You can act "as if" you've already got parts of the program running.
> - For instance, hardcode `json` into the program before using `Http.get`.
> - Create a wishlist and get the easy parts done first.
>
> **Use a whiteboard and sketches** before diving into the code.
> **Spend 80% of your time thinking about the problem**, then code with confidence.

- Carefully consider the data first.
- But do "the enough" thing. Don't over prepare.
- Always look for ways to simplify processes and data.
- Only use custom types when they're an improvement on simple ones.

You can always hardcode bits of your data and make them dynamic later. Use the compiler to help you refactor. For instance, you can change the shape of `json` data to fit your (simpler) model. These questions are necessary with `json`:

1. Is it always in the same shape?
2. Are there some bits of data missing sometimes?
3. Is there a better source for the data?
4. Does the API have great support? (Consider ditching if not)

Think carefully about your data:

- Do you need non-empty lists?
- Can you hold off on `Maybe.withDefault` until the very end?
- Can you validate data reliably?


## The sad (but real) truth

> 1. **Do what you're good at.**
> 2. **I'll repeat. Do what you're good at!**
> 3. **You've got one life, so don't waste time.**
>
> Programming is a HUGE investment in time. Ideally you want to learn only the things relevant to your project, or your goals. Unfortunately you often drop down rabbit holes when trying to solve problems.
>
> - What are your goals?
> - How much of these can be solved _without_ code?
> - How long can you hold off without a team?
>
> **Don't get bogged down in research.** Build just enough to turn a profit.
> Then find someone better than you to take over when you can afford it.

I don't have time to relearn the 60% of forgotten recursive learning HTDP taught me. I don't have patience to become a great programmer. I need to focus most of my time on high-level thinking, strategy, marketing, business, and sales. Then make great art (which won't be programming).

- Some people make great developers
- Some people's mind is a finely-tuned logic machine
- Some people really _love_ it

I'm not one of those people. Purely practical, or good to keep the grey matter alive. And that's OK. I'm happy to do simple forms, simple json, spreadsheets for a bit of data, AI for help, and GUI tools to do the rest.

## What I'm _not_ for

> - I'm not a database admin
> - I don't need to do the heavy lifting
> - I don't need to fall down rabbit holes
> - I don't need deep knowledge

I need to learn enough to teach, prototype, get by, and make money. I don't want to deal with virtual servers, postgres setup, big programs, or anything like that.
I want to keep things simple and manageable. I don't need to learn SICP. Or maths. Or Haskell.

It's a little like Mandarin, a nice idea, admire the caligraphy, but it has deminishing returns and doesn't align with my goals. Move on to saner pursuits that are better for my personality type and strengths.





## To-Dos (chapter 5)

### Definitely add

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
