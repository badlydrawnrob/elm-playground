module Form.Passport exposing (..)

{-| ----------------------------------------------------------------------------
    Parsing a `String` into a `Passport`
    ============================================================================
    > ⭐ LESSON LEARNED: Keep your programs as simple as possible ...
    > Text editing is difficult! It's hard labour! Parsing text is no joke!
    > As I don't program enough to make it muscle-memory, it's best to avoid
    > handling complicated cases like this. Keep the inputs dumb and simple,
    > let Ai handle it, pick a GUI tool, find a good package to do it, OUTSOURCE!

    For forms:
        - @ https://discourse.elm-lang.org/t/what-is-the-elm-way-to-validate-form-fields/9689
    For files:
        - @ https://package.elm-lang.org/packages/elm/file/latest/

    I'm using @rtfeldman's validation method from Elm Spa example. It's quite
    advanced and there are easier ways to validate. My top-tip when doing forms
    is to use a 3rd party tool, figure out what you need, then build it in Elm.
        - @ https://github.com/rtfeldman/elm-spa-example/blob/master/src/Page/Login.elm


    ⚠️ A checklist for validating
    -----------------------------
    > One data atom per field. Nothing more.
    > Types and code should be as simple as possible!
    > "Do as little code as possible, and fail fast!" - @cscalfani

    The more state and transformations you have to do with your data, the more
    pain it's gonna be. Save the harder tasks for a package or a GUI tool. Or,
    better still — delegate!

    1. Explicit is better than implicit code
    2. Simple and verbose is better than concise and hard-to-read code
    3. Simplify your inputs for an easier life (the "2:00" problem)
        - Keep your inputs as dumb and simple as possible!
        - Text is notorous for spaces, tabs, and newlines, so take care!
        - Pick easy inputs to work with and `String.trim` the ends
        - `List.filter` any empty spaces once you've split your text
    4. Guards at the top!
        - @ https://en.wikipedia.org/wiki/Guard_(computer_science)
    5. Narrow your types (reduce the cardinality of your sets)
        - @ https://guide.elm-lang.org/appendix/types_as_sets
    6. Equality or negative equality is a personal preference
    7. Trust nothing! (defensive programming)
        - How can you reduce the amount of state you'd need to deal with?
        - Or reduce the surface area of errors?
        - The better quality your data, the easier it is to work with.
    8. Do the "just enough" and "just-in-time" thing
        - Wait until a problem crops up, rather than exhaustive error-checking
    9. It's better to return a generic error message, for security
        - "username or password is incorrect" avoids oversharing, which risks a
          brute force hack. It's not necessary in this package.


    Parse, don't validate
    ---------------------
    > Mike doesn't approve of this method; he feels it's not efficient:
    > "Parsing could raise exceptions or errors you could've handled before
    > asking the parsing engine to do it's thing."

    This is an example with the concept "Parse, don't validate" which can be
    found in this article:

        @ https://juliu.is/permutate-parsers/
        @ https://sporto.github.io/elm-patterns/basic/parse-dont-validate.html
        @ https://discourse.elm-lang.org/t/what-is-the-elm-way-to-validate-form-fields/9689

    The basic premise is, rather than returning a `Bool` you want to return the
    actual value, so long as it's valid. If it's not valid, you return a `Nothing`,
    or alternatively, an `Err` or `Error` type.

    Haskell takes this further such as parsec, where we can remove the need for
    intermediary types such as `PassportField`. Other frameworks have built-in
    parsers of sorts, such as FastAPI use Pydantic, where types are used to
    validate data. We're not going to get into any of those here.

    In the below example, I've taken a shortcut and am not implementing the
    `parseEntry` function. I assume all the data entry is ALWAYS correct (which
    is dangerous!) and don't do `case [word] of` ["name:Alex"]` ->
    `(PassportField, String)` as in the article.


    ⚠️ Notes
    --------
    > Text input (and parsing) is a minefield of potential errors.
    > The more complex the input, the more errors you'll have to handle!

    In real-life I'd rarely read from a file or text field in this way. You may need
    to `String.trim` the front and back of a text field, but any text inside would
    be taken verbatim. For this example I'm assuming perfect input, which makes
    our code easier to write:

    1. Assume input is always correctly formatted
        - So we don't need to worry about `Maybe` types, as we would in the
          `case` example to `Maybe (PassportField, String)` in the article.
    2. Assume `String.trim` is never required:
        - This is a dumb assumption, as any `tab` or `space` in front of a line
          from user input will be included in the string.
        - With a real input, fuzz testing would be useful to test against.

    To test how annoying multiline text can be, try adding `"""` and the
    with the next line being a `tab`. Or any `\n` newline will also give us
    an empty space we'd have to trim:

    - It's wise to step through each function with different text inputs to
      see how they output. We're assuming quite a bit here.
    - `"""line\nline"""` would be fine, but any `\n` could result in `("", "")`

-}

