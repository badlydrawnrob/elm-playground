module Picshare04 exposing (main)

{-| Our comments form
    -----------------

    (1) Add an `onSubmit` event handler with the `SaveComment` message to the form.
        This will allow users to click on the Save button or hit the Return key
        to save a comment.

    (2) Let the value of the input field reflect what’s currently in the model’s
        `newComment` field. You’ll need this when you clear the input later in
        the update function.

    (3) Add an `onInput` event handler with the `UpdateComment` message to the input.

    (4) Disable the button if the `newComment` field is currently empty.
        This prevents users from submitting empty comments.

    (5) In the book it says this:

          "Even though you disable the Save button when newComment is empty, you
          can still technically submit with the Enter key. You’ll catch that here
          and ignore it by just returning the current model. This ensures you
          don’t accidentally add an empty comment to the comment list."

        But checking an empty string seems unnecessary,

    (6) If you don’t have the empty string, then you use the wildcard to match
        any other string.

-}

import Browser
import Html exposing (..)
-- START:imports
import Html.Attributes
    exposing
        ( class, disabled, placeholder, src, type_, value )
import Html.Events exposing (onClick, onInput, onSubmit)
-- END:imports


type alias Model =
    { url : String
    , caption : String
    , liked : Bool
    , comments : List String
    , newComment : String
    }


baseUrl : String
baseUrl =
    "https://programming-elm.com/"


initialModel : Model
initialModel =
    { url = baseUrl ++ "1.jpg"
    , caption = "Surfing"
    , liked = False
    , comments = [ "Cowabunga, dude!" ]
    , newComment = ""
    }


viewLoveButton : Model -> Html Msg
viewLoveButton model =
    let
        buttonClass =
            if model.liked then
                "fa-heart"

            else
                "fa-heart-o"
    in
    div [ class "like-button" ]
        [ i
            [ class "fa fa-2x"
            , class buttonClass
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

        _ ->  -- (6)
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
