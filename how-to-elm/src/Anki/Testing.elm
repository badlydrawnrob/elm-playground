module Anki.Testing exposing (..)

{-| A handy module for testing Anki flashcard code

> Can you lift a `Loaded value` without casing on enum types?

This could be designed better, with a `Success Feed` instead of `Just Feed`,
then we could either (a) create a `Success.map` function, or (b) use "naked" values
inside the `view` function with `Msg` and pass around the values, finally re-wrapping
when appropriate.

You can't deconstruct enumerated values easily, as you'd need to case on the `Success`
constructor for each branch.

-}

import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events

import Debug

type alias Photo =
    { id : Int
    , url : String
    , liked : Bool
    }

type alias Feed =
    List Photo

type alias Id =
    Int

{- Feed pulled from API -}
type alias Model =
    { feed : Maybe Feed }

type Msg =
    Liked Int


-- View ------------------------

view : Model -> Html Msg
view model =
    case model.feed of
        Nothing ->
            Html.text "Loading..."

        Just feed ->
            Html.div []
                (List.map viewPhoto feed)

viewPhoto : Photo -> Html Msg
viewPhoto photo =
    Html.img [ Html.Attributes.src photo.url
             , Html.Events.onClick (Liked photo.id)
             ] [ Html.text (Debug.toString photo.liked) ]

-- Update ----------------------

toggleLiked : Photo -> Photo
toggleLiked photo =
    { photo | liked = not photo.liked }

updateFeed : (Photo -> Photo) -> Id -> Maybe Feed -> Maybe Feed
updateFeed fn id maybeFeed =
    Maybe.map (updatePhotoByID fn id) maybeFeed

updatePhotoByID : (Photo -> Photo) -> Int -> Feed -> Feed
updatePhotoByID fn id feed =
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
        Liked id ->
            { model | feed = updateFeed toggleLiked id model.feed }

-- Model -----------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = { feed = Nothing }
        , view = view
        , update = update
        }
