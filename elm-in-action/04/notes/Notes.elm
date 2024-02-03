{-| What we're trying to achieve:

    - Improve code quality to help new team members get up to speed.
    - Let users choose between small, medium, and large thumbnails.
    - Add a Surprise Me! button that randomly selects a photo.
|-}

-- 4.0 -------------------------------------------------------------------------

-- Talking to servers --
-- We'll grab photos from the cloud,
-- associate some metadata to each photo
-- and display it on top of the big photo.

-- 4.1 -------------------------------------------------------------------------

-- Our model needs to change --
--
-- We won't have the data automatically,
-- we'll now have to send a server request
-- and build our model from external data.
--
-- If there's a problem, display an error message.
--
-- : 1) We're still loading pictures (initial state)
-- : 2) There's been a server error (display error)
-- : 3) Data successfully loaded. (grab photos, display one)

type Status
  = Loading
  | Loaded (List Photo) String
  | Errored String

-- This represents all possibilities of state.
--
-- : We could've also used a _list zipper_ data structure.
--   That's like a `List` that has exactly one of it's elements
--   marked as selected.
--
-- : We could replace `Loaded (List Photo) String with a `Loaded`
--   variant that contains a single value, a list zipper.
--
--   @ List zippers (Learn you an Elm — difficult) http://tinyurl.com/ycxyy7kt
--   @ Elm Package: http://tinyurl.com/elm-lang-list-zippers


-- Our view now has to change --
-- inside our main `view` function

-- A div is just a set of attributes and a `List`
-- of children ...

div [ class "wrapper" ]  -- Missing `[]`

-- That's not valid syntax until we add the missing `[]`
-- but we create a separate function that will return
-- a `List (Html Msg)` like so:

aRandomNumber : Int
aRandomNumber = 1

viewInsideWrapper Int -> List (Html Msg)
viewInsideWrapper arguments =
  [
    p [] [ text (String.fromInt arguments)]
  ]

-- We've just broken up our `Model` into it's component parts ------------------
--
-- : The main `view` function takes a `Model`
-- : Our `viewInsideWrapper` need only access the
--   arguments it needs to make things happen!


-- The `<|` operator --

-- An operator that calls a function.
-- These two expressions do exactly the same thing!
--
-- : The <| operator takes a function and another value,
--   and passes the value to the function. That might not sound
--   like it does much, but it’s handy for situations like the
--   one we have here — where an infix operator would look nicer than
--   parentheses.

String.toUpper (string.reverse "hello")  -- parens
String.toUpper <| String.reverse "hello" -- `<|` operator


-- 4.1.2 -----------------------------------------------------------------------

