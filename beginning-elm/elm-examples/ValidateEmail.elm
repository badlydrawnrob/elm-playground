module PlaygroundTwo exposing (..)

import Html
import Regex


validateEmail email =
    let
        emailPattern =
            Regex.regex "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b"

        isValid =
            Regex.contains emailPattern email
    in
        if isValid then
            ( "Valid email", "green" )
        else
            ( "Invalid email", "red" )


main =
    validateEmail "thedude@rubix.com"
        |> toString
        |> Html.text
