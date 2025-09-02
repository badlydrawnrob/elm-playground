module Main exposing (..)

{-| ----------------------------------------------------------------------------
    Develop, Debug, Deploy: debugging
    ============================================================================
    Using `Debug` module to check our `json` API, such as:

    - How are `breed` strings capitalised?
    - What `breed`s do we have in the API?
    - Is our `Dog` decoded properly in `main`?
        - If not, what's the `Err` message?


    Wishlist
    --------
    1. What if we have MANY breeds?
        - Does it make sense to have a type for every one?
        - Or should we use stringly typed breeds?
    2. Is there an alternative to `Json.andThen`?
        - `Decode.map` also seems to work:
          @ https://stackoverflow.com/a/57248663

-}

import Html exposing (Html, div, p, img, text)
import Html.Attributes exposing (src)
import Json.Decode as Json
import Json.Decode.Pipeline exposing (required)


-- Model -----------------------------------------------------------------------

type Breed
    = Sheltie
    | Poodle
    | Beagle

type alias Dog =
    { name : String
    , age : Int
    , breed : Breed -- Represent as `String` in json
    , image : String
    }


-- Decoders --------------------------------------------------------------------

{-| Decode a breed from a string

We've discovered that our user input has inconsistent capitalization.
We've also left out the following tasks, pick one!

- Add `Json.fail ("Unknown breed " ++ breed)` in the `_` case
- Allow an `Other String` breed type for miscellaneous breeds
- Use a `Unknown breed` as a `json.succeed` branch (silently fails)
    - This allows other dog details to still be decoded.
-}
decodeBreed : String -> Json.Decoder Breed
decodeBreed breed =
    case String.toLower (Debug.log "breed" breed) of
        "sheltie" ->
            Json.succeed Sheltie

        "poodle" ->
            Json.succeed Poodle

        "beagle" ->
            Json.succeed Beagle

        _ ->
            Debug.todo "Handle failure case"

decodeDog : Json.Decoder Dog
decodeDog =
    Json.succeed Dog
        |> required "name" Json.string
        |> required "age" Json.int
        |> required "breed"
            (Json.string |> Json.andThen decodeBreed)
        |> required "image" Json.string

jsonDog : String
jsonDog =
    """
    {
        "name": "Tucker",
        "age": 11,
        "breed": "Poodle",
        "image": "/poodle.jpg"
    }
    """

decodedDog : Result Json.Error Dog
decodedDog =
    Json.decodeString decodeDog jsonDog


-- View ------------------------------------------------------------------------

viewDog : Dog -> Html msg
viewDog dog =
    div []
        [ img [ src dog.image ] []
        , p [] [
            text <|
                dog.name
                ++ " the "
                ++ breedToString dog.breed
                ++ " is "
                ++ String.fromInt dog.age
                ++ " years old."
        ]
    ]

breedToString : Breed -> String
breedToString breed =
    case breed of
        Sheltie ->
            "Sheltie"

        Poodle ->
            "Poodle"

        Beagle ->
            "Beagle"

-- -- Main ------------------------------------------------------------------------

main : Html msg
main =
    case Debug.log "decodedDog" decodedDog of
        Ok dog ->
            viewDog dog

        Err _ ->
            text "ERROR: Couldn't decode dog."
