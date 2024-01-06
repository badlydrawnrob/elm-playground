{-| A couple of notes about the dom,
    and how Elm represents it with functions.
    See also figures `2.1` and `2.2` in this chapter.
|-}

-- 2.1.1

-- HTML is shorthand for "virtual DOM node"
-- : We generally don't use `node` directly, but use the HTML elements
--   such as `img`, `button`, so on.
-- : The following two lines are equivalent:

node "img" [ src "logo.png" ] []
      img  [ src "logo.png" ] []

-- : It's best practice to use functions like `img` as much as possible, and to
--   fall back on `node` only when no alternative is available.

-- Commas --
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
