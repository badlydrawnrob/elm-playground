module HowToDecode.BadAPI exposing (..)

{-| ----------------------------------------------------------------------------
    ⚠️ Open Library API example (and an AWFUL API design? 💩)
    ============================================================================
    The goal was to create a very simple form input where the user enters an ISBN
    and we grab the `Book` details from OpenLibrary.org. The user can then add
    this data to their clipboard (with Clipboard.js) and paste it into the form.
    This turned out to be a bit muddled and not particularly user-friendly. It
    requires chaining `HTTP.get` calls, building cover image URLs, and it's all
    a bit too messy and head-banging to get this done.

    Books:
      @ https://openlibrary.org/dev/docs/api/books
      @ https://openlibrary.org/isbn/{ISBN#}.json -- provides author/covers IDs

    Authors:
      @ https://openlibrary.org/dev/docs/api/authors
      @ https://openlibrary.org/authors/{UUID}.json

    Covers:
      @ https://openlibrary.org/dev/docs/api/covers
      @ https://covers.openlibrary.org/b/$key/$value-$size.jpg

    Clipboard:
      @ https://claytonflesher.github.io/2016/11/01/copy-to-clipboard.html
      @ https://clipboardjs.com/
      @ https://stackoverflow.com/a/54915838 BUG FIX: use `ClipboardJS()`

    API examples:
      "title", "authors", "covers", "isbn_13" seem to be always on
      "physical_format" is sometimes unavailable
      @ https://openlibrary.org/isbn/9780241351635.json (12 Rules for Life)
      @ https://openlibrary.org/isbn/9781398519473.json (A Pocketful of Happiness)
      @ https://openlibrary.org/isbn/1853263060.json (The Prince)


    ⚠️ Problems
    ===========
    The API seems awful. These are the kind of icky problems I don't want
    to deal with for prototyping. It's possible to do, but it just causes problems
    along the way, and the code is going to get complex or complected. AVOID!!!

    Poor API design?
    ----------------
    1. Chaining HTTP requests is required, AVOID for now:
        - `/authors/{ID}` requires another `Http.get` request
        - It's a pain in the arse and could lead to complex code
        - See @ https://tinyurl.com/chaining-pokemon-http-requests for ideas,
          but I don't understand the solutions mentioned.
    2. URLS need to be built, rather than a simple image link
        - `covers` require building a Covers API url (see above)
    3. MISSING data, rather than `nullable` entries, such as "authors", "covers",
       and "physical_format" are inconsistant.
        - See here for the argument for and against `null` within your API:
          @ https://softwareengineering.stackexchange.com/q/285010
    4. Is an "ISBN_13" always present, even for old books? I don't know:
        - You'd potentially have to do an `if ... then` to cover books that are
          missing an ISBN number with 13 numbers.
        - In this package it's tough luck if "ISBN_13" is empty.

    Too many Maybes:
    ----------------
    The API design leads requires using A LOT of `Maybe` types with
    `Json.Decode.maybe` as `nullable` won't work with this API. TOO MANY MAYBEs
    make for an uncomfortable design, for instance: having to get the `List.head`
    of an image ID `[8739161]` (resulting in `Maybe Int`).

    * I guess it's a list to allow for multiple cover images?
    * Authors are sometimes assigned and sometimes not?
    * "A Pocketful of Happiness" json file has NO authors in the `json`, but
      viewing the page as normal _displays_ the author, Richard E. Grant.
      What gives? That's weird.

    Messy data:
    -----------
    > Prevents us using simple decoders like `at` due to design.

    It's inconsistant and kind of ugly/messy. It has weird data structures, so we
    can't use `at` and have to resort to a pointless `(list keyDecoder)` decoder
    because the structure looks like:

        "authors" : [ { "key" : "/authors/OL34184A" } ]

    And the ISBN numbers are strings inside a list. Why? Well, perhaps there's
    multiple ISBN numbers for eBook or other formats, but it's an added hassle:

        "ISBN_13" : [ "9780140328721" ]

    Why would you do that? I can't find any book that has any more objects in
    that list format other than that ONE "key" field.

    Potential fixes:
    ---------------
    With (a LOT of?) effort, I suppose you could convert these into nicer types,
    without the wrapping `List`, `"key"`, etc. This is the data structure I
    started with, which is preferable to what I have now:

        Book "" "" "" 0 (Just "Paperback")

    ⭐ It would be SO much easier and pleasant to work with if the `json`
    types started out as easier structures themselves. I'm not an API guru, but
    I can't see a good reason why they've gone for complicated structures in some
    cases. You could probably map them to simpler ones, but not without EFFORT.
    And I'm all for simplicity.

    Redirects:
    ----------
    It redirects `/books/{ISBN}.json` API url to `/books/{UUID}.json` for some
    unknown reason. So GET with Curl requires the `-L` flag to follow the
    redirects (as well as having to chain HTTP requests).

    Luckily Elm's `Json.Decode` package handles this as default.


    Wishlist
    --------
    Rather than a proper `Book`, I tried to SIMPLIFY things by using raw `json`
    data instead of chaining `HTTP.get` requests and building URLs.

    1. GET an ISBN number from OpenLibrary.org
    2. Display the `Book` to the customer: Title, Author, Picture, Binding
    3. "Add to clipboard" with Clipboard.js
    4. Paste into the Tally form.
    5. Repeat if needed for Kids books.
    6. Add in your name and address to the Tally form
    7. SUBMIT.

    Yet even that's STILL problematic and becomes a bit useless to the end-user:
    why on earth would they want to copy/paste data that looks unformated, and
    if I can only reliably grab the `Title` and `ISBN` then WHY EVEN BOTHER?

    And the full search and work/edition API is just as bad. It doesn't list a
    bunch of `Book` objects, but a big long list of `/isbn` numbers, or `/book`
    IDs, which don't seem to have ANY particular order, and you'll find books of
    all different nationalities there to boot. IT'S A HUGE MESS.
-}

