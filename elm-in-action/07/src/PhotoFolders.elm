module PhotoFolders exposing (main)

import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)


-- Model -----------------------------------------------------------------------

-- #1: We're getting data from the server right away, by sending a `Cmd`
-- #2: For now, ignore the server's response and succeed with `initialModel`.

type alias Model =
  { selectedPhotoUrl : Maybe String }

initialModel : Model
initialModel =
  { selectedPhotoUrl = Nothing }

init : () -> ( Model, Cmd Msg )
init _ =
  ( initialModel
  , Http.get  -- #1
      { url = "http://elm-in-action.com/folders/list"
      , expect = Http.expectJson GotInitialModel modelDecoder
      }
  )

modelDecoder : Decoder Model
modelDecoder =
  Decode.succeed initialModel  -- #2


-- Update ----------------------------------------------------------------------

-- #1: Accepts the new model we recieved from the server
-- #2: We'll ignore page load errors for now.

type Msg
  = ClickedPhoto String
  | GotInitialModel (Result Http.Error Model)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ClickedPhoto url ->
      ( { model | selectedPhotoUrl = Just url }, Cmd.none )

    GotInitialModel (Ok newModel) ->
      ( newModel, Cmd.none )  -- #1

    GotInitialModel (Err _) ->
      ( model, Cmd.none )


-- View ------------------------------------------------------------------------

-- #1: I think this is the correct way to do this. Remember that in this
--     scenario a `msg` isn't returned. In other scenarios `msg` is a type variable,
--     or else it'd be a `Msg`.
--     @ https://tinyurl.com/elm-lang-html-attr-src
--
-- #2: Here we cycle through a list of urls (Strings) and generate our thumbs

type alias Photo =
  { title : String
  , size : Int
  , relatedUrls : List String
  , url : String
  }


view : Model -> Html Msg
view model =
  h1 [] [ text "The Grooviest Folders the World Has Ever Seen" ]


urlPrefix =
  "http://elm-in-action.com/"

imgSource : String -> String -> Attribute msg  -- #1
imgSource url size =
  src (urlPrefix ++ "photos/" ++ url ++ size)

viewSelectedPhoto : Photo -> Html Msg
viewSelectedPhoto photo =
  div
    [ class "selected-photo" ]
    [ h2 [] [ text photo.title ]
    , img [ (imgSource photo.url "/full") ] []
    , span [] [ text (String.fromInt photo.size ++ "KB") ]
    , h3 [] [ text "Related" ]
    , div [ class "related-photos" ]
        (List.map viewRelatedPhoto photo.relatedUrls)  -- #2
    ]

viewRelatedPhoto : String -> Html Msg
viewRelatedPhoto url =
  img
    [ class "related-photo"
    , onClick (ClickedPhoto url)
    , (imgSource url "/thumb")
    ]
    []

-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
