module UsePhotoDecoder

{-| You must expose the `photoDecoder` within the module
    to be able to use it here or in the REPL -}

import Communicate.WithServers exposing (photoDecoder)
import Json.Decode exposing (decodeString)

decodeString : Result
decodeString photoDecoder """
    { "id": 1
    , "url": "https://programming-elm.surge.sh/1.jpg"
    , "caption": "Surfing"
    , "liked": false
    , "comments": ["Cowabunga, dude!"]
    }
"""
