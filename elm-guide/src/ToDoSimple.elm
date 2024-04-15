module ToDoSimple exposing (..)

{-| Following this tutorial:

      @ https://dev.to/selbekk/creating-a-todo-app-in-elm-i3o

    Could be improved:

      Simple:
        Split the list in a better way for `removeFromList`.
        Use the `<|` pipe function instead of parens for `toggleAtIndex`?

      Hard(er):
        Get rid of indexes completely and assign a proper ID to each
        ToDo record. Use this ID to `remove` and `toggle` the ToDo.

    Questions:

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
  }

type Message
  = AddToDo
  | RemoveToDo Int
  | ToggleToDo Int
  | ChangeInput String


-- Main ------------------------------------------------------------------------

initialModel =
  { todos = []
  , inputText = ""
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

view : Model -> Html Message
view model =
  Html.form [ onSubmit AddToDo ]
    [ h1 [] [ text "Todos in Elm" ]
    , input [ value model.inputText
            , onInput ChangeInput
            , placeholder "What do you want to do?"
            ] []
    , viewList model.todos
    ]

viewList : ToDoList -> Html Message
viewList list =
  if (isEmptyList list) then
    p [] [ text "The list is clean 🧘‍♀️" ]
  else
    ol [] (List.indexedMap viewToDo list)

isEmptyList : ToDoList -> Bool
isEmptyList list =
  List.isEmpty list

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
