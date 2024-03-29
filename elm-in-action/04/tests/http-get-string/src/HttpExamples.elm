module HttpExamples exposing (main)

import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Browser


-- Model -----------------------------------------------------------------------

type alias Model =
  { nicknames : List String
  , errorMessage : Maybe String
  }


initialModel : Model
initialModel =
  { nicknames = []
  , errorMessage = Nothing
  }


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick SendHttpRequest ]
      [ text "Get data from the server" ]
    , viewNicknamesOrError model
    ]

viewNicknamesOrError : Model -> Html Msg
viewNicknamesOrError model =
  case model.errorMessage of
      Just message ->
        viewError message
      Nothing ->
        viewNicknames model.nicknames

viewError : String -> Html Msg
viewError errorMessage =
  let
    errorHeading =
      "Couldn't fetch nicknames at this time."
  in
    div []
      [ h3 [] [ text errorHeading ]
      , text ("Error: " ++ errorMessage)
      ]


viewNicknames : List String -> Html Msg
viewNicknames nicknames =
  div []
    [ h3 [] [ text "Old School Main Characters" ]
    , ul [] (List.map viewNickname nicknames)
    ]

viewNickname : String -> Html Msg
viewNickname nickname =
  li [] [ text nickname ]


-- Update ----------------------------------------------------------------------

-- #1 `Http.get` type signature looks like this:
--     `get : { url : String, expect : Expect msg } -> Cmd Msg`
--
--     : It takes a record with two fields and returns a Cmd
--     : `Random.generate` and `Http.get` are structurally different,
--       but hold similar key ingredients":
--
--     1. A mechanism for creating a command
--     2. What needs to happen when the command is run?
--     3. Which message should be sent to the app after the
--        command has been executed?
--
-- #2 `Http.expectString` looks like this:
--     `expectString : (Result Http.Error String -> msg) -> Expect msg
--
--     : Elm Runtime will send a `Msg` to update for us.
--
-- #3  Elm has a Type for called `Result`. It accepts two arguments,
--     `error` and `value` which pass through to the `Ok value` or
--     `Err error` type variants.
--
--     : Our `Msg` for Random is simpler, because it always succeeds.
--       Fetching data from a server can fail. Perhaps the server isn’t
--       available or the URL we’re trying to reach is incorrect.
--
-- #4  `Http.Error` is a built-in custom type!
--
--      type Error
--        = BadUrl String
--        | Timeout
--        | NetworkError
--        | BadStatus Int
--        | BadBody String
--
-- #5  We need to tell the `update` function what to do when the
--     `DataReceived` message arrives! All we are doing here is
--     unpacking the result payload that rides on `DataReceived`’s back.
--
--     : We can use pattern matching instead of nested `case`.
--       @ http://tinyurl.com/beginning-elm-pattern-matching
--
--     : We’ve also replaced the payload httpError with `_`
--       because we aren’t using it right now.
--
-- #6  Errors ... try loading with an incorrect `url` for example:
--     @ http://localhost:5016/invalid.txt
--
--     : We use a function called `buildErrorMessage` to `case` on all possible
--       `Http.Error`s and return a String for each one.
--
--     : We wrap the result in a `Just String` which we'll use in the `view`!
--       We `case` again with a `viewNicknamesOrError` helper function, and
--       pass forward the data that we need.
--
--       - `viewError String` or `viewNicknames List String`.

type Msg
  = SendHttpRequest
  | DataReceived (Result Http.Error String)  -- #3, #4

url : String
url =
  "http://localhost:5016/old-school.txt"  -- #6

getNicknames : Cmd Msg
getNicknames =
  Http.get  -- #1
    { url = url
    , expect = Http.expectString DataReceived  -- #2
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SendHttpRequest ->
      ( model, getNicknames )

    DataReceived (Ok nicknamesStr) ->  -- #5
      let
        nicknames =
          String.split "," nicknamesStr
      in
      ( { model |  nicknames = nicknames }, Cmd.none )
    DataReceived (Err error) ->
      ( { model | errorMessage = Just (buildErrorMessage error) }  -- #6
      , Cmd.none
      )

buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
  case httpError of
    Http.BadUrl message ->
      message
    Http.Timeout ->
      "Server taking too long to respond"
    Http.NetworkError ->
      "Unable to reach server."
    Http.BadStatus statusCode ->
      "Request failed with status code " ++ String.fromInt statusCode
    Http.BadBody message ->
      message


-- Making it all work with main ------------------------------------------------

-- #1  flags unused
-- #2  subscriptions unused

main : Program () Model Msg
main =
  Browser.element
    { init = \_ -> ( initialModel, Cmd.none )  -- #1
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none  -- #2
    }
