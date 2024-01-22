module PhotoGroove exposing (main)
-- #1

{-| Photo Groove

    @ http://tinyurl.com/elm-in-action-c02-full-notes

    Chapter 03:

    1. Improve code quality and ease of understanding for beginners.
    2. Let users choose between small, medium, large thumbnails.
    3. Add a "Surprise me!" button that randomly selects a photo.
-}

-- #2
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Browser
import Array exposing (Array)


-- View ------------------------------------------------------------------------
-- #3
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

photoListUrl : String
photoListUrl =
  "http://elm-in-acdtion.com/list-photos"

viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , classList [ ("selected", selectedUrl == thumb.url) ]
      , onClick { description = "ClickedPhoto", data = thumb.url }
      ] []


-- Model -----------------------------------------------------------------------

initialModel : { photos : List { url : String }, selectedUrl : String }
initialModel =
  { photos =
    [ { url = "1.jpeg" }
    , { url = "2.jpeg" }
    , { url = "3.jpeg" }
    ]
  , selectedUrl = "1.jpeg"
  }

photoArray : Array { url : String }
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
