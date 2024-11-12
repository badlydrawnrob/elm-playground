module HowToMessage.NarrowTypes exposing (..)

{-| ----------------------------------------------------------------------------
    Narrowing types for messages
    ============================================================================
    From @ https://programming-elm.com/ (the types have been changed)

    1. Nested records (state) is generally avoided
    2. Don't optimise too early (do you really need an extensible record?)
    3. Keep your components simple (reusable radio buttons look confusing)
    4. Keep your types simple.

    You should start with the simplest thing possible:

        - A flat record
        - A flat `Msg` type
        - etc

    And split out into modules and narrowed types when it becomes necessary, or
    you see patterns emerge. Don't use functions like `Html.map` until they're
    absolutely necessary.

    More about extensible records:
    ------------------------------

        @ https://tinyurl.com/adv-types-extensible-records (second-half only)
        @ https://tinyurl.com/whats-wrong-using-html-map

    The general consensus seems extensible records are helpful to group
    functions around a particular "slice" of your larger, flatter, model WITHOUT
    the need for nested records.

    Nested records
    --------------

    The only other way to narrow types is with a nested `type alias Contact` as
    a nested record. The downside of this is you need nested update functions
    to handle it. This gets unwieldy with too many nested states, or something
    crazy like `model.contact.email` records:

        init =
            { name = ""
            , contact =
                { email : ""
                , phone : 0
                }
        }

    The `<<` operator
    -----------------

    You'll see in the `onInput` values that we're using the functional composition
    operator `<<`. Why? `onInput supplies the `Msg` with a `String` so our narrow
    type of `Email String` (our contact message) receives the string and passes
    it on to `ContactMsg`. Parenthesis won't work here because our `String` is
    sort of "silently" passed (not explicitly stated in the code). So ...
    `(ContactMsg (Email ...))` wouldn't work! (radio buttons are different)

    Simple checkbox
    ---------------

    See @ https://discourse.elm-lang.org/t/elm-radio-button/6608/2
    See @ https://github.com/dwyl/learn-elm/blob/master/examples/checkboxes.elm

    ⚠️ Reusable components
    ----------------------

    Programming Elm's "Salad Builder" (chapter 6) encourages reusing of Html
    functions, such as `type_ "radio"`. I think these make things MORE complicated
    as you end up with functions that take A LOT of arguments, you're abstracting
    things in a way that can become MORE confusing.

    Possibly better to just split out components as modules, but keep them simple
    and only reuse where absolutely necessary. Keep Html as Html unless creating
    reusable functions makes it _more_ simple to understand/read.

    Keep a form a form. Keep a radio button a radio button. etc.

    ⚠️ Number inputs
    ----------------

    > the input value is not automatically validated to a particular format
    > before the form can be submitted, because formats for telephone numbers
    > vary so much around the world.

    Even though `<input type="tel">` prevents submission if input isn't numbers
    it STILL allows any old fucking character. So what's the bloody point?

        @ https://tinyurl.com/beware-input-type-numbers

    Html and CSS sucks, so do the absolute simplest minimal thing possible.
    Always validate with Elm.

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
