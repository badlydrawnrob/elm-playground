module CustomTypes.Songs exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type (see `CustomTypes.md` for notes)
    ============================================================================
    Original attempt:
        @ https://tinyurl.com/custom-type-songs-v01 (commit #a0ab8a0)
    See also "What messages are for":
        @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    Unpack (or "lift") `Maybe`s etc in ONE place:
        @ https://tinyurl.com/stop-unpacking-maybe-too-often


    What I learned
    --------------
    It's way easier to check errors in one place, build a `Song` in one place,
    and `updateAlbum` without creating a `Song` in that function. It's way easier
    to just use a simple `String` in `UserInput` rather than a `Tuple`. At times
    I'm not sure which function should do which action, and where in the program
    these functions should be. There's a LOT of approaches to forms and validation.

        1. Stupid (data) decisions upfront have HORRID artifacts:
           - @ https://tinyurl.com/songs-v1-possible-states (commit c25d389)
           - If there's LOTS OF STATE then FUCKING CHANGE IT!
        2. Unpack `Maybe` in ONE place
        3. It's easier to split the `Song` creation (if no errors) ...
        4. And have an `updateAlbum` action (if there's a `Song`) ...
        5. Than combining those actions into ONE `updateAlbum` function
           - @ 5d419efd9740fd891a21b299f7468a133c61bf64
        6. Updating nested records (prefer a flatter model)
           - @ https://discourse.elm-lang.org/t/updating-nested-records-again/1488
           - See @rtfeldman's response to the above thread



    What we're looking to achieve:
    ------------------------------

        1. An alternative to a `Maybe List`
        2. Preparing ready to save a form to `json`
        3. Store `Err` messages with `Result`
        4. Display these in-place on the form
        5. To NOT store optional data as `json`
           - I've been told that's better. Just use a `Maybe` in your app.

        Here's the steps:
        -----------------

        1. User inputs form field data
        2. On input, check for errors
        3. Save `Result` to `UserInput` record
        4. When save button is clicked ...
        5. Check if all errors are clean
        6. If so, create a `Song` ...
        7. And create (or update) our `Album`.


    Solving other problems that arose in last attempt
    -------------------------------------------------

        1. Unpack `Maybe` types in ONE place (`String.toInt`)
        2. ONE data type per `Result` (not chaining 3 different types)
        3. Store that data type (so we convert it in ONE place)
        4. We can show EVERY input's error (but only ONE error per input)
        5. `runErrorChecks` was messy in the last version. Tidy up our code.
            - We were mixing error handling strategies (if `Bool` and `Result`)
        6. We create a `Tuple` ONCE and ONLY ONCE in our program
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
        2. We probably should only check errors ON CLICK BUTTON,
           especially if there's lots of fields?
        3. `SongTitle` can be absolutely anything. We're also
           not stripping empty space.


    Things I don't know yet ...
    ---------------------------

        1. Are nested records undesirable?
        2. Is having a type alias with `Result String a` bad?
        3. Is `Result` a poor choice for a form with lots of fields?
        4. Can I split our the form `Msg` so it's self-contained?
        5. Handling `first` and `rest` of `Album` in a single function?
        6. Better data "flow" and usage of functions


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Sketch out the flow of the program BEFORE you start coding.
    How might it be simplified?

    1. Edit a `Song` with a form (but not the ID)
    2. Delete a `Song`
    3. Edit the `Album` `Song` order
    4. Potentially change the view if only ONE `Song` ...
    5. `Album` title? (perhaps use a Collection)
    6. YouTube or audio of the song?
    7. Count number of songs and display in heading
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

{- Using functional composition `<<` operator -}
songIDtoString : SongID -> String
songIDtoString = String.fromInt << extractID

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

songTimeToString : SongTime -> String
songTimeToString (m,s) =
    String.concat
        [ String.fromInt m
        , "mins "
        , String.fromInt s
        , "secs"
        ]

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
that data can come in many forms, so use a type variable. Is this going
to potentially cause problems in future? -}
type alias Validate a
    = Result String a

