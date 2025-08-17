module Form.ToDoSimple exposing (..)

{-| Following this tutorial:

      @ https://dev.to/selbekk/creating-a-todo-app-in-elm-i3o

    Bugs:
    -----

      You have 3 items. Go to "remaining items" and toggle off item #2.
      Now toggle item #3. Item #2 reappears, as if _that_ item had been
      toggled on again. Item #3 remains on screen.

      This seems to be due to the `List.indexedMap`:

        1. Toggling `item #2` means `item #3` now has an index of 2
        2. Toggling _that_ item targets the original [..., item2, ...] in the list
        3. So our model of ListToDo is incorrectly being assigned on screen

      This could be solved by attributing an ID to each ToDo.
      Or, using CSS to toggle the list between completed etc.

    Could be improved:
    ------------------

      Simple:
        Split the list in a better way for `removeFromList`.
        Use the `<|` pipe function instead of parens for `toggleAtIndex`?
        `viewSelectFilter` is it necessary to use a record here?

      Hard(er):
        Get rid of indexes completely and assign a proper ID to each
        ToDo record. Use this ID to `remove` and `toggle` the ToDo.

    Questions:
    ----------

      Should small helper functions be used? (Check if List.empty)
      or just have them inline as and when needed?
-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Debug exposing (..)


-- Model -----------------------------------------------------------------------

-- I changed `Todo` to `ToDo` below!

type alias ToDo =
  { text : String
  , completed : Bool
  }

type alias ToDoList =
  List ToDo

type alias Model =
  { todos: ToDoList
  , inputText : String
  , filter: Filter
  }

type Message
  = AddToDo
  | RemoveToDo Int
  | ToggleToDo Int
  | ChangeInput String
  | ChangeFilter Filter

type Filter
  = All
  | Completed
  | Remaining

type alias RadioWithLabelProps =
  { filter : Filter
  , label : String
  , name : String
  , checked : Bool
  }

-- Main ------------------------------------------------------------------------

initialModel =
  { todos = []
  , inputText = ""
  , filter = All
  }

main =
  Browser.sandbox
    { init = initialModel
    , update = update
    , view = view
    }


-- Update ----------------------------------------------------------------------

-- #1: This actually updates the entire state, so could be given a completely
--     new model instead of "updating" the existing one.
--
-- #2: We're essentially splitting the list here, by creating two lists to the
--     left and the right of the item we're dropping.
--
-- #3: I've split out this into it's own helper function (original was an
--     anonymous function)

update : Message -> Model -> Model
update message model =
  case message of
      AddToDo ->  -- #1
        { model
          | todos = addToList model.inputText model.todos
          , inputText = ""
        }

      RemoveToDo index ->
        { model | todos = removeFromList index model.todos }

      ToggleToDo index ->
        { model | todos = toggleAtIndex index model.todos }

      ChangeInput input ->
        { model | inputText = input }

      ChangeFilter filter ->
        { model | filter = filter }

addToList : String -> List ToDo -> List ToDo
addToList input todos =
  todos ++ [{ text = input, completed = False }]

removeFromList : Int -> List ToDo -> List ToDo
removeFromList index list =
  List.take index list ++ List.drop (index + 1) list  -- #2

toggleAtIndex : Int -> List ToDo -> List ToDo
toggleAtIndex indexToToggle list =
  List.indexedMap (checkIndex indexToToggle) list

checkIndex : Int -> Int -> ToDo -> ToDo
checkIndex indexToToggle index todo =
  if indexToToggle == index then
    { todo | completed = not todo.completed }
  else
    todo


-- View ------------------------------------------------------------------------

-- #1: Error: Without the `(` parens this pipeline won't work. I've searched
--     for a reason why, but I can't find one. In the tutorial, it works without
--     the parens. Boo!

view : Model -> Html Message
view model =
  Html.form [ onSubmit AddToDo ]
    [ h1 [] [ text "Todos in Elm" ]
    , input [ value model.inputText
            , onInput ChangeInput
            , placeholder "What do you want to do?"
            ] []
    , viewSelectFilter model.filter
    , viewList model.todos model.filter
    ]

viewList : ToDoList -> Filter -> Html Message
viewList list filter =
  if (isEmptyList list) then
    p [] [ text "The list is clean 🧘‍♀️" ]
  else
    ol []
      (list -- #1
      |> List.filter (applyFilter filter)
      |> List.indexedMap viewToDo)

isEmptyList : ToDoList -> Bool
isEmptyList list =
  List.isEmpty list

applyFilter : Filter -> ToDo -> Bool
applyFilter filter todo =
  case filter of
      All ->
        True

      Completed ->
        todo.completed

      Remaining ->
        not todo.completed

viewToDo : Int -> ToDo -> Html Message
viewToDo index todo =
  li
    [ style "text-decoration" (viewTextStyle todo.completed) ]
    [ text todo.text
    , button [ type_ "button", onClick (ToggleToDo index) ] [ text "Toggle" ]
    , button [ type_ "button", onClick (RemoveToDo index) ] [ text "Delete" ]
    ]

viewTextStyle : Bool -> String
viewTextStyle bool =
  if bool then "line-through" else "none"

viewRadioWithLabel : RadioWithLabelProps -> Html Message
viewRadioWithLabel config =
  label []
    [ input
        [ type_ "radio"
        , name config.name
        , checked config.checked
        , onClick (ChangeFilter config.filter)
        ] []
    , text config.label
    ]

viewSelectFilter : Filter -> Html Message
viewSelectFilter filter =
  fieldset []
    [ legend [] [ text "Current filter" ]
    , viewRadioWithLabel
        { filter = All
        , name = "filter"
        , checked = filter == All
        , label = "All items"
        }
    , viewRadioWithLabel
        { filter = Completed
        , name = "filter"
        , checked = filter == Completed
        , label = "Completed items"
        }
    , viewRadioWithLabel
        { filter = Remaining
        , name = "filter"
        , checked = filter == Remaining
        , label = "Remaining items"
        }
    ]
