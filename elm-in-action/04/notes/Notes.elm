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

-- Resolving data dependencies --
--
-- If you change your model, you'll have to make sure any
-- `case` statements or `model.outdated` calls are changed.
-- For instance, `model.selectedUrl` no longer exists!

GotSelectedIndex index ->
  ( { model | selectedUrl = getPhotoUrl index }, Cmd.none )
--            ^^^^^^^^^^

-- We require a new helper function called `selectUrl url status`
-- that `case`s on our `Status` type for it's three branches (see `PhotoGroove.elm`)

-- The `_` underscore placeholder --
--
-- : It is a special placeholder indicating that there is a value here,
--   but we’re choosing not to use it. Attempting to reference `_`
--   in our logic would be a compile error.
--
-- : You can use `_` in case-expression branches as well as in function arguments

a3ArgumentFunction _ _ _ =
  "I ignore all three of my arguments and return string!"


-- SKETCHING OUT REFACTOR OPTIONS ----------------------------------------------
--
-- We no longer hardcoded Photos so need a new approach.
--
-- 1. We delete our photo functions and LET THE COMPILER HELP US
--    to figure out what we do next.
--
-- 2. We look at our options and sketch out possiblities:
--
--    - Create a `photoArray` on the fly?
--    - Randomly pick a photo without `Array.get`?
--
-- There's a function called `Random.uniform` that can help us.
-- This produces a `Random.Generator` that randomly picks one of the
-- `elem` values we passed it. It's called `uniform` because it has the same
-- chance of randomly producing any of the elements. Their probabilities have
-- a _uniform_ distribution.

Random.uniform elem -> List elem -> Random.Generator elem

-- Why does it take both `elem` argument and a `List elem`?
-- Because `List.elem` could be empty, and it would be impossible
-- for `uniform` to pick one element from `[]` empty.
--
-- : Elm's standard libraries don't include a `NonEmptyList` type
--   but functions like this take a _default_ value.
--
-- : So TL;DR: you _must_ supply a default value as well as a `List elem`

