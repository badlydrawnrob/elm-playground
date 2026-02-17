module Task.Time exposing (main)

{-| ----------------------------------------------------------------------------
    Tasks: a simple Time example
    ============================================================================
    > Original: @ https://sporto.github.io/elm-workshop/05-effects/04-tasks.html

    The `Time` module asks us to do quite a bit manually: e.g: `Int`->`String`
    for the day. See a detailed explanation of the important parts of time in
    `/words/time.md`, and in `/python-playground/building-with-fast-api` where
    we validate a JWT with a timestamp.

    See also: @ https://tinyurl.com/elm-spa-timestamp (Posix)
              @ https://tinyurl.com/elm-spa-metadata-timestamp (ISO String)
              @ https://www.iso.org/iso-8601-date-and-time-format.html (What is?)

              @ https://package.elm-lang.org/packages/justinmimbs/time-extra/1.2.0/
              @ https://discourse.elm-lang.org/t/date-and-time-conversion/9677

    Tasks
    -----
    > `Task x Posix` should `Never` fail.

    `Time.now` is a `Task` that can never fail, so `Task.perform` can be used.
    If a `Task` does have a potential `Error`, we handle it with `Task.attempt`.


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. "This should never happen" problem
        - Is `Nothing` really necessary? Our task can never fail.
        - The only feasible reason it'd fail is slow data / no js
        - An `""` empty string or default value could be used.
    2. Integrate `ISO 8601` which our API will likely use.
-}

import Browser
import Html exposing (Html, h1, p, text)
import Html.Attributes exposing (style)
import Task
import Time exposing (Posix)


-- Model -----------------------------------------------------------------------

type alias Model =
    { time : Maybe Posix }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = Nothing }
    , Task.perform GotTime Time.now
    )


-- Messages --------------------------------------------------------------------

type Msg
    = GotTime Posix


-- View ------------------------------------------------------------------------

view : Model -> Html msg
view model =
    case model.time of
        Just t ->
            h1 [] [ text (viewTime t) ]

        Nothing ->
            p [ style "color" "red" ]
                [ text "Time hasn't loaded for some reason" ] -- #1

viewTime : Posix -> String
viewTime time =
    String.concat
        [ dayString time
        , " — "
        , hourString time
        , ":"
        , String.fromInt (Time.toMinute Time.utc time)
        , "mins"
        ]

dayString : Posix -> String
dayString time =
    case Time.toWeekday Time.utc time of
        Time.Mon ->
            "Monday"

        Time.Tue ->
            "Tuesday"

        Time.Wed ->
            "Wednesday"

        Time.Thu ->
            "Thursday"

        Time.Fri ->
            "Friday"

        Time.Sat ->
            "Saturday"

        Time.Sun ->
            "Sunday"

hourString : Posix -> String
hourString time =
    case Time.toHour Time.utc time of
        0 ->
            "12am"

        1 ->
            "1am"

        2 ->
            "2am"

        3 ->
            "3am"

        4 ->
            "4am"

        5 ->
            "5am"

        6 ->
            "6am"

        7 ->
            "7am"

        8 ->
            "8am"

        10 ->
            "10am"

        11 ->
            "11am"

        12 ->
            "12pm"

        13 ->
            "1pm"

        14 ->
            "2pm"

        15 ->
            "3pm"

        16 ->
            "4pm"

        17 ->
            "5pm"

        18 ->
            "6pm"

        19 ->
            "7pm"

        20 ->
            "8pm"

        21 ->
            "9pm"

        22 ->
            "10pm"

        23 ->
            "11pm"

        _ -> ""




-- Update ----------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTime time ->
            ( { model | time = Just time }
            , Cmd.none
            )


-- Main ------------------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
