module Ports.LocalStorage exposing (main)

{-| ----------------------------------------------------------------------------
    LocalStorage example (for themes, cookies, and session)
    ============================================================================
    We can persist across our application by using LocalStorage. This will remain
    on our user's device until they clear their browser's cache. See the original
    examples from Elm Guide:
        @ https://ellie-app.com/8yYddD6HRYJa1 #!
        @ https://guide.elm-lang.org/interop/ports.html


    Cookies
    -------
    > A good article on Elm's view of cookies, which are discouraged ...
    > Or at least, you should take care when setting or accessing them!

        @ https://github.com/elm-lang/cookie


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
-- (1) Our `updateWithStorage` function isn't strictly necessary, but allows us
--     to set our `localStorage` with our `Ports.Settings` package functions from
--     ONE place (rather than within the 3 branches)
-- (2) `Cmd.batch` also isn't necessary in this example package. We have no extra
--      commands to run! However, if we _were_ to add a new `Cmd` in any one of
--      our branches, this would ensure the command runs, as well as setting our
--      `localStorage` centrally.

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleTheme theme ->
            updateSettings (\settings -> { settings | theme = theme }) model

        HideCookies ->
            updateSettings (\settings -> { settings | cookies = True }) model

        ClearSession ->
            updateSettings (\settings -> { settings | session = "" }) model

{- @rtfeldman's helper function for updating our model (settings) -}
updateSettings : (P.Settings -> P.Settings) -> Model -> ( Model, Cmd Msg )
updateSettings transform model =
    ( { model | settings = transform model.settings }, Cmd.none )

{- (1) -}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) = update msg oldModel
    in
    ( newModel,
      Cmd.batch [ P.setStorage (P.encoder newModel.settings), cmds ] -- (2)
    )

