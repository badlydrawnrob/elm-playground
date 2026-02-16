module _BadExamples.CustomTypes.Films exposing (..)

{-| ----------------------------------------------------------------------------
    A Film (similar but different to `Songs.elm`)
    ============================================================================
    > ⚠️ Sharing form state between 3 different `Form` types is bad practice!
    > It's led to a quite hard-to-read and complected package. Simplify it!

    A flat model is fine for a single form, but multiple forms on a single page
    gets real hard to read ... simple is better:

    1. Use dedicated endpoints such as `/films/:id/new` and `/edit`
    2. Encapsulate forms better with `Film (List Problem) Form` type
    3. Never use complicated types when simple ones will do
    4. But ... it's event better to remove UI complexity ...
        - And use atomic routes for all your forms (one per form)


    Why?
    ----
    > Because too much (shared) state makes for a confusing codebase.

    It becomes harder to read and reason about! You also have to make sure that
    whenever a form is changed between `New | Edit | ...` the `Model.form` is
    reset to the correct values. Consider whether it's essential to have all that
    state on one UI page at all?

    - Does it benefit the user?
    - Does it lead to shitty, slow, artifacts?


    Tesla 5 steps
    -------------
    > @ https://www.jeffwinterinsights.com/insights/elon-musks-five-step-design-process

    Aim to have your architecture and wishlist simple.
    What are the most essential data and features? What's "extra"?
    Make the state as dumb as possible. Make UI easy to use.
    Use simple data structures. Remove as much data as possible.
    Try to keep program comments short and write articles.


    Helpful articles
    ----------------
    > See articles `/sentence-method` and `/paper-prototypes`

    [#! To be written]


    Other ways to improve
    ---------------------
    > You might want to split out types into modules

    1. Your spec is ALWAYS dumb for the first couple of drafts.
        - @ https://tinyurl.com/elm-playground-spec (original spec)
        - Sketch it out and find a way to make it less dumb. Iterate.
        - 🚀 Paper prototypes and Ai interfaces are cheap. Use them.
    2. Atomic endpoints are FAR, FAR, FAR easier than lots of page state.
        - `/films` to add a film, `/films/:id/edit` to edit a film
        - `/reviews` endpoint could be called with `FilmId`
    3. Use a `Status.map` function so you unwrap `Success` in ONE place.
        - Or, consider holding some state in `Model.lifted` to avoid unpacking.
    4. Never use complicated types where a simple one will do
        - `Success (Just a)` is a code smell. Use `Success []` instead
        - `Film` holding all it's state also makes the `view` case easier
        - You can start to narrow your types better this way too
    5. Convert `Film` to a Transparent Type (rather than Opaque Type)
        - Is a server endpoint the only way to generate a `Film`? (Elm Spa)
        - @ https://github.com/rtfeldman/elm-spa-example/blob/master/src/Article.elm
        - Or are we able to create it without the server? (unlike Elm Spa)
    6. Avoid impossible states like the plague! Add to `Review List` directly.
        - Remember the "Random `Review`" problem which creates a `TimeStamp`
        - `TimeStamp` is automatic (non-editable) but user can edit form
        - This allows a user to create a form state with wrong `TimeStamp`
        - Again making our form state more complicated than it needs to be!
    7. If you must use extensible records ...
        - Consider using only the type signatures (not the type alias)
    8. I think there's a simpler way to grab a filtered `Film`
        - Currently `List.head (filterFilmsByID filmID films)`
        - Creates a potentially unecessary `Maybe` response
        - Look at other structures: `Array`/`List.take`/`List.indexedMap`
        - If `List` is not empty this should never fail!
    9. An infinite loop is possible if the http server isn't running.
        - Does `Loading` have a timeout? It shouldn't run forever.


    Original server assumptions
    ---------------------------
    1. Our http server is already built with a single `/films` endpoint
    2. We output `json` with `List Film` (each film contains full reviews)
    3. Our SQL schema looks like this:

    Film                        Review
    | ID | Title      | ... |   | Timestamp  | Film ID | Name | Stars | Review |
    |----|------------|-----|   |------------|---------|------|-------|--------|
    | 1  | The Matrix | ... |   | 2023-10-01 | 1       | ...  | 5     | ...    |


    WISHLIST
    --------
    > This program is complected. Write simpler code and let it do the talking.

    1. `List Film` must have at least one `Film` to post to server
    2. `Film` must exist before a `Review` can be made
    3. `Film` has no preview state (like Elm Spa)
    4. 🚀 Images are a single file format and lazy loaded
        - @ https://web.dev/explore/fast
    5. `Review`s can be searched from the random review endpoint
        - Rather than a hardcoded number
    6. User must be logged in to perform an action
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Iso8601
import Json.Decode as D exposing (Decoder)
import Process
import Random
import Task
import Time
import Url as U exposing (Url)


-- Model -----------------------------------------------------------------------

{-| Using a flatter model

> ⚠️ Make concrete decisions about your model and program. You can always change
> things later, but being wishy-washy can add confusion.

1. Our `Model` assumes an empty van to start `[]`
2. We simplify and reduce the data wherever we can
3. Our form inputs are just `Strings` (converted to `Film` on save)
4. We'll also assume a slow 4g connection (`LoadingSlowly`)
     - @ https://tinyurl.com/elm-spa-loading-slowly (both comments and article)


## Why not custom types?

> #! There are at least two other routes we could've taken

We're sticking to a flat model for this program. There are cleverer ways to do it,
whereby a type holds ALL the state (including the form) and all possible states
are encapsulated in a single type (used in a nested `model.form`).

As our form and `model.state` aren't bound together, we need to take care our
model doesn't get into an impossible state. Only ONE form should be visible at
any one point in time. `Add/Edit` states will share the same form fields. This is
not the best way, but it's good to have an example where we haven't fully narrowed
the types and our guarantees aren't 100%.

-}
type alias Model =
    { van : Server (List Film) -- #! (1)
    -- The `Film` form
    -- #! Our `json-server` provides the `String` ID
    , title : String
    , trailer : String
    , poster : String
    , summary : String
    , tags : String
    -- The `Review` form
    -- #! Elm automatically generates a `TimeStamp` value.
    , name : String
    , review : String
    , rating : String
    -- The API review we grabbed
    , apiReview : Maybe Review
    -- The state of the form (only ONE visible at any time)
    , formState: Form
    -- Any form errors we need to display
    , errors : List String
    }

init : () -> (Model, Cmd Msg)
init _ =
    ({ van = Loading
       -- The `Film` form
       , title = ""
       , trailer = ""
       , poster = ""
       , summary = ""
       , tags = ""
       -- The `Review` form
       , name = ""
       , review = ""
       , rating = ""
       -- Have we grabbed a review from our API?
       , apiReview = Nothing
       -- The state of the form (only ONE visible at any time)
       , formState = NewFilm
       -- Any form errors we need to display
       , errors = []
    }
    -- 🔄 Initial command to load films
    , Cmd.batch
        [ getFilms
        -- (2) ⏰ @rtfeldman's trick for slow loading data. This is in a `Loading`
        -- package and comes with an error message and a spinner icon ...
        -- @ https://github.com/rtfeldman/elm-spa-example/blob/master/src/Loading.elm
        , Task.perform (\_ -> PassedSlowLoadingThreshold) (Process.sleep 500)
    ]
    )


-- Server ----------------------------------------------------------------------

type Server a
    = Loading
    | LoadingSlowly
    | Success a
    | Error String -- Error message

{-| Ai generated mapping function

> ⚠️ You can have a map function for brevity, or always use `case` in update

You should only be mapping on a `Success a` branch really. And even then
you might as well just `case` on that branch and `_` for the rest.
-}
serverMap : (a -> b) -> Server a -> Server b
serverMap mapFn server =
    case server of
        Loading ->
            Loading

        LoadingSlowly ->
            LoadingSlowly

        Success a ->
            Success (mapFn a)

        Error errorMsg ->
            Error errorMsg

-- Form ------------------------------------------------------------------------
-- Any time we've got a `Form` state we'll need to case on each branch, even if
-- we're not interested in that state in the `view` function. You can use empty
-- `text ""` values if needed.

type Form
    = NewFilm
    | EditFilm FilmID
    | AddReview FilmID

{-| Narrowing the types

> Helps to make our type signatures "feel" more narrow ...

Even if it's the whole `Model` we're passing into our functions. When are these
useful? When are they superfluous?

- @ https://ckoster22.medium.com/advanced-types-in-elm-extensible-records-67e9d804030d

## Notes

> We could've used better types here ...

If we were using custom types we could've done something like:

```elm
type FilmState
    = NewFilm (List Problem) Form
    | EditFilm FilmID (List Problem) Form
    | AddReview FilmID (List Problem) Form
```

Or gotten even _more_ specific and used our `Film _ _ _` types more scope, by
including the `Form` within those `Film` type branches. This allows us to be more
specific and have more guarantees about our code base.

-}
type alias FilmForm r =
    { r
        | title : String
        , trailer : String
        , poster : String
        , summary : String
        , tags : String
    }

{-| Narrowing the types

1. `TimeStamp` should NOT be entered by the user, only set by Elm.
    - We've avoided this problem by NOT adding `/reviews/:id` API calls to the
      form fields.
2. Don't display the form until we actually need it! (Use buttons)
3. Only ONE form should be available at any one time.

-}
type alias ReviewForm r =
    { r
        | name : String
        , review : String
        , rating : String
    }


-- Film ------------------------------------------------------------------------

{-| Our Film data structures

> We're using ONE endpoint only (`/films`) unlike Elm Spa example which uses
> two endpoints (`/films/:id` and `/films/:id/comments`). We also don't distinguish
> between displays: a `Film` is always a film (see `Article Preview` and
> `Article.previewDecoder` in Elm Spa)

As this is not an opaque type (we're updating it directly, it isn't read-only) we
technically don't need `Internals` type written like this, but we'll utilise it anyway.

We could've just used a flat `type alias Record` here.

## Notes

1. Our `Film` type needn't be a custom type really
    - It isn't read-only and we're updating it directly (not via server)
2. #! We're being a little inconsistant with accessor functions:
    - How often do we need to access particular values?
    - Should they be accessed `internals.directly` or `internals`?

-}
type Film
    = Film Internals (List Review) -- #! (1)

type FilmID
    = FilmID String -- #! `json-server` unfortunately stores IDs as `String`

type alias PosterID
    = String

type alias Internals =
    { id : FilmID
    , title : String
    , trailer : Maybe Url
    , summary : String
    , poster : PosterID -- #! One size, eventually `-S`, `-M`, `-L`
    , tags : List String -- #! Optional is not `null`, it's `[]` empty!!!
    }

posterUrl : String
posterUrl =
    "http://localhost:3000/poster/"

filmData : Film -> Internals
filmData (Film internals _) =
    internals -- #! (2)

getFilmID : Film -> FilmID
getFilmID (Film internals _) =
    internals.id -- #! (2)

filmReviews : Film -> List Review
filmReviews (Film _ reviews) =
    reviews

decodeFilm : Decoder Film
decodeFilm =
    D.map2 Film
        decodeFilmMeta
        (D.field "reviews" (D.list decodeReview)) -- #! Optional, but NOT `null` (use empty list)

decodeFilmMeta : Decoder Internals
decodeFilmMeta =
    D.map6 Internals
        (D.field "id" (D.map FilmID D.string))
        (D.field "title" D.string)
        (D.field "trailer" (D.map U.fromString D.string)) -- #! Forces a `Maybe`
        (D.field "summary" D.string)
        ((D.field "poster" (D.list D.string)
            |> D.andThen decodePoster))
        (D.field "tags" (D.list D.string))

{-| ⚠️ Change the poster value shape (a bit hacky) -}
decodePoster : List String -> Decoder PosterID
decodePoster posterList =
    if List.length posterList == 1 then
        D.succeed (List.head posterList |> Maybe.withDefault "")
    else
        D.fail "Poster list must have exactly one item"


-- Review ----------------------------------------------------------------------

{-| Our Review data structures

> Records are useful for different fields with the same type, or lots of
> values to be stored/accessed publically. Otherwise, consider using a
> custom type. A custom type also allows you to AVOID nested records.

The first version of this allowed a random `/reviews/:id` API to be directly added
to the review form. This had a serious potential bug, where the timestamp from
the review got added to a hidden form field (and `readonly` added to form fields).

- What if a user edited one of the form fields?
- What if a user deleted the form and started again?

Our `TimeStamp` could've gotten out of sync. So it's safer for us to save a review
from that API directly to the `List Review`. We could always allow the user to
modify it later on.

## Notes

> Do not allow any `null` values for a review! Add it or don't.

1. We'll utilize `rtfeldman/elm-iso8601-date-strings` to convert times
    - @ https://timestampgenerator.com/
2. Stars can only ever be a number between 1-5. See "Cardinality":
    - @ https://guide.elm-lang.org/appendix/types_as_sets#cardinality
    - We don't allow `.5` decimal points, and round up if a review has them.

-}
type alias Review =
    { timestamp : TimeStamp -- (1)
    , name : Name
    , review : String
    , rating : Stars -- (2)
    }

type alias TimeStamp
    = Time.Posix -- (1)

type Name
    = Name String

nameToString : Name -> String
nameToString (Name name) =
    name

{- Be strict with your `Int` types for `Stars` and avoid the "2:00" problem -}
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

urlAPI : String
urlAPI = "http://localhost:3000"

getFilms : Cmd Msg
getFilms =
    Http.get
        { url = urlAPI ++ "/films"
        , expect = Http.expectJson GotFilms (D.list decodeFilm)
        }

getReview : Int -> Cmd Msg
getReview reviewID =
    Http.get
        { url = urlAPI ++ "/reviews" ++ "/" ++ String.fromInt reviewID
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




--------------------------------------------------------------------------------
-- - @ https://github.com/rtfeldman/elm-spa-example/blob/cb32acd73c3d346d0064e7923049867d8ce67193/src/Page/Login.elm#L120
--------------------------------------------------------------------------------


-- View ------------------------------------------------------------------------
-- Also consider `Html.Lazy` to lazy load the films.

{-| Our view functions

1. Add Film form is outside the `viewFilms` view.
2. Edit and Add Review are edited-in-place (within the `Film`)
3. Try to narrow the types as much as possible

-}
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
                , button [ onClick CancelAllForms ]
                    [ text "Cancel all forms and reset to `NewFilm` state" ]
                -- #! Using `Nothing` here is a bit hacky!
                , case model.formState of
                    NewFilm ->
                        viewFilmForm Nothing model addFilmButton

                    EditFilm _ ->
                        text ""

                    AddReview _ ->
                        text ""
                , hr [] []
                -- #! We haven't narrowed the types enough!!!
                -- We need `model.formFields` later on in order to change the state
                -- correctly. Even worse, we're sharing the film form between the
                -- Add Form state and Edit Form state :(
                , viewFilms model.formState films model -- (1)
            ]

        Error errorMsg ->
            text ("Error loading films: " ++ errorMsg)


viewFilms : Form -> List Film -> Model -> Html Msg
viewFilms formState films model =
    case films of
        [] ->
            text "No films yet!"

        _ ->
            ul []
                (List.map (viewFilmOrForm formState model) films)

{-| #! ⚠️ Our caseing is a little CRAZY!

> ⚠️ Our state is becoming quite hard to manage ...
> Because our types aren't 100% encapsulated, we need to case on all the things.

Alternatively we could be more sure that a film is in an `EditFilm` state, and
provide everything we need to know about it's state to the particular `Film` that
needs editing. Then we wouldn't have to worry about `NoForm` or `NewFilm`.

## Notes

1. We're also doing a lot more casing than is necessary!
    - With a different type structure we could've narrowed the types a bit.

```elm
if selectedFilmID == filmID then
    case filmState of
        Film EditMode _ _ ->
            ...
        Film AddReviewMode _ _ ->
            ...
else
    viewFilm film
```

-}
viewFilmOrForm : Form -> Model -> Film -> Html Msg
viewFilmOrForm formState model film =
    let
        filmID = getFilmID film
    in
    case formState of
        NewFilm ->
            viewFilm film -- No need for form fields

        EditFilm selectedFilmID ->
            if selectedFilmID == filmID then
                -- #! If we've selected a film to edit, we'll need to send
                -- along the whole `Model` just to access the form fields.
                viewFilmForm (Just filmID) model editFilmButton
            else
                viewFilm film

        AddReview selectedFilmID ->
            if selectedFilmID == filmID then
                -- #! If we've selected a film to edit, we'll need to send
                -- along the whole `Model` just to access the form fields.
                viewReviewFormOrRandom filmID model
            else
                viewFilm film


viewPoster : String -> Html msg
viewPoster id =
    img [ src (posterUrl ++ id), attribute "loading" "lazy" ] []

{-| #! THIS NEEDS TIDYING UP: WOULD BE EASIER IF IN OWN MODULE!!! -}
viewFilm : Film -> Html Msg
viewFilm film =
    let
        data = filmData film
        reviews = filmReviews film
    in
    div [ class "film"]
        [ li []
            [ h1 [] [ text data.title ]
            , div [] [ text data.summary ]
            , viewTrailor data.trailer
            , viewPoster data.poster
            , viewReviews reviews
            ]
        , button [ onClick (ClickedAddReview data.id) ]
            [ text "Add a review" ]
        , button [ onClick (ClickedEditFilm data.id) ]
            [ text "Edit film" ]
        ]

viewTrailor : Maybe Url -> Html msg
viewTrailor maybeUrl =
    case maybeUrl of
        Just url ->
            a [ href (U.toString url) ] [ text "Watch trailer" ]

        Nothing ->
            text "No trailer available"

{- Returns an empty list if no reviews -}
viewReviews : List Review -> Html msg
viewReviews reviews =
    ul [] (List.map viewReview reviews)

viewReview : Review -> Html msg
viewReview review =
    li []
        [ text ("Review by " ++ nameToString review.name)
        , text ("Rating: " ++ String.fromInt (starsToNumber review.rating))
        , text ("Review: " ++ review.review)
        , text ("Timestamp: " ++ Iso8601.fromTime review.timestamp)
        ]

viewReviewFormOrRandom : FilmID -> Model -> Html Msg
viewReviewFormOrRandom filmID model =
    div []
        [ viewReviewForm filmID model addReviewButton
        , case model.apiReview of
            Nothing ->
                button [ onClick ClickedRandom ] [ text "Get a random review" ]
            Just review ->
                saveAPIReviewButton filmID review
        ]

viewInput : String -> (String -> msg) -> String -> String -> Html msg
viewInput t toMsg p v =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

{-| ⚠️ Here's a little hacky form

> Remember that our `onSubmit` state is in the FORM (not button) ..

We need a `Maybe FilmID` here as we're sharing the view between Add/Edit and we've
no other way to know which is which. We could've encapsulated this better like:

```elm
type Form
    = NewForm (List Problem) FilmForm
    | EditForm FilmID (List Problem) FilmForm
    | ...
```

## Better safe than sorry ...

We could also `case formState of` and have our Add Review form within this function
also, but just to be safe we'll split that out into another function.

-}
viewFilmForm : Maybe FilmID -> FilmForm a -> Html Msg -> Html Msg
viewFilmForm maybeFilmID form button =
    Html.form [ onSubmit (ClickedSaveFilm maybeFilmID) ] -- #! Case on this in update function
        [ viewInput "text" InputTitle "Title" form.title
        , viewInput "text" InputTrailer "Trailer URL" form.trailer
        , viewInput "text" InputPoster "Poster URL" form.poster
        , viewInput "text" InputSummary "Summary" form.summary
        , viewInput "text" InputTags "Tags (comma separated)" form.tags
        , button
        ]

viewReviewForm : FilmID -> ReviewForm a -> Html Msg -> Html Msg
viewReviewForm filmID form button =
    Html.form [ onSubmit (ClickedAddReview filmID) ] -- #! Case on this in update function
        [ viewInput "text" InputName "Name" form.name
        , viewInput "text" InputReview "Review" form.review
        , viewInput "text" InputRating "Rating" form.rating
        , button
        ]

addFilmButton : Html msg
addFilmButton =
    saveFilmButton "Add a new film"

editFilmButton : Html msg
editFilmButton =
    saveFilmButton "Edit the film"

addReviewButton : Html msg
addReviewButton =
    saveFilmButton "Add a review"

saveFilmButton : String -> Html msg
saveFilmButton caption =
    button [ class "button" ]
        [ text caption ]

{-| Another way to add a review — from our `/reviews/:id` API

> We've simplified the `TimeStamp` problem by avoiding adding to the form

We store the review temporarily and have a simple "Add Review" button so the user
can add it automatically. We could always give them an option to edit the review
if we wanted.

-}
saveAPIReviewButton : FilmID -> Review -> Html Msg
saveAPIReviewButton filmID review =
    button [ class "button", onClick (ClickedAddAPIReview filmID review) ]
        [ text ("Add review by " ++ nameToString review.name)
        , text " (Rating: "
        , text (String.fromInt (starsToNumber review.rating))
        , text ")"
        ]


-- Messages --------------------------------------------------------------------
-- ⚠️ Is it better to have ONE message per action, or share messages between two
-- different (but similar) actions? (Example: an API click that requires a
-- `Review`, -vs- a form click that generates a `Review` on validation)

type Msg
    = CancelAllForms
    | ClickedAddReview FilmID
    | ClickedAddAPIReview FilmID Review
    | ClickedEditFilm FilmID
    | ClickedSaveFilm (Maybe FilmID) -- #! Shared by Add/Edit
    | ClickedSaveReview FilmID
    | ClickedRandom
    | GotFilms (Result Http.Error (List Film))
    | GotNumber Int
    | GotReview (Result Http.Error Review)
    | PassedSlowLoadingThreshold
    -- Film form
    | InputTitle String
    | InputTrailer String
    | InputPoster String
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
    case Debug.log "Messages" msg of
        CancelAllForms ->
            -- Reset the form state to `NewFilm`
            ( { model
                | formState = NewFilm
                , title = ""
                , trailer = ""
                , summary = ""
                , poster = ""
                , tags = ""
                , errors = []
              }
            , Cmd.none
            )

        ClickedAddReview filmID ->
            ( { model
                | formState = AddReview filmID
              }
            , Cmd.none)


        ClickedAddAPIReview filmID review ->
            -- If we're in this branch, our `model.van` should have films
            case model.van of
                -- #! ⚠️ You could use `Maybe.map` here instead!!!
                Success films ->
                    ( { model
                            | van =
                                Success (updateFilms (updateReviews filmID review) films)
                            -- #! ⚠️ Reset the form state: This could get quite
                            -- confusing eventually! Perhaps it'd be better to
                            -- hold all state in on `Status` type?
                            , apiReview = Nothing
                            , formState = NewFilm
                            , errors = []
                      }
                    , Cmd.none
                    )

                _ ->
                    -- If we don't have a film, we can't add the review
                    -- This should never error (I don't think)
                    ( { model | errors = [ "Cannot add review without a film" ] }
                    , Cmd.none
                    )

        ClickedEditFilm filmID ->
            case model.van of
                Success films ->
                    -- #! ⚠️ We should be able to guarantee this function always
                    -- returns a valid film. It should never fail
                    case List.head (filterFilmsByID filmID films) of
                        Just film ->
                            -- If we have a film, we can edit it
                            let
                                fields = filmData film
                            in
                            ( { model
                                | formState = EditFilm fields.id
                                , title = fields.title
                                , trailer = Maybe.map U.toString fields.trailer |> Maybe.withDefault ""
                                , summary = fields.summary
                                , poster = fields.poster
                                , tags = fields.tags |> (List.intersperse " ") |> String.concat
                            }
                            , Cmd.none)

                        Nothing ->
                            -- If we don't have a film, we can't edit it
                            ( { model | errors = [ "Cannot edit film that does not exist" ] }
                            , Cmd.none
                            )

                _ ->
                    -- If we don't have a film, we can't edit it
                    ( { model | errors = [ "Cannot edit film without a van" ] }
                    , Cmd.none
                    )

        ClickedRandom ->
            ( model, randomNumber )

        ClickedSaveFilm maybeFilmID ->
            case maybeFilmID of
                Just filmID ->
                    -- If we have a film ID, we're editing an existing film
                    ( { model
                        | formState = NewFilm -- Reset to NewFilm after saving
                        , errors = [ Debug.todo "Make the film form work" ] -- Clear any previous errors
                      }
                    , Cmd.none
                    )

                Nothing ->
                    -- Otherwise, we're adding a new film
                    ( { model
                        | formState = NewFilm -- Reset to NewFilm after saving
                        , errors = [ Debug.todo "Make the film form work" ] -- Clear any previous errors
                      }
                    , Cmd.none
                    )

        ClickedSaveReview filmID ->
            ( { model
                | formState = NewFilm -- Reset to NewFilm after saving
                , errors = [ Debug.todo "Make the review form work" ] -- Clear any previous errors
            }
            , Cmd.none
            )

        -- ⚠️ It doesn't matter if our films are `[]` empty or not. Just return
        -- them and let the view functions worry about the empty case.
        GotFilms (Ok films) ->
            ( { model
                | van = Success films
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
            ( { model | apiReview = Just review }
            , Cmd.none
            )

        GotReview (Err _) ->
            ( { model | errors = [ "Failed to load review" ] }
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

        InputPoster str ->
            ( { model | poster = str }
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

updateFilms : (Film -> Film) -> List Film -> List Film
updateFilms transform films =
    List.map transform films

updateReviews : FilmID -> Review -> Film -> Film
updateReviews filmID review film =
    if filmID == getFilmID film then
        addReviewToFilm review film
    else
        film -- No change if the film ID doesn't match

addReviewToFilm : Review -> Film -> Film
addReviewToFilm review (Film internals reviews) =
    Film internals (reviews ++ [review])

filterFilmsByID : FilmID -> List Film -> List Film
filterFilmsByID filmID films =
    List.filter (\film -> getFilmID film == filmID) films


-- Film functions --------------------------------------------------------------
-- Add, edit, delete, save, orderBy stars total (update server right away)






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
