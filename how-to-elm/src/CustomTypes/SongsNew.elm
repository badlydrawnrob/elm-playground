module CustomTypes.SongsNew exposing (..)

{-| ----------------------------------------------------------------------------
    Songs (the correct way to do user input)
    ============================================================================
    > You shouldn't store computed values in the model!

    Not only do you make excess work for yourself, but the code becomes more
    complicated. The previous version also used a custom `Album` and `Song` type,
    rather than a simple `List Song` (or record). You also want to hang on to the
    original input, so you can show that back to the user.

    1. I'm not using @rtfeldman's method here (with `.concatMap`)
        - Generating a `List String` of errors might be preferable in some cases?
        - If the `List String` of errors is empty, the form can be saved!
    2. Think carefully whether you need a custom type!
        - What guarantees are you trying to create?
        - Is it _really_ an improvement over basic data structures?
    2. A `Msg` is to CARRY DATA and notify a state change. It's NOT for changing
       and updating state. That's updates job.
        - @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    3. It's best to unpack (lift) a `Maybe` type in ONE place.
        - @ https://tinyurl.com/stop-unpacking-maybe-too-often
        - Reach for `Maybe.withDefault` LATE (normally in your view)
    4. Nested records are faster to unpack (.accessor function), harder to update.
        - @ https://tinyurl.com/custom-type-songs-65d9662
    5. Custom types (not a record) are harder to unpack (pattern matching), but
       easier to update (no nested update function required)
        - @ https://tinyurl.com/custom-type-songsalt-65d9662
    6. For a short form, you might like to have ALL fields as their own `Msg`.
        - As we've got quite a few inputs, a single `Msg` is better.
    7. It's the FORM that has the `onSubmit` state (not the button)
        - Button must live _inside_ the `form` tag, or it won't submit.
        - You _could_ use `onClick` instead if for some reason the button needed
          to live outside the form.

    Simplify
    --------
    > Simplify your state wherever possible!
    > Is the data flow and functions easy to follow?
    > Can you see things at-a-glance? (My future stupid self)

    - See "The 5 ways to reduce code" (Tesla model)
    - Nested records are OK in moderation, but prefer a flatter style ...
        - You could easily just write a big record with more fields.
    - `List.map` expects everything in the list to be the same type.
    - Simplify state (input variations) `"Int:Int"` (The `"2:00"` problem)
    - Only use `Result.andThen` for a single data point
        - Avoid chaining `Result`s together. It makes life complected.
        - `Result.map` only goes up to FIVE arguments (`.map6` doesn't exist)
        - If `Song` had 7 fields, the `Result.map` might need to be 3 levels
          deep, which adds complexity (how to pass a `Song` to a `Song`?!)
    - A function should have as few parameters as possible!

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


    Wishlist (basic)
    ----------------
    1. ~~Build a form with song details~~
    2. ~~Validate the form as the user is typing (not `onSubmit`)~~
        - Do you want to show errors as the user is typing, or on save?
        - The errors can appear under the form field input.
    3. ~~When user clicks submit, check the form is valid (`onSubmit`)~~
    4. ~~If a `Song` is valid, create an `Album`.~~
        - ~~An `Album` cannot be created without at least ONE `Song`.~~
    5. ~~Add the `Song` to the `Album` (songs do not have an `ID`).~~

    Wishlist (advanced)
    -------------------
    > `List.take`, `List.indexedMap` (like `ToDoSimple`), or `Array` can be used
    > to get the index of a list. It might be easier to just give each song an
    > `ID` or a list position (normally songs are numbered in Apple Music) ...

    1. Give the form different states:
        - `Insert | Edit ID | Delete` modes (to edit the songs)
        - What happens if `NoAlbum`? Or MULTIPLE Albums?
        - `Album` is going to cause you problems (for delete, sort, etc) because
          `firstSong` needs concatonation or destructuring on every album save.
            - #! `List Song` would be FAR easier!
        - Is using the same form a risk? (is type safe changes enough?)
    2. Pull/Push to an API. Keep it simple for now.
        - Should ALWAYS have at least one `Song` in the `Album`.
        - Do you update the `Album` straight away? (on EVERY song change)

    Errors
    ------
    > We're using `Result.mapX` here, no @rtfeldman's Elm Spa method.

    `Result.map` only goes up to FIVE. For anything over that you'll have to
    do some trickery to make it work. It could be difficult to generate a `Song`
    if you're having to `andThen` or chain `Result.map`.

    It's also maybe not the best way to work out validations. In @rtfeldman's
    example he uses `ValidField` types `Email | Password` and generates a
    `List String` of errors (rather than working with `Result.map`). If the error
    list is empty, you can go ahead and generate a `Song`!

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

import Browser
import Debug

import Html exposing (Html, button, div, form, h1, hr, input, li, p, text, ul)
import Html.Attributes exposing (placeholder, style, value)
import Html.Events exposing (onInput, onSubmit)


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
    | AlbumTitle
    | Year
    | Minutes
    | Seconds


-- Model -----------------------------------------------------------------------

type alias Model =
    { album : Album
    , currentSong : Form
    , error : String
    }

init =
    { album = NoAlbum
    , currentSong = { title = "", artist = "", album = "", year = "", minutes = "", seconds = "" }
    , error = ""
    }


-- Messages --------------------------------------------------------------------
-- Our `ChangeInput` type doesn't really save us much. May as well be explicit.

type Msg
    = ClickedSave
    | ChangeInput Input String


-- Helper functions ------------------------------------------------------------
-- #! `getAllSongs` is helpful if the `Album` has no ID or title to grab, as we
--    don't have to repeatedly concatonate the `firstSong` and `restSongs` together.
--    If `Album` had it's own metadata, this might not work.

getAllSongs : Album -> List Song
getAllSongs album =
    case album of
        NoAlbum ->
            []

        Album firstSong restSongs ->
            [firstSong] ++ restSongs

getTime : (Int, Int) -> String
getTime (mins, secs) =
    String.fromInt mins ++ ":" ++ String.fromInt secs


-- View ------------------------------------------------------------------------
-- See `Form.Simple`, `Form.SingleField` and other examples on structuring input.
-- `Input` could be replaced with a `String`, `Int`, or full `Msg` type.

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Songs" ]
        , viewSongForm model.currentSong
        , p [ style "colour" "red" ] [ text model.error ]
        , hr [] []
        , viewAlbum model.album
        ]

{- We've changed to use `getAllSongs` so we don't work with the album directly -}
viewAlbum : Album -> Html Msg
viewAlbum album =
    case Debug.log "all songs" (getAllSongs album) of
        [] ->
            div [] [ text "No Album created yet" ]

        songs ->
            div []
                [ ul []
                    (List.map viewSongItem songs)
                ]

viewSongItem : Song -> Html Msg
viewSongItem {title, artist, album, year, time } =
    li []
        [ text (title ++ " by " ++ artist)
        , p [] [ text album ]
        , p [] [ text (String.fromInt year) ]
        , p [] [ text ("runtime:" ++ getTime time) ]
        ]

{- Explicit is better than implicit? -}
viewSongForm : Form -> Html Msg
viewSongForm { title, artist, album, year, minutes, seconds } =
    form [ onSubmit ClickedSave ]
        [ input
            [ value title
            , onInput (ChangeInput Title)
            , placeholder "Title"
            ]
            []
        , p [] [ viewError title isEmpty ]
        , input
            [ value artist
            , onInput (ChangeInput Artist)
            , placeholder "Artist"
            ]
            []
        , input
            [ value album
            , onInput (ChangeInput AlbumTitle)
            , placeholder "Album"
            ]
            []
        , input
            [ value year
            , onInput (ChangeInput Year)
            , placeholder "Year"
            ]
            []
        , p [] [ viewError year isYear ]
        , input
            [ value minutes
            , onInput (ChangeInput Minutes)
            , placeholder "Minutes"
            ]
            []
        , input
            [ value seconds
            , onInput (ChangeInput Seconds)
            , placeholder "Seconds"
            ]
            []
        , button [] [ text "Create a song" ]
        ]

{- We only care (return) if it's an error -}
viewError : String -> (String -> Result String a) -> Html msg
viewError value check =
    case (check value) of
        Ok _ ->
            text ""

        Err error ->
            text error



-- Update ----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
    let
        {- #! Can't use `model.record` to update record directly -}
        songRecord = model.currentSong
    in
    case msg of
        ClickedSave ->
            case (createSong model.currentSong) of
                Just song ->
                    { model
                        | album = updateAlbum song model.album
                        , currentSong = { title = "", artist = "", album = "", year = "", minutes = "", seconds = "" }
                        , error = ""
                    }

                Nothing ->
                    { model | error = "The form is not a valid song" }

    {- #! This doesn't really save us much, other than extra `Msg` types -}
        ChangeInput Title value ->
            { model | currentSong = { songRecord | title = value } }

        ChangeInput Artist value ->
            { model | currentSong = { songRecord | artist = value } }

        ChangeInput AlbumTitle value ->
            { model | currentSong = { songRecord | album = value } }

        ChangeInput Year value ->
            { model | currentSong = { songRecord | year = value } }

        ChangeInput Minutes value ->
            { model | currentSong = { songRecord | minutes = value } }

        ChangeInput Seconds value ->
            { model | currentSong = { songRecord | seconds = value } }


createSong : Form -> Maybe Song
createSong form =
    case Debug.log "is valid song?" (isValidSong form) of
        Ok song ->
            Just song

        Err _ ->
            Nothing

{- Mock some of the data for now -}
isValidSong : Form -> Result String Song
isValidSong { title, artist, album, year, minutes, seconds } =
    Result.map5 Song
        (isEmpty title)
        (Ok (String.trim artist))
        (Ok (String.trim album))
        (isYear year) <|
            (Result.map2 (\mins secs -> (mins, secs))
                (Ok (Maybe.withDefault 0 (String.toInt minutes)))
                (Ok (Maybe.withDefault 0 (String.toInt seconds))))

{- #! FIX THIS: DUPLICATING SONGS! -}
updateAlbum : Song -> Album -> Album
updateAlbum song album =
    case album of
        NoAlbum ->
            Album song []

        Album firstSong songs ->
            Album firstSong (song :: songs)


-- Validation ------------------------------------------------------------------

isYear : String -> Result String Int
isYear str =
    case String.toInt str of
        Just year ->
            if year > 2000 && year < 2030 then
                Ok year

            else
                Err "Year must be between 2000 and 2030"

        Nothing ->
            Err "Year must be a number"

isEmpty : String -> Result String String
isEmpty str =
    if String.isEmpty str then
        Err "Field cannot be empty"

    else
        Ok (String.trim str)


-- Main ------------------------------------------------------------------------

main =
    Browser.sandbox { init = init, update = update, view = view }
