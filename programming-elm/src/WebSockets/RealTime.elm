module WebSockets.RealTime exposing (..)

{-| Communicating with the servers
    ------------------------------

    Previous versions of this app ...
    ---------------------------------
    @ src/RefactorEnhance/Picshare04.elm
    @ src/Communicate/WithServers.elm


    This version's tasks
    --------------------
    We have two loading states in our view: one for the `Maybe Feed`, one for the
    `Maybe Http.Error`. We're covering knowledge such as: `Maybe`, `Result`,
    `Json.Decode.Pipeline`, `json`, `Browser.element`, `List.map`, `Html.Attributes`,
    `Html.events` ...

    1. Disable the form if `String.empty` for `newComment`
    2. Validate the form after clicked button (with `photo.id`)
    3. Store a `List String` of comments
    4. Use more than one `Photo`
    5. Create a real-time stream of `List Photo` (websockets)
    6. Search the feed to like or comment a `Photo`
    7. Add any `Err`ors to our `Model` (with `Maybe` type)

    Using an ID to update the comment
    ---------------------------------

    1. We're passing through an `Id` to our `Msg`!
    2. We're still using `List.map`, but our `Maybe.map` is now "lifting" a
      `Maybe Feed` rather than a `Maybe Photo`. Our main update function must
      return a `Feed` (which is a `List Photo`)
        - It's also possible to use `List.filter`
          @ https://tinyurl.com/elm-playground-4d7819c
          but that'd only filter a single `Photo` (with `ID`) so we'd have to
          rejoin it to the main `List Photo` (our `Feed`)


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
import Json.Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Http


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


initialModel : Model
initialModel =
    { feed = Nothing
    , error = Nothing
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
            , onClick (ToggleLike photo.id) -- Now using an Id
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
        , form [ class "new-comment", onSubmit (SaveComment photo.id) ] -- Id
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

viewContent : Model -> Html Msg
viewContent model =
    case model.error of
        Just error ->
            div [ class "feed-error" ]
                [ text (errorMessage error) ]

        Nothing ->
            viewFeed model.feed

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

type Msg
    = ToggleLike ID -- (1)
    | UpdateComment ID String
    | SaveComment ID
    | LoadFeed (Result Http.Error (List Photo)) -- (2)


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
            ( { model | feed = updateFeed (updateComment comment) id model.feed }  -- (8)
            , Cmd.none )

        SaveComment id ->
            ( { model | feed = updateFeed saveNewComment id model.feed }
            , Cmd.none )

        LoadFeed (Ok photoList) ->
            ( { model | feed = Just photoList }
            , Cmd.none )

        -- #! We're handling any returned errors from our Http response here
        LoadFeed (Err error) ->
            ( { model | error = Just error }, Cmd.none )


-- Main ------------------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
