module Notes exposing (..)

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

