module PhotoGroove exposing (main)

{-|
    Rules:
      Design Guidelines: https://package.elm-lang.org/help/design-guidelines
      Styleguide: https://elm-lang.org/docs/style-guide
      Other styleguides: https://github.com/NoRedInk/elm-style-guide
                         https://gist.github.com/laszlopandy/c3bf56b6f87f71303c9f
                         https://github.com/ohanhi/elm-style-guide

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
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Browser
import Array exposing (Array)
import Random


-- View ------------------------------------------------------------------------

-- We've broken our `view` into different parts, which follow our `Status` type.
-- This means we can deconstruct our `Model` and give each function only what it
-- requires to work properly.
--
-- : 1) Our main function that takes a `Model`
-- : 2) Our child function that takes only what it needs:
--      `photos`, `selectedUrl`, and a `chosenSize`.
-- : 3) Our other `Status` loading states.
--
-- Also note that (2) returns a `List (Html Msg)` now.

type Msg
  = ClickedPhoto String
  | GotSelectedIndex Int
  | ClickedSize ThumbnailSize
  | ClickedSurpriseMe

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
    , div [ id "thumbnails", class (sizeToString chosenSize ) ]
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
      , classList [ ("selected", selectedUrl == thumb.url) ]
      , onClick (ClickedPhoto thumb.url)
      ] []

viewSizeChooser : ThumbnailSize -> Html Msg  -- #3
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

-- randomPhotoPicker : Random.Generator Int
-- randomPhotoPicker =
--   Random.int 0 (Array.length photoArray - 1)

-- Model -----------------------------------------------------------------------

-- #1: Change model to `Status` (original below)
--     @ http://tinyurl.com/elm-in-action-change-status
--
-- #2: Change `initialModel` to `Loading` (original below)
--     @ http://tinyurl.com/nhddmc8v

type ThumbnailSize
  = Small
  | Medium
  | Large

type alias Photo =
  { url : String }

type Status
  = Loading
  | Loaded (List Photo) String
  | Errored String

type alias Model =
  { status : Status  -- #1
  , chosenSize : ThumbnailSize
  }

initialModel : Model
initialModel =
  { status = Loading
  , chosenSize = Medium
  }

-- photoArray : Array Photo
-- photoArray =
--   Array.fromList initialModel.photos

-- getPhotoUrl : Int -> String
-- getPhotoUrl index =
--   case Array.get index photoArray of
--     Just photo ->
--       photo.url
--     Nothing ->
--       ""


-- Update ----------------------------------------------------------------------

-- 1) Instead of updating a `selectedUrl` string (which doesn't exist now),
--    we pass it a function (2). That function tackes a `url` (a "string") and a
--    `model.status`.
--
-- 2) This function doesn’t do much. If it’s passed a Status that is in the
--    Loaded state, it returns an updated version of that Status that has the
--    thumbnails’ selectedUrl set to the given URL. Otherwise, it returns the
--    Status unchanged.
--
--    - `_` underscore is kind of a placeholder. It indicates there's
--      a value here, but we choose not to use it.

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    GotSelectedIndex index ->
      ( { model | status = selectUrl (getPhotoUrl index) model.status }
      , Cmd.none )
    ClickedSize size ->
      ( { model | chosenSize = size }, Cmd.none )
    ClickedPhoto url ->
      ( { model | status = selectUrl url model.status }
      , Cmd.none )
    ClickedSurpriseMe ->
      ( model, Random.generate GotSelectedIndex randomPhotoPicker )

-- 2) helper function --

selectUrl : String -> Status -> Status
selectUrl url status =
  case status of
      Loaded photos _ ->
        Loaded photos url
      Loading ->
        status
      Errored errorMessage ->
        status
-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
  Browser.element
    { init = \flags -> ( initialModel, Cmd.none )
    , view = view
    , update = update
    , subscriptions = \model -> Sub.none
    }