import Debug exposing (..)

import Browser exposing (..)
import Json.Decode as D exposing (at, Decoder, field, int, list, maybe, map5, string)
import Html exposing (button, div, Html, p, text)
import Html.Attributes exposing (class, attribute)
import Http exposing (..)


-- Json ------------------------------------------------------------------------

jsonExample =
  """
  {
    "identifiers": {
      "goodreads": [
        "1507552"
      ],
      "librarything": [
        "6446"
      ]
    },
    "title": "Fantastic Mr. Fox",
    "authors": [
      {
        "key": "/authors/OL34184A"
      }
    ],
    "publish_date": "October 1, 1988",
    "publishers": [
      "Puffin"
    ],
    "covers": [8739161],
    "contributions": [
      "Tony Ross (Illustrator)"
    ],
    "languages": [
      {
        "key": "/languages/eng"
      }
    ],
    "source_records": [
      "promise:bwb_daily_pallets_2021-05-13:KP-140-654",
      "ia:fantasticmrfox00dahl_834",
      "marc:marc_openlibraries_sanfranciscopubliclibrary/sfpl_chq_2018_12_24_run02.mrc:85081404:4525",
      "amazon:0140328726",
      "bwb:9780140328721",
      "promise:bwb_daily_pallets_2021-04-19:KP-128-107",
      "promise:bwb_daily_pallets_2020-04-30:O6-BTK-941"
    ],
    "local_id": [
      "urn:bwbsku:KP-140-654",
      "urn:sfpl:31223064402481",
      "urn:sfpl:31223117624784",
      "urn:sfpl:31223113969183",
      "urn:sfpl:31223117624800",
      "urn:sfpl:31223113969225",
      "urn:sfpl:31223106484539",
      "urn:sfpl:31223117624792",
      "urn:sfpl:31223117624818",
      "urn:sfpl:31223117624768",
      "urn:sfpl:31223117624743",
      "urn:sfpl:31223113969209",
      "urn:sfpl:31223117624750",
      "urn:sfpl:31223117624727",
      "urn:sfpl:31223117624776",
      "urn:sfpl:31223117624719",
      "urn:sfpl:31223117624735",
      "urn:sfpl:31223113969241",
      "urn:bwbsku:KP-128-107",
      "urn:bwbsku:O6-BTK-941"
    ],
    "type": {
      "key": "/type/edition"
    },
    "first_sentence": {
      "type": "/type/text",
      "value": "Down in the valley there were three farms."
    },
    "key": "/books/OL7353617M",
    "number_of_pages": 96,
    "works": [
      {
        "key": "/works/OL45804W"
      }
    ],
    "classifications": {

    },
    "ocaid": "fantasticmrfoxpu00roal",
    "isbn_10": [
      "0140328726"
    ],
    "isbn_13": [
      "9780140328721"
    ],
    "latest_revision": 26,
    "revision": 26,
    "created": {
      "type": "/type/datetime",
      "value": "2008-04-29T13:35:46.876380"
    },
    "last_modified": {
      "type": "/type/datetime",
      "value": "2023-09-05T03:42:15.650938"
    }
  }
  """

