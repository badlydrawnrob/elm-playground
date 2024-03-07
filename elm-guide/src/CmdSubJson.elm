module CmdSubJson exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, map4, field, int, string)

{-| Getting Json from the server

    Random quotes from a selection of books
    The URL we're using automatically randomises the
    quotes.

    See the link for more options when decoding json:

      @ https://guide.elm-lang.org/effects/json

    ----

    We could use a standard JSON file with different quotes
    as arrays, and use `Random.uniform` to select them
    from an Elm data structure.

    It raises the question, which is the better method?

    1. A standalone Random generator for quotes as a Json api
        - Then fetch that single quote somewhere in your site
    2. Pull in a Json set of arrays, and store as Elm data type
        - In the same program/page, randomise the quote.

    Both methods are valid. I think in this version Evan's using
    a backend script to randomise the quotes.

    NOTE:
    -----

      I've made some minor changes to _destructure_ the `Quote`
      record type, so that it's a little shorter (only a little)

      @ https://gist.github.com/yang-wei/4f563fbf81ff843e8b1e

    WHY DECODERS?
    -------------

      We have no guarantees about any of the information here.
      The server can change the names of fields, and the fields may
      have different types in different situations. It is a wild world!

      In Elm, we validate the JSON before it comes into our program.

        { "age": 42 }      --> DECODER INT    --> 42
        { "name": "Tom" }  --> DECODER STRING --> "Tom"

      We then snap them together and feed them to an Elm type:

        type alias Person = { name : String, age : Int }

        map2 Person              -- Maps two fields to `Person` type.
          (field "name" string)  -- Expects an object with field key "name"
          (field "age" int)      -- Expects an object with field key "age"

-}


-- Main ------------------------------------------------------------------------

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- Model -----------------------------------------------------------------------

type Model
  = Failure
  | Loading
  | Success Quote

type alias Quote =
  { quote : String
  , source : String
  , author : String
  , year : Int
  }

init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getRandomQuote)


-- Update ----------------------------------------------------------------------

type Msg
  = MorePlease
  | GotQuote (Result Http.Error Quote)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      MorePlease ->
        (Loading, getRandomQuote)

      GotQuote (Ok quote) ->
        (Success quote, Cmd.none)

      GotQuote (Err _) ->
        (Failure, Cmd.none)


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- View ------------------------------------------------------------------------

-- #1: There are two ways to do this:
--         1. Success quote -> quote.quote, quote.source, ...
--         2. Success {quote, source, ...} -> quote, source, ...

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Random Quotes" ]
    , viewQuote model
    ]

viewQuote : Model -> Html Msg
viewQuote model =
  case model of
      Failure ->
        div []
          [ text "I could not load a random quote for some reason."
          , button [ onClick MorePlease ] [ text "Try Again!" ]
          ]

      Loading ->
        text "Loading ..."

      Success {quote, source, author, year} ->  -- #1
        div []
          [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
          , blockquote [] [ text quote ]
          , p [ style "text-align" "right" ]
              [ text "— "
              , cite [] [ text source ]
              , text (" by " ++ author ++ " (" ++ String.fromInt year ++ ")")
              ]
          ]


-- Http ------------------------------------------------------------------------

getRandomQuote : Cmd Msg
getRandomQuote =
  Http.get
    { url = "https://elm-lang.org/api/random-quotes"
    , expect = Http.expectJson GotQuote quoteDecoder
    }

quoteDecoder : Decoder Quote
quoteDecoder =
  map4 Quote
    (field "quote" string)
    (field "source" string)
    (field "author" string)
    (field "year" int)
