module RippleCarryAdderTests exposing (allTests)

import Test exposing (describe, test)
import Expect
import RippleCarryAdder exposing (..)


inverterTests =
    describe "Inverter"
        [ test "output is 0 when the input is 1" <|
            \() ->
                inverter 0
                    |> Expect.equal 1
        , test "output is 1 when the input is 0" <|
            \() ->
                inverter 1
                    |> Expect.equal 0
        ]


andGateTests =
    describe "AND gate"
        [ test "output is 0 when both inputs are 0" <|
            \() ->
                andGate 0 0
                    |> Expect.equal 0
        , test "output is 0 when the first input is 0" <|
            \() ->
                andGate 0 1
                    |> Expect.equal 0
        , test "output is 0 when the second input is 0" <|
            \() ->
                andGate 1 0
                    |> Expect.equal 0
        , test "output is 1 when both inputs are 1" <|
            \() ->
                andGate 1 1
                    |> Expect.equal 1
        ]


orGateTests =
    describe "OR gate"
        [ test "output is 0 when both inputs are 0" <|
            \() ->
                orGate 0 0
                    |> Expect.equal 0
        , test "output is 1 when first input is 1" <|
            \() ->
                orGate 1 0
                    |> Expect.equal 1
        , test "output is 1 when second input is 1" <|
            \() ->
                orGate 0 1
                    |> Expect.equal 1
        , test "output is 1 when both inputs are 1" <|
            \() ->
                orGate 1 1
                    |> Expect.equal 1
        ]


halfAdderTests =
    describe "Half adder"
        [ test "sum and carry-out are 0 when both inputs are 0" <|
            \() ->
                halfAdder 0 0
                    |> Expect.equal { carry = 0, sum = 0 }
        , test "sum is 1 and carry-out is 0 when the 1st input is 0 and the 2nd input is 1" <|
            \() ->
                halfAdder 0 1
                    |> Expect.equal { carry = 0, sum = 1 }
        , test "sum is 1 and carry-out is 0 when the 1st input is 1 and the 2nd output is 0" <|
            \() ->
                halfAdder 1 0
                    |> Expect.equal { carry = 0, sum = 1 }
        , test "sum is 0 and carry-out is 1 when both inputs are 1" <|
            \() ->
                halfAdder 1 1
                    |> Expect.equal { carry = 1, sum = 0 }
        ]


fullAdderTests =
    describe "Full adder"
        [ describe "when both inputs are 0"
            [ test "and carry-in is 0 too, then both sum and carry-out are 0" <|
                \() ->
                    fullAdder 0 0 0
                        |> Expect.equal { carry = 0, sum = 0 }
            , test "but carry-in is 1, then sum is 1 and carry-out is 0" <|
                \() ->
                    fullAdder 0 0 1
                        |> Expect.equal { carry = 0, sum = 1 }
            ]
        , describe "when the 1st input is 0, and the 2nd input is 1"
            [ test "and carry-in is 0, then sum is 1 and carry-out is 0" <|
                \() ->
                    fullAdder 0 1 0
                        |> Expect.equal { carry = 0, sum = 1 }
            , test "and carry-in is 1, then sum is 0 and carry-out is 1" <|
                \() ->
                    fullAdder 0 1 1
                        |> Expect.equal { carry = 1, sum = 0 }
            ]
        , describe "when the 1st input is 1, and the 2nd input is 0"
            [ test "and carry-in is 0, then sum is 1 and carry-out is 0" <|
                \() ->
                    fullAdder 1 0 0
                        |> Expect.equal { carry = 0, sum = 1 }
            , test "and carry-in is 1, then sum is 0 and carry-out is 1" <|
                \() ->
                    fullAdder 1 0 1
                        |> Expect.equal { carry = 1, sum = 0 }
            ]
        , describe "when the 1st input is 1, and the 2nd input is 1"
            [ test "and carry-in is 0, then sum is 0 and carry-out is 1" <|
                \() ->
                    fullAdder 1 1 0
                        |> Expect.equal { carry = 1, sum = 0 }
            , test "and carry-in is 1, then sum is 1 and carry-out is 1" <|
                \() ->
                    fullAdder 1 1 1
                        |> Expect.equal { carry = 1, sum = 1 }
            ]
        ]


rippleCarryAdderTests =
    describe "4-bit ripple carry adder"
        [ describe "given two binary numbers and a carry-in digit" <|
            [ test "returns the sum of those numbers and a carry-out digit" <|
                \() ->
                    rippleCarryAdder 1001 1101 1
                        |> Expect.equal 10111
            ]
        , describe "when the 1st input is 1111, and the 2nd input is 1111"
            [ test "and carry-in is 0, the output is 11110" <|
                \() ->
                    rippleCarryAdder 1111 1111 0
                        |> Expect.equal 11110
            , test "and carry-in is 1, the output is 11111" <|
                \() ->
                    rippleCarryAdder 1111 1111 1
                        |> Expect.equal 11111
            ]
        , describe "when the 1st input is 0000, and the 2nd input is 0000"
            [ test "and carry-in is 0, the output is 0000" <|
                \() ->
                    rippleCarryAdder 0 0 0
                        |> Expect.equal 0
            , test "and carry-in is 1, the output is 0001" <|
                \() ->
                    rippleCarryAdder 0 0 1
                        |> Expect.equal 1
            ]
        ]


allTests =
    describe "4-bit Ripple Carry Adder Components"
        [ inverterTests
        , andGateTests
        , orGateTests
        , halfAdderTests
        , fullAdderTests
        , rippleCarryAdderTests
        ]
