module PhotoGroove exposing (main)

{-| Beginning our Elm app:
    Photo Groove!

    : #1 Declares a new module
    : #2 Imports module's elements

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
import Html.Events exposing (onClick)


-- Constants ------------------------------------------------------------
-- : #1 Split out reusable stuff into separate constants
urlPrefix =
  "http://elm-in-action.com/"


-- View ------------------------------------------------------------------------
-- This should base it's return value on the model argument
--
-- : #3 h1 element with an empty attributes list
--
-- : #4 An Html element accepts two lists:
--      - An attributes list
--      - A child list
--
--   a) `List.map` returns a list, so we can use this function! However, now that
--      our `model` is a `record` that contains a `list of url` and `selectedUrl`,
--      we need to be more specific about which element to pass `List.map` ...
--      - `model.selectedUrl` is passed to the `viewThumbnail` function (to check "selected")
--      - `model.photos` is passed to the `List.map` to access `list of url` records!
--
--   b) Here we're using the `model.selectedUrl` to add a large image
--
-- : #5 We're passing `viewThumbnail` as the 1st argument to our _higher order
--      function_ `List.map` along with the `model` list of `url string` records.
--
--      - Div is expecting a `[]` list of Html elements, so we need to wrap
--        our mapping function with `()` parenthesis.
--
--    a) We've changed the hardcoded list of `img` to a dynamic `img` element
--       in a function called `viewThumbnail`. This is passed to `List.map` in view.
--
--    b) We're also using conditional loading. Is it a `selected` image or not?
--
--    c) We need to capture the event, and pass a `msg` data for update to consume.
--       The Elm Runtime takes care of managing event listeners behind the scenes,
--       so this one-line addition is the only change we need to make to our view.
--
-- : #6 We need some value to store our `selected` image
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]  -- #3
    , div [ id "thumbnails" ]
        (List.map                    -- #4a
          (viewThumbnail model.selectedUrl)
          model.photos
        )
    , img
        [ class "large"
        , src (urlPrefix ++ "large/" ++ model.selectedUrl)  -- #4b
        ] []
    ]


-- See `Figure 2.8`
-- : 1 We pass `List.map` a translation function and a list
-- : 2 It runs that translation function on each value in the list.
-- : 3 `List.map` returns a new list containing the translated values.

-- Helper functions ------------------------------------------------------------
-- Helps another function to do it's job. Used in the `view` function
-- where we've pulled out the image to use in the `view->img` list.
--
-- : Remember that `++` concatonates strings!
-- : `List.map` will pass through a record `{ url = "string" }` to `thumb`
-- : `thumb` can access the `url` (string) from the record.
viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)                                -- #5a
      , classList [ ("selected", selectedUrl == thumb.url)          -- #5b
      , onClick { description = "ClickedPhoto", data = thumb.url }  -- #5c
      ]
      ] []


-- Model -----------------------------------------------------------------------
-- We create a list of _records_
-- each record containing a `url` string
initialModel =
  { photos =
    [ { url = "1.jpeg" }  -- #5
    , { url = "2.jpeg" }
    , { url = "3.jpeg" }
    ]
  , selectedUrl = "1.jpeg"  -- #6
  }


-- Update --
-- Look at the message received,
-- Look at the current model
-- Use these to find new model
update msg model =
  if msg.description == "ClickedPhoto" then
    { model | selectedUrl = msg.data }
  else
    model

-- View --
-- Pass the model to the view in main
main =
  view initialModel
