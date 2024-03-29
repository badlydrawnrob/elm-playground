module Notes exposing (..)

{-|

    I DON'T UNDERSTAND TESTING AND IT'S PLUGINS VERY WELL.
    ------------------------------------------------------

    I think I need to go over it a handful of times to get it.
    Especially looking through the docs and figuring out how the
    pieces fit together – it's not very easy for me at all.

    It kind of makes you disheartened, as some of the tests are easy,
    but some of them seem to be almost as much work as writing the damn
    functions in the main module — testing `view` for instance.

    For that reason, these notes don't cover the whole of the chapter.
    For now I'm just concentrating on making the fucking thing work for
    very simplified usecases, and not worry about testing too much.

    I can test it manually if it's small enough, or very small tests
    that'll test the Json decoders.

|-}

-- 6.1 -------------------------------------------------------------------------

-- The compiler can do a lot for us, but we should still test our
-- business logic to make sure it does what we expect it to do.
--
-- `elm-explorations` packages might be a core package someday.
--
-- Install `npm install elm-test`
-- Run `npx elm-test init`

elm-test init

-- Sets ups three things:
--
-- 1. A new folder called tests
-- 2. A file inside that folder called Example.elm
-- 3. A new dependency in our elm.json file
--
-- elm-test init also installed a package called `elm-explorations/test`
-- as a test dependency. A test dependency’s modules are available only
-- when running tests, meaning only modules we put in this new `tests/`
-- directory will be able to access them.
--
-- The application’s dependencies and test dependencies are listed in that
-- `elm.json` file. We’ll dive into this file in greater depth in appendix B.

-- Elm module names must match their filenames. If we kept the first
-- line as module Example but renamed the file to PhotoGrooveTests.elm,
-- we would get an error when we ran our tests.


-- Test-driven development -----------------------------------------------------

-- Here we're writing tests _after_ we've created our code.
-- That's not the only way to do it. It can be helpful to write
-- tests _before_ finishing the initial version of the business
-- logic itself, to guide implementation and help reveal design flaws.

-- In Elm, a _unit test_ is a test that runs once, and whose test logic
-- does not perform effects. (In chapter 4, you learned that an effect
-- is an operation that modifies external state.)

-- Notice that the argument the test function receives is not an actual
-- Expectation value, but rather an anonymous function that returns an
-- Expectation.

suite : Test
suite =
    test "one plus one equals two" (\_ -> Expect.equal 2 (1 + 1))

-- What exactly is the throwaway value that gets passed to that function?

test : String -> (() -> Expectation) -> Test
--                ^^

-- Here we can see that the anonymous function we’re passing has the
-- `type () -> Expectation`, which means the only possible value it
-- can be passed is `()`. Because a function like that must always
-- return the same value every time it is called, one of the few things
-- it’s useful for is to delay evaluation.

-- Our test will only be evaluated when that `() -> Expectation` function
-- is called. It helps to perform optimizations such as running tests in
-- parallel. And stuff.


-- Getting access to our program --
--
-- This will import all values exposed by our PhotoGroove module.
-- We can check which values a module exposes by looking at its first line.

import PhotoGroove

-- Uh-oh! It looks like we’re exposing only main at the moment.
-- By default, Elm modules hide their values from the outside
-- world — an excellent default, as we will see in chapter 8!
--
-- If we want to access photoDecoder from PhotoGrooveTests,
-- we’ll have to expose it too — in our `PhotoGroove.elm` file:
--
-- `module PhotoGroove exposing (main, photoDecoder)`
--                                     ^^^^^^^^^^^^

decoderTest : Test
decoderTest =
    test "title defaults to (untitled)"  -- test description
      (\_ ->
        "{\"url\": \"fruits.com\", \"size\": 5}"  -- anon func wrapper
          |> decodeString PhotoGroove.photoDecoder             --
          |> Expect.equal                                      --
            (Ok { url = "fruits.com", size = 5, title = "" })  -- decoding the json
      )

-- You may recall the decodeString function from chapter 4. It takes a decoder and a
-- string containing some JSON, then returns a Result:

decodeString : Decoder val -> String -> Result String val


-- Tidying up the Json ---------------------------------------------------------

