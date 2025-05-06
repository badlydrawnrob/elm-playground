module CustomTypes.Films exposing (..)

{-| ----------------------------------------------------------------------------
    A Film (similar but different to `Songs.elm`)
    ============================================================================
    You're a video man and have a range of films. Each film has a bunch of reviews,
    as well as data about the film itself. We want to add, delete, edit our videos
    and pull/push to an API (or local storage?).

        How do other apps do it?

        For your API, you can search for `FILM_ID` and get back a choice of
        `FILM_REVIEWS` which you can select from to populate the form.

        Ideally you should send as little data between server and client to make
        your app speedy. Do we pass two `Msg`? `ClickedSaveReview` and
        `SaveFilmWithAllReviews`? We need to notify the user of how we're storing
        our data gracefully.

        Do I give each review a unique ID? (the SQL database handles IDs)
        Or do we convert to an `Array` or use `List.take`, `List.indexedMap` ...

        ⚠️ Stupid (data) decisions upfront have HORRID artifacts:
           - @ https://tinyurl.com/songs-v1-possible-states (commit c25d389)
           - If there's LOTS OF STATE then FUCKING CHANGE IT!

        Customer journey ...
        --------------------

        1. User inputs form field data
        2. On input, errors are checked and shown
            - Check ON SAVE and not every keystroke
        3. User can click save (even if errors are there)
            - We check for errors and return `model` if any `Err`
            - Use must clear all errors before `Song` is created
        4. All `Song`s are added to our `Album` type


    Previous attempts
    -----------------
    > Here's some learning experiences.
    > These versions store computed user input: don't do that!

    1. Songs first version:
        - @ https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/Songs.elm
    2. Songs (alternative) with `UserInput` type:
        - @ https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/SongsAlt.elm
    ~~3. Songs (editable) — failed experiment~~
        - @ https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/SongsEditable.elm


    In a sentence
    -------------
    > Really think about how your app is going to be used, which dictates your
    > architecture and data structures. Start with the simplest thing that could
    > possibly work, and build up from there.

    - Do I use a custom type or a record for reviews?
        - Does a review have many fields, or just a few?
    - Use a FLAT style (no nested records)
        - Use NAMED input fields (every input has a message)
    - We'll have a LOT of input fields, so use a `viewInput` function to
      reduce duplication.
    - Use a basic data type (`Maybe (List whatever)` inside `Film (FilmId ...)`)
    - Use all validations on the form entries (but @rtfelman's method)
        - Consider your APP Architecture ... how are user states handled?
        - What happens when you have a `[singleton]` (album shouldn't be empty)
    - Have a fake json server (do you use `null` values?)
        - Extend this to a JSONBIN or `elm-json-server` (or similar)

    Wishlist:
    ---------
    1. Make a film's reviews siftable (asc, desc, ...)
    2. Make a film reviews editable (states `NoFilm | Film | Edit`)
        - Try to use the same form for our film states
    3. Make a film's details editable
        - We're likely going to need TWO forms: filmData and reviewData.
    4. Use `andMap` instead of `mapX` for our result?
        - Perhaps use @rtfeldman's method for reviewData, but `andMap` for
          our filmData?
    5. Make sure our reviews have `loading="lazy"` when rendered.
        - Make our first review the one that loads first (no lazy)
    6. See how `Html.Lazy` works (how does it affect load speed?)
    7. Our `Model` might get quite large with all those fields as a flat record
        - Create some narrow types for our records.
        - Takes a `{ review | ... }` for example.
    8. Aim to create a timestamp for [the film? the review?]
    9. Add to the BACK of the list, not the front (reviews)
    10. Is displaying ALL errors possible? Desirable? (if branch returns only the
        current error)
    11. Is `Result` a poor choice for a form with lots of fields?

-}

