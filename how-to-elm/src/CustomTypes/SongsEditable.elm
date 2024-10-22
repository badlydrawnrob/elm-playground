module CustomTypes.SongsEditable exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type (see `CustomTypes.md` for notes)
    ============================================================================
    This started out as an alternative for a `Maybe List`. Remember that the
    simplest thing possible is often the best solution. If you don't need
    complexity — don't add it!

    We have a couple of options for our model:
    ------------------------------------------
    For now I'm sticking with the nested record approach, and I'm only expecting
    an `ID` for the `Album`, not the `Song` (just use the `Song.title`)

        @ Songs.elm    (nested record)
        @ SongsAlt.elm (custom `UserInput` type)

    Learning points
    ---------------
    I'm using a record here for `UserInput` rather than a custom type. The benefit
    of a custom type is that it's FLATTER (no cranky nested record update function),
    but the benefit of a record is it's accessor `.valid` `.input` etc. They almost
    balance each other out, so it's a matter of preference.

    @ https://www.diffchecker.com/me6aANHb/

    1. `Msg` is for CARRYING DATA and NOT for changing state
        - @ https://discourse.elm-lang.org/t/message-types-carrying-new-state/2177/5
    2. Lift `Maybe` in ONE place when possible
    3. Look how `Song` is created; `updateAlbum` is simply passed a `Song`.
    4. A `Tuple` adds some complexity.
        - UserInput is way easier _without_ a `Tuple`.
    5. Remember the roles of `Msg`, `Update`, `View` and put functions in right place!
    6. Validating forms is a bit of a minefield. Just get something working.
        - There's many ways to do it
        - @ https://tinyurl.com/the-elm-way-to-validate-form
    7. Remember the `2.0` fiasco. Simplify data entry at source.
        - The fewer state possibilities, the better (in general)
    8. Simplify your state wherever possible:
        - See "The 5 ways to reduce code"
    9. Nested records are OK in moderation, but prefer a flatter style ...
        - You could easily just write a big record with more fields.
        - A custom type can reduce the need for records, but makes code slightly
          harder to read (syntax highlighting on `song.error` but not `songError`)
        - They also need deconstructing, which can add a little bulk to a function.
    10. More on Nested Records (and ways to do it)
        - @ https://discourse.elm-lang.org/t/updating-nested-records-again/1488
        - @ https://tinyurl.com/elm-spa-nested-login (using lambda and function)
        - @ https://tinyurl.com/elm-lang-why-not-nested
        - @ https://tinyurl.com/elm-spa-custom-types-eg
    10. Chaining `Result`s seems like a bad idea (see `HowToResult/FieldError`)
        - Only use `Result.andThen` for a single data point (it seems to me)
    11. The program (and data) FLOW should be as SIMPLE as possible:
        - Can you re-read it and tell EXACTLY what's going on?
        - I certainly can't do that quickly with `HowToResult/FieldError`


    Questions
    ---------
    Is this the best way to structure the `Model`? Should I just keep it simple,
    without custom types? One big record?!

    1. I could've used `Album { id = ..., song = Song }` instead of params.
       - What's the benefit of using a record in a custom type over arguments?
       - I've heard that a function should have as few parameters as possible.
       - I also understand the benefit of typed stuff like `FirstName String`.
    2. Can I create just ONE `getID` for `SongID` and `AlbumID`?
    3. How do you `.map` over a bunch of user inputs if they're different types?

    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Currently ALL fields are required. I'll need to add in optional fields also.
    You might also want to take another look at other routes for form validation.

    1. Need to set the `AlbumID` correctly if pulling in from the server
    2. Strip spaces from front/back of `String`s before saving
    3. Preview media (album image, video url, etc)
    4. Editable `Song`s
    5. Delete a `Song`?
    6. Edit `Song` order?
    7. Reduce repetition in the view (`viewInput` function etc)
    8. Post to `jsonbin` (can we limit it to only my URL?)
       - MUST contain at least ONE song

    Other things to consider in future

        1. Use proper `Url` instead of `String`?
        2. Validate only on save
        3. Pull in from an API (openlibrary)
        4. Splitting out components/messages/etc
        5. Only ONE `Song`?
-}

import Debug
import File.Download exposing (url)



