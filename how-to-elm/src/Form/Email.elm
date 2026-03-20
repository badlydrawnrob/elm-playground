module Form.Email exposing (main)

{-| ----------------------------------------------------------------------------
    Email (with Regex)
    ============================================================================
    > Which computed type might you return from a form?

    1. `Email` type
    2. `Maybe String`
    3. `Result String Email`

    You could use any one of these depending on context. However you'd likely
    want to return a `List Error` or `[]` and allow sending to the server. You'd
    then create an opaque type for `Email` and generate it from the server.

    Originally I had an `Email = Email String | NotAnEmail` type, but it's unlikely
    we'd want to generate this unless we're entering in a form. And, if it's a
    form we're dealing with `String`s and successful validation. We'd only create
    an `Email` type for, say, a user's profile.


    Regex alternative
    -----------------
    In the docs it says generally speaking, it will be easier and nicer to use a
    parsing library like `elm/parser` instead of this.


    Wishlist
    --------
    1. There's no real input validation hereAlways output an `Email` but mark red or green (valid?)
    2. With Piccolo you'd get an error from the server
        - Perhaps add this in later/never (mock the response)

-}

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Regex


-- Model ------------------------------------------------------------------------

type Msg
    = EnteredEmail String

type alias Model =
    { email : String}

init : Model
init =
    { email = "" }

-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
    Html.div []
        [ Html.input
            [ Attr.type_ "email"
            , Attr.placeholder "Please enter your email ..."
            , Attr.value model.email
            , onInput EnteredEmail
            ]
            []
        , if validateEmail model.email then
            Html.p [ Attr.style "color" "green" ] [ Html.text model.email ]
          else
            Html.p [ Attr.style "color" "red" ] [ Html.text model.email ]
        ]

validateEmail : String -> Bool
validateEmail input =
    let
        emailPattern =
            Maybe.withDefault Regex.never -- We must unwrap `Maybe Regex` first!
                <| Regex.fromString "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b"
    in
    Regex.contains emailPattern input


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
    case msg of
        EnteredEmail str -> { model | email = str }


-- Main ------------------------------------------------------------------------

main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
