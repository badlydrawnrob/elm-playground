module HowToResult.FieldError exposing (..)

{-| Field Error
    ===========

    You can see the Elm Guide on error handling here. `Result` is the main one
    we're concerned about:

        @ https://guide.elm-lang.org/error_handling/
        @ https://guide.elm-lang.org/error_handling/maybe
        @ https://guide.elm-lang.org/error_handling/result

    The examples tend to be basic. They may contain multiple errors, but ONLY
    ONE ERROR would be shown to the user at a time.


    The core problem
    ----------------

    > Simple is better.
    > If your logic becomes too complex or too many steps in the process,
    > there's probably a simpler way you haven't thought about.
    > eg: Two `Int` inputs (minutes, seconds) is simpler.

    Can we show ALL errors that a `String` contains at the same time?
    That way a visitor can see exactly what needs to be changed. We're
    only concerned with a SINGLE field right now:

        A `String` value (of specific length)
        Is a `Float`, not an `Int` ...
        Has a `minutes` part and a `seconds` part
        e.g: A song runtime.

    We're doing some basic error checks on the `String`, adding your own
    error checking functions to this module might be possible, but not
    preferable (see "a module probably isn't the answer") as unless it's a very
    generic String, such as an email, it's likely to be quite specific to that
    project and could be hard to retro-fit.

    I'm sure there's easier ways of handling this data type, but I'm using
    `Result` and chaining them together. I'm also assuming that only the
    following problems have to be dealt with (I'm sure there'd be more):

        - `String` is empty or not a `Float`
        - An `Int` is entered rather than a "proper" `Float`
        - The decimal point is too long (more than two)
        - ~~The string entered shouldn't have more than one decimal point~~
        - ...

    There is actually a package that could handle the decimal point issue
    better:

        @ https://package.elm-lang.org/packages/myrho/elm-round/latest/


    Order is important
    ------------------
    If we need to check that the `Float` has two decimal points, we might want
    to check that _before_ the `String` is converted to an `Int`. A
    cursory glance in the docs and I can't find a better way — other than using
    Round, Floor or Ceil to convert to an `Int`.

    Whatever way you do it, you must consider the chaining order.


    WRITE IT DOWN FIRST! List ALL possible states
    ---------------------------------------------
    Remember the practice you did in "How To Design Programs", before you
    generated a function you provided "tests" or data that you're likely to
    see, such as typos, wrong data, wrong format, so on. You might need to
    use fuzz tests for this. A good example is here:

        @ https://discourse.elm-lang.org/t/handling-nested-conditional-logic/2163/5

    Figure out, upfront, what kind of computations you'll need to do on the data
    before you start! Some things will be generic (limit length) and others
    might need a bunch of `Result` errors depending on it's state.

    I've said it once, so I'll say it again: SIMPLE IS BETTER, use the
    5 steps to reduce code (Elon Musk). If your state is too hard to reason
    about, maybe your form is too complex.


    Gotchas and problems
    --------------------
    Even for a single field, there's a few problems that make life difficult. And
    with a real form, you'd likely want to check more than one field at once.
    If we _were_ using this as a generic module (we're not) we'd consider:

    1. ⚠️ It's difficult for a module to be a catch-all:
        - The data type we're checking is important to know up-front
        - Is it a required field? Which errors are we checking for, exactly?
        - Is our API flexible enough to deal with all these potentials?
        - Is this making life harder than it needs to be? Is it easier to just
          write a program and use errors specific to that program?
    2. ⚠️ If this field is optional, how do we deal with this?
        - A `Maybe` type?
        - If its `Nothing`, do we ignore the field completely?
        - Do we handle that in this module, or in the main program?!
    3. ⚠️ How might we add extra error checks to the module?
        - Or any other function for that matter?

    As you can see, it's going to get complicated quickly. Remember the hassle
    you had with form logic in WeWeb no-code .. it can compound. There's also
    this article (for Javascript, so might not apply in Elm) on `number` input:

        https://stackoverflow.blog/2022/12/26/why-the-number-input-is-the-worst-input/


    Simple error checking methods
    -----------------------------

    We need to chain conditional functions, somehow. We also need some way to
    represent the errors. A simple way would be to use `Bool` and chain them,
    and not worry in what order they are:

        False AND True AND False == Err "There's some error here"

    That doesn't give us much information. but we could simply write out in the
    error message that:

        "Field requires email, < 20 characters, and [more errors]"

    We could also somehow generate a list of `Bool`, along with their error
    strings, and somehow parse this later (could also be a record):

        `[(False, "Error note"), (True, ""), (False, "Error note")] and so on.

    Perhaps a simple `List String` would suffice, too:

        ["error 1", "error 2", "error 3"]

    The final way I can think of doing it is by using a custom type. I've heard
    it could potentially "flatten" the case statements. However we do it, we
    need to give the user good enough feedback so they can answer:

        HOW DO I RECTIFY MY MISTAKE?

    The more descriptive the better, ideally only listing the errors they need
    to fix, NOT every error that's possible. And, ideally it's placed next to the
    field they need to fix.


    Again, this could all get complex quite quickly
    -----------------------------------------------
    It might be fine to generate a `List String` for ONLY the errors the string
    contains, but compound that 10x for 10 different fields and that's A LOT
    of complexity you probably don't want.

    You can read this thread for "which method do I use?"

        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/2
        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/10

    You can read this thread for "handling nested (chained) conditions":

        @ https://discourse.elm-lang.org/t/handling-nested-conditional-logic/2163


    ---------------------------------------
    ⚠️ A MODULE IS PROBABLY NOT THE ANSWER!
    ---------------------------------------
    See Richard Feldman's answer to the following question. It's very difficult
    to create a "catch all" module that will handle all eventualities. DON'T
    SEARCH FOR A UNICORN that'll solve all your problems. Treat each form like
    a mini-program:

        @ https://tinyurl.com/elm-validate-form-fields


    Don't repeat work if you can avoid it
    -------------------------------------
    I started by creating types and functions that may not be needed. Remember
    that a custom type is useful when it solves a problem simple data can't,
    and it's very descriptive of the issue at hand. You don't have to go
    recreating the `Result` type.

    Using the defaults also comes with the benefit of being able to use their
    helper functions, like `Result.andThen` to chain error results. Multiple
    errors is a difficult problem, and I'd probably lean to the simplest solution
    (perhaps a simple `List Error`?) and chain `if/else` statements.


    Using `.map` and `.andThen`
    ---------------------------

    `andThen` is useful if you want to chain two `Result` types, so the
    first one succeeds (without `Err` message), but the second one doesn't, giving
    you a more SPECIFIC error message for that field. `.map` allows us to use a
    function on an `Ok a` result value.

    I'm not sure that these solve the multiple fields problem though.

-}
import Html.Attributes exposing (..)
import String exposing (split)
import Html exposing (s)

{- I started out by using types for the fields,
but it's going to change from a `String` to a `Float`,
so this might just cause problems ... -}

-- type alias Field
--     = String

-- type alias FieldErr
--     = String

-- type alias FieldValid
--     = Int

{- This might be overkill, but we need some way to return the type of error
it is, ideally ALL of our errors, but for now might just have to step through
each error and spit out the last one. The alternative way to do this is just
use a simple `case` statement like:
@ https://guide.elm-lang.org/error_handling/result. -}
type FieldError
    = Empty | NotFloat | NumberTooHigh | NotTwoDecimals

checkForErrors : Field -> Result FieldErr Field
checkForErrors f =
    Debug.todo


-- Error checks ----------------------------------------------------------------

-- First we'll list the possible states of the form field.
-- Note that `String.toFloat` renders `"2"` as a float, when
-- we want it to create an error. I can't think of a better
-- way than using string functions for this use case.
--
-- ""
-- "isn't a number"
-- "2"               (an `Int`)
-- "2.3456"          (too many decimal points)
-- "2.35"            (perfect)
-- "2.3.4"           (this isn't SemVer! We need a `Float`!)
-- "11.35"           (too high a `minutes` number)
-- "2.61"            (too high a `seconds` number)
-- "2.00"            (out of scope for our requirements)
-- "-1"              (out of scope for negative numbers)


{- This isn't required as `String.toFloat` will spit out `Nothing`
if it's empty string. Here we're using point-free style, without arguments -}
-- checkEmptyString : String -> Result FieldError String
-- checkEmptyString s =
--     if String.isEmpty s then
--         Err Empty
--     else
--         Ok s


{- Check if it's not empty, or isn't a number first. This will
also come back as `Nothing` if a SemVer number is given. -}
checkIfFloat : String -> Result FieldError String
checkIfFloat s =
    case String.toFloat of
        Nothing -> Err "Either not a number or an empty string"
        Just f  -> Ok f

{- Next, we'll check if it's a "proper" `Float` (decimal point)
We know we have a number, but if that number is an `Int` then the
`tail` call will come back empty. That's not what we're looking for! -}
checkTwoDecimals : String -> Result FieldError String
checkTwoDecimals s =
    let
        split = String.split "." s
        rest = List.tail split
    in
    case rest of
        Nothing -> Err "There's nothing there"
        Just [] -> Err "The number must contain a decimal point"
        Just f  -> Ok s -- Return the string, as we still need it ...

{- Finally, we want to check that both sides are in range, I'm not
bothering to check if they're positive numbers, but that could happen -}
checkNumbersInRange : String -> Result FieldError String


{-| ... To check both sides are }

{- This is probably a dumb way to check this, as I could just
convert `String.toFloat` and somehow round down to two decimals -}
checkTwoDecimals : String -> Result FieldError String
checkTwoDecimals s =
    let
        float = String.toFloat s  -- Returns a `Maybe Float`
        Maybe.map somefunc float

        split = String.split "." s
        decimals = extractDecimals (List.tail split)
        countDecimals = String.length decimals <= 2
    in
    case countDecimals of
        True -> Ok s
        False -> Err NotTwoDecimals

checkIsInt : String -> Result FieldError String
checkIsInt s =
    case String.toFloat s of
        Nothing -> ""
        Just


checkIfFloat : Maybe Float -> Bool
checkIfFloat f =
    case f of


{- Here it's a good idea to list the possible states of your
decimals. They could be `Nothing`, `""` (empty), or "123+" of
any number of decimals. You could also have used the `String.toFloat`
and `Round` down to two decimals. This is a bit laborious -}
extractDecimals : Maybe (List String) -> String
extractDecimals l =
    case m of
        Nothing   -> ""
        Just [""] -> ""
        Just l    -> l

{- The order of this is important. It should return an `Int` and
NOT a `String` ... here we're converting it to a `Float` and check if it's
higher than an abitrary number. We probably should've done this FIRST?! -}
isLowerThan : String -> Result FieldError Float
isLowerThan s =
    let
        number = String.toFloat
        number |> String.toLower |> ((<=))
    case String.toFloat s of
        Nothing -> Err NotFloat
        Just n  ->

isLowerThanHelper : Float -> Result FieldError Float
isLowerThanHelper f ->
    if f <= 5 then
        Field



-- Our main Error Checker function ---------------------------------------------

runErrorCheck : Field -> Result FieldErrorType Field
runErrorCheck f =
    if checkEmptyString f then
        Err "This field must not be empty"
    else
        case f of
            checkEmptyString

