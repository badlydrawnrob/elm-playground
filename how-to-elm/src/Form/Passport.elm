module Form.Passport exposing (..)

{-| ----------------------------------------------------------------------------
    Parsing a `String` into a `Passport`
    ============================================================================
    It's HIGHLY unlikely I'll ever need to implement something so difficult. I'm
    not in the habit of parsing text, and would let Ai handle this. However,
    you could use this with a form, or a file import:
        @ https://package.elm-lang.org/packages/elm/file/latest/

    I've take a shortcut here, I'm not implementing the `parseEntry` function.
    Instead, I'm using @rtfeldman's validation method. This assumes input is
    always correctly formatted (dangerous!), but you can find the original
    article here:
        @ https://juliu.is/permutate-parsers/ (`case [word] of` ["name:Alex"])


    ⚠️ Warnings
    -----------
    > I want ONE data atom per field. Nothing more.
    > I want my types and my code as simple as possible!
    > As @cscalfani says, "do as little code as possible, and fail fast"

    The original article is practically a text editor, which is difficult. If I'm
    parsing raw text, I want a tool to do that for me! It's hard labour.

    Also, Mike doesn't approve of this method; he feels it's not efficient:
    "Parsing could raise exceptions or errors you could've handled before
    asking the parsing engine to do it's thing."

    Here is a checklist for any validation functions you write:

    1. Explicit is better than implicit code
    2. Simple and verbose is better than concise and hard-to-read code
    3. Simplify your inputs for an easier life (the "2:00" problem)
        - Text is notorous for spaces, tabs, and newlines
        - The easiest inputs to work with, and `String.trim` or `List.filter`
    4. Guards at the top
        - @ https://en.wikipedia.org/wiki/Guard_(computer_science)
    5. Narrow your types (reduce the cardinality of your sets)
        - @ https://guide.elm-lang.org/appendix/types_as_sets
    6. Equality or negative equality is a personal preference
    7. Trust nothing! (defensive programming)
    8. Do the "just enough" and "just-in-time" thing
        - Wait until a problem crops up, rather than exhaustive error-checking
    9. It's better to return a generic error message, for security
        - "username or password is incorrect" avoids oversharing, which risks a
          brute force hack. It's not necessary in this package.


    Parse, don't validate
    ---------------------
    This is an example with the concept "Parse, don't validate" which can be
    found in this article:

        @ https://juliu.is/permutate-parsers/
        @ https://sporto.github.io/elm-patterns/basic/parse-dont-validate.html
        @ https://discourse.elm-lang.org/t/what-is-the-elm-way-to-validate-form-fields/9689

    The basic premise is, rather than returning a `Bool` you want to return the
    actual value, so long as it's valid. If it's not valid, you return a `Nothing`,
    or alternatively, and `Err` or `Error` type.

    Haskell takes this further such as parsec, where we can remove the need for
    intermediary types such as `PassportField`. Other frameworks have built-in
    parsers of sorts, such as FastAPI use Pydantic, where types are used to
    validate data. We're not going to get into any of those here.


    Notes
    -----
    > Text input (and parsing) is a minefield of potential errors.
    > The more complex the input, the more errors you'll have to handle!

    1. I'm assuming the `String.trim` function isn't required.
        - This will be helpful incase user input (from form or file) contains tabs
          or spaces in front of any of the lines of text!
        - Fuzz testing of inputs might be required here!
    2. ⚠️ Multiline text files can hide a multiple of errors
        - If we `"""` with tabs, it'll give us a leading `" "` empty space
        - Newlines `\n` will give empty spaces with `String.lines`
            - `"""line\nline"""` however, will return `["line", "line"]`
    2. I'm avoiding `Maybe` types here (assumes input is correctly formatted)
        - For example, `splitField` should never return `("","")`

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


-- Main ------------------------------------------------------------------------

main : Html msg
main =
    text <| Debug.toString (getPassports userInput)
