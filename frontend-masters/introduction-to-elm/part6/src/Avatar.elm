module Avatar exposing (Avatar, decoder, encode, src, toMaybeString)

{-|


# Task

1.  Avatar url is broken:
      - Case on the `Maybe String` and provide ...
      - A branch for the `Just`
      - A backup branch for the `Nothing` (with fallback url)

Note that the `decoder` is within the `Avatar` module, rather than having a
`decodeAvatar` function. It uses `nullable` as we may have an empty `json` value.


## Learning points

1.  The `src` function is adding a `case` statement for an `""` empty string
      - Is this entirely necessary? Surely when we're encoding the value we can
        force the string to be a `Nothing` or a `Just nonEmptyString`?


## Questions

1.  What is `src` function doing and why?

-}

import Asset
import Html exposing (Attribute)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- TYPES


type Avatar
    = Avatar (Maybe String)



-- CREATE


decoder : Decoder Avatar
decoder =
    Decode.map Avatar (Decode.nullable Decode.string)



-- TRANSFORM


src : Avatar -> Attribute msg
src (Avatar maybeUrl) =
    Html.Attributes.src <|
        if maybeUrl == Just "" then
            resolveAvatarUrl Nothing

        else
            resolveAvatarUrl maybeUrl


resolveAvatarUrl : Maybe String -> String
resolveAvatarUrl maybeUrl =
    case maybeUrl of
        Just url ->
            url

        Nothing ->
            "https://static.productionready.io/images/smiley-cyrus.jpg"


encode : Avatar -> Value
encode (Avatar maybeUrl) =
    case maybeUrl of
        Just url ->
            Encode.string url

        Nothing ->
            Encode.null


toMaybeString : Avatar -> Maybe String
toMaybeString (Avatar maybeUrl) =
    maybeUrl
