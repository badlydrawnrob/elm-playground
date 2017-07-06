module Signup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


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


view : User -> Html Msg
view user =
    div []
        [ h1 [] [ text "Sign up" ]
        , Html.form []
            [ div []
                [ text "Name"
                , input
                    [ id "name"
                    , type_ "text"
                    , onInput SaveName
                    ]
                    []
                ]
            , div []
                [ text "Email"
                , input
                    [ id "email"
                    , type_ "email"
                    , onInput SaveEmail
                    ]
                    []
                ]
            , div []
                [ text "Password"
                , input
                    [ id "password"
                    , type_ "password"
                    , onInput SavePassword
                    ]
                    []
                ]
            , div []
                [ button
                    [ type_ "submit"
                    , onClick Signup
                    ]
                    [ text "Create my account" ]
                ]
            ]
        ]


type Msg
    = SaveName String
    | SaveEmail String
    | Save Password String
    | Signup



{-
   If a pattern does exist, `update` executes the code for that pattern. Otherwise, the application crashes. Therefore, it’s important to handle all possible incoming messages.
-}


update : Msg -> User -> User
update message model =
    case message of
        SaveName name ->
            { user | name = name }

        SaveEmail ->
            { user | email = email }

        SavePassword password ->
            { user | password = password }

        Signup ->
            { user | loggedIn = True }


main : Program Never User Msg
main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
