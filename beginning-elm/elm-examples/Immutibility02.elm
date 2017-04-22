module Immutibility02 exposing (..)


multiplier =
    2


scores =
    [ 316, 320, 312, 370, 337, 318, 314 ]


multiplier =
    3


doubleScores scores =
    List.map (\x -> x * multiplier) scores
