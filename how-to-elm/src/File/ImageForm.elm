module File.ImageForm exposing (..)

{-| ----------------------------------------------------------------------------
    Image file upload
    ============================================================================
    > Uses a `base64` string to upload form data

    ⚠️ Security: browser only allows `File.select` with user action.

    Currently selects a single image. The method I've used is `Select.file` which
    is a `Cmd` that opens the file explorer and allows the user to select a file.
    This could be added to a `List Url` for multiple images.

    One of the examples of where Elm is great for low dependencies, but not so hot
    for developer convenience. With a javascript library you would avoid having to
    research low-level detail like base64 encoding!


    Multiple images (alternative)
    -----------------------------
    > An Elm example uses `multiple True` for file input

    This stores files in array `event.target.files`, decoded into `List File`. Has
    the downside of refreshing the list every time the upload button is clicked.

        @ https://web.dev/articles/read-files
        @ https://elm-lang.org/examples/upload


    Previous version with `File`
    ----------------------------
    > You can't extract the name from Base64 string.

    Previous version handled `File.url` and `File.name` directly in the update
    function. Having showed it to other Elmers nobody said it was incorrect
    other than lifting the `base64` value once. The `Model` was not the best
    setup I think:

        ```
        ImageUrl = ImageNotAskedFor | Image (Result Http.Error String)

        type alias Model =
            { image : Maybe String
            , imageName : String
            , imageUrl : ImageUrl
            }
        ```

    For the following reasons ...

        (a) Don't store computed values in the model! (`Result`)
        (b) It's possibly better storing `File` directly in the model
        (c) As there's only a single image `Maybe File` is easier
        (d) `Url` as a separate (simple) field


    ⚠️ Impossible states
    --------------------
    > Have we handled impossible states correctly?

    If we changed our `Msg` order, view or other parts of our program would the
    impossible state be 100% handled correctly? The `Url` custom type could probably
    be tightended up a little:

        (a) `Base64` is an empty string (no file yet) ⚠️
        (b) `Base64` is only created from `File`
        (c) `Loaded` is only created from server response

    We've also got `NoImage` state when the user has not yet selected a file. Are
    there any ways our program could end up in an impossible state? Unfortunately
    `File.toUrl` is a `Task` that needs to be performed (creating an extra `Msg`).

    We must have the ability to retrieve info about the file, so we store it as
    a seperate entry on `Model`. We could clear this after send to server.

        States: no image, file, base64, image url


    Prototyping
    -----------
    > Paper prototype your UI and shape your bet. Fat marker.

    You've still got to handle the image compression etc! It might be easier
    while prototyping to use a 3rd-party service, or Tally forms and handle the
    conversions offline. Hosting and processing is the hard part!


    The API
    -------
    > @ https://api.imgbb.com/ is used. I've tried `freeimage.host` but couldn't
    > get it to work reliably. See `ImageServer` for other services.

    ```
    curl -X POST "https://api.imgbb.com/1/upload?expiration=600&key=<API_KEY>" \
    -H "accept: application/json" \
    -H "content-type: multipart/form-data" \
    -F "image=@/path/to/image.jpg;type=image/jpeg"
    ```


    Sentence method
    ---------------
    > Upload -> Convert -> Display

    What does the customer journey look like? Can it be simplified?

    1. Button launches file explorer
    2. Add single file with allowed MIME type(s)
    3. Store the individual `File` to retrieve information about it
        - For multiple images store as `List File`?
    4. `File.toUrl` -> `Base64 String` with metadata
    5. Strip metadata `data:[<mediatype>][;base64],` at comma
        - Some servers may accept the metadata but ImgBB does not
    6. Send `Base64 String` to the server
        - You may need to use `--form` and url encoded `Base64 String`
    7. Store server response as url and preview image


    What is `base64`?
    ----------------
    > @ https://tinyurl.com/simplest-way-to-upload-img
    > @ https://github.com/badlydrawnrob/elm-playground/issues/43

    Also see `elm/file` package and Elm guid for examples.
    Server must accept `base64` POST in the URL and allow CORS.


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
    > Currently does not consider any lazy-loading previews, conversion to
    > different resolutions, or other optimizations.

    1. Is the `Url` impossible state correct?
        - We create `Base64` from `File`
        - We create `Loaded` from server response
    2. Is there a way to remove the need for `Maybe` types?
        - Or use `Maybe.map` in the view to avoid "lifting"?
    3. What ways can we add multiple file upload?
        - Ideally in a way that doesn't refresh the list every time
        - `Task.sequence` may help to stack up the calls if `Task` successful
    4. How can we convert this to a component for reuse?
        - A `List Url` for multiple images?
        - A `List File` for multiple files?
        - A `List Base64` for multiple base64 strings?
    5. How might we deal with image limits? (lazy customers)
        - File size and compression (nobody will minimise iPhone uploads!)
        - Error handling (from server and client)
        - Unit testing for errors
-}

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, h2, img, p, strong, text)
import Html.Attributes exposing (class, src, alt)
import Html.Events exposing (onClick)
import Http exposing (..)
import File.ImageServer as Server
import Json.Decode as D exposing (decodeString, Decoder)
import Task
import Url.Builder as UB


