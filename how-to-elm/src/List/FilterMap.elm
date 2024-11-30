module List.FilterMap exposing (..)

{-| ----------------------------------------------------------------------------
    A handy function for search params
    ============================================================================
    Requires a function that converts a `value` to a `Maybe value`.
        @ https://guide.elm-lang.org/error_handling/maybe

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
