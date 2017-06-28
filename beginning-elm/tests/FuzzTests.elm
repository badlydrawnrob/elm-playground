module FuzzTests exposing (allTests)

import Random exposing (minInt, maxInt)
import Test exposing (Test, describe, test, fuzz, fuzz2, fuzzWith)
import Expect
import Fuzz exposing (..)


allTests : Test
allTests =
    describe "Example Fuzz Tests"
        [ addOneTests
        , addTests
        , addOneFrequencyTest
        , flipTests
        , multiplyFloatTests
        , pizzaLeftTests
        , stringTests
        ]


addOneTests : Test
addOneTests =
    describe "addOne"
        [ fuzz (intRange minInt maxInt) "adds 1 to any integer" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        ]


addTests : Test
addTests =
    describe "add"
        [ fuzz2 int int "adds two given integers" <|
            \num1 num2 ->
                add num1 num2
                    |> Expect.equal (num1 + num2)
        ]


addOne : Int -> Int
addOne x =
    1 + x


add : Int -> Int -> Int
add x y =
    x + y


frequencyFuzzer : Fuzzer Int
frequencyFuzzer =
    let
        probabilities =
            frequency
                [ ( 70, constant 7 )
                , ( 12, intRange 8 9 )
                , ( 6, constant 6 )
                , ( 9, intRange 2 4 )
                , ( 1, constant 5 )
                , ( 1, constant 1 )
                , ( 1, constant 10 )
                ]
    in
        probabilities
            |> Result.withDefault (intRange 1 10)


addOneFrequencyTest : Test
addOneFrequencyTest =
    describe "addOne"
        [ fuzz frequencyFuzzer "adds 1 to the given integer" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        ]


flip : Bool -> Bool
flip x =
    not x


flipTests : Test
flipTests =
    describe "flip"
        [ fuzz bool "negates the given boolean value" <|
            \value ->
                flip value |> Expect.equal (not value)
        ]


multiplyFloat : Float -> Int -> Float
multiplyFloat x y =
    x * (toFloat y)


multiplyFloatTests : Test
multiplyFloatTests =
    describe "multiplyFloat"
        [ fuzz2 (floatRange -1.0 1.0) int "multiplies given numbers" <|
            \x y ->
                multiplyFloat x y
                    |> Expect.equal (x * (toFloat y))
        ]


pizzaLeft : Float -> Float -> Float
pizzaLeft eatenPercent totalSlices =
    totalSlices - (eatenPercent * totalSlices)


pizzaLeftTests : Test
pizzaLeftTests =
    describe "pizzaLeft"
        [ fuzz2 percentage float "returns remaining pizza" <|
            \eaten total ->
                pizzaLeft eaten total
                    |> Expect.equal (total - (eaten * total))
        ]


stringTests : Test
stringTests =
    describe "The String module"
        [ describe "String.reverse"
            [ test "has no effect on a palindrome" <|
                -- Unit Test - 1
                \() ->
                    let
                        palindrome =
                            "hannah"
                    in
                        palindrome
                            |> String.reverse
                            |> Expect.equal palindrome
            , test "reverses a known string" <|
                -- Unit test - 2
                \() ->
                    "ABCDEFG"
                        |> String.reverse
                        |> Expect.equal "GFEDCBA"
            , fuzz string "restores the original string if you run it again" <|
                \randomnlyGeneratedString ->
                    randomnlyGeneratedString
                        |> String.reverse
                        |> String.reverse
                        |> Expect.equal randomnlyGeneratedString
            ]
        ]
