module Result.SimplifyState exposing (..)

{-| ----------------------------------------------------------------------------
    The "2:00" problem (using `Result`)
    ============================================================================
    > Simplify your state and don't store computed data!

    Battling with complexity? Too many functions? Stop and slow down!

        Sketch it out: sentence method, interfaces, black-box thinking.
        Paper prototype: 247 loc with simple state and fewer functions.
        Simplify your types! Reassess your life choices!

    The following improvements are discovered:

    1. Splitting the string `"2:00"` gives too many potential states!
    2. Aim to use a single `Result` and not for every validation
    3. Keep the user input as `String`s rather than Elm types
    4. Needlessly using wrapped types can result in too much unpacking
    5. Don't store computed data if you can avoid it!

    Use the sketch it out method to discover early complexity and flows of data,
    without having to code it up first. If you need to use Ai to mock up a UI then
    do that too. Avoid needless complicated types which need unpacking.


    The original code for this module was madness.
    ----------------------------------------------
    > Guards are the only issue now; more complex than `String.isEmpty`.

    Our initial attempts were a lot worse:

        (a) "2:00" rather than "2" and "00"
        (b) Using a Tuple for user input
        (c) Too many `Result`s for validation
        (d) Too any `Maybe` types for validation


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

        `Input String String` has high cardinality
        `Input Field String`  has low cardinality


    Original examples
    -----------------
    > These are obviously bad practice (attempts 1-3)

        @ https://tinyurl.com/e0d9643
        @ https://tinyurl.com/how-to-elm-7526926 (311 loc)
        @ https://tinyurl.com/how-to-elm-6b10d6f (213 loc - multiple `Result`)

    Our final example has slightly more lines of code than attempt 3, but it's
    a lot more robust and still easy to read!


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. Do not show all form errors at once!
        - Move validation logic closer to the individual minute/second guards.
        - Field is empty? Show only `["empty"]` error (for that field)
        - Field is not empty? Show all other errors (for that field)
    2. Do something with a successful form submission!
        - See Elm Spa example and `Form.ListError` for ideas
        - Will `Result.map` or `Result.andThen` be useful here?
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)



-- Types and init --------------------------------------------------------------

type alias Mins
    = String

type alias Secs
    = String

type Field
    = Minutes
    | Seconds

type alias Model =
    { mins : Mins
    , secs : Secs
    , errors : List String
    }

type Msg
    = UpdateInput Field String -- #! Lower cardinality
    | SaveInput

initialModel =
    { mins = ""
    , secs = ""
    , errors = []
    }



-- Update ----------------------------------------------------------------------


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput Minutes str ->
            { model | mins = str }

        UpdateInput Seconds str ->
            { model | secs = str }

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


validate : Mins -> Secs -> Result (List String) String
validate mins secs =
    case buildErrorList mins secs of
        [] ->
            (Ok "Valid form")

        lst ->
            (Err lst)

{-| Concatonate our error list

> `Maybe.withDefault` only works as we're not allowing zero values.

This is more elegant and closer to `Form.ListError`. An accumulator could've
also been used to build the list; `String` return values instead of `List String`!
-}
buildErrorList : Mins -> Secs -> List String
buildErrorList mins secs =
    [ checkEmpty mins
    , checkEmpty secs
    , checkMins (String.toInt mins |> Maybe.withDefault 0) -- #!
    , checkSecs (String.toInt secs |> Maybe.withDefault 0) -- #!
    ]
    |> List.concat

checkEmpty : String -> List String
checkEmpty field =
    if String.isEmpty field then
        ["field cannot be empty!"]
    else
        []

checkMins : Int -> List String
checkMins mins =
    if mins > 0 && mins < 9 then
        []
    else
        ["minutes must be between 1 and 8!"]

checkSecs : Int -> List String
checkSecs secs =
    if secs > 0 && secs < 60 then
        []
    else
        ["seconds must be between 1 and 59!"]


-- View ------------------------------------------------------------------------


{-| See `Msg` for potential improvements -}
view : Model -> Html Msg
view model =
    form [ class "float-input", onSubmit SaveInput ]
            [ input
                [ type_ "text"
                , placeholder "Please add minutes ..."
                , value model.mins
                , onInput (UpdateInput Minutes)
                ]
                []
            , input
                [ type_ "text"
                , placeholder "Please add seconds ..."
                , value model.secs
                , onInput (UpdateInput Seconds)
                ]
                []
            , button [] [ text "Save" ]
            , div []
                (List.map viewError model.errors)
            ]

viewError : String -> Html msg
viewError err =
    Html.span
        [ class "field-error"
        , style "color" "red"
        ] [ text (err ++ " ") ]


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
