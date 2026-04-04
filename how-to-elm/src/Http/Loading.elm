module Http.Loading exposing (..)

{-| ----------------------------------------------------------------------------
    Server `Status a` with `LoadingSlowly`
    ============================================================================
    > Checks the time it takes for the server to respond. Originally from
    > @rtfeldman's Elm Spa example.

        @ https://web.dev/explore/fast
        @ https://www.browserstack.com/docs/live/network/network-simulation

    `LoadingSlowly` only checks a period of time has elapsed. It's not enough to
    understand which part of the app is slow! @rtfeldman's version also splits out
    files into `Api`, `Article`, `Loading` etc which is quite nice.

    1. `Process.sleep` is a `Task` that can never fail
    2. `LoadingSlowly` occurs with no response after X seconds

    If you don't understand the code, ask Ai to step you through it!


    A more precise calculation
    --------------------------
    > `Process.sleep` is a "dumb" timer that only checks time elapsed.

    A better speed test for latency and execution time:

    - [] Page load (load a small asset to detect speed?)
    - ✅ Initial connection (time to first byte)
    - [] Server upload time (for POST requests)
    - ✅ Server processing time (for the endpoint)
    - ✅ Size of response (larger responses take longer to download)
    - [] Response download (`Progress, `track`, `fractionReceived`)


    API
    ---
    > @ https://dummyjson.com/quotes

    Uses a low-resource heavy API to grab some quotes.


    Threshold
    ---------
    > 0.5 seconds is not a lot of time! (500ms)

    Using Brave Browser's network throttling (slow 4G) you'll get a brief flash
    of `Loading` and `LoadingSlowly` before returning the quotes.


    How can a response go wrong?
    ----------------------------
    > Here are potential problems with the server ...

    1. Poor data connection (wifi is off? poor 4G? Disconnected?)
    2. Server is down (not responding for some reason)
    3. Server is up but response is slow (e.g. due to load)
    4. Server is up but response has error (e.g. 500 or 404)
    5. Server is up but response is malformed (e.g. JSON error)
    6. Cross-origin issue (only on Brave browser with this API)

    An example of (1) is when we `Http.get` with a mock `Decode.succeed` decoder
    but the network is disconnected. The request will fail with a network error!
    For (6), it's probably easiest to just roll your own localhost API.


    How do we handle slow data?
    ---------------------------
    > What might happen with a slow connection in our app?
    > Some of these suggestions require `model.mode` status.

    So we've discovered the perfect recipe to detect slow connections. We've
    detected whether the problem is latency, slow 4G, server process time, and
    so on. What could an app do to create a better user experience?

        (a) Automatically rejig the app depending on speed
        (b) Prompt the user to select app mode (slow/fast)

    Pictures

        @ https://www.dofactory.com/html/picture
        @ https://www.dofactory.com/html/img/sizes

        We already have `<picture>` or `<img>` element which can load 1x,
        2x, 3x images based on the user's device. This goes by device
        capability or viewport width (use `100vw` for width in `sizes`).

    Text-only

        You could automatically (or prompt the user to) switch to a
        text-only mode if the connection is slow. This could also be
        the default for mobile users (or 1x images).

    Feature detection

        @ https://addyosmani.com/blog/adaptive-serving/
        @ https://caniuse.com/?search=navigator.connection

        Sniff the device to display certain features (like 3x image).
        Some browsers use `navigator.connection.effectiveType` and the
        `renderTime` but it's not browser-safe.


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    > Easiest way to check for slow 4G connection seems to be calculate the
    > server process time, minus the time to full response (of first byte).

    1. Test on a live server with a few devices and connections.
        - In the city centre with a bad connection
        - BrowserStack with throttling on various devices
    2. What's a realistic `sleepThreshold`? How long is too long?
        - `Process.sleep` only checks a time period (not the response load)
        - If quotes load after 0.5 seconds is a loading animation enough?
        - Larger transfers can take 2-3 seconds to load (Building with FastApi)
    3. See the module introduction for more precise calculations.
        - Which methods are easiest or "good enough" to calculate?
        - Will latency - server process time give accurate results?
        - Are `Progress`/`track` necessary or is latency - process time enough?
        - Feature detection for client and device capabilities are also possible
    4. Which bottlenecks are most common and worth considering?
        - Which endpoints are the biggest problems?
        - Which parts of the client are a biggest user experience problem?
        - Which endpoints might benefit from pagination (smaller packets)?
    5. Do we need more than one `LoadingSlowly` status?
-}

import Browser
import Html exposing (Html)
import Html.Attributes exposing (style)
import Http
import Json.Decode as Decode exposing (Decoder)
import Process
import Task exposing (Task)

import Debug


-- Model -----------------------------------------------------------------------

type alias Quote =
    { id : Int
    , quote : String
    , author : String
    }

type alias Model =
    { status : Status (List Quote) }

{-| @rtfeldman's version `Failed` without errors -}
type Status a
    = Loading
    | LoadingSlowly
    | Success a
    | Failure Http.Error

quoteDecoder : Decoder Quote
quoteDecoder =
    Decode.map3 Quote
        (Decode.field "id" Decode.int)
        (Decode.field "quote" Decode.string)
        (Decode.field "author" Decode.string)


-- Update ----------------------------------------------------------------------

type Msg
    = PassedSlowLoadThreshold
    | GotQuotes (Result Http.Error (List Quote))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PassedSlowLoadThreshold ->
            let
                status =
                    case model.status of
                        Loading ->
                            LoadingSlowly

                        other ->
                            other
            in
            ( { model | status = status }, Cmd.none )

        GotQuotes (Ok quotes) ->
            ( { model | status = Success quotes }, Cmd.none )

        GotQuotes (Err error) ->
            ( { model | status = Failure error }, Cmd.none )



-- View ------------------------------------------------------------------------


view : Model -> Html Msg
view model =
    Html.div [ style "width" "600px"
        , style "margin" "0 auto"
        ]
        [ case model.status of
            Loading ->
                Html.text "Loading..."

            LoadingSlowly ->
                Html.text "Loading slowly ... changing to text-only mode"

            Success quotes ->
                Html.div []
                    (List.map viewQuote quotes)

            Failure error ->
                Html.text ("Error: " ++ Debug.toString error)
        ]

viewQuote : Quote -> Html msg
viewQuote { quote, author } =
    Html.blockquote [ style "border-left" "4px solid #ccc"
                    , style "padding-left" "1em"
                    , style "margin-left" "0"
                    , style "font-style" "italic"
                    ]
        [ Html.p [] [ Html.text quote ]
        , Html.footer [] [ Html.text ("— " ++ author) ]
        ]


-- Main ------------------------------------------------------------------------

sleepThreshold : Task x ()
sleepThreshold =
    Process.sleep 500 -- 0.5 seconds

{-| Server request with sleep timer

> Don't call `LoadingSlowly` directly in `Task.perform`!

1. Starts with loading status
2. Batch together the server request and the sleep timer
3. If the sleep timer finishes before the server responds, we set `LoadingSlowly`
4. If the server responds before the sleep timer, we set `Success` or `Failure

Alternative method from Discourse:

```elm
Process.sleep 100 |> Task.perform (always (ChangeStyleSet "green"))
```
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = Loading }
    , Cmd.batch
        [ Http.get
            { url = "https://dummyjson.com/quotes"
            , expect =
                Http.expectJson GotQuotes
                    (Decode.field "quotes" (Decode.list quoteDecoder))
            }
        , Task.perform (\_ -> PassedSlowLoadThreshold) sleepThreshold
        ]
    )

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
