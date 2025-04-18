module Decode.BestPractice exposing (..)

{-| ----------------------------------------------------------------------------
    Best Practice: decoding JSON
    ============================================================================
    1. Never use `Json.Decode.maybe` (is optional ok?)
    2. Store `null` values to be explicit (see `Decode.Nullable`)
    3. Keep the `json` as flat as possible! (no more than 2 levels deep)
    4. Similar `json` structure to your `Model` structure (you can change shape)
    5. Keep types as simple as possible ("2:00" problem)
    6. Never store computed values (if client compute is cheap)
    7. Better to not store custom types? (just store `String` or `Int`)
    8. Custom types are harder to decode than `alias Record`s
    9. Run some tests against BAD data (is your `json` malformed?)
    10. Use `Json.Decode as D` where function names are liable to clash.

    It's generally better to play it safe, and make sure your Elm types don't
    become out-of-sync with your json data.

    OpenLibrary (`Decode.BadAPI`) is actually standard for a public API, but it
    makes life a bit harder for us. We've got to `.andThen` or `.map` over the
    list and run _another_ API call to the (for instance) `/covers` endpoint.

    If you don't need a public API, consider simple SQL joins and serving the
    full image (or whatever) paths in the first request. It's simpler!

    Options
    -------
    1. `Json.Decode.Pipeline` has a handy `optional` function
        - You can supply a default value if the field is `null` or missing.
    2. It's extra work to convert a `List String` in json to a `Difficulty` type:
        - We've STILL got to convert that back to a string with Elm.
        - Consider if a simple `(list string)` decoder is a better option.
    3. To convert a `List String` to a `CustomType` we use `.succeed` and `.fail`
        - It's not enough to simply use a `.map`, as there's many potential strings.
        - `.map` is useful if our `String` can be transformed simply, such as:
            - `"2" -> Int`, `Dict -> Dict.name`, and so on.
            - @ https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#map
            - @ https://stackoverflow.com/a/61857967

    Questions
    ---------
    > Consider your app architecture up-front.

    - What does the end-user see?
    - What data points can we leave out?
    - How can we simplify?

    1. How many items should we decode?
        - `Json.Decode` only goes up to `.map8` (8 fields)
        - `Json.Decode.Pipeline` can handle many fields

-}

import Browser
import Json.Decode as D exposing (Decoder, andThen, field, int, list, nullable, string)
import Html exposing (Html, div, text, ul, li)
-- import Http

recipeOne: String
recipeOne =
    """
    {
        "id": 1,
        "title": "Fresh Summer Salad",
        "description": "A light and refreshing salad with mixed greens, avocado, and citrus vinaigrette.",
        "cookingTime": 15,
        "difficulty": "easy",
        "featured": false,
        "image": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800",
        "tags": ["Healthy", "Salad", "Vegan"],
        "rating": 4.5,
        "reviews": 89,
        "servings": 6,
        "ingredients": [
            "Mixed greens",
            "2 Avocado",
            "Cherry tomatoes",
            "Cucumber",
            "Red onion",
            "Citrus vinaigrette"
        ],
        "instructions": [
            "Wash and dry greens",
            "Chop vegetables",
            "Make vinaigrette",
            "Combine ingredients",
            "Toss with dressing"
        ]
    }
    """

recipeTwo: String
recipeTwo =
    """
    {
        "id": 2,
        "title": "Japanese Ramen Bowl",
        "description": "Rich and comforting ramen with tender chashu pork, soft-boiled egg, and fresh vegetables in a savory broth.",
        "cookingTime": null,
        "difficulty": "hard",
        "featured": true,
        "image": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800",
        "tags": ["Japanese", "Soup", "Noodles"],
        "rating": 4.9,
        "reviews": 204,
        "servings": 2,
        "ingredients": [
            "Ramen noodles",
            "Pork belly",
            "Eggs",
            "Green onions",
            "Nori",
            "Soy sauce",
            "Mirin"
        ],
        "instructions": null
    }
    """

-- Types -----------------------------------------------------------------------

type Difficulty
    = Easy
    | Medium
    | Hard

difficultyToString : Difficulty -> String
difficultyToString difficulty =
    case difficulty of
        Easy -> "easy"

        Medium -> "medium"

        Hard -> "hard"

{- A subset of the full recipe -}
type alias Recipe =
    { id : Int
    , title : String
    , time : Maybe Int -- Could potentially be `null`
    , difficulty : Difficulty
    , ingredients: List String
    }


-- Messages --------------------------------------------------------------------

type Msg =
    NoOp


-- Decoders --------------------------------------------------------------------

recipeDecoder : Decoder Recipe
recipeDecoder =
    D.map5 Recipe
        (field "id" int)
        (field "title" string)
        (field "cookingTime" (nullable int)) -- Can be `null` or value
        ((field "difficulty" string
            |> andThen difficultyDecoder)) -- A little confusing is this!
        (field "ingredients" (list string))

difficultyDecoder : String -> Decoder Difficulty
difficultyDecoder str =
    case str of
        "easy" -> D.succeed Easy
        "medium" -> D.succeed Medium
        "hard" -> D.succeed Hard
        _ -> D.fail "Invalid difficulty"


-- View ------------------------------------------------------------------------

view : Model -> Html msg
view model =
    div []
        (List.map viewRecipe model.recipes)

viewRecipe : Recipe -> Html msg
viewRecipe recipe =
    div []
        [ ul []
            [ li [] [ text (String.fromInt recipe.id) ]
            , li [] [ text recipe.title ]
            , li [] [ text (String.fromInt (Maybe.withDefault 0 recipe.time)) ]
            , li [] [ text (difficultyToString recipe.difficulty) ]
            , li [] [ text (String.join ", " recipe.ingredients) ]
            ]
        ]


-- Update ---------------------------------------------------------------------

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)


-- Model -----------------------------------------------------------------------
-- #! Fuck me, the `init _` underscore had me baffled ... it needs an argument,
--    even if it's empty.

type alias Model =
    { recipes : List Recipe }

init : () -> (Model, Cmd Msg)
init _ =
    ({ recipes = [] }, Cmd.none)


-- Subscriptions ---------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- Run the decoder -------------------------------------------------------------

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }
