module CustomTypes.Films exposing (..)

{-| ----------------------------------------------------------------------------
    A Film (similar but different to `Songs.elm`)
    ============================================================================
    > Aim to keep your wishlist and architecture simple.
    > Have it written down somewhere, where it's easy to glance at.

    Can you write your spec in a single sentence? A page? How much detail do
    you need to know before you start coding? Can you encapsulate everything we
    need to know about the program in 1-2 Markdown pages?

        Make the spec less dumb!
        Remember that comments can become outdated if code changes:
        @ [Previous spec]

    The sentence method
    -------------------
    > Using the sentence method to break down the problem!
    > We've mocked up a films API for this program in the `data-playground` repo!

    "You're a video man with a van full of films."
        "You need to log each film and send it to the server."
    "Each film can (optionally) hold some reviews."
        "A review can only be created if the film already exists."
    "The film can be updated but the reviews can only be deleted."
        "A film should be updated immediately, whereas reviews can be added and deleted,
    then saved to the server."
        "The video man can "lookup" reviews from a different API and copy them
        to the review form (what's the best UI for this?)."
    "Finally, expect a slow 4G connection (how do I load this quickly?)"

    The customer journey
    --------------------
    > Where do you start? Sketch out the user story.
    > What app architecture decisions did other apps choose? (Rotten Tomatoes)

    Start with the end-user's experience in mind. Is it performing as they
    would expect? Do they _really_ need this feature?

    1. Are our endpoints public, private or non-existant? (e.g: reviews have no public url)
    2. Is there one obvious way to do it? User intent == obvious UI/UX?
    3. Does a user need to be logged in to perform an action? (Yes!)
    4. What are we allowing the user to do? (add, edit, order, delete)
    5. Do they have the correct permissions do do this? (only their films)
    6. Are there restrictions in place (e.g: only ONE review per user)? (No)
    7. Are we displaying errors right away, or on SAVE?


    Handling state
    --------------
    > Prefer minimal state wherever you see it.

    - What are all the possible states and how do we represent them?
    - Can we create some guarantees to make impossible states impossible?
    - Can any of these states be simplified or removed?
    - Is the complexity really needed? (two endpoints -vs- one)

        @ https://www.youtube.com/watch?v=x1FU3e0sT1I (make data structures)
        @ https://sporto.github.io/elm-patterns/basic/impossible-states.html
        @ https://elm-radio.com/episode/life-of-a-file/ (which data struture?)

    -Film state:-
    Would we have a short description for `List Film` and then full details for
    `Film`? Or would we just have a single `Film` type with all the details?
    Are we deleting our `Film`s one-by-one or all at once?

    -Review state:-
    In @rtfeldman's Elm Spa a comment can be `Editing ""` (empty), `Editing str`,
    or `Sending str`. The server must respond with an `Ok` (or `Err`) before
    another comment is allowed. In our version, we're saving a `Review` locally
    first, then `updateFilm` to send to server. We also need to make sure a `Film`
    already exists to create a review.

    -Loading state:-
    > A single `Status` for our `List Film` is enough.
    Elm Spa also has a `Status` type with `Loaded a` states for both comments and
    articles. This is overkill for our purposes (we don't ping the server right
    away for comments).

        @ https://realworld-docs.netlify.app/
        @ https://tinyurl.com/elm-spa-article-status-type


    The data
    --------
    > The life of a file (decisions and tradeoffs)
    > Prefer minimal data wherever possible

    1. Imagine that we've already created our http server!
    2. What's the minimal amount of data do we need to store? (e.g: film, reviews)
    3. Are we pulling from a single endpoint, or multiple? (e.g: get all reviews)
    4. What does our SQL schema look like? (e.g: film, reviews by film ID)
    5. How do our endpoint functions work? (e.g: `film/:id` -> implicit `List Review` w/ full text)
    6. What is our resulting json structure? (e.g: film with full-text reviews)
    7. How can we make life easier? (same `.jpg` file format, `[ID]` -> `ID`)

    Film                        Review
    | ID | Title      | ... |   | Timestamp  | Film ID | Name | Stars | Review |
    |----|------------|-----|   |------------|---------|------|-------|--------|
    | 1  | The Matrix | ... |   | 2023-10-01 | 1       | ...  | 5     | ...    |

    I've simplified the `Review` type similar to how @rtfeldman deals with his
    `Comment` type in Elm Spa example, and I've removed the `ID` field (which might
    not be best practice for SQL):

        @ https://tinyurl.com/clickedPostComment-Article (line 404)
        @ https://tinyurl.com/spa-ArticleComment-post (`Http.send` is deprecated)

    Another thing to note is that some ORMs return `List (Film, Review)` tuples,
    so you can grab both film and review without having to make a second API call.

    Translating to Elm data structures
    ----------------------------------
    > How are we're going to translate this into Elm data structures?

    1. What's READ ONLY data? What do we expose fully with our Elm types? (e.g: IDs)
    2. Where are custom types useful? Where are they not giving any benefit?


