module Notes exposing (..)

import Json.Decode exposing (decodeString, list, string, int)


-- List decoder ----------------------------------------------------------------

-- All elements in a list should be
-- the SAME TYPE!!! Just like Elm lists.


-- Type signatures --

-- list : Decoder a -> Decoder (List a)
-- string : <internals> : Decoder String
-- <internals> : Decoder Int

nicknameJson = "[\"The Godfather\", \"The Tank\", \"Beanie\", \"Cheese\"]"

decodeString (list string) nicknameJson
-- Ok ["The Godfather","The Tank","Beanie","Cheese"]
--    : Result Error (List String)

decodeString (list int) "[1,2,3]"
-- Ok [1,2,3] : Result Error (List Int)


-- List of lists (Arrays) --

decodeString (list (list int)) "[[1,2], [3,4]]"
-- Ok [[1,2],[3,4]]
--    : Result Error (List (List Int))
