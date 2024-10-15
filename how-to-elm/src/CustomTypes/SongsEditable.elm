module CustomTypes.SongsEditable exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type (see `CustomTypes.md` for notes)
    ============================================================================
    This started out as an alternative for a `Maybe List`. Remember that the
    simplest thing possible is often the best solution. If you don't need complexity
    then don't add it.

    Options for our `Model` (nested record/custom type)
        @ Songs.elm  -OR-  @ SongsAlt.elm

    Learning points
    ---------------
    1. `Msg` is for CARRYING DATA and NOT for changing state
        @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    2. Lift `Maybe` in ONE place when possible
    3. Look how `Song` is created; `updateAlbum` is simply passed a `Song`.
    4. A `Tuple` adds some complexity. Don't bother? (definitely not for user input)
    5. Remember the roles of `Msg`, `Update`, `View` and put functions in right place!
    6. Validating forms is a bit of a minefield. Just get something working.
        - There's many ways to do it.
    7. Remember the `2.0` fiasco. Simplify data entry at source.
    8. Also simplify your state wherever possible
        - See "The 5 ways to reduce code"
    9. Nested records are OK in moderation, but prefer a flatter style ...
        - You could easily just write a big record with more fields.
        - A custom type can reduce the need for records, but makes code slightly
          harder to read (syntax highlighting on `song.error` but not `songError`)
        - They also need deconstructing, which can add a little bulk to a function.
        - @ https://tinyurl.com/elm-lang-why-not-nested
        - @ https://tinyurl.com/elm-spa-custom-types-eg
    10. Chaining `Result`s seems like a bad idea (see `HowToResult/FieldError`)
        - Should probably only use `Result.andThen` for a single data point.
    11. The program (and data) FLOW should be as SIMPLE as possible:
        - Can you re-read it and tell EXACTLY what's going on?
        - I certainly can't do that quickly with `HowToResult/FieldError`)

    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Currently ALL fields are required. I'll need to add in optional fields also.
    You might also want to take another look at other routes for form validation.

    1. An `Album` name
    2. An `Album` image
       - See `elm-spa` for splitting up / combining types
       - unique ID for the Album? (use `uuid` for songs?)
    3. More `Song` fields (the `Tuple` problem)
       - Strip spaces from front/back of `String`?
       - Song audio or video file/link
    4. Editable `Song`s
    5. Delete a `Song`?
    6. Edit `Song` order?
    7. Reduce repetition in the view (`viewInput` function etc)
    8. Post to `jsonbin` (can we limit it to only my URL?)
       - MUST contain at least ONE song

    Other things to consider in future

        1. Validate only on save
        2. Pull in from an API (openlibrary)
        3. Splitting out components/messages/etc
        4. Only ONE `Song`?
-}
