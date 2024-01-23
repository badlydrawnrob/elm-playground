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
-- : #1 Error in the book (`photoListUrl`)
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]
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

urlPrefix : String  -- #1
urlPrefix =
  "http://elm-in-acdtion.com/list-photos"

viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , classList [ ("selected", selectedUrl == thumb.url) ]
      , onClick { description = "ClickedPhoto", data = thumb.url }
      ] []


-- Model -----------------------------------------------------------------------
-- : #1 To avoid duplication we can assign `url` a type alias
type alias Photo =
  { url : String }  -- #1

initialModel : { photos : List Photo, selectedUrl : String }  -- #1
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

update msg model =
  if msg.description == "ClickedPhoto" then
    { model | selectedUrl = msg.data }  -- #6
  else
    model


-- Main ------------------------------------------------------------------------

main =
  Browser.sandbox  -- #7
    { init = initialModel  -- can be any value
    , view = view          -- what the visitor sees
    , update = update      -- what the computer sees
    }
