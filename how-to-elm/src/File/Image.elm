module File.Image exposing (..)

{-| ----------------------------------------------------------------------------
    The Image Module: uploading a file to the server (a URL in response)
    ============================================================================
    ⚠️ Try to avoid naming clashes with elm packages.
    ⚠️ Avoid large files. Read notes on `data:` urls.
    You can allow multiple image types (MIME) in `File.toUrl` as a list.

    See @ issue #43 for detailed notes on `base64` (freeimage.host CORS error).
    See @ https://tinyurl.com/simplest-way-to-upload-img for help.
    See `elm/file` package for example csv upload program.

    Technical tasks
    ---------------

    1. Upload a file (based on allowed `MIME` types)
    2. Convert `file` to `File.toUrl`.
    3. Strip the `data:[<mediatype>][;base64],` part.
    4. Store it in the `Model`.
    5. URL encode the `<data-string>` part (`freeimage.host` only)
    6. Send to server with POST (or `--form`) (with `onClick` message)
    7. AVOID LARGE FILES (both `curl` and POST will crash, load slow, or error)
        - `200kb` is fine, `1mb` isn't
    8. Collect the image url from the server response ...
    9. Repeat for multiple files (or send multiple `Task`s perhaps?)

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
    For some reason in certain cases the module is NOT SHOWING this in the
    browser (it's there if you inspect element). That could be a CSS issue.

    What it looks like to a visitor
    -------------------------------
    1. Click a button (and select an acceptable image file)
    2. Upload the file. Returns the file name (and the `<data-string>`)
        - You'll likely want to hide the data string from user.
    3. "Send to image server" button is now available
        - You could use `Task.sequence` here to store multiple files?
        - We're only allowing ONE file right now ...
        - But your form might have 2-3 image fields available
        - They're only image urls! Step (2) does the hard work.
    4. If our `Task` is successful, user sees "Image ready"
        - Our image is simply a URL ...
        - Which we can post to our `json` server with a form.
        - Your form might have 2-3 image fields available, (step 3) is doing
          the hard work here.

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
    2. WRITE BASIC UNIT TESTS!! There was one instance where I didn't export
       `Base24` type (`String` that `Msg` consumed) in my `Model` module and the
       compiler DID NOT CATCH IT.
    3. Check image FILE SIZE ... over ___ takes way too long
    4. Elm `Html` with `p` and `strong` looks kind of UGLY. How can I make it
       easier to work with? Find a good plugin
    5. It might be nice to hold on to the `data:` meta, just strip it for now.
    6. Version `js` and `css` files to force fresh reload (sometimes seems to get
       stuck at a previous version)
    7. Could we handle the `imageUrl` in the model a bit better?
        - Right now we're chaining `case` statements for our possible image
          states. Could we improve the STRUCTURE OF OUR VIEW?

-}

import Browser
import File exposing (File)
import File.Select as Select
import File.ImageModel exposing (..)
import File.ImageMultiPart exposing (postImage)
import Html exposing (Html, button, div, p, strong, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Http exposing (..)
import Task
import Debug exposing (..)



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
            chopBase24 = String.join "" (List.drop 1 (String.split "," base64))
        in
        ( { model | image = Just chopBase24 }
        , Cmd.none
        )

    {- #! We KNOW that `model.image` is not `Nothing` at this point. No need
    for another "lifting" of the `Maybe` type. Just send it along! -}
    SendToServer base24 ->
        ( model
        , postImage "104e88f54082d98be7ac1d3649ba21d1" base24 )

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
            [ p [] [ text ("image: " ++ url ++ "is ready to add to the form!") ] ]


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
