{-| A couple of notes about the dom,
    and how Elm represents it with functions.
    See also figures `2.1` and `2.2` in this chapter.
|-}

-- 2.1.1

-- Filename conventions --
-- Although I prefer lisp's (kebab-case ...), in Elm you
-- MUST be `CamelCase`. Variables should also be `camelCase`. 
-- : @ https://en.wikipedia.org/wiki/Camel_case
-- : @ https://elmprogramming.com/constant.html
-- : @ http://tinyurl.com/programming-cases
--
-- : 🚫 `src/photo-groove.elm` wrong naming convention
-- : I expect all files follow module naming convention:
--
--   | Module name  | File Path          |
--   |--------------|--------------------|
--   | Main         | ./Main.elm         |
--   | HomePage     | ./HomePage         |
--   | Http.Helpers | ./Http/Helpers.elm |


-- Documentation and comments --
--
-- Module declaration _must come before_ `module` statement.
-- Repeat! DO NOT put comments before `module` statement:
--
-- : @ https://package.elm-lang.org/help/documentation-format


-- Working with the Document Object Model (DOM)
-- HTML is shorthand for "virtual DOM node" ...
-- : We generally don't use `node` directly, but use the HTML elements
--   such as `img`, `button`, so on.
-- : The following two lines are equivalent:

node "img" [ src "logo.png" ] []
      img  [ src "logo.png" ] []

-- : It's best practice to use functions like `img` as much as possible, and to
--   fall back on `node` only when no alternative is available.

-- Commas --
-- Commas first takes some getting used to, but ...
-- : 🚫 Beware of mistakes!
-- : It's best to have commas at the start of the line, as lines can be mistaken
--   for syntactically valid Elm code — but NOT the code you intended to write.

rules = [
  rule "Do not talk about Sandwich Club.",
  rule "Do NOT talk about Sandwich Club."  -- I'm missing a comma!!!
  rule "No eating in the common area."
]

-- The above code would be mistaken for something like this:

rules = [
  (rule "Do not ..."),
  (rule "Do NOT ..." rule "No eating...")
]

-- Instead of 3 distinct lines.
-- : instead of calling `rule` 3 times, with one argument,
--   the second call to `rule` is receiving 3 arguments.

rules = [
  rule "Do not ..."
  rule "Do NOT"            -- I'm missing a comma!
  , rule "No eating ..."
]

-- The above commas first is easier to check mistakes.


-- More on the DOM structure --
-- The PhotoGroove module will render a basic DOM
--
-- : The functions that create elements — in this case, div, h1, and img
--   take exactly _two arguments_ in all cases:
--
--   1. A list of attributes (or an empty `[]` list)
        h1 [] [ text "Photo Groove" ]
--   2. A list of _child DOM nodes_ (or an empty `[]` list)
        img [ src "1.jpeg" ] []
-- : If an element has neither attributes nor children?
        br [] []


-- Qualified -vs- unqualified style
--
-- `String.filter` (qualified style)
-- : Uses the module's name here and now.
--
-- `import HTML exposing (div, h1, img, text)` allows for:
-- : Using `div` instead of `Html.div`
--   (this is an unqualified style.)
--
-- We can use unqualified style when we _expose_ the module.
-- It imports the module, and exposes `Html.function`
