module Result.FieldMaybe exposing (..)

{-| ----------------------------------------------------------------------------
    Ok with Maybe: what happens if our field is optional?
    ============================================================================
    What about `Maybe` types? That could be an empty string, an optional number,
    etc. Our form inputs are generally strings however, but could also be an image
    a user hasn't uploaded, or an empty list of comments. Let's start with a VERY
    rudimentary example:

    `String` isOptional
    -------------------
    It's important to notify your program that a field is OPTIONAL. If you process
    inputs as simple `String`s, `""` empty would be ALLOWED if optional.

        @ https://tinyurl.com/result-maybe-14ab857 (first attempt, crappy)
        @ https://tinyurl.com/how-to-result-maybe-54a6474 (error checking with strings)
        @ https://tinyurl.com/field-maybe-commit-f369c88 (`Result` output -vs- `List Problem`)


    Examples in the wild
    --------------------
    @rtfeldman's Elm Spa example uses a `List Problem`, `ValidatedField`,
    a `fieldsToValidate` function, and `List.concatMap` in an interesting way.

        @ https://tinyurl.com/list-concat-map
        @ https://tinyurl.com/elm-spa-settings-page
        @ https://tinyurl.com/elm-spa-validate-field-func

    Some fields in those examples seem to be ignored for validation, so he doesn't
    seem to care if they're invalid. Those ones are either empty or not. He also
    takes care to "trim" (remove whitespace) fields, and uses this type for valid:

        type ValidForm
            = Valid Form

    In the above examples, he's only dealing with `String` types, and encodes
    them ready for `json`. If `List Problem` is an `[]` empty list, it's POSTed.

        @ https://tinyurl.com/elm-spa-encoded-updates

        ```
        updates =
            [ ( "username", Encode.string form.username )
            , ( "email", Encode.string form.email )
            , ( "bio", Encode.string form.bio )
            , ( "image", encodedAvatar )
            ]
        ```

    Other alternatives
    ------------------

    1. Some people say you shouldn't store computed values in the `Model`, but
       in one version, I'm using `{ input : String, valid: Result }` and updating
       that on every key stroke:

       @ `CustomTypes.Songs`

    2. A big fat function that returns `Ok (Just value)` or `Err String` for
       each field. This is because `optional` fields require a `Nothing` if
       they're `""` empty, because that's allowed. And, as every return value for
       a function MUST be the same type, they're all `Result String (Maybe a)`

    3. Alternatively, you could have individual functions handle each field, like
       I've done in (1), but NOT store them in the `Model`. You'd `Result.map`
       them and return a valid record structure if no `Err`, for example.

    4. Take a look at packages and other options Elm programmers are using, but
       as a rule, I prefer to keep things simple (and packages are a bit of a risk)

    For each method, you could consider custom types for FIELD STATES and start
    thinking about Cardinality for each, rather than combinations of `Boolean`
    values:

    Cardinality
    -----------
    `optional` -> Empty? 2 -> Full? + Required? 4 (accounts for `True` and `False`)
    `required` -> Empty? 2 -> Full? + Required? 4 (accounts for `True` and `False`)

    I _think_ there's really only 3 states we'd wish our simple field data to be,
    if you remove the `Boolean` options down to Union types:

    type PossibleFieldStates
        = Empty
        | FullAndRequiredLength
        | FullAndNotRequiredLength


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
    4. How about `String.concat` ALL the errors for a `Field` type, and then
       `String.concatMap` them into a `InvalidEntry ValidatedField String` so it
       contains EVERY error for that particular field?

-}

import Debug exposing (..)

{- Employer might be better as a Union Type, but this will suffice -}
type alias Person =
    { name : String
    , age : Int
    , employer : Maybe String -- Perhaps they're unemployed?
    }

type alias Model =
    { name : String
    , age : String
    , employer : String -- This is an optional field
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

type Msg
    = EnteredName String
    | EnteredAge String
    | EnteredEmployer String
    | FormSubmitted


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
-- type PossibleStates
--     = Empty -- allowed if optional
--     | FullAndRequiredLength
--     | FullAndNotRequiredLength

{- #! Remember: Each return value MUST be the same of type. As we have an
`optional` field which needs to return `Nothing`, all our other branches here
need to return a `Maybe a` -}
simpleValidate : Model -> ValidateFields -> List String
simpleValidate model field =
    case field of
        Name ->
            if String.isEmpty model.name then
                ["Name field must not be empty"]
            else
                []
        Age ->
            if String.isEmpty model.age then
                ["Age field must not be empty"]
            else if isRequiredLength model.age then
                []
            else
                ["Age field must be less than 4 characters"]

        Employer ->
            isEmployerOk model.employer

isRequiredLength : String -> Bool
isRequiredLength =
    (>=) 4 << String.length -- Function composition and point-free style

isEmployerOk : String -> List String
isEmployerOk s =
    if String.isEmpty s then
        [] -- "" empty is allowed for an `optional` field
    else
        if isRequiredLength s then
            []
        else
            -- if not "" then must be required length
            ["Employer field must be less than 4 characters"]

{- Right now the `listOfValidateFields` is a little redundant, as we're not
storing the `ValidateField` in the output ... it's a simplified version of
@rtfeldman's Elm Spa form examples. -}
runValidationCheck : Model -> List String
runValidationCheck model =
    List.concatMap (simpleValidate model) listOfValidateFields

update : Msg -> Model -> Model
update msg model =
    case msg of
        EnteredName str ->
            { model | name = str }

        EnteredAge str ->
            { model | age = str }

        EnteredEmployer str ->
            { model | employer = str }

        {- Here we have a `List ValidateFields` and a `isEmpty` function that we
        want to run to validate our ACTUAL `List String` from each form field. It's
        quite a clever method that @rtfeldman uses to mix a custom field type with
        the actual user input. -}
        FormSubmitted ->
            Debug.todo "What happens when the form is submitted?"


