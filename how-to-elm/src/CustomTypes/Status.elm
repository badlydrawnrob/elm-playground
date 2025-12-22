module CustomTypes.Status exposing (..)

{-| A simple `Status` custom type which we can use with server responses

> Currently the singleton `Photo` model is hardcoded for brevity.

I'm fairly certain that if you're using a `Status a` type to wrap your main value,
you MUST unpack it within every `update` function: as a `Status.map` or (if you
only need to unpack once) a `Status.unpack` like `Maybe.Extra.unpack`. The update
function always takes the full `Model` but you can add helper functions that take
parts of the model.

I don't think there's a way to "narrow the types" like you can in a `view` function,
by unwrapping a value ONCE and ONLY once. Within our `view` we can `case` on
`model.feed` and use it's exposed value in a `Lifted` message (or any other event
or message we might write). This way we've deconstructed the value to allow for
as simple code as possible.

You can package the `Photo` types and `updatePhoto` functions together in a single
module if you prefer, but `Status` is best left within the main body file.

Which other types in `elm-playground` could be lifted once only?

-}

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html exposing (a)


type alias Photo =
    { id : Int
    , url : String
    , liked : Bool
    }

type alias Feed =
    List Photo

type alias Id =
    Int

type Status a
    = Loading
    | Loaded a

type alias Model =
    { feed : Status (List Photo) }

type Msg =
    Lifted Photo


-- Setup -----------------------
pic : Photo
pic = Photo 1 "1.jpg" False

init : Model
init =
    { feed = Loaded [ pic ] }

-- View ------------------------

view : Model -> Html Msg
view model =
  case model.feed of
    Loading ->
      Html.text "Do nothing"

    Loaded photos ->
        Html.div []
            (List.map viewPhoto photos)

viewPhoto : Photo -> Html Msg
viewPhoto photo =
    Html.a [ Events.onClick (Lifted photo)
    , Attr.href "#" -- photo.url
    ]
    [ Html.text
        ((++) "🎤 We could be lifted: "
        <| if photo.liked then "True" else "False")
    ]


-- Update ----------------------

statusMap : (a -> a) -> Status a -> Status a
statusMap fn status =
  case status of
    Loaded a ->
        Loaded (fn a)

    Loading ->
        Loading

toggleLiked : Photo -> Photo
toggleLiked photo =
  { photo
    | liked = not photo.liked }

updatePhotos : (Photo -> Photo) -> Int -> Feed -> Feed
updatePhotos fn id feed =
  List.map
    (\photo ->
      if photo.id == id then
        fn photo
      else
        photo
      )
      feed

update : Msg -> Model -> Model
update msg model =
    case msg of
        Lifted photo ->
            { model | feed =
                -- Could we "narrow the types" here in some way?
                -- `Model` still expects a `Status (List Photo)`
                statusMap
                    (updatePhotos toggleLiked photo.id)
                    model.feed
            }

-- Model -----------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
