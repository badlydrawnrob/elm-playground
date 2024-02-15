module PhotoGroove exposing (main)

{-|
    Rules:
      Design Guidelines: https://package.elm-lang.org/help/design-guidelines
      Styleguide: https://elm-lang.org/docs/style-guide
      Other styleguides: https://github.com/NoRedInk/elm-style-guide
                         https://gist.github.com/laszlopandy/c3bf56b6f87f71303c9f
                         https://github.com/ohanhi/elm-style-guide

    Be sure to check:
      1. All View functions should be prepended with `view`?
      2. Helper functions seem to ignore this, so ...
      3. Perhaps it's all functions that return `Html` start with `view`?
      4. The `()` type (known as unit) is both a type and a value.
         `function () = ...` only accepts the value `()`.
      5. The type `Program () Model Msg` refers to an Elm Program with no flags,
         whose model type is `Model` and whose message type is `Msg`.

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

    Here's what we're doing in Chapter 04:
      1. Our data model now represents three distinct states:
         Loading, Loaded, and Errored.
      2. We begin in the Loading state, but now we access photos
         or selectedUrl only when in the Loaded state.
        (Because we now store those values in the Loaded variant,
        we’ve guaranteed that we can’t possibly access them in any
        other state.)
      3. When the user clicks the Surprise Me! button, we randomly select
         a photo without creating an intermediate Array (so we got rid of
         the `Array` import).
-}

import Html exposing (..)
import Html.Attributes exposing (class, classList, id, name, title, type_, src)
import Html.Events exposing (onClick)
import Browser
import Random
import Http
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)


-- View ------------------------------------------------------------------------

-- We've broken our `view` into different parts, which follow our `Status` type.
-- This means we can deconstruct our `Model` and give each function only what it
-- requires to work properly.
--
-- : 1) Our main function that takes a `Model`
-- : 2) Our child function that takes only what it needs:
--      `photos`, `selectedUrl`, and a `chosenSize`.
-- : 3) Our other `Status` loading states.
--
-- Also note that (2) returns a `List (Html Msg)` now.

type Msg
  = ClickedPhoto String
  | ClickedSize ThumbnailSize
  | ClickedSurpriseMe
  | GotRandomPhoto Photo
  | GotPhotos (Result Http.Error (List Photo))

view : Model -> Html Msg
view model =
  div [ class "content" ] <|
    case model.status of
      Loaded photos selectedUrl ->
        (viewLoaded photos selectedUrl model.chosenSize)

      Loading ->
        []

      Errored errorMessage ->
        [ text ("Error: " ++ errorMessage) ]

viewLoaded : List Photo -> String -> ThumbnailSize -> List (Html Msg)
viewLoaded photos selectedUrl chosenSize =
    [ h1 [] [ text "Photo Groove" ]
    , button
      [ onClick ClickedSurpriseMe ]
      [ text "Surprise Me!" ]
    , h3 [] [ text "Thumbnail Size:" ]
    , div [ id "choose-size" ]
      (List.map viewSizeChooser [ Small, Medium, Large ] )
    , div [ id "thumbnails", class (sizeToString chosenSize) ]
        (List.map
          (viewThumbnail selectedUrl) photos
        )
    , img
        [ class "large"
        , src (urlPrefix ++ "large/" ++ selectedUrl)
        ] []
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

-- #1: Change model to `Status` (original below)
--     @ http://tinyurl.com/elm-in-action-change-status
--
-- #2: Change `initialModel` to `Loading` (original below)
--     @ http://tinyurl.com/nhddmc8v
--
-- #3  Our type alias `Photo` gives us a constructor function,
--     which allows us to create a `Photo` record like this:
--
--         Photo "http://somewhere.com" 4 "Some where"
--
--     Which means we can hand it over to our Decoder easily!
--
--     : Beware of re-ordering type alias fields! This will re-order
--       it's function's arguments, too.

type ThumbnailSize
  = Small
  | Medium
  | Large

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
  }

initialModel : Model
initialModel =
  { status = Loading  -- #2
  , chosenSize = Medium
  }


-- Update ----------------------------------------------------------------------

-- #1 Instead of updating a `selectedUrl` string (which doesn't exist now),
--    we pass it a function (2). That function takes a `url` (a "string") and a
--    `model.status`.
--
-- #2 a) We `case` on the `Model` again. Why do we do this?
--    b) If there's an `[]` empty list, we basically _do nothing_
--       and return the `model` (and no `Cmd`)
--
-- #3 Here we're using the pipeline operator which both pass `Random.uniform`
--    to the `.generate` function needed, then wrap the whole thing in a
--    `(model, [the randomiser Cmd])` tuple.
--
-- #4 We're no longer expecting a `String` because we're using `expectJson`.
--    this means (thanks to our Decoder) that the return value will be a
--    `List Photo`. We can use _pattern matching_ to split the `List` and
--    pass to `Loaded _ _`. If it's an empty list `[]` then we'll add an
--    Error with a string.

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    GotRandomPhoto photo ->
      ( { model | status = selectUrl photo.url model.status }  -- #1
      , Cmd.none )

    ClickedSize size ->
      ( { model | chosenSize = size }, Cmd.none )

    ClickedPhoto url ->
      ( { model | status = selectUrl url model.status }
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


-- Commands --------------------------------------------------------------------

-- #1  The `list` here is important as `GotPhotos` and `Loaded`
--     expect a `List Photo` data type.

initialCmd : Cmd Msg
initialCmd =
  Http.get
    { url = "http://elm-in-action.com/photos/list.json"
    , expect = Http.expectJson GotPhotos (list photoDecoder)  -- #1
    }

-- Main ------------------------------------------------------------------------

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
