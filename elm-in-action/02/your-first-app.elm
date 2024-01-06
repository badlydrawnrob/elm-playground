{-| Something goes here
    but I'm not sure what
    quite yet.
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

