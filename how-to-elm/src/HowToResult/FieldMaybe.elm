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

        @ https://tinyurl.com/result-maybe-14ab857 (first attempt, crappy)


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

    TL;DR
    -----
    1. He uses `String` of each form input
    2. He validates against custom types (a list of)
    3. He uses valid `String` inputs for the `Http.send`
        - His `Encode` looks something like this:

        ```
        updates =
            [ ( "username", Encode.string form.username )
            , ( "email", Encode.string form.email )
            , ( "bio", Encode.string form.bio )
            , ( "image", encodedAvatar )
            ]
        ```

    Computed values ARE NOT STORED in the `json` here. He ONLY seems to store
    things on the backend as plain strings, but those strings have been validated
    (albeit VERY SIMPLY) and only really checks for `""` empty and `"length"`.


    ----------------------------------------------------------------------------
    Wishlist
    ============================================================================
    1. A standardised way to check for errors
    2. Storing the `json` once form is validated:
        - Store as simple strings in `json` and compute on `Http.get`?
        - Store a successful `Form` within the `Model` as correct types,
          Then `Http.post` that information as valid `json`, `Encoded` as
          proper types (`List`, `Int`, etc, etc)
    3. For (2) you'd need two steps for the end-user:
        1. First the form "posts" to a valid `Model` (such as `Song`)
        2. Next notify the user that `json` has been stored in the backend ...
           Or have them SAVE AGAIN to store update the users `json` config file.

-}

import Debug exposing (..)
import Html exposing (input)

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

listOfValidateFields : List ValidateFields
listOfValidateFields =
    [ Name
    , Age
    , Employer
    ]

-- allowedStates
--     = Empty -- if optional this is OK
--     | FullAndWrongLength
--     | FullAndCorrectLength


-- Validating and checking for errors ------------------------------------------
--
-- 1. We have 2 `optional` and 1 `required` fields,
-- 2. If `optional` is `""` empty, that's Ok!
-- 3. If `optional` has `"string"` run required length checks.
-- 4. All `required` fields only need required length checks.
--     - To keep the example simple and reduce cognitive load.
--
-- Cardinality
-- -----------
-- There's really only 2-3 options for `optional`: Empty? Full+Required?
-- There's really only 1 option for `required` : Full+Required?
--
-- `optional` -> Empty? 2 -> Full? + Required? 4 (accounting for `True` and `False`)
-- `required` -> Empty? 2 -> Full? + Required? 4 (accounting for `True` and `False`)
--
-- It could be better to have a `Type` for all possible options:
--
-- type Valid
--     = Empty
--     | FullAndRequiredLength
--     | FullAndNotRequiredLength

isEmpty : ValidateFields -> String -> Result String a
isEmpty field input =
    case field of
        Name ->
            if String.isEmpty input then
                Err "Must not be empty"
            else
                Ok input
        Age ->
            if String.isEmpty input then
                Err "Must not be empty"
            else isRequiredLength input then
                Ok input
            else
                Err "This string is not the required length"

        Employer ->
            isEmployerOk input

isRequiredLength : String -> Bool
isRequiredLength =
    (>=) 4 << String.length -- Function composition and point-free style

isEmployerOk : String -> Result String String
isEmployerOk s =
    if String.isEmpty s then
        Ok Nothing -- "" empty is allowed for an `optional` field
    else
        if isRequiredLength s then
            Ok input -- if not "" then must be required length
        else
            Err "This string is not the required length"

update : Msg -> Model -> Model
update msg model =
    EnteredInput1 str ->
        { model | input1 = str }

    EnteredInput2 str ->
        { model | input2 = str }

    EnteredInput3 str ->
        { model | input3 = str }

    {- Here we have a `List ValidateFields` and a `isEmpty` function that we
    want to run to validate our ACTUAL `List String` from each form field. It's
    quite a clever method that @rtfeldman uses to mix a custom field type with
    the actual user input. -}
    FormSubmitted ->
        List.concatMap validateForm listOfValidateFields


