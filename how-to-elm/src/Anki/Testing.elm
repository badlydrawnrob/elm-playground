module Anki.Testing exposing (..)

{-| A handy module for testing Anki flashcard code -}

type Clock = Clock Int Int

type alias Input =
  { entry : String }

list : List Input
list =
  [ { entry = "20" }
  , { entry = "-10" }
  ]

validate : List Input -> List (Result String Int)
validate =
  List.map
    (\record -> isNumber record.entry)

isNumber : String -> Result String Int
isNumber input =
  case String.toInt input of
    Just number ->
      if number >= 0 then
        (Ok number)
      else
        (Err "Negative number")

    Nothing ->
      (Err "Not a number")

makeClock : List Input -> Result String Clock
makeClock ls =
  case validate ls of
    [a, b] ->
      Result.map2
        Clock a b

    _ ->
      Err "Not a clock"
