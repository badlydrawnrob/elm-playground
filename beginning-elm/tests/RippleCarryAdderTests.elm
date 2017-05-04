module RippleCarryAdderTests exposing (main)

import Test exposing (describe, test)
import Expect
import Test.Runner.Html exposing (run)
import RippleCarryAdder exposing (..)


main =
    run <|
        describe "Less than comparison"
            [ test "an empty list's length is less than 1" <|
                \() ->
                    List.length []
                        |> Expect.lessThan -1
            ]
