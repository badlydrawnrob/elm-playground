module File.UploadToServer exposing (..)

{-| Uploading an image file to a server
    ----------------------------------

    Based on the original script @ https://package.elm-lang.org/packages/elm/file/latest/

-}

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Task



-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { image : Maybe String
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Nothing, Cmd.none )



-- UPDATE


type Msg
  = ImageRequested
  | ImageSelected File
--   | ImageLoaded String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ImageRequested ->
      ( model
      , Select.file ["image/jpg"] ImageSelected
      )

    ImageSelected file ->
      ( model
      , Task.perform ImageLoaded (File.toString file)
      )

    CsvLoaded content ->
      ( { model | image = Just content }
      , Cmd.none
      )



-- VIEW


view : Model -> Html Msg
view model =
  case model.csv of
    Nothing ->
      button [ onClick ImageRequested ] [ text "Load CSV" ]

    Just content ->
      p [ style "white-space" "pre" ] [ text content ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
