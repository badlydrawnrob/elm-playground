module Result.MapInput exposing (..)

{-| ----------------------------------------------------------------------------
    Mapping an input (mocked)
    ============================================================================
    > Previously was using a very poor approach!

    The program has been mocked and hardcoded to show how we might use the
    mapping function for `Result`. Coding the input validation this way is far
    from ideal as it uses too many `Result`s which are different types! See
    `Form.ListError` for a better approach.


    Lessons learned
    ---------------
    1. Duplicate data should be avoided in the Model
    2. Computed data should rarely be stored in the Model
    3. Custom types are not required for user input
    4. Reduce the amount of `Result` types in the Model

    Previous inputs looked like this in `Model`:

        `Field "Hounds of Love" (Ok "Hounds of Love")`
        `Field "2" (Ok 2)`

    This has the following problems:

        (a) See above intro
        (b) Way more complex than needed
        (c) `List Result` has different types
        (d) Too many arguments in `Result.map` functions


    Lifting data
    ------------
    > With a `Result` you "lift" over the "wall" of its type.

    Why make life harder than it needs to be? First start from the assumption
    that a simpler type is available without requiring the lift.

    Next consider if you can have one single `Result` to lift the entire object
    or collection, rather than individual `Result`s. The same applied for other
    liftable types like `Maybe`. `Result Error (Maybe a)` is mostly shitty too!


    Too many arguments
    ------------------
    > Previously a function took 3 `Result String a` arguments

    Reduce the amount of arguments in a function by composing functions and
    simplifying the type signatures. You can first treat functions like a black
    box with interfaces, where you're passing data around.

        mins secs -> (mins, secs)
        time tuple -> Song title time


    Useful packages
    ---------------
    > `elm-community/result-extra` comes with some handy features.

    Now that we've reduced our `Result` types to a single result, these aren't
    really necessary, but could be useful in future.

        @ https://tinyurl.com/elm-comm-result-extra-andMap
        @ https://tinyurl.com/elm-comm-result-extra-combine


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. Are multiple `Result`s ever a good idea?
    2. View and update are not implemented
    3. Properly validate the inputs and show errors
    4. Add more songs to the list (the proper way)
    5. Send to server?
-}

import Browser
import Html exposing (Html)
import Result.Extra exposing (andMap)

import Debug



-- Model and types -------------------------------------------------------------


{-| Our field inputs -}
type alias Model =
    { title : String
    , mins : Int
    , secs : Int
    , songs : List Song
    }

{-| Type to convert form to -}
type alias Song =
    { title : String
    , time : (Int, Int)
    }

type Msg
    = NothingToSee

inputs : List String
inputs =
    [ "Hounds of Love", "2", "30" ]

songTitle : Result String String
songTitle =
    (Ok "Hounds of Love")

songMins : Result String Int
songMins =
    (Ok 2)

songSecs : Result String Int
songSecs =
    (Ok 30)

songs : List Song
songs =
    [ { title = "Afraid", time = (3, 28) } ]


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
    Html.div []
        (List.map viewSongTitle model.songs )

    -- Debug.todo "Make the form and error messages work here"

viewSongTitle : Song -> Html msg
viewSongTitle { title } =
    Html.p [] [ Html.text title ]


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
    Debug.todo "Update the form fields, submit and make list of songs"

{-| This seems harder to achieve with `Result.map2` -}
result : Result String Song
result =
    Ok (\t tuple -> Song t tuple)
    |> Result.Extra.andMap songTitle -- Ok "Hounds of Love"
    |> Result.Extra.andMap
        (Result.map2 Tuple.pair songMins songSecs) -- Ok (2, 30)


-- Main ------------------------------------------------------------------------

init : Model
init =
    { title = ""
    , mins = 0
    , secs = 0
    , songs =
        songs ++
            [ (Result.withDefault (Song "Nope" (0,0)) result) ]
    }

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }

