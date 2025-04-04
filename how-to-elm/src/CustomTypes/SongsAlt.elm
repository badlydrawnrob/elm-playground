module CustomTypes.SongsAlt exposing (..)

{-| ----------------------------------------------------------------------------
    A simple `Album` custom type (✏️ see `CustomTypes.md` for notes)
    ============================================================================
    ⚠️ It's not a good idea to store computed data in your model! So this entire
       can be seen as a learning exercise. This example is very similar to
       `CustomTypes.Songs` but uses a custom type for user input.

    Nested Record version (without editable `Song`s)
        @ Songs.elm
    Original attempt:
        @ https://tinyurl.com/custom-type-songs-v01 (commit #a0ab8a0)
    "What messages are for":
        @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    Unpack (or "lift") `Maybe`s etc in ONE place:
        @ https://tinyurl.com/stop-unpacking-maybe-too-often
    Diff of `UserInput` here:
        @ https://www.diffchecker.com/me6aANHb/


    Problems
    --------
    1. `UserInput a` is kind of vague for our type signatures
       - The `Result`s value is either a `String` or an `Int`.
    2. `allValid` deconstructs values into a Tuple, which isn't ideal as the
       number of `UserInput` increases. Perhaps a `map` function would be better.

    What I learned
    --------------

    1. Check errors in ONE place
    2. Unpack (or "lift") `Maybe`s in ONE place where possible
    3. SPLIT the functions to create `Song` and `updateAlbum` (passing a `Song`)
    4. Why bother using a `Tuple`? For forms, two `Int`s are way easier.
    5. Think carefully which function performs which action ...
    6. And where in the codebase it should go (msg, update, view)
    7. There's A LOT of approaches to validating forms.
    8. SIMPLIFY DATA: `2.0` mins/secs has horrible artifacts (confusing functions)
    9. SIMPLIFY STATE
    10. Prefer a flatter model (without nested records) where possible
        - I've decided to try a custom type instead of a record in this version
        - But means that we don't have the handy `.valid` record accessors
        - @ https://discourse.elm-lang.org/t/updating-nested-records-again/1488
          (see @rtfeldman response)
    11. Chaining `Result`s (that isn't ONE data) can make for messy code
    12. Aim to make data and program-flow as SIMPLE as possible to re-read
    13. NESTED RECORDS are EASIER TO READ at-a-glance in the codebase with the
        current syntax highlighting (rather than a `UserInput` type) but ...
        - They DO make the model updates slightly shorter (NO NESTED RECORDS) ...
        - but the make our function arguments slightly longer, as they need
          deconstructing: `(UserInput var1 var2)`


    What we're looking to achieve:
    ------------------------------

    1. Alternative to a `Maybe List` (and `Album` type)
    2. Prepare for saving `Album`s to `json`
        - Any optional fields should simply NOT be stored in `json`
        - This might require them to be a `Maybe` type.
    3. Each input has it's own `Result` (this might not be ideal)
    4. Errors shown in-place, but validate on SAVE
    5. A `Song` can be edited (currently in the same form)

        Customer journey ...
        --------------------

        1. User inputs form field data
        2. On input, errors are checked and shown
        3. User can click save (even if errors are there)
            - We check for errors and return `model` if any `Err`
            - Use must clear all errors before `Song` is created
        4. All `Song`s are added to our `Album` type


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

        1. Is having a type alias with `Result String a` bad?
        2. Is `Result` a poor choice for a form with lots of fields?
        3. Can I split our the form `Msg` so it's self-contained?
        4. Handling `first` and `rest` of `Album` in a single function?
        5. Better data "flow" and usage of functions


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Sketch out the flow of the program BEFORE you start coding.
    How might it be simplified?

    1. Edit a `Song` with a form (but not the ID)
    2. `Album` title? (perhaps use a Collection)
    3. Have a `viewInput` function to avoid repetition?

        2. Delete a `Song`
        3. Edit the `Album` `Song` order
        4. Potentially change the view if only ONE `Song` ...
        5. YouTube or audio of the song?
        6. Count number of songs and display in heading
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_, value, placeholder)
import Html.Events exposing (onInput, onSubmit)

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
that data can come in many forms, so use a type variable. This may cause
problems in future as our forms grow. -}
type alias Validate a
    = Result String a

{- #! Take care of "unbound" variables. This can mean a type variable that
must be explicit when using type signatures (the `Result String a`) — this is
fine for now, because we're using `Validate` type signature in some places. -}
type UserInput a =
    UserInput String (Validate a)

getInput : UserInput a -> String
getInput (UserInput string _) =
    string

getValid : UserInput a -> Validate a
getValid (UserInput _ result) =
    result

initUserInput = UserInput "" (Err "Field is be empty")

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
    , currentSong = initUserInput
    , currentMins = initUserInput
    , currentSecs = initUserInput
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
            { model | currentSong = UserInput title (checkSong title) }

        EnteredInput "minutes" mins ->
            { model | currentMins = UserInput mins (checkTime checkMinutes mins) }

        EnteredInput "seconds" secs ->
            { model | currentSecs = UserInput secs (checkTime checkSeconds secs) }

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
    allValid model.currentID model.currentSong model.currentMins model.currentSecs

{- We check all fields are error free and CREATE THE SONG HERE!

#! Deconstruct all `Result` values into a `Tuple`. Check these are valid in one go.
`Tuple` maxes out at 3 items, so if we have more `UserInput` fields, we'd have to
change this (using a `map` function?) -}
allValid : SongID -> UserInput String -> UserInput Int -> UserInput Int -> Maybe Song
allValid id song mins secs =
    case ((getValid song), (getValid mins), (getValid secs)) of
        (Ok title, Ok minutes, Ok seconds) ->
            Just (Song id title (minutes, seconds))
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
    if String.isEmpty s then
        Err "Field cannot be empty"
    else
        Ok s

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
        {- We're currently adding the song to the front of the list, although
        you could just as well add it to the end. I don't think we need to check
        if the list is empty here. -}
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

{- #! Using a custom type becomes slightly harder here as we MUST (I think)
deconstruct it to extract it's values -}
viewForm : SongID -> UserInput String -> UserInput Int -> UserInput Int -> Html Msg
viewForm _ (UserInput title titleError) (UserInput mins minsError) (UserInput secs secsError) =
    form [ class "form-songs", onSubmit ClickedSave ]
            [ input
                [ type_ "text"
                , placeholder "Add a song title"
                , value title
                , onInput (EnteredInput "song")
                ]
                []
            , viewFormError titleError
            , div [ class "input-group" ]
                [
                    div [ class "collapse" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Add a song time (minutes)"
                            , value mins
                            , onInput (EnteredInput "minutes")
                            ] []
                        , viewFormError minsError
                        ]
                ,   div [ class "collapse" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Add a song time (seconds)"
                            , value secs
                            , onInput (EnteredInput "seconds")
                            ] []
                        , viewFormError secsError
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
