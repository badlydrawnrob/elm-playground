module WebAppsNav exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Debug

{-| For larger applications

    We'll create a "web app" with a bunch of different
    pages, starting with a single page

    The simple way to serve different pages would be to use
    separate Html files. That's fine and it works. It does have
    some weaknesses however:

    1. Blank Screens: the screen goes white every time you load new
       Html. Can we do a nice transition instead?

    2. Redundant requests: each package has a single `docs.json` file,
       but it gets loaded each time you visit a module like `String`
       or `Maybe`. Can we share the data between pages somehow?

    3. Redundant code: the homepage and the docs share a lot of functions,
       like `Html.text` and `Html.div`. Can this code be shared between
       pages?

    We can improve all three cases! Only load HTML once, and use URL routing.
    We use `Browser.application` for this.

    How it works
    ------------

    1. `init` gets the current `Url` from the browsers nav bar. this allows
       you to show different things depending on `Url`.

    2. When someone clicks a link, it is intercepted as a `UrlRequest`.
       This creates a message for your `update` where you can decide what
       to do next. Save scroll position, persist data, change the `Url` etc.

    3. When the URL changes, the new `Url` is sent to `onUrlChange`. The
       resulting message goes to `update where you can decide how to show
       the new page.

    The following example simply keeps track of the current URL.
    All the new and interesting stuff happens in `update`.
-}


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }


-- Model -----------------------------------------------------------------------

-- #1: This returns a function. It's a custom type.
--     @ https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#Key
--     @ https://stackoverflow.com/questions/66309002/what-is-a-browser-navigation-key-in-elm
-- #2: @ https://package.elm-lang.org/packages/elm/url/latest/Url#Url

type alias Model =
  { key : Nav.Key
  , url : Url.Url
  }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url, Cmd.none )


-- Update ----------------------------------------------------------------------

-- #1: @ https://package.elm-lang.org/packages/elm/browser/latest/Browser#UrlRequest
-- #2: @ https://package.elm-lang.org/packages/elm/url/latest/Url#Url

type Msg
  = LinkClicked Browser.UrlRequest  -- #1
  | UrlChanged Url.Url              -- #2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
      LinkClicked urlRequest ->
        case urlRequest of
          Browser.Internal url ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

          Browser.External href ->
            ( model, Nav.load href )

      UrlChanged url ->
        ( { model | url = url }
        , Cmd.none
        )


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


-- View ------------------------------------------------------------------------

view : Model -> Browser.Document Msg
view model =
  { title = "URL Interceptor"
  , body =
    [ text "The current URL is: "
    , b [] [ text (Url.toString (Debug.log "model-url" model.url)) ]
    , ul []
      [ viewLink "/home"
      , viewLink "/profile"
      , viewLink "/reviews/the-century-of-the-self"
      , viewLink "/reviews/public-opinion"
      , viewLink "/reviews/shah-of-shahs"
      ]
    ]
  }

viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]
