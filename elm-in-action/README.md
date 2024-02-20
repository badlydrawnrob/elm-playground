# Stuff to add to Anki?

> **[Bin first](https://hamberg.no/gtd).** Then group. Then filter. Then do.[^1]
>
> 1. A highighted and heavily bookmarked eBook[^2]
> 2. A folder full of useful screenshots from the book (not in repo)
> 3. A `Notes.elm` file for each chapter
> 4. Useful notes in each `PhotoGroove.elm` file (removed once chapter completed)
> 5. The [Elm in Action repo](https://github.com/rtfeldman/elm-in-action/commits/master/) with code examples

**Don't add cards recklessly.** One of the biggest downsides of writing revision notes and a big `to-do` list for Anki card creation is one of time. Is it really worth the overhead to create and revise this card? Perhaps I'm lazy, but in general I try to remind myself:

1. Start with NO!
    - I start projects from a place of "why would I want to do __"?
    - Is __ in-keeping with my goals? Is it a timesink?
2. _Try_ not to get sidetracked. Is this a useful waste of time?
    - I get sidetracked _all the time_, especially for CSS and new programming concepts.
    - Keep in mind _why_ you're learning. Does it fit my target goals?
    - You can waste _hours_ (and days) trying to figure things out with code :(
3. Have a great filter.
    - Group related tasks and remove ones that aren't important.
    - Where possible, find shortcuts or ask someone for help.
4. Cards should be done in 30 seconds (in general).
    - How quickly can I get to the root of the question?
    - If it takes longer than 30 seconds to solve, is there a better way to revise?

The book uses quite a few javascript examples and a lot of terminology that needn't be consigned to memory. For now, I'm only really interested in learning the language Elm, so javascript notes aren't useful (to me).[^2] Common functional programming concepts and terminology that can be shared across Lisp, Elm, and other functional languages are useful. <mark>Mark them with highlights</mark>.

## Lazy loading of cards

> - ⚠️ **To what level do I want to learn programming?**[^3]
> - 🎯 **How much do I care?**[^4]
>
> 1. **Write it down** (a brief summary of a learning point)
> 2. **Group related learning points!**
> 3. How well do you **understand?** How well do you **remember?**
> 4. Is having an example on file, or **a set of notes enough?**
> 5. **Do I understand the idea well enough?** Will it make sense in a few months?
> 6. If it's warranted, **write out a "to-do" Anki card item as a sentence of intent**, ideally in your own words.
> 7. For more complex ideas, **[3 times, 3 ways](https://github.com/badlydrawnrob/anki/issues/93)**
> 8. **Mixed learning techniques** (learning styles, formats) — add a link, a video, whatever.
> 9. **Interleave** where possible (e.g: similar ideas in lisp/elm)
> 10. **Group, filter, timebox** a potential card (using other mental models if needed)
> 11. **Create an example card in your own words!**

Learning and teaching with programming takes quite a bit of breaking things down and moving up in small steps, so that the student understands what options they have, and how to write things more succinctly.

Looking back at some of the [Racket lang challenges](https://github.com/badlydrawnrob/racket-playground/issues/1) I've really forgotten quite a bit, and the functional examples seem a verbose and long-winded.

- [ ] Which texts or online learning get it right?
- [ ] How to break down that learning for better Anki cards?
- [ ] Is linking cards to Chapter of the book enough?


## General notes for all code ventures:

> 1. How do we sketch out and prioritise new feature requests? Start with the Model!
> 2. How do you take [a large code base](https://github.com/badlydrawnrob/elm-playground/issues/12) and distill it down for an Anki card in just a few lines? Or, do you link through to the full program/file?


## Chapter 04 to-dos

> It might be an idea to break up each functionality into it's own Ellie demo. This way I can properly view the flow of each part.

### First working example

> A working PhotoGroove from a simple string of photos served on an external server: https://github.com/badlydrawnrob/elm-playground/releases/tag/0.3.23 and in Ellie App: https://ellie-app.com/qgp5GSmkLk4a1

A diagram of how the different bits fit together, mainly the initial `Http.get`, it's `Result` and how we're casing on that result, then propogating to other `Status` checks.


### General to-dos

1. We've removed our `getPhotoUrl` function, which relied on our `Array.get` function (which in turn provided us a `Maybe Photo`). Make a very concise diagram? file? piece of code? To [show the difference of our refactor](https://github.com/badlydrawnrob/elm-playground/commit/55b0d1b45ff9ee000426747bd35a34c84a0b9559).
2. Explain `side-effects`. Elm functions can't have these. All side-effects are performed by the Elm-runtime itself. Our code only describes what effects to perform.
3. **How do you uninstall packages?!**
4. Passing a `Result` and `case`ing on it

```elm
GotPhotos result ->  -- is a Result
    case result of   -- is a Result
        Ok responseStr ->  -- if Result is Ok
```

5. [Explain this refactor](http://tinyurl.com/eia-destructure-firstUrl). Note that you're no longer storing `url` but rather generating a `list` in between `case ... of` and we're using the [`as`](https://elm-lang.org/docs/syntax#:~:text=import%20List%20as%20L) keyword (`1 :: [2, 3, 4]`)
    - Rather than the base case resulting in an `[]` empty list we use `Errored ""` instead.
    - Simple question, should I use `List.head` here or something else? `deconstruct the list`
6. **`type alias Photo` also gives us a [convenience function](http://tinyurl.com/elm-in-action-convenience-func)** whose job is to build `Photo` record instances!
    - `Photo "1.jpeg" == { url = "1.jpeg" }`
    - Convert `List.map (\url -> { url = url }) urls` to the above shorter refactor.
7. Explain [this code properly](http://tinyurl.com/elm-in-action-initialCmd-HTTP) with images! [(Http.get)](https://package.elm-lang.org/packages/elm/http/latest/Http#get)
8. **Now explain how it's possible to [simplify to just `GotPhotos`](http://tinyurl.com/eia-curried-initialCmd)** (how is pg.264 of the eBook) We know we're expecting a `Ok String` or an `Error String` but where is it passed to `GotPhotos _`?
9. **Note that `_` is a common pattern for variables that we don't care about (yet) and aren't being used.**
10. Renaming modules like [`Json.Decode as Decode`](http://tinyurl.com/elm-in-action-renaming-modules)


### Dealing with refactoring

1. Type mismatch like the one below. How to fix it?
2. Refactoring [with `case` pattern matching](http://tinyurl.com/elm-lang-case-pattern-matching). Whenever you find yourself putting a `case` inside another `case` you might be able to do this. (and do it in [another language](https://dev.realworldocaml.org/lists-and-patterns.html))

```terminal
-- TYPE MISMATCH ------------------------------------------- src/PhotoGroove.elm

This `model` record does not have a `status` field:

61|     (case model.status of
                    ^^^^^^
This is usually a typo. Here are the `model` fields that are most similar:

    { photos : Status
    , chosenSize : ThumbnailSize
    }

So maybe status should be photos?
```

See http://tinyurl.com/elm-in-action-refactor-status


### `case` the `Model` more than once. Why?

> We must cater for all eventualities:
>
> 1. A server error
> 2. A "no string found" error
> 3. A `List photo` error (empty list?)

1. See this diff. Now we `case` on the model in both `view` and `update`. Why do we have to do this?
2. [Destructuring](https://github.com/badlydrawnrob/elm-playground/commit/9300630ac479894e37904f834662edd0f12557b9#r1382554700). We use `first :: rest` which we wrapped in `()` brackets. Explain.
3. Explain the difference between our original random function and the new `random.uniform` one.


### The `<|`, `|>` operator

1. <s>**A couple of simple and [more verbose](http://tinyurl.com/elm-lang-pipeline-simplifies) examples for `<|`.**
2. See the `Tuple.pair` example (also in `__Anki__`) Show an example [before and after](http://tinyurl.com/elm-lang-parens-vs-pipeline) using the `|>` operator. Show that you flip the function order around (do you do like Lisp, or like Elm?)</s>
3. **In general, I'm quite happy with Lisp style.**



### JSON and JSON Pipeline

> **There's [a couple of ways to do this](https://github.com/badlydrawnrob/elm-playground/commit/8463befd4e69c77e3ae87afeddf7b001dbf9a029#r138476648).** Currently has the pipeline method.

1. Examples of atoms
2. Examples of multiple [fields](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#field) `map3`
3. How to nest using `map3`?
4. **JSON pipeline and the [`succeed`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#succeed) function**
    - **Remind yourself of `|>` pipeline operator ([it takes some time](https://harfangk.github.io/2018/01/27/elm-function-operators.html) to wrap your head around)**
    - Think about what each "field" returns and gets passed as a value to `buildPhoto` (otherwise it would look unwieldy)
5. Understanding [`succeed`](https://stackoverflow.com/a/59329981)
6. Make a note of `(list photoDecoder)` (which is needed to turn a single `Decoder Photo` into a `Decoder (List Photo)`)

### Dealing with lists and Html

1. `tables` and concatonating lists, like `th` and `td` each wrapped in a `tr`, inside a `table [] []`.


### More robust functions and errors (logging)

> pg. 96 (pdf) or pg. 234 (book)
>
> Tip
>
> This function could be made more robust. Currently, if it gets a photo URL to select before the photos have loaded, it ignores that error and proceeds as if nothing has gone wrong. A more robust implementation might return a Maybe Status, so that update could fire off a Cmd to record the error in a logging service. We won’t use a logging service in this book, but although it’s good to recover from errors that shouldn’t have happened, additionally logging that they happened gives you a way to later investigate what went wrong.


## Chapter 05 to-dos

> In this chapter we covered JS interop through custom html elements and Ports. We also covered using a helper function to add filters to the model, and using flags and subscriptions.
>
> Use [Beginning Elm](https://elmprogramming.com/interact-with-javascript-intro.html) to better understand [subscriptions](https://elmprogramming.com/subscriptions.html) and flags. **In general I want to avoid using javascript wherever possible.**
>
> **Asking “Which approach rules out more bugs?” is a good way to decide between different ways to model data.**

### I don't like javascript

It might be useful, but I'm not going to save this to memory. If and when I need it I can look up the chapter again.

### Design choices and tradeoffs

1. Pages 323—328 are good overviews of making design decisions about the model — especially about trying to rule out bugs in our design. "Guarantees" that the compiler can give us.
2. It’s generally a good idea to keep our types as narrow as possible, so we’d like to avoid passing `viewLoaded` the entire `Model` if we can. However, that’s not a refactor we need to do right now.
3. SHARING CODE BETWEEN UPDATE BRANCHES — Usually, the simplest way to share code is to extract common logic into a helper func- tion and call it from both places. This is just as true for update as it is for any func- tion, so let’s do that!
4. Note that you can pass a model (record) to another helper function, like our `applyFilters` function. It first applies changes to the model, then passes through to the `applyFilters` helper which also adds further changes to the model.
    - You can do this on `update` in any branch
    - So if you need to add a filter, for instance, you'd need to call the function **on load**, **on change**, etc.
    - Give an example that's simpler than the slider.
    - Take care — you'd need to `Tuple.pair` and add `Cmd.none` in the _helper function_ so it's taking a model and returning a `(model, Cmd.none)`
5. <s>Elm’s division operator (/) works only if you give it two Float values. The `Basics.toFloat` function converts an Int to a Float, so `toFloat model.hue` converts `model.hue` from an `Int` to a `Float—at` which point we can divide it by 11 as normal.</s> — this doesn't seem true in 0.19.1
6. Working with Ports and external javascript also has **a problem with _timing_**. If the javascript loads _before_ the `Loaded` state happens, your javascript might not work on page load. See "browsers repaint the DOM" on page 151 of pdf. See also `requestAnimationFrame`.
7. Cmd and Sub are both parameterized on the type of message they produce. We noted earlier that `setFilters` returns a `Cmd msg` (as opposed to `Cmd Msg`) because it is a command that **produces no message after it completes**. In contrast, activityChanges returns a `Sub msg`, but **here `msg` refers to the `type` of message** returned by the `(String -> msg)` function we pass to `activityChanges`.
8. Flags and decoding javascript values with `Json.Decode.Value`

> Whereas it’s normal for setFilters to return Cmd msg, it would be bizarre for activityChanges to return Sub msg. After all, a Cmd msg is a command that has an effect but never sends a message to update—but sub- scriptions do not run effects. Their whole purpose is to send messages to update. Subscribing to a Sub msg would be like listening to a disconnected phone line: not terribly practical.



## Chapter 06

> I'll probably have to re-read this chapter — not sure it's a good idea to try and commit them to Anki cards.

1. Why does this function return `(Err 1)`
 unchanged? (tip: look at the type signature). You'd use `Result.mapError` instead.

 ```elm
 Result.map : (a -> b) -> Result x a -> Result x b
 Result.map String.fromInt (Err 1) -- == (Err 1)
 ```
2. Accessing a record value by just using `List.map` with a `.key` "function", for records. It's exactly the same as an anonymous function `(\record -> record.title)` — it takes a record and returns the content of it's title field.
3. Briefly explain how we [reduced this code down](http://tinyurl.com/elm-lang-json-decode-test) (we were checking the entire decoder but now we're just checking the optional field)
4. `decodeValue` is quicker than converting into a string, and decoding from a string. Make a note of the difference between using a hardcoded test, vs a fuzz test.
5. Sometimes it's quite difficult to know what type signature to give more difficult functions (especially when using pipeline) — see `testSlider` in `Notes.elm`






 -----


## Things for later ...

**A black box procedure** should be obvious to it's input and output, but the user _does not have to know_ anything about the internal mechanism. You should be able to change the inner workings and keep the same inputs and outputs (or at least, refactor with minimal fuss)

**Which types and functions go in each section?** (1) `Model`, (2) `View`, (3) `Update`, (4) `helper functions`, (5) `Cmd`, (6) `Msg`.

**Cleaning up code** such as: instead of `class (sizeToString ...)` could we create a function to make this class [better](https://github.com/badlydrawnrob/elm-playground/blob/5fd295c5f8a1aa5315e1a9e2e073e03566c83c14/elm-in-action/03/src/PhotoGroove.elm#L36)? Improve the user experience: display thumbnail size `medium` on page load; tabbed selection already works.

1. Draw sketches to show the black box procedures of `currying`.
    - One of them is _currying_
    - One of them is _random numbers_
2. Add a visual diagram of a more complex type annotation.
3. Add a couple more `type variable` examples to your deck. For instance [is this a type variable](http://tinyurl.com/elm-lang-is-a-type-variable) or just an argument? Is it wise to [never use them](https://discourse.elm-lang.org/t/the-use-and-over-use-of-type-variables/2044/5)?
4. As the main `view` function gets bigger with more `Html` elements, how can we keep the code nice to view at-a-glance? In proper HTML there's more indentation and it's easier to see the different elements.
5. What other options are there than `onClick` for events?
6. A DOM picture and a Elm runtime picture
7. A basic `model->view->update` — a view takes a model and returns a list of Html nodes, user events like clicks get translated into message values, messages get run through the update function to produce a new model, after an update a new model is sent to the view function to determine the new dom, so on (reduce this down to 3 simple steps)
    - Use the type alias of the `Model`
    - Make links between `Big Bang` in Racket lang and Elm's runtime
8. How do we migrate from a simple static `Model` (that `main` consumes), to `Browser.element` and beyond?
9. [Destructuring](http://tinyurl.com/eia-destructure-firstUrl), both in `case` and in `functions` like this example.


## Various design decisions:

- `Loaded Photo (List Photo) String` ([non-empty list](http://tinyurl.com/eia-design-decisions-nonempty))




[^1]: Most things should be punted to **some day**: that goes for books, courses, learning a new thing (I'd love to play piano well), starting a new project, so on. For instance, I tried to work through both SICP and Elm in Action and there's simply not enough headspace to do both productively. [Apocryphal or not](https://www.cnbc.com/2018/06/05/warren-buffetts-answer-to-this-question-taught-alex-banayan-a-lesson.html), the 5/25 rule is all about honing in on what's important. Unless you're a kid, you simply don't have time to do everything well. Programming and learning are NEVER-ENDING. So be pragmatic and do a handful of things well.

[^2]: I have color-coordinated some sections with highlights on the _Elm in Action_ ebook. Just how useful these notes are is up for question. It's quite hard to skim the book for knowledge; that would be a job for documentation, or "micro programs' where everything is in-place.

[^3]: Remember to be careful with your time and energy! Eli5, RRr, Bin first, filter, and timebox tasks.

[^4] Always. Always [keep in mind your learning target](https://github.com/badlydrawnrob/elm-playground/issues/9).
