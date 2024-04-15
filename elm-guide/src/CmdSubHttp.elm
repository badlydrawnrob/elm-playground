module CmdSubHttp exposing (..)

import Browser
import Html exposing (Html, text, pre)
import Http

{-| Getting a book from a server

    We've graduated from using `Browser.sandbox` to a more
    capable `Browser.element`. This allows us to talk with the
    outside world, such as servers.

-}


-- Main ------------------------------------------------------------------------

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- Model -----------------------------------------------------------------------

type Model
  = Failure
  | Loading
  | Success String

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      { url = "https://elm-lang.org/assets/public-opinion.txt"
      , expect = Http.expectString GotText
      }
  )


-- Update ----------------------------------------------------------------------

type Msg
  = GotText (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      GotText result ->
        case result of
            Ok fullText ->
              (Success fullText, Cmd.none)

            Err _ ->
              (Failure, Cmd.none)


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "I was unable to load your book."

    Loading ->
      text "Loading ..."

    Success fullText ->
      pre [] [ text fullText ]