-- That JSON string is pretty noisy with all those backslash-escaped
-- quotes, though. Let’s clean that up a bit.

jsonTripleQuote =
  """
  {"url": "fruits.com", "size": 5}
  """

-- 1. Triple-quoted strings can span across multiple lines.
-- 2. Triple-quoted strings can contain unescaped quotation marks.


-- Using Pipeline --------------------------------------------------------------

-- It’s no coincidence that the record on the bottom is the record at
-- the end of our pipeline.
--
-- As long as our test code is written in a pipeline style that ends in
-- `|> Expect.equal`, we should be able to look at our code side by side
-- with the test output and see by visual inspection which value Expect.equal received as which argument. The value at the top in our test should line up with the value at the top of the console output, and the value on the bottom in our test should line up with the value on the bottom of the console output.

-- It’s useful to start with an intentionally failing test and then fix it.
-- This helps avoid the embarrassing situation of accidentally writing a test
-- that always passes! After you’ve seen the test fail, and then fixed it—or,
-- even better, fixed the implementation it’s testing—you can have more
-- confidence that the test is actually verifying something.


-- The left pipe operator <| ---------------------------------------------------

funcSubtract a b = a - b

funcSubtract 10 <| 2

test "title defaults to (untitled)"
  (\_ -> ... )

test "title defaults to (untitled)" <|
  \_ -> ...


-- 6.1.3 -----------------------------------------------------------------------

-- Narrowing test scope --------------------------------------------------------

-- Our test’s description says "title defaults to (untitled)", but we're
-- actually testing much more than that. We’re testing the structure of the
-- entire Photo!
--
-- If we were to update the structure of `Photo` like adding a neew field,
-- the test will break.
--
-- We’ll have to come back and fix it manually, when we wouldn’t have needed
-- to if the test did not rely on the entire Photo structure. Even worse,
-- if something breaks about url or size, we’ll get failures not only for the
-- tests that are directly responsible for those, but also for this unrelated
-- test of title.
--
-- Those spurious failures will clutter up our test run output!
--
-- Result.map
-- Apply a function to a result. If the result is Ok, it will be converted.
-- If the result is an Err, the same error value will propagate through.

Result.map : (a -> value) -> Result x a -> Result x value

"""{"url": "fruits.com", "size": 5}"""
  |> decodeString PhotoGroove.photoDecoder
  |> Result.map (\photo -> photo.title)  -- 1
  |> Expect.equal (Ok "(untitled)")  -- 2

-- 1) We added a step to our pipeline
-- 2) We changed Ok to the narrower test of (Ok "(untitled)")

-- Similarities to other map functions:
       List.map : (a -> b) -> List     a  -> List     b
Json.Decode.map : (a -> b) -> Decoder  a  -> Decoder  b
     Result.map : (a -> b) -> Result x a  -> Result x b

-- 1. Takes a data structure with a type variable we’ve called a here
-- 2. Also takes an (a -> b) function that converts from a to b
-- 3. Returns a version of the original data structure in which the type variable is b instead of a

-- Here's some examples:

       List.map   String.fromInt            [ 5 ] ==        [ "5" ]
Json.Decode.map   String.fromInt     (succeed 5)  == (succeed "5")
     Result.map   String.fromInt          (Ok 5)  ==      (Ok "5")

-- Transforming a container’s contents is the main purpose of map, but
-- in some cases map does not transform anything, and returns the original
-- container unchanged:

       List.map  String.fromInt             [] ==             []
Json.Decode.map  String.fromInt (fail "argh!") == (fail "argh!")
     Result.map  String.fromInt        (Err 1) ==        (Err 1)

-- 1) List.map has no effect on [].
-- 2) Json.Decode.map has no effect on decoders created with fail.
-- 3) Result.map has no effect on Err variants.

Result.map : (a -> b) -> Result x a -> Result x b  -- x cannot be passed through to (a -> b) function
--                              ^^

Result.mapError : (x -> y) -> Result x a -> Result y a  -- but it can be here.
--                ^^^               ^^^

-- So passing `Err` value to `Result.map` does nothing
-- And passing a `Ok` value to a `Result.mapError` does nothing either
-- It's all in the type signature, as to how the function affects it's values.

