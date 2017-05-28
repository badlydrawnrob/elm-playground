module RunTestsInBrowser exposing (main)

import Test.Runner.Html exposing (run)
import RippleCarryAdderTests exposing (allTests)


main =
    run allTests
