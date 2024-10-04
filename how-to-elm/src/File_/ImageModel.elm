module File_.ImageModel exposing
    ( ImageUrl(..)
    , init
    , Msg(..)
    , Model
    )

{-| Upload to server Model
    ----------------------
    ⚠️ I think Elm doesn't like modules and package name clashes (like `File`)

    I've split this out for clarity. I'm using this repo as an example of how
    to modulerize the program:

        @ https://github.com/passiomatic/elm-designer

-}

import File exposing (File)
import Http


type ImageUrl
    = ImageNotAskedFor
    | Image (Result Http.Error String)

type alias Base24 =
    String

type Msg
  = ImageRequested
  | ImageSelected File
  | ImageLoaded String
  | SendToServer Base24
  | SentImage (Result Http.Error String)

type alias Model =
  { image : Maybe String
  , imageName : String
  , imageUrl : ImageUrl
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model Nothing "" ImageNotAskedFor, Cmd.none )
