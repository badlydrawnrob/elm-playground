module Form.Simple exposing (..)

{-| ----------------------------------------------------------------------------
    A simple form
    ============================================================================
    > ⚠️ Forms are a LOT of work, even simple ones!

    Prototype with Tally Forms as they're easy and quick, until:

        - You understand the customer and their journey
        - You understand the API and it's data
        - You are clear on what errors may occur


    Sketch it out
    -------------
    > Previous version:
    >

    Always start with data. What's `Model's shape?
    Simplify your code to reduce user input state.
    Simplify your code so it's easy to read (a single `Msg` isn't easier)
    Use simple expressions rather than lots of helper functions

    Make the customer journey easy to enter valid data, and clear when they've
    made a mistake. This also reduces the complexity of validation checks. Always
    validate your data on the server too!


    Form data
    ---------
    1. What's the simplest form our user input can take?
    2. What validations and guards do we need to put in place?
    3. How do we want to display validation errors?
    4. How do we want to display success?


    User input
    ----------
    > Enter a name and a password

    - Are any strings empty?
    - Do the passwords match?
    - Is the password at least 8 characters long?


    Validation method
    -----------------
    > ⚠️ We're basically using chained `bool` statements here

    For small error chains this might be ok, but at scale and with larger chains
    this becomes unreadable! Check better methods, like `List.filter` or other.


    Messages
    --------
    > Our messages are maybe more complicated than needed.

    1. It can be easier to read with full Html
    2. Individual field messages are fine for small forms

    ```
    type Msg
        = Name String
        | Password String
        | PasswordAgain String
    ```


    Similar is not the same
    -----------------------
    > Catch-all frameworks don't exist!
    > Rarely are two forms exactly the same.

    @rtfeldman says treat forms like programs. Hold onto the user input strings,
    use regular Elm functions to validate with `Bool`, `Maybe`, `Result`, or
    `List Error` and minimise dependencies. As far as we know, the simplest code
    comes from writing the logic for your particular scenario without any special
    extras. Give that a shot before deciding you need something more complex!


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    > We're using some premature opimizations which may not be needed.
    > Errors are also a tough cookie, so testing might be useful.

    1. Simplify `Msg` so each field has its own message?
    2. Simplify inputs by writing the Html out properly?
    3. Error chaining is a bit hard to read. What's better?
        - Would a `case` statement be better than nested `if`s?
        - Could you supply a table of conditions and error messages?
    4. Error messages aren't quite right
        - Currently you must enter both password field before getting feedback
          on the validity of the password.
    5. Add some tests using a table of possible states
        - "" "Abs0lute" ""
        - "" "Abs0lute" "Abs0lute"
        - And so on ...
    6. Save valid data somehow (as a `model.save` or server post)

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import String exposing (any)
import Char exposing (isDigit, isLower, isUpper)


-- Main ------------------------------------------------------------------------

main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }


-- Model -----------------------------------------------------------------------

type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  }

init : Model
init =
  Model "" "" ""  -- #1



-- Update ----------------------------------------------------------------------

type FieldType
  = Name
  | Password
  | PasswordAgain

fieldToString : FieldType -> String
fieldToString field =
  case field of
      Name ->
        "Name"

      Password ->
        "Password"

      PasswordAgain ->
        "Re-enter your password"

type Msg
  = InputField FieldType String

{-| #! Individual field messages may be easier to read -}
update : Msg -> Model -> Model
update msg model =
  case msg of
      InputField Name str ->
        { model | name = str }

      InputField Password str ->
        { model | password = str }

      InputField PasswordAgain str ->
        { model | passwordAgain = str }



-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ viewInput Name "text" model.name
    , viewInput Password "password" model.password
    , viewInput PasswordAgain "password" model.passwordAgain
    , viewValid model
    ]

{-| #! Solved the "too many arguments" problem!

> Previous solution:
> @

With a larger form however, input events could be different, so you might need
`(a -> msg)` argument for flexibility.
-}
viewInput : FieldType -> String -> String -> Html Msg
viewInput field inputType model =
  input
    [ onInput (InputField field)
    , type_ inputType
    , placeholder (fieldToString field)
    , value model ] []


{-| Order here matters!

> #! You don't see password validity until `PasswordAgain` is filled in!

1. Check fields are filled
2. Check password validity
3. Check passwords match

You don't want to check if the passwords match before checking other conditions!
-}
viewValid : Model -> Html msg
viewValid { name, password, passwordAgain } =
    if (allFieldsFilled [name, password, passwordAgain]) then
        if (validatePassword password) then
            if password == passwordAgain then
                div [ style "color" "green" ] [ text "OK" ]
            else
                div [ style "color" "red" ] [ text "Passwords do not match!" ]

        else
            div [ style "color" "red" ]
                [ text
                    """
                    Password is invalid! Must be at least 8 characters long and
                    contain a mix of uppercase, lowercase, and numeric characters.
                    """
                ]

    else
        div [ style "color" "red" ] [ text "Fields must not be empty!" ]

{-| Way easier than my first attempt of `List.map String.isEmpty`! -}
allFieldsFilled : List String -> Bool
allFieldsFilled =
    List.all (not << String.isEmpty)

validatePassword : String -> Bool
validatePassword str1 =
  (String.length str1 >= 8) && (validateStringContains str1)

validateStringContains : String -> Bool
validateStringContains str =
  (any isDigit str)
    |> (&&) (any isUpper str)
    |> (&&) (any isLower str)
