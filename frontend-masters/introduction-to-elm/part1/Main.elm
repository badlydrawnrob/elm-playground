module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)


{-| See the notes in `Documents/Library/code/elm`

# Task

1.  Add a logo and tagline to the banner
2.  Use the variable `banner` within `main`

-}


banner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "Conduit" ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]


feed =
    div [ class "feed-toggle" ] [ text "(In the future we’ll display a feed of articles here!)" ]


main =
    div [ class "home-page" ]
        [ banner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ] [ feed ]
                , div [ class "col-md-3" ] []
                ]
            ]
        ]
