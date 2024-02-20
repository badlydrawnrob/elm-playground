module PhotoGrooveTests exposing (..)

import Expect exposing (Expectation)
import Json.Decode as Decode exposing (decodeString)
import Json.Encode as Encode
import PhotoGroove
import Test exposing (..)


decoderTest : Test
decoderTest =
    test "title defaults to (untitled)" <| -- test description (pipe test to this function)
      \_ ->                                -- anon func wrapper
        """{"url": "fruits.com", "size": 5}"""   -- Json triple quote!
          |> decodeString PhotoGroove.photoDecoder  -- Our `photoDecoder` has optional `title` field
          |> Result.map .title             -- map the title from the decoder
          |> Expect.equal                                      -- Expect the below (Ok value)
            (Ok "(untitled)")  -- decoding the json
