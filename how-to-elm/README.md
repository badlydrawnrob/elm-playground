# README

> The good bits of Elm

1. It forces you to build things without too many dependencies
2. Some low-level detail must be done by the user (js makes you a bit lazy)

These can be a blessing and a curse, as some things might be better with a dedicated package, such as image uploads. For that you have to understand what `base64` is and how file uploads work.


## Rules

> I need to start setting rules for myself ...
> How do I keep my programs simple? What's in? What's out?

1. What format am I using? (custom headings or `elm-format`)
2. What indentation style am I preferring? (`2` or `4` spaces)
3. What learning is "in" and what is "out"?[^1]


## Improvements

1. When using `port`s, it can be handy to have a cursory knowledge of javascript.
    - In general I use as little javascript as possible. Set it and forget it.


[^1]: I'm using Elm as my go-to language and for that reason learning the details in a little more depth than, say, Python. However, my purpose is prototyping and I still want to keep my learning light. Some implementations (SPA, packages) get complicated quite quickly as an app scales.
