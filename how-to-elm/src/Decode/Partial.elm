module Decode.Partial exposing (..)

{-| ----------------------------------------------------------------------------
    A partial decoder, for when you only want to change part of the `json`.
    ============================================================================
    This can be useful if you only need to work with a portion of the `json` file.

    If you use `Json.Decode.Value` you don't need to worry about the exact shape
    of that `json` value. The `Value` can be any javascript value: a boolean,
    null, string, undefined, an array, object, function, html, etc. Essentially it
    stores the (representation of) that javascript untouched (without a "proper")
    Elm decoder.

        - @ [`Json.Decode.Value`](...)
        - @ [1602/json-value](https://package.elm-lang.org/packages/1602/json-value/latest)
        - @ [`Json.Decode.dict`](https://package.elm-lang.org/packages/elm/json/#dict)

    You may also have need for the `Json.Decode.decodeValue` function, but it's
    unlikely (mostly used for Ports).


    Wishlist
    --------
    > Imagine that it's a user profile/preference file!

    1. Use the `(<|)` pipe for a longer `.map2 << .map8` decoder
    2. Try out different version of the same method:
        - `Json.Decode.at` with two keys: decoder and `Json.Decode.Value` (collection?)
        - Using `Json.Decode.Value` for a particular element (like a `List Record`)
    3. Encode them ready to send back to the server

-}

import Json.Decode as D exposing (..)
import Ports.Settings exposing (Theme(..))


-- Types -----------------------------------------------------------------------
-- We're only concerned with our `User` here, nothing else matters.

type alias User =
    { age : Int
    , level : Int
    , name : String
    , occupation : String
    , options : List String
    , theme : Theme
    , addressOne : String
    , addressTwo : String
    , postcode : String
    }

type Theme
    = Light
    | Dark


-- Example JSON ----------------------------------------------------------------

garden =
    """
    {
        "user": {
            "age": 34,
            "level": 3,
            "name": "Herbert",
            "occupation": "Gardner",
            "options": ["Sunny", "Rain", "Storm"],
            "theme": "Dark",
            "address_one": "24 Pickle Gardens",
            "address_two": "North Tyneside",
            "postcode": NE1 3YE
        },
        "items": [
            { id: 1,
              title: "A wonderful day",
              weather: "Sunny",
              day: "Monday",
              hours: 10
            },
            { id: 2,
              title: "Light drizzle",
              weather: "Rain",
              day: "Tuesday",
              hours: 7,
            }
        ]
    }
    """

decodeUser : Decoder User
decodeUser =
    D.map2
        (<|) -- A handy way to extend the `.map8` to `.mapX`!
        (D.map8 User
            (field "age" int)
            (field "level" int)
            (field "name" string)
            (field "occupation" string)
            (field "options" (list string))
            ((field "theme" string)
                |> D.andThen decodeTheme)
            (field "address_one" string)
            (field "address_two" string))
        (field "postcode" string)

decodeTheme : String -> Decoder Theme
decodeTheme str =
    case str of
        "Light" ->
            D.succeed Light

        "Dark" ->
            D.succeed Dark

        _ ->
            D.fail "This is not a proper theme!"


-- The funky model -------------------------------------------------------------
-- A proper decoder for `User`, but ANY old javascript value for `"items"`.

type alias Model =
    { user : User, items : Value }


-- Method #1: `Json.Decode.at` -------------------------------------------------

decodeAt : Decoder Model
decodeAt =
    D.map2 (\a b -> { user = a, items = b })
        (D.at ["user"] decodeUser)
        (D.at ["items"] value)
