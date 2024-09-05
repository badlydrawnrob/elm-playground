module HowToResult.FieldErrorRevisited exposing (..)

{-| Field Error
    ===========

    You need to SKETCH OUT THINGS better and show the flow of data.

    All the original notes are in `FieldError.elm` and should be left in.
    It's quite amazing how small decisions can make a massive difference to
    the ease and comprehension of a code base. I want it as simple as possible,
    full stop. I don't want to have to learn crazy amounts of code just for
    incremental improvements.

    It probably doesn't solve everything, but it's most the way there.


    Surprise!
    --------

    We _don't_ need a function like:

        `unpackTuple : (String, String)`

    we can use destructuring instead!

        @ https://gist.github.com/yang-wei/4f563fbf81ff843e8b1e


    Multiple inputs
    ---------------
    This is a little tricky, rather than having multiple `Msg` type for each
    input, you can specify an ID (later you could use this in the field
    record) and partially apply that function. See `Msg` for an example.

        @ https://tinyurl.com/multiple-field-inputs-msg-01

    Use Brave browser with "elm message input two arguments" for AI answer.


    Using Tuples
    ------------
    > SIMPLIFY!

    This seems to make life a bit more difficult too. Simplify! You can simply
    use two individual fields or a record type, and it'll probs be easier.
    Leave as-is for now.


    Append more than one `String`
    -----------------------------

    "this" ++ "that" you could wrap in parens
    OR use String.concat ["list", "of", "strings"]


    Errors
    ------
    #! Here I could probably be more efficient (we're converting `String.toInt`
    in two places)


    Learning from mistakes
    ----------------------
    Elm Lang compiler erros are FAR more helpful than the ones I've seen in
    Purescript so far, when you're tired you make LOTS of silly mistakes. I'd
    be pretty stuck without it.


    At first I had the `checkAndSave` function using `Ok (f,s)` as if the
    `Result` gave out a `Tuple String String`, but it DOESN'T, it gives
    out a record! See this commit for some glaring errors:

        @ https://tinyurl.com/e0d9643

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)

{- No custom types, as it's not necessary and adds more code -}

{- Error checks kept short and sweet, so no need for special header -}

{-| Data is fucking EASY to understand what all the inputs might be.
No Elm `Float` "zero decimal" errors. No multiple changing of data.
Very few `Maybe` types.

""  (invalid `Int`)
"s" (invalid `Int`)

Minutes
-------
"2"  (valid minutes)
"20" (invalid minutes)
"0"  (invalid minutes)

Seconds
-------
"20" (valid seconds)
"61" (invalid)
"00" (valid)
"0"  (invalid)           -- #! This is the only error not covered?

-}

-- #!
-- You can use this function for both minutes and seconds
-- You might still have to deal with `Maybe`, but I've left it out.
checkErrors : Input -> Result String SongRunTime
checkErrors tuple =
    let
        checkNumbers =
            case tuple of
                (f,s) ->
                    (checkMinutes (String.toInt f))
                        && (checkMinutes (String.toInt s))
    in
    case checkNumbers of
        True  -> Ok (extractMinsAndSecs tuple)
        False -> Err "The number is not in range"

-- I forgot to do this!
extractMinsAndSecs : Input -> SongRunTime
extractMinsAndSecs i =
    { minutes = extractInt (Tuple.first i)
    , seconds = extractInt (Tuple.second i)
    }

extractInt : String -> Int
extractInt i =
    case String.toInt i of
        Nothing -> 100 -- #! What on earth do I put here? Make sure it fails.
        Just int  -> int

-- Now for our `Boolean` statements
-- (0, 10] or [0, 60] (intervals)
checkMinutes : Maybe Int -> Bool
checkMinutes minutes =
    case minutes of
        Nothing   -> False
        Just mins -> mins <= 10 && mins > 0

checkSeconds : Maybe Int -> Bool
checkSeconds seconds =
    case seconds of
        Nothing  -> False
        Just sec -> sec <= 60 && sec >= 0


-- Update ----------------------------------------------------------------------

-- You could use a `Maybe Int` here if you wanted for `mins` and `seconds` but
-- I can't be bothered. They can default to zero for now.

type alias Input =
    (String, String)

type alias SongRunTime =
    { minutes : Int
    , seconds : Int
    }

type alias Model =
    { userInput : (String, String)
    , fieldError : String
    , savedInput : SongRunTime
    }

type Msg
    = UpdateInput String String  -- An ID and the VALUE
    | SaveInput

initialModel =
    { userInput = ("", "")
    , fieldError = ""
    , savedInput = { minutes = 0, seconds = 0} -- Could be `Maybe Int`
    }



-- Update ----------------------------------------------------------------------

{- We need to pass the info through to the model -}
update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput "minutes" str
            -> { model | userInput = Tuple.mapFirst (\_ -> str) model.userInput }

        UpdateInput "seconds" str
            -> { model | userInput = Tuple.mapSecond (\_ -> str) model.userInput }

        UpdateInput _ _ -> model

        SaveInput
            -> checkAndSave model

checkAndSave : Model -> Model
checkAndSave model =
    let
        errors = checkErrors model.userInput
    in
    case errors of
        Err str  -> { model | fieldError = str }
        Ok srt   -> { model
                    | userInput = ("", "") -- reset
                    , fieldError = ""       -- reset
                    , savedInput = srt
                    }



-- View ------------------------------------------------------------------------

-- See `Form/SingleField.elm` for notes on this form!
-- #! Are there any ways to join two fields inputs easily? (to tuple)
-- #! How to handle multiple fields? Multiple messages?

view : Model -> Html Msg
view model =
    form [ class "float-input", onSubmit SaveInput ]            -- (a)
            [ input
                [ type_ "text"
                , placeholder "Please add minutes ..."
                , value (Tuple.first model.userInput)           -- (b)
                , onInput (UpdateInput "minutes")             -- (c)
                ]
                []
            , input
                [ type_ "text"
                , placeholder "Please add seconds ..."
                , value (Tuple.second model.userInput)
                , onInput (UpdateInput "seconds")
                ]
                []
            , p [ class "field-error" ]
                [ text model.fieldError ]
            , button [] [ text "Save" ]
            , div [ class "display-result" ]
                [ p [] [
                    strong [] [ text "Success: " ]
                    , (grabMinutesAndSeconds model.savedInput)
                    ]
                ]
            ]

-- createMinutesAndSecondsInput : String -> String -> Tuple String
-- createMinutesAndSecondsInput s1 s2 =
--     Tuple.pair s1 s2

grabMinutesAndSeconds : SongRunTime -> Html Msg
grabMinutesAndSeconds srt =
    text (String.concat
            [ (String.fromInt srt.minutes)
            , "."
            , (String.fromInt srt.seconds)
            ])


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
