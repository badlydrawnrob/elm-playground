module PhotoGroove exposing (Status(..), Msg(..), Photo, urlPrefix, view, main, photoDecoder, initialModel)

{-|
    Rules:
      Design Guidelines: https://package.elm-lang.org/help/design-guidelines
      Styleguide: https://elm-lang.org/docs/style-guide
      Other styleguides: https://github.com/NoRedInk/elm-style-guide
                         https://gist.github.com/laszlopandy/c3bf56b6f87f71303c9f
                         https://github.com/ohanhi/elm-style-guide

    Be sure to check:
      1. All View functions should be prepended with `view`?
      2. Helper functions seem to ignore this, so ...
      3. Perhaps it's all functions that return `Html` start with `view`?
      4. The `()` type (known as unit) is both a type and a value.
         `function () = ...` only accepts the value `()`.
      5. The type `Program () Model Msg` refers to an Elm Program with no flags,
         whose model type is `Model` and whose message type is `Msg`.

    Earlier versions:
      1. Chapter 02:
            @ http://tinyurl.com/elm-in-action-chapter-02-done
            @ http://tinyurl.com/elm-in-action-c02-full-notes
      2. Two variations of `case`:
            Update with `if`: http://tinyurl.com/elm-in-action-update-if
            Update with `case`: http://tinyurl.com/elm-in-action-update-case
      4. Chapter 03:
            @ http://tinyurl.com/elm-in-action-chapter-03-done
            @ http://tinyurl.com/elm-in-action-c03-full-notes
      5. Chapter 04:
            @ http://tinyurl.com/elm-in-action-c04-full-notes
      6. Chapter 05:
            << REMOVED >>
      7. Chapter 06:
            << REMOVED >>

    Here's what we're doing in Chapter 06:
      1. Storing values with associated keys using dictionaries
      2. Building interactive trees by using recursive custom types
      3. Using intermediate representations to decode json incrementally
      4. Decoding recursive data structures with recursive json decoders
-}

import Html exposing (..)
import Html.Attributes exposing (class, classList, id, name, title, type_, src)
import Html.Events exposing (onClick)
import Browser
import Random
import Http
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)


-- View ------------------------------------------------------------------------

type Msg
  = ClickedPhoto String
  | ClickedSize ThumbnailSize
  | ClickedSurpriseMe
  | GotRandomPhoto Photo
  | GotPhotos (Result Http.Error (List Photo))

view : Model -> Html Msg
view model =
  div [ class "content" ] <|
    case model.status of
      Loaded photos selectedUrl ->
        (viewLoaded photos selectedUrl model.chosenSize)

      Loading ->
        []

      Errored errorMessage ->
        [ text ("Error: " ++ errorMessage) ]

viewLoaded : List Photo -> String -> ThumbnailSize -> List (Html Msg)
viewLoaded photos selectedUrl chosenSize =
    [ h1 [] [ text "Photo Groove" ]
    , button
      [ onClick ClickedSurpriseMe ]
      [ text "Surprise Me!" ]
    , h3 [] [ text "Thumbnail Size:" ]
    , div [ id "choose-size" ]
      (List.map viewSizeChooser [ Small, Medium, Large ] )
    , div [ id "thumbnails", class (sizeToString chosenSize) ]
        (List.map
          (viewThumbnail selectedUrl) photos
        )
    , img
        [ class "large"
        , src (urlPrefix ++ "large/" ++ selectedUrl)
        ] []
    ]


-- Helper functions --

urlPrefix : String
urlPrefix =
  "http://elm-in-action.com/"

viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , title (thumb.title ++ " [" ++ String.fromInt thumb.size ++" KB]")
      , classList [ ( "selected", selectedUrl == thumb.url ) ]
      , onClick (ClickedPhoto thumb.url)
      ] []

viewSizeChooser : ThumbnailSize -> Html Msg
viewSizeChooser size =
  span [] [
    label []
    [ input [
        type_ "radio", name "size", onClick (ClickedSize size)
      ] []
    , text (sizeToString size)
    ]
  ]

sizeToString : ThumbnailSize -> String
sizeToString size =
  case size of
      Small -> "small"
      Medium -> "med"
      Large -> "large"


-- Model -----------------------------------------------------------------------

type ThumbnailSize
  = Small
  | Medium
  | Large

type alias Photo =
  { url : String
  , size : Int
  , title : String }

photoDecoder : Decoder Photo
photoDecoder =
  succeed Photo
    |> required "url" string
    |> required "size" int
    |> optional "title" string "(untitled)"

type Status
  = Loading
  | Loaded (List Photo) String
  | Errored String

type alias Model =
  { status : Status
  , chosenSize : ThumbnailSize
  }

initialModel : Model
initialModel =
  { status = Loading
  , chosenSize = Medium
  }


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    GotRandomPhoto photo ->
      ( { model | status = selectUrl photo.url model.status }  -- #1
      , Cmd.none )

    ClickedSize size ->
      ( { model | chosenSize = size }, Cmd.none )

    ClickedPhoto url ->
      ( { model | status = selectUrl url model.status }
      , Cmd.none )

    ClickedSurpriseMe ->
      case model.status of
        Loaded [] _ ->
          ( model, Cmd.none )
        Loaded (firstPhoto :: otherPhotos) _ ->
          ( Random.uniform firstPhoto otherPhotos
              |> Random.generate GotRandomPhoto
              |> Tuple.pair model
          )
        Loading ->
          ( model, Cmd.none )
        Errored errorMessage ->
          ( model, Cmd.none )

    GotPhotos (Ok photos) ->
      case photos of
        (first :: rest) ->
          ( { model | status = Loaded photos first.url }, Cmd.none )
        [] ->
          ( { model | status = Errored "O photos found" }, Cmd.none )

    GotPhotos (Err _) ->
      ( { model | status = Errored "Server error!" }, Cmd.none )


-- helper functions --

selectUrl : String -> Status -> Status
selectUrl url status =
  case status of
      Loaded photos _ ->
        Loaded photos url
      Loading ->
        status
      Errored errorMessage ->
        status


-- Commands --------------------------------------------------------------------

initialCmd : Cmd Msg
initialCmd =
  Http.get
    { url = "http://elm-in-action.com/photos/list.json"
    , expect = Http.expectJson GotPhotos (list photoDecoder)
    }

-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
  Browser.element
    { init = \_ -> ( initialModel, initialCmd )
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
