module FuzzTests exposing (allTests)

import Test exposing (Test, describe, test, fuzz, fuzz2)
import Expect
import Fuzz exposing (..)


allTests : Test
allTests =
    describe "Example Fuzz Tests"
        [ addOneTests, addTests ]


addOneTests : Test
addOneTests =
    describe "addOne"
        [ fuzz int "adds 1 to any integer" <|
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
