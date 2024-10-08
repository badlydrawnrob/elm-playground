module LargerApps.PicShare exposing (..)

{-| Communicating with the servers
    ------------------------------

    Previous versions of this app ...
    ---------------------------------
    @ src/RefactorEnhance/Picshare04.elm
    @ src/Communicate/WithServers.elm
    @ https://tinyurl.com/programming-elm-4e21a56 (without WebSockets)
    @ src/WebSockets/RealTime.elm (with WebSockets)


    What we've done so far ...
    --------------------------
    Two loading states in our view, a `Maybe feed` and `Maybe Http.Error`.
    We've also got a live stream `Feed` (that's not a `Maybe`) which is an empty
    list or full.

    1. Comments form with a disabled button if `String.empty` for each `Photo`
        - Uses an `ID` to update the correct `Photo`
    2. Validate each `Photo`s comments form if clicked submit
    3. Store the comments in `List comment` and reset the `newComment`.
    4. Show multiple `Photo`, as well as a WebSocket's `Feed` of `Photo`s
    5. Handle `Err`ors for our `LoadFeed` and `LoadStreamPhoto` branches
        - We have views for each with success and errors
    6. Use `ports` and some javascript in our `Html` form to allow us to send
       and receive information from our WebSockets setup.
    7. Display a banner and queue new photos for WebSockets which can be
       updated and integrated into our `Maybe Feed` by the visitor.
        - This means the user's experience isn't interupted when viewing photos.

    Decoding JSON
    -------------
    1. We're using `expectJson` with `Json.Decode.Pipeline` and a `Decoder`.
        - We automatically decode `json` with our decoder
    2. We're also using `decodeString` for our websockets feed.
        - We need to manually decode this ...
        - We use the same `photoDecoder` function that `expectJson` uses!

    Using an ID to update the comment
    ---------------------------------

    1. We're passing through an `ID` to our `Msg`!
    2. We're still using `List.map`, but our `Maybe.map` is now "lifting" a
      `Maybe Feed` rather than a `Maybe Photo`. Our main update function must
      return a `Feed` (which is a `List Photo`)
    3. `List.filter` should be used when you want to LIMIT the number of `Photo`
       returned by the function. `List.map` is better when you want to keep ALL
       photos but edit one of them.


    Testing JSON without server ...
    -------------------------------
    You can test a sample string of JSON like this:
        @ https://ellie-app.com/9MqcYmv6JPga1

    How to write function comments
    ------------------------------
    Elm Tooling must be installed

    `{-|-}` above a function allows you to write Markdown, and hovering over the
    function will show it's "documentation", with other stuff. I quite like
    shorthand comments (1), (2), for some things but having in-place
    documentation is quite helpful.

    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    1. Tests are bit of a pain in the arse. But for important things, such as
       potential `Http.Error` of `Http.BadBody`, use `elm-test` or similar.

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing ( class, classList, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode exposing (Decoder, bool, decodeString, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Http
import LargerApps.WebSocket as WS exposing (listen, receive)


-- Model -----------------------------------------------------------------------

type alias ID = Int

type alias Photo =
    { id : ID
    , url : String
    , caption : String
    , liked : Bool
    , comments : List String
    , newComment : String
    }

type alias Feed =
    List Photo

type alias Model =
  { feed : Maybe Feed
  , error : Maybe Http.Error
  , streamQueue : Feed  -- #! Not a `Maybe`
  }

photoDecoder : Decoder Photo
photoDecoder =
  succeed Photo
    |> required "id" int
    |> required "url" string
    |> required "caption" string
    |> required "liked" bool
    |> required "comments" (list string)
    |> hardcoded ""


baseUrl : String
baseUrl =
    "https://programming-elm.com/"

{- #! WebSocket url -}
wsUrl : String
wsUrl =
    "wss://programming-elm.com"

initialModel : Model
initialModel =
    { feed = Nothing
    , error = Nothing
    , streamQueue = []
    }

init : () -> ( Model, Cmd Msg )
init () =
  ( initialModel, fetchFeed )

{- We're now using a `List Photo`, so our decoder is `list`
#! We're also using a `LoadFeed` message which accepts a
`Result` type and handles our `Err` if any. -}
fetchFeed : Cmd Msg
fetchFeed =
  Http.get
    { url = baseUrl ++ "feed"
    , expect = Http.expectJson LoadFeed (list photoDecoder)
    }


-- View ------------------------------------------------------------------------

viewLoveButton : Photo -> Html Msg
viewLoveButton photo =
    div [ class "like-button" ]
        [ i
            [ classList
              [ ("fa fa-2x", True)
              , ("fa-heart-o", not photo.liked)
              , ("fa-heart", photo.liked)
              ]
            , onClick (ToggleLike photo.id) -- Now using an `ID`
            ]
            []
        ]


viewComment : String -> Html Msg
viewComment comment =
    li []
        [ strong [] [ text "Comment:" ]
        , text (" " ++ comment)
        ]

viewCommentList : List String -> Html Msg
viewCommentList comments =
    case comments of
        [] ->
            text ""

        _ ->
            div [ class "comments" ]
                [ ul []
                    (List.map viewComment comments)
                ]

{- We're now saving a specific `Photo` using it's `ID` -}
viewComments : Photo -> Html Msg
viewComments photo =
    div []
        [ viewCommentList photo.comments
        , form [ class "new-comment", onSubmit (SaveComment photo.id) ] -- ID
            [ input
                [ type_ "text"
                , placeholder "Add a comment..."
                , value photo.newComment
                , onInput (UpdateComment photo.id) -- ID
                ]
                []
            , button
                [ disabled (String.isEmpty photo.newComment) ]
                [ text "Save" ]
            ]
        ]


viewDetailedPhoto : Photo -> Html Msg
viewDetailedPhoto photo =
    div [ class "detailed-photo" ]
        [ img [ src photo.url ] []
        , div [ class "photo-info" ]
            [ viewLoveButton photo
            , h2 [ class "caption" ] [ text photo.caption ]
            , viewComments photo
            ]
        ]

viewFeed : Maybe Feed -> Html Msg
viewFeed maybePhoto =
    case maybePhoto of
        Just feed ->
            div [] (List.map viewDetailedPhoto feed)
        Nothing ->
            div [ class "loading-feed" ]
                [ text "Loading Feed ..."]


{- Right now we're not handling the errors properly, just adding
some default text to handle the main cases -}
errorMessage : Http.Error -> String
errorMessage error =
    case error of
        Http.BadBody _ ->
            """Sorry, we couldn't process your feed at this time.
            We're working on it!"""

        _ ->
            """Sorry, we couldn't load your feed at this time.
            Please try again later."""

viewStreamNotification : Feed -> Html Msg
viewStreamNotification queue =
    case queue of
        [] ->
            text ""

        _ ->
            let
                content =
                    "View new photos:"
                        ++ String.fromInt (List.length queue)
            in
            div [ class "stream-notification"
                , onClick FlushStreamQueue
                ]
                [ text content ]

viewContent : Model -> Html Msg
viewContent model =
    case model.error of
        Just error ->
            div [ class "feed-error" ]
                [ text (errorMessage error) ]

        Nothing ->
            div []
                [ viewStreamNotification model.streamQueue
                , viewFeed model.feed
                ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "Picshare" ] ]
        , div [ class "content-flow" ]
            [ viewContent model ]
        ]


-- Update ----------------------------------------------------------------------
-- 1. We're now using an `ID` to update a specific `Photo`!
-- 2. Now provides a `List Photo` from `.json`. We also handle the
--   `Result` we get back from our `Http` response and handle any errors
--    in the update function.
-- 3. Here we load a `WebSocket` stream of photos. It used to simply hold a
--    a `String` (the `event.data`), but now holds a `Result`.
-- 4. Does what it says ... deletes the stream data.

type Msg
    = ToggleLike ID -- (1)
    | UpdateComment ID String
    | SaveComment ID
    | LoadFeed (Result Http.Error (List Photo)) -- (2)
    | LoadStreamPhoto (Result Json.Decode.Error Photo) -- (3)
    | FlushStreamQueue -- (4)


-- START:saveNewComment
saveNewComment : Photo -> Photo
saveNewComment photo =
    let
        comment =
            String.trim photo.newComment
    in
    case comment of
        "" ->
            photo

        _ ->
            { photo
                | comments = photo.comments ++ [ comment ]
                , newComment = ""
            }
-- END:saveNewComment


toggleLike : Photo -> Photo
toggleLike photo =
    { photo | liked = not photo.liked }

updateComment : String -> Photo -> Photo
updateComment comment photo =
    { photo | newComment = comment }

{- Our model is a `Maybe Feed`, so we need a way to "lift" the `Feed`,
grab a `Photo` by it's `ID`, and use an update function on it's attributes -}
updateFeed : (Photo -> Photo) -> ID -> Maybe Feed -> Maybe Feed
updateFeed updatePhoto id maybeFeed =
    Maybe.map (updatePhotoById updatePhoto id) maybeFeed

{- We add the `updatePhoto` function first, then the `ID`.
The anonymous function looks a bit ugly here, we could probably
do better. `List.filter` would only return a `Photo`, not a
the `Feed` that we'd need -}
updatePhotoById : (Photo -> Photo) -> ID -> Feed -> Feed
updatePhotoById updatePhoto id feed =
    List.map (\photo ->
                if photo.id == id then
                    updatePhoto photo
                else
                    photo
            )
            feed

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike id ->
            ( { model
                | feed = updateFeed toggleLike id model.feed }  -- This is more succinct!
            , Cmd.none )

        UpdateComment id comment ->
            ( { model | feed = updateFeed (updateComment comment) id model.feed }
            , Cmd.none )

        SaveComment id ->
            ( { model | feed = updateFeed saveNewComment id model.feed }
            , Cmd.none )

        {- We handle our initial `Cmd` for `Http` here. It's a `Result` type,
        so we'll get `Ok` or `Err`. If we get our initial feed from our url,
        we then call our `WebSocket` port for more photos. -}
        LoadFeed (Ok photoList) ->
            ( { model | feed = Just photoList }
            , WS.listen wsUrl -- A `Cmd` that turns into a `Msg`?
            )

        {- #! Handle any errors from our `Http` request here -}
        LoadFeed (Err error) ->
            ( { model | error = Just error }, Cmd.none )

        {- #! Here we handle our WebSockets subscriptions, we now convert
        our `json` string with our `subscriptions` function, which we receive
        from `event.data` (in the html js code) -}
        LoadStreamPhoto (Ok photo) ->
            ( { model | streamQueue = photo :: model.streamQueue }
            , Cmd.none
            )

        {- If there's a problem with our data for whatever reason, we could
        print out the errors here -}
        LoadStreamPhoto (Err _) ->
            ( model, Cmd.none )

        {- Append any new photos to the list, and reset `streamQueue` -}
        FlushStreamQueue ->
            ( { model
                | feed = Maybe.map ((++) model.streamQueue) model.feed
                , streamQueue = []
            }
            , Cmd.none )

-- Main ------------------------------------------------------------------------

{- Now using `WebSockets`. Here we manually decode our `event.data` with the
`decodeString` method: https://tinyurl.com/elm-json-decodeString — we're also
using the `<<` function compose operator -}
subscriptions : Model -> Sub Msg
subscriptions model =
    WS.receive
        (LoadStreamPhoto << decodeString photoDecoder)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
