# README

> All the good bits of Elm ... (without `elm-format`)

It's better to practice a little and often, otherwise you'll get rusty.[^1]

1. Elm can be quite low-level sometimes but it removes dependencies
2. While prototyping routes see how much coding you can avoid doing
3. Only code up forms if they're (a) simple (b) effective (c) fun

Elm with Ai is very hit-and-miss at the moment, but (in my rules) I try to reduce coding for the idea validation period; brutalist, minimalist, zen design. The API and database seems fine by hand, but it would be remiss to avoid Ai, which is now quite capable of paper-prototyping a UI very quickly. This can be tested with live users.

Elm can later be used to code up an app properly, or outsourcing is an option. Certain areas of Elm are not particularly well developed, such as [image uploads](src/File/ImageForm.elm). A [cheap image service](https://uploadcare.com/) can be used, but you'll not get the fancy UI (ports maybe).


## Rules for myself

> Set a learning frame and some rules for yourself
> What's in? What's out?[^2] How do I keep my programs simple?

**Don't repeat yourself** (one is enough, no duplicate examples)

1. Is this **best practice** to the best of my knowledge?
2. Is this something **Ai could do better**? Why break my back?[^3]
3. Is there a tool I can use to spead up validation?[^4]
4. Is this the [simplest](https://pragprog.com/titles/dtcode/simplicity/) program I could possibly make?


## Build

> Working examples by running `elm reactor` or using `/build/..` files.

There's also `src/Anki` and `00-anki-testing.html` files for testing out [Anki programming flashcard](https://github.com/badlydrawnrob/anki) code examples before building your cards.


## Improvements

1. When using `port`s, it can be handy to have a cursory knowledge of javascript.
    - In general I use as little javascript as possible: set it and forget it.

## Tools and guides

1. [Elm Watch](https://lydell.github.io/elm-watch/)[^5] (live reload your app)
2. [Elm Patterns](https://sporto.github.io/elm-patterns/index.html) (common ways of Elm-ing)
3. [Clear cache](https://nicholasbering.ca/tools/2016/10/09/devtools-disable-caching/) in developer tools[^6]


[^1]: Coming back after 2-3 months off and I'm rusty as fuck!

[^2]: Elm is generally my go-to language in terms of depth of learning. Python is extra. I'm more concerned with doing things the Elm way, but realise that as programs scale up they're generally a bit too complicated for me (a large Elm Spa, for example) ... so I keep learning light and aim for simplicity for prototyping. If it makes money, I can hire.

[^3]: You can always "make it perfect" later, but time is of the essence. Can you mock it up? Iterate quicker without coding? Pair program with Ai or a professional programmer?

[^4]: Tally forms, for example, is really excellent and worth using if forms are in any way complex. There's no point in spending hours on a form if it doesn't convert. Once you've got a working formula, you can code it up proper.

[^5]: You'll need to manually point the `elm-watch.json` config to your current working package.

[^6]: This is particularly frustrating. Sometimes Elm (or the browser) caches the output file, so if you make a line change (such as updating a string) it won't properly "reload" in your browser. You could possibly use _incognito mode_ (private) instead.
