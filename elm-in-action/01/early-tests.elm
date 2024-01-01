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

area width height = width * height   -- #1
\width height -> width * height      -- #2

-- Anonymous functions can be used much in the same way as named ones:
--
-- Why should I use an anonymous function?
-- : Useful for one-off, or small functions that don't need accessing elsewhere
-- : - https://docs.racket-lang.org/plait/lambda-tutorial.html

ditchCharacter char = char /= '*'
ditchCharacter = \char -> char /= '*'

-- Let's improve our business logic, and shorten the String function!
-- We'll also use a new function and ban all non-digit characters.
-- : @ https://package.elm-lang.org/packages/elm/core/latest/Char

String.filter (\char -> char /= '-') "800-555-1234"
String.filter (\char -> char /= '-') "(800) 555-1234"

String.filter (\char -> Char.isDigit char) "(800) 555-1234" -- Anon function
String.filter Char.isDigit "(800) 555-1234"                 -- RRr! Simpler.

-- Let's have a quick mess around and return only numbers of 1
-- : String.filter takes any Boolean function and returns if True.

anonCharFunction = \char -> char == '1'
String.filter (\char -> anonCharFunction char) "(800) 135-2311"

-- : Alternatively we could've just written that like this:
String.filter (\char -> char == '1') "(800) 135-2311"

