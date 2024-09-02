module HowToResult.FieldError exposing (..)

{-| Field Error
    ===========

    This module will handle our simple field error, which only
    handles one field right now. We're only concerned with:

        A `String` value (of some length, might be a float/int)

    We're doing some basic error checks on the `String`, but you can add your
    own before you pipe it through to our main `...` function. For example,
    you might want to check a `Float` has only two decimal points. For this
    you'd need to provide a:

        `HowToResult.FieldErr`
            "This field requires two decimal points"

    You can see the Elm Guide on `Result` here:

        @ https://guide.elm-lang.org/error_handling/result


    Gotchas and problems
    --------------------

    1. How do we know ahead of time that `Float` or `Int` fields are required?
    2. How do we know which fields are optional?
    3. How do we accept other functions that check the fields?

    And future problems
    -------------------
    Richard Feldman advised against using any frameworks to do form field
    validation (other than checking individual field entry data, like an
    `Email` field).

        @ https://tinyurl.com/elm-validate-form-fields

    And this problem is a BIGGY:

    - How do we know which field requires which errors?

    You'd need some kind of separate record for each form field, possibly with
    an ID, some text, and maybe other record fields, so you can log this against
    the actual field that's going to be posted.

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



