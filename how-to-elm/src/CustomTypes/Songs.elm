module CustomTypes.Songs exposing (..)

{-| Creating A Simple Custom Type
    =============================
    Always ask **"Do we _really_ need this?"**

    First up a few rules:
    ---------------------

    1. Prefer a `Maybe` to storing default data
       - Default data hides potential issues and mute errors
    2. `Maybe`s are just fine to use, but ...
       - Your own custom descriptive type is better
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
        - Do they need any extra information? (running time?)
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

    We could use a collection, which is a good case for a custom type.
    For instance, an `Album` with an ID could look like this:

        ```
        {
        "Album"        : "Californication",
        "album_id"     : 1,
        "album_tracks" : ["Californication"]
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

        `Maybe.withDefault` and `Maybe.map functionForContents MaybeList`


    Only use a custom type when there's CLEAR benefit
    ------------------------------------------------

    So that's no good. I mean, it helps us if the `json` doc is empty (no list),
    but doesn't quite do enough to use it over a `Maybe List`, or just a `List`.

    What _might_ help, is catering for that singleton (only one item). Perhaps
    we might want to add a default entry `["empty"]` (that seems stupid), or
    maybe we want to make sure _at least one list item_ is available (or will
    be added to the `json`). If it isn't, we could throw an error.

        - EmptyList
        - [OneItem]
        - [..ManyItems..]

    The code below allows us to do this. The question is ...


    ----------------------------------------------------------------------------
    ** DO WE REALLY NEED TO DO THIS?! **
    ----------------------------------------------------------------------------

    Possibly not. If a custom type doesn't make things either:

    a) More explicit and better described data
    b) Easier to work with (make impossible states impossible)

    It's probably not the thing to do.

-}
import FormWithResult.Form exposing (Model)

type alias ID
  = ID Int

extractID : ID -> Int
extractID id =
    case id of
        ID i -> i

{- We're adding more data than we need here -}
type alias Song
    = { songID = ID
      , songName = String
      , runTime  = Float
      }

{- The big difference with this custom type is that
it caters for a singleton, as well as "does not exist" -}
type Album
    = NoAlbum
    | Album Song (List Song)

{- Some caveats here. A Song doesn't really need an ID,
but I might want to delete a Song, so we have to have some
way of referencing the correct song to delete! -}
type Model
    = { currentId = ID -- for keeping ID up-to-date
      , currentEntry = Entry
      , storedEntries = Entries
      }


-- View ------------------------------------------------------------------------

viewWrapper : Model Msg ->
