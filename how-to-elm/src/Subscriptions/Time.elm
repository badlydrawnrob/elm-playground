module Subscriptions.Time exposing (..)

{-| ----------------------------------------------------------------------------
    Subscriptions: Time (slightly more complex)
    ============================================================================
    > For more about `Time` in programming, see `/words/time.md`.

        @ https://package.elm-lang.org/packages/elm/time/latest/

    Time in programming is quite complex. So far, I've only had to deal with a
    time that's AWARE (as in, using a timezone).

    `paused : Bool` (original) -> `running: Bool` as code reads better.


    Tasks
    -----
    > 🔍 Tasks are async operations that are tricky to understand.

        @ https://tinyurl.com/ohanhi-tasks-in-modern-elm
        @ https://package.elm-lang.org/packages/elm/core/latest/Task

    We use a `Task.perform` to setup our timezone (takes a `Task Never a` that
    never fails); later we update the `Time.every` minute.


    Cmd
    ---
    You need to briefly understand a command. Basically we're sending a message
    outside of Elm to get/set the timezone.


    Subscriptions
    -------------
    We "pull" in from the outside world by subscribing to JS time. A subscription
    is given some configuration, and you describe how to to produce `Msg` values.


    Debug
    -----
    Very useful for checking if the `model.running` is on or off.


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. ✅ Ability to turn off (pause) the clock
    2. `Time.minutes` does not have leading `0`
    3. Design a digital clock using `elm/html`
        - Fonts, colors, `elm/svg` clock face with red second hand.
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Task
import Time
-- import Debug


-- Main ------------------------------------------------------------------------

main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model -----------------------------------------------------------------------

type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , running : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) False
    , Task.perform AdjustTimeZone Time.here
    )



-- Update ----------------------------------------------------------------------


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | StopStartClock


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model
              | zone = newZone
              , running = True
              }
            , Cmd.none
            )

        StopStartClock ->
            ( { model | running = not model.running }
            , Cmd.none
            )



-- Subscriptions ---------------------------------------------------------------


{-| Pull data from outside world. Clock is running? Send time. -}
subscriptions : Model -> Sub Msg
subscriptions clock =
    if clock.running then
        Time.every 1000 Tick -- every second

    else
        Sub.none



-- View ------------------------------------------------------------------------
-- Not sure `viewHelper` makes it any easier to read, but it's shared now.

viewTime : (Time.Zone -> Time.Posix -> Int) -> Model -> String
viewTime zoneFunc m =
    String.fromInt (zoneFunc m.zone m.time)

viewTimeString : String -> String -> String -> Html msg
viewTimeString hr min sec =
    text (String.concat [hr, ":", min, ":", sec])

view : Model -> Html Msg
view model =
    let
        hour =
            viewTime Time.toHour model

        minute =
            viewTime Time.toMinute model

        second =
            viewTime Time.toSecond model
    in
    div
        [ style "width" "200px"
        , style "margin" "20px auto"
        ]
        [ h1
            [ style "color" "red"
            , style "font-family" "system-ui"
            ]
            [ viewTimeString hour minute second ]
        , viewButton model.running
        ]


btn : Msg -> String -> Html Msg
btn msg label =
    button [ onClick msg ] [ text label ]

viewButton : Bool -> Html Msg
viewButton running =
    -- let
    --     _ = Debug.log "is running?" running
    -- in
    if running then
        btn StopStartClock "Turn off clock"

    else
        btn StopStartClock "Turn on clock"