-- Model -----------------------------------------------------------------------
-- #! Aim for the simplest thing possible that could work BEFORE thinking about
--    more complicated setup (which will be needed eventually)
--
--    Album could be one of NewAlbum, EditAlbum, DeleteAlbum.
--    Song could be one of NewSong, EditSong, DeleteSong.
--    we also need to load it from `json` and update it by `json`.
--    we might eventually need a `Status` (loading/loaded/failed/etc)
--    should I just generate a `uuid` for album/song?
--
--    You also have the option of referencing a song by NAME or ID.
--    It might not be essential for each song to have it's own ID.
--    Check if name already exists in (List Song) as protection!

type AlbumID =
    AlbumID Int

type alias AlbumTitle =
    String

getAlbumID : AlbumID -> Int
getAlbumID (AlbumID id) =
    id

type Album =
    Album AlbumMeta AlbumSongs

type alias AlbumMeta =
    { id : AlbumID
    , title : AlbumTitle
    , image : String
    }

{- `AlbumSongs` MUST hold at least one `Song` -}
type AlbumSongs =
    AlbumSongs Song (List Song)

type alias SongTitle =
    String

type alias RunTime =
    (Int, Int)

type alias Song
    = { title : SongTitle
      , time  : RunTime
      , youtube : Maybe String  -- Optional YouTube link
      }

type alias Validate a
    = Result String a

{- This could've been a custom type -}
type alias UserInput a
    = { input : String
      , valid : Validate a
      }

{- A default `UserInput` if the field is required -}
initUserInput = { input = "", valid = Err "Field cannot be empty" }

type AlbumStatus
    = NewAlbum
    | EditAlbum AlbumID
    | EditSong AlbumID SongTitle

{- #! I need to handle the AlbumID and the SongID -}
type alias Model =
    { albumID : AlbumID
    , albumTitle : UserInput String
    , albumImage : String
    , songTitle : UserInput String
    , minutes : UserInput Int
    , seconds : UserInput Int
    , youtube : UserInput String
    , albums : List Album
    , status : AlbumStatus
    }

init : Model
init =
    { albumID = AlbumID 0 -- #! Reset if get from server
    , albumTitle = initUserInput
    , albumImage = { input = "", valid = Ok "" } -- Not required
    , songTitle = initUserInput
    , minutes = initUserInput
    , seconds = initUserInput
    , youtube = { input = "", valid = Ok "" } -- Not required
    , albums : [] -- #! Reset if get from server
    , status = NewAlbum
    }




-- Update ----------------------------------------------------------------------

type Msg
    = EnteredInput String String
    | ClickedSaveAlbum
    | ClickedEditAlbum AlbumID
    | ClickedEditSong AlbumID SongTitle
    | ClickedImageLink String

update : Msg -> Model -> Model
update msg model =
    let
        {- See notes for original link to do this -}
        updateInput record input valid =
            { record | input = input, valid = valid }
    in
    case msg of
        EnteredInput "AlbumTitle" title ->
            { model
                | albumTitle =
                    updateInput model.albumTitle title (isEmptyStr title) }

        ClickedAlbumImage url ->
            Debug.todo "Import the image file upload"

        EnteredInput "SongTitle" title ->
            { model
                | songTitle =
                    updateInput model.songTitle title (isEmptyStr title) }

        EnteredInput "SongMinutes" mins ->
            { model
                | minutes =
                    updateInput model.minutes mins (checkTime checkMinutes mins) }

        EnteredInput "SongSeconds" secs ->
            { model
                | minutes =
                    updateInput model.minutes secs (checkTime checkSeconds secs) }

        EnteredInput "YouTube" url ->
            { model
                | youtube =
                    updateInput model.minutes url (checkYouTube url) }


isEmptyStr : String -> Validate String
isEmptyStr s =
    if String.isEmpty s then
        Ok s
    else
        Err "Field cannot be empty"

checkTime : (Int -> Bool) -> String -> Validate Int
checkTime func s =
    case String.toInt s of
        Nothing -> Err "Field cannot be empty, must be a number"
        Just i  ->
            if func i then
                Ok i
            else
                Err "Number is not in range"

checkMinutes : Int -> Bool
checkMinutes mins =
    mins > 0 && mins <= 10

checkSeconds : Int -> Bool
checkSeconds secs =
    secs >= 0 && secs <= 60

{- A very basic url checker for now (you could switch to `elm/url`) -}
checkYouTube : String -> Validate String
checkYouTube url =
    if isYouTube url && isProperLink url then
        Ok url
    else
        Err "This isn't a proper YouTube link"

isYouTube : String -> Bool
isYouTube
    (String.contains "youtube.com") || (String.contains "youtu.be")

isProperLink : String -> Bool
    (String.contains "http://") || (String.contains "https://")


