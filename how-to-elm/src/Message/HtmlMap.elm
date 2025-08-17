module Message.HtmlMap exposing (..)

{-| ----------------------------------------------------------------------------
    Narrowing types with `Html.map`
    ============================================================================
    See `HowToMessage.NarrowTypes` for notes on extensible records and other
    parts of this program. Here we're concerned with reusable form fields and the
    `Html.map` function (which should be used sparingly).

    1. Create reusable input types
    2. `Html.map` over child message with parent one

    ⚠️ The downsides of `Html.map` and reusable inputs
    --------------------------------------------------
    In general, using `(ContactMsg << Email)` or `(a -> msg)` is a bit cleaner
    than using `Html.map`, but it's useful if you don't have much control over
    your imported package or module messages. Here's more info on the alternative
    "teach me how to message" pattern for child modules:

        @ https://tinyurl.com/whats-wrong-using-html-map
        @ https://elm.land/concepts/components.html#defining-the-component

    It could also be said this reusable `viewInput` function makes code a little
    harder to read; for a few inputs it's overkill. Ask yourself the question
    "does the function save me many lines of code?" or "Would this be better in
    it's own component module?":

    1. TWO of our inputs can't use the `viewInput` function:
        - `"Your name"` because `viewInput` expects a `ContactMsg` type
        - `"checkbox" because it's got different attributes to `viewInput`
    2. Counting lines of code, it's only a slight improvement:
        - For very large forms, it may make sense to cut code down ...
        - But this could also be done by creating modules around types.

    ⚠️ Use `Html.map` sparingly
    --------------------------
    It seems that `Html.map` should be rarely used, as there are other methods
    (like functional composition) that effectively do the same job.

        @ https://tinyurl.com/whats-wrong-using-html-map

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

