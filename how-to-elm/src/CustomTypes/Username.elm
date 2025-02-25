module CustomTypes.Username exposing (Username, decoder, toString)

{-| ----------------------------------------------------------------------------
    A Simple `Username` type (@imported by `Cred.elm`)
    ============================================================================
    ⚠️ Remember, `Username` is an OPAQUE TYPE and doesn't expose it's internals.
    The ONLY way to get a `Username` is to decode one from `json`. To get the
    `String`, we can expose the `toString` function, once we've decoded.

    It's quite nice to have each key element with it's own decoder and `toString`
    function, for ease of naming conventions.
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
