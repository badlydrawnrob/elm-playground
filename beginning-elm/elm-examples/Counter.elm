module Counter exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type alias Model =
    Int


initialModel : Model
initialModel =
    0


view : Model -> Html msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , text (toString model)
        , button [ onClick Increment ] [ text "+" ]
        ]


update : msg -> Model -> Model
update msg model =
    initialModel


main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
