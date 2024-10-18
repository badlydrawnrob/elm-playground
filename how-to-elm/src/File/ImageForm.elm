module File.ImageForm exposing (..)

{-| ----------------------------------------------------------------------------
    Image POST `--form` to server: `base64` with MultiPart
    ============================================================================
    ⚠️ Try to avoid naming clashes with elm packages.
    ⚠️ Avoid large files. Read notes on `data:` urls.
    ⚠️ Version `js` and `css` files to force reloading when upgrading app.
    You can allow multiple image types (MIME) in `File.toUrl` as a list.

    See @ issue #43 for detailed notes on `base64` (and CORS errors).
    See @ https://tinyurl.com/simplest-way-to-upload-img for help.
    See `elm/file` package for example csv upload program.

    Technical tasks
    ---------------
    This module is the correct way to do things for a server that accepts
    `base64` POST in the URL. Currently looking for a server that allows CORS.

    1. Upload a file (based on allowed `MIME` types)
    2. Convert `file` to `File.toUrl`.
    3. Strip the `data:[<mediatype>][;base64],` part.
    4. Store it in the `Model`.
    5. `Http.stringPart` handles any URL encoding (if any?) for `<data-string>`
    6. Send to server with POST (`--form`) with `onClick` message
        - At this point we can pass along our `Just url` so we don't need to
          unpack the `Maybe`. We know it's NOT `Nothing`.
    7. LARGE FILES are OK, but should be AVOIDED (it's slow and `curl` is also)
        - Anything over `200kb-500kb` should have a "LOADING" status for UI
    8. Collect the image url from the server response ...

    Handy tools:
    ------------

    1. Encode an image as `base64` string
        @ https://www.base64-image.de/
        `base64 image.jpg > base64.txt` with terminal
    2. Decode an image from `base64` string
        @ https://base64.guru/converter/decode/image
        `pbpaste | base64 -d > image.jpg` with terminal
        (copy from clipboard)  (file format)
    3. Strip slashes from `json` `"url"` value:
        @ https://www.browserling.com/tools/strip-slashes


    ----------------------------------------------------------------------------
    The UI and customer journey ...
    ----------------------------------------------------------------------------
    ⚠️ Some file names (such as a large `.gif` don't show their `<data-string>`
    for some reason — perhaps they're too long? It is there however, if you use
    "inspect element".

    How it should look to the visitor in future ...
    -----------------------------------------------
    1. Click a button (and select an acceptable image file)
    2. -- Select multiple images? --
    3. Upload the file(s)
        - The `<data-string>` shouldn't be shown to the user, only filename/size.
    4. "Send to server" button is now visible
        -- Could this be automatic? --
    5. User clicks button and all files are uploaded

    Technical considerations
    ------------------------
    You could either have a "upload files" button with a `List File`, or have the
    user go through the process as many times as they need. The former option is
    likely the best user-experience.


    - User still needs to continue with the "main" form to attach the image url's
      to the main body of the form (POST Json)

    Questions
    ---------
    1. Our `Task.perform` can NEVER fail. Why?
        - `Never` means just that. It can never fail?
    2. We don't want to unpack `Maybe` more than ONCE:
        - Rather than "lift" the `Maybe`, send it along in the `Msg`.
        - We know it's not `Nothing` so this should be safe.


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    1. Convert into a component, that can be run multiple times (at least 3 img)
        - @ https://elm-lang.org/examples/upload (multiple files)
        - `Task.sequence` may help to stack up the calls
        - Some kind of spinner would be required when uploading/sending
        - A limit will be necessary (check each file image size -> ERROR?)
            - Max file size / Max images (3?)
    2. Use `ImageForm` module within another main form (attaching the URLs)
        - POST the form as `Json` and retrieve it in the view (demo)
    2. BASIC UNIT TESTS!! There was one instance where I didn't export
       `Base64` type (`String` that `Msg` consumed) in my `Model` module and the
       compiler DID NOT CATCH IT.
    4. How can `Html` be tidied up so it doesn't look like Boilerplate? Ugly.
    5. Should we hold on to the `data: ...` meta? It could be useful.
    7. Could we handle the `imageUrl` in the model a bit better?
        - Right now we're chaining `case` statements for our possible image
          states. Could we improve the STRUCTURE OF OUR VIEW?

-}

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, p, strong, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as D exposing (at, decodeString, Decoder, Error, string)
import Task
import Url.Builder as UB exposing (crossOrigin, string)
-- import Debug exposing (..)


-- Model -----------------------------------------------------------------------

type ImageUrl
    = ImageNotAskedFor
    | Image (Result Http.Error String)

type alias Base64 =
    String

type Msg
  = ImageRequested
  | ImageSelected File
  | ImageLoaded String
  | SendToServer Base64
  | SentImage (Result Http.Error String)

type alias Model =
  { image : Maybe String
  , imageName : String
  , imageUrl : ImageUrl
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model Nothing "" ImageNotAskedFor, Cmd.none )



-- Image Server ----------------------------------------------------------------
-- If your image server is on the SAME domain, or it allows CORS on a different
-- domain, you can use this ...

serverUrl : String
serverUrl =
    "https://api.imgbb.com"  -- Trailing slash `/` is not required

{- #! How do you map this to a `type alias` that's also a `String`? -}
decodeImage : Decoder String
decodeImage =
    (D.at ["data", "image", "url"] D.string)

{- Helpful for testing in `elm repl` -}
grabImage : String -> Result D.Error String
grabImage json =
    decodeString decodeImage json

{- This helps us percent encode our `<data-string>` (file) -}
buildUrl : String -> String -> String
buildUrl expiration key =
    UB.crossOrigin
        serverUrl
        [ "1", "upload" ]
        [ UB.string "expiration" expiration
        , UB.string "key" key
        ]

{- Instead of a simple `Http.post`, we've got to use `request` as ImgBB expects
a `--form` POST request. We pass in a `base64` file string (not the file) -}
postImage : String -> String -> Base64 -> Cmd Msg
postImage expiration key file =
    Http.request
        { method = "POST"
        , headers = []
        , url = buildUrl expiration key
        , body =
            Http.multipartBody
                [ Http.stringPart "image" file ]
        , expect = Http.expectJson SentImage decodeImage
        , timeout = Nothing
        , tracker = Nothing
        }




-- Main ------------------------------------------------------------------------


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- Update ----------------------------------------------------------------------

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ImageRequested ->
        ( model
        , Select.file ["image/jpg", "image/png", "image/gif"] ImageSelected
        )

    {- We need to do a few things to our `base64` string, but `Task` expects
    a `Never` type, which only `File.toUrl` can give us ... -}
    ImageSelected file ->
        -- Collect the file name to preview for our visitor!
        ( { model | imageName = (File.name file) }
        -- Convert file to a `base64` string (with metadata)
        , Task.perform ImageLoaded (File.toUrl file)
        )

    ImageLoaded base64 ->
        let
        {- Now strip the metadata from the `base64` string:
        1. Convert uploaded image to a `base64` string with `File.toUrl`
        2. APIs like @ http://freeimage.host` don't like the `data:` meta ...
           so we've got to strip it from the string.
        3. First we split at the `,` then drop the metadata part -}
            chopBase64 = String.join "" (List.drop 1 (String.split "," base64))
        in
        ( { model | image = Just chopBase64 }
        , Cmd.none
        )

    {- #! We KNOW that `model.image` is not `Nothing` at this point. No need
    for another "lifting" of the `Maybe` type. Just send it along! -}
    SendToServer base64 ->
        ( model
        , postImage "600" "104e88f54082d98be7ac1d3649ba21d1" base64 )

    {- #! See the custom type for `imageUrl` -}
    SentImage payload ->
        ( { model | imageUrl = Image payload }
        , Cmd.none
        )



-- View ------------------------------------------------------------------------


view : Model -> Html Msg
view model =
  case model.imageUrl of
    ImageNotAskedFor ->
        viewUploaded model

    Image (Ok url) ->
        div [ class "wrapper" ]
            [ p [] [ text ("image: " ++ url ++ " is ready to add to the form!") ] ]


    Image (Err error) ->
        case error of
            BadUrl str ->
                p [] [ text str ]

            Timeout ->
                p [] [ text "Oops! There's been a TIMEOUT. Start again?" ]

            NetworkError ->
                p [] [ text "Oops! There's been a NETWORK ERROR. Start again?" ]

            BadStatus num ->
                p [] [ text ("Oops! There's been a" ++ (String.fromInt num) ++ ". Start again?") ]

            BadBody str ->
                p [] [ text str ]

viewUploaded : Model -> Html Msg
viewUploaded model =
    case model.image of
        Nothing ->
            button [ onClick ImageRequested ] [ text "Load Image" ]

        Just url ->
            div [ class "wrapper" ]
                [ p [] [ strong [] [ text ("filename: " ++ model.imageName) ] ]
                , p [] [ strong [] [ text " / url: "], text url ]
                , button [ onClick (SendToServer url) ]
                    [ text "Upload Image to Server!"]
                ]



-- Subscriptions ---------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
