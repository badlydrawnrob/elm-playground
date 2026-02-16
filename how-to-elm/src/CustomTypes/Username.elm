module CustomTypes.Username exposing (Username, decoder, toString)

{-| ----------------------------------------------------------------------------
    An Opaque `Username` Type (consumed by `CustomTypes.Cred`)
    ============================================================================
    > See `CustomTypes.Cred` for more information on Opaque Types

    `Username` can only be created internally by this module, once it's been
    decoded from the `Cred` endpoint. It's quite nice to have each key element
    with it's own decoder and `toString` function, for ease of naming conventions.

    This is how @rtfeldman does it in his Elm Spa example.
-}

import Json.Decode as Decode exposing (Decoder)

type Username
    = Username String

decoder : Decoder Username
decoder =
    Decode.map Username Decode.string

toString : Username -> String
toString (Username username) =
    username
