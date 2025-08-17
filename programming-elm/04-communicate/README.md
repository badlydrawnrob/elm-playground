# README

Using the `photoDecoder` example:

```elm
import WithServers exposing (photoDecoder)
import Json.Decode exposing (decodeString)

decodeString : Result Error Photo
decodeString photoDecoder """
    { "id": 1
    , "url": "https://programming-elm.surge.sh/1.jpg"
    , "caption": "Surfing"
    , "liked": false
    , "comments": ["Cowabunga, dude!"]
    }
"""
```