    Error handling
    --------------
    > In this program, we're checking errors on SAVE event only.

    1. Is our error checking simple or complex? (e.g: only check for non-empty string)
    2. Which error handling method? (e.g: @rtfeldman's `List Validated` -vs- `Result.andMap`)
        - I'll use both methods to show what's possible!
    3. Be strict with your `Int` types for `Stars` ...
        - Avoid the `"2:00"` problem (too many potential states)


    Our server assumptions
    ----------------------
    1. We perform an SQL join to get individual `Film`s reviews.
    2. Our server endpoint `/films` returns the full film and all it's reviews
        - No need to ping a separate review API endpoint (or batch `Cmd`s)
        - No need for an `Article Preview`-style type.
    3. We use the `ID` of the `Film` (rather than Elm Spa's `article-slug`)
        - @ https://realworld-docs.netlify.app/specifications/backend/api-response-format/#single-article

-}

import Time
import Url as U exposing (fromString, toString, builder)
import Url.Builder as UB exposing (absolute, crossOrigin)


-- Model -----------------------------------------------------------------------
-- Our man in a van holds a list of films, we want to simplify data where we can.
-- On building our `Film`, we need to convert our `String` inputs to a proper
-- data type.

type alias Model =
    { van : List Film
    -- The `Film` form
    -- #! Let `json-server` handle the ID (as would a real server)
    , title : String
    , trailer : String -- convert to `URL`
    , image : String -- #! An image uploader could be used (later)
    , summary : String
    , tags : Maybe (List String)
    -- The `Review` form
    -- TimeStamp handled by Elm (not user input)
    , rating : Int
    , reviewer : String -- Short text
    , description : String -- Long text
    -- Errors
    , error : List String -- #! Only our `Film` form needs this
    -- State
    , serverState : ServerState -- Loading, LoadingSlowly, Success, Error
    , formState : FormState -- NoForm, EditForm
    }

-- Server ----------------------------------------------------------------------

type Server a
    = Loading
    | LoadingSlowly
    | Success a
    | Error String -- Error message

-- Form ------------------------------------------------------------------------
-- Here we'll need two forms, one for a `Film` and one for `Review`. Our `Film`
-- forms have two states: new and update.

type Form
    = NewFilm
    | EditFilm FilmId -- reviews do NOT have an ID


-- Film ------------------------------------------------------------------------
-- Consider whether you're pulling from `/films` or `/films/:id`. The Elm Spa by
-- @rtfeldman pulls in the articles feed on the `Home.elm` page (I'm not 100%
-- sure how but uses `Article.previewDecoder`) with a `List (Article Preview)`.
-- The individual `Article.elm` outputs an `Article Full` type.
--
-- Both `Article`s have an `Internals` record (`Article.internalsDecoder`), with
-- a `Slug` type (can be generated from `Url.Parser.custom`). So either grab the
-- slug from the URL, or the articles API endpoint.
--
--    @ https://web.archive.org/web/20190714180457/https://elm-spa-example.netlify.com/
--    @ https://realworld-docs.netlify.app/specifications/frontend/routing/
--
-- (1) Alternatively this could be a flat record, not a custom type!
-- (2) A film can have zero reviews (`null` value in the json)
-- (3) How can we narrow the types with extensible records?
--     - @ https://ckoster22.medium.com/advanced-types-in-elm-extensible-records-67e9d804030d

type alias Film
    = Film Internals (Maybe (List Review)) -- #! (1) (2)

type alias FilmID
    = FilmID Int -- Convert from `json-server` ID

type alias Internals =
    { id : FilmID
    , title : String
    , trailer : Url
    , summary : String
    , image : Url -- Eventually `-S`, `-M`, `-L`
    , tags : Maybe (List String) -- Optional
    }

type alias FilmRecord a -- #! (3) Is this really required?
    = { a
        | id : FilmID
        , title : String
        , trailer : Url
        , summary : String
        , tags : Maybe (List String) -- Optional
      }


-- Review ----------------------------------------------------------------------
-- (1) Records are useful for different fields with the same type, or lots of
--     values to be stored/accessed publically. Otherwise, consider using a
--     custom type. A custom type also allows you to AVOID nested records.

type Review
    = Review TimeStamp Name Stars String -- #! (1)

type alias TimeStamp
    = Time.Posix -- #! Change to ISO (rtfeldman)?

type Name
    = Name String -- This could be more complex

type Stars
    = Stars Int


-- Film functions --------------------------------------------------------------
-- Add, edit, delete, save, orderBy stars total (update server right away)


-- Review functions ------------------------------------------------------------
-- Add, delete, orderBy stars (update film once you're done)


-- View forms ------------------------------------------------------------------
-- Inputs: every input field has it's own message
--         consider using a `viewInput` function to reduce duplication.
-- Images: lazy load the images with `loading="lazy"`
--         How does `Html.Lazy` work? Any benefits?
