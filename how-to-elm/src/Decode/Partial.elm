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
    > It's easier to read `Maybe User -> User` than
    > `Result x (Maybe D.Value) -> Result D.Error User`
    > ... and far easier to reason about.


    ----------------------------------------------------------------------------

    Using the `Dict`ionary method (it's tricky)
    -------------------------------------------
    > If you're going to use `Dict` then it's easier to use it for proper
    > _fuller_ dictionary decoders, rather than this partial decoder!

    - @ [`Json.Decode.dict`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#dict)

    1. A Dict requires types to be the same (here they are both `Value`)
    2. Pull out the `"user"` value (using simple type signatures as mentioned above)
    3. Extract out the values, as simply as possible `(Ok (Just value))` -> `value`.
    4. `decodeString (D.dict value) garden` returns `<internals>` (hidden values)

    > Do you _really_ need to keep the full `Dict` around?

    - Using `Json.Decode.andThen` with a `decodeUser` decoder is easier.
    - Building up your record with `D.at` is way easier!

    Dictionary return values:
    -------------------------

    > ⚠️ How complicated are your types?!
    > ⚠️ How difficult are your return values?
    > ⚠️ How easy is your code to read and understand?

    What if our function looks like this: `D.decodeValue decodeUser value` and
    returns `Result D.Error User`? We have a big problem!!! An `Error` type
    looks a bit like this:

    ```
    Err (Failure ("Expecting a STRING") <internals>)
    Err (Failure ("Expecting an OBJECT with a field named `use`") <internals>)
    ```

    `Error` isn't really supposed to be written out by hand; yet our function
    could return a `Nothing`: what value do we return? It should be `D.Error`!
    But that's hard to write! And on, and on, and on. Save yourself headaches.

    If you see some code like this:

    ```
    getUserValue : Dict String D.Value -> Result D.Error User
    getUserValue dictionary =
        case Dict.get "user" dictionary of
            Just value ->
                D.decodeValue decodeUser value

            Nothing ->
                Debug.crash "The key was not found" -- What type should this be?
    ```

    You're probably on the WRONG path. Instead we'd want to use:

    - `Json.Decode.at` or some other method to a full `Decoder User`
    - Do a `case of` on the `Result` type and output `Result String User`, which
      is a much simpler type to work with than `D.Error`.

    ----------------------------------------------------------------------------

    Wishlist
    --------
    > Imagine that it's a user profile/preference file!

    1. Using `Json.Decode.Value` for a particular element (like a `List Record`)

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
-- This seems to be the most complicated solution, with more steps to fully
-- decode the `Value` we want (the `"user"` value). It'd be a lot easier to simply
-- (Json.Decode.at) the `"user"` value and decode it directly (discard the `Dict`)
-- but then there are _far easier_ ways to do that (rather than using `Dict`).
--
-- *****************************************************************************
-- ******************* ⚠️ NON-WORKING CODE BELOW *******************************
-- *****************************************************************************


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

If your type signatures are difficult to follow, you might be on the wrong path.
Here we've simplified our types a little so instead of `D.Error` we can return
a `Maybe User`.

#! Now our `Nothing` branch also becomes easier. Instead of having to return a
`Result D.Error User`, we can return a `Maybe User` type. Far easier to handle
and build the error type — it's just a String! See below for `D.Error` version:

    - @ [`Json.Decode.Error`]

This type signature is overly complicated:

    Result x (Dict String D.Value) -> Result x (Maybe D.Value)

Here is a type signature that's simpler. You could potentially use `Result.map`
to implement it:

    Dict String D.Value -> Maybe User
-}
getUserValue : Dict String D.Value -> Maybe User
getUserValue dictionary =
    case Dict.get "user" dictionary of
        Just value ->
            case D.decodeValue decodeUser value of
                Ok user ->
                    Just user

                Err _ ->
                    Nothing

        Nothing ->
            Nothing


{-| It's a little easier to re-encode.

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
    E.encode 0 (E.dict identity identity dictionary) -- presumes both parts are `Value`s.
