module CustomTypes.Cred exposing (Cred, decoder, encodeToken, username)

{-| ----------------------------------------------------------------------------
    Simple `Cred`entials with `Username` custom type
    ============================================================================
    ⚠️ Remember, `Cred` is an OPAQUE TYPE. You have to expose the functions that
    create and transform this type. `Username` is also an opaque type. See the module's `toString` function, as
    well as it's `decoder`.

    The only way to create these opaque types is when decoding from `json`.

    What I learned
    --------------
    1. To access the `username` function, we could import as
       `Cred` (the module) and use `Cred.username` to get the function. We can
       then pass `username` the `Cred` (decoded custom type) value.
    2. Using a record isn't necessary for so few values
    3. But a record can be deconstructed (Cred { token }) without `_`, which
       makes life a little easier.
    4. Don't fall into the trap of making too many "getters" or "setters".
        - The whole point of Opaque Types is to hide implementation detail.
        - Only expose what's absolutely essential (such as `Username`)

    Gotchas
    -------
    > Username is an OPAQUE TYPE. It doesn't expose it's externals.
    > This means `String` is only accessible with the `toString` function.

    To get the username `String`, you'll need to first pull out the
    `Username` value from `Cred`, then use `Username.toString` from
    the `Username` module!

-}

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import CustomTypes.Username as Username

type Cred
    = Cred Username String

username : Cred -> Username
username (Cred username _) =
    username -- See `Username` module


-- Decoders --------------------------------------------------------------------

decoder : Decoder Cred
decoder =
    Decode.succed Cred
        |> required "username" Username.decoder
        |> required "token" Decode.string

-- Encoders --------------------------------------------------------------------

encodeToken : Cred -> Value
encodeToken (Cred _ token) =
    Encode.string token
