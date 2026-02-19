module File.ImageForm exposing (..)

{-| ----------------------------------------------------------------------------
    Image POST `--form` to server: `base64` with MultiPart
    ============================================================================
    ✏️ Improve the documentation of this file and it's example.

    Poor UI and low-data are the fundamental things to improve, so focus on those
    things first! Early prototypes can use Tally forms for paper prototyping the
    `upload->convert->display` interface, and help shore up architecture and design
    routes.

    Remember, you've got to HOST these images; uploading is a small part! See
    `src/ImageServer` for reliable image servers.  I tried and failed to get
    @ http://freeimage.host working, so @ https://imgbb.com is fine for now.


    Learning
    --------
    > ⚠️ How is the user experience of uploading from an iPhone?

    1. Try to avoid naming clashes with other Elm packages
    2. Avoid large files and error check for a file size limit
    3. Have a `LoadingSlowly` status for files `200kb`-`500kb`
    4. Version your Javascript files to avoid Elm caching old versions


    What is `base64`?
    ----------------
    > @ https://tinyurl.com/simplest-way-to-upload-img
    > @ https://github.com/badlydrawnrob/elm-playground/issues/43

    Also see `elm/file` package and Elm guid for examples.
    Server must accept `base64` POST in the URL and allow CORS.


    Sentence method
    ---------------
    > Paper prototype your UI and shape your bet. Fat marker.

    1. Upload file with allowed `MIME` type(s)
    2. Convert the file with `File.toUrl` function
    3. Strip the metadata from `data:[<mediatype>][;base64],`
    4. Store it either individually or as `List String`
    5. Send to the server individually or as a group
        - POST `--form` with `onClick` message
        - URL encode `<data-string>`if needed with `Http.stringPart`
    6. Server should respond with our `Just url` which ...
        - We can use naked value and not unpack `Maybe` twice!
        - We can guarantee that it's not `Nothing` at this point


    Tooling
    -------
    > Apart from Tally forms you can make use of ...

    @ https://www.base64-image.de/ (image->base64)
    @ https://base64.guru/converter/decode/image (base64->image)
    @ https://www.browserling.com/tools/strip-slashes (strips slashes json url)

    > 1. Convert to base64
    > 2. Copy from clipboard | convert to file format

    ```terminal
    base64 image.jpg > base64.txt
    pbpaste | base64 -d > image.jpg
    ```


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    > ⚠️ Documentation and examples could be improved. Consider low-data 4g solutions
    > like lazy-loading, 1x/2x/3x resolutions, multiple images, and so on.

    1. Could we handle the `ImageUrl` and view model better?
        - Is a `Maybe` type essential? (Or use `Maybe.map` in view)
        - Could our data structures and flow be improved?
    2. `ImageForm` component that can be run multiple times (at least 3 img)
        - @ https://elm-lang.org/examples/upload (multiple files)
        - `Task.sequence` may help to stack up the calls, if `Task` is successful,
          user sees "Image Ready".
        - Some kind of spinner would be required when uploading/sending
        - How would the form need to look? `List String`?
        - I think `.multipartBody` can send multiple files
    3. Max file size and number of images will be necessary
        - Check each file image size and error if too large
        - Limits on number of images able to upload to server
        - Error handling for failed uploads
    4. Test a decent image server that allows for different resolutions
        - And manipulating the images (direct upload from iPhone too large)
        - Can the image be directly got and displayed? (It'll just be a URL)
    5. Unit tests ...
        - does `Msg` always receive a `Base64` string?
    6. Try and prettify the code and HTML
        - It looks like boilerplate right now

    Questions
    ---------
    1. Why can `Task.perform` NEVER fail?

-}

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, p, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http exposing (..)
import File.ImageServer as Server
import Json.Decode as D exposing (decodeString, Decoder)
import Task
import Url.Builder as UB


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

type alias ImageSize
    = String

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

{-| ImgBB expects a `--form` POST request.

> We pass in a `base64` file string (not the file)

Other servers can use a simple `Http.post` with a `url` and `Http.emptyBody`.
Some servers can use `Http.request` and `Http.fileBody` for the file itself. Either
way the `<data-string>` should be URL % encoded.

You can send multiple files with `Http.multipartBody` (see docs)  -}
postImage : String -> Server.ApiKey -> Base64 -> Cmd Msg
postImage expiration (Server.ApiKey str) file =
    Http.request
        { method = "POST"
        , headers = []
        , url = buildUrl expiration str
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
            -- ⚠️ Strips the metadata from `Base64` string. Is it important?

            -- 1. Convert uploaded image to a `base64` string with `File.toUrl`
            -- 2. Some APIs don't like the `data:` metadata prefix. Strip it
            -- 3. Split at the `,` then drop the metadata part
            chopBase64 = String.join "" (List.drop 1 (String.split "," base64))
        in
        ( { model | image = Just chopBase64 }
        , Cmd.none
        )

    {- #! We KNOW that `model.image` is not `Nothing` at this point. No need
    for another "lifting" of the `Maybe` type. Just send it along! -}
    SendToServer base64 ->
        ( model
        , postImage "600" (Server.ApiKey "104e88f54082d98be7ac1d3649ba21d1") base64 )

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

        {- #! Here it'd be helpful to use an existing URL for the image, too -}
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
