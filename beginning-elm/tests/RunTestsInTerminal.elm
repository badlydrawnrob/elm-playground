port module RunTestsInTerminal exposing (main)

import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import RippleCarryAdderTests exposing (allTests)


main =
    run emit allTests


port emit : ( String, Value ) -> Cmd msg
