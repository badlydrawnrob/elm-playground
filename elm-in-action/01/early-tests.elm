{-
  Some early playing with the REPL
  and getting used the syntax
-}

-- 1.3.1

-- Testing for plurality
-- are there 1 or many elves?
-- : there's a nested `if` statement below

if elfCount == 1 then
  "elf"
else if elfCount >= 0 then
  "elves"
else
  "anti-elves"

-- Converting the above into a function

isPositive num = num > 0

isPositive 2  -- True
isPositive 0  -- False
isPositive -1 -- False

-- Refactoring our `if` statement with a function

pluralize singular plural count =
  if count == 1 then singular else plural

pluralize "elf" "elves" 3           -- "elves"
pluralize "elf" "elves" (round 0.9) -- "elf"



-- 1.3.2

-- The string module houses the functions specific to "strings"
-- each function set is split into it's own type (i.e: Set)

String.toLower "Why don't you make it LOWER?"
String.toUpper "Why don't you make it upper?"
String.fromFloat 44.1 -- "44.1"
String.fromInt 531    --"531”

String.length "the length of this string"
String.fromChar 'a' -- "a"

-- Using filter (see also filter in [lisp](https://www.youtube.com/watch?v=7bKn9T-35mk))
-- an example of a _higher order function_ — functions that accept functions as an argument
--
-- : SICP: remember a lambda function is just an unamed function.
-- : `/=` is the same as `!=` — "is not equal to"
-- : It doesn't seem that `?` is allowed in function names, like lisp (that's a shame)

isKeepable? char = char /= '-'

String.filter isKeepable "800-555-1234" -- strips all '-' characters


-- 1.3.3

-- Creating a reusable function, but keeping `isKeepable` in local scope,
-- meaning the function only works within it's parent function ...
-- : 🚫 Don't name functions twice, it'll throw an error!

withoutDashes string =
  let
    dash = '-'
    isKeepable character = character /= dash
  in
    String.filter isKeepable string

withoutDashes "800-555-1234"


-- 1.3.4

-- Introducing anonymous functions (y'know, lambdas λ). In lisp you can use the
-- word `lambda` or symbol `λ` to "name" your function, but a `\` in Elm lang.
--
-- 1. They have no names.
-- 2. They begin with a \ symbol.
-- 3. Their parameters are followed by a -> symbol instead of an = symbol.”
--
-- : #1: named function (uses `=`)
-- : #2: unnamed (anonymous) function (note the `->` difference)

area width height = width * height  -- #1
\width height -> width * height      -- #2
