module CustomTypes.Songs exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type (see `CustomTypes.md` for notes)
    ============================================================================
    Questions raised in this test:

    ONE Data type per `Result` would make life easier (with one function to
    check each data type's errors)

        1. We're converting `String.toInt` in more than one place.
            - Convert this into a helper function?
            - Should we only convert each field ONCE?
            - Example:
                - Convert at the point of error check
                - Store the `Int` someplace (or pass it with `Result.andThen`)
                - Retrieve our `Int` in a record (or an `Ok Int`)
        2. Our error messages aren't stored, only ONE is shown:
            - We'll only get an error for ONE of the fields.
            - What happens if we have TWO fields with an error?
        3. The `runErrorChecks` is a bit of a mess:
            - We're using a `Bool` in one place and `Result` in another
            - Better to be consistant with our field errors?
        4. Our `Tuple` may be overkill
            - It requires unpacking or `Tuple.pair`
            - Which leads to kind of verbose code
            - When is a `Tuple` absolutely necessary?
            - Where does it excel?
        5. (This is hard to explain) In general how do we pass state around?
            - In which functions do we check it?
            - In which functions do we modify it?
            - Can we pass another `Msg` like `SaveSong` after `ClickedSave`?
            - Can we narrow the types in `Update` so we're only taking in
              the song variables required to validate the fields?
            - Should this happen in a helper function _BEFORE_ we click save?
            - Result seems a bit unwieldy for lots of possible error messages
        6. How do we start narrowing our data types?
            - Splitting out our `Msg` for a `Form` messages
            - Giving our functions ONLY what they really need.
        7. See "What messages are for" here:
            - @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5


    Things to consider
    ------------------
    1. TIME YOURSELF! How long did the thing take?
    2. Do we handle joining the `first` and `rest` of `Album` in ONE single func?
    3. Is the `Tuple Int` for song runtime necessary, or just use two record fields?


    Is this Custom Type really a benefit over regular data?
    ------------------------------------------------------
    Only action what you really need, right now.

        - A list of song titles (which are strings)
        - The only extra information I need is the song time and an ID
        - They're not part of anything more (could've used an Album collection)
        - We _might_ be able to get away without an ID (use an Array?)
        - But an ID can be added as a `class` and sifted.

    From this description, a `List Record` might've been enough. Even a
    `List String` if we didn't need to edit them. What I've ended up with is
    something similar to `Random.Uniform` which is a bit different from a `List`.


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Before you start coding — sketch the damn thing out! The general rule seems
    to be: use `Maybe` for data that is optional, but DON'T store default data
    in json, just leave it out.

    1. Edit a Song with a form
    2. Edit the Album Song order
    3. We're currently converting `Album` to a list ...
       - Might we need a ONE Song view?

    Nice to have but not important:

    1. Album title
    2. Youtube or audio of the song (like a playlist)

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_, value, placeholder)
import Html.Events exposing (onInput, onSubmit)
import Debug

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

{- This represents `minutes` and `seconds`.
A Tuple requires unpacking, so might not be the best representation -}
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

{- The big difference with this custom type is that
it caters for a singleton, as well as "does not exist" -}
type Album
    = NoAlbum
    | Album Song (List Song)

{- Some caveats here. A Song doesn't really need an ID,
but I might want to delete a Song, so we have to have some
way of referencing the correct song to delete! -}
type alias Model
    = { currentID : SongID -- for keeping ID up-to-date
      , currentSong : SongTitle
      , currentMins : String
      , currentSecs : String
      , fieldError : String
      , album : Album
      }

{- It might be better to use `Maybe` here rather than default data.
In any event, we've got to sanitise the data first. What checks do we need?
-}
init : Model
init =
    { currentID = SongID 0
    , currentSong = ""
    , currentMins = ""  -- Stick to simple data until `Result`
    , currentSecs = ""  -- Stick to simple data until `Result`
    , fieldError = ""    -- We're ONLY checking for errors in `SongTime`
    , album = NoAlbum
    }


-- Update ----------------------------------------------------------------------

type Msg
    = UpdateCurrentInput String String
    | ClickedSave
    | SaveSong


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCurrentInput "song" title ->
            { model | currentSong = title }

        UpdateCurrentInput "time (minutes)" mins ->
            { model | currentMins = mins }

        UpdateCurrentInput "time (seconds)" secs ->
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








