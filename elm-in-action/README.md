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

1. A couple of simple and more verbose examples for `<|`.
2. See the `Tuple.pair` example (also in `__Anki__`) Show an example [before and after](http://tinyurl.com/elm-lang-parens-vs-pipeline) using the `|>` operator. Show that you flip the function order around (do you do like Lisp, or like Elm?)
3. In general, I'm quite happy with Lisp style.


### More robust functions and errors (logging)

> pg. 96 (pdf) or pg. 234 (book)
>
> Tip
>
> This function could be made more robust. Currently, if it gets a photo URL to select before the photos have loaded, it ignores that error and proceeds as if nothing has gone wrong. A more robust implementation might return a Maybe Status, so that update could fire off a Cmd to record the error in a logging service. We won’t use a logging service in this book, but although it’s good to recover from errors that shouldn’t have happened, additionally logging that they happened gives you a way to later investigate what went wrong.


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
