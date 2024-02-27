import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)

{-| Additions:

    1. Add a `Reset` button
    2. No negative numbers

        - There may be better ways to do this, such as a Positive type:
          @ http://tinyurl.com/elm-lang-positive-integer-type
-}

-- Main ------------------------------------------------------------------------

main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }


-- Model -----------------------------------------------------------------------

type alias Model = Int

init : Model
init =
  0


-- Update ----------------------------------------------------------------------

type Msg
  = Increment
  | Decrement
  | Reset

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      if modelIsZero model then
        model
      else
        model - 1

    Reset ->
      0

modelIsZero : Model -> Bool
modelIsZero model =
  (==) model 0


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]  -- Reduce Int
    , div [] [ text (String.fromInt model) ]     -- The text
    , button [ onClick Increment ] [ text "+" ]  -- Increase Int
    , button [ onClick Reset ] [ text "Reset" ]  -- Reset to Zero
    ]
