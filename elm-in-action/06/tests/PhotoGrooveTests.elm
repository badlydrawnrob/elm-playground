module PhotoGrooveTests exposing (..)

import Expect exposing (Expectation)
import Json.Decode exposing (decodeString)
import PhotoGroove
import Test exposing (..)


decoderTest : Test
decoderTest =
    test "title defaults to (untitled)"  -- test description
      (\_ ->                             -- anon func wrapper
        """{"url": "fruits.com", "size": 5}"""   -- Json triple quote!
          |> decodeString PhotoGroove.photoDecoder             --
          |> Expect.equal                                      --
            (Ok { url = "fruits.com", size = 5, title = "(untitled)" })  -- decoding the json
      )
