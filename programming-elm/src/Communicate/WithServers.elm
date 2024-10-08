module Communicate.WithServers exposing (main)

{-| Communicating with the servers
    ------------------------------

    Our process in Chapter 4 has been as follows:

    1. Create the `Model` you'd expect to see if everything validates:
        @ https://shorturl.at/L39Zm

    2. Create our `decoder` and our `fetchFeed` stuff with a `Msg` type,
       but don't bother to unpack or use it just yet.
       - At this point you could build out your tests for the decoder.

    3. Using our `Model` (which we convert to a `Maybe` type), build out all
       the functionality we need to consume and use it.

    4. Finally, once all that's done, we can load and validate the `json` from
       our server.

    Decoders are difficult!
    -----------------------
    Here is a visual introduction to our decoders, and how things get verified
    and passed around:

        @ link


    (1) — (6) Comment field submission
    -----------------------------------
    Go to `src/RefactorEnhance/Picshare04.elm` learn how our `viewComments`
    form handles our comment entries and submit. It's reasonably straight forward.

    @ See also page 57 in the PDF

    Elm protects us from the outside world, by making some states impossible.
    You should never be able to have unexpected JSON break your app. It'll
    error out, and you'll be able to decide what to do with unexpected JSON.


    (7) — (More notes)
    -------------------

    We're essentially doing the same things as we were in Chapter 3, which you
    can view in `src/RefactorEnhance/Picshare04.elm`, but we've changed to using
    a `Maybe Photo` and we're now pulling in json from the server.

    (7) You could've simplified things here by using `Maybe.withDefault`, without
        the need for a `case` statement, but the following won't work! It needs
        to return the same type. `text` is a `Html Msg` and `model.photo` is `Photo`.

            `withDefault (text "") model.photo`

    (8) Remember that this uses a curried function (the function is partially
        applied) and uses the `comment`. Note also that we're using a `Maybe.map`
        so that we can properly handle a `Maybe Photo` type, which will either
        be a `Nothing` or a `Just Photo`!

    (9) It's pretty simple to validate your server's `json` by using pattern
        matching in the two branches. For `Err`ors you can get really specific
        and even try again if there's some problem with the server:

        @ https://package.elm-lang.org/packages/elm/http/latest/Http#Error

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
  { photo: Maybe Photo }

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
    { photo = Nothing }

init : () -> ( Model, Cmd Msg )
init () =
  ( initialModel, fetchFeed )

fetchFeed : Cmd Msg
fetchFeed =
  Http.get
    { url = baseUrl ++ "feed/1"
    , expect = Http.expectJson LoadFeed photoDecoder
    }

{-| If you put a comment here, you can add a [link](http://docs.com)
    and _italics_ or **bold** and the plugin we're using will add it
    as "documentation" when you hover over the function where it's
    being used! Quite useful. -}
viewLoveButton : Photo -> Html Msg
viewLoveButton photo =
    div [ class "like-button" ]
        [ i
            [ classList
              [ ("fa fa-2x", True)
              , ("fa-heart-o", not photo.liked)
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
        , form [ class "new-comment", onSubmit SaveComment ] -- (1)
            [ input
                [ type_ "text"
                , placeholder "Add a comment..."
                , value photo.newComment -- (2)
                , onInput UpdateComment  -- (3)
                ]
                []
            , button
                [ disabled (String.isEmpty photo.newComment) ] -- (4)
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
            [ viewFeed model.photo ]  -- (7)
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
            photo  -- (5)

        _ ->       -- (6)
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
            ( { model | photo = Just photo }  -- (9)
            , Cmd.none )

        LoadFeed (Err _) ->
            ( model, Cmd.none )               -- (9)
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
