module PhotoGroove exposing (main)

{-| Beginning our Elm app:
    Photo Groove!

    : #1 Declares a new module
    : #2 Imports other modules
    : #3 h1 element with an empty attributes list
    : #4 Put commas at the start of the line.
    : #5 img element with an empty children list
    : #6 We’ll discuss “main” later.

    We're exposing `main` but NOT `view` for other modules to import.
    Another module that imported `PhotoGroove` would get
    an error if it tried to access `PhotoGroove.view`.

    : Only exposed values can be accessed by other modules.
      As a general rule, it's best for our modules to expose
      _as little as possible_.
-}

-- #2
import Html exposing (..)
import Html.Attributes exposing (..)


view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]  -- #3
    , div [ id "thumbnails" ]        -- #4
      [ img [ src "http://elm-in-action.com/1.jpeg" ] []  -- #5
      , img [ src "http://elm-in-action.com/2.jpeg" ] []
      , img [ src "http://elm-in-action.com/3.jpeg" ] []
      ]
    ]

-- Model --
-- We create a list of _records_
-- each record containing a `url` string
initialModel =
  [ { url = "1.jpeg" }
  , { url = "2.jpeg" }
  , { url = "3.jpeg" }
  ]

-- View --
-- Pass the model to the view in main
main =
  view initialModel
