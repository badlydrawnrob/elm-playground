module Playground exposing (..)

import Html


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


speed distance time =
    distance / time


time startTime endTime =
    endTime - startTime


add a b =
    a + b


multiply c d =
    c * d


divide e f =
    e / f


(+++) first second =
    first ++ second



-- CASE


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


hashtag dayInNumber =
    case weekday dayInNumber of
        "Sunday" ->
            "#SinDay"

        "Monday" ->
            "#MondayBlues"

        _ ->
            "#NoDayLikeToday"


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


revelation =
    """
  It became very clear to me sitting out there today that every decision Ive made in my entire life hash been wrong. My life is the complete "opposite" of everything I want it to be. Every instinct I have, in every aspect of life, be it something to wear, something to eat - it's all been wrong.
  """


simpleList =
    [ 1, 2, 4 ]


descendingList a b =
    case compare a b of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ


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



-- Good: piping functions
-- - Not good: (too "many" (chaining 32 (functions 7.56)))


main =
    [ "Night King", "Joffrey", "Ramsay" ]
        |> List.sortWith evilometer
        |> toString
        |> Html.text



-- [ 316, 320, 312, 370, 318, 314 ]
--     |> List.sortWith descendingList
--     |> toString
--     |> Html.text
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