import Debug exposing (..)
import Html exposing (Html, text)


-- Dummy input -----------------------------------------------------------------
-- Be careful with multiline strings, any tabs and spaces will be included!

userInput = """
name:Alex age:32 height:200cm number:1234567890

name:Harry age:26 height:180cm
"""


-- Types -----------------------------------------------------------------------

{- You could expand the scope to optional types here -}
type alias Passport =
    { name : String
    , age : Int
    , height : Int
    , number : Int
    }

type PassportField
    = Name
    | Age
    | Height
    | Number


-- Let's combine those types into a handy list ---------------------------------

fieldsToValidate = [ Name, Age, Height, Number ]


-- Let's zip the fields from the `userInput` ------------------------------------
-- Here we're avoiding `Maybe` types for brevity, but they could be useful to
-- make sure that `userInput` is the correct format.

splitPassports : String -> List String
splitPassports =
    String.lines >> List.filter ((/=) "") -- #! `String.trim` may be required!

splitWords : String -> List String
splitWords =
    String.words -- #! `>> List.filter ((/=) "")` isn't needed here?

splitField : String -> (String, String)
splitField str =
    case String.split ":" str of
        [a,b] -> (a,b)
        _ -> ("","") -- #! This should never happen

zipFields : List String -> List (String, String)
zipFields =
    List.map splitField

getPassports : String -> List (List (String, String))
getPassports =
    splitPassports >> List.map splitWords >> List.map zipFields


-- Update ----------------------------------------------------------------------
-- Our simplified code means zero `Maybe`s to deal with (see Notes), we can use
-- @rtfeldman's technique here to check errors for `PassportField` types. This
-- treats every field as a dumb `String`.


-------------------------- STOP!!! ---------------------------------------------
-- Sketch the problem out. This is different from the Elm Spa example as our  --
-- input is a list of strings, not a record. That makes life a little bit     --
-- difficult! The original article uses a `(PassportField, String)` tuple      --
-- which is easier to case over and check our `String` for errors.            --
--------------------------------------------------------------------------------
-- 1. Understand `List.concatMap` better
-- 2. Figure out the easiest route (extract each list item -> validateField)
--    It might be as easy as `List.map (List.concatMap ...)`
-- 3. Ideally you want to start simplifying your code down, so that these kind
--    of complex problems (which you don't have the muscle memory to solve)
--    never crop up, or you hand over the job to a package or black-box solution.

-- validate : (List (String, String)) -> Result (List Problem) Passport
-- validate lst =
--     case List.concatMap (validateField lst) fieldsToValidate of
--         [] ->
--             Ok
--                 { name = "Alex"
--                 , age = 32
--                 , height = 200
--                 , number = 1234567890
--                 }

--         problems ->
--             Err problems

-- validateField : (String, String) -> PassportField -> List Problem
-- validateField input field =
--     case field of
--         Name ->
--             case


-- Main ------------------------------------------------------------------------

main : Html msg
main =
    text <| Debug.toString (getPassports userInput)
