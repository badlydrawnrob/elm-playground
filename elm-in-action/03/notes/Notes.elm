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

-- Reusing annotations with type aliases
-- : We can reduce duplication, at the moment both `initialModel`
--   and `photoArray` repeat `{ url : String }`
initialModel : { photos : List {url : String}, ..}
photoArray : Array {url : String}
-- : A _type alias_ assigns a name to a type. Anywhere you would
--   refer to that type, you can substitute this name instead.
-- : Let's give `{url : String}` a type alias called `Photo`
type alias Photo =
  { url : String }

initialModel : .. List Photo ..
photoArray : Array Photo
