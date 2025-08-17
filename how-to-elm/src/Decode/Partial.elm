module Decode.Partial exposing (..)

{-| ----------------------------------------------------------------------------
    A partial decoder, for when you only want to change part of the `json`.
    ============================================================================
    > Use a json validator to make sure it's valid!!

    This can be useful if you only need to work with a portion of the `json` file.
    The decoding option you use will depend on your `json` architecture! So sketch
    that out first, and see what your options are.

    `Json.Decode.Value` does not worry about it's exact shape, unless you need
    to `decodeValue`. It could be ANY javascript value: a boolean, null, string,
    undefined, an array, object, function, html, etc. Essentially it stores the
    (representation of) that javascript untouched (without a "proper") Elm decoder.

        - @ [`Json.Decode.Value`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#Value)
        - @ [`Json.Decode.at`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#at)
        - @ [1602/json-value](https://package.elm-lang.org/packages/1602/json-value/latest)

    The `decodeValue` function is mainly used for Ports.


    🚀 Keep your type signatures simple
    -----------------------------------
    > It's easier to read `Maybe User -> User` than it is to read
    > `Result x (Maybe D.Value) -> Result D.Error User` ... and FAR easier
    > to reason about.

    Whenever you see a difficult type signature, STOP. Sketch out the data flow
    and determine if the types can be simplified. Perhaps your program is too
    complicated or data types too nested (`Ok (Just value)`). Unless there's a
    very good reason to use something more complciated, DON'T. YAGNI.

    1. How easy is it to decode your values? How many steps?
    2. What guarantees do you need? Can you avoid `Ok`s and `Just's?
    3. Our two "direct" decoders are far easier than the `Dict` decoder.
        - And they essentially do exactly the same thing.
    4. Always ask: what are the benefits of this type? What are the negatives?
        - If there's no obvious benefit, start with YAGNI mentality.

    ----------------------------------------------------------------------------

    Simplifying return values:
    --------------------------

    > ⚠️ How complicated are your types?!
    > ⚠️ How difficult are your return values?
    > ⚠️ How easy is your code to read and understand?

    If our function `D.decodeValue decodeUser value` returns `Result D.Error User`
    we have a big problem!!! An `Error` type looks a bit like this:

    ```
    Err (Failure ("Expecting a STRING") <internals>)
    Err (Failure ("Expecting an OBJECT with a field named `use`") <internals>)
    ```

    You're probably on the WRONG path if you're returning a `D.Error` outside of
    a `Msg` type. `Error` isn't really supposed to be written out by hand; If your
    return value is a `Result D.Error ...` rethink your types:

    ```
    getUserValue : Dict String D.Value -> Result D.Error User
    getUserValue dictionary =
        case Dict.get "user" dictionary of
            Just value ->
                D.decodeValue decodeUser value

            Nothing ->
                Debug.crash "The key was not found" -- What type should this be?
    ```

    How could this be simplified and save ourselves a big headache?

    1. Instead of `Result D.Error User` aim for `User` or `Maybe User`
    2. Consider using a `case` statement on the `Result` type ...
        - A `Result String User` is easier to work with (but (1) is best!)

    ----------------------------------------------------------------------------

    Using the `Dict`ionary method (it's tricky)
    -------------------------------------------
    > ⚠️ Expect a lot of unpacking of `Result` and `Maybe` types!
    > ⚠️ What benefit are we gaining from using a dictionary type? Any?

        - @ [`Json.Decode.dict`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#dict)

    1. A Dict requires types to be the same (here they are both `Value`s)
    2. Pull out the `"user"` value (using simple type signatures as mentioned above)
    3. Extract out the values, as simply as possible `(Ok (Just value))` -> `value`.
    4. `decodeString (D.dict value) garden` returns `<internals>` (hidden values)

    > I'd advise (in general) to only use `Dict`ionary decoders if you're
    > planning to decode the whole object as a dictionary. Do you _really_ need
    > to keep the full `Dict` around?

    Consider using `Json.Decode.andThen` if you don't need to keep the `"items"`
    value around. However, `D.at` is way easier!

    ----------------------------------------------------------------------------

    Wishlist
    --------
    > Imagine that it's a user profile/preference file!

    1. We could use a `Json.Decode.Value` for a _part_ of a dictionary, if it's
       unlikely to be updated (but might as well decode it and leave it alone)
    2. Our dictionary style decoder results in a `Maybe User`.
        - How confident are we there'll ALWAYS be a `user` value in our object?
        - If we're 100% confident, `Dict.get` is probably overkill — just use a
          simpler decoder (you can always use `D.nullable`)

-}

import Dict exposing (..)
import Json.Decode as D exposing (..)
import Json.Encode as E exposing (..)

import Debug


-- Types -----------------------------------------------------------------------
-- We're only concerned with our `User` here, nothing else matters.

type alias User =
    { age : Int
    , level : Int
    , name : String
    , occupation : String
    , options : List String
    , theme : Theme
    , addressOne : String
    , addressTwo : String
    , postcode : String
    }

type Theme
    = Light
    | Dark


-- Example JSON ----------------------------------------------------------------
-- We want to use a proper decoder for the `"user"` value, but any old `Value`
-- for the `"items"` value (we're not currently using it in our Elm page)

garden =
    """
    {
        "user": {
            "age": 34,
            "level": 3,
            "name": "Herbert",
            "occupation": "Gardner",
            "options": ["Sunny", "Rain", "Storm"],
            "theme": "Dark",
            "address_one": "24 Pickle Gardens",
            "address_two": "North Tyneside",
            "postcode": "NE1 3YE"
        },
        "items": [
            { "id": 1,
              "title": "A wonderful day",
              "weather": "Sunny",
              "day": "Monday",
              "hours": 10
            },
            { "id": 2,
              "title": "Light drizzle",
              "weather": "Rain",
              "day": "Tuesday",
              "hours": 7
            }
        ]
    }
    """

decodeUser : Decoder User
decodeUser =
    D.map2
        (<|) -- A handy way to extend the `.map8` to `.mapX`!
        (D.map8 User
            (field "age" D.int)
            (field "level" D.int)
            (field "name" D.string)
            (field "occupation" D.string)
            (field "options" (D.list D.string))
            ((field "theme" D.string)
                |> D.andThen decodeTheme)
            (field "address_one" D.string)
            (field "address_two" D.string))
        (field "postcode" D.string)

encodeUser : User -> E.Value
encodeUser user =
    E.object
        [ ( "age", E.int user.age )
        , ( "level", E.int user.level )
        , ( "name", E.string user.name )
        , ( "occupation", E.string user.occupation )
        , ( "options", E.list E.string user.options )
        , ( "theme", E.string (encodeTheme user.theme) )
        , ( "address_one", E.string user.addressOne )
        , ( "address_two", E.string user.addressTwo )
        , ( "postcode", E.string user.postcode )
        ]

encodeTheme : Theme -> String
encodeTheme theme =
    case theme of
        Light ->
            "Light"

        Dark ->
            "Dark"

decodeTheme : String -> Decoder Theme
decodeTheme str =
    case str of
        "Light" ->
            D.succeed Light

        "Dark" ->
            D.succeed Dark

        _ ->
            D.fail "This is not a proper theme!"


-- The funky model -------------------------------------------------------------
-- A proper decoder for `User`, but ANY old javascript value for `"items"`.

type alias Model =
    { user : User, items : D.Value }


-- Method #1: `Json.Decode.Value` ----------------------------------------------
-- 1. A `Decoder` we want to change (and work with in Elm)
-- 2. A `Value` we won't change (any shape, but we don't care about it)

decodeWithValue : Decoder Model
decodeWithValue =
    D.map2 (\willUse wontUse -> { user = willUse, items = wontUse })
        (D.field "user" decodeUser) -- (1)
        (D.field "items" D.value) -- (2)

encodeWithValue : Model -> E.Value
encodeWithValue =
    \record ->
        E.object
            [ ( "user", encodeUser record.user ) -- (1)
            , ( "items", record.items ) -- (2) No need to encode
            ]


-- Method #2: `Json.Decode.at` with `Value` ------------------------------------

decodeAt : Decoder Model
decodeAt =
    D.map2 (\a b -> { user = a, items = b })
        (D.at ["user"] decodeUser)
        (D.at ["items"] value)


-- Method #3: `Json.Decode.dict` -----------------------------------------------
-- > ⚠️ Using these functions without `Msg` types is a hassle. There's lots of
-- > `Ok` results and `Just`s hanging around. Prefer simpler types.
--
-- Much more complicated than our previous examples: more steps to get our working
-- dictionary and partial `User` decoded. Alternatively you could directly
-- `Json.Decode.at` the `"user"` dictionary, but our previous examples make that
-- MUCH easier to do.
--
-- Steps to use:
--
-- 1. Decode the `Dict` with `Http.expectJson` or `D.decodeString`
--     - Will return an `Ok` or `Err` value ...
--     - You can unpack these in a `Msg` or with `Result.map`
-- 2. `Result.map getUserValue` with our `Ok (Dict.fromList ...)` result
-- 3. Store our `Maybe User` value in the `Model`.
--     - Do some work with our `User` values
-- 4. Save our `User` value back into the `Dict` with `putUserValue`
--     - You might have to use a `Maybe.map` here and curry the function.


{-| This will return a dictionary of `Value`s


```
>> D.decodeString decodeDict garden
Ok (Dict.fromList [("items",<internals>),("user",<internals>)])
    : Result Error (Dict.Dict String Value)
```
-}
decodeDict : Decoder (Dict String D.Value)
decodeDict =
    D.dict value

{-| Get the `user` value from the dictionary

> ⚠️ Keep your type signatures SIMPLE.
> ⚠️ Prefer simpler type signatures where possible.
> ⚠️ I was far less confident coding this up than our other decoders.

If your type signatures are difficult to follow, you might be on the wrong path.
Here we've simplified our types a little so instead of `D.Error` we can return
a `Maybe User`.

1. #! Our `Nothing` branch now becomes easier:
    - `Result D.Error User` becomes `Maybe User`.
    - We don't have to worry about a complicated `D.Error` type.
2. Instead of the `Nothing` branch evaluating to `Nothing`, we use `Maybe.andThen`.
    - This will evaluate to `Nothing` if the first map returns `Nothing`.

#! We now have a much simpler type signature to work from; Here's two examples
from our original code that are WAY more complicated then they need to be:

    Dict String D.Value -> Result D.Error User
    Result x (Dict String D.Value) -> Result x (Maybe D.Value)

    - @ [`Json.Decode.Error`](https://tinyurl.com/decode-partial-0d86c38)

-}
getUserValue : Dict String D.Value -> Maybe User
getUserValue dictionary =
    Dict.get "user" dictionary -- returns `Maybe Value`
        |> Maybe.andThen -- returns `Nothing` if above value is `Nothing`.
            (\maybeValue ->
                case D.decodeValue decodeUser maybeValue of
                    Ok user ->
                        Just user

                    Err _ ->
                        Nothing)

{-| Re-assemble our dictionary

> `Dict.insert` will replace the existing value if it exists.

We can curry the function with `Maybe.map (putUserValue dict) maybeUser` (I
reordered the argument order for this purpose). Our `maybeUser` needs to handle
both cases.

The dictionary would contain the undecoded `items` value and (an optional)
`user` value to update.
-}
putUserValue : Dict String D.Value -> User -> Dict String D.Value
putUserValue dictionary user =
    Dict.insert "user" (encodeUser user) dictionary

{-| It's a little easier to re-encode.

> Presumes both dictionary parts are `Value`s.

1. `identity` returns the same value it takes ...
2. So for both `(k -> String)` and `(v -> Value)` we can return itself.

```
-- This dictionary ...
Dict.fromList [("items",<internals>),("user",<internals>)] : Dict.Dict String Value

-- Returns this string ...
"{\"items\":[{...},{...}], {\"user\":...}"
```
-}
reEncode : Dict String D.Value -> String
reEncode dictionary =
    E.encode 0 (E.dict identity identity dictionary)
