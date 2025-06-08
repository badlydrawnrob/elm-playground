module CustomTypes.Films exposing (..)

{-| ----------------------------------------------------------------------------
    A Film (similar but different to `Songs.elm`)
    ============================================================================
    > Aim to keep your wishlist and architecture simple.
    > Have it written down somewhere, where it's easy to glance at.
    > @ [Films API](https://github.com/badlydrawnrob/data-playground/mocking/films)

    It's a rough and ready proof-of-concept that's imperfect. Here are the things
    that haven't been done yet:

    - Form validation  - Fancy CSS   - Some `Form` state management

    Here's the core learning points

    1. Never use a `Maybe` when a `[]` will do (it adds complexity artifacts)
        - We can avoid LOTS of unpacking and packing (or `Maybe.map`ing here)
        - If you must use `Maybe`, `Maybe.map` is useful in a pipeline ...
        - But you might want to unpack it with pattern matching inside a `case`
    2. Try to avoid impossible states
        - If you've got a note in your code saying "this should never happen ..."
        - Then your types are probably wrong. Make impossible states impossible!
    3. Our Add/Edit forms share the same fields and view
        - The view isn't too much of a problem ...
        - But we should probably encapsulate the form state better ... like a
          `EditFilm (List Problem) Form` type (or within the `Film` type)
        - A flat model is fine for a single form, but gets messy with multiple
    4. Atomic endpoints are FAR, FAR, FAR easier than lots of page state.
        - `/films` to add a film, `/films/:id/edit` to edit a film
        - And perhaps a `/films/:id/reviews` to add a review
    5. Your spec is always dumb for the first 2-3 drafts
        - @ [Original spec](https://tinyurl.com/elm-playground-spec)
        - Sometimes you find this out along the way, but aim to nail it
        - Sketch it out, write it down, find a way to make it less dumb
        - Paper prototypes / user testing are cheaper and quicker
    6. Keep your comments up-to-date and short. For full notes, create a document
       or article you can refer to.
        - Aim for ONE idea per `/how-to-elm` package.
    7. Simple decisions have big ripple effects: the "TimeStamp" problem
        - Adding a random review to the review form means we worry about bugs
        - Our `TimeStamp` could get out of whack if fields are user-editable
            - We'd also need a `"hidden"` field and read-only form fields


    Make the spec less dumb!
    ------------------------
    1. Can you write your spec in a single sentence?
    2. Is it starting to gather into a few lines (the sentence method)
    3. Do you end up with a PDF full of 16 pages of code and notes?
    4. Have we minimised the state of the page and data?**
    5. Are our types as narrow as they could be?

    Try to encapsulate everything we need to know about the program in
    1-2 Markdown pages. If there are learning points along the way, add them to
    Anki, your notes, or a dedicated article.

    **A balance of user-experience and developer pain. We really don't need an
      opaque type like `Film` here (it's purpose for Elm Spa is different to ours
      as it's generated from the server) and it's not read-only. We might want
      to consider changing our app architecture similarly to Elm Spa.


    The sentence method (our van man)
    ---------------------------------
    > Using the sentence method to break down the problem!

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


    Assumptions
    -----------
    1. Our http server is already built with a single `/films` endpoint
    2. We output `json` with `List Film` (each film contains full reviews)
    3. Our SQL schema looks like this:

    Film                        Review
    | ID | Title      | ... |   | Timestamp  | Film ID | Name | Stars | Review |
    |----|------------|-----|   |------------|---------|------|-------|--------|
    | 1  | The Matrix | ... |   | 2023-10-01 | 1       | ...  | 5     | ...    |


    Wishlist
    --------
    > Our van is an endpoint. It starts with `[]` zero objects.
    > We're not allowed to push to the server without any `Film`s.

    We have three forms: add, edit, add review. The add form is above the
    `List Film` when it's visible. The other forms can be edited in place (within
    the `Film` it's editing)

    1. The only endpoint is `/films`. We have no individual `:id` endpoint.
        - A `Review` is implicitly tied to a `Film`.
    2. `Film` has no `Preview` state (like Elm Spa)
        - All `Film` data is loaded if it exists on the server.
        - Don't display all `Film.fields` if you need a preview view.
    3. All image URLs must be `jpeg` format and small (for fast loading)
        - Add `loading="lazy"` to the `img` tag for the view
        - @ https://web.dev/explore/fast (🚀 TIPS ON LOADING QUICKLY)
    4. A `Film` must exist before a `Review` can be made.[^1]
        - The `FilmID` is required to add a review (Elm Spa uses `/slug`)
        - Multiple reviews can be added to a film (the user is an admin)
    5. We have access to a `/reviews` API (see the films API above) to:
        - Search a review by `:id` (a bit like an ISBN number)
        - Add the review to the list (or manually create one instead)
    6. The end-user must have `Cred` (an existing logged-in account)
        - They can only peform actions (add, edit, delete, save) if logged in.
        - This type is read-only (an opaque type; generated by Auth0)
    7. Consider using `Array` or `List.take` or `List.indexedMap`
        - The latter allows us to generate an index for each list item.

    [^1]: Don't use a custom type unless you need to. We don't gain much if our
          `Review` type is a custom type (our first draft) rather than a record.

    ----------------------------------------------------------------------------

    Paper prototyping the customer journey
    --------------------------------------
    > ⚠️ Sketch out the potential routes before you start to code

    There are so many micro-decisions to make about your program. How the user
    interacts with it, your server endpoints, how often you're pinging the server,
    how the customer journey affects state, and therefore your types.

    Reduce, reduce, reduce the possible states of your program!!!

    - Prefer minimal data wherever possible
    - What are all the possible states and how do we represent them?
    - Can we create some guarantees to make impossible states impossible?
    - Can any of these states be simplified or removed?
    - Are any of our types read-only

    Helpful videos
    --------------
    @ https://www.youtube.com/watch?v=x1FU3e0sT1I (make data structures)
    @ https://sporto.github.io/elm-patterns/basic/impossible-states.html
    @ https://elm-radio.com/episode/life-of-a-file/ (which data struture?)
    @ https://discourse.elm-lang.org/t/domain-driven-type-narrowing/7753 (narrow types)

    Elm Spa as an example (@rtfeldman)
    ----------------------------------
    1. The login page has a simple `model.form` fields setup
    2. Article uses `Status a` for `model.article` and `model.comments`
    3. Editor has a more complex `Status` type (holds every state possible)

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
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
import Platform.Cmd as Cmd
import Platform.Cmd as Cmd
import List exposing (filter)


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
    { van : Server (Maybe (List Film)) -- #! (1)
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
    = Film Internals (Maybe (List Review)) -- #! (1)

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
    , tags : Maybe (List String) -- Optional (`null` allowed)
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

filmReviews : Film -> Maybe (List Review)
filmReviews (Film _ maybeReviews) =
    maybeReviews

decodeFilm : Decoder Film
decodeFilm =
    D.map2 Film
        decodeFilmMeta
        (D.field "reviews" (D.nullable (D.list decodeReview)))

decodeFilmMeta : Decoder Internals
decodeFilmMeta =
    D.map6 Internals
        (D.field "id" (D.map FilmID D.string))
        (D.field "title" D.string)
        (D.field "trailer" (D.map U.fromString D.string)) -- #! Forces a `Maybe`
        (D.field "summary" D.string)
        ((D.field "poster" (D.list D.string)
            |> D.andThen decodePoster))
        (D.field "tags" (D.nullable (D.list D.string)))

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


viewFilms : Form -> Maybe (List Film) -> Model -> Html Msg
viewFilms formState maybeFilms model =
    case maybeFilms of
        Just films ->
            -- #! We were supposed to have a list here, but because we've got

            ul []
                (List.map (viewFilmOrForm formState model) films) -- #! Edit form only


        Nothing ->
            text "No films yet!"

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

viewReviews : Maybe (List Review) -> Html msg
viewReviews maybeReviews =
    case maybeReviews of
        Just reviews ->
            ul [] (List.map viewReview reviews)

        Nothing ->
            text "No reviews yet!"

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
                Success (Just films) ->
                    ( { model
                            | van =
                                Success (Just (updateFilms (updateReviews filmID review) films))
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
                Success (Just films) ->
                    case List.head (filterFilmsByID filmID films) of
                        Nothing ->
                            -- If we don't have a film, we can't edit it
                            ( { model | errors = [ "Cannot edit film that does not exist" ] }
                            , Cmd.none
                            )

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
                                , tags = fields.tags |> Maybe.map (List.intersperse " ") |> Maybe.map String.concat |> Maybe.withDefault ""
                            }
                            , Cmd.none)

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

        GotFilms (Ok []) ->
            -- If our van is empty (from the server) we notify:
            ( { model
                | van = Success Nothing
              }
            , Cmd.none
            )

        GotFilms (Ok films) ->
            -- Otherwise update the model with current list of films
            ( { model | van = Success (Just films)
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
    case reviews of
        Just hasReviews ->
            -- If we have reviews, add the new one to the BACK of the list
            Film internals (Just (hasReviews ++ [ review ]))

        Nothing ->
            Film internals reviews

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
