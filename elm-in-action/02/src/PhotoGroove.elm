module PhotoGroove exposing (main)
-- #1

{-| Photo Groove

    See this link for full comments and notes:
    @

    : #1 The name of our module

    : #2 The other modules we’re importing

    : #3 The `view` function takes the current model and returns some HTML.

    : #4 `viewThumbnail` is partially applied here.

    : #5 When the user clicks, this message is sent to update.

    : #6 Changes the selected URL to the photo the user clicked

    : #7 Browser.sandbox describes our complete application.
-}

-- #2
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Browser


-- View ------------------------------------------------------------------------
-- #3
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]
    , div [ id "thumbnails" ]
        (List.map
          (viewThumbnail model.selectedUrl)  -- #4
          model.photos
        )
    , img
        [ class "large"
        , src (urlPrefix ++ "large/" ++ model.selectedUrl)  -- #4b
        ] []
    ]

-- Helper functions --

urlPrefix =
  "http://elm-in-action.com/"

viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , classList [ ("selected", selectedUrl == thumb.url) ]
      , onClick { description = "ClickedPhoto", data = thumb.url }  -- #5
      ] []


-- Model -----------------------------------------------------------------------

initialModel =
  { photos =
    [ { url = "1.jpeg" }  -- #5
    , { url = "2.jpeg" }
    , { url = "3.jpeg" }
    ]
  , selectedUrl = "1.jpeg"  -- #6
  }


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
