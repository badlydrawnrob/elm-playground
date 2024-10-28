module HowToResult.FieldMaybe exposing (..)

{-| ----------------------------------------------------------------------------
    Ok with Maybe: what happens if our field is optional?
    ============================================================================
    Here we want to allow `""` empty entries, whatever the value we're expecting
    from the visitor. A few `Maybe` types could be:

        "" An empty string?
        ~~[] An empty list?~~

    This is a VERY rudimentary example and in real life there'd be quite a few
    error checks dependant on the input field and calculated value.

    isOptional
    ----------
    Somehow you have to "notify" your function that this particular field is an
    "optional" one. Ideally your `.input` is just a plain `String`, so you need
    some other way of notifying your program this _particular_ field needn't have
    any value (i.e: an "" empty string)

    Examples in the wild
    --------------------
    @rtfeldman's Elm Spa example uses a `List Problem`, `ValidatedField`, and
    `fieldsToValidate` function, and `List.concatMap` in an interesting way.

        @ https://tinyurl.com/list-concat-map
        @ https://tinyurl.com/elm-spa-settings-page

    It seems he ignores any other fields in the validation process and simply
    trims them (remove whitespace) and outputs a:

        type ValidForm
            = Valid Form

    And does some trickery to `Encode` all the strings as valid `json`:

        @ https://tinyurl.com/elm-spa-encoded-updates

-}

import Debug exposing (..)

{- Employer might be better as a Union Type, but this will suffice -}
type alias Person =
    { name : String
    , age : Int
    , employer : Maybe String -- Perhaps they're unemployed?
    }

type Model =
    { input1 : String
    , input2 : String
    , input3 : String -- This is an optional field
    }

type ValidateFields
    = Name
    | Age
    | Employer -- This one is optional!

{-| 1. Is the field optional?
    2. Is the field empty?
    ------------------------
    If (1) is `True` and (2) is `True` return `Nothing`
    If (1) is `False` and (2) is `True return `Err`
    If the latter, run any further error checks for each field!
-}
isEmpty : Bool -> String -> Result String a
isEmpty isOptional input =
    if isOptional && String.isEmpty then
        Ok Nothing
    else String.isEmpty then
        Err "field cannot be empty"
    else
        runErrors input

isRequiredLength : String -> Bool
isRequiredLength =
    (>=) 4 << String.length -- Function composition and point-free style

update : Msg -> Model -> Model
update msg model =
    EnteredInput1 str ->
        { model | input1 = str }

    EnteredInput2 str ->
        { model | input2 = str }

    EnteredInput3 str ->
        { model | input3 = str }

    {- Run all the error checks etc -}
    FormSubmitted ->
        Debug.todo "figure out how to loop over all inputs"


