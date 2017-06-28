module CustomTypes exposing (..)


type Greeting a
    = Howdy
    | Hola
    | Namaste String
    | NumericalHi Int Int


sayHello : Greeting a -> String
sayHello greeting =
    case greeting of
        Howdy ->
            "How y'all doin'?"

        Hola ->
            "Hola amigo!"

        Namaste message ->
            message

        NumericalHi value1 value2 ->
            value1 + value2 |> toString


type alias Movie =
    { name : String, releaseYear : Int }


releasedIn2016 : Movie -> Bool
releasedIn2016 movie =
    movie.releaseYear == 2016
