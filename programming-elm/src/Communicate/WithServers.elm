module Communicate.WithServers exposing (..)

{-| Communicating with the servers
    ------------------------------

    See `src/RefactorEnhance/Picshare04.elm` for instructions on how
    our `viewComments` form is handling comment entries and submit.
    It's reasonably straight forward.

    @ See also page 57 in the PDF

    Elm protects us from the outside world, by making some states impossible.
    You should never be able to have unexpected JSON break your app. It'll
    error out, and you'll be able to decide what to do with unexpected JSON.

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing ( class, classList, disabled, placeholder, src, type_, value )
import Html.Events exposing (onClick, onInput, onSubmit)


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


update : Msg -> Model -> Model
-- START:update
update msg model =
    case msg of
        ToggleLike ->
            { model | liked = not model.liked }

        UpdateComment comment ->
            { model | newComment = comment }

        SaveComment ->
            saveNewComment model
-- END:update


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
