module Form.SingleFieldNotes exposing (..)

{-| ----------------------------------------------------------------------------
    ✅ A simple form that's validated with `Result`
    ============================================================================

    Notes on `Maybe` and `type Custom`
    ----------------------------------

    I tried to make a custom type that's similar to, but more specific
    than a `Maybe` (`Just (List entryRecord)` or `Nothing`). Here's the gist:

    1. `Maybe` requires using `Maybe.map entryFieldFunc model.entry`, which
       unwraps the `Maybe (List Entry)` to let us edit it's fields.
    2. `Entries` custom type does much the same thing, but it's a little more
       specific by calling it either `NoEntries` or `Entries (List Entry)`

    The second option doesn't really help us _that_ much, as `NoEntries` is
    almost the same as `[]` which an empty list covers. A list can also be a
    singleton, i.e `[Entry]` or "many" `[Entry1, Entry2, ...]`.

    So either `Maybe List` or `Entries` allow us to check if a list exists in
    our `json` and provide us with a datatype that covers this. We might also
    want to wrap this in a `Collection` (which would be a `Maybe` instead of
    the `List`)

    Extracting from `ID`
    --------------------
    extractID (ID num) = num
-}


{-| It might be better to be specific about our Id field, incase a different
type also requires an Id. The compiler will stop us using this Id for the
wrong type. Alternatively, just use a `uuid` for all the things -}
type alias Id =
    Id Int

{-| We'll need a function to extract the Id -}
getId : Id -> Int
getId id =
    case id of
        Id number -> number

type alias Entry =
    { id : Id
    , text : String
    }

{-| There's no real benefit here to using a custom type ...
... as a simple `List Entry` has `[]` (empty). However,
it might be useful if there's the potential that a list doesn't
even exist in the json response (i.e: it hasn't been created yet)
-}
-- type Entries
--     = NoEntries
--     | Entries (List Entry)

-- type alias Model =
--     { id : Id
--     , entries : Entries
--     , currentEntry : String
--     }

-- initialModel : Model
-- initialModel =
--     { id = 0
--     , entries = NoEntries
--     , currentEntry = ""
--     }

{-| Instead of the above, we have a simple list type -}
type alias Entries =
    List Entry

{-| Our model then could look like this: -}
type alias Model =
    { id : Id
    , entries : Entries
    , currentEntry : String
    }

initialModel =
    { id : Id 0
    , entries : []
    , currentEntry : ""
    }

type Msg
    = UpdateCurrentEntry String
    | SaveEntry


-- View ------------------------------------------------------------------------

{-| If we knew we are only ever going to receive an `[]` empty list, or a
`List Entry`, we wouldn't have to do much in `view` and could just output an
empty list in the HTML such as ... -}

simpleList : Entries -> Html Msg
simpleList entries =
    ul []
        (List.map makeListItem initialModel)

makeListItem : Entry -> Html Msg
makeListItem entry =
    li [class (String.toInt (getId entry.id))] [ text entry.text ]

{-| However, if we're playing safe and using a `Maybe (List Entry)` we'd have
to make sure to `case` on the eventuality that it's `Nothing` (our json has
zero `List Entry` available). -}

view : Model -> Html Msg
view model =
        case model.entries of
            NoEntries ->
                ...
            Entries listOfEntries ->
                ...


-- Update ----------------------------------------------------------------------

{-| If we are simply using `List Entry`, our `update` function is pretty simple.
We're NOT adding any field error checks here though -}

update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateCurrentEntry entry ->
            { model | currentEntry = entry }

        SaveEntry ->
            { model | entries = model.entry ++ [currentEntry] }

{-| However, if we're playing for safety with `Maybe`, we'll need to unwrap,
and then wrap the `Entries` in a `Just a` ... you can do this in a nice succinct
way _without_ having to resort to `case` and `Nothing` or `Just a` branches.
You can see the example below. -}

addOneToEntry : Entry -> Entry
addOneToEntry entry =
    { entry | id = entry.id + 1 }

doStuffWithMaybe : Maybe Entry -> Maybe Entry
doStuffWithMaybe entry =
    entry |> Maybe.map addOneToEntry

doStuffWithMaybe : Maybe Entry
doStuffWithMaybe (Just (Entry 1 "a lovely comment"))

{- The above `doStuffWithMaybe` function is a catch all function that we can
use with helper functions for _all_ our field changes. We need to unwrap and wrap
the `Maybe Entry` every time! (in real life this would be a `Maybe (List Entry)`
and we'd use `List.map` to cycle through our list of records). }
