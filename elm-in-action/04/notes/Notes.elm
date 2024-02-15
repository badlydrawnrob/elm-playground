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


-- Case expression: Pattern Matching -------------------------------------------
--
-- Pattern matching is a way of destructuring values based on how their
-- containers look. In the example, if we have a `GotPhotos` containing
-- an `Ok` containing a `value`, that value will go into a variable called
-- `responseStr`.

case msg of
  ...
  GotPhotos (Ok responseStr) ->
    ...
  GotPhotos (Err _) ->
    ( model, Cmd.none )

case list of
  (first :: rest) ->  -- 1 :: [2,3]
    someFunction first rest  -- 1 [2,3]


-- Commands --------------------------------------------------------------------

-- Making initial Cmd Msg --
--
-- We'll use this `initialCmd` value to run our HTTP request when
-- the program starts up.
--
-- The type of initialCmd:
--
-- Why does `initialCmd` have the type `Cmd Msg`?
-- Let’s look at the type of Http.get again:
--
-- `Http.get : { url : String, expect : Expect msg } -> Cmd msg`
--
-- Because `msg` is lowercase, it’s a `type variable` like the ones
-- we saw in chapter 3. This means whatever flavor of Expect we pass to
-- `Http.get`, we’ll get the same flavor of `Cmd` back.
--
-- Their type parameters will necessarily be the same!
--
-- How can we tell what Expect’s type parameter will be in this expression?
-- Let’s dig one level deeper and look at `Http.expectString` again:
--
-- `Http.expectString : (Result Http.Error String -> msg) -> Expect msg`
--
-- Once again we see a type variable called msg. So the Expect will be
-- parameterized on whatever `type` we return from the
-- `(Result Http.Error String -> msg)` function we pass to
-- `Http.expectString`. In our case, that would be this anonymous function:
--
-- `Http.ExpectString (\result -> GotPhotos result)`
--
-- Because that function returns a `Msg`, the call to `Http.expectString`
-- will return an `Expect Msg`, which in turn means `Http.get` will return
-- `Cmd Msg`.

initialCmd : Cmd Msg
initialCmd =
  Http.get
    { url = "http://link.com/to/images"
    , expect = Http.expectString (\result -> GotPhotos result)
    }

-- Simplifying `initialCmd` --
--
-- This will compile, but we can simplify it. Back in section 2.2.1
-- of chapter 2, we noted that an anonymous function like
-- `(\foo -> bar baz foo)` can always be rewritten as `(bar baz)`
-- by itself (a partially applied function).
--
-- This means we can replace `(\result -> GotPhotos result)`
-- with `GotPhotos` like so:

initialCmd : Cmd Msg
initialCmd =
  Http.get
    { url = "http://link.com/to/images"
    , expect = Http.expectString GotPhotos -- curried function:
    }                                      -- the string will get
                                           -- passed to GotPhotos _



-- 4.3 -------------------------------------------------------------------------
-- 4.3.1 -----------------------------------------------------------------------

