module Playground exposing (..)

import Html
import Regex
import MyList exposing (..)


escapeEarth : Float -> Float -> String -> String
escapeEarth velocity speed fuelStatus =
    let
        escapeVelocityInKmPerSec =
            11.186

        orbitalSpeedInKmPerSec =
            7.67

        whereToLand fuelStatus =
            if fuelStatus == "low" then
                "Land on droneship"
            else
                "Land on launchpad"
    in
        if velocity > escapeVelocityInKmPerSec then
            "Godspeed"
        else if speed == orbitalSpeedInKmPerSec then
            "Stay in orbit"
        else
            whereToLand fuelStatus


speed : Float -> Float -> Float
speed distance time =
    distance / time


time : number -> number -> number
time startTime endTime =
    endTime - startTime


multiply : number -> number -> number
multiply c d =
    c * d


divide : Float -> Float -> Float
divide e f =
    e / f


(+++) : appendable -> appendable -> appendable
(+++) first second =
    first ++ second



-- CASE


weekday : number -> String
weekday dayInNumber =
    -- Case is the same as:
    --
    -- if dayInNumber == 0 then
    --     "Sunday"
    -- else if dayInNumber == 1 then
    --     ...
    case dayInNumber of
        0 ->
            "Sunday"

        1 ->
            "Monday"

        2 ->
            "Tuesday"

        3 ->
            "Wednesday"

        4 ->
            "Thursday"

        5 ->
            "Friday"

        6 ->
            "Saturday"

        _ ->
            "Unknown day"


hashtag : number -> String
hashtag dayInNumber =
    case weekday dayInNumber of
        "Sunday" ->
            "#SinDay"

        "Monday" ->
            "#MondayBlues"

        _ ->
            "#NoDayLikeToday"


whereToPark : Float -> String
whereToPark speed =
    case speed of
        7.67 ->
            "Low Earth Orbit"

        3.8 ->
            "Medium Earth Orbit"

        3.07 ->
            "Geostationary Orbit"

        _ ->
            "Nowhere"


revelation : String
revelation =
    """
    It became very clear to me sitting out there today that every decision Ive made in my entire life hash been wrong. My life is the complete "opposite" of everything I want it to be. Every instinct I have, in every aspect of life, be it something to wear, something to eat - it's all been wrong.
    """


simpleList : List number
simpleList =
    [ 1, 2, 4 ]


descendingList : comparable -> comparable -> Order
descendingList a b =
    case compare a b of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ


evilometer : String -> String -> Order
evilometer character1 character2 =
    case ( character1, character2 ) of
        ( "Joffrey", "Ramsay" ) ->
            LT

        ( "Joffrey", "Night King" ) ->
            LT

        ( "Ramsay", "Joffrey" ) ->
            GT

        ( "Ramsay", "Night King" ) ->
            LT

        ( "Night King", "Joffrey" ) ->
            GT

        ( "Night King", "Ramsay" ) ->
            GT

        _ ->
            GT


addOne : number -> number
addOne x =
    x + 1


guardiansWithShortNames : List String -> Int
guardiansWithShortNames guardians =
    guardians
        |> List.map String.length
        |> List.filter (\x -> x < 6)
        |> List.length


add : Int -> Int -> Int
add x y =
    x + y


signUp : String -> String -> Result String String
signUp email age =
    case String.toInt age of
        Err message ->
            Err message

        Ok age ->
            let
                emailPattern =
                    Regex.regex "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b"

                isValidEmail =
                    Regex.contains emailPattern email
            in
                if age < 13 then
                    Err "You need to be at least 13 years old to sign up"
                else if isValidEmail then
                    Ok "Your account has been created successfully"
                else
                    Err "You entered an invalid email"


type alias Character =
    { name : String
    , age : Maybe Int
    }


sansa : Character
sansa =
    { name = "Sansa"
    , age = Just 19
    }


arya : Character
arya =
    { name = "Arya"
    , age = Nothing
    }


getAdultAge : Character -> Maybe Int
getAdultAge character =
    case character.age of
        Nothing ->
            Nothing

        Just age ->
            if age >= 18 then
                Just age
            else
                Nothing


list1 : MyList a
list1 =
    Empty


list2 : MyList number
list2 =
    Node 9 Empty



-- Good: piping functions
-- - Not good: (too "many" (chaining 32 (functions 7.56)))


main : Html.Html msg
main =
    isEmpty list2
        |> toString
        |> Html.text



-- [ "Night King", "Joffrey", "Ramsay" ]
--     |> List.sortWith evilometer
--     |> toString
--     |> Html.text
-- [ 316, 320, 312, 370, 318, 314 ]
--     |> List.sortWith descendingList
--     |> toString
--     |> Html.text
--
--
-- Html.text revelation
--
-- whereToPark 7.67
--     |> Html.text
--
-- hashtag 1
--    |> Html.text
--
-- escapeEarth 10 6.7 "low"
--     |> Html.text
--
-- Html.text ("Peanut butter " +++ "and jelly")
-- divide 30 10
--     |> multiply 10
--     |> add 5
--     |> toString
--     |> Html.text
--
-- time 2 3
--     |> speed 7.67
--     |> escapeEarth 11
--     |> Html.text
