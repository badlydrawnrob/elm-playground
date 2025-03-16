module Form.Simple exposing (..)

{-| A simple form

    Always start with the `Model` — what shape will our data take?
    Start with at least one field, then write the `view` and `update`
    functions. Gradually refactor the design until you get there.

    1. Enter a name and a password
    2. Validate passwords — do they match?
    3. Add some more simple `Bool` validations
       - Is not "" empty string
       - Is at least 8 characters long
    4. Convert 3 messages into ONE
       - Record pattern matching

    Obviously this is a fraction of the work needed to properly validate
    a form — and it should also be validated server side for security reasons!!

    NOTE:

    It seems like efforts to make generic validation libraries have not been
    too successful. I think the problem is that the checks are usually best
    captured by normal Elm functions. Take some args, give back a Bool or Maybe.
    E.g. Why use a library to check if two strings are equal? So as far as we
    know, the simplest code comes from writing the logic for your particular
    scenario without any special extras. So definitely give that a shot before
    deciding you need something more complex!
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import String exposing (any)
import Char exposing (isDigit, isLower, isUpper)
import Debug exposing (log)


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
  if (validatePassword model.password model.passwordAgain) then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]


validatePassword : String -> String -> Bool
validatePassword str1 str2 =
  if (validateStringEquals str1 str2) then
    validateStringCompare str1
  else
    False

validateStringEquals : String -> String -> Bool
validateStringEquals str1 str2 =
  log "validateStringEquals" (str1 == str2)

validateStringCompare : String -> Bool
validateStringCompare str =
  if (validateStringLength str) then
    log "validateStringContains" (validateStringContains str)
  else
    False

validateStringLength : String -> Bool
validateStringLength str =
  log "validateStringLength" (String.length str >= 8)

validateStringContains : String -> Bool
validateStringContains str =
  (any isDigit str)
    |> (&&) (any isUpper str)
    |> (&&) (any isLower str)
