module RippleCarryAdder exposing (..)

import Bitwise
import Array


andGate a b =
    Bitwise.and a b


orGate a b =
    Bitwise.or a b


inverter a =
    case a of
        0 ->
            1

        1 ->
            0

        _ ->
            -1


halfAdder a b =
    let
        d =
            orGate a b

        e =
            andGate a b
                |> inverter

        sumDigit =
            andGate d e

        carryOut =
            andGate a b
    in
        { carry = carryOut
        , sum = sumDigit
        }


fullAdder a b carryIn =
    let
        firstResult =
            halfAdder b carryIn

        secondResult =
            halfAdder a firstResult.sum

        finalCarry =
            orGate firstResult.carry secondResult.carry
    in
        { carry = finalCarry
        , sum = secondResult.sum
        }


rippleCarryAdder a b carryIn =
    let
        -- Extract digits
        ( a3, a2, a1, a0 ) =
            extractDigits a

        ( b3, b2, b1, b0 ) =
            extractDigits b

        -- Compute sum and carry-out
        firstResult =
            fullAdder a0 b0 carryIn

        secondResult =
            fullAdder a1 b1 firstResult.carry

        thirdResult =
            fullAdder a2 b2 secondResult.carry

        finalResult =
            fullAdder a3 b3 thirdResult.carry
    in
        [ finalResult, thirdResult, secondResult, firstResult ]
            |> List.map .sum
            |> (::) finalResult.carry
            |> numberFromDigits


digits number =
    let
        digits n =
            if n == 0 then
                []
            else
                (n % 10) :: digits (n // 10)
    in
        digits number
            |> List.reverse


padZeros total list =
    let
        numberOfZeros =
            total - (List.length list)
    in
        (List.repeat numberOfZeros 0) ++ list


arrayToTuple array =
    let
        firstElement =
            Array.get 0 array
                |> Maybe.withDefault -1

        secondElement =
            Array.get 1 array
                |> Maybe.withDefault -1

        thirdElement =
            Array.get 2 array
                |> Maybe.withDefault -1

        fourthElement =
            Array.get 3 array
                |> Maybe.withDefault -1
    in
        ( firstElement, secondElement, thirdElement, fourthElement )


extractDigits number =
    digits number
        |> padZeros 4
        |> Array.fromList
        |> arrayToTuple


numberFromDigits digitsList =
    List.foldl (\digit number -> digit + 10 * number) 0 digitsList



-- stringToInt string =
--     -- Strips leading '0's
--     String.toInt string
--         |> Result.withDefault -1
