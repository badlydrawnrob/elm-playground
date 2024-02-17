module Notes exposing (..)

-- 5.1.1 -----------------------------------------------------------------------

-- Json.Encode --
--
-- We're not using this to encode JSON, but rather encode a JavaScript `Value`
-- for the `Html.Attributes.property` function. This will set a `JavaScript
-- _property_ on this `<range-slider>` node, so that our custom element can
-- read it later. The property will be named `val` and it will be set to our
-- `magnitude` value.

Html.Attributes.property "val" (Json.Encode.int magnitude)

-- `Json.Encode.int` function specifies what the property's type will be on the
-- JS side. You could've used `Json.Encode.string (String.fromInt m)) instead,
-- which would set to a JS string instead of a number.


-- Don't be ambiguous!! --------------------------------------------------------
--
-- Two names from different modules can cause an error:
--
-- `max` (the number function)
-- `Html.Attributes.max`

import Html.Attributes as Attr exposing (class, classList, ...)

-- Now you can call `Attr.max` instead!


-- Nested fields --
-- for Json.Decode
--
-- These two methods are essentially the same.
--
-- : You can also use these to convert a JavaScript object like
--   `{detail: {userSlidto: 7}}`

field "detail" (field "userSlidTo" int)

at [ "detail", "userSlidTo" ] int


-- Http.Events.on --
--
-- Using Json.Decode.Map

Json.Decode.map negate float  -- decodes a float, then negates it
Json.Decode.map (\num -> num * 2) int  -- decodes an integer, then doubles it
Json.Decode.map (\_ -> "[[redacted]]") string
-- decodes a string, then replaces it with "[[redacted]]"
-- no matter what it was originally.


import Html.Events exposing (on, onClick)

onSlide : (Int -> msg) -> Attribute msg
onSlide toMsg =
    let
        detailUserSlidTo : Decoder Int
        detailUserSlidTo =
            at [ "detail", "userSlidTo" ] int
        msgDecoder : Decoder msg
        msgDecoder =
            Json.Decode.map toMsg detailUserSlidTo
    in
    on "slide" msgDecoder

-- Notice how we assemble this value in three steps
-- (detailUserSlidTo, msgDecoder, and on), and each step’s
-- final argument is the previous step’s return value?
-- That means we can rewrite this to use the pipeline style
-- you learned in chapter 4! Let’s do that refactor:

onSlide : (Int -> msg) -> Attribute msg
onSlide toMsg =
    at [ "detail", "userSlidTo" ] int
        |> Json.Decode.map toMsg
        |> on "slide"
