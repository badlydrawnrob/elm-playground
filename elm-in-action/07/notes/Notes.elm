{-| Stick to the key points for notes.
    Skip over things we've learned before.

-}


-- 7.1.1 -----------------------------------------------------------------------

-- The first thing we've done is to sketch out our layout, and consider
-- what data (incrementally) lives in each section.
--
-- 1. There's a folder layout
-- 2. There's a main (large) picture
-- 3. There's pictures related to (2) image.
--
-- We've started out by building the `Model` and `Msg`, as well as our
-- `Cmd` that gets fired as soon as our page launches.
--
-- Our `main` function was simple to begin, and the `Model` only held a
-- single record entry for `selectedPhotoUrl`.
--
-- We then built out the view functions to display the main image, and the
-- related images — but these haven't been built into the `Model` yet. We have,
-- however, created a `Photo` type alias.
--
-- The folder layout is something we haven't done before, and seems quite
-- difficult so that we'll leave til later.


-- View selected photo --

-- OPTION (1)
--
-- `List Photo`
--
-- To call `viewSelectedPhoto`, we’d take the selected URL from
-- `model.selectedPhotoUrl` (assuming it’s a `Just` rather than a `Nothing`)
-- and look through every single record in our `List` in search of a `Photo`
-- whose url field matches that selected URL.
--
--     - If we found a matching `Photo` record, we’d pass it to `viewSelectedPhoto`.
--     - Otherwise, we’d have nothing to render and would do nothing.
--

-- This works, but it's not very efficient. We might have to search
-- the entire list to find a match. For 1000 photos, that's a long search!
--
-- Also, if multiple `Photo` records have the same URL we're looking for,
-- how to we handle that? It's not clear how.

-- OPTION (2)
--
-- `Dict Photo`
--
-- A _dictionary_ is a collection in which each _value_ is associated with
-- a unique _key_ (as you've seen in Python).
--
-- Dictionaries are somewhere between Records and Lists. You can search a value
-- quickly by using it's Key. EVERY KEY IS GUARANTEED TO BE UNIQUE WITHIN
-- THE DICTIONARY!
--
-- This means it's impossible to encounter multiple matches.
--
-- The `Dict.fromList` function takes a `List Tuple` and returns a Dict.
-- Each tuple represents a key-value pair that will be stored in the dictionary.

import Dict
dict = Dict.fromList [ ("pi, give or take", 3.14), ("answer", 42) ]
-- Dict.fromList [("answer",42),("pi, give or take",3.14)]
--    : Dict.Dict String Float

Dict.get "a key we never added!" dict
-- Nothing : Maybe Float

Dict.get "pi, give or take" dict
-- Just 3.14 : Maybe Float

-- Dictionary type params --
--
-- A Dict has two type parameters (unlike `List a` or `Array a`)
-- for example `Dict Char Int` or `Dict String Photo`.
--
-- It's keys must be `comparable`, but it's values can be any type.


-- Remembering `Maybe` types ---------------------------------------------------

-- It’s common for functions that look up values within Elm data structures
-- to return a `Maybe` if the desired element might not be found.
-- This approach is used in `Array.get`, `Dict.get`, `List.head`, and more.


-- Constrained Type Variables --------------------------------------------------

-- You'll remember that `number` is a constrained type variable:
--     - It can be an `Int` or a `Float`
--
-- `appendable` can resolve to `String` or `List` (++ is appendable func)
-- `comparable` can resolve to `Int`, `Float`, `Char`, `String`, `List` ...
--     - Or a Tuple containing these values.

Dict.get : (comparable -> Dict comparable -> value -> Maybe value)
Dict.get
--          ^^^^^^^^^^    ^^^^^^^^^^^^^^^
--         i.e: String    A Dict (String, Value)

(*) : number -> number -> number
(*)
--    ^^^^^^    ^^^^^^
--   comparable of type `number`



-- Retrieving a `Photo` --------------------------------------------------------

-- Our `viewSelectedPhoto` expects a `Photo` type, from which it'll extract the
-- values it neeeds, i.e: `.title`
--
-- We have (at init) a `Dict.empty` and (with server response) a `Dict String Photo`.
-- So we need to review our Types to find useful functions to get
-- the types we need.
--
-- When our server has returned our request:
--
-- 1. We want a `Photo` for the selected photo, so `view` can pass it to the function
-- 2. We have a `Maybe String` indicating which photo is selected, if any
-- 3. We have a `Dict string Photo` of all the photos.
--
-- To get from a `Maybe String` to a `Photo` record we'll need to do 3 things:
--
-- 1. Handle the possibility that `selectedPhotoUrl` is `Nothing`.
-- 2. If it isn't `Nothing`, pass the selected photo URL to `Dict.get` on `model.photos`
-- 3. Handle the possibility that `Dict.get` returns `Nothing`.
--
-- We're back to nested `case` expressions again:

selectedPhoto : Html Msg
selectedPhoto =
  case model.selectedPhotoUrl of
    Just url ->
      case Dict.get url model.photos of
        Just photo ->
          viewSelectedPhoto photo

        Nothing ->
          text ""  -- These could perhaps be more useful

    Nothing ->
      text ""      -- Throw an error instead of empty string?


-- Using `Maybe.andThen` -------------------------------------------------------

-- We can make the above code neater (and smaller) by using `Maybe.andThen`:

Maybe.andThen : (original -> Maybe final) -> Maybe original -> Maybe final

-- Whenever we have two nested `case` expressions like this, with both of them
-- handling `Nothing` the same way, `Maybe.andThen` does exactly the same
-- thing as the code we had before.

photoByUrl : String -> Maybe Photo
photoByUrl url =
  Dict.get url model.photos

selectedPhoto : Html Msg
selectedPhoto =
  case Maybe.andThen photoByUrl model.selectedPhotoUrl of
    Just photo ->
      viewSelectedPhoto photo

    Nothing ->
      text ""
