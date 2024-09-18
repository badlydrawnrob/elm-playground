module CustomTypes.Songs exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type (see `CustomTypes.md` for notes)
    ============================================================================
    Original attempt:
        @ https://tinyurl.com/custom-type-songs-v01 (commit #a0ab8a0)
    See also "What messages are for":
        @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5


    What we're looking to achieve:
    ------------------------------

        1. An alternative to a `Maybe List`
        2. Preparing ready to save a form to `json`
        3. Store `Err` messages with `Result`
        4. Display these in-place on the form
        5. To NOT store optional data as `json`
           - I've been told that's better. Just use a `Maybe` in your app.


    Solving other problems that arose in last attempt
    -------------------------------------------------

        1. Unpack `Maybe` types in ONE place (`String.toInt`)
        2. ONE data type per `Result` (not chaining 3 different types)
        3. Store that data type (so we convert it in ONE place)
        4. We can show EVERY input's error (but only ONE error per input)
        5. `runErrorChecks` was messy. Tidy up our code.
            - We were mixing error handling strategies (if `Bool` and `Result`)
        6. We create a `Tuple` ONCE and only once in our program
            - When is a `Tuple` needed? When is it not?
        7. Our data and state flow wasn't so easy to follow before.
            - Where in the code do we create a `Song`?
            - Where do we check for errors? How?
            - Could we pass two `Msg`: `ClickedSave` and `SaveSong`?
            - Can we narrow our types? In `Msg` too?
                - Only taking in the types needed to validate the fields


    Things we don't care about (for this attempt)
    ---------------------------------------------

        1. Displaying ALL errors for each data type
           - I don't think this is possible with `Result`
        2. We're not checking for errors on input (or `onBlur` when leaving
           an input field), but ONLY when button clicked.


    Things I don't know about
    -------------------------

        1. Is having a type alias with `Result String a` bad?
        2. Is `Result` a poor choice for a form with lots of fields?
        3. Can I split our the form `Msg` so it's self-contained?
        4. Handling `first` and `rest` of `Album` in a single function?


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Sketch out the flow of the program BEFORE you start coding.
    How might it be simplified?

    1. Edit a `Song` with a form (but not the ID)
    2. Delete a `Song`
    3. Edit the `Album` `Song` order
    4. Potentially change the view if only ONE `Song` ...
    5. `Album` title?
    6. YouTube or audio of the song?
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_, value, placeholder)
import Html.Events exposing (onInput, onSubmit)
import Debug

{- An ID comes in handy if you want to edit or delete a `Song` -}
type SongID
  = SongID Int

{- A simpler way to unpack the `Int` than using `case` -}
extractID : SongID -> Int
extractID (SongID num) =
    num

createID : SongID -> SongID
createID (SongID num) =
    SongID (num + 1)

type alias SongTitle
    = String

{- Represents `minutes` and `seconds`. Is a `Tuple` necessary? -}
type alias SongTime
    = (Int,Int)

extractMinutes : SongTime -> Int
extractMinutes (m,_) = m

extractSeconds : SongTime -> Int
extractSeconds (_,s) = s

