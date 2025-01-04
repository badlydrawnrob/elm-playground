module Result.FieldError exposing (..)

{-| ⚠️ Field Error
    ==============
    > This file example is really quite hard to follow when it gets in to the
    > error checking. I think this is a result of poor data choices up-front.

    See below for why this example is flawed. You can see the Elm Guide on error
    handling here. `Result` is the main one we're concerned about:

        @ https://guide.elm-lang.org/error_handling/
        @ https://guide.elm-lang.org/error_handling/maybe
        @ https://guide.elm-lang.org/error_handling/result

    The examples tend to be basic. They may contain multiple errors, but ONLY
    ONE ERROR would be shown to the user at a time.


    I should've sketched out the problem first!
    ------------------------------------------

    > This is a great example of OVER ENGINEERING!

    We're making extra work for ourselves here, as we could've just treat the
    inputs as two boxes, each as an `Int`, rather than wrestling with maths
    or `String` manipulations:

        input 2 mins 30 seconds

    It's also easier to contain each field's errors within ONE result type, as
    you'll potentially have a lot of errors. Or use a different data type, such
    as a `List a`.


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
        Is a "proper" `Float`, not an `Int` ...
        Has a `minutes` part and a `seconds` part
        e.g: A song runtime.

    We're doing some basic error checks on the `String`, adding your own
    error checking functions to this module might be possible, but not
    preferable (see "A MODULE PROBABLY ISN'T THE ANSWER") as unless it's a very
    generic String, such as an email, it's likely to be quite specific to that
    project and could be hard to retro-fit.

    I'm sure there's easier ways of handling this data type, but I'm using
    `Result` and chaining them together. I'm also assuming that only the
    following problems have to be dealt with (I'm sure there'd be more):

        - `String` is empty or not a `Float`
        - An `Int` is entered rather than a "proper" `Float`
        - The decimal point is too long (more than two)
        - Both sides of the decimal point are within range of x/y
        - ~~The string entered shouldn't have more than one decimal point~~
        - ...

    Unpacking `Maybe` types

        It turns out having to keep checking the number in this way leads to a
        lot of unpacking of `Maybe` types (i.e: `String.toInt`) all over our
        program — which is far from ideal!

        Perhaps a better way is to convert the `Float` first and keep that around,
        as well as the original `String`, to perform operations on?

    Switching types

        Our `Result _ VALUE` switches (at some point in the chain) from a `String`
        to a `Float`, which might also be a bad idea.

    Packages that could help

        To make life simpler, we could simply truncate the decimal point,
        rather checking with a `String`. But that requires maths (oh no!):

        @ https://stackoverflow.com/a/31952975

        Luckily there's an Elm package that can help us:

        @ https://package.elm-lang.org/packages/myrho/elm-round/latest/

    Finally, if we convert `String.toFloat` and that number includes zero
    decimal points, we get back something that looks like an `Int` but has
    a type of `Float`:

        @ https://github.com/elm/core/issues/964

    We don't want that.



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
    It might be fine to generate a `List String` for our errors, but compound
    that 10x for 10 different fields and that could create A LOT of complexity
    you probably don't want.

    You can read this thread for "which method do I use?"

        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/2
        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/10

    You can read this thread for "handling nested (chained) conditions":

        @ https://discourse.elm-lang.org/t/handling-nested-conditional-logic/2163


    ----------------------------------------------------------------------------
    ⚠️ A MODULE IS PROBABLY NOT THE ANSWER!
    ----------------------------------------------------------------------------
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


    Using `.map`, `.andThen`, and `toMaybe`
    ---------------------------------------

    `Result` has some useful functions that it can be used with. `andThen` is
    useful if you want to chain two `Result` types, so the first one succeeds
    (without `Err` message), but the second one doesn't, giving you a more
    SPECIFIC error message for that field. `.map` allows us to use a function
    on an `Ok a` result value.

    I'm not sure that these solve the multiple fields problem though.

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)

