module CmdSubRandom exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random
import CmdSubHttp exposing (Msg)

{-| Generate a random dice

    Tasks:
    ------

      1. Show the die face as an image
      2. Create a weighted die with `Random.weighted`
      3. Add a second die and have them roll at the same time
      4. Have the dice flip around randomly before they settle on
         a final value

    Here's what we're doing
    -----------------------

    1. A `Generator` that describes _how_ to generate a random value
    2. A `Generate` function that manages side-effects via a `Cmd -> Msg`
    3. A `Msg` handler in `update` function.
    4. Our `View` handles the rendering for different states.

    Generators can do a lot!!
    -------------------------

    From small building blocks, you can do some really cool stuff!
    @ https://guide.elm-lang.org/effects/random

      type Symbol = Cherry | Seven | Bar | Grapes
      type alias Spin = { one : Symbol, two : Symbol, three: Symbol }

      symbol = Random.uniform Cherry [ Seven, Bar, Grapes ]

      spin = Random.map3 Spin symbol symbol symbol
}


-- Main ------------------------------------------------------------------------

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- Model -----------------------------------------------------------------------

type alias Model =
  { dieFace : Int }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model 1
  , Cmd.none
  )


-- Update ----------------------------------------------------------------------

type Msg
  = Roll
  | NewFace Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      Roll ->
        ( model
        , Random.generate NewFace (Random.int 1 6)
        )

      NewFace newFace ->
        ( Model newFace
        , Cmd.none
        )


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (String.fromInt model.dieFace) ]
    , button [ onClick Roll ] [ text "Roll" ]
    ]

