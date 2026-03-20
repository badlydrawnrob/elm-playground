module Message.NarrowTypes exposing (..)

{-| ----------------------------------------------------------------------------
    Narrowing types for messages
    ============================================================================
    > ⚠️ Nested messages add complexity and should rarely be used! Originally
    > from @ https://programming-elm.com/ (types have been changed).

    1. Avoid nested records wherever possible
    2. Avoid nested messages wherever possible (see Elm Spa form)
    3. Simplify components and types as much as possible

    Sketch your routes and start with the simplest thing possible! You may wish
    to split modules around narrowed types or patterns, but it's not necessary.
    `Html.map` is used in Programming Elm but this is best avoided.

        - Flat record
        - Flat `Msg` type
        - etc

    As your file grows you may wish to split modules around narrowed types, or
    when you see patterns emerge. `Html.map` should almost NEVER be used!


    Reusable components
    -------------------
    > The Salad Builder example (Programming Elm, chapter 6) encourages reusable
    > input functions, and Elm Land uses components.

    These can be handy, but they aren't always easier to read. If you're only
    dealing with a small number of inputs, just use plain old Html.


    Alternative to extensible record alias
    -------------------------------------
    > An extensible record must output it's own type or a field value.

    An extensible record in the type signature (without an alias) can work out
    a little cleaner, as it makes the output type more obvious. Extensible records
    allow you to group functions around a "slice" of your flat model, without the
    need for nested records. Add minimum amount of fields for a working function.

        function : { r | field : String } -> String
        function { field } =
            field

    Some more examples ...

        @ https://tinyurl.com/adv-types-extensible-records (second-half only)
        @ https://allanderek.prose.sh/extensible-records   (a small warning)


    The `<<` operator
    -----------------
    > A compose function similar to Haskell

    Sometimes you'll need "functional composition" where a pipe just wouldn't do.
    This also helps to do point-free style functions, which should be used only
    every so often, as it can lead to hard to read code.

    The `onInput` "silently" passes a string to one of the `ContactMsg` messages,
    so we've got to use functional composition to pass it to the parent `Msg`.


    Input types
    -----------
    > Aim for minimal amount of HTML and CSS.

    A simple checkbox is straightforward.

        @ https://discourse.elm-lang.org/t/elm-radio-button/6608/2
        @ https://github.com/dwyl/learn-elm/blob/master/examples/checkboxes.elm

    Number inputs

        @ https://tinyurl.com/beware-input-type-numbers

    Just because a number input is used does not mean there won't be bugs! Treat
    everything as a string in general. For example, `type="tel"` will error if
    input is not a number, but still allows characters.

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
        [ h1 [] [ text "Narrowing types with messages" ]
        , form [ class "narrow-types", onSubmit Send ]
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
                [ type_ "tel" -- Might be better as a string?
                , placeholder "07953222894"
                , value model.phone
                , onInput (ContactMsg << Phone) -- returns a `String` even though
                ] []                            -- it's verified as a number (Html)
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
