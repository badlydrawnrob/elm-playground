module RunTestsInBrowser exposing (main)

import Test.Runner.Html exposing (TestProgram, run)
import RippleCarryAdderTests
import FuzzTests
import Test exposing (describe)


main : TestProgram
main =
    run <|
        describe "Test suite"
            [ RippleCarryAdderTests.allTests
            , FuzzTests.allTests
            ]
