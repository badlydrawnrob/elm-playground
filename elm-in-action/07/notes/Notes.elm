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
