port module RunTestsInTerminal exposing (main)

import Test.Runner.Node exposing (TestProgram, run)
import Json.Encode exposing (Value)
import RippleCarryAdderTests
import FuzzTests
import Test exposing (describe)


main : TestProgram
main =
    run emit <|
        describe "Test suite"
            [ RippleCarryAdderTests.allTests
            , FuzzTests.allTests
            ]


port emit : ( String, Value ) -> Cmd msg