{- I started out by using types for the fields,
but it's going to change from a `String` to a `Float`,
so this might just cause problems ... -}

-- type alias Field
--     = String

-- type alias FieldErr
--     = String

-- type alias FieldValid
--     = Int

{- We could just use a `String` for our `Result` errors, which might be
the easier thing to do. For our purposes though, I'm going to use a type
and this can be converted to an error message in the view. Might be overkill! -}
type FieldError
    = YayNoErrors
    | EmptyOrNotString
    | NotProperFloat
    | NumbersTooHigh
    | NotTwoDecimals



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
--
-- Out of scope for our purposes
-- "2.1"             (only one decimal point)
-- "2.10"            (Elm removes zeros)
-- "2.00"            (Elm removes zeros)
-- "-1"              (negative numbers)


{- This isn't required as `String.toFloat` will spit out `Nothing`
if it's empty string. Here we're using point-free style, without arguments -}
-- checkEmptyString : String -> Result FieldError String
-- checkEmptyString s =
--     if String.isEmpty s then
--         Err Empty
--     else
--         Ok s


-- Step 1 ----------------------------------------------------------------------

{- Check if it's not empty, or isn't a number first. This will
also come back as `Nothing` if a SemVer number is given. -}
checkIfFloat : String -> Result FieldError String
checkIfFloat s =
    case String.toFloat s of
        Nothing -> Err EmptyOrNotString
        Just f  -> Ok s  -- We want to keep the float to run string tests later


-- Step 2 ----------------------------------------------------------------------

