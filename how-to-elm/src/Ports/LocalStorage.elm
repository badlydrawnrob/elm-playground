module Ports.LocalStorage exposing (main)

{-| ----------------------------------------------------------------------------
    LocalStorage example (for themes, cookies, and session)
    ============================================================================
    We can persist across our application by using LocalStorage. This will remain
    on our user's device until they clear their browser's cache. See the original
    examples from Elm Guide:
        @ https://ellie-app.com/8yYddD6HRYJa1
        @ https://guide.elm-lang.org/interop/ports.html

    Notes
    -----
    1. I'm using @rtfeldman's "magic" nested settings state pattern.
       @ https://tinyurl.com/elm-spa-login-update
    2. If the decoder structure changes, we will receive an `Err`. This means
       we'll load the error state and on next save, the new settings `setItem`.

    Wishlist
    --------
    1. How do I "flush" the cache for new settings version?
        - Resaving the file, or `?version`ing the import doesn't work.
        - You could set a timer on the `localStorage`?

-}

import Browser
import Html exposing (button, Html, main_, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports.Settings as P exposing (..)
import Json.Decode as D
import Json.Encode as E
import CustomTypes.Songs exposing (Msg)


-- Main ------------------------------------------------------------------------
-- The second argument is the initial settings (flags)

main : Program E.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = \_ -> Sub.none
        }

init : E.Value -> ( Model, Cmd Msg )
init flags =
    (
        case D.decodeValue P.decoder flags of
            Ok settings ->
                { settings = settings }
            Err _ -> -- #! (2)
                { settings = { theme = Light, cookies = False, session = "logged in" } }
    , Cmd.none
    )


-- Model -----------------------------------------------------------------------

type alias Model =
    { settings : P.Settings }


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
    main_ []
        [ viewThemeButton model.settings.theme
        , button [ onClick HideCookies] [ text "Hide cookies" ]
        , button [ onClick ClearSession] [ text "Clear session" ]
        ]

viewThemeButton : Theme -> Html Msg
viewThemeButton theme =
    button [ onClick (ToggleTheme (P.themeToggle theme)) ]
        [ text (P.themeToString theme) ]

-- Messages --------------------------------------------------------------------

type Msg
    = ToggleTheme Theme
    | HideCookies
    | ClearSession


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleTheme theme ->
            updateSettings (\settings -> { settings | theme = theme }) model

        HideCookies ->
            updateSettings (\settings -> { settings | cookies = True }) model

        ClearSession ->
            updateSettings (\settings -> { settings | session = "" }) model

{- Helper function for update. Updates the settings -}
updateSettings : (P.Settings -> P.Settings) -> Model -> ( Model, Cmd Msg )
updateSettings transform model =
    ( { model | settings = transform model.settings }, Cmd.none )

updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmd ) = update msg oldModel
    in
    ( newModel,
      P.setStorage (P.encoder newModel.settings) -- elm guide uses `Cmd.batch`
    )

