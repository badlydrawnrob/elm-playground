# README

> `elm make src/Communicate/WithServers.elm --output=04-communicate-with-servers.js`

## Useful features

1. Boolean for [`disabled`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#disabled) ([examples](https://www.w3schools.com/tags/att_fieldset_disabled.asp)) on form elements.
2. [Default `value`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#value) for form elements (automatically updates the model element passed to it. It's an opaque type so you can't "get" the value)
3. [`onInput`](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput) Html event (pass to a `Update String` message)


## Things for Anki

> **Start with the simplest thing possible.** Most of these things I forget and can't remember how to do them unaided. That's a problem. I need to remember all the basic **data types** (`list`, `record`, `tuple`, `set`, `array`, etc) and some sketches to show the flow of information and functions used in the below.
>
> **There's really a LOT packed in to Chapter 4, so I'm not sure how simply I can write the notes**

## The simplest thing first

It seems to be a technique to **start with a data model that we can use** _instead of the json_ that we're going to expect from the server. Do that first so you can set up the structure of your app, and then worry about loading the JSON.

## Now set to `Nothing` and pull in the `json`

1. `onInput : (String -> msg) -> Attribute msg` within a form, takes a function that returns a `msg` type variable. So `UpdateComment String` is a function and also a `Msg` type. The DOM event handler will pass the `event.target.value` as a `String` argument. Every time the value changes in the input field. See (3) in the `viewComments` function. (see also `(7)`).
2. **Sketch out the flow of a decoder, and `Browser.element` and how things are passed around.** See pg.69 and earlier pages. How is `succeed` decoder passed into another decoder?
    - You need to write this whole section in language that's easier to understand with imagery.
    - [Order matters](https://discourse.elm-lang.org/t/should-decoder-and-record-be-fields-order-independant/3295/4) in the decoder (it'll populate in the order of the curried function variables), but key/values can be in any order in the json string. It maps in the order of the decoder.
    - The string in `required "name" string` decoder is the `key` in the json string.
    - Possibly a good idea to show a _basic_ decoder in the original `Json.Decode` and a more _complex_ decoder with `Json.Decode.Pipeline` as it does seem a little easier to grasp — things like []`hardcoded`](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/Json-Decode-Pipeline#hardcoded) are handy.
    - When showing the `photoDecoder` you should've by now shown that calling the `Photo` type alias is basically the same as creating a record. It's called a `constructor` function.
    - **Order matters** if you switched the order of the `id` and `url` fields you'd get a compiler error. It follows the order of the arguments for the function (in this case a record) you're passing to the decoder.
3. Add an example of loading the json from a localhost server (see pg.74)
4. Add an example of testing the json decoder `PhotoDecoder`.
5. Handling _no_ photos. There's two possibilities: the json hasn't loaded yet, or the json contains no photos. You could start the initial state as `Waiting` message type, or something like that. You'll want to use a `Maybe` type if there's a chance of no photos from the json.
    - Give a few examples of areas that you must restructure now we have a `{ photo : Photo }` record (not a direct `Photo` in the model) — anything that consumes this Photo (or it's internal record values) MUST be updated! (see `toggleLike` and `updateComment`). Simplify wherever possible and **only consume the types that you must**. Also remember the `Racket Lang` rules of splitting out into simpler functions (and abstracting where needed)
    - Add an example for [`Maybe.map`](https://package.elm-lang.org/packages/elm/core/latest/Maybe#map) which does [the same job as this](https://shorturl.at/zy6s8).
    - Make sure to add a note that we're refactoring things (like adding a `Just` and changing type annotations to `Photo`, because now `Model` is wrapping `Photo` in a record.)
    - Gotchas! Once we've changed everything, there's one function in `view` that now needs to take a `photo` (line 172) — **you can't just use `model.photo` because thats a `Maybe Photo`. You'll need it to take a `Photo` and case on the `Maybe`!
        - You could also use [`Maybe.withDefault`](https://package.elm-lang.org/packages/elm/core/latest/Maybe#withDefault) here too (maybe).
        - Don't do this do it _[this](https://shorturl.at/rSTa7)_ way.
    - Remember we can use a curried function that supplies it's other argument when consumed by `Maybe.map`.
6. pg. 75 (and check [Beginning Elm](https://elmprogramming.com/who-this-book-is-for.html) also) for a diagram of how different functional programming is from javascript — it's pure with no [side-effects](https://elmprogramming.com/side-effects.html).
7. When to validate forms and if you can rely on only HTML5 field form validators, such as regex and disable. **I think this is a NO. You should validate it?**. Validating data: Is HTML5 form validation enough? If you're using json encoder (to post) it might well be.
    - Client-side form validation is a good way for enhancing user experience, it also provides some styling that can help to communicate that an input is required.
    - But you will allways still have to validate any data submitted on the server, making sure is clean and safe data. The required attribute can be manipulated by a malicious user.
8. Should I consign the `() -> ( Model, Cmd )` setup for `Browser.element`? I have one already in the Anki cards, but I'll _never_ remember exactly what to put. Only roughly. **That's where good notes or good documentation comes into play!**
9. If you're fetching from the server right away (on page load) why do you need the initial model as well? Is there a better way to do this? A blank initial model?
10. Revisit `map`, `filter`, `reduce`. Mostly `map` for now (such as `Result.map`)
    - Create a list of records, then retrieve one of their values with `List.map .key listOfRecords`


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
