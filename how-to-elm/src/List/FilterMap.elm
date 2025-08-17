module List.FilterMap exposing (..)

{-| ----------------------------------------------------------------------------
    A handy function for search params
    ============================================================================
    Requires a function that converts a `value` to a `Maybe value`.
        @ https://guide.elm-lang.org/error_handling/maybe

    Lessons learned
    ---------------
    1. Careful with types: `(a -> Maybe a)` should be `b`
    2. Careful with types: `List a` should contain `List (List a)`
    3. `String.startsWith` is case-sensitive!

-}

import Html exposing (a)

-- Simple `a -> b` examples ----------------------------------------------------

filterBy : (a -> Maybe b) -> List a -> List b
filterBy func list =
    List.filterMap func list

filterByInt : List Int
filterByInt = filterBy String.toInt ["this", "is", "1", "working"]

filterByCons : List (Char, String)
filterByCons = filterBy String.uncons ["", "abc", "123"]

-- More complex examples -------------------------------------------------------

filterByHead : List String
filterByHead = List.filterMap List.head [[], ["these"], ["ones", "work"]]

filterByLambda : List String
filterByLambda = List.filterMap
                    (\str -> if String.startsWith "happy" str then
                                Just str
                            else
                                Nothing)
                    ["sad song", "happy song", "happy life"]

{- Function is case-sensitive -}
filterByLambdaX2 : List String
filterByLambdaX2 = List.filterMap
                    (\str -> if (String.startsWith "W" str) && (String.endsWith "s" str) then
                                Just str
                            else
                                Nothing)
                    ["Weekends", "what a fucking day", "wet weather is", "Words"]
