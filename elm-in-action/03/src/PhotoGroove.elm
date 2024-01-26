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
-- : #3 Create our radio buttons for choosing `ThumbnailSize`
--      (see #5 for more info)
--
-- : #4 Error in the book (`photoListUrl`)
--
--   @ http://tinyurl.com/racket-lang-tick-and-handlers
--     Handlers and message changing is a bit like big-bang in Racket lang
--
-- : #5 a) Convert our Custom Type `ThumbnailSize` into a string that we can use
--         for our checkbox in `viewSizeChooser`
--      b) Render the `class` of the `ThumbnailSize` depending on which
--         radio button the user chooses. The `sizeToString` function converts
--         a `ThumbnailSize` type to a `"string"` which we add to the `class`.

type alias Msg =
  { description : String, data : String }  -- #1

view : Model -> Html Msg  -- #1
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]
    , button
      [ onClick { description = "ClickedSurpriseMe", data = "" } ]  -- #2
      [ text "Surprise Me!" ]
    , h3 [] [ text "Thumbnail Size:" ]
    , div [ id "choose-size" ]
      (List.map viewSizeChooser [ Small, Medium, Large ] )  -- #3
    , div [ id "thumbnails", class (sizeToString model.chosenSize ) ]  -- #5b
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

urlPrefix : String  -- #4
urlPrefix =
  "http://elm-in-action.com/"

viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , classList [ ("selected", selectedUrl == thumb.url) ]
      , onClick { description = "ClickedPhoto", data = thumb.url }
      ] []

viewSizeChooser : ThumbnailSize -> Html Msg  -- #3
viewSizeChooser size =
  span [] [
    label []
    [ input [type_ "radio", name "size" ] []
    , text (sizeToString size)
    ]
  ]

sizeToString : ThumbnailSize -> String  -- #5a
sizeToString size =
  case size of
      Small -> "small"
      Medium -> "med"
      Large -> "large"



-- Model -----------------------------------------------------------------------
-- : #1 A Custom Type is not an alias. It's a brand new type!
-- : #2 To avoid duplication we can assign `url` a type alias
-- : #3 We've also created an alias for the `initialModel`
--      which tidies things up too.
-- : #4 a) Deconstructing a `Maybe` custom type. We're checking for results
--      that have an element (`Just typeVariable`) or don't exist `Nothing`.
--      b) `photo` is a `type variable` so can be named anything.
type ThumbnailSize  -- #1
  = Small
  | Medium
  | Large

type alias Photo =
  { url : String }  -- #2

type alias Model =
  { photos : List Photo  -- #3
  , selectedUrl : String
  , chosenSize : ThumbnailSize  -- #1
  }

initialModel : Model
initialModel =
  { photos =
    [ { url = "1.jpeg" }
    , { url = "2.jpeg" }
    , { url = "3.jpeg" }
    ]
  , selectedUrl = "1.jpeg"
  , chosenSize = Medium
  }

photoArray : Array Photo  -- #2
photoArray =
  Array.fromList initialModel.photos

getPhotoUrl : Int -> String  -- #4a
getPhotoUrl index =
  case Array.get index photoArray of
    Just photo ->                       -- #4b
      photo.url
    Nothing ->
      ""


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
