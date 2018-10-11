module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)



---- MODEL ----


type alias Model =
    {}


type DoorState
    = Opened
    | Closed
    | Locked


type AlarmState
    = Armed
    | Disarmed
    | Triggered


type Model
    = ViewRoom DoorState AlarmState


initialModel : Model
initialModel =
    ViewRoom Closed Armed



---- UPDATE ----


type Msg
    = Open
    | Close
    | Lock
    | Unlock
    | Arm
    | Disarm


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
