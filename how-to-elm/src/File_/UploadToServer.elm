module File_.UploadToServer exposing (..)

{-| Uploading an image file to a server
    ----------------------------------
    ⚠️ I think Elm doesn't like modules and package name clashes (like `File`)

    See `UploadToServerModel` and `UploadToServerResponse`.
    Original script @ https://package.elm-lang.org/packages/elm/file/latest/


    The file
    -------
    1. Upload file
    2. Convert it into a `base64` string (`File.toString`)
    3. When button clicked, send `base64` string to server
    4. Collect the URL in the response (it's a `Result` type)

    Questions
    ---------
    1. What if our `Task.perform` fails?
        - And what does `Never` mean. It can never fail?
    2. Our `Maybe` is causing problems.
       What's the most suitable route?
        - Our image upload is a `Maybe String` ...
        - We deal with that in a `view` with `case`
        - When it comes to pinging the server, we must "lift" the
          maybe. We know it exists.
    3. **How do I handle the `imageUrl` in the model better?
        - It's one of
    4. Our `view` is chaining `case` expressions:
        - We have a `Maybe String` for our `image` upload
        - And a `Result` for our `imageUrl` (server)
        - How might we improve the structure of our view?

-}

import Browser
import File exposing (File)
import File.Select as Select
import File_.UploadToServerModel exposing (..)
import File_.UploadToServerResponse exposing (postImage)
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (style)
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
        , Select.file ["image/jpg", "image/png"] ImageSelected
        )

    {- #! Should `File.name` function be the second param to `Task.perform`?
    Should `File.toString` be `File.toUrl`? -}
    ImageSelected file ->
      ( model
      , Task.perform (ImageLoaded (File.name file)) (File.toString file)
      )

    {- #! I'm not sure if our `filename` should be a `Maybe` too?
    I think if our `Task` is successful then it's probably OK without -}
    ImageLoaded filename content ->
      ( { model
            | image = Just content
            , imageName = filename
        }
      , Cmd.none
      )

    {- #! Here we KNOW that there's a `base64` string ready, but we still
    need to unpack the bloody `Maybe`. For now I'm doing a dirty and using
    `Maybe.withDefault`. -}
    SendToServer ->
        ( model
        , postImage "6d207e02198a847aa98d0a2a901485a5" (Maybe.withDefault "" model.image) )

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
        p [] [ text ("image: " ++ url ++ "is ready to add to the form!") ]

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

        Just _ ->
            div []
                [ p [ style "white-space" "pre" ] [ text model.imageName ]
                , button [onClick SendToServer] [ text "Upload Image to Server!"]
                ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
