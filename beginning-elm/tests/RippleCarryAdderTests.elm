module RippleCarryAdderTests exposing (main)

import Test exposing (describe, test)
import Expect
import Test.Runner.Html exposing (run)
import RippleCarryAdder exposing (..)


main =
    run <|
        describe "Comparison"
            [ test "2 is not equal to 3" <|
                \() ->
                    2 |> Expect.notEqual 3
            , test "4 is less than 5" <|
                \() ->
                    4 |> Expect.lessThan 5
            , test "6 is less than or equal to 7" <|
                \() ->
                    6 |> Expect.atMost 7
            , test "9 is greater than 8" <|
                \() ->
                    9 |> Expect.greaterThan 8
            , test "11 is greater than or equal to 10" <|
                \() ->
                    11 |> Expect.atLeast 10
            , test "a list with zero elements is empty" <|
                \() ->
                    (List.isEmpty [])
                        |> Expect.true "expected the list to be empty"
            , test "a list with some elements is not empty" <|
                \() ->
                    (List.isEmpty [ "Jyn", "Cassian", "K-2SO" ])
                        |> Expect.false "expected the list not to be empty"
            ]
