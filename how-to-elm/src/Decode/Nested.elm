module Decode.Nested exposing (..)

{-| ----------------------------------------------------------------------------
    How to decode: some nested examples
    ============================================================================

    1. If a field is optional (whether you use a `Maybe` or default data in
       your `Model`) DO NOT add it to your `json`. Keep things simple.

-}

import Json.Decode as D exposing (..)
import Url as U exposing (Url)

-- Some simpler nested examples ------------------------------------------------

jsonSimpleNested : String
jsonSimpleNested =
    """
    { "id" : 0
    , "title" : "Afraid"
    , "songs" : [ { "title" : "Heathen", "time" : "2:00", "link" : "http://bowie.com" },
                  { "title" : "Afraid", "time" : "3:58", "link" : "http://bowie.com" },
                  { "title" : "Afraid", "time" : "3:58" }
                ]
    }
    """

type alias Album =
    { id : Id
    , title : String
    , songs : List Song
    }

type alias Song =
    { title : String
    , time : String
    , link : Url
    }

albumDecoder : Decoder Album
albumDecoder =
    D.map3 Album
        (field "id" int)
        (field "title" string)
        (field "songs" (list songDecoder))

songDecoder : Decoder Song
    D.map3 Song
        (field "title" string)
        (field "time" string)
        (D.maybe (field "link" urlDecoder))

urlDecoder : Decoder Url
urlDecoder
    D.map U.fromString string