-- Model -----------------------------------------------------------------------

{-| Url is one of:

1. A trimmed `Base64` string without metadata prefix
2. A loaded image url successfully returned from the server

View lifts the `Base64 String` for the button click!
-}
type Url
    = Base64 String
    | Loaded String

type Msg
  = ImageRequested
  | ImageSelected File
  | ImageToUrl String
  | SendToServer String -- #! See `Url` notes
  | ImageServerResponse (Result Http.Error String)

{-| Simplified model

> ⚠️ May contain impossible state! See notes.

Reduced the fields from previous versions.
-}
type alias Model =
  { image : Maybe File
  , url : Url
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model Nothing (Base64 ""), Cmd.none )



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

{-| ImgBB expects a `--form` POST request!

> We pass in a `base64` file string (not the file)

Other servers can use a simple `Http.post` with a `url` and `Http.emptyBody`.
Some servers can use `Http.request` and `Http.fileBody` for the file itself. Either
way the `<data-string>` should be URL % encoded.

You can send multiple files with `Http.multipartBody` (see docs)  -}
postImage : String -> Server.ApiKey -> String -> Cmd Msg
postImage expiration (Server.ApiKey str) file =
    Http.request
        { method = "POST"
        , headers = []
        , url = buildUrl expiration str
        , body =
            Http.multipartBody
                [ Http.stringPart "image" file ]
        , expect = Http.expectJson ImageServerResponse decodeImage
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

{-| `File` to `Base64`

> We hold on to `File` and convert to `Base64`

This `base64` value must be stripped of it's metadata as the image API does
not accept the prefix.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "Msg" msg of
    ImageRequested ->
        ( model
        , Select.file ["image/jpg", "image/png", "image/gif"] ImageSelected
        )

    -- #! No longer has `Task.perform ImageLoaded (File.toUrl file)` step as we
    --    store `File` in the model and only convert it on server upload click.
    ImageSelected file ->
        ( { model
            | image = Just file
        }
        , Task.perform ImageToUrl (File.toUrl file)
        )

    -- #! It may be better to store this as a separate value
    ImageToUrl unTrimmedBase64 ->
        let
            trimmedBase64 = (trimBase64 unTrimmedBase64)
        in
        ( { model
            | url = trimmedBase64
          }
        , Cmd.none
        )

    SendToServer base64 ->
        ( model
        , postImage "600" (Server.ApiKey "104e88f54082d98be7ac1d3649ba21d1") base64 )

    {- #! See the custom type for `imageUrl` -}
    ImageServerResponse (Ok payload) ->
        ( { model | url = Loaded payload }
        , Cmd.none
        )

    ImageServerResponse (Err _) ->
        ( model
        , Debug.todo "Handle server errors here"
        )

{-| ImgBB doesn't like the prefix -}
trimBase64 : String -> Url
trimBase64 unTrimmedBase64 =
    List.drop 1 (String.split "," unTrimmedBase64)
        |> String.join ""
        |> Base64


-- View ------------------------------------------------------------------------


{-| #! File view

> We store the `File` to access it's information

However, only certain functions are available directly in the `view`.
Other functions, such as `File.toString` require a `Task` -> `Msg`.
-}
view : Model -> Html Msg
view model =
  case model.image of
    Nothing ->
        button [ onClick ImageRequested ] [ text "Upload an image" ]

    Just file ->
        div [ class "wrapper" ]
            [ p []
                [ strong []
                    [ text ("Upload " ++ (File.name file) ++ " to the server!") ]
                ]
            , p []
                [ strong []
                    [ text ("size: " ++ (String.fromInt (File.size file))) ]
                ]
            , case model.url of
                Base64 str ->
                    div []
                        [ button [ onClick (SendToServer str) ]
                            [ text "Upload Image to Server!"]
                        -- , Debug.todo
                        --     """
                        --     Server errors may need to be handled!
                        --     @rtfeldman used `List Problem` for form AND server errors!
                        --     """
                        ]

                Loaded url ->
                    div []
                        [ h2 [] [ text "Image Uploaded! Here's the URL:" ]
                        , img [ src url
                            , alt "Uploaded image"
                            ] []
                        ]
            ]


-- Subscriptions ---------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
