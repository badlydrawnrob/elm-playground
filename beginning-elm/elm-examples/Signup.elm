module Signup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias User =
    { name : String
    , email : String
    , password : String
    , loggedIn : Bool
    }


initialModel : User
initialModel =
    { name = ""
    , email = ""
    , password = ""
    , loggedIn = False
    }



{-
   We exposed everything from the Html and Html.Attributes
   modules and both of them define a function called form,
   so we need to specify which module (Html.form)
-}


view : User -> Html msg
view user =
    div []
        [ h1 [] [ text "Sign up" ]
        , Html.form []
            [ div []
                [ text "Name"
                , input
                    [ id "name"
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ text "Email"
                , input
                    [ id "email"
                    , type_ "email"
                    ]
                    []
                ]
            , div []
                [ text "Password"
                , input
                    [ id "password"
                    , type_ "password"
                    ]
                    []
                ]
            , div []
                [ button
                    [ type_ "submit" ]
                    [ text "Create my account" ]
                ]
            ]
        ]


update : msg -> User -> User
update msg model =
    initialModel


main : Program Never User msg
main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