-- Model -----------------------------------------------------------------------
-- 1: `nullable` won't work here as in some API calls it doesn't exist. @Simon Lydell
--    discourages using `Json.Decode.maybe` as `nullable` is a safer all-rounder.

type alias Book =
  { title : String
  , authors : Maybe (List String)
  , covers : Maybe (List Int)
  , isbn : List String
  , binding : Maybe String
  }

decodeBook : Decoder Book
decodeBook =
  D.map5 Book
    (field "title" string)
    (maybe (field "authors" decodeAuthors)) -- "A Pocketful of happiness" has no authors
    (maybe (field "covers" (list int))) -- "A Pocketful of happiness" has no covers
    (field "isbn_13" (list string)) -- "The Prince" was given isbn_10 but also has isbn_13
    (maybe (field "physical_format" string)) -- #1

decodeAuthors : Decoder (List String)
decodeAuthors =
  (list (field "key" string))

type alias Model =
  { book : Book
  , error : String
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( { book = Book "" (Just [""]) (Just [0]) [""] Nothing, error = "" }
  , Http.get
      { url = "https://openlibrary.org/isbn/9780241351635.json"
      , expect = Http.expectJson GotJson decodeBook
      }
  )


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  div []
    [ viewBook model.book
    , button [ class "copy-button", attribute "data-clipboard-target" ".copy-me" ]
        [ text "Copy the API text" ]
    ]

viewBook : Book -> Html msg
viewBook { title, authors, covers, isbn, binding } =
  p [ class "copy-me" ]
    [  text <| String.concat
            <| List.intersperse " - "
                [ title
                , viewAuthor authors -- This is a Maybe
                , (viewCover covers)           -- This is a Maybe
                , Maybe.withDefault "" (List.head isbn)
                , Maybe.withDefault "" binding -- And THIS is a fucking Maybe
                ]
    ]

viewAuthor : Maybe (List String) -> String
viewAuthor authors =
  case authors of
    Nothing ->
      ""
    Just list ->
      Maybe.withDefault "" (List.head list)

viewCover : Maybe (List Int) -> String
viewCover covers =
  case covers of
    Nothing ->
      ""
    Just list ->
      String.fromInt (Maybe.withDefault 0 (List.head list))


-- Update ----------------------------------------------------------------------

type Msg
  = GotJson (Result Http.Error Book)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "message" msg of
      GotJson (Ok str) ->
        ( { model | book = str }
        , Cmd.none
        )

      GotJson (Err _) ->
        ( { model | error = "There was an error" }
        , Cmd.none
        )


-- Main ------------------------------------------------------------------------

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
