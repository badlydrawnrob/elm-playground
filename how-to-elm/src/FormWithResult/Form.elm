module FormWithResult.Form exposing (..)

{-| A simple form that's validated with `Result`
    ============================================

    Questions to be answered
    ------------------------

    1. How might you add the validation errors in-place with the form field?
    2. Is `Result` the best way to do this, or is there a better method?
        - For instance, we could use a `List error` or something.
    3. Is there an easier way to check `viewEntries` if empty and return
       different if so? I have a feeling `Maybe Entries` and `Maybe.Default`
       is an option here? Or `type Custom`?

    Notes on the comments
    ---------------------

    I'm not sure I like the way the `{-|-}` comments look. I quite like having
    things tidy — comments at the start of each section, with a number that
    references the part of the code we're talking about.

    The `{-|-}` method is quite useful when hovering over the function where it's
    used to get a definition however.

    The jury is out on that one!

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, classList, disabled, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)

type alias Entry =
    { id : Int
    , text : String
    }

type Entries
    = NoEntries
    | List Entry

type alias Model =
    { id : Int
    , entries : Entries
    , currentEntry : String
    }

initialModel : Model
initialModel =
    { id = 0
    , entries = NoEntries
    , currentEntry = ""
    }

type Msg
    = UpdateCurrentEntry String
    | SaveEntry


-- View ------------------------------------------------------------------------

{-| Pull in a record, output a `li` -}
viewEntryItem : Entry -> Html Msg
viewEntryItem entry =
    li [] [ text .text ]

viewEntries : List Entry -> Html Msg
viewEntries entries =
    case entries

    _ ->
        (List.map viewEntryItem entryList )

{-| Our simple form field, which we'll have to validate before allowing the
user to submit ... see `update` and our `FormValidate` module.

    (a) In this version we don't care if `entryList` is empty `[]` ...
    - "/programming-elm/RefactorEnhance/Picshare04.elm" on line 95  has an
      example function which output `text ""` if `[]`. It's quite easy.

    `onSubmit SaveEntry` passes a `Msg` we can `case` on ...
    `value comment` takes our `model.entry` as a value, and updates as our
    model updates with our `onInput Comment` message.
-}
viewWrapper : String -> List Entry -> Html Msg
viewWrapper currentEntry entries =
    div [] [
        if isEntry entries then
            ul [ class "entry-list" ]
                viewEntries entries
            , viewForm entries
        else
            div [] [ text "You need to add an entry first!" ]

        ,
        ]

viewForm : String -> Html Msg
viewForm currentEntry =
    form [ class "new-entry", onSubmit SaveEntry ]  -- (a)
            [ input
                [ type_ "text"
                , placeholder "Add your cool entry here ..."
                , value entry                             -- (b)
                , onInput UpdateCurrentEntry              -- (c)
                ]
            ]

view : Model -> Html Msg
view model =
    main_ []
        [ div [ class "wrapper" ]
            [ h1 [] [ text "Testing a simple form" ] ]
        , section [ class "form" ]
            [ viewForm model.currentEntry model.entries ]
        ]


-- Update ----------------------------------------------------------------------

saveEntries : Model -> Model
saveEntries model =
    let
        entry = String.trim model.currentEntry
    in
    case entry of
        "" ->
            model

        _ ->
            { model
                | entries = model.entries ++ [ Entry id entry ]
                , currentEntry = ""
                , id = id + 1
            }


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCurrentEntry entry ->
            { model | currentEntry = entry }

        SaveEntry ->
            { model | saveEntries model }
