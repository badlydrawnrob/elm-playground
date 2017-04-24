module Immutibility02 exposing (..)

import Html


multiplier =
    2


scores =
    [ 316, 320, 312, 370, 337, 318, 314 ]



-- Elm won't allow us to redefine `multiplier`!
-- multiplier =
--     3


doubleScores scores =
    List.map (\x -> x * multiplier) scores


scoresLessThan320 scores =
    List.filter isLessThan320 scores


isLessThan320 score =
    score < 320


main =
    doubleScores scores
        |> toString
        |> Html.text



-- scoresLessThan320
--     |> toString
--     |> Html.text
