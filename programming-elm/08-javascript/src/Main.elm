module Main exposing (..)

{-|

---

    Image upload form (new and improved!)
    ============================================================================

-}

import Browser
import File exposing (File)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onSubmit)



-- Types -----------------------------------------------------------------------


type alias Model =
    { images : List File }


type Msg
    = UpdateImage File
    | UpdateTitle String
    | UpdateDescription String
    | Submit



-- View ------------------------------------------------------------------------


{-| Drag-and-drop form

Use Mozilla's developer example:

    <pre id="output"></pre>

[Hijacks](https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault)
some events related to drag-and-drop and file selection:

    Html.Events.preventDefaultOn event (D.map hijack decoder)

-}
view : Model -> Html Msg
view model =
    form [ onSubmit Submit ]
        [ input
            [ Attr.placeholder "Title"
            , Attr.attribute "aria-label" "Title" -- ⚠️ Not required if `label` used.
            , Attr.type_ "text"
            , Attr.name "text"
            , Attr.value model.title
            ]
            []
        , textarea
            [ Attr.name "Description"
            , Attr.placeholder "Write a description for your images"
            , Attr.attribute "aria-label" "Description" -- ⚠️ Not required if `label` used.
            , Attr.value model.description
            ]
            []
        , pre
            [ Attr.id "output"
            , hijackOn "dragenter" (D.succeed DragEnter)
            , hijackOn "dragover" (D.succeed DragEnter)
            , hijackOn "dragleave" (D.succeed DragLeave)
            , hijackOn "drop" dropDecoder
            ]
            [ text "Drop files here from your file system." ]
        ]


hijackOn : String -> D.Decoder msg -> Attribute msg
hijackOn event decoder =
    preventDefaultOn event (D.map hijack decoder)


hijack : msg -> ( msg, Bool )
hijack msg =
    ( msg, True )



-- Update ----------------------------------------------------------------------
