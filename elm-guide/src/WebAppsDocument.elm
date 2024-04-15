module WebAppsDocument exposing (..)

import Browser exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Buttons exposing (Msg(..))

{-| A single HTML page

    `Browser.document` gives you a little more control over
    the Html such as the `title`. You can specify what's in
    the `<body>` too. It's just a list of `Html Msg`, so there
    could be more than one element (multiple wrapper `div`s,
    for instance).

    The downsides are that you'd have to include your CSS some
    other way than including it in the `<link>`, such as `elm-css`
    or `elm-ui`, which to me is total overkill ...

    You can compile this file into an `index.html` file with `elm make`;
    Alternatively, you can compile with `--output=` and then call it
    as normal in your own `index.html` file, using the `head` for your
    external CSS file ... Elm will simply replace the `title` and the
    `body` tags with `view`.

    @ https://stackoverflow.com/q/68836013
    @ https://package.elm-lang.org/packages/elm/browser/latest/Browser#document
-}


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
  Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- Model -----------------------------------------------------------------------

type alias Model
  = { counter : Int }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model 0
  , Cmd.none
  )

-- View ------------------------------------------------------------------------

type alias Document msg =
  { title : String
  , body : List (Html msg)
  }

view : Model -> Document Msg
view model =
  { title = (String.fromInt model.counter) ++ " is the number"
  , body = [
      div []
        [ h1 [] [ text "A test document" ]
        , input [ value (String.fromInt model.counter) ] []
        , button [ onClick Increment ] [ text "increment" ]
        , button [ onClick Decrement ] [ text "decrement" ]
        ]
    ]
  }


-- Update ----------------------------------------------------------------------

type Msg
  = Increment
  | Decrement

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
      Increment ->
        ( { model | counter = model.counter + 1 }
        , Cmd.none
        )

      Decrement ->
        if model.counter == 0 then
          ( model, Cmd.none )
        else
          ( { model | counter = model.counter - 1 }
          , Cmd.none
          )


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
