import Browser
import Html exposing (Html, Attribute, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

{-| The Brief:

    A simple app that reverses the contents of a text field.

    1. Originally I reversed the text in `update` (edited the model)
    2. In the Elm Guide, it's done in the `view` instead.

    I don't know which way is preferrable (I guess you should store
    the original first, and then convert it).

    I suppose it's possible to store both the original text
    (that the user is entering) and a separate record entry for the
    reversed text too. You'd have to clone it with a function.
-}

-- Main ------------------------------------------------------------------------

main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }


-- Model -----------------------------------------------------------------------

type alias Model =
  { content : String }

init : Model
init = { content = "" }

-- Update ----------------------------------------------------------------------

type Msg
  = Change String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Change str ->
      { model | content = str }


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
  [ input [ type_ "text", onInput Change ] []
  , text (String.reverse model.content)
  ]
