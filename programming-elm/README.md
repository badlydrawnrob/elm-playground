# README

> `elm make src/Communicate/WithServers.elm --output=04-communicate-with-servers.js`


## The sad (but real) truth

> **Do what you're good at.** I'll repeat. Do what you're good at!!! **You've got one life, so don't waste time.**
>
> Learning to program (properly) is such a _huge_ investment in time. I only really want to be able to use it for simple prototypes, proof-of-concepts, until their turning over a profit and I can find someone better than me to work with.
>
> **Remind yourself of that, and don't get bogged down with research for CompSci.** Only do it for fun or necessity (or for quick brain training).

I've forgotten at least 60% of what I learned during HTDP (the college-level course) and recursive algorithms would probably take a good deal of rejigging in my mindbox to get right (they can get very difficult!).

I don't think I have that kind of time at my disposal. There's lots of other things I'd rather be doing; high-level thought, a bit of design, learning the piano, writing a book; all of which are a considerable investment in time themselves.

- Some people make great developers
- Some people's mind is a finely-tuned logic machine
- Some people really _love_ it

I'm not one of those people. Purely practical, or good to keep the grey matter alive. And that's OK. I'm happy to do simple forms, simple json, spreadsheets for a bit of data, AI for help, and GUI tools to do the rest.

No data base admin, no heavy lifting, no racking my brains for maths or difficult algorithms. Fuck that. I'll learn enough to teach, enough to get by, enough to make some money. I can follow documentation and tutorials, cobble together some basic websites, and that's enough.

The Structure and Interpretation of Computer Programs is a nice _theoretical_ dream to complete, but it's _such_ and investment in time that would have diminishing returns.

A little like learning Mandarin! Don't do it!!! Admire the caligraphy, learn a few characters and stock phrases; move on to saner, better pursuits (for me!).


## Timesinks

> Get better at focusing in on the essentials.

- Writing notes on books or adding issues to Github
- Asking questions and figuring things out on forums
- Adding unecessary complexity ...
- Which I always end up simplifying anyway!
- Flip-flopping between tasks or learning goals
- Consuming too many books, articles, videos
    - Often trying to flip between them when I should full-ass one thing.


## Things for Anki

> Do you really need to remember how to do difficult recursive programs? NO!!! Mostly these are done for you with `map`, `filter`, `reduce` etc.
>
> - **Start with the simplest thing possible**
> - Without practice you'll forget lots of stuff
> - If you _really_ want to become a good programmer, it's lots and lots of hours of practice.
>
> For most of us who just want to _think_ like a programmer, learning about data (`set` theory, `arrays`, or [`the array I used that isn't an array!`]), algorithms, simple functions (that could be ported to Excel), and problem solvers.


## To-Dos

> There's a LOT packed into Chapter 4. It becomes a bit tricky to fit all that knowledge into cards.
>
> You **do not** need to consign all of this to memory. A good deal of it could be in a file with notes, or a small summary book of sorts. There's also documentation for things you're likely to forget...
>
> So, for some things, learn it _silently_. Add it to your Anki card but don't feel the need to explain it. Especially esoteric stuff like the unitless type `()`.

