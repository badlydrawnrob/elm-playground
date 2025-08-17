port module Ports.Settings exposing (Settings, decoder, encoder, setStorage, Theme(..), themeToggle, themeToString)

{-| ----------------------------------------------------------------------------
    Ports (user settings)
    ============================================================================
    Here we can setup our settings for theme (light/dark), cookies, and whatever
    else we might need to persist across our application! Our application will
    not be a SPA, but simple files with embedded Elm on each page.

    Errors
    ------
    1. We need some way to convert a `String` to a `Theme`. If you use
       `D.map` you'd have to have to covert the `_` other strings case.
       @ https://stackoverflow.com/a/61857967
    2. If the decoder and the `settings` localStorage are not in sync, we can
       error (see `init` in `LocalStorage.elm` and then reset the settings with
       the new encoder!

    Wishlist
    --------
    1. Should cookies have more options?

-}

import Json.Decode as D exposing (..)
import Json.Encode as E exposing (..)


-- Ports -----------------------------------------------------------------------

port setStorage : E.Value -> Cmd msg
-- port getStorage : (E.Value -> msg) -> Cmd msg


-- Types -----------------------------------------------------------------------

type alias Settings =
    { theme : Theme
    , cookies : Bool
    , session : String
    }

type Theme
    = Light
    | Dark

themeToString : Theme -> String
themeToString theme =
    case theme of
        Light -> "light"
        Dark -> "dark"

themeToggle : Theme -> Theme
themeToggle theme =
    case theme of
        Light -> Dark
        Dark -> Light


-- Decoders / Encoders ---------------------------------------------------------

decoder : D.Decoder Settings
decoder =
    D.map3 Settings
        ((D.field "theme" D.string)
            |> D.andThen decoderTheme)
        (D.field "cookies" D.bool)
        (D.field "session" D.string)

decoderTheme : String -> D.Decoder Theme
decoderTheme str =
    case str of
        "light" -> D.succeed Light
        "dark" -> D.succeed Dark
        _ -> D.fail "Invalid theme" -- #! (1)

encoder : Settings -> E.Value
encoder { theme, cookies, session } =
    E.object
        [ ("theme", E.string (themeToString theme))
        , ("cookies", E.bool cookies)
        , ("session", E.string session)
        ]

