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
--   a function can also return a non-empty list using a Tuple:
--   `( elem, List elem )`


-- We're now randomly generating a `Photo` (not an `Index` number) -------------
--
-- : Our message type changes from `GotSelectedIndex`
--   to `GotSelectedPhoto` (which is a `Photo` type).

| GotRandomPhoto Photo


-- Preparing for all cases! ----------------------------------------------------
--
-- Loading is self explanatory (show a spinny icon)
-- Errored just holds an error `String`
-- What about `Loaded`?
--
-- `Loaded (List Photo) String` could be in two states:
--
-- 1) Loaded with an `[]` empty list
-- 2) Loaded with [{url = "1.jpeg"}] a single item
-- 3) Loaded with many items
--
-- `Random.Uniform` allows us to set a default if the list only has one item,
-- so that's got us covered, but `(first :: last)` will error out if there's
-- nothing in the list.
--
-- : We need to `case` on the empty list!!

type Status
  = Loading
  | Loaded (List Photo) String
  | Errored String


-- We do this in the `ClickedSurpriseMe` button `case`
-- We do this in the `update` function (it's a `Msg`)
-- We do this with `[] ->` pattern matching

type Msg
  = ...
  | ClickedSurpriseMe

-- in `update`
ClickedSurpriseMe ->
  case model.status of
    Loaded [] _ ->
      -- There's nothing in the list ...
      -- DO SOMETHING with that case!
    Loaded (first :: rest) _ ->
      -- do something
    Loading ->
      -- do nothing (return `status`)
    Errored errorMessage ->
      -- do nothing (return `status`)


-- Using the pipeline operator --
--
-- Remember, this is only possible because Elm allows you to do partial
-- functions (functions that return a function when not given all the arguments)
--
-- 1) Call Random.uniform firstPhoto otherPhotos.
-- 2) Pass its _return value_ as the final argument to Random.generate GotRandomPhoto.
-- 3) Pass that _return value_ as the final argument to Tuple.pair model.


-- Lisp style --

Tuple.pair model
  (Random.generate GotRandomPhoto
    (Random.uniform firstPhoto otherPhotos))

-- Elm Pipline style --

Random.uniform firstPhoto otherPhotos
  |> Random.generate GotRandomPhoto
  |> Tuple.pair model



-- 4.2 -------------------------------------------------------------------------

-- 4.2.1 -----------------------------------------------------------------------

-- No side-effects! --
--
-- : An effect is an operation that modifies external state.
--   A function that modifies external state when it executes
--   has a side effect.
--
-- : Our code can explain what effects to perform, but all side-effects
--   are handled by the Elm Runtime. When you return a new Model with `update`,
--   it's not the `update` function directly alters state, but the Runtime.
--
-- : This is called _"Managed Effects"_.

-- HTTP request --
--
-- We'll use `Cmd` to tell Elm Runtime to perform and effect,
-- like we did with `Random`. When this `Cmd` is complete, it
-- will send a `Msg` to `update` to tell us what happened.
--
-- 1) Send an HTTP GET request to http://manning.com.
-- 2) I expect to get back a String for the response.
-- 3) When the response comes back, use this toMsg function to translate it into a Msg.
-- 4) Send that Msg to update.
--
-- (see Figure 4.2)
--
-- : There's a lot that can go wrong with a HTTP request,
--   so if it fails we'll want to know what went wrong.
--   `Http.expectString` uses a `Result` for this. It's a little
--   similar to `Maybe` in that it can return an `Ok` or an `Error`.
--
-- : The `errValue` or the `okValue` could be any type (it's a type variable)
--   so if we asked for a `string` that's what we'd get back.
--   If we asked for `json` — that's what we'd get back (or an error message).

Http.get : { url : String, expect : Expect msg } -> Cmd msg

type Result errValue okValue
  = Err errValue
  | Ok okValue

expectString : (Result Http.Error String -> Msg) -> Expect msg
get          :             { url : String, expect : Expect msg } -> Cmd msg


-- In our `GotPhotos result ->` result case --
-- Which is a new `Msg` type variant ...
--
-- 1. Case on `Ok` and `Error`
-- 2. If `Ok` generate `List Photo`
-- 3. If `Ok` change the `model.status`

GotPhotos result ->
  case result of
    Ok responseStr
      -- Ok will be a String
      -- in a `let` split string with ","
      --   next generate `{ url = "1.jpeg" }`
      --   i.e: List Photo
      --   Grab the first in `List`
      -- `in`
      --   store in `Loaded _ _` as `model.status`


-- `List.head` vs `(firstUrl :: _)` --
--
-- to get around the `Maybe` problem (having to write a `case`
-- statement to account for an empty list) we can do like this:
--
-- : The as urls part of this pattern means
--   “give the name `urls` to this entire List,
--   while also subdividing it into its first element
--   (which we will name firstUrl) and its remaining elements,
--   which we will decline to name by using the _ placeholder.


case list of
  (firstUrl :: _) as urls ->
    aListFunction firstUrl url  -- Returns something

-- Alternatively ...
(firstUrl :: _) as urls ->
  urls -- Simply recreates the original list
       -- because `1 :: [2, 3, 4]` -> `[1, 2, 3, 4]`

-- TIP: You can also use as when destructuring function arguments.
--      For example, `doSomethingWithTuple (( first, second ) as tuple) = ...`
--      or perhaps `doSomethingWithRecord ({ username, password } as record) = ...`



-- 🎯 DESIGN DECISIONS ----------------------------------------------------------

-- A NON-EMPTY LIST
--
-- Because we now know our `List Photo` in the `Loaded` variant
-- will never be empty, we could change the type of Loaded to hold
-- a non-empty list instead of a `List Photo`.
--
-- : For example, its type could be `Loaded Photo (List Photo) String`.
--   We won’t make that change here, but try it out if you have time.”



-- Using TYPE ALIAS to create records ------------------------------------------
--
-- Declaring `type aliad Photo = { url : String }` does more than give
-- us a `Photo` type we can use in type annotations. It also gives us a
-- convenience function whose job is to build `Photo` record instances.
--
-- : This function is also called `Photo`!

type alias Photo
  = { url : String }

Photo
-- <function> : String -> Photo

Photo "1.jpeg" == { url = "1.jpeg" }

type alias ThumbnailSize
  = Small
  | Medium
  | Large

type alias Model =
    { status : "string"
    , chosenSize : ThumbnailSize
    }

Model
-- <function> : String -> ThumbnailSize -> Model

Model "working" Small
-- { chosenSize = Medium, status = "someone" }
--    : Model





