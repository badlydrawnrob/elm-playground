{-| What we're trying to achieve:

    - Improve code quality to help new team members get up to speed.
    - Let users choose between small, medium, and large thumbnails.
    - Add a Surprise Me! button that randomly selects a photo.
|-}

-- 3.1 -----------------------------------------------------------------------

-- Compiler as assitant --
-- We can rely on the compiler to help us with Type annotations etc
--
-- | Code never lies. Comments sometimes do.
-- | — Ron Jeffries
--
-- : It's important to keep comments concise, to-the-point, accurate
--   and up-to-date. It's easy to let them become stale.
--
-- : Type annotations don't lie. They'll HAVE TO BE relevant
--   and up-to-date or the compiler will complain!
--
-- : Elm’s compiler will check our entire code base to make sure
--   our Type annotations are telling the truth! That goes for the
--   original variable, as well as any functions that use that
--   variable.


-- 3.1.1 -----------------------------------------------------------------------

-- Type annotations --
-- Depending on language, these can be both good and bad:
-- @ https://realpython.com/lessons/pros-and-cons-type-hints/
-- @ https://www.micahcantor.com/blog/thoughts-typed-racket/

-- It's as simple as:
-- : #! Error in the book: `photoListUrl` should be
--   `urlPrefix`
urlPrefix : String
urlPrefix =
  "http://elm-in-acdtion.com/list-photos"

-- And for functions, we use the `->` between their
-- arguments and return values.
isEmpty : String -> Bool
isEmpty srt = str == ""

-- Here's how to annotate a _record_
selectPhoto : { description : String, data : String }
selectPhoto = { description = "ClickedPhoto", data = "1.jpeg" }

-- A list remember, must all be of _the same type_
--
-- : List String
-- : List Bool
-- : List number
-- : List Float
--
-- More complicated lists, have type annotations like so:

[ ["thanks", "for"], ["all", "the", "fish"] ]
-- : List (List String)
[ ["this", "is", "a"], [1, 2, 3] ] -- ERROR!
-- Remember: a list _must be the same type!_
[ ["this", "is", "a"], [String.fromInt 1, String.fromInt 2] ]
-- [["this","is","a"],["1","2"]]
--   : List (List String)
[ { url = "string"}, { url = "string"} ]
-- : List { url : String }


-- 3.1.2 -----------------------------------------------------------------------

-- Lists and Arrays --
-- Both are sequential collections of varying length
--
-- : How Arrays differ from lists, and are they better or worse?
--
--   ❌ List perform better than Arrays so they're the standard
--     (which is different to JavaScript)
--   ❌ Arrays have no literal syntax in Elm
--   ✅ We always create arrays by calling functions
--   ✅ Arrays are better for arbitrary positional access
--
--   @ https://elmprogramming.com/array.html
--   @ http://tinyurl.com/elm-lang-list-vs-array
--
-- : Obviously `Array.fromList`s Type will depend on what you pass it:

import Array

Array.Array.fromList [ 2, 4, 6 ]          -- : Array.Array number
Array.Array.fromList ["dog"]              -- : Array.Array String
Array.Array.fromList []                   -- : Array.Array a
Array.Array.fromList [{ url = "string"}]  -- Array.Array { url : String }


-- Importing the Array module properly -----------------------------------------
--
-- ❌ Importing Array without the `exposing` bit
-- ✅ Importing Array with the `exposing` bit:
--    (we can write it in a simpler way!)
import Array exposing (Array)

Array.fromList [ 2, 4, 6 ]  -- Array number


-- We can use the following pattern in a type annotation:
fromList : List elementType -> Array elementType

-- Type Variables --
-- `elementType` is a _type variable_ ...
--
-- : A type variable represents more than one possible type.
-- : Type variables have lowercase names, making them
--   easy to differentiate from concrete types like String,
--   which are always capitalized.
-- : You must be consistent with naming type variables.
--
--   @ http://tinyurl.com/elm-lang-type-variables
--
-- : A custom type -vs- type variable?
--   @ http://tinyurl.com/elm-lang-on-type-variables



-- 3.1.3 -----------------------------------------------------------------------

-- Reusing annotations with type aliases --
--
-- : We can reduce duplication, at the moment both `initialModel`
--   and `photoArray` repeat `{ url : String }`

