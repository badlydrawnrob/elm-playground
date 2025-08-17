module Form.Email exposing (validateEmail)

{-| ----------------------------------------------------------------------------
    Email (with Regex)
    ============================================================================
    Some helpful links:
        @ http://html-to-elm.com
        @ hecrj/html-parser (package)
        @ elm-explorations/markdown (Github)
        @ pablohirafuji/elm-markdown (package)

    Wishlist
    --------
    1. Add some color (red or green)
    2. Present user with error message ("username or password incorrect")
        - Be careful of oversharing which risks a brute force hack!
        - @ https://ux.stackexchange.com/questions/111830
    3. Add log files? (backend, probably)
-}

import Regex


type alias Email
    = Maybe String

validateEmail : String -> Email
validateEmail userinput =
    let
        pattern = Regex.regex "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b"
        isEmailStr = Regex.contains pattern userinput

    in
        if isEmailStr then
            Email userInput
        else
            Nothing