{- We're adding more data than we need here -}
type alias Song
    = { songID : SongID
      , songTitle : SongTitle
      , songTime  : SongTime
      }

{- Custom type caters for empty, one, many -}
type Album
    = NoAlbum
    | Album Song (List Song)

{- #! We're using `Result` to gather errors and unpack data, but
that data can come in many forms, so use a type variable. -}
type alias Validate
    = Result String a

{- #! I'm not sure how best to write this. For now it's only `String` types,
but what if there's different types? Use `a` type variable? -}
type alias UserInput
    = { input : String
      , valid : Validate
      }

{- For now I'm not using aliases for user input -}
type alias Model
    = { currentID : SongID -- The only field that isn't a record
      , currentSong : UserInput
      , currentMins : UserInput
      , currentSecs : UserInput
      , album : Album
      }

{- #! Would it be better to use a bunch of `Maybe` here instead of default data?
I don't really like the idea of too many `Maybe`s as that's a lot to "lift". We
sanitise the data anyway, I guess. I'm keeping `SongTime` entries simple record
fields rather than a `Tuple`. It's easier to manage. -}
init : Model
init =
    { currentID = SongID 0
    , currentSong = { input = "", valid = Err "Field is empty" }
    , currentMins = { input = "", valid = Err "Field is empty" }
    , currentSecs = { input = "", valid = Err "Field is empty" }
    , album = NoAlbum
    }


-- Update ----------------------------------------------------------------------

type Msg
    = EnteredInput String String
    | ClickedSave
    -- | SaveSong


update : Msg -> Model -> Model
update msg model =
    case msg of
        EnteredInput "song" title ->
            { model | currentSong = title }

        EnteredInput "time (minutes)" mins ->
            { model | currentMins = mins }

        EnteredInput "time (seconds)" secs ->
            { model | currentSecs = secs }

        ClickedSave ->
            case (runErrorChecks model.currentSong model.currentMins model.currentSecs) of
                Err str ->
                    { model | fieldError = str }
                Ok _ ->
                    {- Here we're only saving the album (with a helper function)
                    if all errors have come back clean. We're building the Song
                    within that helper function. It might've been better to do
                    that with `Result`? -}
                    { model
                    | currentID = (createID model.currentID)
                    , currentSong = ""
                    , currentMins = ""
                    , currentSecs = ""
                    , fieldError = ""
                    {- I feel here should be entering the data we ACTUALLY need
                    in a way that's been unpacked (`Maybe Int`) -}
                    , album = updateAlbum model model.album
                    }


updateAlbum : Model -> Album -> Album
updateAlbum model album =
    case album of
        NoAlbum ->
            Album
                (Tuple.pair
                    (String.toInt model.currentMins) (String.toInt model.currenSongTimeSecs)
                    |> (Song model.currentID model.currentSong))
                []
        {- Do you want to add to the front, or end of the list? You could check
        here that the list isn't empty by using (first :: rest) but I ain't! -}
        Album first rest ->
            Album first
                ((Tuple.pair
                    (String.toInt model.currentMins) (String.toInt model.currentSecs)
                    |> (Song model.currentID model.currentSong)) :: rest)



-- Error checking --------------------------------------------------------------
-- I'm using `HowToResult.FieldErrorRevisited` as an example.

{- Non negative numbers -}
checkMinutes : Int -> Bool
checkMinutes mins =
    mins > 0 && mins <= 10

checkSeconds : Int -> Bool
checkSeconds secs =
    secs >= 0


{- My first attempt at this was to use ONE function to handle all errors with
`Result`. You could've potentially returned a `Ok Song` at the end of it ...
but it felt messy, so this time around, each input gets it's own `Result`. -}
checkSong : String -> Result String SongTitle
checkSong s =
    case String.isEmpty s of
        True  -> Err "Field cannot be empty"
        False -> Ok s

{- Let's abstract the function as both minutes and seconds are similar errors.
`String.toInt` will also check if empty as `Nothing`. We're also using the
`Result` to unpack the `Maybe Int` that we'd get from the string function! -}
checkTime : String -> Result String Int
checkTime func s =
    case String.toInt s of
        Nothing -> "Field cannot be empty, or not a number"
        Just i  ->
            if func i then
                Ok i
            else
                Err "Number is not in range"



-- View ------------------------------------------------------------------------
-- In this view, for `Album`, it's possible the state could be `Album Song []`,
-- where our `rest` has NO SONGS. I'm not currently accounting for that here.

view : Model -> Html Msg
view model =
    case model.album of
        NoAlbum ->
            h1 [] [ text "No album has been added" ]

        {- If this was a `Maybe List` you could unpack the list
        by using destructuring, like: `Just (first :: rest)` -}
        Album first rest ->
            div [ class "album" ]
                [ h1 [] [ text "An album with no name" ]
                , viewForm model.fieldError model.currentID model.currentSong model.currentMins model.currentSecs
                , viewSongs first rest
                ]

viewForm : SongID -> UserInput -> UserInput -> UserInput -> Html Msg
viewForm _ title mins secs =
    form [ class "form-songs", onSubmit ClickedSave ]
            [ input
                [ type_ "text"
                , placeholder "Add a song title"
                , value title.input
                , onInput (EnteredInput "song")
                ]
                []
            , viewFormError title.valid
            , div [ class "input-group" ]
                [ input
                    [ type_ "text"
                    , placeholder "Add a song time (minutes)"
                    , value mins.input
                    , onInput (EnteredInput "time (minutes)")
                    ] []
                , viewFormError mins.valid
                , input
                    [ type_ "text"
                    , placeholder "Add a song time (seconds)"
                    , value secs.input
                    , onInput (EnteredInput "time (seconds)")
                    ] []
                , viewFormError secs.valid
                ]
            {- We could add disable to the button until ALL errors are fixed,
            but this would mean constantly checking our `Result` on every key
            stroke, which isn't ideal. See `Form.SingleField` for this approach -}
            , button [] [ text "Save" ]
            ]

viewFormError : Validate -> Html Msg
viewFormError valid =
    case valid of
        Err str -> p [ class "form-error" ] [ text str ]
        Ok _ -> text ""

{- A `Song` is a record. If our `List Song` is empty, just show an empty
list item. We're not interested in using a `Maybe` here. We could split out
our function to handle both our `Album Song []` (singleton) and
`Album Song (List Song)` but for now, just concatonate into one list! -}
viewSongs : Song -> List Song -> Html Msg
viewSongs song lsong =
    ul [ class "album-songs" ] List.map viewSong (song :: lsong)

viewSong : Bool -> Song -> Html Msg
viewSong _ song =
    li [ class "album-s-song" ]
        [ text (song.songTitle ++ "(time: " ++ song.songTime ++ ")") ]



-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
