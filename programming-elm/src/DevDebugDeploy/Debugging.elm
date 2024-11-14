module DevDebugDeploy.Debugging exposing (..)

{-| ----------------------------------------------------------------------------
    Develop, Debug, Deploy: debugging
    ============================================================================
    Using `Debug` module

-}

import Html exposing (Html, text)
import Json.Decode as Json
import Json.Decode.Pipeline exposing (required)
import WebSockets.RealTime exposing (Msg)


-- Model -----------------------------------------------------------------------

type alias Dog =
    { name : String
    , age : Int
    }


-- Decoders --------------------------------------------------------------------

dogDecoder : Json.Decoder Dog
dogDecoder =
    Json.succeed Dog
        |> required "name" Json.string
        |> required "age" Json.int

jsonDog : String
jsonDog =
    """
    {
        "name" : "Tucker",
        "age" : 11
    }
    """

decodedDog : Result Json.Error Dog
decodedDog =
    Json.decodeString dogDecoder jsonDog


-- View ------------------------------------------------------------------------

viewDog : Dog -> Html msg
viewDog dog =
    text <|
        dog.name
        ++ " is "
        ++ String.fromInt dog.age
        ++ " years old."


-- -- Main ------------------------------------------------------------------------

-- main : Html msg
-- main =
--     case Debug.log "decodedDog" decodedDog of
--         Ok dog ->
--             viewDog dog

--         Err _ ->
--             text "ERROR: Couldn't decode dog."
