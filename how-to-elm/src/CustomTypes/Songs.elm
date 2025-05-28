module CustomTypes.Songs exposing (..)

{-| ----------------------------------------------------------------------------
    Songs (the correct way to do user input) ⏰ 1 day
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
    3. A `Msg` is to CARRY DATA and notify a state change. It's NOT for changing
       and updating state. That's updates job.
        - @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    4. It's best to unpack (lift) a `Maybe` type in ONE place.
        - @ https://tinyurl.com/stop-unpacking-maybe-too-often
        - Reach for `Maybe.withDefault` LATE (normally in your view)
    5. Nested records are faster to unpack (.accessor function), harder to update.
        - @ https://tinyurl.com/custom-type-songs-65d9662
    6. Custom types (not a record) are harder to unpack (pattern matching), but
       easier to update (no nested update function required)
        - @ https://tinyurl.com/custom-type-songsalt-65d9662
    7. For a short form, you might like to have ALL fields as their own `Msg`.
        - As we've got quite a few inputs, a single `Msg` is better.
    8. It's the FORM that has the `onSubmit` state (not the button!)
        - Button must live _inside_ the `form` tag, or it won't submit.
        - You _could_ use `onClick` instead if for some reason the button needed
          to live outside the form.
    9. Consider your APP ARCHITECTURE in relation to your data model.
        - An `Album` should be non-empty (why not just use a `Maybe (List Song)`?)
        - If a `[singleton]` is deleted, do we ...
            - (a) delete the `Album` (if a collection of albums)
            - (b) notify the user "This album cannot be empty"

    Simplify your program
    ---------------------
    > Simplify your state wherever possible!
    > Is the data flow and functions easy to follow?
    > Can you see things at-a-glance? (My future stupid self)

    First, see "The 5 ways to reduce code" (Tesla model).
    A `List Song` is FAR easier to deal with than `Album first rest` ...
    That list could easily be ordered, shuffled, filtered (no cancatonation)

        @ https://www.youtube.com/watch?v=XpDsk374LDE ("Life of a File")

        What functionality do we need our `Album` type to have?
        If there's no non-List functionality, why bother using it?

    We could simplify our model further:

    - Prefer a flatter model: only use nested records in moderation!
    - Never nest records more than one level deep.
    - Consider refactoring into a bigger record with more fields.
    - A function should have as few parameters as possible!

    Be careful with types:

    - `List.map` expects everything in the list to be the same type.
    - Simplify state (input variations) `"Int:Int"` (The `"2:00"` problem)

    Only use `Result.andThen` for a single data point:

    - Avoid chaining `Result`s together. It makes life complected.
    - `Result.map` only goes up to FIVE arguments (`.map6` doesn't exist)
    - If `Song` had 7 fields, the `Result.map` might need to be 3 levels
      deep, which adds complexity (how to pass a `Song` to a `Song`?!)


    ----------------------------------------------------------------------------
    The previous version looked like this (storing `Result`). You shouldn't be
    storing computed data like this:

        type alias Validate a
            = Result String a

        type alias UserInput a
            = { input : String
              , valid : Validate a
              }

        - @ [Songs first version](https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/Songs.elm)
        - @ [Songs alt `UserInput` type](https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/SongsAlt.elm)
        - @ [Failed experiments](https://github.com/badlydrawnrob/elm-playground/blob/71fda7d64bc716665b8fbe5b1230b41fcb17dedf/how-to-elm/src/CustomTypes/SongsEditable.elm)

    ----------------------------------------------------------------------------

    The sentence method
    -------------------
    > Using the sentence method to break down the problem:

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
    > See `Films` for more advanced wishlist items.

    1. #! Our latest `Song` is added to the FRONT of the list.
        - We likely want to add it to the BACK of the list!
    2. Give the form different states:
        - `Insert | Edit ID | Delete` modes (to edit the songs)
        - What happens if `NoAlbum`? Or MULTIPLE Albums?
        - `Album` is going to cause you problems (for delete, sort, etc) because
          `firstSong` needs concatonation or destructuring on every album save.
            - #! `List Song` would be FAR easier!
        - Is using the same form a risk? (is type safe changes enough?)
    3. Pull/Push to an API. Keep it simple for now.
        - Should ALWAYS have at least one `Song` in the `Album`.
        - Do you update the `Album` straight away? (on EVERY song change)

    Errors
    ------
    > We're using `Result.mapX` here, not @rtfeldman's Elm Spa method.

    You might find it easier to use `Result.Extra.andMap` if your `Song` has many
    fields. That's easier than chaining `Result.map` or using `andThen`. If a
    package has a `.mapX` function, it'll probably have a package.extra with an
    `andMap` function.

        @ https://ellie-app.com/vnfwMpHjwd8a1

    It may be wiser to use @rtfeldman's validation style, as we generate a
    `List String` of errors from `ValidField` types (such as `Email | Password`).
    If the error list is empty, you can save the form and generate a `Song`. He
    doesn't use a `Result` type at all!

        @ https://tinyurl.com/rtfeldman-elm-spa-login

    You'll still have the issue of returning multiple errors per `ValidField`
    however (you could simply have every `if` branch with a generic error message).

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

composeAllSongs : List Song -> Album
composeAllSongs songs =
    Debug.todo "This would be super helpful when using list functions"

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
        , p [] [ viewError isEmpty title ]
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
        , p [] [ viewError isYear year ]
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

{- We only care (return) if it's an error ...
Remember the value that changes the most should come last! -}
viewError : (String -> Result String a) -> String -> Html msg
viewError check value =
    case (check value) of
        Ok _ ->
            text ""

        Err error ->
            text error



-- Update ----------------------------------------------------------------------
-- (1) This doesn't save us much, other than an extra `Msg` type
-- (2) Mock some of the data for now (imagine all our validation funcs are done)
-- (3) Be careful of Ai hallucinations! It wrote the `Album _ songs ->` branch
--     as `Album song (song :: songs)` which gave duplicate entries!

update : Msg -> Model -> Model
update msg model =
    let
        songRecord = model.currentSong -- #! `model.record` can't update record directly!
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

        {- #! (1) -}
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

{- (2) -}
isValidSong : Form -> Result String Song
isValidSong { title, artist, album, year, minutes, seconds } =
    Result.map5 Song -- Here we could also use `Result.Extra.andMap`
        (isEmpty title)
        (Ok (String.trim artist))
        (Ok (String.trim album))
        (isYear year) <|
            (Result.map2 (\mins secs -> (mins, secs))
                (Ok (Maybe.withDefault 0 (String.toInt minutes)))
                (Ok (Maybe.withDefault 0 (String.toInt seconds))))

{- #! (3) -}
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
