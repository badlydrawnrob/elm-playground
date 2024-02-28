import Browser
import Html exposing (Html, Attribute, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

{-| The Brief:

    A simple app that reverses the contents of a text field.

    1. In the Elm Guide, `String.reverse` is called in `view`
    2. Previous versions of mine also only kept the `String.reverse`
       version of the `String` which I updated in a record.
    3. Finally, I've stored both the original user input, AND the
       reversed string. There's a record entry for both.

    @ https://elm-lang.org/docs/records#updating-records


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
  { content : String
  , reverseContent : String
  }

init : Model
init =
  { content = ""
  , reverseContent = ""
  }

-- Update ----------------------------------------------------------------------

type Msg
  = Change String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Change str ->
      { model | content = str, reverseContent = (String.reverse str) }


-- View ------------------------------------------------------------------------

-- #1: `onInput` requires a function that takes a `String` and returns a `Msg`.
--     so our "container" of type `Msg` will hold that `String`.
-- #2: Here I've changed the code slightly so that the `Model` record holds
--     the reversed string.

view : Model -> Html Msg
view model =
  div []
  [ input
      [ type_ "text"
      , placeholder "Text to reverse"
      , value model.content
      , onInput Change ] []    -- #1
  , text model.reverseContent  -- #2
  ]
