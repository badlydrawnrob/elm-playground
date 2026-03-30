module Result.SimplifyState exposing (..)

{-| ----------------------------------------------------------------------------
    ❌ The "2:00" problem (using `Result`)
    ============================================================================
    > Simplify your state and don't store computed data! (311 loc -> 213 loc)

    **TL;DR:** If you ever find yourself battling with complexity and lots of
    functions, slow down, sketch it out, and reassess your life choices!

    Simplify your types!

    1. Splitting the string `"2:00"` gives too many potential states!
    2. Aim to use a single `Result` and not for every validation
    3. Keep the user input as `String`s rather than Elm types
    4. Needlessly using wrapped types can result in too much unpacking
    5. Don't store computed data if you can avoid it!

    Use interfaces, black-box thinking, and paper prototyping to discover early
    complexity and flows of data. Two integers are far easier to deal with than
    splitting a string; creating Tuple stores of data leads to needless `Maybe`
    types that must be dealt with.


    The original code for this module was madness.
    ----------------------------------------------

        (a) Using a Tuple for user input
        (b) Too many `Result`s for validation
        (c) Too any `Maybe` types for validation


    Tuple for user input
    --------------------
    > What was I thinking?!

    It's a bad idea to store computed values if you don't need to! It's adding
    complexity to your code. If the form is sent directly to the server, you'll
    only need a decoder to retrieve a type from a successful form submission.

    With this particular example I'm constantly having to `Tuple.first` and weird
    fucking `Tuple.mapFirst (\_ -> str)` to wrestle raw user input into a type
    I arbitrarily decided on saving in the model!


    Too many `Result`s
    ------------------
    Ideally you'd have ONE and one only; a valid form or calculated type.


    Too many `Maybe`s
    -----------------
    Stick to simpler `Bool`s or easier validation techniques such as @rtfeldman's
    `List Problem` (see `Form.ListError`). If you absolutely MUST use `Maybe's
    then lean on `Maybe.andThen` or `Maybe.map` before extracting the values all
    over the place.


    Cardinality
    -----------
    How many combinations of data is possible with your chosen types?

        "2" "00" can be easily converted to `Int`s (limited combinations)
        "2:00"   is a lot harder to deal with (infinity combinations)

    Too many variations:

        `Input String String` is too many
        `Input Field String` is much better!


    Original examples
    -----------------
    > These are obviously bad practice

        @ https://tinyurl.com/e0d9643 (attempt 1)
        @ https://tinyurl.com/how-to-elm-7526926 (attempt 2)
        @ https://tinyurl.com/how-to-elm-6b10d6f (attempt 3)


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. When field empty only shows "not an integer" (not all errors)
    2. Reduce the cardinality of input `Msg`s
    3. Do something with a successful form submission
        - See Elm Spa example and `Form.ListError` for ideas
        - Will `Result.map` or `Result.andThen` be useful here?
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)



-- Types and init --------------------------------------------------------------

type alias Mins
    = String

type alias Secs
    = String

type alias Model =
    { mins : Mins
    , secs : Secs
    , errors : List String
    }

type Msg
    = UpdateInput String String -- #! Reduce cardinality (see notes)
    | SaveInput

initialModel =
    { mins = ""
    , secs = ""
    , errors = []
    }



-- Update ----------------------------------------------------------------------


{-| #! TO DO: Do something with the valid form! -}
update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput "minutes" str ->
            { model | mins = str }

        UpdateInput "seconds" str ->
            { model | secs = str }

        UpdateInput _ _ ->
            model -- #! Too many variations (see Cardinality)

        SaveInput ->
            case validate model.mins model.secs of
                (Ok _) ->
                    { model
                        | mins = ""
                        , secs = ""
                        , errors = []
                    }


                (Err lst) ->
                    { model | errors = lst }


{-| #! Only displays the first error message, not all of them -}
validate : Mins -> Secs -> Result (List String) String
validate mins secs =
    case ((String.toInt mins), (String.toInt secs)) of
        (Just num1, Just num2) ->
            if (checkMins num1) && (checkSecs num2) then
                (Ok "Valid form")
            else
                (Err ["somehow", "created", "error", "list"])

        (_, _) ->
            (Err ["not", "an", "integer!"]) -- #! Single error displayed

checkMins : Int -> Bool
checkMins mins =
    mins > 0 && mins < 9

checkSecs : Int -> Bool
checkSecs secs =
    secs > 0 && secs < 60


-- View ------------------------------------------------------------------------


{-| See `Msg` for potential improvements -}
view : Model -> Html Msg
view model =
    form [ class "float-input", onSubmit SaveInput ]
            [ input
                [ type_ "text"
                , placeholder "Please add minutes ..."
                , value model.mins
                , onInput (UpdateInput "minutes")
                ]
                []
            , input
                [ type_ "text"
                , placeholder "Please add seconds ..."
                , value model.secs
                , onInput (UpdateInput "seconds")
                ]
                []
            , button [] [ text "Save" ]
            , div []
                (List.map viewError model.errors)
            ]

viewError : String -> Html msg
viewError err =
    Html.span [ class "field-error" ] [ text (err ++ " ") ]


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
