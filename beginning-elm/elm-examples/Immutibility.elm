module Immutibility exposing (..)

import Html


multiplier =
    6



-- multiplier =
--     5


multiplyByFive number =
    let
        multiplier =
            5

        -- multiplier =
        --     4
    in
        number * multiplier


main =
    multiplyByFive 5
        |> toString
        |> Html.text