identity : a -> a
identity a = a

-- This function knows so little about it's argument that it can't do anything
-- to it. For example, if it tried to divide whatever it received by 2, it would
-- have to be `identity : Float -> Float` instead.
--
-- The only way to implement an Elm function with the type `a -> a` is to have
-- it return its argument unchanged.
--
-- Inferring implementation details like this can speed up bug hunting.
-- Sometimes you can track a bug just by looking at a functions type.
-- If the function couldn't possibly affect the problematic value, you're clear
-- to move on and search elsewhere.

-- Reducing our anonymous function by refactoring ------------------------------
--
-- Writing `.title` by itself gives us a function that takes a record,
-- and returns the contents of it's title field. It's exactly the same as
-- `(\photo -> photo.title)` function, but shorter.

"""{"url": "fruits.com", "size": 5}"""
  |> decodeString PhotoGroove.photoDecoder
  |> Result.map (\photo -> photo.title)  -- 1
  |> Expect.equal (Ok "(untitled)")

  |> Result.map .title  -- 1


List.map .title [{url = "string", title = "title"}, {url = "string2", title = "bother"}]
-- ["title","bother"] : List String


-- 6.2 -------------------------------------------------------------------------

-- Writing fuzz tests ----------------------------------------------------------

-- It can be time consuming to hunt down _edge cases_ in tests.
-- In Elm, _fuzz tests_ help us detect edge case failures by writing
-- one test that verifies a large number of randomly generated inputs.
--
-- These run several times with randomly generated inputs. Also known as
-- _fuzzing, generative testing, property-based testing, or QuickCheck-style
-- testing_.
--
-- Often you'll start with a unit test and convert into a fuzz test.

{..} -- from one manual record input

{..}
{..}
{..} -- to multiple automated record inputs


-- 6.2.1 -----------------------------------------------------------------------

-- Replace hardcoded Json string with code to generate Json programatically.

-- We used `Json.Decode` module to turn Json into Elm values.
-- We can use `Json.Encode` to turn Elm values into Json

-- Whereas the Json.Decode module centers around the Decoder abstraction,
-- the Json.Encode module centers around the Value abstraction. A Value
-- (short for Json.Encode.Value) represents a JSON-like structure.
--
-- In our case, we will use it to represent actual JSON, but it can
-- represent objects from JavaScript (like the JavaScript event objects
-- we decoded in chapter 5) as well.

Encode.int    : Int                    -> Value
Encode.string : String                 -> Value
Encode.object : List ( String, Value ) -> Value
--                     ^^^^^^  ^^^^^

-- For Json (or Javascript) objects:
--    The key must be a String
--    The value can be Int, Float, String, etc.
--
-- """{"url": "fruits.com",
--     "size": 5}"""

encoded =
  Encode.object
    [ ( "url", Encode.string "fruits.com" )
    , ( "size", Encode.int 5 )
    ]

-- We represent the same JSON structure as we did with `photoDecoder`
-- with the above functions.


