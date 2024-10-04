module File_.Image exposing (..)

{-| ----------------------------------------------------------------------------
    Uploading an image file to a server
    ============================================================================
    ⚠️ Try to avoid naming clashes with elm packages.
    See `elm/file` package for example csv upload program.

    ----------------------------------------------------------------------------
    The problem with `base64`
    ----------------------------------------------------------------------------
    Elm Lang uses `elm/file` `File.toUrl` to encode it's uploaded image with
    `base64`. However, if you look at the output:

        data:image/jpeg;base64,<string>

    It prepends the `base64` string (or url) with `data:`. Our handy tools below
    handle it just fine. Our Image Server APIs DO NOT!!! They expect everything
    _after_ the `,` comma.

        <string>

    So we need to `String.split "," url` and use it's `tail`. It's an added hassle
    but that's what the `NETWORK ERROR` problems were. The API is not expecting
    the metadata in the call.


    Handy tools:
    ------------

    1. Encode an image as `base64` string
        @ https://www.base64-image.de/
    2. Decode an image from `base64` string
        @ https://base64.guru/converter/decode/image
    3. Strip slashes from `json` `"url"` value:
        @ https://www.browserling.com/tools/strip-slashes


    ----------------------------------------------------------------------------
    Our Image module
    ----------------------------------------------------------------------------
    `File.toUrl` seems to work fine with multiple image types, but you've got to
    be careful as sometimes it's NOT SHOWING in the browser. It's there if you
    inspect element though.

    Uploading an Image file (`.jpg`, `.jpeg`)
    ----------------------------------------
    1. Upload file (after clicking button)
    2. Convert it into a `base64` string (`File.toString`)
    3. Split the string at the `","` to remove `data:image/jpeg;base64`
    4. Store in the model ...
    5. Show "Send to server" button.
    6. Click button -> send `base64` string to server
    7. Collect the URL in the response (it's a `Result` type)

    Questions
    ---------
    1. Our `Task.perform` can NEVER fail. Why?
        - `Never` means just that. It can never fail?
    2. Our `Maybe` is causing problems.
        - Rather than "lift" the `Maybe`, send it along in the `Msg`.
        - We know it's not `Nothing` so this should be safe.
    3. **How do I handle the `imageUrl` in the model better?**
        - ...
    4. Our `view` is chaining `case` expressions:
        - We have a `Maybe String` for our `image` upload
        - And a `Result` for our `imageUrl` (server)
        - How might we improve the structure of our view?


    ----------------------------------------------------------------------------
    Wishlist
    ----------------------------------------------------------------------------
    1. Elm `Html` with `p` and `strong` looks kind of UGLY. How can I make it
       easier to work with? Find a good plugin
    2. It might be nice to hold on to the `data:` meta, just strip it for now.
    3. Write some basic tests? (`List.drop` and other areas)
    4. Version `js` and `css` files to force fresh reload (sometimes seems to get
       stuck at a previous version)

-}

import Browser
import File exposing (File)
import File.Select as Select
import File_.ImageModel exposing (..)
import File_.ImageResponse exposing (postImage)
import Html exposing (Html, button, div, p, strong, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Http exposing (..)
import Task



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
        , postImage "6d207e02198a847aa98d0a2a901485a5" base24 )

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
