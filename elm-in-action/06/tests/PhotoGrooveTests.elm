module PhotoGrooveTests exposing (..)

import Expect exposing (Expectation)
import Json.Decode as Decode exposing (decodeString, decodeValue)
import Json.Encode as Encode
import Html.Attributes as Attr exposing (src)
import PhotoGroove exposing (Status(..),  Msg(..), Photo, urlPrefix, view, main, photoDecoder, initialModel)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag, attribute)
import Test.Html.Event as Event


-- A simple unit test with a Json string ---------------------------------------

decoderTest : Test
decoderTest =
    test "title defaults to (untitled)" <| -- test description (pipe test to this function)
      \_ ->                                -- anon func wrapper
        """{"url": "fruits.com", "size": 5}"""   -- Json triple quote!
          |> decodeString PhotoGroove.photoDecoder  -- Our `photoDecoder` has optional `title` field
          |> Result.map .title             -- map the title from the decoder
          |> Expect.equal                                      -- Expect the below (Ok value)
            (Ok "(untitled)")  -- decoding the json


-- Building our Json programatically -------------------------------------------

-- #1: We're now building our Json programatically but with hardcoded values,
--     e.g: "fruits.com". We want randomly generated `String` and `Int` values
--
-- #2: Here we've setup a fuzz test. Elm will run this function 100 times,
--     each time randomly generating a fresh `String` value and passing it
--     in as `url`, and a fresh `Int` value and passing it in as `size`.
--
--     We can now have considerably more confidence that any JSON string
--     containing only properly set "url" and "size" fields—but no
--     "title" field—will result in a photo whose title defaults to "(untitled)".

decoderValueTest : Test
decoderValueTest =
  test "title defaults to (untitled) using Value instead of String" <|
    \_ ->
      [ ( "url", Encode.string "fruits.com" )
      , ( "size", Encode.int 5 )
      ]
        |> Encode.object
        |> decodeValue PhotoGroove.photoDecoder  -- Calling decodeValue instead of decodeString
        |> Result.map .title
        |> Expect.equal (Ok "(untitled)")

decoderValueFuzzTest : Test
decoderValueFuzzTest =
  fuzz2 string int "title defaults to (untitled) using Value with Fuzz testing" <|
    \url size ->
      [ ( "url", Encode.string url )
      , ( "size", Encode.int size )
      ]
        |> Encode.object
        |> decodeValue PhotoGroove.photoDecoder  -- Calling decodeValue instead of decodeString
        |> Result.map .title
        |> Expect.equal (Ok "(untitled)")


-- Testing the view ------------------------------------------------------------

noPhotosNoThumbnails : Test
noPhotosNoThumbnails =
  test "Not thumbnails render when there are no photos to render" <|
    \_ ->
      initialModel
        |> PhotoGroove.view
        |> Query.fromHtml
        |> Query.findAll [ tag "img" ]
        |> Query.count (Expect.equal 0)


-- Getting more complicated --

thumbnailRendered : String -> Query.Single msg -> Expectation
thumbnailRendered url query =
  query
    |> Query.findAll [ tag "img", attribute (Attr.src (urlPrefix ++ url)) ]
    |> Query.count (Expect.atLeast 1)

photoFromUrl : String -> Photo
photoFromUrl url =
  { url = url, size = 0, title = "" }

thumbnailsWork : Test
thumbnailsWork =
  fuzz (Fuzz.intRange 1 5) "URLs render as thumbnails" <|
    \urlCount ->
      let
        urls : List String
        urls =
          List.range 1 urlCount
            |> List.map (\num -> String.fromInt num ++ ".png")

        thumbnailChecks : List (Query.Single msg -> Expectation)
        thumbnailChecks =
          List.map thumbnailRendered urls
      in
        { initialModel | status = Loaded (List.map photoFromUrl urls) "" }

          |> view
          |> Query.fromHtml
          |> Expect.all thumbnailChecks


-- The final thumbnail test ----------------------------------------------------

-- Clicking on a thumbnail, does it render
-- a thumnail as large?

urlFuzzer : Fuzzer (List String)
urlFuzzer =
  Fuzz.intRange 1 5
    |> Fuzz.map urlsFromCount

urlsFromCount : Int -> List String
urlsFromCount urlCount =
  List.range 1 urlCount
    |> List.map (\num -> String.fromInt num ++ ".png")

thumbnailsWorkTwo : Test
thumbnailsWorkTwo =
  fuzz urlFuzzer "URLs render as thumbnails 2nd version" <|
    \urls ->
      let
        thumbnailChecks : List (Query.Single msg -> Expectation)
        thumbnailChecks =
          List.map thumbnailRendered urls
      in
        { initialModel | status = Loaded (List.map photoFromUrl urls) "" }

          |> view
          |> Query.fromHtml
          |> Expect.all thumbnailChecks

clickThumbnail : Test
clickThumbnail =
  fuzz3 urlFuzzer string urlFuzzer "clicking a thumbnail selects it" <|
    \urlsBefore urlToSelect urlsAfter ->
      let
        url =
          urlToSelect ++ ".jpeg"

        photos =
          (urlsBefore ++ url :: urlsAfter)
            |> List.map photoFromUrl

        srcToClick =
          urlPrefix ++ url

      in
        { initialModel | status = Loaded photos "" }
          |> view
          |> Query.fromHtml
          |> Query.find [ tag "img", attribute (Attr.src srcToClick) ]
          |> Event.simulate Event.click  -- Simulates clicking image
          |> Event.expect (ClickedPhoto url)