1. Basic data types: `list`, `record`, `tuple`, using the `Photo` record with `comments` and modifying in a tuple for `update`.
2. `Json.Decode` and `Json.Decode.Pipeline` visual explanation that a 12 year old would understand. You need to write this whole section in language that's easier to understand with imagery.
    - Each decoder passes it's information into one of the `Photo` decoder's record fields. **page 69** and **Beginning Elm** or other sources.
    - Show a basic decoder first (from `Json.Decode`) probably `map2`.
    - **[Order matters:](https://discourse.elm-lang.org/t/should-decoder-and-record-be-fields-order-independant/3295/4)** the order you stack up the mini-decoders within our `photoDecoder` function should mirror our `Photo` constructor function's argument's order `<function> : Int -> String -> Int -> Photo`.
    - You can potentially order the decoders in any order, so long as they use the correct `"key"` and `data` types (such as `required "id" int`) but **beware that this will screw up our `Photo` model if they're ordered incorrectly.
    - Remember `Photo` can be a curried function, or a partially applied function.
    - The decoder type signatures can be a bit confusing, but just picture it as passing your `Photo` record down the line, with each mini-decoder filling in one of the fields.
    - Briefly explain `succeed` and how this works.
    - Also explain [`hardcoded`](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/Json-Decode-Pipeline#hardcoded) and why it's handy (it allows us default values where they don't exist in the `json`).
3. Beginning Elm shows us how to set up our own localhost server. Provide a notes file with an example. Also see **pg 74**
    - But first, show an example of how to run a test on a mini-decoder, with a `"string \"which is escaped\""` and a `"""triple string"""` for our `photoDecoder`.
4. We need to be aware of the potential states of our program. Loading in from the server requires a `Result`. There's potentially an error there. To begin with, he doesn't bother writing this properly and simply uses a hardcoded data model (which represents what _would_ be loaded).
5. Once the data is loaded, there's the possiblity that the json contains no photos. We could use a `Maybe Photo` for this eventuality, which gives us a `Just a` or `Nothing`. We now also need to change our `Model` to use a simple record which can store that maybe type.
    - Remember that you can't just use `model.photo` because it's now a `Maybe` type. We have to `case` on that type depending on if it's a `Just a` or `Nothing`. (see line 172 and don't do it [this way](https://shorturl.at/rSTa7))
    - We'll have to change our `update` functions as they must consume, unwrap, and wrap the `Just a` or `Nothing` fields.
    - Show all the areas in our app that needed to be updated to reflect this.
    - We can use [`Maybe.map`](https://package.elm-lang.org/packages/elm/core/latest/Maybe#map) to achieve this (rather than the more [convoluted method](https://shorturl.at/zy6s8)). Show both options.
    - **[Show a few examples of where `Maybe` is not the best option](https://discourse.elm-lang.org/t/staying-sane-with-maybe-maybe-vs-type/9897/10), and where a `type Custom` is a better choice!**
6. You can also make use of `Maybe.withDefault` when converting a `.field` into a `text "string"` (or another data type). [See here](https://discourse.elm-lang.org/t/staying-sane-with-maybe-maybe-vs-type/9897/10) for some examples.
    - If you find yourself peppering everything with `Maybe.withDefault` it's an indication you should probably be using a `type Custom` instead (although I don't have many examples of this refactor).
7. It seems to be good practice to only consume the data that you _really_ need in your functions (especially `update` and `view` helper functions). Simplify wherever possible and **only consume the types that you must**.
    - An example would be instead of the whole `Model` you only need `Photo.url`, which is a `String`, so your type signature would be `String -> Html Msg` in your function.
    - **Revisit some examples in HTDP and `Racket Lang`** where you're using the rule of splitting functions into simpler functions; abstracting where needed.
8. Pay close attention to the `comments` form entry and button. Rewrite the following so it's simpler to understand:
    - `onInput : (String -> msg) -> Attribute msg` within a form, takes a function that returns a `msg` type variable. So `UpdateComment String` is a function and also a `Msg` type. The DOM event handler will pass the `event.target.value` as a `String` argument. Every time the value changes in the input field. See (3) in the `viewComments` function. (see also `(7)`).
    - Boolean for [`disabled`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#disabled) ([examples](https://www.w3schools.com/tags/att_fieldset_disabled.asp)) on form elements.
    - [Default `value`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#value) for form elements <s>(automatically updates the model element passed to it.</s> It's an opaque type so you can't "get" the value)
    - [`onInput`](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput) Html event (pass to a `Update String` message)
9. We don't have to worry about comparing too much with javascript, but it's worth noting that Elm's aim is to [avoid side effects](https://elmprogramming.com/side-effects.html) (mutating state).
10. HTML5 forms offer a nice addition by validating user entry, such as the `email` form field. **Careful! This can be manipulated by bad actors.**
    - You will allways still have to validate any data submitted on the server, making sure is clean and safe data. The required attribute can be manipulated by a malicious user.
    - Perhaps you could leave the validation to HTML5 forms, but make sure it's a `String` before saving it as `json`?
11. You don't need to add this to an Anki card as it's hard to remember! But the `()` unitless type is used for `Browser.element` and also requires `Sub.none` and `Cmd.none`. It also wraps the model and the command in a tuple: `( model, Cmd.none )`.
12. Have a little go at `map`, `filter`, `reduce` in Elm lang.



## Chapter 4

### The simplest thing first

It seems to be a technique to **start with a data model that we can use** _instead of the json_ that we're going to expect from the server. Do that first so you can set up the structure of your app, and then worry about loading the JSON.

### Decoders are difficult

><s>Write a simple introduction for a 12 year old.
> Use images and simple words where possible. Do one for the simplest thing possible (`Json.Decode.map2`) and one using the `Json.Decode.Pipeline`. Take a look at Beginning Elm and other resources to get your head around it.</s>
>
> @ see pg.69 and surrounding pages

<s>You're basically passing your record down the line through a few decoders, which check the json object `key`s and match them (in the order of the decoders) to the variables in your curried function.

Order matters! It follows the order for the `Photo` constructor function arguments. If you accidently passed a required `String` json object to a `Photo` `int`, you're going to have problems!</s>

### Now set to `Nothing` and pull in the `json`

1. <s>`onInput : (String -> msg) -> Attribute msg` within a form, takes a function that returns a `msg` type variable. So `UpdateComment String` is a function and also a `Msg` type. The DOM event handler will pass the `event.target.value` as a `String` argument. Every time the value changes in the input field. See (3) in the `viewComments` function. (see also `(7)`).</s>
2. <s>**Sketch out the flow of a decoder, and `Browser.element` and how things are passed around.** See pg.69 and earlier pages. How is `succeed` decoder passed into another decoder?
    - You need to write this whole section in language that's easier to understand with imagery.
    - [Order matters](https://discourse.elm-lang.org/t/should-decoder-and-record-be-fields-order-independant/3295/4) in the decoder (it'll populate in the order of the curried function variables), but key/values can be in any order in the json string. It maps in the order of the decoder.
    - The string in `required "name" string` decoder is the `key` in the json string.
    - Possibly a good idea to show a _basic_ decoder in the original `Json.Decode` and a more _complex_ decoder with `Json.Decode.Pipeline` as it does seem a little easier to grasp — things like [][`hardcoded`](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/Json-Decode-Pipeline#hardcoded) are handy.
    - When showing the `photoDecoder` you should've by now shown that calling the `Photo` type alias is basically the same as creating a record. It's called a `constructor` function.
    - **Order matters** if you switched the order of the `id` and `url` fields you'd get a compiler error. It follows the order of the arguments for the function (in this case a record) you're passing to the decoder.</s>
3. <s>**Add an example of loading the json** from a localhost server (see pg.74)</s>
4. <s>**Add an example of testing the json decoder** `PhotoDecoder`.</s>
5. <s>**Handling _no_ photos.** There's two possibilities: the json hasn't loaded yet, or the json contains no photos. You could start the initial state as `Waiting` message type, or something like that. You'll want to use a `Maybe` type if there's a chance of no photos from the json.</s>
    <s>- Give a few examples of areas that you must restructure now we have a `{ photo : Photo }` record (not a direct `Photo` in the model) — anything that consumes this Photo (or it's internal record values) MUST be updated! (see `toggleLike` and `updateComment`). Simplify wherever possible and **only consume the types that you must**. Also remember the `Racket Lang` rules of splitting out into simpler functions (and abstracting where needed)
    - Add an example for [`Maybe.map`](https://package.elm-lang.org/packages/elm/core/latest/Maybe#map) which does [the same job as this](https://shorturl.at/zy6s8).
    - Make sure to add a note that we're refactoring things (like adding a `Just` and changing type annotations to `Photo`, because now `Model` is wrapping `Photo` in a record.)</s>
    <s>- Gotchas! Once we've changed everything, there's one function in `view` that now needs to take a `photo` (line 172) — **you can't just use `model.photo` because thats a `Maybe Photo`. You'll need it to take a `Photo` and case on the `Maybe`!
        - You could also use [`Maybe.withDefault`](https://package.elm-lang.org/packages/elm/core/latest/Maybe#withDefault) here too (maybe).
        - Don't do this do it _[this](https://shorturl.at/rSTa7)_ way.
    - Remember we can use a curried function that supplies it's other argument when consumed by `Maybe.map`.</s>
6. <s>**pg. 75 (and check [Beginning Elm](https://elmprogramming.com/who-this-book-is-for.html) also) for a diagram of how different functional programming is from javascript** — it's pure with no [side-effects](https://elmprogramming.com/side-effects.html).</s>
7. <s>**When to validate forms** and if you can rely on only HTML5 field form validators, such as regex and disable. **I think this is a NO. You should validate it?**. Validating data: Is HTML5 form validation enough? If you're using json encoder (to post) it might well be.
    - Client-side form validation is a good way for enhancing user experience, it also provides some styling that can help to communicate that an input is required.
    - But you will allways still have to validate any data submitted on the server, making sure is clean and safe data. The required attribute can be manipulated by a malicious user.</s>
8. <s>**Should I consign the `() -> ( Model, Cmd )` setup for `Browser.element`?** I have one already in the Anki cards, but I'll _never_ remember exactly what to put. Only roughly. **That's where good notes or good documentation comes into play!**</s>
9. <s>If you're fetching from the server right away (on page load) why do you need the initial model as well? Is there a better way to do this? A blank initial model?</s>
10. **Revisit `map`, `filter`, `reduce`.** Mostly `map` for now (such as `Result.map`)
    - Create a list of records, then retrieve one of their values with `List.map .key listOfRecords`</s>
11. <s>**Recursive lists are useful to know only on a cursory level (for me at least)** as you'll most likely be using the above higher order functions where everything is pretty much done for you. I find them a little easier with Lisp, but you can get used to the Elm syntax also.
    - Recursive lists are a bit of a PITA, especially sorting algorithms, as you need to be aware of both the shape of the data flow (flat and triangular) and making sure all cases are dealt with.
    - For instance, it's easy to sort some lists, but others you'd need to keep looping until everything is sorted in order. Writing a recursive function for that becomes quite tricky.</s>


## Chapter 5






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
