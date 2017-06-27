module FuzzTests exposing (allTests)

import Test exposing (Test, describe, test, fuzz)
import Expect
import Fuzz exposing (..)


allTests : Test
allTests =
    describe "Example Fuzz Tests"
        [ addOneTests ]


addOneTests : Test
addOneTests =
    describe "addOne"
        [ fuzz int "adds 1 to any integer" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        ]


addOne : Int -> Int
addOne x =
    1 + x
