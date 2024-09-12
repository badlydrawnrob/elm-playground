module CustomTypes.Songs exposing (..)

{-| ----------------------------------------------------------------------------
    Creating A Simple Custom Type
    ============================================================================

    Always ask:
    -----------
    1. Do we _really_ need this feature?
    2. Is this as simple as it can be?
    3. Have I scoped the problem out well enough?
    4. Have I written it down and sketched it out?
    5. Have I followed '5 steps to reduce code'?

    Don't use a custom type unless it's:
    ------------------------------------
    a) More explicit and better described data
    b) Easier to work with (make impossible states impossible)
    c) Better shaped than simple data (easier to reason about)


    First up a few rules:
    ---------------------
    1. Prefer a `Maybe` to storing default data
       - Default data hides potential issues and mute errors
    2. `Maybe`s are just fine to use, but ...
       - Your own custom descriptive type is better
       - If it improves on simple data ..
       - Or makes impossible states (impossible)
    3. Reach for `Maybe.withDefault` LATE (at the very end)
       - For example, at the last moment in your `view`.
    4. For other custom types, you can reach for a codec ...
       - Codecs are fine for _transmitting_ the data. But you probably
         don't want to store it as is.
       - But rethink storing them directly, as your custom types
         and `json` data can get out of sync VERY quickly.
       - You'd have to version your custom types.


    What's the benefit of a custom type over regular data?
    -----------------------------------------------------

    First it's best to really think about the type of data you
    actually need, and the best way to represent this:

        - It's a list of song titles? (strings)
        - Do they need any extra information? (song time?)
        - Are the part of anything more? (an album)
        - Do we really need that extra information? (such as ID)

    So maybe all we need is a `List String` and that's it. In the below code
    I started with a list, and ended up with a custom type that's not too
    disimilar to `Random.Uniform`. First we need to consider what a basic
    data type _actually is_, though.

        ["Get Back", "Afraid", "Californication"]

    A list is either empty, a single item, or many items.

    Often, we'll only have to worry whether the item is empty or full,
    without having to concern ourselves with _how many_ items it holds.

    Sometimes, however, we might want to treat the list differently
    if it holds _only one_ item. A good example might be within our
    view. It's an `<ul>` if there's many items, but we might use a
    different element if it's just one item.

    What happens if we don't get a list at all?
    -------------------------------------------
    Perhaps we have a `json` document, and we don't know ahead of time if
    this list is available. We could use `Maybe` for this possibility.
    If there's no list in the `json` doc, we can set it to `Nothing`.
    If there's a list there, we can set it to `Just []` ... or the number
    of items that are in that list.

    The problem is, not only do we have to check for `Nothing`, we also have
    to check for the `Just` ... _before_ handling the `List`. Only then
    can we check for empty, single, or full list (by unpacking `Just`s
    contents) and start working with that data.

    That all adds up and creates quite a bit of work for ourselves.


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
    may also call for a `Maybe` type. But, if the album is found, we could
    generally predict that it wouldn't have an empty list. We'd have to make
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


    Only use a custom type when there's CLEAR benefit
    ------------------------------------------------

    So that's no good. I mean, it helps us if the `json` doc is empty (no list),
    but doesn't quite do enough to use it over a `Maybe List`, or just a `List`.

    What _might_ help, is catering for that singleton (only one item). Perhaps
    we can add a default entry (like `Random.uniform`) if there's no `List` in
    our json? Or we want to assure that AT LEAST ONE SONG is added to our data.
    If at least one song isn't added, we could throw an error. We have the
    following possibilities:

        - `AnEmptyList` or `[]`
        - `Entry "String"` or `["String"]`
        - `[(Entry "String") ...]` or `["Many", "Items"]`

    That's what I'm doing in this file, with a custom type instead of `List`.


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    Before you start coding — sketch the damn thing out! Follow the rules and
    questions above! The general rule seems to be: use `Maybe` for data that is
    optional, but DON'T store default data in json, just leave it out.

    1. A form to add a song to an album
    2. There's no album title (yet)
    3. A view to preview either:
       - No songs in album
       - One song in the album (add more songs)
       - A full album (from our Idol)
    4. What checks on the data do we need?
       - Non-empty `SongTitle`
       - `SongTime` must be positive number
       - `00` for minutes must be rendered as a string
       - `SongId` must be unique (package for `UUID`?)

    Nice to have but not important:

    1. Youtube or audio of the song (like a playlist)

-}

type SongID
  = SongID Int

{- A simpler way to unpack the `Int` than using `case` -}
extractID : ID -> Int
extractID (SongID num) =
    num

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
      , songName : SongTitle
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
    = { currentId : ID -- for keeping ID up-to-date
      , currentSong : Song
      , album : Album
      }

{- It might be better to use `Maybe` here rather than default data.
In any event, we've got to sanitise the data first. What checks do we need? -}
init : Model
init =
    { songId = 0
    , songName = ""
    , songTime = (0,0)
    }


-- Update ----------------------------------------------------------------------


-- View ------------------------------------------------------------------------


-- Main ------------------------------------------------------------------------
