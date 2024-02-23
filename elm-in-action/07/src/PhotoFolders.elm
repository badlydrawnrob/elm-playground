module PhotoFolders exposing (main)

import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Dict exposing (Dict)


-- Model -----------------------------------------------------------------------

-- #1: Instead of a `List Photo` or an `Array Photo`, we're using a `Dict`.
--     A `Dict` must have a `comparable` as it's Key. It's Value can be anything.
--     This make our `Photo`s much quicker to find/search.
--
--     As our `init` won't have access to the server's `Photo`s, we'll need to
--     start off with an empty dictionary: `Dict.empty`
--
-- #2: We're getting data from the server right away, by sending a `Cmd`
-- #3: For now, ignore the server's response and succeed with `initialModel`.

type alias Model =
  { selectedPhotoUrl : Maybe String
  , photos : Dict String Photo  -- #1
  }

initialModel : Model
initialModel =
  { selectedPhotoUrl = Nothing
  , photos = Dict.empty  -- #1
  }

init : () -> ( Model, Cmd Msg )
init _ =
  ( initialModel
  , Http.get  -- #2
      { url = "http://elm-in-action.com/folders/list"
      , expect = Http.expectJson GotInitialModel modelDecoder
      }
  )

modelDecoder : Decoder Model
modelDecoder =
  Decode.succeed initialModel  -- #3


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
--
-- #3: This is a little complex. We need to check:
--
--     a) Does `selectedPhotoUrl` contain a `String`?
--     b) If so, use this value for `Dict.get` function. If the`comparable`
--       value (a `String`) has a matching `Key` in our Dictionary, grab it's
--       value (a `Photo`).
--     c) If we have both a `String` value in `selectedPhotoUrl`, AND it's also
--        matching our `Dict.get` Key in our `Dict`ionary — return it's Value.
--        Pass that value to call our `viewSelectedPhoto` function to build the image.
--     d) If there is no `selectedPhotoUrl`, return `Nothing`. If there is no
--        match in `Dict`ionary, return `Nothing`. (Share the `Nothing` case)

type alias Photo =
  { title : String
  , size : Int
  , relatedUrls : List String
  , url : String
  }


view : Model -> Html Msg
view model =
  let
    photoByUrl : String -> Maybe Photo
    photoByUrl url =
      Dict.get url model.photos

    selectedPhoto : Html Msg
    selectedPhoto =
      case Maybe.andThen photoByUrl model.selectedPhotoUrl of  -- #3b, #3a
          Just photo ->
            viewSelectedPhoto photo                            -- #3c

          Nothing ->
            text ""                                       -- #3c
    in
      div [ class "content" ]
        [ h1 [] [ text "The Grooviest Folders the World Has Ever Seen" ]
        , div [ class "selected-photo" ] [ selectedPhoto ]
        ]



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
