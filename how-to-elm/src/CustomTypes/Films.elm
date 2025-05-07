module CustomTypes.Films exposing (..)

{-| ----------------------------------------------------------------------------
    A Film (similar but different to `Songs.elm`)
    ============================================================================
    You're a video man and have a range of films. Each film has a bunch of reviews,
    as well as data about the film itself. We want to add, delete, edit our videos
    and pull/push to an API (or local storage?). This is quite close to one of
    my app ideas in it's implementation.

        @ https://sporto.github.io/elm-patterns/basic/impossible-states.html
        @ https://elm-radio.com/episode/life-of-a-file/ (which data struture?)

    Inspiration
    -----------
    > @rtfeldman's Elm Spa is quite complicated ...
    > @ https://tinyurl.com/clickedPostComment-Article (line 404)
    > @ https://tinyurl.com/spa-ArticleComment-post (`Http.send` is deprecated)

    A comment, for example is either in `Editing ""`, `Editing str`,
    or `Sending str` mode. No comments can be made if our comments have not
    `Loaded a` yet. Each potential "thing to be saved" passes along a `cred` and
    a `slug` (the URL path to the json server I guess). Complicated, right?

        1. Wait for the server to load and return data.
        2. The user enters a comment.
        3. The user clicks `"Save"`. (how strict is our error checking?)
        4. The comment is sent to the server (comments are disabled)
        5. The server returns a success or error message.
        6. If the comment has been saved, refresh our state to view it.

    In our version, we'll save our `Film` data RIGHT AWAY ... but our `Review`s
    will only be saved locally (for each film), and the user must press the
    "SAVE FILM" button to properly save film data to the server.

    ----------------------------------------------------------------------------

    Think carefully about the problem
    ---------------------------------
    > What does a user expect to happen?
    > How can we make it easy for them?
    > ⚠️ Is our error checking basic, or complex?

    For example, for our reviews the error checking might be very basic. We only
    need to know if a `Editing ""` holds an empty string. If not, we can send it
    straight to the server. The user might also expect their review to be saved
    right away, so our UI would need to make the "SAVE FILM" state explicit.

    Error handling
    --------------
    > ⚠️ We're mostly using @rtfeldman's Elm Spa method for error handling.

    But I'll use `Result.andMap` for the `Review` type, just to show it's possible.
    I would pick ONE method in production, and keep things consistent.

    Speed
    -----
    > We're lazy loading our images with `loading="lazy"`.
    > How does `Html.Lazy` work? (how does it affect load speed?)

    And we should try to keep the data packets small, and the pings to our server
    to a minimum.

    Mocking
    -------
    1. Imagine that your python server is ready to go.
    2. Data will be normalised and stored in a SQL database (eventually).

    ----------------------------------------------------------------------------

    THE API

        @ https://openlibrary.org/developers/api
        @ https://openlibrary.org/isbn/9780140328721.json
        @ https://covers.openlibrary.org/b/id/8739161-L.jpg
        @ https://covers.openlibrary.org/b/isbn/9780140328721-L.jpg

        OpenLibrary isn't consistant. Some books ignore certain data fields.

            978-0590353427 (strip slashes, or char == digit)
            https://www.jsondiff.com/ (diff the two `json` files)

        Mock up a `List Review` that's similar to `ISBN` API above.
        Use only the data points that are most consistant: the API is MESSY.
        Eventually we'll transition to Nielsen data (for example).

    ----------------------------------------------------------------------------

    The sentence method
    -------------------
    > Using the sentence method to break down the problem!

    1. Write out your program in plain English with a single sentence.
    2. Any clauses (commas, and, then) should be split into it's own sentence.
    3. Repeat the process until you have a list of single sentences.
    4. Convert these into HTDP style headers (wishlist); watch out for state!
        - Which functions have ZERO state? Which have some state?

    |   Our video van man can create a new film by entering it's details in a
    |   form. He can also enter a `List Review`s for any film. Each film can be
    |   edited, and each film's review list can be edited. These films can be
    |   pulled/pushed to the server.

    The customer journey
    --------------------
    > Simple to understand, simple to action.
    > Can we simplify this customer journey?**

    1. Start with zero films (an empty van)
    2. Each film must have (some) film data
    3. Each film must have (at least) one review
        - This would be a non-empty list
        - Alternatively you could allow `null`
    4. A film can be saved to the server without a review
        - We check all errors on SAVE (and not every keystroke)
    5. A review can be pulled in from a different API
    6. The video man can select one of these reviews to add to the film
        - Could one of the review fields be optional?
    7. The video man can delete one, or all, of the reviews
        - Deleting all of the reviews will invalidate the film
    8. The video man can delete one, or all, of the films
    9. The video man can reorder a film's reviews
        - But reordering the films is not possible**

    |--------------------------------------------------------------|
    | ** Use the Tesla method to simplify the scope and processes. |
    |                                                              |
    | Is it more likely the video man will reorder the reviews? or |
    | the videos? Think carefully about the user story.            |
    |--------------------------------------------------------------|
      make the scope less dumb. Reduce the data to the minimum.


    Simplifying the problem
    -----------------------
    > How is your app going to be used? This dictates your architecture.

    1. Start with the simplest thing that could possibly work.
    2. What don't we need? How much can be cut? How do other APIs do it?
    3. Which processes are overly complicated?

    The model:

    - We'll use a flat model with no nested records. We'll narrow the types,
      however, and use extensible record type signatures.

    The server:

    - If the goal is speed, we should likely ping the server as little as possible.
    - Wherever possible, our data packets should be small!

    Reviews:

    > We won't need a compose/uncompose function as we're using plain `List`.
    > This makes life a bit easier, and we have access to `Maybe` functions.

    - Our reviews don't really need an ID, but they could be timestamped.
    - Instead of a custom type like `Album Song (List Song)` (essentially a
      non-empty list), we'll use a simpler `Maybe (List Review)`.
    - A `Film` can have zero reviews, so allow `null` values in `json`.

    View:

    > How is state handled and the user journey? Simplify!

    - For a proper server, we'd need to consider carefully APP ARCHITECTURE.
    - How would our routes look? Are they public or private?
    - For now we'll assume that it's similar to OpenLibrary API in structure.
    - Let's keep things simple and give every input field it's own message.
    - We'll create a `viewInput` function to reduce code duplication.

    RRR state:

    > ⚠️ Stupid (data) decisions upfront have HORRID artifacts ...
    > If there's LOTS OF STATE potential — FUCKING CHANGE IT!!!

        The "2:00" problem
        @ https://tinyurl.com/songs-v1-possible-states (commit c25d389)

    For one thing, we can be strict with our `Int` types. Let's only allow `1—5`
    stars, for example. How narrow can we make our types?

    ----------------------------------------------------------------------------

    Previous attempts at custom types
    ---------------------------------
    > Here's some learning experiences.
    > These versions store computed user input: don't do that!

    1. Songs first version:
        - @ https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/Songs.elm
    2. Songs (alternative) with `UserInput` type:
        - @ https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/SongsAlt.elm
    ~~3. Songs (editable) — failed experiment~~
        - @ https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/SongsEditable.elm

    ----------------------------------------------------------------------------

    Wishlist:
    ---------
    1. Sort a film's reviews be star, asc, decs.
    2. You'll need two forms: `Film`, and `Review`.
        - You'll also need a `NewFilm` and `NewReview` form.
        - At least one of these forms will be `XEditable` state.
    3. Use `andMap` instead of `mapX` for our result?
        - Perhaps use @rtfeldman's method for reviewData, but `andMap` for
          our filmData?
    4. Make sure our review is added to the BACK of the list (not the front)
    5. Consider using `Array` or use `List.take`, `List.indexedMap` ...

    Wishlist (YAGNI)
    ----------------
    1. Should a review have a timestamp? The film? (Add later)
    2. Add a total % of reviews (like rotten tomatoes)

    Questions
    ---------
    1. Do we need a separate form for the film and the review?
        - It probably doesn't make sense to save a Film's data along with the
          review data, as if we want to add a review, we're sending ALL of the
          film's data to the `Msg` again (but not making any changes)
    2. Is displaying ALL errors possible? Desirable? (if branch returns only the
       current error)
    3. Is `Result` a poor choice for a form with lots of fields?

-}


