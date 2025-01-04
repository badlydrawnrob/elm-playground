module Result.FieldMapping exposing (..)

{-| ----------------------------------------------------------------------------
    Mapping: a few examples
    ============================================================================
    You're basically "lifting" the values over the "wall" of a `Result`, which
    will be `Err`or or `Ok value`. The the whole point of `mapN`, `andMap`,
    `andThen` is to do "error handling" and "exit" as soon as one is encountered!

    `elm-community/result-extra` comes with some handy features:

        @ https://tinyurl.com/elm-comm-result-extra-andMap
        @ https://tinyurl.com/elm-comm-result-extra-combine

-}

import Result.Extra exposing (andMap)

-- `Result.map` with `Result.toMaybe` ------------------------------------------

type alias Song =
    { title : String
    , time : (Int, Int)
    }

type alias Field a =
    { input : String
    , valid : Result String a
    }

validInputString : Field String
validInputString = Field "Hounds of Love" (Ok "Hounds of Love")

validInputMins : Field Int
validInputMins = Field "2" (Ok 2)

validInputSecs : Field Int
validInputSecs = Field "30" (Ok 30)

{- Takes 3 arguments and ... -}
mapResult : Result String String ->
            Result String Int ->
            Result String Int -> Result String Song
mapResult = Result.map3 (\title mins secs -> Song title (mins, secs))

{- Succeeds with a `Song` ... -}
workingResult : Result String Song
workingResult = mapResult validInputString.valid validInputMins.valid validInputSecs.valid

{- Or fails with first `Err` message -}
failedResult : Result String Song
failedResult = mapResult validInputString.valid validInputMins.valid (Err "This fails")

{- Possibly more useful than a simple `Result` as we can `case` on this, as in
`CustomTypes.Songs` module update function! -}
createMaybe : Maybe Song
createMaybe = failedResult |> Result.toMaybe


-- `Result.Extra.andMap` -------------------------------------------------------

createAndMap : Result String Song
createAndMap =
    Ok (\title mins secs -> Song title (mins, secs))
    |> Result.Extra.andMap validInputString.valid
    |> Result.Extra.andMap validInputMins.valid
    |> Result.Extra.andMap validInputSecs.valid
