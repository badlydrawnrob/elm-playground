module Http.Loading exposing (..)

{-| ----------------------------------------------------------------------------
    Server `Status a` with `LoadingSlowly`
    ============================================================================
    > Checks the time it takes for the server to respond. Originally from
    > @rtfeldman's Elm Spa example.

        @ https://web.dev/explore/fast
        @ https://www.browserstack.com/docs/live/network/network-simulation

    It's not enough to run `LoadingSlowly` with a sleep timer, as it doesn't
    guarantee that the server is actually slow. @rtfeldman's version also splits
    out files into `Api`, `Article`, `Loading` etc which is quite nice.

    1. `Process.sleep` is a `Task` that can never fail
    2. `LoadingSlowly` occurs if server response is over threshold
    3. `Progress` with `track` is needed to quantify:
        - Server upload/download times (the server is at fault)
        - Speed of connection to server (a shitty data connection)

    If you don't understand the code, ask Ai to step you through it.


    API
    ---
    > @ https://dummyjson.com/quotes

    Uses a low-resource heavy API to grab some quotes.


    Steps
    -----
    > Some of the ways a response can go wrong.

    1. Poor data connection (wifi is off? poor 4G? Disconnected?)
    2. Server is down (not responding for some reason)
    3. Server is up but response is slow (e.g. due to load)
    4. Server is up but response has error (e.g. 500 or 404)
    5. Server is up but response is malformed (e.g. JSON error)
    6. Cross-origin issue (only on Brave browser with this API)

    An example of (1) is when we `Http.get` with a mock `Decode.succeed` decoder
    but the network is disconnected. The request will fail with a network error!
    For (6), it's probably easiest to just roll your own localhost API.


    Slow data
    ---------
    > How do we check the problem is a slow connection?

    `Process.sleep` is not a perfect way to check for slow connections. It may
    be tricky to detect whether the server or the connection is the problem.
    not guarantee that the server is actually Adding
    a tracker to `Http.get` tells us how long the server takes to process the
    request. We also might want to check 4G connectivity.

    For images, you can use `<picture>` to load 1x, 2x, or 3x images based on
    the user's device. Here's some potential ideas for slow connections:

    - ✅ Load text-only as default (or minimal requested data)
    - ✅ Add feature detection to a user's client (3x image, etc)
    - ✅ Only include 3x images if `LoadingSlowly` is false (good connection)
    - ✅ Use `Progress` and `track` to monitor the server download progress
    - ✅ Set a timer on the backend server to time the query execution!
    - ⁉️ Load a small asset on very first page load to test connection

    ❌ Sniffing the user's network to see what connection they're on is also
    possible with `navigator.connection.effectiveType`, but it's not browser-safe.
    `renderTime` to check how long an element takes to load is also possible in
    the future.

        @ https://caniuse.com/?search=navigator.connection (Chrome only)
        @ https://addyosmani.com/blog/adaptive-serving/


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    > I feel the easiest way to check a slow connection is to (1) `Process.sleep`
    > (maybe two of them) and (2) server-side timing metric response.

    1. Test with BrowserStack or developer tools with throttling
        - How realistic is the `sleepThreshold`? Too long? Too short?
    2. Which method will accurately check connectivity?
        - Which parts of your app are potential bottlenecks?
        - Use feature detection for client and device capabilities
        - Use speed testing to check if connectivity is good
    2. Add `Progress` tracking to more accurately measure server response
        - @ https://package.elm-lang.org/packages/elm/http/latest/Http#track
        - @ https://package.elm-lang.org/packages/elm/http/latest/Http#fractionReceived
    3. Add a server-side "time to execute" metric in the json response
        - How long does the server take to process the request?
    4. Add `LoadingVerySlowly` for really poor connections?
        - Switch to `text-only` mode if this happens
    5. You may wish to have a `NoOp` or `NotAskedFor` state for `Status a`, if
       the UI is a button to trigger the request.

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