-- The Json.Decode.decodeString function --
--
-- Has many functions for different types of primitives:
--   `decodeString (bool | string | int | float) value`
-- `undefined` is NOT allowed.
--
-- : `decodeString bool "true"
--
-- : A table showing what will return:

decodeString : Decoder val -> String -> Result Error val

-- Decoder passed in  | Returns                 | Example success value
-- -------------------|-------------------------|------------------------
-- Decoder Bool       | Result Error Bool       | Ok True
-- Decode String      | Result Error String     | Ok "Win!"
-- Decoder (List Int) | Result Error (List Int) | Ok [1, 2, 3]

decodeString bool "true"
-- Ok True : Result Error Bool
decodeString bool "false"
-- Ok False : Result Error Bool
decodeString bool "42"
-- Err (Failure ("Expecting a BOOL") <internals>) : Result Error Bool
decodeString float "3.33"
decodeString int "76"
decodeString string "\"backslashes escape quotation marks\""


-- Arrays --
--
-- Whereas bool is a decoder, list is a function that takes
-- a decoder and returns a new one.

bool : Decoder bool
list : Decoder value -> Decoder (List value)

list bool
-- <internals> : Decoder (List Bool)


-- Decoding objects ------------------------------------------------------------
--
-- The simplest way to decode an object is with the
-- field function. When this decoder runs, it performs
-- three checks:
--
-- 1. Are we decoding an `Object`?
-- 2. If so, does that `Object` have a field called `email`?
-- 3. If so, is the `Object`s `email` field a `String`?
--
-- If all three are true, then decoding succeeds with the
-- value of the `Object`’s email field.

-- JSON
-- 5                           -- Err ... (not a field)
-- {"email": 5}                -- Err ... (not a string)
-- {"email": "cate@nolf.com"}  -- Ok "cate@nolf.com"

decoder : Decoder String
decoder =
  field "email" string


-- Decoding multiple fields ----------------------------------------------------
--
-- The simplest way is using a function like `map2`

-- JSON
-- {"x": 5}            -- Error ... (y was missing)
-- {"x": 5, "y": null} -- Err ... (y was null, not int)
-- {"x": 5, "y": 12}   -- Ok (5, 12)

  map2
    (\x y -> (x, y))
    (field "x" int)
    (field "y" int)


-- Decoding many fields --------------------------------------------------------

-- The photo information we'll be getting back from our server
-- will be in the form of JSON that looks like this:

-- JSON
-- {"url": "1.jpeg", "size": 36, "title"}
--
-- : An object with 3 fields — use `map3`!
-- : `map8` is as high as it goes.

type alias Photo =
  { url : String
  , size: Int
  , title : String
  }

photoDecoder : Decoder Photo
photoDecorder =
  map3
    (\url size title -> { url = url, size = size, title = title })
    (field "url" string)
    (field "size" int)
    (field "title" string)


-- Decoding with pipeline ------------------------------------------------------
-- requires `NoRedInk/elm-json-decode-pipeline`

photoDecoder : Decoder Photo
photoDecoder =
  succeed buildPhoto
    |> required "url" string
    |> required "size" int
    |> optional "title" string "(untitled)"  -- default value

buildPhoto : String -> Int -> String -> Photo
buildPhoto url size title =
  { url = url, size = size, title = title }


-- Let's break that down --

succeed : a -> Decoder a
buildPhoto : String -> Int -> String -> Photo

-- putting them together --

Decoder (String -> Int -> String -> Photo)

-- That does (almost) nothing by itself, so ... --
-- Adding a `required` field succeed if (and only
-- if) we give it a JSON object with a field
-- called `url` that holds a `string`.

functionDecoder : Decoder (Int -> String -> Photo)
functionDecoder =
  succeed buildPhoto
    |> required "url" string

-- before:
--   Decoder (String -> Int -> String -> Photo)
-- after:
--   Decoder (          Int -> String -> Photo)

-- This decoder also has a different type than the
-- `succeed Photo` one did (it's shrunk by one argument)

-- Adding more fields in this method eventually shrinks
-- our `Decoder (String -> Int -> String -> Photo)` down
-- to a `Decoder Photo`!


-- You don't actually need `buildPhoto`!! --------------------------------------

-- A type alias also gives us a `Photo` function
-- for free! If we supply it with arguments, it'll
-- construct a record (of type `Photo`) for us!

type alias Photo =
  { url : String
  , size : Int
  , title : String
  }

-- So we can call it like this:

-- > Photo
-- <function> : String -> Int -> String -> Photo

-- And create it like this:

-- > Photo "http://somewhere.com" 3 "some photo"
-- { size = 3, title = "some photo", url = "http://somewhere.com" }
--    : Photo


-- Warning!!! ------------------------------------------------------------------

-- Reordering any function’s arguments can lead to unpleasant
-- surprises. Because reordering the fields in the `Model` type
-- alias has the consequence of reordering the `Model` function’s
-- arguments, you should be exactly as careful when reordering
-- a `type alias` as you would be when reordering any
-- function’s arguments!



-- 4.3.3 -----------------------------------------------------------------------

-- Beware of naming errors! --
--
-- Sometimes if you `import` two modules that share similar
-- naming conventions, such as `Json.Decode.Pipeline.required` and
-- `Html.Attributes.required` you'll run into errors.
--
-- 1. Use the `as` keyword (and name it as `Decode` for example)
-- 2. Be more specific in your `exposing` such as `(href)`.

-- Error --
--
-- I recommend using qualified names for imported values. I also recommend having
-- at most one `exposing (..)` per file to make name clashes like this less common
-- in the long run.


-- Http.ExpectJson -------------------------------------------------------------

-- You can use `Http.get` with a `expectJson` (instead of a
-- `expectString`) which will decode things for you right away.
--
-- : See `tests/http-get-json` for examples.
-- : `expectJson` accepts a `Decoder val` and on success produces
--   an `Ok val` result instead of an `Ok String` (which means simpler `case`)

expectString : (Result Http.Error String -> msg)                -> Expect msg
expectJson   : (Result Http.Error val    -> msg) -> Decoder val -> Expect msg


-- When decoding fails --
--
-- We'll have to `case` on the following with a `handleError` function.

type Error
  = BadUrl String
  | Timeout
  | NetworkError
  | BadStatus Int
  | BadBody String  -- JSON fails to decode


-- Http.request --
--
-- This allows you a finer grain of detail on your
-- requests and error messages, should you need it:
--
-- @ http://tinyurl.com/elm-lang-http-request
