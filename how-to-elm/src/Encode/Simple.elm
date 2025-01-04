module Encode.Simple exposing (..)

{-| ✅ A nested object with a list
    ==============================

    This is easier than I thought. You simply create atoms, blocks, and
    combine them together like legos.

    1. A `List Int` is self-explanatory
    2. An `Object`, such as `{"key": "value"}` requires converting your
       Elm data type (such as a record) into a `List Tuple` of key/value.


    TO DO
    -----

    Find an easier way to extract our `UUID` in a function.
    Can we do it in point-free style?


    Optional, `Nothing` and `null`
    ------------------------------

    > Start with the simplest thing possible.
    > Add a custom type where it makes sense.
    > Convert custom types to simple json data.[^1]

    I've been told that it's generally better to not store empty or default
    data in `json` if it doesn't exist, for instance `Maybe` types. Better
    to keep things simple and simply not store it.

    - You can use `Maybe.withDefault` for non-existant values
    - You can use `optional` with NoRedInk's `Json.Decode.Pipeline`
    - You can store an empty value as `null` or `[]` in json.

    [^1]: It's a bit more work to use codecs or hack json to store a
          custom type. Better to store it as plain json data types and
          wait until (potentially) Evan figures out how to do this cleanly.


    Here's how we do it ...
    -----------------------

    > You can optionally add `E` to your `Json.Encode` functions so they're
    > not mistaken for `Json.Decode` ones, or alternatively split them
    > out into different modules.

    1. Create our blocks of data from atoms
    2. Store them as constants
    3. Optionally create empty values
    4. Create a `List Tuple` wrapped in an `object`
    5. Wrap them in a `"collection"` object.
    6. Render our json with `encode` and print as text.

-}

import Html exposing (text)
import Json.Encode as E exposing (encode, int, list, object, string)

type UUID
    = UUID Int

extractUUID : UUID -> Int
extractUUID u =
    case u of
        UUID number -> number

simpleList : E.Value
simpleList =
    E.list E.int [1, 2, 3]  -- 1

simpleObject : E.Value
simpleObject =
    E.object
        [ ("entry", simpleList)  -- 1, 2, 4
        , ("empty", E.null)      -- 3
        ]

complexObject : E.Value
complexObject =
    E.object
        [ ("collection", E.int (extractUUID (UUID 0)))  -- 5
        , ("collection entry", simpleObject)
        ]


-- Main ------------------------------------------------------------------------

main =
    text (E.encode 4 complexObject)  -- Render our json and print as text

