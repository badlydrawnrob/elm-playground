module PhotoGroove exposing (main)

{-| Photo Groove

    @ http://tinyurl.com/elm-in-action-c02-full-notes

    Chapter 03:

    1. Improve code quality and ease of understanding for beginners.
    2. Let users choose between small, medium, large thumbnails.
    3. Add a "Surprise me!" button that randomly selects a photo.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Browser
import Array exposing (Array)


-- View ------------------------------------------------------------------------
-- : #1 Specifying our `onClick` handler message.
--      - Our message is a record
--      - `Html`'s type variable reflects the type of message
--        it sends to `update` in response to event handlers.
--        Our event handler here is `onClick`!
--
-- : #2 Add another message (a record) if a button is clicked
--
-- : #3 Error in the book (`photoListUrl`)
--
--   @ http://tinyurl.com/racket-lang-tick-and-handlers
--     Handlers and message changing is a bit like big-bang in Racket lang

type alias Msg =
  { description : String, data : String }  -- #1

view : Model -> Html Msg  -- #1
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]
    , button
      [ onClick { description = "ClickedSurpriseMe", data = "" } ]  -- #2
      [ text "Surprise Me!" ]
    , div [ id "thumbnails" ]
        (List.map
          (viewThumbnail model.selectedUrl)
          model.photos
        )
    , img
        [ class "large"
        , src (urlPrefix ++ "large/" ++ model.selectedUrl)
        ] []
    ]

-- Helper functions --

urlPrefix : String  -- #3
urlPrefix =
  "http://elm-in-action.com/list-photos"

viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , classList [ ("selected", selectedUrl == thumb.url) ]
      , onClick { description = "ClickedPhoto", data = thumb.url }
      ] []


-- Model -----------------------------------------------------------------------
-- : #1 To avoid duplication we can assign `url` a type alias
-- : #2 We've also created an alias for the `initialModel`
--      which tidies things up too.
type alias Photo =
  { url : String }  -- #1

type alias Model =
  { photos : List Photo  -- #1
  , selectedUrl : String }

initialModel : Model
initialModel =
  { photos =
    [ { url = "1.jpeg" }
    , { url = "2.jpeg" }
    , { url = "3.jpeg" }
    ]
  , selectedUrl = "1.jpeg"
  }

photoArray : Array Photo  -- #1
photoArray =
  Array.fromList initialModel.photos


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
  case msg.description of
    "ClickedPhoto" ->
      { model | selectedUrl = msg.data }
    "ClickedSurpriseMe" ->
      { model | selectedUrl = "2.jpeg" }
    _ ->
      model


-- Main ------------------------------------------------------------------------

main =
  Browser.sandbox  -- #7
    { init = initialModel  -- can be any value
    , view = view          -- what the visitor sees
    , update = update      -- what the computer sees
    }
