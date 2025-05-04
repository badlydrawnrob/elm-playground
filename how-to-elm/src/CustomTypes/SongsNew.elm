module CustomTypes.SongsNew exposing (..)

{-| ----------------------------------------------------------------------------
    Songs (the correct way to do user input)
    ============================================================================
    > You shouldn't store computed values in the model!
    > There's different ways to update input (here I'm using a custom type)

    Not only do you make excess work for yourself, but the code becomes more
    complicated. The previous version also used a custom `Album` and `Song` type,
    rather than a simple `List Song` (or record). You also want to hang on to the
    original input, so you can show that back to the user.

    1. Think carefully whether you need a custom type.
        - What guarantees are you trying to create?
        - Is it _really_ an improvement over basic data structures?
    2. A `Msg` is to CARRY DATA and notify a state change. It's NOT for changing
       and updating state. That's updates job.
        - @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    3. It's best to unpack (lift) a `Maybe` type in ONE place.
        - @ https://tinyurl.com/stop-unpacking-maybe-too-often
    4. Nested records are faster to unpack (.accessor function), harder to update.
        - @ https://tinyurl.com/custom-type-songs-65d9662
    5. Custom types (not a record) are harder to unpack (pattern matching), but
       easier to update (no nested update function required)
        - @ https://tinyurl.com/custom-type-songsalt-65d9662
    6. For a short form, you might like to have ALL fields as their own `Msg`.
        - As we've got quite a few inputs, a single `Msg` is better.

    Simplify
    --------
    > Simplify your state wherever possible.
    > Is the data flow and functions easy to follow?
    > Can you see things at-a-glance? (My future stupid self)

    - See "The 5 ways to reduce code"
    - Nested records are OK in moderation, but prefer a flatter style ...
    - You could easily just write a big record with more fields.
    - `List.map` expects everything in the list to be the same type.
    - Converting two `Int` inputs to a `"Int:Int"` string (The `"2:00"` problem)
    - Avoid chaining `Result`s together. It makes life complected.
    - Only use `Result.andThen` for a single data point.
    - A function should have as few parameters as possible.

    ---------------------------------------------------------
    The previous version looked like this (storing `Result`):

        type alias Validate a
            = Result String a

        type alias UserInput a
            = { input : String
              , valid : Validate a
              }

    ---------------------------------------------------------

    Using the sentence method to break down the problem:

    1. Write out your program in plain English with a single sentence.
    2. Any clauses (commas, and, then) should be split into it's own sentence.
    3. Repeat the process until you have a list of single sentences.
    4. Convert these into HTDP style headers (wishlist); watch out for state!
        - Which functions have ZERO state? Which have some state?

    |   The user can create a new song by entering song details into a form.
    |   We start with a `NoAlbum` state, and then move to `Album` state.


    Wishlist
    --------
    1. Build a form with song details
    2. Validate the form as the user is typing (not `onSubmit`)
        - Do you want to show errors as the user is typing, or on save?
        - The errors can appear under the form field input.
    3. When user clicks submit, check the form is valid (`onSubmit`)
    4. If a `Song` is valid, create an `Album` (with an `ID`).
        - An `Album` cannot be created without at least ONE `Song`.
    5. Add the `Song` to the `Album` (songs do not have an `ID`).

    Do something with `List.take` and `List.indexedMap` (like `ToDoSimple`). It
    might've been easier to give each `Song` an `ID` and use that.

    6. The form has a few states:
        - `NoAlbum`, ~~editing `Album`,~~ edit `Song`.
    7. Songs are generally numbered (for now this is implicit)
    8. Pull/Push to an API.
        - Should ALWAYS have at least one `Song` in the `Album`.
    9. `Insert | Edit ID | Delete` modes (potentially use the same form)
        - Is using the same form a bit of a risk?
        - If API do you update song straight away, or in bulk?
        - The trouble with `Album Song (List Song)` is it's a bit harder to work
          with (delete, sort, etc) than a regular `List Song`.


    Errors
    ------
    > We're not using @rtfeldman's method here (Elm Spa Login)

    Instead, use a `Result.mapX` into the `Song`. Each field can have it's own
    validation function rather than `case`ing on `(ValidField, String)` types
    (like `Form.Passport`) or `.concatMap` over `List ValidField` to generate a
    `List Error` like @rtfeldman does.

    ----------------------------------------------------------------------------

    Other learning points
    ---------------------
    > There's many ways to validate a form. Just make it work!
    > @ https://tinyurl.com/the-elm-way-to-validate-form

    - Look how `Song` is created; `updateAlbum` is simply passed a `Song`.
    - A `Tuple` adds some complexity. A `String` is easier to work with.
    - Remember the roles of `Msg`, `Update`, `View` and put functions in right place!
    - More on Nested Records (and ways to do it)
        - @ https://discourse.elm-lang.org/t/updating-nested-records-again/1488
        - @ https://tinyurl.com/elm-spa-nested-login (using lambda and function)
        - @ https://tinyurl.com/elm-lang-why-not-nested
        - @ https://tinyurl.com/elm-spa-custom-types-eg

