{-| A couple of notes about the Document Oject Model (DOM),
    and how Elm represents it with functions.
    See also figures `2.1` and `2.2` in this chapter.
|-}


-- 2.1.1 -----------------------------------------------------------------------

-- Terminal commands
--
-- : #1 `elm init`
-- : #2 `elm reactor`
-- : #3 `elm make src/PhotoGroove.elm --output app.js`


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
-- It's generally better to be explicit with qualified style, which will prevent
-- us from having duplicate functions (like `String.reverse` and `List.reverse`)
-- : Qualified style is also more _self-documenting_.
--
-- `String.filter` (qualified style)
-- : Uses the module's name here and now.
--
-- `import HTML exposing (div, h1, img, text)` allows for:
-- : Using `div` instead of `Html.div`
--   (this is an unqualified style.)
--
--   - We can use unqualified style when we _expose_ the module.
--   - It imports the module, and exposes `Html.function`
--   - Possibly best to have one "family" of unqualified styles per file,
--     to avoid confusion when looking up module functions.


-- Exposing all elements --
-- The following will give us all the Html module has to offer:
--
-- `import Html exposing (..)


-- Html elements have two lists --
--
-- : List one is the attributes of the element
img [ class "large", src "./url.jpeg" ] []
-- : List two is the children elements (if any)
div [] [
  img [ src "./url.jpeg" ] [] -- Child element with no children
]



-- 2.2 -------------------------------------------------------------------------

-- Managing data flow:
-- Elm runtime --Msg--> update ----> Model ----> View --Html--> Elm Runtime



-- 2.2.1 -----------------------------------------------------------------------

-- Instead of the old days where we listend to DOM and changed on node change,
-- like `class="expanded"` or `class="collapsed"` was, basically pants and didn't scale.
--
-- For this reason, state is stored outside the DOM and passed over to the DOM
-- where necessary.
--
-- First, we declare a model (declares the state of an Elm application)
-- Next, we can initiate the model in `main`.

initialModel =
  types/data

main =
  view initialModel


-- The model holds the `state` of the data we need to pass around to `view`, and
-- perhaps other functions that need to know when things are selected, for example.
--
-- : #1 A relevant structure of data (list? Record? Nested records?)
-- : #2 The model needs to be passed around!!! If a function doesn't have access
--      to the model's current state (and it needs it) we're unable to change
--      the view/values properly.

-- Reduce, Reduce, reduce! --
-- Don't use verbose terms if you can use cleaner ones:

-- Verbose --
viewThumbnail selectedUrl thumb =
  if selectedUrl == thumb.url then
    img [ src (urlPrefix ++ thumb.url)       -- individual image if selected
        , class "selected"
        ] []
  else
    img [ src (urlPrefix ++ thumb.url) ] []  -- individual image if not selected

-- Reduced --
-- : using `classList`
--   @ http://tinyurl.com/5enp9ndh
viewThumbnail selectedUrl thumb =
  img [ src (urlPrefix ++ thumb.url)
      , classList [
        ( "selected", selectedUrl == thumb.url )  -- Tuple: "class" and boolean function
      ]
      ] []


-- Accessing records -----------------------------------------------------------

initialModel.photos
-- [{ url = "1.jpeg" },{ url = "2.jpeg" },{ url = "3.jpeg" }]
initialModel.selected
-- "1.jpeg" : String


-- Partial application of a function -------------------------------------------
-- Also known as `curried` functions. This means you don't have to pass all
-- arguments through to a function.
--
-- : In Elm, functions are curried by default! (in Javascript they're not.)
-- : To change default behavior, create a tupled function (and deconstruct it)
--   @ See `early-tests.elm` and `multiply3d` function for example.
--
-- : 1) Pass a single argument to a function that accepts two ...
-- : 2) Returns another function that takes the second argument
--
-- : `(+)` Could be thought of as:
-- : <function> : (number -> number) -> number
--
-- 🚫 #1 With curried functions, which order to you add arguments?
--    which ones do we need to access first?

partial = (+) 1  -- <function> : number -> number
partial 2        -- 3 : number

-- A simplified version of `viewThumbnail` --

urlPrefix = "http://site.com/"

viewThumbnail selectedUrl thumb =
  if selectedUrl == "1.jpeg" then
    img [ src (urlPrefix ++ thumb.url) ] []
  else
    img [] []

viewThumbnail "1.jpeg" -- 🚫 #1
-- <function> : { a | url : String } -> Html msg
viewThumbnail "1.jpeg" { url = "2.jpeg" }
-- <internals> : Html msg



-- 2.2.2 -----------------------------------------------------------------------

-- Handling events with messages and updates --
-- : A `message` is a value used to pass information from one part of the system
--   to another. I suppose a little like Racket's Universe (with handler functions)
--
--   @ http://tinyurl.com/htdp-universe-big-bang
--
-- : Elm doesn't use `addEventListener` like Javascript does,
--   rather, we write an `update` function that translates messages
--   into our desired `model`.

-- : The message should descibe _what happened_.
-- : The format of our message is up to us.
-- : It could be a string, a list, a number, ...
--
-- : Example user action triggers update function:
--   — user clicks a thumbnail

-- { Action, What was clicked }
{ description = "ClickedPhoto", data = "2.jpeg" }

-- Our update (or handler) function will:
-- 1. Look at the message received
-- 2. Look at our current model
-- 3. Use (1) and (2) to return a new model

update msg model =
  if msg.description == "ClickedPhoto" then
    -- update the model
  else
    -- use the existing model

-- Update the model --
-- : It's a bit like `set!` in lisp, but everything is supposed to
--   be immutable so I think it returns a new record.
--   @ https://docs.racket-lang.org/guide/set_.html
{ model | selectedUrl = msg.data }

-- : If we receive an unrecognized message, we return the
--   original model unchanged. This is important!
-- : Whatever else happens, the `update` function must **always**
--   return a new model, even if it's the same as the old one.

-- Html.Events and messages --
-- We also need some way to "create" the message,
-- and we're binding it to an `onClick` event:
--
-- ... (thumbnail function)
, onClick { description = "ClickedPhoto", data = thumb.url }
-- ... (end thumbnail function)


-- The main function needs to change -------------------------------------------
--
-- Up until now our `main` function has been simple:
main =
  view initialModel
-- This is "static" and passes the view a static model.
-- To make things dynamic, we'll need to make some changes!!
--
-- @ http://tinyurl.com/elm-lang-browser-module
-- @ https://elmprogramming.com/model-view-update-part-1.html
--
-- : Similar to Racket's Universe, we need a model->view->update process!
--   @ http://tinyurl.com/designing-world-programs
--
-- Using the `Browser` module we get access to the sandbox
-- : Here we take a model, a view, and an update function
-- : Update takes a model and a message, and updates the model.
--   Our `onClick` function generates the message and update
--   listens for the event.
-- : Elm doesn't re-create the entire DOM structure of the page every time,
--   but compares the old Html to the new Html and updates the necessary parts.
--   - Imagine it's like a Git file that only needs to update part of a file!
--
-- : Updates are batched to avoid expensive repaints and layout reflows.
-- : Application state is far less likely to get out of sync with the page.
-- : Replaying application state changes effectively replays user interface changes.
main =
  Browser.sandbox
    { init = initialModel  -- can be any value
    , view = view          -- what the visitor sees
    , update = update      -- what the computer sees
    }
