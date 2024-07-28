module FormWithResult.Form exposing (..)

{-| A simple form that's validated with `Result`
    ============================================

    Questions to be answered
    ------------------------

    1. How might you add the validation errors in-place with the form field?
    2. Is `Result` the best way to do this, or is there a better method?
        - For instance, we could use a `List error` or something.

    Notes on the comments
    ---------------------

    I'm not sure I like the way the `{-|-}` comments look. I quite like having
    things tidy — comments at the start of each section, with a number that
    references the part of the code we're talking about.

    The `{-|-}` method is quite useful when hovering over the function where it's
    used to get a definition however.

    The jury is out on that one!

-}

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, classList, disabled, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)

type alias Entries =
    { id : Int
    , entry : String
    , entries : List Entry
    }

type alias Entry =
    { id : int
    , text : String
    }

type alias Model =
    Entries


initialModel : Model
initialModel =
    { id = 0
    , text = ""
    , entries []
    }


-- View ------------------------------------------------------------------------

{-| Our simple form ...

1. A bit dirty using anonymous function. Loops through the `entryList`.

2. Our simple form field, which we'll have to validate before we allowing the
   user to submit (using the `update` function and a `case` on `Result`)

    - In this version we don't care if `entryList` is empty `[]` ...
    - "/programming-elm/RefactorEnhance/Picshare04.elm" on line 95  has an
      example function which output `text ""` if `[]`. It's quite easy.

    `onSubmit SaveEntry` passes a `Msg` we can `case` on ...
    `value comment` takes our `model.entry` as a value, and updates as our
    model updates with our `onInput Comment` message.


-}
viewForm : Entry -> List Entry -> Html Msg
viewForm entry entryList =
    div []
        [ ul [ class "entry-list" ]
            (List.map (\_ -> li [] [ text _ ]) entryList)  -- (1)
        , form [ class "new-entry", onSubmit SaveEntry ]   -- (2)
            [ input
                [ type_ "text"
                , placeholder "Add your cool entry here ..."
                , value entry                             -- (2)
                ]
            ]
        ]

view : Model -> Html Msg
view model =
    main_ []
        [ div [ class "wrapper" ]
            [ h1 [] [ text "Testing a simple form" ] ]
        , section [ class "form" ]
            [ viewForm model.entry model.entries ]
        ]