-}

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (placeholder)


-- Types -----------------------------------------------------------------------

type alias Song =
    { title : String
    , artist : String
    , album : String
    , year : Int
    , time : (Int, Int)
    }

type alias Form =
    { title : String
    , artist : String
    , album : String
    , year : String
    , minutes : String -- time
    , seconds : String -- time
    }

type Album
    = NoAlbum
    | Album Song (List Song)

type Input
    = Title
    | Artist
    | Album
    | Year
    | Minutes
    | Seconds


-- Model -----------------------------------------------------------------------

type alias Model =
    { album : Album
    , currentSong : Form
    }


-- Messages --------------------------------------------------------------------
-- Our `ChangeInput` type doesn't really save us much. May as well be explicit.

type Msg
    = SavedForm
    | ChangeInput Input String


-- Helper functions ------------------------------------------------------------


-- View ------------------------------------------------------------------------
-- See `Form.Simple`, `Form.SingleField` and other examples on structuring input.
-- `Input` could be replaced with a `String`, `Int`, or full `Msg` type.

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Songs" ]
        , viewSongForm model.currentSong
        ]

{- Explicit is better than implicit? -}
viewSongForm : Form -> Html Msg
viewSongForm { title, artist, album, year, minutes, seconds } =
    div []
        [ input []
            [ value title
            , onInput (ChangeInput Title)
            , placeholder "Title"
            ]
        , input []
            [ value artist
            , onInput (ChangeInput Artist)
            , placeholder "Artist"
            ]
        , input []
            [ value album
            , onInput (ChangeInput Album)
            , placeholder "Album"
            ]
        , input []
            [ value year
            , onInput (ChangeInput Year)
            , placeholder "Year"
            ]
        , input []
            [ value minutes
            , onInput (ChangeInput Minutes)
            , placeholder "Minutes"
            ]
        , input []
            [ value seconds
            , onInput (ChangeInput Seconds)
            , placeholder "Seconds"
            ]
        ]

-- Update ----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
    case msg of
        SavedForm ->
            case model.album of
                NoAlbum ->
                    { model
                        | album = Album (createSong model.currentSong) []
                    }

                Album song songs ->
                    { model
                        | album = Album song (createSong model.currentSong :: songs)
                    }

    {- #! This doesn't really save us much, other than extra `Msg` types -}
        ChangeInput Title value ->
            { model | currentSong = { model.currentSong | title = value } }

        ChangeInput Artist value ->
            { model | currentSong = { model.currentSong | title = value } }

        ChangeInput Album value ->
            { model | currentSong = { model.currentSong | album = value } }

        ChangeInput Year value ->
            { model | currentSong = { model.currentSong | year = value } }

        ChangeInput Minutes value ->
            { model | currentSong = { model.currentSong | minutes = value } }

        ChangeInput Seconds value ->
            { model | currentSong = { model.currentSong | seconds = value } }


createSong : Form -> Song
createSong { title, artist, album, year, minutes, seconds } =
    Result.map6 Song
        (Ok (String.toInt year))
        (Ok (String.toInt minutes))
        (Ok (String.toInt seconds))
        (Ok (String.trim title))
        (Ok (String.trim artist))
        (Ok (String.trim album))

