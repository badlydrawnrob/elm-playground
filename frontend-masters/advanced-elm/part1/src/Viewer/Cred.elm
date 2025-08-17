module Viewer.Cred exposing (Cred, addHeader, addHeaderIfAvailable, decoder, encodeToken, username)

{-|


# Task

1.  Make `Cred` an opaque type
      - `.token` should not be accessible directly
2.  You need to expose `username` however
      - Create a function that exposes the username
      - But does not break (1)
3.  Fix ALL errors that arise from changing (1) and (2)
      - There's A LOT of errors in different parts of the app
      - Deconstruct `token`, eg: `(Cred _ token)`
      - Access `Username` with `username` function

Records in custom (opaque) types are better used when you have different fields
with the same types, or when you have quite a few different fields.


## Points to consider

> If you need to expose _some_ details of the Opaque Type, you can
> write functions to grab those details, like `Cred.username`

1.  `Cred` is an opaque type, as modules should no longer be able
    to grab the `token` value directly
2.  Other modules still need to access the `username` value


## Gotchas

To get the username `String`, you'll need to first pull out the
`Username` value from `Cred`, then use `Username.toString` from
the `Username` module!

-}

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Username exposing (Username)



-- TYPES


type Cred
    = Cred Username String


username : Cred -> Username
username (Cred user _) =
    user



-- SERIALIZATION


decoder : Decoder Cred
decoder =
    Decode.succeed Cred
        |> required "username" Username.decoder
        |> required "token" Decode.string



-- TRANSFORM


encodeToken : Cred -> Value
encodeToken (Cred _ token) =
    Encode.string token


addHeader : Cred -> RequestBuilder a -> RequestBuilder a
addHeader (Cred _ token) builder =
    builder
        |> withHeader "authorization" ("Token " ++ token)


addHeaderIfAvailable : Maybe Cred -> RequestBuilder a -> RequestBuilder a
addHeaderIfAvailable maybeCred builder =
    case maybeCred of
        Just cred ->
            addHeader cred builder

        Nothing ->
            builder
