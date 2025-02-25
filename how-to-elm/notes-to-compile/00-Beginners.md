# Beginners

> Here are things that a beginner should probably know ...
> Always aim to teach the most simple route (ideally the best option) ...
> Always aim to teach the "good habits" ways.

Some of these take an awful lot of time to explain, so using tools like Tally give us a big head-start. Validating big forms and json decoders are tough to teach.

1. Light introduction to decoders (but not encoders?)
2. **There's a bunch of useful info in `CustomTypes.md`** so pull out essentials
3. **Simple methods to search** (and when to store the results)
    - A `Bool` within the search items model isn't preferred.
    - Just compute the results!
    - You can store the filtered results in the model if they'll be accessed regularly, or if speed is an issue.
    - SQL should be doing some of the heavy lifting here!
4. **Errors and validation** ([don't use a plugin](https://tinyurl.com/elm-validate-form-fields) for beginners)
    - Compile a checklist (like HTDP problem solver) from `HowToResult.md`
    - Examples for forms (is @rtfeldman login page too advanced?)
    - Parse don't validate (kind of advanced but useful)
    - Never rely on HTML validators (or `js`, see `why-html5-is-shit-...`
    - It seems a lot, but validate on client, API, and SQL levels
5. **"Lifting" values** (`.map`, `.filterMap`, `.resultMap`, so on)
    - The general concept needs to be explained quite thoroughly
6. **Impossible states (in a light way)**
    - Don't use `Bool`s when you can use `StateCustomType` instead (servers etc)
    - `Err []` should never happen (`NonEmptyList`)
    - `(0,0)` should never happen (but we're forced to cover all bases)
7. The "building a song" problem (there's a few learning points there)
    - When to actually "build" the song (where in the code base)
    - The problem with "fancy" data structures (`Tuple` more work than `String`)
    - The custom type problem (`Album Song (List Song)` may have no benefit over `Maybe (List Song)`)
8. **Remember to SKETCH THE THING OUT** and avoid bad artifacts
    - Artifacts meaning complicated processes or hard-to-read code
    - **The "curs|or" problem in HTDP** covers this a little bit
    - Picking the right route may take a bit of design time ...
    - But you want the readability as easy as possible (stupid future self)
    - Alas, sometimes you need to go complex to circle back to simple (you don't know what you don't know)
9. **Have a little consideration for growing code, but don't overoptimise (YAGNI)**
    - You can see the unpacking `UserInput a` with 10 user inputs gets narly
    - You can see that conditional form loading gets fucking complex fast
    - There may be shortcuts to this, but often you need to go through the pain to understand what not to do (which can take months/years)
10. **Architecture is hard to teach** (and just takes LOTS of practice, trial/error)
    - There's many ways to do it


## Problems (that crop up)

1. Flushing the "cache" (when `.js?v1` doesn't work)
    - Happens sometimes when refactoring (e.g: changing module name)
    - `elm-watch` might be useful here (or creating new `.js` file)
2. **Computed data: client side or server side?**
    - Offloading compute to client side can save server costs at scale!
    - This can pair nicely with the "2:00" problem (RRR state)

Some things should simply be avoided (so we defensively warn against bad habits).
In this example there's a bunch of learning from "the wrong way to do it". And I
_don't know this upfront_ but learn on the way.

```elm
-- This adds complexity to the code
type UserInput a -- bound type variable
  UserInput (Result String a)
-- It also means that a `List UserInput` won't work
[Ok "This", Ok "won't", Ok "work", Ok 20] -- List must all be same type!
-- It's also storing computed values, which I've been warned against
["just store", "your", "form inputs", "as strings"]
ComputeAtRuntime a b c d
-- A function should take as few variables as possible
extractMultipleInputs one two three
-- but this could grow to be really big, depending on the form model
```



## Might be intermediate (but useful)

1. Nested records -vs- custom types (see `Songs.elm` and `CustomTypes.md`)
    - Nested records are generally discouraged
    - A flat style record with many fields is (generally) preferred
    - There's a few ways to do it (narrow types, nested `Msg`, [anon function](https://tinyurl.com/elm-spa-example-login))
