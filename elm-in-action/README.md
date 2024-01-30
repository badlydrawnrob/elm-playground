# Stuff to add to Anki?

> See the Books app on Mac for highlighted eBook
> _See `./__ANKI__` in local folder (not in repo)_.

Don't add cards recklessly. Is it really worth the overhead to create and revise this card? Remember your "bin first" approach to grouping, filtering, and timeboxing tasks (and your tendency to get side-tracked!)

The book uses quite a few javascript examples and a lot of terminology that needn't be consigned to memory — shared concepts and important keywords/terminology could be useful. <mark>Mark them with highlights</mark>.

For now, I'm only really interested in learning the language Elm so javascript notes aren't useful (to me).[^1]

## Lazy loading of cards

> - ⚠️ **To what level do I want to learn programming?**[^2]
> - 🎯 **How much do I care?**[^3]
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

## Candidates for an Anki card

> A brief note on how to sketch out and prioritise new feature requests. Start with the Model!
>
> How do you take [a large code base](https://github.com/badlydrawnrob/elm-playground/issues/12) and distill it down for an Anki card in just a few lines? Or, do you link through to the full program/file?

## For now ...

### Currying

- Draw sketches to show the black box procedures
    - One of them is _currying_
    - One of them is _random numbers_

A black box procedure should be obvious to it's input and output, but the user _does not have to know_ anything about the internal mechanism. You should be able to change the inner workings and keep the same inputs and outputs (or at least, refactor with minimal fuss)

### Type annotations

1. Add a visual diagram of a more complex type annotation.

- <s>A type annotation for a proper function (see chapter `3.1.4` and `Table 3.5` in the book for a breakdown) — I think visuals would help here!!
    - In the book it starts with `String.padLeft`
    - With currying it's a little tricky to get your head around
    - But break it down into three separate functions (using nested variables) and it's easier to get.
    - Technically, every Elm function takes only one argument, and maybe returns another function</s>

### Type alias

- <s>A type alias declaration assigns a name to a type, much as a constant assigns a name to a value.
* Type aliases to reduce code duplication
    - https://guide.elm-lang.org/types/type_aliases
    - Use the example with an Array (but don't mention it much)
* More type alias examples here: https://guide.elm-lang.org/types/type_aliases</s>

### Type variables

- <s>Type variables represent concrete types that have not been specified yet.
- Give a brief introduction to [`Type Variables`](http://tinyurl.com/elm-lang-type-variables)
    - For example `number` is a type variable.
    - `fromList : List elementType -> Array elementType`</s>

### Errors

* Quiz: [explain why this code doesn't work](https://ellie-app.com/q7sGdX6wLfsa1) (broken link!)
    1. Error in the book `http://elm-in-action.com/list-photos`
    2. Missing a `/` ...
    3. Where do you go to first in the code to fix a problem?
* (Related to (23)) explain why [this error message is occuring](https://ellie-app.com/q8kbndhqGX2a1).




### Custom Type

- A type declaration defines a new custom type, one that did not exist before.
- Custom types can hold more-flexible data than records or tuples can.
- Custom type variants can be either values that are instances of that custom type, or functions that return instances of that custom type.
- You can destructure custom type variants in case-expressions to extract their data.
- What is a custom type option? See `ThumbnailSize`. Note that it's Title case (sorta)
    - What does a ThumbnailSize equal?
    - `Medium == Medium` but not equal to ...
    - Note that `|` pipe operator is used for custom types too to enumerate a list of types
    - Quiz: Why is line 76 in PhotoGrove using `size` variable rather than `ThumbnailSize`?
    - Why don't we need a default branch? [What happens if `size` is something other](https://ellie-app.com/q7TjWjDQZn8a1)? (can't happen, if it's not a valid `ThumbnailSize` it'll fail?)
- Add a link for more info for types https://elmprogramming.com/type-system.html

### Maybe

1. `Maybe` and it's Union Types `Just` and `Nothing`

- A brief introduction to `Maybe`:
    - http://tinyurl.com/elm-lang-maybe-dont-overuse
    - Give an example of _deconstructing_ `Just` and `Nothing` (see line `381` in `Notes.elm`)
    - https://exercism.org/tracks/elm/concepts/maybe#

### The Elm Runtime

- A DOM picture and a Elm runtime picture
- A basic `model->view->update` — a view takes a model and returns a list of Html nodes, user events like clicks get translated into message values, messages get run through the update function to produce a new model, after an update a new model is sent to the view function to determine the new dom, so on (reduce this down to 3 simple steps)
    - Use the type alias of the `Model`
    - Make links between `Big Bang` in Racket lang and Elm's runtime

### Our Model

- Create a document that shows:
    - A simple _static_ model (basic data)
    - A `Browser` dynamic model (with a message)


### View

1. Users can now select from one of three thumbnail sizes.

- Also note that `view` functions have `view` in front of their function name. Is this a standard?
    - Note that other `helper functions` don't do this.
    - I guess it's only Html elements that require it?
- A quick note on `type_` for the radio button is named because `type` is a reserved word.
- How can we make our Html cleaner when calling the `viewSizeChooser`?
- How would we create a `sizeToClass` function, to replace the current `class (sizeToString ...)` chunk?
    - Requires outputting the `class "string"`
    - What the type annotation would be?
- See another version of `onClick` here with a button.
    - https://guide.elm-lang.org/architecture/buttons
- A simplified version of the thumbnail size changer ... you can fuse this with, perhaps, a `Typed` `Msg`.
- Improve the user experience:
    - display thumbnail size `medium` on page load
    - In Safari (with tabbed option selected) the size changes when you tab to the radio button and use the arrow keys to select!
    - What other options are there than `onClick`? (see **Tip** on page 76 of pdf). See also [Html.Events](https://package.elm-lang.org/packages/elm/html/latest/Html.Events)

### Messages

1. From now on, whenever we add a new Msg value, the compiler will give us a missing-patterns error if we forget to handle it (as when we didn’t account for `ClickedSize`).

- If we have more than one `Msg` what do we do?
    - We have two `onClick` events now.
- Migrating from a single `Msg` (a record) to multiple, and different kinds of `Msg` data.
    - [Explain these changes!](https://github.com/badlydrawnrob/elm-playground/commit/3e66e8a99b1a702c467c319b2abb1ea025af9e5a#diff-bf15ae9c129c62ed2594aaad110aea910f4ea83ba7fb0c6332813bb0e90847ec)
    - Cut out **everything** except for the messages and the `Msg` type alias.
    - Note the problems with trying to smush it all into a single `Msg` (changing the data in the `Msg` type alias creates an error, adding unrelated data to unrelated `Msg` types with `onClick` feels wrong, adding a new type of message — one is a `"string"` the other is a `ThumbnailSize`, etc.)
    - **Seperation of concerns!**
    - Converting `Msg` as a CUSTOM TYPE
    - Line `440` gives a so-so summary of what was happening in our original code (how `Msg` was getting passed around).
    - **BETTER TO MAKE A DIAGRAM OF ALL OF THIS!!! Show the data flow on a whiteboard diagram**

### Update

- The `update` function looks weird
    - Two `if` statements, so two ways a `Model` could look (as well as the do nothing `Model`)

### Case statements

- If you don’t write a fallback `_ ->` branch in a case-expression, you’ll get a compiler error unless your code handles all possible cases.
- Converting an `if` statement to a `case` statement
    - How to flatten a complex nested `case` statement?
    - http://tinyurl.com/elm-lang-case-vs-if-else
    - Conditional branches (like lisp's `cond`)
    - Explain the `_` underscore (the `else` part)
        - It's the _default_ branch

### Commands

1. It has a Surprise Me! button that selects a thumbnail at random.

- An elm function given the same arguments will output the same value every time. A **command** however is a value that describes an operation for the Elm Runtime to perform. Running the same command multiple times can have different results.
- What is a command? [How does an update function differ before](https://github.com/badlydrawnrob/elm-playground/commit/0f843dff086a032b6790c0f006670f0a27ad3370#diff-bf15ae9c129c62ed2594aaad110aea910f4ea83ba7fb0c6332813bb0e90847ec) and after we have a command? Go over type variables again for `Cmd Msg`. Tuples too.
    - See `Figure 3.8` for a visual view
    - Go over the difference between custom types `Msg` and type variables `msg`.
    - `Random.generate` is also a _higher order function_.
    - Difference between `Browser.sandbox` and `Browser.element`?
- More in depth on `Random` and `Commands` — [Elm Guide](https://elmprogramming.com/commands.html)
- Also here is a [misunderstanding of how `Random` works](https://www.reddit.com/r/elm/comments/bb2xd3/what_is_wrong_with_random/) ....

### Arrays and lists

- `Array.get` prevents runtime crashes by returning a Maybe instead of a normal element.
- [Arrays vs lists](https://stackoverflow.com/a/37707812)

### Other stuff

- The `()` type (known as unit) is both a type and a value. The only value of type () is the value ().
- The type `Program () Model Msg` refers to an Elm Program with no flags, whose model type is Model and whose message type is Msg.


## For later

1. Add a couple more `type variable` examples to your deck. For instance [is this a type variable](http://tinyurl.com/elm-lang-is-a-type-variable) or just an argument? Is it wise to [never use them](https://discourse.elm-lang.org/t/the-use-and-over-use-of-type-variables/2044/5)?
2. As the main `view` function gets bigger with more `Html` elements, how can we keep the code nice to view at-a-glance? In proper HTML there's more indentation and it's easier to see the different elements.


## Chapter 03
























[^1]: I have color-coordinated some sections with highlights on the _Elm in Action_ ebook

[^2]: Remember to be careful with your time and energy! Eli5, RRr, Bin first, filter, and timebox tasks.

[^3] Always. Always [keep in mind your learning target](https://github.com/badlydrawnrob/elm-playground/issues/9).
