module PhotoGrooveTests exposing (..)

import Expect exposing (Expectation)
import Json.Decode as Decode exposing (decodeString, decodeValue)
import Json.Encode as Encode
import Fuzz exposing (Fuzzer, int, list, string)
import PhotoGroove
import Test exposing (..)


-- A simple unit test with a Json string ---------------------------------------

decoderTest : Test
decoderTest =
    test "title defaults to (untitled)" <| -- test description (pipe test to this function)
      \_ ->                                -- anon func wrapper
        """{"url": "fruits.com", "size": 5}"""   -- Json triple quote!
          |> decodeString PhotoGroove.photoDecoder  -- Our `photoDecoder` has optional `title` field
          |> Result.map .title             -- map the title from the decoder
          |> Expect.equal                                      -- Expect the below (Ok value)
            (Ok "(untitled)")  -- decoding the json


-- Building our Json programatically -------------------------------------------

-- Currently built out of hardcoded values, e.g: "fruits.com"
-- We want randomly generated `String` and `Int` values

decoderValueTest : Test
decoderValueTest =
  test "title defaults to (untitled) using Value instead of String" <|
    \_ ->
      [ ( "url", Encode.string "fruits.com" )
      , ( "size", Encode.int 5 )
      ]
        |> Encode.object
        |> decodeValue PhotoGroove.photoDecoder  -- Calling decodeValue instead of decodeString
        |> Result.map .title
        |> Expect.equal (Ok "(untitled)")
