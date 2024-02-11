module HttpExamples exposing (main)

{-| Here's what's going on:

    1. Setup our `initialModel` and pass it to `main`
    2. Click on a button to call `onClick` which sends a `Msg`
    3. This triggers a `Http.get` which in turn sends a payload
       (via a `Cmd` to our other `Msg` type variant, `DataReceived`.
    4. This triggers one of the `case` expressions in `update` with either
       an `Ok` or an `Err`.
    5. If there's an issue with the server, we load our `view` with
       the error message.

    That's the data request done. You _could_ add a `Loading | Loaded`
    `Msg` type there as well. The next thing we need to do is to check
    that our data is a valid JSON string:

    1. We `case` again with our decoder and return `Ok` or error.
       So we've now cased twice — one for loading the data, one for checking
       the data is valid.

    2. The `case` expression updates the model if JSON is `Ok` and our list
       will load into `view`. If there's a JSON error, we update the model record
       to display _that_ error (so there's two potential errors that can show).

    So we're casing a few times. In `view` and in `update`.

-}

import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Browser
import Json.Decode exposing (Decoder, Error(..), decodeString, list, string)


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

-- #1  Elm has a Type called `Result`. It accepts two arguments,
--     in containers `Ok value` or `Err error` type variants.
--
--     : Our `Msg` for Random is simpler, because it always succeeds.
--       Fetching data from a server can fail. Perhaps the server isn’t
--       available or the URL we’re trying to reach is incorrect.
--
--
-- #2  `Http.Error` is a built-in custom type!
--
--      type Error
--        = BadUrl String
--        | Timeout
--        | NetworkError
--        | BadStatus Int
--        | BadBody String
--
--
-- #3  Errors ... try loading with an incorrect `url` for example:
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
--
--
-- #4 `Http.expectJson` looks like this:
--     `expectJson : (Result Http.Error a -> msg) Decoder a -> Expect msg
--
--     : Unlike `Http.expectString`, we pass the decoder in straight away,
--       no need for a nested `case` statement for the JSON decoder.
--
--     : Elm Runtime will send a `Msg` to update for us.
--
--     Our decoders can be an `atom`, or a `List atom` (or a nested list).
--     This generates a `Decoder` that knows how to translate a JSON array
--     into a list of Elm `String`s.
--
--     `list` is a function that returns a decoder:
--         `Decoder a -> Decoder (List a)`
--     `string` returns a Decoder:
--         `Decoder string`
--      `list string` returns a Decoder:
--          `Decoder (List String)`
--
--     : These by themselves DO NOT DECODE JSON. It's like a recipe, or
--       instructions to be passed on to a function like `decodeString`
--       or `decodeJson`, which does the actual decoding. These functions
--       apply the Decoder to the `string` or `json`.
--
--        @ http://tinyurl.com/elm-lang-http-expectJson
--        @ http://tinyurl.com/elm-lang-http-expectString
--        @ http://tinyurl.com/elm-lang-json-decode-string
--        @ http://tinyurl.com/elm-lang-json-decode-error
--
--      : You can create larger decoders by using primitive decoders and
--        using them as building blocks. All elements in a list need to
--        be the same type! (just like Elm lists)
--
--
-- #5 `Http.get` type signature looks like this:
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
--     It now does two things:
--
--     1. Checks the server is available (responsive),
--     2. Checks if the JSON is valid and returns `Ok (elm data)`
--        or an `Err`or.
--
--     @ http://tinyurl.com/elm-lang-json-decode-error
--
--
-- #6  We need to tell the `update` function what to do when the
--     `DataReceived` message arrives! All we are doing here is
--     unpacking the result payload that rides on `DataReceived`’s back.
--
--     : We can use pattern matching instead of nested `case`.
--       @ http://tinyurl.com/beginning-elm-pattern-matching
--


type Msg
  = SendHttpRequest
  | DataReceived (Result Http.Error (List String))  -- #1, #2

url : String
url =
  "http://localhost:5019/nicknames"  -- #3

getNicknames : Cmd Msg
getNicknames =
  Http.get  -- #5
    { url = url
    , expect = Http.expectJson DataReceived nicknamesDecoder -- #4
    }

nicknamesDecoder : Decoder (List String)
nicknamesDecoder =
  list string  -- #7

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SendHttpRequest ->
      ( model, getNicknames )  -- Http.get and return payload

    DataReceived (Ok nicknames) ->  -- #1, #4, #6  payload piggybacks on type variant
      ( { model | nicknames = nicknames }, Cmd.none )  -- store `List String`

    DataReceived (Err httpError) ->
      ( { model | errorMessage = Just (buildErrorMessage httpError) }  -- #2, #3
      , Cmd.none
      )

buildErrorMessage : Http.Error -> String  -- #9
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
