port module PhotoGroove exposing (main)

{-|
    Rules:
      Design Guidelines: https://package.elm-lang.org/help/design-guidelines
      Styleguide: https://elm-lang.org/docs/style-guide
      Other styleguides: https://github.com/NoRedInk/elm-style-guide
                         https://gist.github.com/laszlopandy/c3bf56b6f87f71303c9f
                         https://github.com/ohanhi/elm-style-guide

    Be sure to check:
      1. Hard reload the page (or clear history)
          - Sometimes the `index.html` gets "stuck" in old version.
          - @ http://tinyurl.com/safari-hard-refresh
      2. Ellie App requires `https` (or it won't load `json`)
      3. Prepended view functions with `view`
          - No need to do this with helper functions.
          - All functions that return `Html Msg` do need this.

    Earlier versions:
      1. Chapter 02:
            @ http://tinyurl.com/elm-in-action-chapter-02-done
            @ http://tinyurl.com/elm-in-action-c02-full-notes
      2. Two variations of `case`:
            Update with `if`: http://tinyurl.com/elm-in-action-update-if
            Update with `case`: http://tinyurl.com/elm-in-action-update-case
      4. Chapter 03:
            @ http://tinyurl.com/elm-in-action-chapter-03-done
            @ http://tinyurl.com/elm-in-action-c03-full-notes
      5. Chapter 04:
            @ http://tinyurl.com/elm-in-action-c04-full-notes

    Here's what we're doing in Chapter 05:
      1. Rendering custom elements
      2. Sending data to JavaScript
      3. Receiving data from JavaScript
      4. Initializing our Elm application by using data
         from JavaScript
-}

import Html exposing (..)
import Html.Attributes as Attr exposing (class, classList, id, name, src, title, type_)
import Html.Events exposing (on, onClick)
import Browser
import Json.Encode as Encode
import Random
import Http
import Json.Decode exposing (Decoder, at, string, int, list, succeed)
import Json.Decode.Pipeline exposing (optional, required)


-- View ------------------------------------------------------------------------

-- #1  a) Displays the filters name
--     b) <range-slider> that goes from 0 to 11
--     c) Sets the slider's val to the current magnitude
--     d) Displays the current magnitude
--     e) We'll need to pass a `Msg` to `onSlide` depending on slider
--
-- #2  It’s generally a good idea to keep our types as narrow as possible,
--     so we’d like to avoid passing `viewLoaded` the entire `Model` if we can.
--     However, that’s not a refactor we need to do right now.

type Msg
  = ClickedPhoto String
  | ClickedSize ThumbnailSize
  | ClickedSurpriseMe
  | GotRandomPhoto Photo
  | GotPhotos (Result Http.Error (List Photo))
  | SlidHue Int
  | SlidRipple Int
  | SlidNoise Int

view : Model -> Html Msg
view model =
  div [ class "content" ] <|
    case model.status of
      Loaded photos selectedUrl ->
        (viewLoaded photos selectedUrl model)  -- #2

      Loading ->
        []

      Errored errorMessage ->
        [ text ("Error: " ++ errorMessage) ]

viewFilter : (Int -> Msg) -> String -> Int -> Html Msg
viewFilter toMsg name magnitude =
  div [ class "filter-slider" ]
      [ label [] [ text name ]  -- #1a
      , rangeSlider   -- #1b
          [ Attr.max "11"  -- #1b
          , Attr.property "val" (Encode.int magnitude)  -- #1c
          , onSlide toMsg  -- #1e
          ]
          []
      , label [] [ text (String.fromInt magnitude) ]  -- #1d
      ]

viewLoaded : List Photo -> String -> Model -> List (Html Msg)
viewLoaded photos selectedUrl model =
    [ h1 [] [ text "Photo Groove" ]
    , button
      [ onClick ClickedSurpriseMe ]
      [ text "Surprise Me!" ]
    , div [ class "filters" ]
      [ viewFilter SlidHue "Hue" model.hue
      , viewFilter SlidRipple "Ripple" model.ripple
      , viewFilter SlidNoise "Noise" model.noise
      ]
    , h3 [] [ text "Thumbnail Size:" ]
    , div [ id "choose-size" ]
      (List.map viewSizeChooser [ Small, Medium, Large ] )
    , div [ id "thumbnails", class (sizeToString model.chosenSize) ]
        (List.map
          (viewThumbnail selectedUrl) photos
        )
    , canvas [ id "main-canvas", class "large" ] []
    ]


-- Helper functions --

urlPrefix : String
urlPrefix =
  "http://elm-in-action.com/"

viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , title (thumb.title ++ " [" ++ String.fromInt thumb.size ++" KB]")
      , classList [ ( "selected", selectedUrl == thumb.url ) ]
      , onClick (ClickedPhoto thumb.url)
      ] []

viewSizeChooser : ThumbnailSize -> Html Msg  -- #3
viewSizeChooser size =
  span [] [
    label []
    [ input [
        type_ "radio", name "size", onClick (ClickedSize size)
      ] []
    , text (sizeToString size)
    ]
  ]

sizeToString : ThumbnailSize -> String
sizeToString size =
  case size of
      Small -> "small"
      Medium -> "med"
      Large -> "large"


-- Model -----------------------------------------------------------------------

