module Form.SingleField exposing (..)

{-| ⚠️ A simple form that's validated with `Result`
    ===============================================

    This example is using the WRONG custom type format, and is no better
    than using a `List` (or `Maybe List`) in it's current form. A preferred
    way might be:

        Entries = NoEntries | Entries Entry (List Entry)

    It's a subtle difference, but it accounts for only ONE list item. See


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

type alias Id =
    Int

type alias Entry =
    { id : Id
    , text : String
    }

type Entries
    = NoEntries
    | Entries (List Entry)

type alias Model =
    { id : Id
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
    li [ class (String.fromInt entry.id)] [ text entry.text ]

{-| Our simple form field, which we'll have to validate before allowing the
user to submit ... see `update` and our `FormValidate` module.

    (a) We run some checks `onSubmit` too
    (b) This simply keeps the value updated with the user input (from our model)
    (c) Handover to our `Msg` on `update`
    (d) Run a check and disable the button if `String` is empty `""`!
-}
viewForm : String -> Html Msg
viewForm currentEntry =
    form [ class "new-entry", onSubmit SaveEntry ]          -- (a)
            [ input
                [ type_ "text"
                , placeholder "Add your cool entry here ..."
                , value currentEntry                        -- (b)
                , onInput UpdateCurrentEntry                -- (c)
                ]
                []
            , button
                [ disabled (String.isEmpty currentEntry) ]  -- (d)
                [ text "Save" ]
            ]

view : Model -> Html Msg
view model =
        case model.entries of
            NoEntries ->
                div [] [
                    div [] [ text "You need to add an entry first!" ]
                    , viewForm model.currentEntry
                ]
            Entries listOfEntries ->
                div [] [
                    ul [ class "entry-list" ]
                        (List.map viewEntryItem listOfEntries)
                    , viewForm model.currentEntry
                ]



-- Update ----------------------------------------------------------------------

{-| Strip the front and back of `currentEntry`, and check if empty

    (a) Return our state to an empty entry
    (b) increment the model.id for our next entry
-}
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
                | entries = updateEntriesList model.id entry model.entries
                , currentEntry = ""  -- (a)
                , id = model.id + 1  -- (b)
            }

{-| Because our `List Entry` are wrapped now in `Entries`, we've got
to work some magic to add a new `comment` (as an `Entry`) to our list:

1. If there's currently `NoEntries`, then create one ...
2. If there's already `Entries`, add one to the list.
-}
updateEntriesList : Id -> String -> Entries -> Entries
updateEntriesList id currentEntry entries =
    case entries of
        NoEntries ->
            Entries [Entry id currentEntry]

        Entries list ->
            Entries (list ++ [Entry id currentEntry])

update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCurrentEntry entry ->
            { model | currentEntry = entry }

        SaveEntry ->
            saveEntries model


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
