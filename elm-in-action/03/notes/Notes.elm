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
photoListUrl : String
photoListUrl =
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