-- Our model holds a `Status` which can only ever be in one of
-- three states. Ideally, we want it to be in a `Loaded` state.
-- We're using a Decoder with a `Http.get` which should return a
-- `List Photo`.

type ThumbnailSize
  = Small
  | Medium
  | Large

port setFilters : FilterOptions -> Cmd msg

type alias FilterOptions =
  { url : String
  , filters : List { name : String, amount : Int }
  }

type alias Photo =
  { url : String
  , size : Int
  , title : String }

photoDecoder : Decoder Photo
photoDecoder =
  succeed Photo  -- #3
    |> required "url" string
    |> required "size" int
    |> optional "title" string "(untitled)"

type Status
  = Loading
  | Loaded (List Photo) String
  | Errored String

type alias Model =
  { status : Status  -- #1
  , chosenSize : ThumbnailSize
  , hue : Int
  , ripple : Int
  , noise : Int
  }

initialModel : Model
initialModel =
  { status = Loading  -- #2
  , chosenSize = Medium
  , hue = 5
  , ripple = 5
  , noise = 5
  }


-- Update ----------------------------------------------------------------------

-- We have three main `onClick` states. We have to make sure we case on
-- `[]` empty, a full `List Photo`, and `Http.Error`s using `Err`.
-- We're using the `|>` pipeline operator which I need to understand better.
-- Our `Http.get` automatically converts the `Decoder` into a `List Photo`
-- and we can put our `model.status` in one of our `Status` states.

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    GotRandomPhoto photo ->
      ( applyFilters { model | status = selectUrl photo.url model.status }  -- #1
      , Cmd.none )

    ClickedSize size ->
      ( { model | chosenSize = size }, Cmd.none )

    ClickedPhoto url ->
      ( applyFilters { model | status = selectUrl url model.status }
      , Cmd.none )

    ClickedSurpriseMe ->
      case model.status of  -- #2a
        Loaded [] _ ->
          ( model, Cmd.none )  -- #2b
        Loaded (firstPhoto :: otherPhotos) _ ->
          ( Random.uniform firstPhoto otherPhotos
              |> Random.generate GotRandomPhoto
              |> Tuple.pair model  -- #3
          )
        Loading ->
          ( model, Cmd.none )
        Errored errorMessage ->
          ( model, Cmd.none )

    GotPhotos (Ok photos) ->  -- #4
      case photos of
        (first :: rest) ->
          ( { model | status = Loaded photos first.url }, Cmd.none )
        [] ->
          ( { model | status = Errored "O photos found" }, Cmd.none )

    GotPhotos (Err _) ->
      ( { model | status = Errored "Server error!" }, Cmd.none )

    SlidHue hue ->
      ( { model | hue = hue }, Cmd.none )
    SlidRipple ripple ->
      ( { model | ripple = ripple }, Cmd.none )
    SlidNoise noise ->
      ( { model | noise = noise }, Cmd.none )


-- #: helper function --

selectUrl : String -> Status -> Status
selectUrl url status =
  case status of
      Loaded photos _ ->
        Loaded photos url
      Loading ->
        status
      Errored errorMessage ->
        status

applyFilters : Model -> ( Model, Cmd Msg )
applyFilters model =
  case model.status of
      Loaded photos selectedUrl ->
        let
          filters =
            [ { name = "Hue", amount = model.hue }
            , { name = "Ripple", amount = model.ripple }
            , { name = "Noise", amount = model.noise }
            ]
          url =
            urlPrefix ++ "large/" ++ selectedUrl
        in
        ( model, setFilters { url = url, filters = filters } )
      Loading ->
        ( model, Cmd.none )
      Errored errorMessage ->
        ( model, Cmd.none )

-- Commands --------------------------------------------------------------------

-- The `list` here is important as `GotPhotos` and `Loaded`
-- expect a `List Photo` data type.

initialCmd : Cmd Msg
initialCmd =
  Http.get
    { url = "http://elm-in-action.com/photos/list.json"
    , expect = Http.expectJson GotPhotos (list photoDecoder)
    }

-- Main ------------------------------------------------------------------------

-- The `()` type (known as unit) is both a type and a value.
-- The type `Program () Model Msg` refers to an Elm Program with no flags,
-- whose model type is `Model` and whose message type is `Msg`.
--
-- #1 Unused `flags` anon func (for init)
-- #2 Unused `model` anon func (for subscriptions)

main : Program () Model Msg
main =
  Browser.element
    { init = \_ -> ( initialModel, initialCmd )  -- #1
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none  -- #2
    }


-- Custom elements -------------------------------------------------------------

-- Together with our JavaScript in `index.html` we're creating
-- a custom element to manipulate our images.
--
-- #1  Decodes the integer located at `event.detail.userSlidTo`
-- #2  Converts that integer to a message using toMsg
--     - `toMsg` needs to be flexible as we have 3 sliders
--        so we'll need 3 unique messages.
-- #3  Creates a custom event handler using that decoder

rangeSlider : List (Attribute msg) -> List (Html msg) -> Html msg
rangeSlider attributes children =
  node "range-slider" attributes children

onSlide : (Int -> msg) -> Attribute msg
onSlide toMsg =
  at [ "detail", "userSlidTo" ] int  -- #1
    |> Json.Decode.map toMsg  -- #2
    |> on "slide"  -- #3