initialModel : { photos : List {url : String}, ..}
photoArray : Array {url : String}

-- : A _type alias_ assigns a name to a type. Anywhere you would
--   refer to that type, you can substitute this name instead.
-- : Let's give `{url : String}` a type alias called `Photo`
--
--   @ https://guide.elm-lang.org/types/type_aliases

type alias Photo =
  { url : String }

initialModel : .. List Photo ..
photoArray : Array Photo

-- Html's type variable --
--
-- : Html’s type variable reflects the type of message
--   it sends to update in response to events from handlers
--   like `onClick`.

-- Comparing type variables for `List` to `Html`:

[ "foo" ]                    -- List String
[ 3.14 ]                     -- List Float

div [ onClick "foo" ] []     -- Html String
div [ onClick 3.14 ] []      -- Html Float
dive [ onClick { x = 3.3 }]  -- Html { x : Float }

-- : Because our `onClick` handler produces messages in the form of
--   records that have a `description` string and a `data` string,
--   our `view` funcdtions return type is as follows:

Html { description : String, data : String }

-- Or convert that into a Type Annotation:

type alias Msg =
  { description : String, data : String }


-- View, model, update, and message --------------------------------------------
--
-- See Racket Lang's _Big Bang_:
--
-- @ http://tinyurl.com/racket-lang-tick-and-handlers
--
-- : `(to-draw ...)` is basically `View`
-- : `(on-tick tock)` isn't relevant (yet)
-- : `(on-mouse click)` is our event handler, like `onClick`
--
-- : In some of the projects I worked on you'd have conditionals that would
--   handle a click event, or a key event, and return a model (e.g: a struct)
--   to update the World.


-- 3.1.4 -----------------------------------------------------------------------

-- Annoting longer functions --
-- : #1 Taking a simple function
String.padLeft 10 '.' "string"  -- "....string" : String

-- : #2 Now break that function down by currying
padTen = String.padLeft 10

-- : #3 We know that this will return another function
--   which takes two arguments, innit? But let's stick
--   with the curried concept. So this:
padTen -- <function> -> Char -> (String -> String)

-- : #4 Says we return a function that takes a `Char`
--      and returns another function!
giveMeString = padTen '.'

-- : #5 This will return a function that takes a `String`
--      and, in turn, returns a String:
giveMeString  -- <function> String -> String

-- : #6 And finally, we pass the last argument
giveMeResult = giveMeString "string" -- "....string"

-- So putting that all together, you get:
function : Int -> Char -> String -> String
String.padLeft 10 '.' "string"

-- Or .. with brackets, something like:
function : Int -> (Char -> (String -> String))


-- 3.2 -------------------------------------------------------------------------
-- 3.2.1

-- Using case-expressions --
--
-- : An `if` condition can be converted to `case`
--   but better use for nested `if` statements ...
--
-- @ http://tinyurl.com/elm-lang-case-vs-if-else

sillyError = "http://elm-in-action.com"

-- Stick with `if` ...
isSillyError string =
  if string == "http://elm-in-action.com" then
    "You made a silly error!"
  else
    string

-- Convert to `case`
isSillyError string =
  if string == "http://poop.com/" then
    "Wrong url"
  if string == "http://elm-in-action.com" then
    "Missing trailing slash (/)"
  else
    string

isSillyError string =
  case string of
    "http://poop.com" -> "Wrong url"
    "http://elm-in-action.com" -> "Missing trailing `/`"
    _ -> string


-- 3.2.2 -----------------------------------------------------------------------

-- Custom Type with options --

-- In Javascript we might represent `chosenSize` as a string.
-- : i.e. `"SMALL"`, `"MEDIUM"`, "LARGE".
--
-- : NO, NO, NO, NO!!
--   We can do better in Elm ...
--
-- A Custom Type is one you define by specifying the values it can contain.
-- This is a BRAND NEW TYPE and not just a type alias (like a name for an `int`)
--
-- : ❌ Trying to compare a `ThumbnailSize` to a `number`, `string`,
--   or any other type (using == or any other comparison) will
--   yield an error at build time.
--
-- : ✅ When using a `case` expression for a Thumbnail size, it can only ever be
--   one of three branches, as there's only 3 available things a `ThumbnailSize`
--   can ever be.
--
-- : This is different from type alias, which gives a name to an
--   existing type—much as a variable gives a name to an existing value.
--
--   @ https://elmprogramming.com/type-system.html

