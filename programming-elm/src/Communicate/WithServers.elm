module Communicate.WithServers exposing (main)

{-| Communicating with the servers
    ------------------------------

    See `src/RefactorEnhance/Picshare04.elm` for instructions on how
    our `viewComments` form is handling comment entries and submit.
    It's reasonably straight forward.

    @ See also page 57 in the PDF

    Elm protects us from the outside world, by making some states impossible.
    You should never be able to have unexpected JSON break your app. It'll
    error out, and you'll be able to decide what to do with unexpected JSON.

    Decoders are difficult
    ----------------------
    Write a simple introduction for a 12 year old.
    Use images and simple words where possible.

    @ see pg.69 and surrounding pages

    You're basically passing your record down the line through a few decoders,
    which check the json object `key`s and match them (in the order of the decoders)
    to the variables in your curried function.

    Order matters! It follows the order for the `Photo` constructor function
    arguments. If you accidently passed a required `String` json object to a
    `Photo` `int`, you're going to have problems!

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

type alias Model =
  Photo

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
    { id = 1
    , url = baseUrl ++ "1.jpg"
    , caption = "Surfing"
    , liked = False
    , comments = [ "Cowabunga, dude!" ]
    , newComment = ""
    }

init : () -> ( Model, Cmd Msg )
init () =
  ( initialModel, fetchFeed )

fetchFeed : Cmd Msg
fetchFeed =
  Http.get
    { url = baseUrl ++ "feed/1"
    , expect = Http.expectJson LoadFeed photoDecoder
    }

viewLoveButton : Model -> Html Msg
viewLoveButton model =
    div [ class "like-button" ]
        [ i
            [ classList
              [ ("fa fa-2x", True)
              , ("fa-heart-0", not model.liked)
              , ("fa-heart", model.liked)
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


viewComments : Model -> Html Msg
-- START:viewComments
viewComments model =
    div []
        [ viewCommentList model.comments
        , form [ class "new-comment", onSubmit SaveComment ] -- (1)
            [ input
                [ type_ "text"
                , placeholder "Add a comment..."
                , value model.newComment -- (2)
                , onInput UpdateComment -- (3)
                ]
                []
            , button
                [ disabled (String.isEmpty model.newComment) ] -- (4)
                [ text "Save" ]
            ]
        ]
-- END:viewComments


viewDetailedPhoto : Model -> Html Msg
viewDetailedPhoto model =
    div [ class "detailed-photo" ]
        [ img [ src model.url ] []
        , div [ class "photo-info" ]
            [ viewLoveButton model
            , h2 [ class "caption" ] [ text model.caption ]
            , viewComments model
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "Picshare" ] ]
        , div [ class "content-flow" ]
            [ viewDetailedPhoto model ]
        ]


-- START:msg
type Msg
    = ToggleLike
    | UpdateComment String
    | SaveComment
    | LoadFeed (Result Http.Error Photo)
-- END:msg


-- START:saveNewComment
saveNewComment : Model -> Model
saveNewComment model =
    let
        comment =
            String.trim model.newComment
    in
    case comment of
        "" ->
            model  -- (5)

        _ ->       -- (6)
            { model
                | comments = model.comments ++ [ comment ]
                , newComment = ""
            }
-- END:saveNewComment


update : Msg -> Model -> ( Model, Cmd Msg )
-- START:update
update msg model =
    case msg of
        ToggleLike ->
            ( { model | liked = not model.liked }
            , Cmd.none )

        UpdateComment comment ->
            ( { model | newComment = comment }
            , Cmd.none )

        SaveComment ->
            ( saveNewComment model
            , Cmd.none )

        LoadFeed _ ->
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