-- Next steps --
--
-- 1. Call `Encode.encode` to convert `Value` to a `String` (and use our
--    `decodeString photoDecoder call to run our decoder on that JSON string)
-- 2. Don't bother calling `Encode.encode` and instead swap out our
--    `decodeString photoDecoder` call for a call to `decodeValue photoDecoder`
--    instead.
--
-- Like decodeString, the `decodeValue` function also resides in the Json.Decode
-- module. It decodes a Value directly, without having to convert to and
-- from an intermediate string representation.
--
-- That’s simpler and will run faster, so we’ll do it that way.

Encode.encode 0 encoded
-- "{\"url\":\"fruits.com\",\"size\":5}" : String


fuzz2 string int "the fuzz test notes" <| \str int -> ...
--    ^^^^^^ ^^^
      string : Fuzzer String
      int : Fuzzer Int


-- Fuzz.string --
--
-- `Fuzz.string` does not generate strings completely at random.
-- It has a higher probability of generating values that are likely
-- to cause bugs: the empty string, very short strings, and very long strings.
--
-- Similarly, Fuzz.int prioritizes generating 0, a mix of positive and
-- negative numbers, and a mix of very small and very large numbers.
--
-- Other fuzzers tend to be designed with similar priorities.


-- 6.2.2 -----------------------------------------------------------------------

-- Testing update functions --
--
-- The entire application state is represented by a single `Model` value
-- Model changes only when `update` receives a `Msg` and returns new `Model`
-- `update` is a plain old function, so we can call it from tests.

update : Msg -> Model -> ( Model, Cmd Msg )

-- 1) Call `update` in a test, passing the `Msg` and `Model` of our choice
-- 2) Examine the `Model` it returns

-- REDACTED THE CHAPTER 05 CODE --
--
-- But this is what it'd look like to check the following message:

SlidHue hue ->
  applyFilters { model | hue = hue }

-- It looks simple enough, but that `applyFilters` function could change it
-- in ways we don't expect (if it gets updated) so here's how we'd do it:

slidHueSetsHue : Test
slidHueSetsHue =
  fuzz int "SlidHue sets the hue" <|
    \amount ->
      initialModel
        |> update (SlidHue amount)  -- Returns (Model, Cmd.none)
        |> Tuple.first              -- Model
        |> .hue                     -- Aceesses `hue` key
        |> Expect.equal amount      -- Compares `hue` value
        --              ^^^^^^      -- Should match the amount we passed to test

-- ERROR: TEST WON'T COMPILE ---------------------------------------------------

-- If you tried to run this test it won't compile.
-- You MUST expose the `update` function as well as the following:

module PhotoGroove exposing
  (Model, Msg(..), Photo, initialModel, main, photoDecoder, update)


-- ERROR: COMMANDS -------------------------------------------------------------

-- Currently `elm-test` does not support testing commands directly.
-- You can work around this if you modify your `update` function, by
-- making a custom type that represents all the commands your application
-- can run.
--
-- See pg. 185/186 in the pdf


-- 6.2.3 -----------------------------------------------------------------------

-- Creating multiple tests with one function --
-- For functions that behave in exactly the same way, it may be an idea
-- to run a shared test (that is running more than one test in a test function)
--
-- The photo filter sliders are a good case for this:
--
-- 1) All of them are sliders
-- 2) All of them take an int
--
-- When one of the tests in the given list fails, elm-test will print out
-- not only that test’s description, but also the string passed to describe
-- as the first argument here.
--
-- The testSlider function is a generalized version of our slidHueSetsHue
-- test from earlier.
--
-- See `Table 6.5` on pg 187 of pdf

sliders : Test
sliders =
  describe "Slider sets the desired field in the Model"
    [ testSlider "SlidHue" SlidHue .hue
    , testSlider "SlidRipple" SlidRipple .ripple
    , testSlider "SlidNoise" SlidNoise .noise
    ]

testSlider : String -> (Int -> Msg) -> (Model -> Int) -> Test
testSlider description toMsg amountFromModel =
  fuzz int description <|
    \amount ->                   -- fuzz `int`
      initialModel               -- inital model
        |> update (toMsg amount) -- i.e: `SlidHue amount`
        |> Tuple.first           -- Model
        |> amountFromModel       -- i.e: .hue (from Model)
        |> Expect.equal amount   -- fuzz `int`

-- Take a look at the type of `testSlider`
testSlider : String -> (Int -> Msg) -> (Model -> Int) -> Test
testSlider description toMsg amountFromModel =

-- It's 3 arguments correspond to what we want to customize about the
-- `SlidHue` test
--
-- 1) `description : String` lets us use descriptions other than "SlidHue sets the hue".
-- 2) `toMsg : Int -> Msg` lets us use messages other than SlidHue.
-- 3) `amountFromModel : Model -> Int` lets us use model fields other than .hue.
--
--  `testSlider` function returns a Test,
-- `describe` takes a `List Test`
--
-- This compiles because the SlidHue variant is a function whose type is
-- `SlidHue : Int -> Msg`, which is what the `toMsg` argument expects,
-- and because the `.hue` shorthand is a function whose type is
-- `.hue : Model -> Int`, which is what the amount `FromModel` argument expects.


-- 6.3 -------------------------------------------------------------------------

-- Testing views --
--
-- We render thumbnail photos in different ways:
--
-- 1) Initially we don't render them
-- 2) Once photos load, we render a thumbnail for each of them
-- 3) When you click a thumnail, that photo becomes selected
--
-- By writing tests we can guard against breaking changes if we change other
-- parts of our program. We'll write tests to verify all three of these rules.
--
-- We expose some new modules, as well as `view` so we can import it.
-- We'll also expose `Status(..)` and `urlPrefix` ...

import Html.Attributes as Attr exposing (src)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag, attribute)

import PhotoGroove exposing (Model, Msg(..), Photo, Status(..),
initialModel, update, urlPrefix, view)

-- in the `PhotoGroove.elm` file:
exposing (Model, Msg(..), Photo, Status(..),
  initialModel, main, photoDecoder, update, urlPrefix, view)
--                               ^^^^^^^^^^^^^^^^^^^^  ^^^^

-- Building a Query.Single --
--
-- The first part of the pipeline is this:

initialModel
  |> PhotoGroove.view  -- Html Msg
  |> Query.fromHtml    -- div [ class "content" ]

-- Builds a representation of the DOM to examine

  |> Query.findAll [ tag "img" ]   -- Query.Single msg -> Query.Multiple msg
  |> Query.count (Expect.equal 0)  -- Query.Multiple msg -> Expectation

-- will return all the img tags in the DOM tree beneath the
-- `div [ "content" ]` at the root of our Single query.

-- As you may recall, Expect.equal takes two arguments and compares
-- them to verify that they’re equal. That means these two expressions
-- are equivalent:

Query.count (Expect.equal 0)
Query.count (\count -> Expect.equal 0 count)


-- When tests get bigger and longer --------------------------------------------

-- As our test suites get larger, it can be handy to run only a few tests
-- at a time. Take a look at the `Test.skip` and `Test.only` functions in
-- the documentation for the elm-explorations/test package on the
-- `https://package.elm-lang.org` website. We can also run only a few test
-- files at a time by passing them as arguments to elm-test; for example,
-- elm-test tests/ DecoderTests.elm or elm-test tests/User/*.elm.



-- 6.3.2 -----------------------------------------------------------------------

-- Fuzzing view tests --

-- It’s better to use `Expect.atLeast 1` than `Expect.equal 1` because our
-- business logic permits duplicate thumbnail URLs, and we wouldn’t want
-- our test to incorrectly reject repeats as invalid.

thumbnailRendered : String -> Query.Single msg -> Expectation
thumbnailRendered url query =
  query
    |> Query.findAll [ tag "img", attribute (Attr.src (urlPrefix ++ url)) ]
    |> Query.count (Expect.atLeast 1)

-- We use (urlPrefix ++ url) for our src check instead of url because that’s
-- what our viewThumbnail implementation does.
--
-- Now that we have a function to test whether a single thumbnail was rendered,
-- let’s use it to build a function that tests whether all thumbnails were rendered.
--
-- We can get better test cov- erage by using fuzz tests to randomly generate
-- URLs, and build photos from those!

photoFromUrl : String -> Photo
photoFromUrl url =
  { url = url, size = 0, title = "" }

list : Fuzzer a -> List (Fuzzer a)

fuzz (list string) "Urls render as thumbnails" <|
  \urls ->

-- This will randomly generate a list of strings we can
-- use for our thumbnail urls (prepending `urlPrefix`)


-- Don't create too many randomly created urls! --------------------------------

-- Performance and speed of tests
-- ------------------------------
--
-- Remember that fuzz tests run 100 times by default.
--
-- If those tests generate 300 URLs on average, the total traversal count would
-- be 300 × 300 × 100 — so we’d be looking at _nine million traversals_ in
-- a single test run. That test would take, uh . . . a bit of time to run.
--
-- So let’s not do that!
--
-- When test suites start taking a long time to run, it slows down the
-- whole team. Tests accumulate, and it’s important to be mindful of their
-- performance characteristics to avoid letting slowdowns accumulate as well.

fuzz (Fuzz.intRange 1 5)  -- This will limit the amount of urls we create
--         ^^^^^^^^


-- Fuzzer map --

Fuzz.map : (a -> b) -> Fuzzer   a -> Fuzzer   b
