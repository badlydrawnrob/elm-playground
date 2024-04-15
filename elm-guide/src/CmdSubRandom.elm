module CmdSubRandom exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (src, title)
import Html.Events exposing (..)
import Random

{-| Generate a random dice

    Improvements that could be made:
    --------------------------------

    1. Using `Random.map` could allow us to store all `Random.generator`s
       in a simple `Model Int DieFace DieFace` without the need for extra
       record fields.
    2. So rather than having multiple `Msg` types, we'd have a single
       `NewFace Int Image Image` structure.
    3. Have the dice flip around randomly before they settle on
         a final value

    Tasks:
    ------



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

type alias Model =
  { dieInt : Int
  , dieFace : (List DieFace)
  }

initialModel : Model
initialModel =
  { dieInt = 1
  , dieFace = [One, One]
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( initialModel
  , Cmd.none
  )


-- Update ----------------------------------------------------------------------

type Msg
  = Roll
  | NewFace Int
  | NewFaceImage (List DieFace)

type DieFace
  = One
  | Two
  | Three
  | Four
  | Five
  | Six

type alias Image =
  String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      Roll ->
        ( model
        , Cmd.batch
          [ randomInt
          , randomImageGenerator
          ]
        )

      NewFace newFace ->
        ( { model | dieInt = newFace }
        , Cmd.none
        )

      NewFaceImage newFace ->
        ( { model | dieFace = newFace }
        , Cmd.none
        )


-- Original
randomInt : Cmd Msg
randomInt =
  Random.generate NewFace (Random.int 1 6)

randomImage : Random.Generator DieFace
randomImage =
  Random.weighted
    (10, One)
    [ (10, Two)
    , (10, Three)
    , (10, Four)
    , (20, Five)
    , (40, Six)
    ]

randomList : Random.Generator (List DieFace)
randomList =
  Random.list 2 randomImage

randomImageGenerator : Cmd Msg
randomImageGenerator =
  Random.generate NewFaceImage randomList


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (String.fromInt model.dieInt) ]
    , div []
        (List.map viewDieFace model.dieFace)
    , button [ onClick Roll ] [ text "Roll" ]
    ]

viewDieFace : DieFace -> Html Msg
viewDieFace face =
  let
    imgName = dieFace face
  in
    img [ src (urlPrefix ++ imgName ++ ".png")
        , title ("die face " ++ imgName)
        ] []

dieFace : DieFace -> Image
dieFace face =
  case face of
      One   -> "one"
      Two   -> "two"
      Three -> "three"
      Four  -> "four"
      Five  -> "five"
      Six   -> "six"

urlPrefix : String
urlPrefix = "./img/dieface-"
