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
  { photo: Maybe Feed }

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

fetchFeed : Cmd Msg
fetchFeed =
  Http.get
    { url = baseUrl ++ "feed/1"
    , expect = Http.expectJson LoadFeed (list photoDecoder)
    }

viewLoveButton : Photo -> Html Msg
viewLoveButton photo =
    div [ class "like-button" ]
        [ i
            [ classList
              [ ("fa fa-2x", True)
              , ("fa-heart-0", not photo.liked)
              , ("fa-heart", photo.liked)
              ]
            , onClick ToggleLike
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


viewComments : Photo -> Html Msg
-- START:viewComments
viewComments photo =
    div []
        [ viewCommentList photo.comments
        , form [ class "new-comment", onSubmit SaveComment ]
            [ input
                [ type_ "text"
                , placeholder "Add a comment..."
                , value photo.newComment
                , onInput UpdateComment
                ]
                []
            , button
                [ disabled (String.isEmpty photo.newComment) ]
                [ text "Save" ]
            ]
        ]
-- END:viewComments


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

viewFeed : Maybe Photo -> Html Msg
viewFeed maybePhoto =
    case maybePhoto of
        Just photo ->
            viewDetailedPhoto photo
        Nothing ->
            div [ class "loading-feed" ]
                [ text "Loading Feed ..."]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "Picshare" ] ]
        , div [ class "content-flow" ]
            [ viewFeed model.photo ]
        ]


-- START:msg
type Msg
    = ToggleLike
    | UpdateComment String
    | SaveComment
    | LoadFeed (Result Http.Error Photo)
-- END:msg


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

updateFeed : (Photo -> Photo) -> Maybe Photo -> Maybe Photo
updateFeed updatePhoto maybePhoto =
    Maybe.map updatePhoto maybePhoto

update : Msg -> Model -> ( Model, Cmd Msg )
-- START:update
update msg model =
    case msg of
        ToggleLike ->
            ( { model | photo = updateFeed toggleLike model.photo }
            , Cmd.none )

        UpdateComment comment ->
            ( { model | photo = updateFeed (updateComment comment) model.photo }  -- (8)
            , Cmd.none )

        SaveComment ->
            ( { model | photo = updateFeed saveNewComment model.photo }
            , Cmd.none )

        LoadFeed (Ok photo) ->
            ( { model | photo = Just photo }
            , Cmd.none )

        LoadFeed (Err _) ->
            ( model, Cmd.none )
-- END:update

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
