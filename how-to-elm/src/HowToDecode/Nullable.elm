module HowToDecode.Nullable exposing (..)

{-| ----------------------------------------------------------------------------
    How to encode: using `null` for optional fields
    ============================================================================
    ⚠️ NEVER use `Json.Decode.maybe`!

    @SimonLydell suggests to BE EXPLICIT when Encoding and Decoding optional
    fields, as in his experience it leads to fewer bugs. The alternative is to
    use `Json.Decode.Pipeline` with `optional` and provide default data.
-}

import Json.Decode as D exposing (..)
import Json.Decode.Pipeline as DP exposing (..)
import Json.Decode.Extra as DE exposing (..)

-- Basic `Json.Decode` setup ---------------------------------------------------

jsonOptional01 : String
jsonOptional01 =
    """
    { "brand" : "Toyata",
      "license" : "ABC 1234",
      "colour" : "Red",
      "wheels" : 4
    }
    """

{- Missing colour NOT properly `null`ed-}
jsonOptional02 : String
jsonOptional02 =
    """
    { "brand" : "Toyata",
      "license" : "ABC 1234",
      "wheels" : 4
    }
    """

{- Missing colour PROPERLY `null`ed -}
jsonOptional03 : String
jsonOptional03 =
    """
    { "brand" : "Toyata",
      "license" : "ABC 1234",
      "colour" : null,
      "wheels" : 4
    }
    """

{- Colour has wrong data type -}
jsonOptional04 : String
jsonOptional04 =
    """
    { "brand" : "Toyata",
      "license" : "ABC 1234",
      "colour" : [],
      "wheels" : 4
    }
    """

{- A `type Car = Car {}` HAS NO CONSTRUCTOR FUNCTIONS which causes problems when
used with `D.map4`, as it's expecting a record. Use `type alias Car` for now -}
type alias Car =
    { brand : String, license : String, colour : Maybe String, wheels : Int }

defaultOptionalDecoder : Decoder Car
defaultOptionalDecoder =
    D.map4 Car
        (D.field "brand" string)
        (D.field "license" string)
        (D.field "colour" (D.nullable string))
        (D.field "wheels" int)

workingOptional01 =
    D.decodeString defaultOptionalDecoder jsonOptional01 -- Fully working `Car`
    -- D.decodeString defaultOptionalDecoder jsonOptional02 -- `Err` expectiong object w/ field "colour"
    -- D.decodeString defaultOptionalDecoder jsonOptional03 -- `Nothing` for "colour"
    -- D.decodeString defaultOptionalDecoder jsonOptional04 -- `Err` wrong data type for "colour"


-- Using `Json.Decode.Pipeline` ------------------------------------------------

jsonOptional05 : String
jsonOptional05 =
    """{"key" : "String"}"""

jsonOptional06 : String
jsonOptional06 =
    """{"ke" : "String"}"""

jsonOptional07 : String
jsonOptional07 =
    """{"key" : 20}""" -- wrong data type

simpleOptionalDecoder : Decoder { key : Maybe String }
simpleOptionalDecoder =
    D.succeed (\value -> { key = value })
        |> optional "key" (D.nullable string) Nothing

{- Errors here would be "key not found", "wrong value type" -}
workingOptional02 =
    D.decodeString simpleOptionalDecoder jsonOptional05 -- { key = Just String }
    -- D.decodeString simpleOptionalDecoder jsonOptional06 -- { key = Just Nothing }
    -- D.decodeString simpleOptionalDecoder jsonOptional07 -- { key = Err ... }


-- Using a mix of methods ------------------------------------------------------

jsonOptional08 : String
jsonOptional08 =
    """{ "name" : "Daniel", "age" : 25 }"""

jsonOptional09 : String
jsonOptional09 =
    """{ "name" : "Daniel" }""" -- Missing age

type alias Person =
    { name : String, age : Maybe Int }

{- `Just value` if key exists,
    `Nothing` if key doesn't exist,
   `Err ...` if wrong data type
It's a much simpler `Err` message than `Json.Decode.nullable` -}
mixedOptionalDecoder : Decoder Person
mixedOptionalDecoder =
    D.succeed Person
        |> DP.required "name" string
        |> custom (DE.optionalField "age" int)

workingOptional03 =
    D.decodeString mixedOptionalDecoder jsonOptional08 -- { name = "Daniel", age = 25 }
    -- D.decodeString mixedOptionalDecoder jsonOptional09 -- { name = "Daniel", age = Nothing }
