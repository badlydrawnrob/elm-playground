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

-- #1: We're now building our Json programatically but with hardcoded values,
--     e.g: "fruits.com". We want randomly generated `String` and `Int` values
--
-- #2: Here we've setup a fuzz test. Elm will run this function 100 times,
--     each time randomly generating a fresh `String` value and passing it
--     in as `url`, and a fresh `Int` value and passing it in as `size`.
--
--     We can now have considerably more confidence that any JSON string
--     containing only properly set "url" and "size" fields—but no
--     "title" field—will result in a photo whose title defaults to "(untitled)".

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

decoderValueFuzzTest : Test
decoderValueFuzzTest =
  fuzz2 string int "title defaults to (untitled) using Value with Fuzz testing" <|
    \url size ->
      [ ( "url", Encode.string url )
      , ( "size", Encode.int size )
      ]
        |> Encode.object
        |> decodeValue PhotoGroove.photoDecoder  -- Calling decodeValue instead of decodeString
        |> Result.map .title
        |> Expect.equal (Ok "(untitled)")
