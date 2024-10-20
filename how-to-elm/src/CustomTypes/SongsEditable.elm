module CustomTypes.SongsEditable exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type (see `CustomTypes.md` for notes)
    ============================================================================
    This started out as an alternative for a `Maybe List`. Remember that the
    simplest thing possible is often the best solution. If you don't need
    complexity — don't add it!

    We have a couple of options for our model:
    ------------------------------------------
    For now I'm sticking with the nested record approach

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
        - @ https://tinyurl.com/elm-lang-why-not-nested
        - @ https://tinyurl.com/elm-spa-custom-types-eg
    10. Chaining `Result`s seems like a bad idea (see `HowToResult/FieldError`)
        - Only use `Result.andThen` for a single data point (it seems to me)
    11. The program (and data) FLOW should be as SIMPLE as possible:
        - Can you re-read it and tell EXACTLY what's going on?
        - I certainly can't do that quickly with `HowToResult/FieldError`


    Questions
    ---------
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

    1. An `Album` name
    2. An `Album` image
       - See `elm-spa` for splitting up / combining types
       - unique ID for the Album? (use `uuid` for songs?)
    3. More `Song` fields (the `Tuple` problem)
       - Strip spaces from front/back of `String`?
       - Song audio or video file/link
    4. Editable `Song`s
    5. Delete a `Song`?
    6. Edit `Song` order?
    7. Reduce repetition in the view (`viewInput` function etc)
    8. Post to `jsonbin` (can we limit it to only my URL?)
       - MUST contain at least ONE song

    Other things to consider in future

        1. Validate only on save
        2. Pull in from an API (openlibrary)
        3. Splitting out components/messages/etc
        4. Only ONE `Song`?
-}

import Url exposing (Url, fromString)


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

type alias AlbumName =
    String

getAlbumID : AlbumID -> Int
getAlbumID (AlbumID id) =
    id

type Album =
    Album AlbumID AlbumName AlbumSongs

type AlbumSongs =
    AlbumSongs Song (List Song)

type SongID =
    SongID Int

getSongID : SongID -> Int
getSongID (SongID id) =
    id

type alias RunTime =
    (Int, Int)

type alias Song
    = { id : SongID
      , title : String
      , time  : RunTime
      , url : Maybe Url  -- A YouTube link, for instance
      }

type alias Validate a
    = Result String a

{- This could've been a custom type -}
type alias UserInput a
    = { input : String
      , valid : Validate a
      }

initUserInput = { input = "", valid = Err "Field cannot be empty" }

{- #! I need to handle the AlbumID and the SongID -}
type alias Model =
    { albumID : AlbumID
    , albumName : AblumName
    , songID : SongID
    , songName : UserInput String
    , minutes : UserInput Int
    , seconds : UserInput Int
    , albums : List Album
    }



-- Update ----------------------------------------------------------------------