-- Model -----------------------------------------------------------------------
-- Our man in a van holds a list of films, we want to simplify data where we can.
-- On building our `Film`, we need to convert our `String` inputs to a proper
-- data type.

type alias Model =
    { van : List Film
    -- The `Film` form
    -- (ID would ideally be handled by the server)
    , id : Int -- convert to a `FilmId` on `Film` build.
    , title : String
    , trailer : String -- convert to `URL`
    , summary : String
    , tags : Maybe (List String)
    -- The `Review` form
    , rating : Int
    , reviewer : String -- Short text
    , description : String -- Long text
    -- Errors
    , error : List String -- #! We have TWO forms that need errors
    -- State
    , serverState : ServerState -- Loading, Success, Error
    , formState : FormState -- NoForm, EditForm
    }

-- Server ----------------------------------------------------------------------

type Server
    = Loading
    | Success
    | Error String -- Error message

-- Form ------------------------------------------------------------------------

type Form
    = NewFilm
    | EditFilm FilmId -- reviews do NOT have an ID


-- Film ------------------------------------------------------------------------
-- (1) Alternatively this could be a flat record, not a custom type!
-- (2) @ https://ckoster22.medium.com/advanced-types-in-elm-extensible-records-67e9d804030d

type alias Film
    = Film FilmID Internals (Maybe (List Review)) -- #! (1)

type alias FilmID
    = FilmID Int

type alias Internals =
    { title : String
    , trailer : Url
    , summary : String
    , tags : Maybe (List String)
    }

type alias Film a -- (2)
    = { a
        | title : String
        , trailer : Url
        , summary : String
        , tags : Maybe (List String)
      }


-- Review ----------------------------------------------------------------------
-- (1) Records are useful for different fields with the same type, or lots of
--     values to be stored/accessed publically. Otherwise, consider using a
--     custom type. A custom type also allows you to AVOID nested records.

type Review
    = Review Name Stars String -- #! (1)

type Name
    = Name String -- This could be more complex

type Stars
    = Stars Int
