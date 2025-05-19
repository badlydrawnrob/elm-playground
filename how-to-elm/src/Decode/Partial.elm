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

        - @ [`Json.Decode.Value`](...)
        - @ [`Json.Decode.dict`](https://package.elm-lang.org/packages/elm/json/#dict)
        - @ [1602/json-value](https://package.elm-lang.org/packages/1602/json-value/latest)

    The `decodeValue` function is mainly used for Ports.


    Using the `Dict`ionary method
    -----------------------------
    > Limitation of values having to be the same type (I think) ...
    > You could _potentially_ use `Json.Decode.oneOf`, but seems hacky.

        - @ [`Json.Decode.dict`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#dict)

    Ai also generated this option:

        D.map2 (\a b -> { user = a, items = b })
            (D.field "user" decodeUser)
            (D.field "items" (D.dict value)) -- obviously wouldn't work for list


    Wishlist
    --------
    > Imagine that it's a user profile/preference file!

    1. Using `Json.Decode.Value` for a particular element (like a `List Record`)

-}

import Dict exposing (..)
import Json.Decode as D exposing (..)
import Json.Decode.Pipeline as DP
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

decodeValue : Decoder Model
decodeValue =
    D.map2 (\willUse wontUse -> { user = willUse, items = wontUse })
    (D.field "item" decodeUser) -- (1)
    (D.field "items" D.value) -- (2)

encodeValue : Model -> E.Value
encodeValue =
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
-- This is a bit more complicated and takes more steps to decode, but may take
-- fewer steps to re-encode. Extract the `"user"` value.

{-| Three step process

1. Decode your values as `Value`s
2. Decode the `Value` you'd like to use
3. Re-encode the `Value` you used

```
Ok (Dict.fromList [("items",<internals>),("user",<internals>)])
    : Result Error (Dict.Dict String Value)
```
-}
decodeDict : Decoder (Dict String D.Value)
decodeDict =
    D.dict value

{-| #! These type signatures are a bit confusing:

1. Takes an `Ok Dict` (from `decodeDict`)
2. Returns another `Result` (hopefully with a `"user"` value)

Now (headache) we have a more complex data type (a bit of a mouthful):

```
Ok (Just <internals>) : Result Error (Maybe Value)
```
-}
getUserValue : Result x (Dict String D.Value) -> Result x (Maybe D.Value)
getUserValue =
    Result.map (Dict.get "user") -- Returns `Ok` or `Err`

{-| Finally we can extract the value

```
...
```
-}
getUser : Result x (Maybe D.Value) -> (Result D.Error User) -- #! Which return type?!
getUser dict =
    case dict of
        Ok (Just value) ->
            D.decodeValue decodeUser value

        Ok Nothing ->
            -- Handle the case where the key is not found
            -- There doesn't seem a way to generate a `Json.Decode.Error` here
            Debug.todo "Key not found"

        Err _ ->
            -- Handle the error case
            -- There doesn't seem a way to generate a `Json.Decode.Error` here
            Debug.todo "Error occurred"


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
    E.encode 0 (E.dict identity identity dictionary)
