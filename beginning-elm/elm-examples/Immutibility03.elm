module Immutibility03 exposing (..)


doubleScores aList =
    let
        multiplier =
            2
    in
        List.map (\x -> x * 2) aList


newList =
    [ 316, 320, 312, 370, 337, 318, 314 ]
