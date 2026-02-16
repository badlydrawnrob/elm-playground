module Form.Passport exposing (..)

{-| ----------------------------------------------------------------------------
    Parsing a `String` into a `Passport` (text parsing)
    ============================================================================
    > ⚠️ I started but didn't finish: I hate text parsing and validation.

    "Do as little code as possible, and fail fast!" - @cscalfani

    I don't want to do it. It's difficult and time consuming.
    I'm not the person to handle these sort of tasks and prefer simple types.
    Text input (and parsing) is a minefield of potential errors.
    That's a higher degree of error than I'm comfortable with.
    My learning frame covers simple atomic strings only.


    Why?
    ----
    Because forms and text parsing can be done with Tally etc.
    Because Ai is gonna handle these tasks way better than I can!
    Because there's a GUI tool or package ... or outsource!
    Because `String.trim` is way easier than text editors.


    Learning
    --------
    1. Explicit is better than implicit code
    2. Atomic data is way easier to deal with (the `"2:00"` problem)
    3. Simplify your data, types, and code programs as must as possible
    4. Don't be afraid to delegate to a package or outsource to a GUI tool


    WISHLIST
    --------
    1. @rtfeldman's error handling method is something I could learn though.
        - @ https://github.com/rtfeldman/elm-spa-example/blob/master/src/Page/Login.elm
    2. Re-read the advice on forms (just a program)
        - @ https://discourse.elm-lang.org/t/what-is-the-elm-way-to-validate-form-fields/9689
    3. Possibly upload a simple, well formatted file and parse it
        - @ https://package.elm-lang.org/packages/elm/file/latest/


    Parse, don't validate
    ---------------------
    > Mike doesn't approve, I think due to the fact that you can be more
    > efficient and raise exceptions or errors _before_ the parsing engine does
    > it's thing.

    I guess it depends what stage your data is flowing into the parsing engine.
    Does it have to get too far before a simple error is raised? Here's an
    example of the concept "Parse, don't validate" in this article.

    🍒 Cherry pick only what you need!

        @ https://juliu.is/permutate-parsers/
        @ https://sporto.github.io/elm-patterns/basic/parse-dont-validate.html
        @ https://discourse.elm-lang.org/t/what-is-the-elm-way-to-validate-form-fields/9689

    The basic premise is, rather than returning a `Bool` you want to return the
    actual value, so long as it's valid. If it's not valid, you return a `Nothing`,
    or alternatively, an `Err` or `Error` type.

    Read the articles for the full details

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


-------------------------- STOP!!! ---------------------------------------------
-- Sketch the problem out. This is different from the Elm Spa example as our  --
-- input is a list of strings, not a record. That may render @rtfeldman's     --
-- route too difficult to work with. Check it over again and see if it fits.    --
--------------------------------------------------------------------------------


-- Main ------------------------------------------------------------------------

main : Html msg
main =
    text <| Debug.toString (getPassports userInput)
