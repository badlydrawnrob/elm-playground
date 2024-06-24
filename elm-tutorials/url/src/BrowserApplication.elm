module BrowserApplication exposing (main)

{-| Korban "URL handling with Browser.application"
    ----------------------------------------------
    @ https://shorturl.at/5bhAv

    Some beginner stuff using URL in Elm. It expands on some missing
    stuff from the Elm Guide @ https://guide.elm-lang.org/webapps/url_parsing.html
    such as:

    1. Our `update` parses the URL when it gets a `URLChanged` message
    2. Our `view` function shows different content for different addresses!

-}

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>))


type Msg
    = ChangeUrl Url
    | ClickLink UrlRequest


type alias DocsRoute =
    ( String, Maybe String )


type alias Model =
    { navKey : Nav.Key
    , route : Maybe DocsRoute
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    ( { navKey = navKey, route = UrlParser.parse docsParser url }, Cmd.none )


docsParser : UrlParser.Parser (DocsRoute -> a) a
docsParser =
    UrlParser.map Tuple.pair (UrlParser.string </> UrlParser.fragment identity)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeUrl url ->
            ( { model | route = UrlParser.parse docsParser url }, Cmd.none )

        ClickLink urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.navKey <| Url.toString url )

                External url ->
                    ( model, Nav.load url )


view : Model -> Document Msg
view model =
    let
        inline =
            style "display" "inline-block"

        padded =
            style "padding" "10px"

        menu =
            div [ style "padding" "10px", style "border-bottom" "1px solid #c0c0c0" ]
                [ a [ inline, padded, href "/Basics" ] [ text "Basics" ]
                , a [ inline, padded, href "/Maybe" ] [ text "Maybe" ]
                , a [ inline, padded, href "/List" ] [ text "List" ]
                , a [ inline, padded, href "/List#map" ] [ text "List.map" ]
                , a [ inline, padded, href "/List#filter" ] [ text "List.filter" ]
                ]

        title =
            case model.route of
                Just route ->
                    Tuple.first route
                        ++ (case Tuple.second route of
                                Just function ->
                                    "." ++ function

                                Nothing ->
                                    ""
                           )

                Nothing ->
                    "Invalid route"
    in
    { title = "URL handling example"
    , body =
        [ menu
        , h2 [] [ text title ]
        ]
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = ClickLink
        , onUrlChange = ChangeUrl
        }
