module CustomTypes.Films exposing (..)

{-| ----------------------------------------------------------------------------
    A Film (similar but different to `Songs.elm`)
    ============================================================================
    > Aim to keep your wishlist and architecture simple.
    > Have it written down somewhere, where it's easy to glance at.

    Can you write your spec in a single sentence? A page? How much detail do
    you need to know before you start coding? Can you encapsulate everything we
    need to know about the program in 1-2 Markdown pages?

        -Make the spec less dumb!-
        Remember that comments can become outdated if code changes:
        @ [Previous spec](https://tinyurl.com/elm-playground-less-dumb-spec)

    You find out A LOT along the way, once you start designing and building. For
    example, see "The `TimeStamp` problem" below!


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

    Wishlist
    --------
    > 1. Do we have minimal state and minimal data? (Reduce!)
    > 2. Our `json` endpoint could start with `[]` zero objects ... but we
    >    can't save to the server without any objects!

    1. The only endpoint is `/films`. We're not worried about `:id` endpoints.
        - A `Review` is implicitly tied to a `Film`.
        - Errors are displayed on SAVE (not automatically)
        - Errors use @rtfeldman's `List Validated` type
    2. `Film` has no `Preview` state (like Elm Spa)
        - All `Film` data is loaded if it exists on the server.
        - You can limit what is shown in the `List Film` view.
    3. All image URLs must be `jpeg` format and small (for fast loading)
        - Add `loading="lazy"` to the `img` tag for the view
        - @ https://web.dev/explore/fast (🚀 TIPS ON LOADING QUICKLY)
    4. A `Review` must have an existing `Film` to attach itself to.[^1]
        - Multiple reviews can be added to a film (the user is an admin)
        - Errors are simple (`isEmpty`). Everything is required.
        - We can implement `Result.andMap` to check for `null` values.
    5. We can ping a `/reviews` API (from `data-playground` repo) to:
        - Search a review by `:id` (a bit like an ISBN number)
        - Copy the review to the `Review` form
    6. The end-user must have `Cred` (an existing logged-in account)
        - Only then can they perform any actions (add, edit, delete, save)
        - Ideally this type is read-only (opaque type; it's setup by Auth0)
    7. Consider using `Array` or `List.take` or `List.indexedMap`
        - The latter allows us to generate an index for each list item.

    [^1]: Does `Review` really need to be a custom type? In Dwayne's Elm Spa,
          he primarily uses records. Either way stringly typed is risky:

          - @ https://tinyurl.com/dwayne-elm-spa-article-record
          - @ https://dev.to/dwayne/yet-another-tour-of-an-open-source-elm-spa-1672#:~:text=The%20Page.*%20modules

    ----------------------------------------------------------------------------

    The customer journey
    --------------------
    > ⚠️ Where do you start? Sketch out the user story.
    > 🔍 What app architecture decisions did other apps choose? (Rotten Tomatoes)

    Start with the end-user's experience in mind. Is it performing as they
    would expect? Do they _really_ need this feature?

    1. Are our endpoints public, private or non-existant? (e.g: reviews have no public url)
    2. Is there one obvious way to do it? User intent == obvious UI/UX?
    3. Does a user need to be logged in to perform an action? (Yes!)
    4. What are we allowing the user to do? (add, edit, order, delete)
    5. Do they have the correct permissions do do this? (only their films)
    6. Are there restrictions in place (e.g: only ONE review per user)? (No)
    7. Are we displaying errors right away, or on SAVE?

        🤔 Example: Our "Add Review" from an API state
        ----------------------------------------------
        > What's the expected behaviour? What's easier for the user?

        Right now we're directly saving the `Review` to the review form.
        This makes things quicker, but not necessarily easier ...

        "What if the user already has some data in the review form?"
        "What if they want to add a review to a film that doesn't exist?"
        "What if the film isn't what they wanted. How do they rectify that?"


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

import Browser
import Html exposing (Html, button, div, h1, input, main_, text, ul, li)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Iso8601
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Process
import Random
import Task
import Time
import Url as U exposing (Url)
import Url.Builder as UB exposing (absolute, crossOrigin)

import Debug
import CustomTypes.Songs exposing (Input(..))
import Html exposing (a)


-- Model -----------------------------------------------------------------------
-- Our man in a van holds a list of films, we want to simplify data where we can.
-- On building our `Film`, we need to convert our `String` inputs to a proper
-- data type.
--
-- (1) The van will probably start with an `[]` empty state
--     - A new van man's server will have no films (very likely)
--     - #! Is this the best way to represent the server? Could you have the
--       whole model within the `Server a` type?
-- (2) The `timestamp` should NOT be entered by the user, only set by Elm.
--     For this reason, it's a hidden field (not visible in the view). It's only
--     used if we ping the `/reviews` API to get a review.
-- (3) ⏰ Is your 4g connection slow? Notify users with `LoadingSlowly` state.
--     - @ https://tinyurl.com/elm-spa-loading-slowly
--     - His version is much more granular (`model.comments = LoadingSlowly` etc)
--
-- Moving from a flat model to nested forms
-- ---------------------------------------
-- > I'm not sure if this was the right decision but ...
--
-- Within the `Success (Maybe List Film)` branch we have to access some type of
-- edit/review form because we're trying to EDIT "IN-PLACE" within the `viewFilms`
-- function. If our model is flat, we have to pass in THE WHOLE MODEL (or maybe
-- use extensible records), which doesn't feel quite right if we're trying to
-- narrow the types of our functions.
--
--     @ https://discourse.elm-lang.org/t/domain-driven-type-narrowing/7753
--
-- See the "Form" section for more information.

type alias Model =
    { van : Server (Maybe (List Film)) -- #! (1)
    -- The `Film` form


    --
    , new: FilmForm
    , update: UpdateFilm
    , title : String
    , trailer : String -- convert to `URL`
    , image : String -- #! An image uploader could be used (later)
    , summary : String
    , tags : String
    -- The `Review` form
    , timestamp: String -- #! (2)
    , name : String
    , review : String
    , rating : Int
    -- Errors
    -- #! Currently this is VERY flexible and we're using it for the
    -- `Server` state errors also. That might be a bad idea!
    , errors : List String
    -- State
    , formState : Form
    , formReview : Bool
    }

init : () -> (Model, Cmd Msg)
init _ =
    ({ van = Loading
      -- The `Film` form
      , title = ""
      , trailer = ""
      , image = ""
      , summary = ""
      , tags = ""
      -- The `Review` form
      , timestamp = Time.millisToPosix 0 -- Initial timestamp
      , name = ""
      , review = ""
      , rating = 0
      -- Errors
      , errors = []
      -- State
      , formState = NewFilm
      , formReview = False
      }
    -- 🔄 Initial command to load films
    , Cmd.batch
        [ getFilms
        -- ⏰ @rtfeldman's trick for slow loading data. This is in a `Loading`
        -- package and comes with an error message and a spinner icon ...
        -- @ https://github.com/rtfeldman/elm-spa-example/blob/master/src/Loading.elm
        , Task.perform (\_ -> PassedSlowLoadingThreshold) Process.sleep 500
    ]
    )


-- Server ----------------------------------------------------------------------

type Server a
    = Loading
    | LoadingSlowly
    | Success a
    | Error String -- Error message

-- Form ------------------------------------------------------------------------
-- > We have three form types: new, update, review.
-- > It's important to consider your UI and UX routes while planning.
--
-- You also need to consider where in the UI these forms are going to show. Are
-- they ...
--
-- (a) All ABOVE `viewFilms`,
-- (b) Launching a MODEL WINDOW for all the forms,
-- (c) EDITING IN-PLACE _within_ the `viewFilms` function?
--
-- If we decide our new film form is above `viewFilms`, but our edit/review
-- forms are editing in-place then we have at least three available options:[^1]
--
-- 1. A flat `Model` with every single form field (originally).
--    - We aren't able to narrow our types here, the full `model` is needed in
--      our view functions.
-- 2. A single `Form` type (with all possible forms), or split them up into
--    a `NewForm` (above `viewFilms`) and `UpdateForm` (edit/review) which would
--    be visible on button click within `viewFilms` function.
--
-- Anywhere we have a custom type, we need to `case` on ALL branches. If we had
-- a single `Form` type (with all possible forms) we'd end up with two empty
-- `text ""` branches above the `viewFilms` function.
--
-- [^1]: There is one other route, which is to change the `Film` type to hold it's
--       own form data as well, such as `Film Internals (Maybe (List Review)) Form`
--       but there's a couple of problems with this:
--
--       1. Elm Spa example `/Page/Article/Editor.elm` is where I got this idea
--          from, similar to it's `Status` type (which holds all the state).
--          That view is a lot more simple than ours however. It's just a form.
--          The form has different states (new, edit, so on). The `Status` type
--          looks like `Editing Slug _ Form`. The `Article` is not in the view.
--       2. The Elm Spa example also has it's own route (which is something like)
--          `/article/new` or `/article/slug` and is therefore only interested in
--          updating ONE single article.
--       3. This package has a `List Form`, so we're updating MULTIPLE films on
--          the same page — a VERY DIFFERENT UI DECISION to Elm Spa — and we've
--          also decided two things:
--          - We're keeping server updates to a minimum, editing locally, then
--            hitting a "save to the server" button (this might not be great UX).
--          - We're keeping the `List Form` in the view at all times. This means
--            our program design decisions are different to the Elm Spa example.

{-| We let our `json-server` handle the ID field

> Remember it's better to not store computed data: just use `String`s!
-}
type alias FilmForm =
    { title : String
    , trailer : String -- convert to `URL`
    , image : String -- #! An image uploader could be used (later)
    , summary : String
    , tags : String
    }

{-| #! This could be simplified into it's own type `NewFilm _ _ _`

And then checked for errors within the `Msg` update -}
type alias ReviewForm =
    { timestamp : String
    , name : String
    , review : String
    , rating : String
    }

type EditInPlace
    = NoForm
    | UpdateFilm FilmID Film
    | AddReview


-- Film ------------------------------------------------------------------------
-- Consider whether you're pulling from `/films` or `/films/:id`. The Elm Spa by
-- @rtfeldman pulls in the articles feed on the `Home.elm` page (I'm not 100%
-- sure how but uses `Article.previewDecoder`) with a `List (Article Preview)`.
-- The individual `Article.elm` outputs an `Article Full` type.
--
-- Both `Article`s have an `Internals` record (`Article.internalsDecoder`). It
-- contains a `Slug` type which is generated from the `/articles` server endpoint,
-- or from the `/articles/slug` url with `Url.Parser.custom` (from `Json.Decode.Pipeline`).
-- The `Slug` is likely the SQL string ID within the database.
--
--    @ https://web.archive.org/web/20190714180457/https://elm-spa-example.netlify.com/
--    @ https://realworld-docs.netlify.app/specifications/frontend/routing/
--
-- (1) Alternatively this could be a flat record, not a custom type! Technically
--     we don't really need this data structure. I'm accessing the `Internals`
--     directly (with the ability to edit it).
--     - ⚠️ Within the Elm Spa example, `Internals` is read-only and the `Article`
--       type is only ever created from the server (and decoded into this type).
--         - @ https://tinyurl.com/elm-spa-article-internals
-- (2) A film can have zero reviews (`null` value in the json)
-- (3) How can we narrow the types with extensible records? Which ones are useful,
--     and which superfluous?
--     - @ https://ckoster22.medium.com/advanced-types-in-elm-extensible-records-67e9d804030d

type Film
    = Film Internals (Maybe (List Review)) -- #! (1) (2)

type FilmID
    = FilmID String -- #! `json-server` unfortunately stores IDs as `String`

type alias ImageID
    = String

type alias Internals =
    { id : FilmID
    , title : String
    , trailer : Maybe Url
    , summary : String
    , image : ImageID -- #! One size, eventually `-S`, `-M`, `-L`
    , tags : Maybe (List String) -- Optional (`null` allowed)
    }

type alias FilmForm a -- #! (3) Is this really required?
    = { a
        | id : String
        , title : String
        , trailer : String
        , summary : String
        , image : String
        , tags : String -- Optional
      }

filmData : Film -> Internals
filmData (Film internals _) =
    internals

decodeFilm : Decoder Film
decodeFilm =
    D.map2 Film
        decodeFilmMeta
        (D.nullable (D.list decodeReview))

decodeFilmMeta : Decoder Internals
decodeFilmMeta =
    D.map6 Internals
        (D.field "id" (D.map FilmID D.string))
        (D.field "title" D.string)
        (D.field "trailer" (D.map U.fromString D.string)) -- #! Forces a `Maybe`
        (D.field "summary" D.string)
        (D.field "image" D.string)
        (D.field "tags" (D.nullable (D.list D.string)))


-- Review ----------------------------------------------------------------------
-- Do not allow any `null` values for a review! Add it or don't.
--
-- Review custom type (changed to a record)
-- ----------------------------------------
-- > TL;DR: Both methods are possible, but using a record type is simpler.
-- > If I'm regularly accessing every field, is a custom type the best choice?
--
-- We started with a `Review` custom type, which is very handy if you're wanting
-- to put boundaries on how your type is created and consumed (for example, only
-- allow it to be generated from a server call). However. It turns out we need to
-- decode into a `Review` in a couple of places:
--
--    - When we get a review from the `/reviews/:id` API endpoint
--    - When we decode from a `List Film` and want to access the reviews
--
-- The first one demands one of two routes:
--
--    - Our previous custom type requires all fields to be unpacked within the
--      `Msg` (we're not saving to the model): e.g: `(Review timestamp _ _)`
--    - Or, we use a record type, which is quicker and easier to access. Our
--      "getter" functions are ready-made for us: `review.timestamp`.
--
-- What are records useful for?
--
--    Records are useful for different fields with the same type, or lots of
--    values to be stored/accessed publically. Otherwise, consider using a
--    custom type. A custom type also allows you to AVOID nested records.
--
-- The `Article` example from Elm Spa
-- ----------------------------------
-- In this package we're accessing our review fields in two places, and storing
-- them in one place (each `Film.reviews` record) in our update function. It's
-- important to be aware of the guarantees you're looking to create with a
-- custom type, and not just set "getters" (and especially not "setters") for
-- every single field.
--
-- The `src/Article.elm` example below is only created from a server call, and
-- (I think) the `src/Page/Article/Editor.elm` only displays the form data (in
-- new or edit mode) and we don't create an `Article a` directly. Ever. @rtfeldman
-- has this to say about "getters" and "setters":
--
--    - @ ⚠️ [Beware of "getters"](https://github.com/rtfeldman/elm-spa-example/blob/cb32acd73c3d346d0064e7923049867d8ce67193/src/Article.elm#L66)
--
-- Notes
-- -----
-- (1) We'll utilize `rtfeldman/elm-iso8601-date-strings` to convert times
--     - @ https://timestampgenerator.com/
-- (2) Stars can only ever be a number between 1-5. See "Cardinality":
--     - @ https://guide.elm-lang.org/appendix/types_as_sets#cardinality
--     - We don't allow `.5` decimal points, and round up if a review has them.

type alias Review =
    { timestamp : TimeStamp -- (1)
    , name : Name
    , review : String
    , rating : Stars -- (2)
    }

type alias ReviewForm a
    = { a
        | timestamp : String
        , name : String
        , review : String
        , rating : String
      }

type alias TimeStamp
    = Time.Posix -- (1)

type Name
    = Name String -- This could be more complex

nameToString : Name -> String
nameToString (Name name) =
    name

type Stars
    = One
    | Two
    | Three
    | Four
    | Five

starsToNumber : Stars -> Int
starsToNumber star =
    case star of
        One   -> 1
        Two   -> 2
        Three -> 3
        Four  -> 4
        Five  -> 5

decodeReview : Decoder Review
decodeReview =
    D.map4 Review
        (D.field "timestamp" Iso8601.decoder) -- Handled by Elm
        (D.field "name" (D.map Name D.string)) -- Short text
        (D.field "review" D.string) -- Long text
        (D.field "stars" decodeStars)

decodeStars : Decoder Stars
decodeStars =
    let
        decodeNumber number =
            case number of
                1 -> D.succeed One
                2 -> D.succeed Two
                3 -> D.succeed Three
                4 -> D.succeed Four
                5 -> D.succeed Five
                _ -> D.fail "This is not the number you're looking for!"
    in
    D.int |> D.andThen decodeNumber


-- Http ------------------------------------------------------------------------
-- See the `data-playground/mocking/films` repo.

url : String
url = "http://localhost:3000"

getFilms : Cmd Msg
getFilms =
    Http.get
        { url = url ++ "/films"
        , expect = Http.expectJson GotFilms (D.list decodeFilm)
        }

getReview : Int -> Cmd Msg
getReview reviewID =
    Http.get
        { url = url ++ "/reviews" ++ "/" ++ String.fromInt reviewID
        , expect = Http.expectJson GotReview decodeReview
        }


-- Randomiser ------------------------------------------------------------------
-- This saves us having to manually add a review ID when using `getReview`

randomNumber : Cmd Msg
randomNumber =
    let
        oneToTen : Random.Generator Int
        oneToTen =
            Random.int 1 10
    in
    Random.generate GotNumber oneToTen


-- View ------------------------------------------------------------------------
-- Also consider `Html.Lazy` to lazy load the films.
--
-- (1) It may actually be a better idea to have a `model.form` nested record and
--     then we could narrow the types and pass into the `viewFilms model.form films`
--     function. For now forms are housed OUTSIDE the `viewFilms` function.
--     - @ https://github.com/rtfeldman/elm-spa-example/blob/cb32acd73c3d346d0064e7923049867d8ce67193/src/Page/Login.elm#L120
-- (2) There's two ways to display our `Review` from the API call.
--     - Directly add it to the review form if successfully loaded
--     - Display the review with an "Add Review" button (bipass the form)
-- (3) #! We should try to NARROW THE TYPES as much as possible. Within the branches
--     such as `Success films` ideally we'd only be working with the `List Film`,
--     and not other parts of the `Model`.

view : Model -> Html Msg
view model =
    case model.van of
        Loading ->
            text "Loading films..."

        LoadingSlowly ->
            text "Loading films slowly..."

        Success films ->
            main_ [] [
                h1 [] [ text "Films" ]
                , viewFilmForm model -- ^ What about UpdateForm?
                , viewReviewForm model -- ^ What about Film ID?
                , viewFilms films -- (1)
            ]

        Error errorMsg ->
            text ("Error loading films: " ++ errorMsg)

viewInput : String -> (String -> msg) -> String -> String -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

viewFilmForm : Model -> Html Msg
viewFilmForm model =
    div []
        [ viewInput "text" InputTitle "Title" model.title
        , viewInput "text" InputTrailer "Trailer URL" model.trailer
        , viewInput "text" InputImage "Image URL" model.image
        , viewInput "text" InputSummary "Summary" model.summary
        , viewInput "text" InputTags "Tags (comma separated)" model.tags
        , button [ onClick ClickedAddFilm ] [ text "Add Review" ]
        ]

{- (1) #! (3) -}
viewFilms : Maybe (List Film) -> Html Msg
viewFilms maybeFilms =
    case maybeFilms of
        Just films ->
            ul []
                (List.map viewFilm films)


        Nothing ->
            text "No films yet!"

viewFilm : Film -> Html Msg
viewFilm f =
    let
        film = filmData f
    in
    li []
        [ text ("Film: " ++ film.title)
        , text ("Trailer: " ++ Debug.toString film.trailer)
        , text ("Image: " ++ film.image)
        , text ("Summary: " ++ film.summary)
        , text ("Tags: " ++ Debug.toString film.tags)
        , button [ onClick (ClickedAddReview film.id) ] [ text "Add a review for this film" ]
        ]

{- (2) -}
viewReviewForm : FilmID -> ReviewForm a -> Html Msg
viewReviewForm filmID model =
    div []
        [ viewInput "text" InputName "Name" model.name
        , viewInput "text" InputReview "Review" model.review
        , viewInput "text" InputRating "Rating" model.rating
        , input
            [ type_ "hidden"
            , placeholder "TimeStamp"
            , value model.timestamp
            , onInput InputTimeStamp
            ] []
        ]


-- Messages --------------------------------------------------------------------

type Msg
    = ClickedAddFilm
    | ClickedRandom
    | ClickedAddReview FilmID
    | GotFilms (Result Http.Error (List Film))
    | GotNumber Int
    | GotReview (Result Http.Error Review)
    | PassedSlowLoadingThreshold
    -- Film form
    | InputTitle String
    | InputTrailer String
    | InputImage String
    | InputSummary String
    | InputTags String
    -- Review form
    | InputTimeStamp String -- Hidden (only used for reviews API)
    | InputName String
    | InputReview String
    | InputRating String


-- Update functions ------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedRandom ->
            ( model, randomNumber )

        ClickedAddFilm ->
            Debug.todo "Make the film form work"

        ClickedAddReview ->
            Debug.todo "Make the review form work"

        GotFilms (Ok []) ->
            -- If our van is empty (from the server) we notify:
            ( { model
                | van = Success Nothing
              }
            , Cmd.none
            )

        GotFilms (Ok films) ->
            -- Otherwise update the model with current list of films
            ( { model
                | van = Success (Just films)
                , formReview = True -- #! Only display if there's films!
              }
            , Cmd.none
            )

        GotFilms (Err error) ->
            -- Handle the error (e.g: display an error message)
            -- #! Remember that Ai (copilot) hallucinates. There is no
            -- `Http.errorToString` function in Elm (but `Json.Decode` does!)
            ( { model
                | van = Error ("Failed to load films"  ++ Debug.toString error)
              }
            , Cmd.none )

        GotNumber number ->
            -- Use the random number to get a review
            ( model, getReview number )

        GotReview (Ok review) ->
            ( addTemporaryReview review model
            , Cmd.none
            )

        PassedSlowLoadingThreshold ->
            -- In Elm Spa it doesn't directly change to `LoadingSlowly`, but
            -- checks the state first. If `Loaded` then it does nothing.
            case model.van of
                Loading ->
                    -- If we're still loading, we can switch to LoadingSlowly
                    ( { model | van = LoadingSlowly }
                    , Cmd.none )

                _ ->
                    -- Otherwise, ignore the message: do nothing.
                    ( model, Cmd.none )

        -- Film form

        InputTitle str ->
            ( { model | title = str }
            , Cmd.none
            )

        InputTrailer str ->
            ( { model | trailer = str }
            , Cmd.none
            )

        InputImage str ->
            ( { model | image = str }
            , Cmd.none
            )

        InputSummary str ->
            ( { model | summary = str }
            , Cmd.none
            )

        InputTags str ->
            ( { model | tags = str }
            , Cmd.none
            )

        -- Review form

        InputName str ->
            ( { model | name = str }
            , Cmd.none
            )

        InputReview str ->
            ( { model | review = str }
            , Cmd.none
            )

        InputRating str ->
            ( { model | rating = str }
            , Cmd.none
            )

        -- #! Only used if pulling from the `reviews/:id` API
        InputTimeStamp str ->
            ( { model | review = str }
            , Cmd.none
            )


{-| Adding our review API result to the review form

> ⚠️ Our review form expects strings!
> ⚠️ We could've simply had an "Add Review" button (and not used the form)
> ⚠️ Or used a `Status a` type and saved to the model `Loaded Review`

I decided not to bother saving to the model and storing it temporarily. We'll
just use the values as strings (like our form). Our decoded `Review` has a
`timestamp` and `name` as custom types. This function helps us re-use our review
form when we've pinged the review API!

## The `TimeStamp` problem

> ⚠️ Our `TimeStamp` is a bit tricksy.

The end-user never need know there's a timestamp there. Elm handles that. However,
our `/reviews/:id` API already has timestamps in ISO 8601 format, so we decode
that and use it in a hidden `viewInput "text" _ "Timestamp"` field.

The problem lies in if the user manually edits the review before saving, as now
we have a ROGUE TIMESTAMP! We can either:

(a) Bipass the form completely and have a "SAVE Review" button (from API)
(b) Use `readonly` in our `viewInput` value, with a "CLEAR Form" button. That way
    there's no way for the user to edit the API review, they'll have to clear the
    form and start again.

    - @ https://www.w3schools.com/tags/att_input_readonly.asp

Alternatively, you can make sure that EVERY SINGLE FIELD is made to be user-editable
and you'll never have any clashes.
-}
addTemporaryReview : Review -> Model -> Model
addTemporaryReview review model =
    { model
      | timestamp = Iso8601.fromTime review.timestamp
      , name = nameToString review.name
      , review = review.review
      , rating = String.fromInt (starsToNumber review.rating)
    }


-- Film functions --------------------------------------------------------------
-- Add, edit, delete, save, orderBy stars total (update server right away)


-- Review functions ------------------------------------------------------------
-- Add, delete, orderBy stars (update film once you're done)
--
-- #! If `"timestamp"` field is empty, generate a timestamp
-- #! If `"timestamp"` field contains a `Review.timestamp`, use that one.
--
-- The ideal situation would be to have ZERO hidden form fields, and just generate
-- it when creating a `Film.review`.





-- View forms ------------------------------------------------------------------
-- Images: lazy load the images with `loading="lazy"`
--         How does `Html.Lazy` work? Any benefits?


-- Main ------------------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
