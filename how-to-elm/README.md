# README

> All the good bits of Elm ...

It's better to practice a little and often, otherwise you'll get rusty.[^1]

1. Elm can be quite low-level sometimes but it removes dependencies
2. While prototyping routes see how much coding you can avoid doing
3. Only code up forms if they're (a) simple (b) effective (c) fun

**Ai+Elm is hit-and-miss at the moment**, and on the few occassions I've used it you really have to be on the ball; it gives overly complex solutions and hallucinates.

**Do you have customers yet? No? Then use Ai where possible!** Validate your idea quickly with brutalist, minimalist, zen code and ui. For paper prototyping try to reduce as much hand-coding as possible, and lean on 3rd party tooling. You're looking to do basic user testing before worrying about how code looks! Your API might be best hand-coded but strip everything back where possible. Ai is quite capable with regular frontend and css.

**Coding with Elm really takes quite a lot of time.** For example, this [image upload](src/File/ImageForm.elm) program took a day to achieve. That's too long when prototyping! Elm can be used later to code your app properly, or outsource.


## Rules for myself

> Set a learning frame and some rules for yourself!
> What's in? What's out?[^2] How do I keep my programs simple?

**Don't repeat yourself** (one is enough, no duplicate examples)

1. Is this **best practice** to the best of my knowledge?
2. Is this something **Ai can do better?**? Quicker? [^3]
3. Is there a tool I can use to speed up idea validation?[^4]
4. Is this the [simplest](https://pragprog.com/titles/dtcode/simplicity/) program I could possibly make?


## Build

> Working examples are in `/build/namespace-package.js` or run `elm reactor`.

There's also `src/Anki` and `00-anki-testing.html` files for testing out [Anki programming flashcard](https://github.com/badlydrawnrob/anki) code examples before building your cards.


## Improvements

1. Use `elm-format` on real projects with a team.
2. Using `port`s, a little javascript knowledge can be handy.
3. Hire other people to do the bits you don't enjoy (like javascript!)

## Tools and guides

> See the main [`README.md`](../README.md) for help

You may like to use [`elm-watch`](https://lydell.github.io/elm-watch/)[^5] to live-reload your app, and [clearing the cache](https://nicholasbering.ca/tools/2016/10/09/devtools-disable-caching/) can help when refreshing compiled javascript.[^6]


[^1]: Coming back after 2-3 months off and I'm rusty as fuck!

[^2]: Elm is generally my go-to language in terms of depth of learning. Python is extra. I'm more concerned with doing things the Elm way, but realise that as programs scale up they're generally a bit too complicated for me (a large Elm Spa, for example) ... so I keep learning light and aim for simplicity for prototyping. If it makes money, I can hire.

[^3]: Why break my back when it takes a fraction of the time with Ai to prototype a program? Time is of the essence! Make it "perfect" later and mock it up quickly to validate. Pair-program with Ai and do it yourself later with a mentor (or hire).

[^4]: Tally forms, for example, is really excellent and worth using if forms are in any way complex. There's no point in spending hours on a form if it doesn't convert. Once you've got a working formula, you can code it up proper.

[^5]: You'll need to manually point the `elm-watch.json` config to your current working package.

[^6]: This is particularly frustrating. Sometimes Elm (or the browser) caches the output file, so if you make a line change (such as updating a string) it won't properly "reload" in your browser. You could possibly use _incognito mode_ (private) instead.
