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


-- Constants ------------------------------------------------------------
-- : #1 Split out reusable stuff into separate constants
urlPrefix =
  "http://elm-in-action.com/"


-- View ------------------------------------------------------------------------
-- This should base it's return value on the model argument
--
-- : #3 h1 element with an empty attributes list
--
-- : #4 Because each Html element accepts two lists:
--      - An attributes list
--      - A child list
--      we can use `List.map` function to return a list!
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
-- : #6 We need some value to store our `selected` image
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo Groove" ]  -- #3
    , div [ id "thumbnails" ] (List.map viewThumbnail model)     -- #4
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
viewThumbnail selectedUrl thumb =
  if selectedUrl == thumb.url then
    img [ src (urlPrefix ++ thumb.url)       -- #5a
        , class "selected"
        ] []
  else
    img [ src (urlPrefix ++ thumb.url) ] []  -- #5b


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

-- View --
-- Pass the model to the view in main
main =
  view initialModel
