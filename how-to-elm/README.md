# README

> All the good bits of Elm ...

Avoid getting rusty by practicing little and often.[^1]

1. Elm has fewer dependencies but can be low-level in detail
2. Sketch out routes to limit coding and pick better ones. Never satisfice!
3. Prototype with Ai and tooling to avoid timesinks! (E.g: forms)
4. Keep only best practice versions (1 example to best of my knowledge)

**Ai+Elm can be hit-and-miss at the moment** with complicated solutions, hallucinations, and chatbots varying from local results (that have access to code/compiler). You can [improve reliability](https://simonwillison.net/2025/Mar/11/using-llms-for-code/#context-is-king):

- Write some tests (or a rubric)
- Feed it examples you like (e.g: `elm/parser`, ask it to write tests)
- Ask it to read the entire library (or `docs.json` for smaller context window)
- Ask it to step you through the code (ELi5, racket stepper)
- Ask it to optimise the code (speed, ELi5, my stupid future self)
- Give it access to the Elm compiler (and follow the errors)
- Have it re-read it's code for errors (or use 2 LLMs)

**Do you have customers yet? No? Then minimise your effort!** Validate your idea quickly with brutalist, minimalist, zen code and ui. For paper prototyping try to reduce as much hand-coding as possible, and lean on 3rd party tooling. You're looking to do basic user testing before worrying about how code looks! Your API might be best hand-coded but strip everything back where possible. Ai is quite capable with regular frontend and css.

**Coding with Elm really takes quite a lot of time.** For example, this [image upload](src/File/ImageForm.elm) program took a day to achieve. That's too long when prototyping! Elm can be used later to code your app properly, or outsource.


## Areas of improvement

1. Mine useful examples in [this repo](https://github.com/dwyl/learn-elm/tree/master/examples)
2. Use `elm-format` on real projects with a team.
3. Using `port`s, a little javascript knowledge can be handy.
4. Hire other people to do the bits you don't enjoy (like javascript!)
5. Investigate [performant elm](https://juliu.is/performant-elm/)



## Rules for myself

> My learning frame. What's in? What's out?[^2]

1. Keep your programs and state [simple](https://pragprog.com/titles/dtcode/simplicity/)
2. Sketch out the routes before coding
3. Ask Ai if you don't understand or quick fix[^3]
4. Use tooling to speed up prototyping/validation[^4]
5. Unless it's 10x better, stick to what you know
6. Find a mentor for high risk code (like JWTs)



## Build

> Working examples are in `/build/namespace-package.js`.
> Use `elm reactor` or `elm-watch` for a quick look at the package.

There's also `src/Anki` and `00-anki-testing.html` files for testing out [Anki programming flashcard](https://github.com/badlydrawnrob/anki) code examples before building your cards.



## Tools and guides

> See the main [`README.md`](../README.md) for help

You may like to use [`elm-watch`](https://lydell.github.io/elm-watch/)[^5] to live-reload your app, and [clearing the cache](https://nicholasbering.ca/tools/2016/10/09/devtools-disable-caching/) can help when refreshing compiled javascript.[^6]


[^1]: Coming back after 2-3 months off and I'm rusty as fuck!

[^2]: Elm is generally my go-to language in terms of depth of learning. Python is extra. I'm more concerned with doing things the Elm way, but realise that as programs scale up they're generally a bit too complicated for me (a large Elm Spa, for example) ... so I keep learning light and aim for simplicity for prototyping. If it makes money, I can hire.

[^3]: Why break my back when it takes a fraction of the time with Ai to prototype a program? Time is of the essence! Make it "perfect" later and mock it up quickly to validate. Pair-program with Ai and do it yourself later with a mentor (or hire).

[^4]: Tally forms, for example, is really excellent and worth using if forms are in any way complex. There's no point in spending hours on a form if it doesn't convert. Once you've got a working formula, you can code it up proper.

[^5]: You'll need to manually point the `elm-watch.json` config to your current working package.

[^6]: This is particularly frustrating. Sometimes Elm (or the browser) caches the output file, so if you make a line change (such as updating a string) it won't properly "reload" in your browser. You could possibly use _incognito mode_ (private) instead.
