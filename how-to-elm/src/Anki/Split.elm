module Anki.Split exposing (..)

{-| A test file for an Anki flashcard (delete anytime)

> Extract and pair "2:00" as efficiently as possible ...
> A little practice often as I'm pretty freakin' rusty!

1. Expects "2:00" exactly (many potential states problem)
    - We have a ton of assumptions just in this very simple context[^1]
    - This is the original "2:00" problem ("2" and "0" is far easier)
    - My learning frame is very much ANTI-TEXT-EDITING style programming
2. Our `["2", "0"]` list is more difficult to extract with Elm Lang!
    - The too many `Maybe`s problem: `List.head` returns a maybe ...
    - Our original 2-list extracted with a `case` may result in less code!

Methods:
    The sentence method: https://subjectguides.york.ac.uk/note-taking/sentence
    (also see the `WriteArticles.md` file which is based on "Simplicity" book)

    Extract 2 elements, convert to `Int`, tuple pair, return as strings
    Ideally reduce number of steps (and number of `Maybe`s)

    Sketch out on paper what it means to go from A -> B ..
    Pick the easiest path (which may result in _more_ code)


Stupidity
    + Python is far more forgiving: Elm Lang is more correct but oft harder
    + Simple to read but more code is sometimes the best way to write (future self)
    + A map function always returns it's type (`List.map Tuple.pair` won't work!)
      • Remember the wall analogy: you're "lifting" a value over it!
    + A `List.filterMap` can still result in `Maybes` further down the line
    + Rule out anything that isn't necessary (such as a `Result`)


[^1]: Presumes: 2 items in list only, ":" separator, proper integers.

-}

import Html
import Tuple
import List.Extra


value = "2:00"

splitValues : String -> List String
splitValues =
    String.split ":"

{- Convert values without unpacking `Maybe`s -}
convertValues : List String -> List Int
convertValues lst =
    List.filterMap String.toInt lst

{-| Instead of using a `case` statement we can map to a tuple directly.

1. `List.head` returns a `Maybe` type so we still need to `case`/`.withDefault`
2. `List.tail` returns the remainder of the list ...
    - So it's better to use `List.Extra.last` ...
-}
mapValues : List Int -> Maybe (Int, Int)
mapValues lst =
    Maybe.map2
        Tuple.pair (List.head lst) (List.Extra.last lst) -- #!


-- Main ------------------------------------------------------------------------

main =
    let
        result =
            case (mapValues (convertValues (splitValues value))) of
                Just (a, b) ->
                    String.fromInt a ++ String.fromInt b

                Nothing ->
                    "Failed"
    in
    Html.text result
