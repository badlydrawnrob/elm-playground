module ImageUpload exposing (main)

{-| An image upload component to "embed" into React

The downside of Elm is even to do something as simple as display a file input
button, there's a lot of boilerplate code to write.

-}

import Browser
import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (class, for, id, multiple, type_)



-- Model -----------------------------------------------------------------------


type alias Model =
    ()


init : () -> ( Model, Cmd Msg )
init () =
    ( (), Cmd.none )



-- View ------------------------------------------------------------------------


{-| Browsers limit styling file inputs with CSS.

We will use some custom CSS to hide the input element and style the label above
it like a button. The label’s `for` attribute and input’s `id` attribute match,
so users can instead click on the styled label element to upload images.

-}
view : Model -> Html Msg
view model =
    div [ class "image-upload" ]
        [ label [ for "file-upload" ]
            [ text "+ Add Images" ]
        , input
            [ id "file-upload"
            , type_ "file"
            , multiple True
            ]
            []
        ]



-- Messages --------------------------------------------------------------------


type Msg
    = NoOp



-- Update ----------------------------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Main ------------------------------------------------------------------------


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
