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
    11. Be careful of your types! We're expecting `List Recipe` (not `Recipe`)

    It's generally better to play it safe, and make sure your Elm types don't
    become out-of-sync with your json data.

    OpenLibrary (`Decode.BadAPI`) is actually standard for a public API, but it
    makes life a bit harder for us. We've got to `.andThen` or `.map` over the
    list and run _another_ API call to the (for instance) `/covers` endpoint.

    If you don't need a public API, consider simple SQL joins and serving the
    full image (or whatever) paths in the first request. It's simpler!

    Security
    --------
    > Some things can be public without worrying about security.

    `Http.get` is very simple. It doesn't require any headers. For ease-of-writing
    you might like to keep your `json` documents READ-ONLY, or at least allow them
    to be read without a `X-Access-Key`. This would pull in the data without a
    secret key. However, it'd be public to ANYONE, so you'd have to consider
    CORS to block domains.

    > If it's private, do NOT store secrets in version control!
    > I'll have to regenerate a secret and recompile this package every time.

    Unfortunately, Elm doesn't have a `.env` file or similar. The easiest way to
    manage secrets is by using a `Environment` module. You could have one for
    development and one for production. You'd have to build each program with
    the correct environment.

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
    4. In a production app, you'd probably want to load `json` automatically:
        - A `Loading | Error | Success` type to handle the state of the request.
        - Your `Recipe`s would likely be a `Maybe (List Recipe)`, incase of an
          empty response. You might like to _enforce_ a non-empty list.
        - See @ https://elm-lang.org/examples/book for union type.

    Questions
    ---------
    > Consider your app architecture up-front.

    - What does the end-user see?
    - What data points can we leave out?
    - How can we simplify?

    1. How many items should we decode?
        - `Json.Decode` only goes up to `.map8` (8 fields)
        - `Json.Decode.Pipeline` can handle many fields

    Wishlist
    --------
    1. Remove the `Debug`er and replace with proper error checking.

-}

import Browser
import Debug
import Json.Decode as D exposing (Decoder, andThen, field, int, list, nullable, string)

import Html exposing (Html, article, button, div, h1, hr, text, ul, li)
import Html.Events exposing (onClick)
import Http

import Url.Builder exposing (crossOrigin)


-- Example JSON ----------------------------------------------------------------
-- Our API actually nests this structure under a `record` key, so we need to
-- extract that in our `Http.request`!

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


-- Environment variables -------------------------------------------------------
-- (1) Our `Url.Builder` doesn't require a trailing slash, otherwise it'll fail
--     and look like `https://api.jsonbin.io//` with two slashes.

secret : String
secret =
    "$2a$10$zwCBSPJWDJ5t1v/ck/sBk.iF/gDNUWRmWuCmJeJzQdtX89vcstZ9W"

url : String
url =
    "https://api.jsonbin.io" -- We're using `Url.Builder` so doesn't need trailing slash


-- URL builder -----------------------------------------------------------------
-- The API version, `b` for bin, and specific bin ID

api : String
api =
    crossOrigin url ["v3", "b", "680117848a456b79668b8c5d"] []


-- Request ---------------------------------------------------------------------
-- (1) This is a little verbose, only because we set a `X-Access-Key` header.
-- (2) Our response actually contains a `record` key, so we need to extract that.

request : Cmd Msg
request =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-Access-Key" secret ] -- (1)
        , url = api
        , body = Http.emptyBody
        , expect = Http.expectJson LoadedJson (D.at ["record"] (list recipeDecoder)) -- (1)
        , timeout = Nothing
        , tracker = Nothing
        }


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

type Msg
    = ClickedButton
    | LoadedJson (Result Http.Error (List Recipe))


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
-- Here we're not using any conditional loading. We'll keep it super basic, so
-- if there's no `List Recipe` returned, we simply show an empty list. Our error
-- message shows in the first `div` if there's a problem with our `Http.request`.

view : Model -> Html Msg
view model =
    article []
        [ div []
            [ h1 [] [ text "Here's an example of best practice API decoder" ]
            , viewButton "Load JSON"
            , text
                (if (String.isEmpty model.error) then "No errors!"
                 else model.error)
            , hr [] []
            ]
        , div []
            (List.map viewRecipe model.recipes)
        ]

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

viewButton : String -> Html Msg
viewButton content =
    button [ onClick ClickedButton ] [ text content ]

-- Update ---------------------------------------------------------------------

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ClickedButton ->
            (model, request) -- Action the API call (returns `Recipe`s)

        LoadedJson (Ok response) ->
            ({ model | recipes = response }, Cmd.none)

        LoadedJson (Err error) ->
            -- There are many potential errors, so we'll just log it for now
            ({ model | error = Debug.toString error }, Cmd.none)


-- Model -----------------------------------------------------------------------
-- #! Bugs, bugs, bugs! Sometimes the Elm error messaging isn't obvious. For a
--    good 30 minutes I didn't track down that `init` needed to be `init _`, as
--    it expects an empty `()` flags unit (in the type signature)

type alias Model =
    { recipes : List Recipe
    , error : String }

init : () -> (Model, Cmd Msg)
init _ =
    ({ recipes = [], error = "" }, Cmd.none)


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
