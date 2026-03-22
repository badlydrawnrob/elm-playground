module Http.Loading exposing (..)

{-| ----------------------------------------------------------------------------
    Server `Status a` with `LoadingSlowly`
    ============================================================================
    > Here we have a single type for all server requests

    1. Set initial state to `Loading` while attempting `Http.get`
    2. Use `Process.sleep` to time the server response (see wishlist)
        - We set a threshold for a "slow" response
    3. If longer than the threshold, it's `LoadingSlowly`
        - More than one field in our `Model` could be `LoadingSlowly`
        - For example `model.article` and `model.comments` are `Status a`
    4. Set the response state if successful or failed


    API
    ---
    > @ https://dummyjson.com/quotes

    Uses a low-resource heavy API to grab some quotes.


    Steps
    -----
    > There are a few ways a response can go wrong

    1. Poor data connection (is network connected? wifi off? 4G?)
    2. Server is down (not responding for some reason)
    3. Server is up but response is slow (e.g. due to load)
    4. Server is up but response has error (e.g. 500 or 404)
    5. Server is up but response is malformed (e.g. JSON error)

    For example, we can't mock `Http.get` with a makeshift `Decode.succeed`
    decoder `Msg` with a network error. The whole `Http.get` will fail.


    Slow data
    ---------
    > A simple way to check quality of data connection

    `Process.sleep` only checks how long a response takes, it's not a perfect
    way to check 4G connectivity, so we may have to add other checks.


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. More accurately perform a mobile data connection check
        - Is the network actually connected to the server?
    2. More accurately measure the actual server response time
        - @ https://package.elm-lang.org/packages/elm/http/latest/Http#track
        - @ https://package.elm-lang.org/packages/elm/http/latest/Http#fractionReceived
    3. How is the network performing?
        - Is the bottleneck the mobile connection or the server?
    4. Add a `LoadingVerySlowly` state for really bad connections?
        - E.g. text-only mode
    5. You may wish to have a `NoOp` or `NotAskedFor` state for `Status a`, if
       the UI is a button to trigger the request.

-}

import Http
import Process
import Time


-- Model -----------------------------------------------------------------------

type alias Quote =
    { id : Int
    , quote : String
    , author : String
    }

type alias Model =
    { status : Status (List Quote) }

type Status a
    = Loading
    | LoadingSlowly
    | Success a
    | Failure Http.Error


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of


-- View ------------------------------------------------------------------------



-- Main ------------------------------------------------------------------------
