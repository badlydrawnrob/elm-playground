module Decode.Simple exposing (..)

{-| ----------------------------------------------------------------------------
    How to decode: some simple examples
    ============================================================================
    ⚠️ According to `@SimonLydell` you should NEVER use `Json.Decode.maybe`. But
    I'm listing it here anyway.


    Lessons learned
    ---------------
    1. NEVER use `Json.Decode.maybe` (that function should be BANISHED!)
        - Use `Decode.optionalField` from `Json.Decode.Extra` or ...
        - `Json.Decode.Pipeline` and `optional` is safe too
    2. Better to set optional Elm types to `null` in the `json` (and back again)
        - `Json.Decode.nullable` and `Json.Encode.null` to `null` all the things!
          @ https://tinyurl.com/elm-json-decode-nullable
    3. Keep data types as simple as possible
        - e.g: "2:00" -> (2,0) is quite a bit of work to achieve
               "2:00" for both `json` and Elm model better?
               Or, use a `Time` type for both (probably a `String`)
        - When validating the form, your types can be simple (mins, secs) and
          transform that into a type you'd keep in your built record or json.

-}

import Json.Decode as D exposing (Decoder, field, int, list, string)
import Json.Decode.Pipeline as DP exposing (..)

-- Let's start with some basic types -------------------------------------------

{- a `List Int` -}
listIntDecoder : Decoder (List Int)
listIntDecoder =
    list int

jsonListInt : String
jsonListInt =
    "[1, 2, 3, 4]"

workingListInt =
    D.decodeString listIntDecoder jsonListInt -- Ok [1, 2, 4, 4]

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
    D.decodeString simpleObject jsonObjectInt


-- Maybe types -----------------------------------------------------------------
-- 1. Use an `optional` field with a default (a bit like `Maybe.withDefault`)
-- 2. ⚠️ Wrap the thing in a `D.maybe` (either the field or the decoder)
--     - It's a BIG RISK to use this as it's too permissive!
--     - @ https://stackoverflow.com/a/42308078 for `maybe` with
--       `Json.Decode.Pipeline`
-- 3. Succeeds if `"stuff"` key doesn't exist, but fails if `"stuff"` exists
--    but is the wrong type! `nullable` might be a better option here.

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

simpleObjectMaybe01 : Decoder ObjectMaybe
simpleObjectMaybe01 =
    D.map3 ObjectMaybe
        (field "id" int)
        (field "name" string)
        -- #! Using `Maybe` is risky!
        (D.maybe (field "stuff" listIntDecoder)) -- #! "stuff" is missing?
        -- (field "stuff" (maybe listIntDecoder)) -- #! "stuff" exists but wrong type?

workingObjectMaybe01 =
    D.decodeString simpleObjectMaybe01 jsonObjectMaybeInt02

{- (3) -}
simpleObjectMaybe02 : Decoder ObjectMaybe
simpleObjectMaybe02 =
    D.succeed ObjectMaybe
        |> required "id" int
        |> required "name" string
        |> optional "stuff" (D.map Just listIntDecoder) Nothing -- Fieldname is missing?

workingObjectMaybe02 =
    D.decodeString simpleObjectMaybe02 jsonObjectMaybeInt02
    -- decodeString simpleObjectMaybe02 jsonObjectMaybeInt01 -- #! Will fail HARD!

type alias ObjectWithDefault =
    { id : Int
    , name : String
    , stuff : List Int -- Return `[]` empty if doesn't exist
    }

simpleObjectWithDefault : Decoder ObjectWithDefault
simpleObjectWithDefault =
    D.succeed ObjectWithDefault
        |> DP.required "id" int
        |> DP.required "name" string
        |> DP.optional "stuff" listIntDecoder []

workingObjectWithDefault =
    D.decodeString simpleObjectWithDefault jsonObjectMaybeInt02
