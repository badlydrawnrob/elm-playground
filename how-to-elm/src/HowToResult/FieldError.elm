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

    What this module attempts to do is to show ALL errors that a `String`
    contains at the same time, so a visitor can see exactly what needs to
    be changed. For this example, we're only concerned with ONE field:

        A `String` value (of some length, might be a float/int)

    We're doing some basic error checks on the `String`, but ideally you'd
    be able to add your own before you pipe it through to our main function.
    For example, you might want to check a `Float` has only two decimal points:

        "This field requires two decimal points"


    Gotchas and problems
    --------------------
    Even for a single field, there's a few problems that make life difficult. And
    with a real form, you'd likely want to check more than one field at once.
    So, if we're using this as a module, we need to be aware of:

    1. ⚠️ It's difficult for a module to be a catch-all:
        - If an `Int` field is required, this module might break.
        - If it's just a `String` we need, this module might be useless to us.
        - Can we know ahead of time what data is required in the field?
        - Could we change the module in real-time to either a `String` or an `Int`?
    2. ⚠️ If this field is optional, how do we know upfront?
        - How do we deal with that possibility? A `Maybe` type?
        - If its `Nothing`, do we ignore the field completely?
        - Do we handle that in this module, or in the main program?!
    3. ⚠️ How do we accept our "two decimal points" function as an extra check?
        - Or any other function for that matter?

    As you can see, it's going to get complicated quickly. Remember the hassle
    you had with form logic in WeWeb no code .. it can compound.


    A simple error checking method
    ------------------------------

    The simplest way to error check (I think) is to use `Bool` chained
    conditional functions. You could use `AND` so that if any checks in the chain
    contain a `False` (as in, an error) you can use `if` or `case` to handle
    that possibility:

        [False, False, False, True]

    You lose nuance however, and you'd only be able to render a single "Does not
    compute" `Err` for everything combined. That doesn't give the user much
    information on how to fix the problem. You could have an `Err` statement like:

        "Field requires email, < 20 characters, and [more errors]"

    Which is more descriptive, but it would be nicer to only list the errors that
    the user needs to fix ...


    But that adds lots of complexity
    --------------------------------
    It might be fine to generate a `List String` for ONLY the errors the string
    contains, but compound that 10x for 10 different fields and that's A LOT
    of complexity you probably don't want.

        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/2
        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/10


    A module may not be the answer
    ------------------------------
    See Richard Feldmans answer to the following question. It's very difficult
    to create a "catch all" module that will handle all eventualities.

        @ https://tinyurl.com/elm-validate-form-fields


    Don't repeat work if you can avoid it
    -------------------------------------
    I started out by replicating the `Result` type, with my own naming convention.
    it's probably better to create an `Error` type to pass through to `Result`,
    but I'm not entirely sure how that works. See also this thread:

        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/2
        @ https://discourse.elm-lang.org/t/error-handling-in-elm/5086/10


    Using `.map` and `.andThen`
    ---------------------------

    `andThen` is useful if you want to chain two `Result` types, so the
    first one succeeds (without `Err` message), but the second one doesn't, giving
    you a more SPECIFIC error message for that field. `.map` allows us to use a
    function on an `Ok a` result value.

    I'm not sure that these solve the multiple fields problem though.

-}

type alias FieldErr
    = String

type alias FieldErrList
    = List String

type alias FieldErrModel
    = { fieldErrors : FieldErrList }

type FieldError FieldErrList value
    = Ok value
    | Err FieldErrList

addToFieldErrorList : String -> FieldErrList
addToFieldErrorList s el =
    [s] ++ el


-- Error checks ----------------------------------------------------------------

{- Here we're using point-free style, without arguments -}
checkEmptyString : String -> Bool
checkEmptyString =
    String.isEmpty


-- Our main Error Checker function ---------------------------------------------