{- Next, we'll check if it's a "proper" `Float` (decimal point)
We know we have a number, but if that number is an `Int` then the
`tail` call will come back empty. `String.toFloat` converts a `2.00` to
a `2`, That's not what we're looking for! It's probably NOT an issue however,
as in this thread: @ https://github.com/elm/core/issues/964 but for our
purposes I'm going to treat it as it is. -}
checkTwoDecimals : String -> Result FieldError String
checkTwoDecimals s =
    let
        rest = splitNumberTail s
    in
    case rest of
        Nothing -> Err EmptyOrNotString
        Just [] -> Err NotProperFloat
        Just f  -> (countTwoDecimals f s) -- Return string or error

{- Split out the two sides of the `Float` if they have them. We use special
syntax `>>` for point-free style @ https://tinyurl.com/elm-lang-point-free-style-eg -}
splitNumberTail : String -> Maybe (List String)
splitNumberTail =
    String.split "." >> List.tail

countTwoDecimals : List String -> String -> Result FieldError String
countTwoDecimals m string =
    let
        check =
            case m of
                []  -> False
                [s] -> String.length s <= 2
                _   -> False
    in
    case check of
        False -> Err NotTwoDecimals
        True  -> Ok string


-- Step 3 ----------------------------------------------------------------------

{- Check numbers are in range. We've already checked that we've got a `head`
and `tail` and that there is two decimal points available.

AVOID USING THE FUNCITON THAT RETURNS ANOTHER `MAYBE`!
------------------------------------------------------
That means more unpacking and more headaches. We can simply loop the list or
use a `case` statement and destructure the list instead. We've already run the
checks we need to make sure it's valid data. Haskell uses `&&` and `||` for
`AND`/`OR` ... ugh -}
checkNumbersInRange : String -> Result FieldError Float
checkNumbersInRange s =
    let
        floatList = String.split "." s
        isInRange = checkInRange floatList
    in
    case isInRange of
        True  -> Ok (extractFloat s)  -- Finally, we output the Float
        False -> Err NumbersTooHigh

{- Thankfully we can cheat and do this WITHOUT having to deal with `Maybe`
and unpacking all those bloody `Just a` returns. It can only ever really be
a `[first, second]` as we've checked it, but we have to be specific or Elm
complains when compiling -}
checkInRange : List String -> Bool
checkInRange l =
    case l of
        []  -> False
        [_] -> False

        [first,second] ->
            (checkMinutesInRange (extractInt first))
                && (checkSecondsInRange (extractInt second))

        _ -> False

{- These fucking `Maybe` types are a pain in the ass. They're type-safe,
but it adds a lot of extra checking ... -}
extractInt : String -> Int
extractInt s =
    case String.toInt s of
        Nothing -> 11  -- A nasty hack, but it'll return `False`
        Just i  -> i

{- We already KNOW it's a float as it's been tested at the start .. so
in retrospect, unpacking this more than once is probably a dumb idea. We've
now got a LOT of `Maybe` types cropping up all over the program -}
extractFloat : String -> Float
extractFloat s =
    case String.toFloat s of
        Nothing -> 0
        Just f -> f


{- If it's in range we want this test to pass `True` -}
checkMinutesInRange : Int -> Bool
checkMinutesInRange =
    ((>=) 10)

{- Again if it's in range it'll return `True` -}
checkSecondsInRange : Int -> Bool
checkSecondsInRange =
    ((>=) 60)


-- Our main Error Checker function ---------------------------------------------

{- For now might just have to step through each error and spit out the last one.
The alternative way to do this is just use a simple `case` statement like:
@ https://guide.elm-lang.org/error_handling/result. -}
runErrorCheck : String -> Result FieldError Float
runErrorCheck s =
    checkIfFloat s
        |> Result.andThen checkTwoDecimals
            |> Result.andThen checkNumbersInRange


{- It depends if we're needing to notify the user or the devs to how specific
we're being with our error. For the user, we can covert our `FieldError` to
a `String` — probably best to be specific about the error! -}

convertError : FieldError -> String
convertError fe =
    case fe of
        YayNoErrors      -> ""  -- #! I'm not sure if this is correct ^
        EmptyOrNotString -> "Please enter a float string"
        NotProperFloat   -> "This isn't a proper float"
        NumbersTooHigh   -> "Please keep numbers in range"
        NotTwoDecimals   -> "Too many decimal points"

{- We're going to store the field error somewhere in the model, so how do we
cater for ZERO errors? The `Ok _` is the success case for this, so am I doing
this wrong? -}



-- Update ----------------------------------------------------------------------

-- I can't be bothered using another `Maybe` right now, so I'm just going to
-- default the savedInput to zero.

type alias Model =
    { userInput : String
    , fieldError : FieldError
    , savedInput : Float -- I can't be bothered to use a `Maybe` here today!
    }

type Msg
    = UpdateInput String
    | SaveInput

initialModel =
    { userInput = ""
    , fieldError = EmptyOrNotString
    , savedInput = 0 -- This should really be a `Nothing` but hey-ho.
    }

{- We need to pass the info through to the model -}
update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput str -> { model | userInput = str }
        SaveInput     -> checkAndSave model

checkAndSave : Model -> Model
checkAndSave model =
    let
        checkErrors = runErrorCheck model.userInput
    in
    case checkErrors of
        Err fieldError -> { model | fieldError = fieldError }
        Ok float       -> { model
                            | userInput = "" -- reset
                            , fieldError = YayNoErrors
                            , savedInput = float
                            }


-- View ------------------------------------------------------------------------

-- See `Form/SingleField.elm` for notes on this form!

view : Model -> Html Msg
view model =
    form [ class "float-input", onSubmit SaveInput ]            -- (a)
            [ input
                [ type_ "text"
                , placeholder "Please add a number ..."
                , value model.userInput                        -- (b)
                , onInput UpdateInput                          -- (c)
                ]
                []
            , p [ class "field-error" ]
                [ text (convertError model.fieldError) ]
            , button [] [ text "Save" ]
            , div [ class "display-result" ]
                [ p [] [
                    strong [] [ text "Success: " ]
                    , text (String.fromFloat model.savedInput)
                    ]
                ]
            ]


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
