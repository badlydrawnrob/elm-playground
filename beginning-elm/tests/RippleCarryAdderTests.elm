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
            ]
