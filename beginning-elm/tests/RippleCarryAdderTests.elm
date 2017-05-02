module RippleCarryAdderTests exposing (main)

import Test exposing (describe, test)
import Expect
import Test.Runner.Html exposing (run)
import RippleCarryAdder exposing (..)


main =
    run <|
        describe "Addition"
            [ test "1 + 1 = 2" <|
                \() ->
                    (1 + 1) |> Expect.equal 2
            , test "only 2 guardians have names with less than 6 characters" <|
                \() ->
                    let
                        guardians =
                            [ "Star-lord", "Groot", "Gamora", "Drax", "Rocket" ]
                    in
                        guardians
                            |> List.map String.length
                            |> List.filter (\x -> x < 6)
                            |> List.length
                            |> Expect.equal 2
            ]
