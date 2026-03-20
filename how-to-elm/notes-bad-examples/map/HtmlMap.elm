module Message.HtmlMap exposing (..)

{-| ----------------------------------------------------------------------------
    Narrowing types with `Html.map`
    ============================================================================
    > ⚠️ Don't use `Html.map` if you can avoid it!  use `<<` instead!

    In this file we use `Html.map` to wrap a child `Msg` with a parent one. It's
    generally better to use the compose function `>>` or `(any -> msg)` with the
    "teach me how to message" pattern.

        @ https://tinyurl.com/whats-wrong-using-html-map
        @ https://elm.land/concepts/components.html#defining-the-component


    Reusable inputs
    ---------------
    > Keep forms as simple as possible. For a small amount of inputs, it might
    > be easier to read as full Html!

    However, it can be quite handy to pass `InputType` and convert it to a
    `String` in a helper function. Ask yourself "how many lines of code does this
    save me?" and "does it make the code easier to read?"

    We have one input here that's different, so it negates the benefits.

-}

import Browser
import Debug
import Html exposing (..)
import Html.Attributes exposing (class, checked, type_, placeholder, value)
import Html.Events exposing (onClick, onInput, onSubmit)


-- Model -----------------------------------------------------------------------

{- An extensible record -}
type alias Contact c =
    { c | email : String
        , phone : String
        , notify : Bool
    }

type alias Model =
    { name : String
    , email : String
    , phone : String
    , notify : Bool
    }

init =
    { name = ""
    , email = ""
    , phone = ""
    , notify = False
    }


-- View ------------------------------------------------------------------------

viewInput : String -> String -> String -> (String -> ContactMsg) -> Html ContactMsg
viewInput inType placeholder_ value_ msg =
    input
        [ type_ inType
        , placeholder placeholder_
        , value value_
        , onInput msg
        ] []

{- You have to have a wrapper to apply the `Html.wrap` with, otherwise your
`onSubmit` message would also be wrapped! -}
viewInputs : Model -> Html ContactMsg
viewInputs model =
    div []
        [ viewInput "email" "Your email" model.email Email
        , viewInput "tel" "Your phone" model.phone Phone
        , input
            [ type_ "checkbox"
            , checked model.notify
            , onClick ToggleNotify
            ] []
        ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Narrowing types with messages" ]
        , form [ class "narrow-types", onSubmit Send ]
            [ input
                [ type_ "text"
                , placeholder "Your name"
                , value model.name
                , onInput UpdateName
                ] []
            -- Now wrap all the `ContactMsg` input fields
            -- with the main `Msg` type!
            , Html.map ContactMsg (viewInputs model)
            ]
        , p [] [ text (Debug.toString model) ]
        ]


-- Update ----------------------------------------------------------------------
--
-- We've split out `ContactMsg` and we can use exstensible records.

type ContactMsg
    = Email String
    | Phone String
    | ToggleNotify

type Msg
    = UpdateName String
    | ContactMsg ContactMsg
    | Send

updateContact : ContactMsg -> Contact c -> Contact c
updateContact msg contact =
    case msg of
        Email str ->
            { contact | email = str }

        Phone num ->
            { contact | phone = num }

        ToggleNotify ->
            { contact | notify = not contact.notify }  -- Switch with `not`!

update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateName str ->
            { model | name = str }

        ContactMsg contactMsg ->
            updateContact contactMsg model

        Send ->
            Debug.todo "Do something on form submit!"


-- Main ------------------------------------------------------------------------

main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }

