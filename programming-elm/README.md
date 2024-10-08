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
2. **Advantages or disadvantages of using a custom type** (over a record, say) - you have to build your own functions for getters (rather than simply accessing values with `.keys` for example).


2. I think the basic difference between `List.filter` and `List.map` is that `.filter` limits the amount of values returned, whereas `.map` provides ALL the values, changed in some way. It's more graceful using `List.map` and adding in the `updatePhoto` function etc. (in this particular program)
    - [Updating minimally, with fewer arguments](https://tinyurl.com/elm-playground-f54b4f6) is BETTER (see the `Msg` branches update functions)
    - You MUST lift the `Maybe Feed`, hence why the `Id` mapping function is placed there.
3. A `List.filter` function and using `ID` in form, click events, and `Msg` to update a particular `Photo`.
    - When to use `List.filter` over `List.map`?
    - What if your records contain different data?
    - You can't use `List.map` or `List.filter` in this case?
    - In fact, you won't even be able to use `List` if data isn't all the same types.


3. **Sketch out how the [Http command works](https://github.com/badlydrawnrob/elm-playground/blob/cfe1c7a39d4829c35552ec4252c97dd5975dde2b/programming-elm/src/WebSockets/RealTime.elm#L249):** It's actually quite hard to describe as the [`Http.expectJson`](https://elmprogramming.com/decoding-json-part-1.html#replacing-expectstring-with-expectjson) type signature isn't very easy to understand. **The [simple version in the Elm Guide](https://guide.elm-lang.org/effects/json), however is much easier to understand**
    - Visualise the flow of information ...
    - Initial fetch (or click a button and send a `Cmd`)
    - `Result` is returned with an `Http.Error` or `Ok`
    - We pass the `Ok data` or `Err error` in `Msg`
    - We handle it in the update function
    - We also handle the `view` function if either:
        - Http error
        - No json data (no `Feed`)
4. <s>Explain succinctly what `Http.BadBody` error is. Are there other errors I need to remember?</s>
5. How do subscriptions and commands differ?
    - commands tell the Elm Architecture to do something to the outside world
    - subscriptions tell the Elm Architecture to receive information from the outside world.
6. Using `let` and a `_` to temporarily print out `Debug.log String data` for testing.
7. <s>I know how `decodeString photoDecoder` is working (takes a json string), but need to make it clearer to myself what's happening with the function composition (and the fact that you've GOT to change from `msg String` to `msg Result` in the subscriptions function.
    - **Add `how-function-to-msg-works` to Anki**
    - The simple string, and the `Result`.</s>



## Maybe add

1. How to reduce empty `div`s?
2. Parse a URL segment `/:uuid`, `/#tag`
3. Go over the two ways to use `Random` (array, uniform)






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
