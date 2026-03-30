module Form.SingleField exposing (..)

{-| ----------------------------------------------------------------------------
    ⚠️ Simple field without validation
    ============================================================================
    > Simplify your types if they're not required!

    1. You might want extra hints to the user for accidental saves
    2. `NoEntries` is equivalent to `[]` so stick with a simple list!

    This currently has no validations other than `""` and uses a more complex
    type than is needed. Always look for a simpler option before a custom type.
    Previously looked like this:

    ```
    type Entries =
        | NoEntries
        = Entries (List Entry)
    ```

    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. Add validation errors (only ONE `Result` per form)
    2. Add errors in-place below the field (as-you-type or submit?)

-}

import Browser
import Html exposing (Html)
import Html.Attributes exposing (class, disabled, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)


{- `Id Int` may be preferable -}
type alias Id =
    Int

type alias Entry =
    { id : Id
    , text : String
    }

type alias Entries
    = List Entry

type alias Model =
    { id : Id
    , entries : Entries
    , currentEntry : String
    }

initialModel : Model
initialModel =
    { id = 0
    , currentEntry = ""
    , entries = []
    }

type Msg
    = UpdateCurrentEntry String
    | SaveEntry


-- View ------------------------------------------------------------------------


viewEntryItem : Entry -> Html Msg
viewEntryItem { id, text } =
    Html.li [ class (String.fromInt id)] [ Html.text text ]

{-| Form currently has no validation

We're only checking if a field is empty or not. We do however disable the button
to only be clickable if a non-empty string.

Javascript can be hacked ... always double check values on the server!
-}
viewForm : String -> Html Msg
viewForm currentEntry =
    Html.form [ class "new-entry", onSubmit SaveEntry ]          -- (a)
            [ Html.input
                [ type_ "text"
                , placeholder "Add your cool entry here ..."
                , value currentEntry                        -- (b)
                , onInput UpdateCurrentEntry                -- (c)
                ]
                []
            , Html.button
                [ disabled (String.isEmpty currentEntry) ]  -- (d)
                [ Html.text "Save" ]
            ]

view : Model -> Html Msg
view model =
        case model.entries of
            [] ->
                Html.div []
                    [ Html.p [] [ Html.text "You need to add an entry first!" ]
                    , viewForm model.currentEntry ]

            entries ->
                Html.div []
                    [ Html.ul [ class "entry-list" ]
                        (List.map viewEntryItem entries)
                    , viewForm model.currentEntry ]



-- Update ----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCurrentEntry entry ->
            { model | currentEntry = entry }

        -- Strip trailing spaces, add to list, increment id
        SaveEntry ->
            let
                entry = String.trim model.currentEntry
            in
            case entry of
                "" ->
                    model

                _ ->
                    { model
                        | entries = model.entries ++ [ Entry model.id entry ]
                        , currentEntry = ""
                        , id = model.id + 1
                    }


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
