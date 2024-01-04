{-
  Some early playing with the REPL and getting used the syntax.
  So far, it seems like Elm won't give you too many WTF moments:
  : On javascripts quirks, https://github.com/denysdovhan/wtfjs
  : Or, what the fuck is "this" keyword? http://tinyurl.com/5n8z6kyr
-}

-- 1.3.1 -----------------------------------------------------------------------

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


-- Infix -vs- Prefix notation --------------------------------------------------

-- These all work, but might not be considered "normal" in Elm styleguide.
-- It looks kind of funky with operators like `* + - /` (which are actually
-- just functions) as they only accept 2 parameters.
--
--   1 * 2              -- ✅ Regular infix notation
--   (*) 1 2            -- ✅ Infix notation
--   (*) ((*) 1 2) 3    -- ✅ Infix notation with 3 arguments
--
--   (* 1 2 3)          -- Lisp notation
--
--   (*) 1 2 3          -- 🚫 ERROR (Elm won't let you do this)
--   ((*) ((*) 1 2) 3)  -- ✅ FIXED (Elm notation is ugly)
--
-- : In general, it seems best to use `infix` notation for these operators.
-- : As for functions, most in Elm use `prefix` notation, which can be written
--   with or without `()`.

variableParen a b = a * b * c    -- <function>
variableParen 1 2                -- 2 : number
(variableParen 1 2)              -- 2 : number

variableParen a b c = a * b * c  -- <function>
variableParen 1 2 3              -- 6 : number
(variableParen 1 2 3)            -- 6 : number



-- 1.3.2 -----------------------------------------------------------------------

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



-- 1.3.3 -----------------------------------------------------------------------

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



-- 1.3.4 -----------------------------------------------------------------------

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



-- 1.3.5 -----------------------------------------------------------------------

-- Operators like plus and minus can be written in infix style:

2 + 3 + 4 -- ✅ will work
1 / 2     -- ✅ will work
3 * 4     -- ✅ will work

-- Or they can be written in prefix style (like lisp)
-- : You must wrap these in parenthesis with prefix-style notation
-- : 🚫 HOWEVER, they accept (and only 2) operands

(+) 2 3 4 -- 🚫 won't work
(/) 1 2   -- ✅ will work
(*) 3 4   -- ✅ will work

-- You could even name an operator, if you were mad

divideBy = (/)
divideBy 7 2

-- Testing if calculations calculate the same values

3 + 4 == 8 - 1  -- ✅ This looks simple to look at

-- Writing this in `prefix` style looks quite ugly in Elm.
-- : You'd have to wrap the expressions in parenthesis to make sure
--   that `==` only has two arguments.
-- : Figure 1.7 (page 78) shows operator precedence/order (how they're evaluated)

-- In Lisp it's (equal? (+ 3 4) (- 8 1)) — much better.
(==) ((+) 3 4) ((-) 8 1)  -- 🚫 Waaay more confusing

-- Arithmetic operators are `left` associated (evaluate left to right)
-- : 10 - 5 - 1         =>   ((10 - 5) - 1)
-- Nonassociative operators can't be chained like this:
-- : foo == bar == baz  ==>  error



-- 1.4 -------------------------------------------------------------------------

-- Elm Collections --

-- Elm's most basic collections are lists, records and tuples.
-- : Elm collections are ALWAYS immutable (which differs from other languages)
--   Everything from [module] is a function, there's no fields or methods.
-- : See `Table 1.7`: Comparing lists, records and tuples.
--
-- : 1. Lists are good for collections of _varying size_ whose elements share a
--    _consistent type_.
--
--      @ https://elmprogramming.com/list.html
--
--   2. Records let us represent collections of _fixed fields_ with _varied types_.
--
--      @ https://elmprogramming.com/record.html
--
--   3. Tuples are similar to records but add _conciseness_ . Accessed by position,
--      rather than name. "For when you want a record but don't want to bother
--      naming it's fields"
--
--      If I remember right, with Lisp (Racket lang) you use lists when you're
--      unsure of the structure/naming of a data set, then convert it to
--      named `structs` when this is more clear. So lists or tuples might be
--      a good start until the data matures into proper named data structures:
--      @ https://www.grinning-cat.com/post/racket_structures/
--      @ https://beautifulracket.com/explainer/data-structures.html
--
--      @ https://elmprogramming.com/tuple.html


-- Lists --
-- : remember that 'c' is for character, "c" is for string.
-- : https://package.elm-lang.org/packages/elm/core/latest/List

["one fish", "two fish"]

"one fish" :: ["two fish"]     -- I could also write it like this ...
"one fish" :: "two fish" :: [] -- Or like this.

["one fish"] ++ ["two fish"]   -- Or even, like this.

-- : That's a bit like Lisp `(cons 'a '(b c))` or `(cons 'a (cons 'b '()))`

-- : Because it is a linked list, you can ask for its first element,
--   but not for other individual elements. You can't get from index, for instance.
--   You can grab the first part, and the remainder (like Lisp's `first` and `rest`)
--
-- : You can change a list to an array (for index search) but mostly just use lists

someList = [1, 2, 3, 4, 5]
List.head someList  -- Just 1 : Maybe number
List.tail someList  -- Just [2, 3, 4, 5] : Maybe (List number)
someList            -- Returns the original list (it hasn't been mutated!)

-- : 🚫 Every list MUST BE OF THE SAME TYPE!
--
--   in javascript an array can be mixed types, which can f* things up later.
--   For example, what the hell will this javascript snippet return? Who knows?
--
--   [ -2, "0", "one", 1, "+02", "(3)" ].filter(function(num) { return num > 0; })
--
-- : Elm enforces strict types, which is handy with List.filter as we are more
--   careful to use the correct function depending on type (like `withoutDashes` above).

[1, "string", 2, "string"]    -- ERROR
[1, 2, 3, 4]                  -- (List number)
["string", "string"]          -- (List string)

-- Some examples of mapping a list of strings to try and return integers:

String.toInt "1"                       -- Just 1 : Maybe Int
List.map String.toInt ["1", "2", "3"]  -- [Just 1,Just 2,Just 3] : List (Maybe Int)

-- An example of using correct types for the boolean functions:

List.filter (\char -> char /= '-') ['1', '-', 'a']   -- Characters

List.filter (\char -> char /= '-') ["1", '-', 'a']   -- ERROR (mixed str/chars)
List.filter (\str -> str /= "-") ["ZZ", "-", "Top"]  -- Strings

List.filter Char.isDigit ['7', '9', '-']             -- Digits (numbers)
List.filter (\num -> num > 0) [-1, 2, 5, -4, 3]      -- Numbers



-- 1.4.2 -----------------------------------------------------------------------

-- Records --

-- Again, records are _immutable_ — a collection of named fields,
-- like a `key: value` store. The syntax is different to json.
--
-- Difference to javascript:
-- 1. Records use `=` as a seperator, rather than `:`,
-- 2. Fields can be accessed directly,
-- 3. Records cannot be modified (create a new record for changes),
-- 4. Field names can't start with uppercase letters,
-- 5. You can't list field names on demand,
-- 6. There's no concept of inheritance
--
-- : #1 Elm rearranges the position of each field in alphabetical order.

{ name = "Li", cats = 2 }  -- : #1 { cats : number, name : String }

-- Record updates --

-- Elm merges new values with the old, but creates a completely new record
--
-- : 1. Updating values requires `|` pipe. The stuff to the right of pipe gets updated
-- : 2. Note that `name` and `cats` are more like a variable name,
--      not a string (like in json files)
-- : 3. You'll see that `catLover` _isn't mutated_

catLover = { name = "Li", cats = 2 }    -- { cats = 2, name = "Li" }
withThirdCat = { catLover | cats = 3 }  -- { cats = 3, name = "Li" }

withThirdCat                            -- { cats = 3, name = "Li" }
catLover                                -- { cats = 2, name = "Li" }

-- Update multiple fields of record
-- : You'll see that even updating a record with it's original name
--   will only "change" it at this point in time. It hasn't been stored,
--   as `catLover` still remains unchanged.
-- : `catLover | ...` temporarily created a NEW record.
-- : You'd have to _store it in a different name_

-- Returns a changed record but ...
{ catLover | cats = 88, name = "LORD OF CATS"}           
-- Record hasn't changed! (Above useful to see what _would_ happen)
catLover
-- Store in a new named variable
catLoverForReal = { catLover | cats = 88, name = "LOC"}


-- Tuples --

{-| This is a test block
like is used in Elm docs
— looks f* ugly.
|-}

-- Tuples are often used for things like `key: value` pairs. where writing them
-- out (such as a record) would add verbosity but not much clarity.
--
-- : Extracting `first` and `second` can only be used where there are pairs.
-- : If a tuple has 3 elements, you can use _tuple destructuring_.
--   @ https://discourse.elm-lang.org/t/purpose-of-3-tuples/5764/4
--
-- : 🚫 Elm doesn't support Tuples of more than 3 elements.
--   - Use a record instead!!

("Tech", 9)
Tuple.first ("Tech", 9)
Tuple.second ("Tech", 9)

-- A function that takes a tuple of three elements
-- : Destructuring a tuple into three named values
multiply3d (x, y, z) = x * y * z  -- <function>
multiply3d (6, 7, 2)              -- 84 : number

-- 🚫 Attention! These are NOT the same:
-- > multiply x y z = x * y * z
--   <function> : number -> number -> number -> number
-- > multiply (x, y, z) = x * y * z
--   <function> : ( number, number, number ) -> number
--
-- : The first one is a normal function ...
--   The second is a function that takes a tuple!


