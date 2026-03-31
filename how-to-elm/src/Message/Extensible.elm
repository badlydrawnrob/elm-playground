module Message.Extensible exposing (..)

{-| ----------------------------------------------------------------------------
    ⚠️ Extensible records (narrowing types for a flatter model)
    ============================================================================
    > Removed the need for nested messages with extensible records.

    However:

        (a) We're using nested messages which is hard to read
        (b) We must use functional composition (harder for beginners)
        (c) We don't need an extensibe record alias (use type signature)

    Original code:

        @ https://programming-elm.com/
        @ https://tinyurl.com/adv-types-extensible-records (2nd half)
        @ https://allanderek.prose.sh/extensible-records (warning)

    We could do better by simplifying our components and using type signatures
    `{ r | field : String } -> String` at the expense of slightly more verbose
    code. If there's one field per component, definitely do that. If you've got lots
    of fields to pass to a component, see Elm Land for ideas, use a type alias,
    or it's one of the areas where a nested record might work best (see the `Form`
    record in Elm Spa example).

    1. Avoid nested records wherever possible
    2. Avoid nested messages wherever possible (see Elm Spa form)
    3. Simplify components and types as much as possible


    Start simple
    ------------
    > Start with a single file until you can split around types.

    When you see patterns emerge, you can start to narrow types. When you see
    a group of functions that could work around a type within it's own module,
    start splitting them out. I don't think the Salad Builder in "Programming Elm"
    is a particularly great example. See Elm Land for ideas.

    Aim for the most simple (not easy) and readable solution.


    Html.map
    --------
    99% of the time you don't need it.


    Functional composition (`<<`)
    -----------------------------
    > You don't need to know Haskell to use compose!

    Where a pipe won't do this can be used for point-free style coding. Use
    sparingly as it can make code harder to read. `onInput` silently passes a
    `String` to one of the `ContactMsg` messages. We use `<<` to pass the whole
    message to it's parent `Msg` type. Similar to wrapping in parens.


    Input types
    -----------
    > Aim for minimal amount of HTML and CSS.

    A simple checkbox is straightforward.

        @ https://discourse.elm-lang.org/t/elm-radio-button/6608/2
        @ https://github.com/dwyl/learn-elm/blob/master/examples/checkboxes.elm

    Number inputs

        @ https://tinyurl.com/beware-input-type-numbers

    Don't trust number inputs! It's best to still treat it as a `String` value.
    Number inputs have a few bugs, such as `type="tel"` will error if input is
    not a number, but still allows characters.


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. Simplify the `Msg` types (no nested messages)
    2. Remove the functional composition on `Msg`
    3. Decide if extensible record type signatures are better than alias!
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

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Extensible records and nested messages" ]
        , form [ class "extensible-records", onSubmit Send ]
            [ input
                [ type_ "text"
                , placeholder "Your name"
                , value model.name
                , onInput UpdateName
                ] []
            , input
                [ type_ "email"
                , placeholder "Your email"
                , value model.email
                , onInput (ContactMsg << Email)
                ] []
            , input
                [ type_ "tel" -- Don't trust number inputs!
                , placeholder "07953222894"
                , value model.phone
                , onInput (ContactMsg << Phone) -- Treat as a `String`
                ] []
            , input
                [ type_ "checkbox"
                , checked model.notify
                , onClick (ContactMsg ToggleNotify)
                ] []
            ]
        , p [] [ text (Debug.toString model) ]
        ]


-- Update ----------------------------------------------------------------------

{- #! Merge into the main `Msg` type -}
type ContactMsg
    = Email String
    | Phone String
    | ToggleNotify

type Msg
    = UpdateName String
    | ContactMsg ContactMsg -- #! This should be flattened
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
