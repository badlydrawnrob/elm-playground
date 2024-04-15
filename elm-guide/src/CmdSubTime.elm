module CmdSubTime exposing (..)

import Browser
import CmdSubHttp exposing (Msg)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Task
import Time


{-| Taking the time ...
-------------------

    I don't really understand `Time` that well, nor using `Task`, so would
    need to seek out better tutorials or documentation. I guess `Task` is to
    generate `Cmd -> Msg` sync or async.

    1. [x] Ability to `TurnOffClock` with an `onClick` handler and `if/else`
       statement in the `subscriptions` function. Turn the `Time.every` off.
    2. [x] Make the digital clock look nicer (fonts, positioning)
    3. [ ] Use `elm/svg` to make an analog clock with a red second hand!

    ----------------------------------------------------------------------------

    Between time zones based on ever-changing political boundaries and
    inconsistent use of daylight saving time, human time should basically
    never be stored in your `Model` or database! It is only for display!

    POSIX Time
    ----------

    Everywhere you go on Earth, POSIX time is the same. It is just the
    number of seconds elapsed since some arbitrary moment.

    Time Zones
    ----------

    A “time zone” is a bunch of data that allows you to turn POSIX time into
    human time. Basically, it's complicated — to show a human being a time,
    you must always know the `Time.Posix` and `Time.Zone`.

    This is handled in `View`, NOT the `Model`.

    More info
    ---------

    See `elm/time` for more information on handling times. Especially if you're
    working on scheduling, calendars, etc.

      @ https://package.elm-lang.org/packages/elm/time/latest/

-}



-- Main ------------------------------------------------------------------------


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model -----------------------------------------------------------------------
-- #1: Getting `Time.Zone` is tricky. We created a `command` with
--     `Task.perform ... ...` — we command the runtime to give us the
--     `Time.Zone` wherever the code is running. See `Task` for more
--     information on how this works:
--
--       @ https://package.elm-lang.org/packages/elm/core/latest/Task


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , paused : Bool
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
            ( { model | zone = newZone }
            , Cmd.none
            )

        StopStartClock ->
            ( { model | paused = not model.paused }
            , Cmd.none
            )



-- Subscriptions ---------------------------------------------------------------
-- #1: We use `1000` which means every second. We could've also said `60 * 1000`
--     for every minute, or `5 * 60 * 1000` for every five minutes.
--
--     We also need a function that turns the current time into a `Msg`. For
--     every second, the current time is going to turn into a `Tick <time>` for
--     our `update` function.
--
--     A subscription is given some configuration, and you describe how to
--     to produce `Msg` values.


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.paused then
        Sub.none

    else
        Time.every 1000 Tick



-- #1
-- View


view : Model -> Html Msg
view model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)

        minute =
            String.fromInt (Time.toMinute model.zone model.time)

        second =
            String.fromInt (Time.toSecond model.zone model.time)
    in
    div
        [ style "width" "200px"
        , style "margin" "20px auto"
        ]
        [ h1
            [ style "color" "red"
            , style "font-family" "system-ui"
            ]
            [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        , viewButton model.paused
        ]


viewButton : Bool -> Html Msg
viewButton switch =
    case switch of
        True ->
            button [ onClick StopStartClock ] [ text "Turn on clock" ]

        False ->
            button [ onClick StopStartClock ] [ text "Turn off clock" ]
