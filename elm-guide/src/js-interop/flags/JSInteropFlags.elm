module JSInteropFlags exposing (..)

import Browser
import Html exposing (Html, text)
import Buttons exposing (Msg)

{-| Flags

    Any JS value that can be JSON decoded can be given
    as a flag. This could be API keys, environment variables,
    and user data (for instance WeWeb's user auth data)

    The only important things here is the `init` function says it
    takes an `Int` argument. This is how Elm code gets immediate
    access to the flags you pass in from Javascript. From there,
    you can put things in your model or run some commands. Whatever you
    need to do.

    See here for a `localStorage` demo:

      @ https://github.com/elm-community/js-integration-examples/tree/master/localStorage

    VERIFYING FLAGS
    ---------------

    What happens if `init` says it takes an `Int` flag, but someone tries to
    initialize with `flags: String`? We can check for that with `Json.Decode`.

    By default, Elm checks the `flag` input is the correct type.

    Many folks always use a `Json.Decode.Value` because it gives them really
    precise control. They can write a decoder to handle any weird scenarios in
    Elm code, recovering from unexpected data in a nice way.

    Without a `Json.Decode.Value`, for instance the following would fail:

      ```
      init : Int -> ...

        3.14 => error

      init : Maybe Int -> ...

        null => Nothing
        42   => just 42
        "hi" => error
      ```

    There's more, such as Arrays. The main point is, any deviation from the
    specified input value could throw an error (on the JavaScript side).

    The error will "fail fast" and you won't be able to do much about it.
    With a Json Decoder, you can specify error values or fail gracefully.
-}


-- Main ------------------------------------------------------------------------

main : Program Int Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscription = subscription
    }


-- Model -----------------------------------------------------------------------

type alias Model = { currentTime : Int }

init : Int -> ( Model, Cmd Msg )
init currentTime =
  ( { currentTime = currentTime }
  , Cmd.none
  )


-- Update ----------------------------------------------------------------------

type Msg = NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
  ( model, Cmd.none )


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
  text (String.fromInt model.currentTime)


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
