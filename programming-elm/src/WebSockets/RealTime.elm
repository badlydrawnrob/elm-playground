module WebSockets.RealTime exposing (..)

{-| Communicating with the servers
    ------------------------------

    What we're gonna do
    -------------------

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


    Commenting
    ----------

    Using Elm Tooling, you can write a comment above a function with `{-|-}`. You
    can write it as you would Markdown. When you come to use that function, you
    can select it and the "documentation" will show up under it's type signature.

    Might be an idea to use both `(1)` numbers with comments for a run-down of
    what the module is all about, plus documentation comments for more in-depth
    function analysis.

    For previous versions of this app ...
    -------------------------------------
    @ src/RefactorEnhance/Picshare04.elm
    @ src/Communicate/WithServers.elm

    1. Got a `Maybe Photo` we're pulling in with `json` from a server,
    2. Liking or unliking this photo, and adding a `List comment` with a form,
    3. We've got a `Loading` state and a `Loaded` state in our `view`.

    These cover things like `Maybe`, `Result`, `Json.Decode.Pipeline`,
    `Browser.element`, `List.map`, `Html.Attributes`, `Html.events`.


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    1. Create `errorMessage` function

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

{- We're now using a `List Photo`, so our decoder is `list` -}
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
-- 2. Now provides a `List Photo` from `.json`

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

        LoadFeed (Err _) ->
            ( model, Cmd.none )


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