-- HERE IS WHERE I STOP AND RETHING THINGS!!! ----------------------------------
-- This should really only happen in ONE place in the program?
unpackMaybeInt : Maybe Int -> Int
unpackMaybeInt int =
    case int of
        Nothing -> Debug.todo "Surely there's a better way ..."
        Just _  -> Debug.todo "To unpack these in a single location?"

--------------------------------------------------------------------------------







-- Error checking --
-- We're using the example from `HowToResult.FieldErrorRevisited`, but we're
-- NOT storing our user input as a `Tuple` because it requires more work (having
-- to unpack and pack the `Tuple` everytime the value is changed). Let's ONLY
-- zip it as a tuple if (and ONLY if) the `Result` comes back as `Ok`.

checkEmpty : String -> Bool
checkEmpty =
    String.isEmpty

{- Non negative numbers -}
checkMinutes : Int -> Bool
checkMinutes mins =
    mins > 0 && mins <= 10

checkSeconds : Int -> Bool
checkSeconds secs =
    secs >= 0

{- I decided to NOT return the values (or a Song) and simply to return a `String`
for both `Err` and `Ok`. If we have LOTS of values, the only way I can see this
working is to have a record field for each `Ok data` per input.

This function is less than ideal. We're checking 3 errors here: for
an empty string (`Bool`), for a number (`Result`), and range of numbers (`Result`).
We're mixing methods here. `Result.andThen` is useless as it's best for dealing
with ONE (and only one?) data type with multiple error checking.

Unfortunately there's many ways to do forms. What would be the easiest route
to check errors and build a `Song` type if error free? -}
runErrorChecks : SongTitle -> String -> String -> Result String String
runErrorChecks title mins secs =
    let
        checkErrors =
            if checkEmpty title then
                runTimeErrorChecks mins secs
            else
                Err "Song field must not be empty"
    in
    {- #! I think I'm chaining these `Result` types together wrong -}
    case checkErrors of
        Err str -> Err str
        {- Rather than return data, we're returning a `String` here -}
        Ok str -> Ok str

runTimeErrorChecks : String -> String -> Result String String
runTimeErrorChecks mins secs =
    let
        minutes = checkTime checkMinutes mins
        seconds = checkTime checkSeconds secs
    in
    {- #! This is awful, but will stick with it for now! -}
    case (minutes, seconds) of
        (Err _, Err _) -> Err "Minutes and seconds fields are broken"
        (Err _, Ok _)  -> Err "Minutes is broken"
        (Ok _, Err _)  -> Err "Seconds is broken"
        (Ok _, Ok _)   -> Ok "All is well" -- We could've data here (Tuple)


{- Because both the time `Result`s are almost identical, let's abstract the func.
In real life, this might not be so helpful without a distinct error message,
but we could always add an argument for that later ... -}
checkTime : (Int -> Bool) -> String -> Result String String
checkTime func int =
    case String.toInt int of
        Nothing ->
            Err "Input requires a number"

        Just num ->
            if func num then
                Ok "Number is OK"
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

viewForm : String -> SongID -> SongTitle -> String -> String -> Html Msg
viewForm error _ title mins secs =
    form [ class "form-songs", onSubmit ClickedSave ]
            [ p [ class "form-errors"]
                [ text error ]
            , input
                [ type_ "text"
                , placeholder "Add a song title"
                , value title
                , onInput (UpdateCurrentInput "song")
                ]
                []
            , div [ class "input-group" ]
                [ input
                    [ type_ "text"
                    , placeholder "Add a song time (minutes)"
                    , value mins
                    , onInput (UpdateCurrentInput "time (minutes)")
                    ] []
                , input
                    [ type_ "text"
                    , placeholder "Add a song time (seconds)"
                    , value secs
                    , onInput (UpdateCurrentInput "time (seconds)")
                    ] []
                ]
            {- We could add disable to the button until ALL errors are fixed,
            but this would mean constantly checking our `Result` on every key
            stroke, which isn't ideal. See `Form.SingleField` for this approach -}
            , button [] [ text "Save" ]
            ]

{- A `Song` is a record. If our `List Song` is empty, just show an empty
list item. We're not interested in using a `Maybe` here. We could split out
our function to handle both our `Song` SINGLETON and our `List Song`, but for
now, let's simply concatonate them into a single list! -}
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
