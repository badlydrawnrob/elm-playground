module Debugging01 exposing (..)

{-| ----------------------------------------------------------------------------
    Develop, Debug, Deploy: debugging
    ============================================================================
    Using `Debug` module

    Questions:
    ----------
    1. How to best transform types to json?
        - `Breed` is represented as a json string.
        - What if we have _lots_ of breeds?
    2. Is the `Json.andThen` the only way to convert `"Sheltie"`?
        - `Decode.map` also seems to work:
          @ https://stackoverflow.com/a/57248663

-}

import Html exposing (Html, text)
import Json.Decode as Json
import Json.Decode.Pipeline exposing (required)


-- Model -----------------------------------------------------------------------

type Breed
    = Sheltie
    | Poodle

type alias Dog =
    { name : String
    , age : Int
    , breed : Breed -- Represent as `String` in json
    }


-- Decoders --------------------------------------------------------------------

decodeBreed : String -> Json.Decoder Breed
decodeBreed breed =
    case Debug.log "breed" breed of
        "Sheltie" ->
            Json.succeed Sheltie
        _ ->
            Debug.todo "Handle other breeds in decodeBreed"

dogDecoder : Json.Decoder Dog
dogDecoder =
    Json.succeed Dog
        |> required "name" Json.string
        |> required "age" Json.int
        |> required "breed" (Json.string |> Json.andThen decodeBreed)

jsonDog : String
jsonDog =
    """
    {
        "name": "Tucker",
        "age": 11,
        "breed": "Poodle"
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
        ++ " the "
        ++ breedToString dog.breed
        ++ " is "
        ++ String.fromInt dog.age
        ++ " years old."

breedToString : Breed -> String
breedToString breed =
    case breed of
        Sheltie -> "Sheltie"
        Poodle -> "Poodle"

-- -- Main ------------------------------------------------------------------------

main : Html msg
main =
    case Debug.log "decodedDog" decodedDog of
        Ok dog ->
            viewDog dog

        Err _ ->
            text "ERROR: Couldn't decode dog."
