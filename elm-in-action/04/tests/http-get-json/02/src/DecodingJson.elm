module DecodingJson exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, int, list, map3, string)
import Json.Decode.Pipeline exposing (optional, optionalAt, required, requiredAt)


-- Model -----------------------------------------------------------------------

type alias Post =
  { id : Int
  , title : String
  , author : String
  }

type alias Model =
  { posts : List Post
  , errorMessage : Maybe String
  }


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick SendHttpRequest ]
        [ text "Get data from the server" ]
      , viewPostsOrError model
    ]

viewPostsOrError : Model -> Html Msg
viewPostsOrError model =
  case model.errorMessage of
      Just message ->
        viewError message
      Nothing ->
        viewPosts model.posts

viewError : String -> Html Msg
viewError errorMessage =
  let
    errorHeading =
      "Couldn't fetch data at this time."
  in
    div []
      [ h3 [] [ text errorHeading ]
      , text ("Error: " ++ errorMessage)
      ]

viewPosts : List Post -> Html Msg
viewPosts posts =
  div []
    [ h3 [] [ text "Posts" ]
    , table []
      ([ viewTableHeader ] ++ List.map viewPost posts)
    ]

viewTableHeader : Html Msg
viewTableHeader =
  tr []
    (List.map viewTableHeaderItem ["ID", "Title", "Author"])

viewTableHeaderItem : String -> Html Msg
viewTableHeaderItem header =
    th [] [ text header ]

viewPost : Post -> Html Msg
viewPost post =
  tr []
    [ td []
        [ text (String.fromInt post.id) ]
    , td []
        [ text post.title ]
    , td []
        [ text post.author ]
    ]


-- Update ----------------------------------------------------------------------

-- #1  We added Decode as an alias, so we can write it this way.
--     `Decode.succeed` function ignores the given JSON and always
--     produces a specific value.

type Msg
  = SendHttpRequest
  | DataReceived (Result Http.Error (List Post))

postDecoder : Decoder Post
postDecoder =
  Decode.succeed Post
    |> required "id" int
    |> required "title" string
    |> required "author" string

httpCommand : Cmd Msg
httpCommand =
  Http.get
    { url = "http://localhost:5019/posts"
    , expect = Http.expectJson DataReceived (list postDecoder)
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
      SendHttpRequest ->
        (model, httpCommand )

      DataReceived (Ok posts) ->
        ( { model
            | posts = posts
            , errorMessage = Nothing
          }
        , Cmd.none
        )

      DataReceived (Err httpError) ->
        ( { model
            | errorMessage = Just (buildErrorMessage httpError)
          }
        , Cmd.none
        )

buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
  case httpError of
    Http.BadUrl message ->
      message

    Http.Timeout ->
      "Server is taking too long to respond. Please try again later"

    Http.NetworkError ->
      "Unable to reach server"

    Http.BadStatus statusCode ->
      "Request failed with status code: " ++ String.fromInt statusCode

    Http.BadBody message ->
      message


-- Main ------------------------------------------------------------------------

init : () -> ( Model, Cmd Msg )
init _ =
  ( { posts = []
    , errorMessage = Nothing
    }
  , Cmd.none
  )

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
