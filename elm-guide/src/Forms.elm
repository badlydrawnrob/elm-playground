module Forms exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Buttons exposing (init)
import Buttons exposing (update)
import Buttons exposing (Msg)

{-| A simple form

    Always start with the `Model` — what shape will our data take?
    Start with at least one field, then write the `view` and `update`
    functions. Gradually refactor the design until you get there.

    1. Enter a name and a password
    2. Validate passwords — do they match?
    3. Add some more simple `Bool` validations
       - Is not "" empty string
       - Is at least 8 characters long

    Obviously this is a fraction of the work needed to properly validate
    a form — and it should also be validated server side for security reasons!!
-}


-- Main ------------------------------------------------------------------------

main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }


-- Model -----------------------------------------------------------------------

-- #1: A type alias exposes a constructor function

type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  }

init : Model
init =
  Model "" "" ""  -- #1


-- Update ----------------------------------------------------------------------

-- #1: You could also pattern match on a record here to avoid having so many
--     messages which are essentially CRUD expressions.alias
--
--     @ http://tinyurl.com/elm-lang-pattern-match-record

type Msg
  = Name String  -- #1
  | Password String  -- #1
  | PasswordAgain String  -- #1

update : Msg -> Model -> Model
update msg model =
  case msg of
      Name name ->
        { model | name = name }

      Password password ->
        { model | password = password }

      PasswordAgain password ->
        { model | passwordAgain = password }


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Name" model.name Name
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
    , viewValidation model
    ]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

viewValidation : Model -> Html msg
viewValidation model =
  if model.password == model.passwordAgain then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]
