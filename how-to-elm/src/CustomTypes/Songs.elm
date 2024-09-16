module CustomTypes.Songs exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type
    ============================================================================
    Questions raised in this test:

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
        5. (This is hard to explain) How do we pass state around in `Update`?
            - Narrowing types to only take song variables
            - So that we can check them with an error function
            - Which returns a `Msg` telling `Update` to `SaveSong`
            - Is this the wrong way to do things?

    Always ask:
    -----------
    1. Have I scoped the problem and sketched it out?
    2. What problems have I discovered? What routes?
    3. Do we _really_ need this feature?
    4. Is this as simple as it can be? ('5 steps to reduce code')
        - We need to convert `Album` to a list ...
        - So we're not differentiating a single `Song` in our view
        - We _might_ want to enforce a singleton if saving to json
        - It's likely this could've been simplified to a `List Song`
    6. Have I accounted for ALL POSSIBLE STATES of my data?
        - An `Album Song []` for example.
        - We MUST make sure at least an empty list is provided there
        - A `SongTime` uses a `Tuple` ONLY when form is saved. This makes our
          inputs a bit easier to deal with.

    Don't use a custom type unless it's:
    ------------------------------------
    a) More explicit and better described data
    b) Easier to work with (make impossible states impossible)
    c) Better shaped than simple data (easier to reason about)


    First up a few rules:
    ---------------------
    1. Don't store default data or `null` in json
       - Simply handle it with `Maybe` in your application
       - Default data hides potential issues and mute errors
    2. `Maybe`s are just fine to use, but ...
       - Sometimes your own custom descriptive type is better
       - ONLY if it improves on simple data ..
       - Or makes impossible states (impossible)
    3. Reach for `Maybe.withDefault` LATE (at the very end)
       - For example, at the last moment in your `view`.
    4. For other custom types, you can reach for a codec ...
       - Codecs are fine for _transmitting_ the data. But you probably
         don't want to store it as is ...
       - Your custom types and `json` data can get out of sync VERY quickly,
         if you store them directly.
       - You'd have to version your custom types if you saved them as json.


    What's the benefit of a custom type over regular data?
    -----------------------------------------------------
    First it's best to really think about the type of data you
    actually need, and the best way to represent this. Only action what
    you REALLY need, right now (YAGNI):

        - It's a list of song titles (which are strings)
        - The only extra information I need is the song time and an ID
        - They're not part of anything more (could've used an Album collection)
        - We _might_ be able to get away without an ID (use an Array?)
        - But an ID can be added as a `class` and sifted.

    From this description, a `List Record` might've been enough. Even a
    `List String` if we didn't need to edit them. What I've ended up with is
    something similar to `Random.Uniform` which is a bit different from a `List`.

    What exactly is a `List`?
    -------------------------
    > A list is either empty, a single item, or many items.

        ["Get Back", "Afraid", "Californication"]

    Often, we'll only have to worry whether the item is empty or full,
    without having to concern ourselves with _how many_ items it holds.

    Sometimes, however, we might want to treat the list differently
    if it holds _only one_ item. A good example might be within our
    view. It's an `<ul>` if there's many items, but we might use a
    different element if it's just one item.

    What happens if we don't get a list at all?
    -------------------------------------------
    We're using `NoAlbum` with a custom type. Perhaps we have a `json` document,
    and we don't know ahead of time if this list is available. We could use
    `NoAlbum` for this possiblity, but we could've used `Maybe` too.

    - If there's no list in the `json` doc, we can set it to `Nothing`.
    - If there's a list there, we can set it to `Just []` (or a full list)

    The problem with either of these is that before we can deal with our list,
    we have to "climb the wall" so to speak, to "lift" or unpack the list. Only
    then can we check for empty, single, or a full list and start working with
    the data. `Maybe` gives us some ready made functions for this purpose. If we
    use a custom type, we have to write our own functions.

    Either way, all that lifting adds up and creates quite a bit of work for
    ourselves. I feel the best way is to unpack it in ONE place where possible.


    A couple of alternatives
    ------------------------

    We could use a Collection, which is a good case for a custom type.
    For instance, an `Album` with an ID could look like this:

        ```
        {
          "Album"        : "Californication",
          "album_id"     : 1,
          "album_tracks" : ["Californication", "..."]
        }
        ```

    We'd still need to figure out the eventuality of "Album not found", which
    may also call for a `Maybe` type. But if the album is found, we could
    generally predict it wouldn't have an empty list. We'd have to make
    sure we have control over our data to remove that possibility.


    A (failed) simpler version
    --------------------------

    The original custom type I tried looked like this:

        type Entries = NoEntries | Entries (List Entry)

    Where `Entry` is a record. This took much trial and error to get right!
    The problem is IT DOES NOT HELP US THAT MUCH!
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    We still have to do everything we'd do with a `Maybe` (check for `Nothing`,
    unwrap the `Just`, etc) and we don't have the added benefit of all those
    helper functions that `Maybe` gives us (we'd have to create them):

        `Maybe.withDefault` and `Maybe.map runSomeFunction (Just "String")`


    ----------------------------------------------------------------------------
    Things to consider
    ----------------------------------------------------------------------------
    1. TIME YOURSELF! How long did the thing take?
    2. Do we handle joining the `first` and `rest` of `Album` in ONE single func?
    3. Is the `Tuple Int` for song runtime necessary, or just use two record fields?


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Before you start coding — sketch the damn thing out! Follow the rules and
    questions above! The general rule seems to be: use `Maybe` for data that is
    optional, but DON'T store default data in json, just leave it out.

    1. Edit a Song with a form
    2. Edit the Album Song order
    3. We're currently converting `Album` to a list ...
       - Might we need a ONE Song view?
    4. Error checks (keeping it simple)
       - Non-empty `SongTitle`
       - `SongTime` must be positive number
       - `00` for minutes must be rendered as a string
       - `SongId` must be unique (package for `UUID`?)

    Nice to have but not important:

    1. Album title
    2. Youtube or audio of the song (like a playlist)

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_, value, placeholder)
import Html.Events exposing (onInput, onSubmit)
import Debug
import Json.Decode exposing (int)
import HowToResult.FieldError exposing (runErrorCheck)

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
            runErrorChecks model.currentSong model.currentMins model.currentSecs

        SaveSong ->
            { model
            | currentID = (createID model.currentID)
            , currentSong = ""
            , currentMins = ""
            , currentSecs = ""
            , fieldError = ""
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

{- I think this function is less than ideal. We're checking 3 errors here: for
an empty string, for a number, and range of number. One error is a simple `Bool`
in an if statement, the other two are chaining errors in a `Result.andThen`.
Unfortunately there's many ways to do forms, but what would be the easiest route
to check errors and build a `Song` type if error free? -}
runErrorChecks : SongTitle -> String -> String -> Result String Song
runErrorChecks title mins secs =
    let
        checkErrors =
            if checkEmpty title then
                checkTime checkMinutes mins
                    |> Result.andThen (checkTime checkSeconds secs)
            else
                Err "Song field must not be empty"
    in
    case checkErrors of
        Err str -> str
        {- Is it OK to do this? We discard the `Result` payload and send a new
        message. This probably wouldn't work if we started narrowing the types
        within our update function. -}
        Ok _ -> SaveSong


{- Because are time `Result` are almost identical, let's abstract the func.
In real life, this might not be so helpful without a distinct error message,
but we could always add an argument for that later ... -}
checkTime : Int -> (Int -> Bool) -> Result String Int
checkTime func int =
    case String.toInt int of
        Nothing ->
            Err "Input requires a number"

        Just num ->
            if func num then
                Ok num
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
                , viewForm model.currentID model.currentSong model.currentMins model.currentSecs
                , viewSongs first rest
                ]

viewForm : SongID -> SongTitle -> String -> String -> Html Msg
viewForm _ title mins secs =
    form [ class "form-songs", onSubmit ClickedSave ]
            [ input
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
    Debug.todo "create if/else edit state"

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
