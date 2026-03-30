module Form.ListError exposing (..)

{-| ----------------------------------------------------------------------------
    Form `List Error` (like Elm Spa Example)
    ============================================================================
    > This feels the fastest way to work with forms while prototyping!

    🤖 Ask Ai to step you through the original Elm Spa example.

        "It's `List.map` and `List.concat` combined. A single operation
        that clearly expresses 'apply this function to each item and flatten
        the results' otherwise you'd have to collect `List Error` first."

    Simplified version of the original! It's a very clever solution that results
    in a single `Result` for the entire form (rather than each field validator).
    You don't want to have lots of `Result`s or `Maybe`s to deal with!

    The original uses a second `List.map` to apply the `Problem` type to either
    the `ValidatedField` or a server response error. All errors are then collected
    into a `List Problem`. If you don't need a validator for a particular field,
    you can leave it out.

        @ https://tinyurl.com/list-concat-map
        @ https://tinyurl.com/elm-spa-example-list-error
        @ https://tinyurl.com/elm-spa-settings-page
        @ https://tinyurl.com/elm-spa-validate-field-func

    You'd then encode these values to POST as json if `List Problem` is empty:

        @ https://tinyurl.com/elm-spa-encoded-updates
        @ https://tinyurl.com/elm-spa-eg-save-new-article


    Downsides to this approach
    --------------------------
    > This method POSTs directly to the server! Other apps might want to store
    > collections in the model, then send to the server in bulk.

    `List.concatMap` approach sends directly to the server if valid. We needn't
    convert `String`s to types on the client! We let the server handle that, as
    we don't store computed values locally. Once Pydantic checks valid types, the
    server response can be sent (or errors). Initially I had a `Person` type:

    ```
    type alias Person =
        { name : String
        , age : Int
        , employer : Maybe String
        }
    ```

    This is redundant! But we will need a `personDecoder` to convert server data
    into proper Elm types for our page view. Other problems are:

        (a) It doesn't show errors in real time as the user types
        (b) It seems difficult to display all errors at the same time
        (c) It doesn't show the error next to each field (this can be solved)


    Chaining conditions
    -------------------
    > Similar does not mean the same!

    Black box thinking will reveal if conditional chains rely on a specific order.
    You might also want to consider a better way for optional fields, such as using
    the `||` or operator.


    Previous attempts
    -----------------
    > Previously I tried to use `Result` or `Maybe`. For simple forms it's much
    > easier to just return a `[]` or `["error"]` for each field.

        @ https://tinyurl.com/result-maybe-14ab857 (crap)
        @ https://tinyurl.com/how-to-result-maybe-54a6474 (result or `Err` string)
        @ https://tinyurl.com/field-maybe-commit-f369c88 (comparison to `List Problem`)

    @rtfeldman's example simplifies the form problem by treating all return values
    as `List String` (full or empty) instead of different Result types. If your
    form is complicated this could reduce the complexity of guards and calculated
    data quite a lot.


    Alternatives
    ------------
    > There's a great number of ways we could validate a form.

    Whichever you choose @rtfeldman says to treat it like a basic program and
    not get too fancy, or search for a package that solves every problem. Each
    form is different and you've got to treat them so. We also don't store these
    errors in the model, so they'll clear on the next form submit.

    One other potential route is using tables to apply validation functions. You
    could use an accumulator list to store the results of each type:

    ```
    case field of
        Name -> [validateNameNotEmpty, validateNameLength]
        ...
    ```

    Other packages use "parse, don't validate" or decoder-style approaches.


    Cardinality
    -----------
    > You could potentially consider the number of possible states

    If you're using `Result`, there could be many states for each fields. The
    cardinality of `List Problem` feels low, as there's:

    - Empty or full input strings (optional? required?)
    - Empty or full error list (and only as many as `ValidatedFields`)

    Other validation methods might have a higher number of potential states.


    ----------------------------------------------------------------------------
    Wishlist
    ============================================================================
    1. `String.concat` every fields problems into `List Error`?
        - Do we need a proper `List Problem` type for server errors?
    2. Build the proper form and allow it to POST to an endpoint
        - Validator returns `Result (List Error) TrimmedForm`
    3. Deal with the server response with impossible states
        - Do you have a single endpoint or `/new` and `/edit`?
-}

import Debug exposing (..)



type alias Model =
    { name : String     -- Required
    , age : String      -- Required
    , employer : String -- Optional
    }

type ValidateFields
    = Name     -- Required
    | Age      -- Required
    | Employer -- Optional

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
    | ClickedSave


-- Validating and checking for errors ------------------------------------------

{- #! Return values MUST be the same type -}
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
    (>=) 4 << String.length

{-| Optional field allows empty string -}
isEmployerOk : String -> List String
isEmployerOk s =
    if String.isEmpty s then
        []
    else
        if isRequiredLength s then
            []
        else
            ["Employer field must be less than 4 characters"]

{- Elm Spa returns `Result (List Problem) TrimmedForm`

`Page.Article.Editor` cannot be viewed without `Cred` (be logged in); POSTing to
the `/articles` endpoint won't work without a valid `TrimmedForm` and `Cred`. -}
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

        {-| See Elm Spa example for solution -}
        ClickedSave ->
            Debug.todo "https://tinyurl.com/elm-spa-eg-save-new-article"


