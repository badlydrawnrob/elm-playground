module Main exposing (..)

{-| Introduction to Elm v2: early tests, using `elm-format`

I don't really like the way the comments are formatted, but I'll try it for this
tutorial at least.

-}

import Html exposing (..)


type alias Model =
    { name : String }



-- This is a test --------------------------------------------------------------


init =
    Model "Bobby"


view : Model -> Html msg
view model =
    div []
        [ text model.name
        , button [] [ text "click me" ]
        ]
