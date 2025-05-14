# README

> The good bits of Elm
> It's a good idea to practice regularly![^1]

1. It forces you to build things without too many dependencies
2. Some low-level detail must be done by the user (js makes you a bit lazy)

These can be a blessing and a curse, as some things might be better with a dedicated package, such as image uploads. For that you have to understand what `base64` is and how file uploads work.

I'm not using `elm-format` in this repository, as I quite like my _own_ commenting style.


## Rules

> I need to start setting rules for myself ...
> How do I keep my programs simple? What's in? What's out?

1. Is this file the **best practice** way of doing things?
2. What format am I using? (custom headings or `elm-format`)
3. What indentation style am I preferring? (`2` or `4` spaces)
4. What's your **learning frame**? What's "in"? What's "out"?[^2]
5. Could Ai do this quicker/better? Use that then!!![^3]
6. See the [simplicity book](https://pragprog.com/titles/dtcode/simplicity/) and follow it's advice.


## Improvements

1. When using `port`s, it can be handy to have a cursory knowledge of javascript.
    - In general I use as little javascript as possible: set it and forget it.

## Tools

1. [Elm Watch](https://lydell.github.io/elm-watch/) (live reload your app)
2. [Clear cache](https://nicholasbering.ca/tools/2016/10/09/devtools-disable-caching/) in developer tools[^4]


[^1]: Coming back after 2-3 months off and I'm rusty as fuck!

[^2]: I'm using Elm as my go-to language and for that reason learning the details in a little more depth than, say, Python. However, my purpose is prototyping and I still want to keep my learning light. Some implementations (SPA, packages) get complicated quite quickly as an app scales.

[^3]: You can always "make it perfect" later, but time is of the essence. Can you mock it up? Iterate quicker without coding? Pair program with Ai or a professional programmer?

[^4]: This is particularly frustrating. Sometimes Elm (or the browser) caches the output file, so if you make a line change (such as updating a string) it won't properly "reload" in your browser. You could possibly use _incognito mode_ (private) instead.
