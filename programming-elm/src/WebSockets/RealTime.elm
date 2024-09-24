module WebSockets.RealTime exposing (..)

{-| Communicating with the servers
    ------------------------------

    What we're gonna do
    -------------------

    1. Disable the form if `String.empty` for `newComment`
    2. Validate the form after clicked button
    3. Store a `List String` of comments
    4. Use more than one `Photo`
    5. Create a real-time stream of `List Photo` (websockets)
    6. Search the feed to like or comment a `Photo`

    Using an ID to update the comment
    ---------------------------------

    We're passing through an `Id` to our `Msg`!


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
  { feed : Maybe Feed }

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
    { feed = Nothing }

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
              , ("fa-heart-0", not photo.liked)
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

{- We're now saving a specific `Photo` using it's `Id` -}
viewComments : Photo -> Html Msg
viewComments photo =
    div []
        [ viewCommentList photo.comments
        , form [ class "new-comment", onSubmit (SaveComment photo.id) ] -- Id
            [ input
                [ type_ "text"
                , placeholder "Add a comment..."
                , value photo.newComment
                , onInput (UpdateComment photo.id) -- Id
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


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "Picshare" ] ]
        , div [ class "content-flow" ]
            [ viewFeed model.feed ]
        ]


-- Update ----------------------------------------------------------------------
-- 1. We're now using an `Id` to update a specific `Photo`!
-- 2. Now provides a `List Photo` from `.json`
type Msg
    = ToggleLike Id -- (1)
    | UpdateComment Id String
    | SaveComment Id
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

updateComment : Id -> String -> Photo -> Photo
updateComment id comment photo =
    { photo | newComment = comment }

updateFeed : (Photo -> Photo) -> Maybe Photo -> Maybe Photo
updateFeed updatePhoto maybePhoto =
    Maybe.map updatePhoto maybePhoto

{- Gets passed to `List.filter` -}
isPhotoId : Id -> Photo -> Boolean
isPhotoId id photo =
    if id == photo.id then True else False

{- Takes a list and returns a Photo with `Id` -}
updatePhotoById : List Photo -> Photo
updatePhotoById id photoList =
    List.filter (filterFeed id) photoList


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike id ->
            ( { model
                | feed = updatePhotoById id model.feed |> (updateFeed toggleLike) }
            , Cmd.none )

        -- UpdateComment id comment ->
        --     ( { model | photo = updateFeed (updateComment comment) model.photo }  -- (8)
        --     , Cmd.none )

        -- SaveComment id ->
        --     ( { model | photo = updateFeed saveNewComment model.photo }
        --     , Cmd.none )

        LoadFeed (Ok photoList) ->
            ( { model | feed = Just photoList }
            , Cmd.none )

        LoadFeed (Err _) ->
            ( model, Cmd.none )

        _ ->
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
