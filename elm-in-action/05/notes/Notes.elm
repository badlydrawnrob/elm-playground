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


-- AVOIDING BUGS (vs design choices) -------------------------------------------

-- By using individual fields instead of a list of records, we can rule out the
-- entire category of bugs related to invalid filter names.
--
-- Increasing conciseness and saving potential future effort are nice, but
-- preventing bugs in a growing code base tends to be more valuable over time.
-- Verbosity has a predictable impact on a project, whereas the impact of bugs
-- can range from “quick fix” - to “apocalyptic progress torpedo.”
--
-- Ruling those out is more valuable than a bit of conciseness!
-- We’ll go with the approach that prevents more bugs.
--
-- Take a moment to look back at tables 5.3, 5.4, and 5.5, and implement the
-- changes in the first column. Then let’s revise our viewLoaded function to
-- accept Model as its final argument instead of ChosenSize, and to use Model’s
-- new fields:


-- Cmd msg (a type variable) --
--
-- A command that produces no messages has the type `Cmd msg`,
-- a subscription (for example, Sub.none) that produces no messages
-- has the type `Sub msg`, and a list that has no elements—that is,
-- `[]` has the similar type `List val`. Because their type variables
-- have no restriction, you can use a `Cmd msg` anywhere you need any
-- flavor of `Cmd`, just as you can use an empty list anywhere you need
-- any flavor of List. Playing around with empty lists in elm repl can
-- be a helpful way to see how types like these interact with other types.
--
-- Both Cmd.none and setFilters produce no message after completing.

port setFilters : FilterOptions -> Cmd msg


-- SHARING CODE BETWEEN UPDATE BRANCHES ----------------------------------------

-- Usually, the simplest way to share code is to extract common logic
-- into a helper function and call it from both places. This is just
-- as true for update as it is for any function, so let’s do that!


-- Keep javascript light (to a minimum) ----------------------------------------

-- Now we’re going to write a bit more JavaScript code. Whenever we access a
-- JS library from Elm, it’s best to write as little JavaScript as possible.
-- This is because if something crashes at runtime, it’s a safe bet that the
-- culprit is somewhere in our JavaScript code so the less of it we have,
-- the less code we’ll have to sift through to isolate the problem.
