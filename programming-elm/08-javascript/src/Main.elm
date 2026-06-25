module Main exposing (..)

{-|

    ----------------------------------------------------------------------------
    Image upload form (new and improved!)
    ============================================================================

    ## Drag-and-drop

    I'm using Mozilla's developer example element:

        <pre id="output"></pre>

    [Hijacks](https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault)
    some events related to drag-and-drop and file selection:

        Html.Events.preventDefaultOn event (D.map hijack decoder)

    We listen for events on the `<pre>` element, and pass our `Msg` type to a decoder.
    This decoder must produce a message and a `Bool` that decides if `preventDefault`
    should be called. Our drag events simply change the `model.hover` state.

    The `dropDecoder` hijacks the [`drop`](https://tinyurl.com/mozilla-drag-drop-file)
    event. Browser automatically populates files into the event's `DataTransfer` object.
    Elm decodes as either a single `File.decoder` or `GotFiles` message.

        ⚠️ `D.list File.decoder` could also be used to same effect.


    Immutable
    ---------
    > `ListFile` object inside `DataTransfer.files` is immutable

    So we cannot update or change it. Dragging more files into the `<pre>` element
    will replace the previous files (not add to them).


    Non-empty list
    --------------
    > Took me a while to understand `D.oneOrMore`!

    As our `FileList` can never be empty, we need a decoder that will always
    produce a non-empty list. So our `GotFiles File (List File)` always guarantees
    that at least one file is present.

    It's NOT used for what I initially thought (adding more files to the list).
    We can't do that anyway (see "Immutable" above).



    ----------------------------------------------------------------------------
    WISHLIST
    ============================================================================
    1. See what the `GotFiles` message looks like in the console.

-}

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import Json.Decode as D



-- Types -----------------------------------------------------------------------


type alias Model =
    { hover : Bool
    , title : String
    , description : String
    , images : List File
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { hover = False
      , title = ""
      , description = ""
      , images = []
      }
    , Cmd.none
    )


type Msg
    = UpdateTitle String
    | UpdateDescription String
      -- Image uploads
    | Pick
    | DragEnter
    | DragLeave
    | GotFiles File (List File)
      -- Form submission
    | Submit



-- Update ----------------------------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTitle title ->
            ( { model | title = title }
            , Cmd.none
            )

        UpdateDescription description ->
            ( { model | description = description }
            , Cmd.none
            )

        Pick ->
            ( model
            , Select.files [ "image/*" ] GotFiles
            )

        DragEnter ->
            ( { model | hover = True }
            , Cmd.none
            )

        DragLeave ->
            ( { model | hover = False }
            , Cmd.none
            )

        GotFiles file files ->
            ( { model
                | images = file :: files
                , hover = False
              }
            , Cmd.none
            )

        Submit ->
            ( model
            , Cmd.none
            )



-- View ------------------------------------------------------------------------


{-| Drag-and-drop form

> ⚠️ If a `label` is used, `aria-label` is not required.

-}
view : Model -> Html Msg
view model =
    form [ onSubmit Submit ]
        [ input
            [ Attr.placeholder "Title"
            , Attr.attribute "aria-label" "Title"
            , Attr.type_ "text"
            , Attr.name "text"
            , Attr.value model.title
            ]
            []
        , textarea
            [ Attr.name "Description"
            , Attr.placeholder "Write a description for your images"
            , Attr.attribute "aria-label" "Description"
            , Attr.value model.description
            ]
            []
        , pre
            [ Attr.id "output"
            , Attr.classList [ ( "hover", model.hover ) ]
            , hijackOn "dragenter" (D.succeed DragEnter)
            , hijackOn "dragover" (D.succeed DragEnter)
            , hijackOn "dragleave" (D.succeed DragLeave)
            , hijackOn "drop" dropDecoder
            ]
            [ text "Drop files here from your file system." ]
        ]


{-| Decode the `json` from the `drop` event.

> `dataTransfer.files` is an array-like `FileList` object.

We use `D.oneOrMore` as it's a non-empty list. First `File` is decoded with
`File.decoder`; the rest as a list of `File`s.

-}
dropDecoder : D.Decoder Msg
dropDecoder =
    D.at [ "dataTransfer", "files" ] (D.oneOrMore GotFiles File.decoder)


hijackOn : String -> D.Decoder msg -> Attribute msg
hijackOn event decoder =
    preventDefaultOn event (D.map hijack decoder)


hijack : msg -> ( msg, Bool )
hijack msg =
    ( msg, True )



-- Subscriptions ---------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- Main ------------------------------------------------------------------------


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