type ThumbnailSize
  = Small   -- each
  | Medium  -- of these
  | Large   -- is a variant

Medium == Medium  -- True
Medium == 10      -- False
Medium == Small   -- False


-- Reducing duplication --
-- Any time we see the same function being called multiple times,
-- in a list, it's likely we can make that cleaner with `List.map`

div [ id "choose-size" ]
[ viewSizeChooser Small, viewSizeChooser Medium, viewSizeChooser Large ]

-- Make it cleaner!

div [ id "choose-size" ]
(List.map viewSizeChooser [ Small, Medium, Large ] )



-- 3.2.3 -----------------------------------------------------------------------

-- Problems to be solved --
--
-- : #1 We have a `[]` list of `Photo` records
--
--      - In Javascript we could access with index `photos[2].url`
--      - ❌ What happens if the list changes?
--
--          1. Our list could be empty
--          2. Our list could have fewer entries
--          3. Our list could be really long
--
-- : #2 ✅ `Array.get` helps with our problem:
--
--       - It NEVER returns `undefined` or `null`
--       - `Array.get` doesn't use the index
--       - `Array.get` _always_ returns a container
--         value called `Maybe`
--
-- : #3 `Maybe` is implemented as a custom type, but a special kind of
--      custom type. One that holds data. A `Maybe` is a _container_ like `List`.
--      It looks like this:
--
--      @ http://tinyurl.com/elm-lang-maybe-dont-overuse
--
--      (Note the type variable `value` below.)

type Maybe value
  = Just value
  | Nothing

-- Why use `Maybe`? --
-- It represents the potential absence of a value. It provides a _container-based_
-- alternative to Javascripts _drop-in replacements_ of `null` and `undefined`.
--
-- : See `Figure 3.6` for a comparison.

photos = Array.fromList [ a, b, c, d ]

Array.get 2 photos  -- Just c
Array.get 2 []      -- Nothing

-- So if the index 2 is outside it's bounds (doesn't exist) then
-- `Array.get` will return Nothing.

-- `Maybe` as a container --
--
-- Just as you can have a `List String` or a `List Photo`,
-- you can also have a `Maybe String` or `Maybe Photo`.
-- The difference is that whereas List Photo means “a list of photos,”
-- `Maybe Photo` means “either a Photo or nothing at all.”
--
-- Put another way, `Maybe` is a container that can hold at most one element.

Nothing        -- Nothing : Maybe a

Just           -- <function> : a -> Maybe a
Just "string"  -- Just "string" : Maybe String


-- Destructuring `Just` function --
-- “A capital question! The answer is right around the corner.
--
-- : Before, we destructured a function that had a tuple as it's arguments.
--   As it turns out, we can also destructure custom type variants such
--   as Just in the branches of case-expressions. This destructuring is what
--   sets variants apart from other functions.
--
-- : #1 Index is an `int`, but the `List` could contain any number
-- : #2 Destructuring `Just` and naming it's contained value "age"
-- : #3 Fall back on "0" if there was no `age` at that index.

numberList = [1, 2.0, 3.3, 4]
numberArray = Array.fromList numberList

aCustomTypeVariant : Int -> Float  -- #1
aCustomTypeVariant index =
  case Array.get index numberArray of
    Just age ->                         -- #2
      age
    Nothing ->
      0

aCustomTypeVariant 2  -- 3.3 : Float
aCustomTypeVariant 0  -- 0 : Float


-- Capitalized or not capitalized? --
--
-- This is where the distinction between capitalized and uncapitalized functions
-- matters. By comparing their capitalizations, Elm’s compiler can tell that
-- `Just photo ->` refers to a _type variant_ called `Just` that holds a value
-- we've chosen to name `photo`. If we'd instead written `Just True ->`,
-- the compiler would know we meant “the Just variant holding exactly the
-- value True.”


-- Indentation: 2 or 4 spaces? -------------------------------------------------

aCustomTypeVariant : Int -> Float
aCustomTypeVariant index =
  case Array.get index numberArray of
    Just age ->
      age
    Nothing ->
      0

anotherCustomTypeVariant : Int -> Float
anotherCustomTypeVariant index =
    case Array.get index numberArray of
        Just age ->
            age
        Nothing ->
            0