{- #! What the fuck is an "unbound" type variable?
   #! I'm not sure how best to write this. For now it's only `String` types,
but what if there's different types? Use `a` type variable? -}
type alias UserInput a
    = { input : String
      , valid : Validate a
      }

initUserInput = { input = "", valid = Err "Field cannot be empty" }

{- For now I'm not using aliases for user input -}
type alias Model
    = { currentID : SongID -- The only field that isn't a record
      , currentSong : UserInput String
      , currentMins : UserInput Int
      , currentSecs : UserInput Int
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
    let
        {- #! NESTED RECORDS is a problem. I think Elm
        discourages this. See the notes and links at the
        top of this file. You can't update in the way you'd
        think you could :( -}
        updateInput record input valid =
            { record | input = input, valid = valid }
    in
    case msg of
        EnteredInput "song" title ->
            { model
                | currentSong =
                    updateInput model.currentSong title (checkSong title) }

        EnteredInput "minutes" mins ->
            { model
                | currentMins =
                    updateInput model.currentMins mins (checkTime checkMinutes mins) }

        EnteredInput "seconds" secs ->
            { model
                | currentSecs =
                    updateInput model.currentSecs secs (checkTime checkSeconds secs) }

        EnteredInput _ _ ->
            model

        ClickedSave ->
            -- 1. [x] Check each input
            -- 2. [x] Each input has it's own error checking function
            -- 3. [x] Now check if there's any errors in each `.valid`
            -- 4. [x] Where do I add `Ok data` to? `.valid`?
            --    - We add it to the valid record field for each UserInput
            -- 5. [x] If everything comes back clean, use the data ...
            --    - Handled in the case statement function
            --    - 6. To create a `Song` ...
            -- 7. And add it to an `Album` :)
            --    - Handled in the `Just song` branch with update helper

            case runErrorsAndBuildSong model of
                Nothing ->
                     model
                Just song ->
                    {- All `.valid` fields have come back without any errors.
                    we can now build our `Song` and pass it over to `updateAlbum`,
                    and reset all the things, ready for a new form. -}
                    { model
                    | currentID = (createID song.songID) -- Add one
                    , currentSong = initUserInput
                    , currentMins = initUserInput
                    , currentSecs = initUserInput
                    {- #! I'm sure I could narrow the types here better? How do
                    we provide lots of arguments in a nicer way? -}
                    , album = (updateAlbum model.album song)
                    }


runErrorsAndBuildSong : Model -> Maybe Song
runErrorsAndBuildSong model =
    getValid model.currentID model.currentSong model.currentMins model.currentSecs

{- Pulls valid field from each `UserInput` and contstructs `Song` if no error.
#! What happens if we have lots of fields? That's too many inputs! -}
getValid : SongID -> UserInput String -> UserInput Int -> UserInput Int -> Maybe Song
getValid id song mins secs =
    case (song.valid, mins.valid, secs.valid) of
        (Ok songTitle, Ok minutes, Ok seconds) ->
            Just (Song id songTitle (minutes, seconds))
        _ ->
            Nothing

-- Error checking --------------------------------------------------------------
-- Previously using ONE function to handle all errors and chaining `Result`,
-- thinking that I could output `Ok Song` at the end of it. It was a mess.
--
-- This version is WAY easier to think about than that. ONE `Result` for each
-- input data. See also `HowToResult.FieldErrorRevisited` for a reference.


{- #! I'm using `Validate a` type alias rather than `Result String SongTitle`
here ... is that going to cause problems? -}
checkSong : String -> Validate String
checkSong s =
    case String.isEmpty s of
        True  -> Err "Field cannot be empty"
        False -> Ok s

{- Let's abstract the function as both minutes and seconds are similar errors.
`String.toInt` will also check if empty as `Nothing`. We're also using the
`Result` to unpack the `Maybe Int` that we'd get from the string function! -}
checkTime : (Int -> Bool) -> String -> Validate Int
checkTime func s =
    case String.toInt s of
        Nothing -> Err "Field cannot be empty, must be a number"
        Just i  ->
            if func i then
                Ok i
            else
                Err "Number is not in range"

{- Non negative numbers -}
checkMinutes : Int -> Bool
checkMinutes mins =
    mins > 0 && mins <= 10

checkSeconds : Int -> Bool
checkSeconds secs =
    secs >= 0 && secs <= 60


{- Finally, if there are NO errors, we can add the `Song` to the album! -}
updateAlbum : Album -> Song -> Album
updateAlbum album song =
    case album of
        NoAlbum ->
            Album song []
        {- Do you want to add to the front, or end of the list? You could check
        here that the list isn't empty by using (first :: rest) but I ain't! -}
        Album first rest ->
            Album first (song :: rest)


-- View ------------------------------------------------------------------------
-- In this view, for `Album`, it's possible the state could be `Album Song []`,
-- where our `rest` has NO SONGS. I'm not currently accounting for that here.

view : Model -> Html Msg
view model =
    case model.album of
        NoAlbum ->
            div [ class "wrapper empty"]
                [ h1 [] [ text "No album has been added" ]
                , initForm model
                ]
        {- If this was a `Maybe List` you could unpack the list
        by using destructuring, like: `Just (first :: rest)` -}
        Album first rest ->
            div [ class "wrapper" ]
                [ h1 [] [ text "An album with no name" ]
                , initForm model
                , viewSongs first rest
                ]

initForm : Model -> Html Msg
initForm model = viewForm model.currentID model.currentSong model.currentMins model.currentSecs

{- #! I could probably reduce duplication here and create `viewInput` func -}
viewForm : SongID -> UserInput String -> UserInput Int -> UserInput Int -> Html Msg
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
                [
                    div [ class "collapse" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Add a song time (minutes)"
                            , value mins.input
                            , onInput (EnteredInput "minutes")
                            ] []
                        , viewFormError mins.valid
                        ]
                ,   div [ class "collapse" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Add a song time (seconds)"
                            , value secs.input
                            , onInput (EnteredInput "seconds")
                            ] []
                        , viewFormError secs.valid
                        ]
                ]
            {- We could add disable to the button until ALL errors are fixed,
            but this would mean constantly checking our `Result` on every key
            stroke, which isn't ideal. See `Form.SingleField` for this approach -}
            , button [] [ text "Save" ]
            ]

viewFormError : Validate a -> Html Msg
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
    ul [ class "album" ] (List.map viewSong (song :: lsong))

{- #! We need to build an EDIT function into this later -}
viewSong : Song -> Html Msg
viewSong song =
    li [ class "album-song", class ("id-" ++ (songIDtoString song.songID)) ]
        [ text (song.songTitle ++ " (time: " ++ (songTimeToString song.songTime) ++ ")") ]



-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
