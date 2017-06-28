module Jsonify exposing (..)

import Json.Decode as Decode


-- {
--   "users": [
--     {
--       "name": "Jack",
--       "age": 24,
--       "description": "A person who writes Elm",
--       "languages": ["elm", "javascript"],
--       "sports": {
--         "football": true
--       }
--     },
--   ]
-- }


type alias User =
    { name : String
    , age : Int
    , description : Maybe String
    , languages : List String
    , playsFootball : Bool
    }



-- If sports isn't defined, use 'False'


SportsDecoder =
    (Decode.oneOf
        [ Decode.at [ "sports", "football" ] Decode.bool
        , Decode.succeed False
        ]
    )


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map5
        User
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "age" ] Decode.int)
        (Decode.maybe (Decode.at [ "description" ] Decode.string))
        (Decode.at [ "languages" ] (Decode.list Decode.string))
