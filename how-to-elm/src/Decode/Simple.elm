module Decode.Simple exposing (..)

{-| ----------------------------------------------------------------------------
    How to decode: some simple examples
    ============================================================================

    Lessons learned
    ---------------
    1. NEVER use `Json.Decode.maybe` (that function should be BANISHED!)
        - Use `Decode.optionalField` from `Json.Decode.Extra` or ...
        - `Json.Decode.Pipeline` and `optional` is safe too
    2. Better to set optional Elm types to `null` in the `json` (and back again)
        - `Json.Decode.nullable` and `Json.Encode.null` to `null` all the things!
          @ https://tinyurl.com/elm-json-decode-nullable
    2. Keep data types as simple as possible
        - e.g: "2:00" -> (2,0) is quite a bit of work to achieve
               "2:00" for both `json` and Elm model better?
               Or, use a `Time` type for both (probably a `String`)
        - When validating the form, your types can be simple (mins, secs) and
          transform that into a type you'd keep in your built record or json.

-}

import Json.Decode as D exposing (..)
import Json.Decode.Pipeline as DP exposing (..)

-- Let's start with some basic types -------------------------------------------

{- a `List Int` -}
listIntDecoder : Decoder (List Int)
listIntDecoder =
    D.list D.int

jsonListInt : String
jsonListInt =
    "[1, 2, 3, 4]"

{- `Ok [1, 2, 4, 4]` -}
workingListInt =
    decodeString listIntDecoder jsonListInt

type alias Object =
    { id : Int
    , name : String
    , stuff : List Int
    }

jsonObjectInt : String
jsonObjectInt =
    """
    { "id" : 0, "name" : "List of integers", "stuff" : [1, 2, 3, 4] }
    """
simpleObject : Decoder Object
simpleObject =
    D.map3 Object
        (field "id" int)
        (field "name" string)
        (field "stuff" listIntDecoder)

workingObjectListInt =
    decodeString simpleObject jsonObjectInt


-- Maybe types -----------------------------------------------------------------
-- ⚠️ According to `@SimonLydell` you should NEVER use `Json.Decode.maybe`. But
-- I'm listing it here anyway.
--
-- 1. Use an `optional` field with a default (a bit like `Maybe.withDefault`)
-- 2. ⚠️ Wrap the thing in a `D.maybe` (either the field or the decoder)
--    @ https://stackoverflow.com/a/42308078 for `maybe` with `Json.Decode.Pipeline`

jsonObjectMaybeInt01 : String
jsonObjectMaybeInt01 =
    """
    { "id" : 0, "name" : "Has stuff but wrong type", "stuff" : "Isn't an Int" }
    """

jsonObjectMaybeInt02 : String
jsonObjectMaybeInt02 =
    """
    { "id" : 0, "name" : "Has no stuff" }
    """

type alias ObjectMaybe =
    { id : Int
    , name : String
    , stuff : Maybe (List Int)
    }

{- #! `Json.Decode.maybe` should NEVER be used, but here's how it works -}
simpleObjectMaybe01 : Decoder ObjectMaybe
simpleObjectMaybe01 =
    D.map3 ObjectMaybe
        (field "id" int)
        (field "name" string)
        (D.maybe (field "stuff" listIntDecoder)) -- Fieldname is missing?
        -- (field "stuff" (maybe listIntDecoder)) -- Fieldname exists but wrong type?

workingObjectMaybe01 =
    decodeString simpleObjectMaybe01 jsonObjectMaybeInt02

{- Succeeds if `"stuff"` key doesn't exist, but fails if `"stuff"` exists
but is the wrong type! Better to just use `null` however -}
simpleObjectMaybe02 : Decoder ObjectMaybe
simpleObjectMaybe02 =
    D.succeed ObjectMaybe
        |> required "id" int
        |> required "name" string
        |> optional "stuff" (D.map Just listIntDecoder) Nothing -- Fieldname is missing?

workingObjectMaybe02 =
    decodeString simpleObjectMaybe02 jsonObjectMaybeInt02
    -- decodeString simpleObjectMaybe02 jsonObjectMaybeInt01 -- This will fail HARD!

type alias ObjectWithDefault =
    { id : Int
    , name : String
    , stuff : List Int -- Return `[]` empty if doesn't exist
    }

simpleObjectWithDefault : Decoder ObjectWithDefault
simpleObjectWithDefault =
    D.succeed ObjectWithDefault
        |> required "id" int
        |> required "name" string
        |> optional "stuff" listIntDecoder []

workingObjectWithDefault =
    decodeString simpleObjectWithDefault jsonObjectMaybeInt0
