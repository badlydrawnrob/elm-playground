{-| What we're trying to achieve:

    - Improve code quality to help new team members get up to speed.
    - Let users choose between small, medium, and large thumbnails.
    - Add a Surprise Me! button that randomly selects a photo.
|-}

-- 4.0 -------------------------------------------------------------------------

-- Talking to servers --
-- We'll grab photos from the cloud,
-- associate some metadata to each photo
-- and display it on top of the big photo.

-- 4.1 -------------------------------------------------------------------------

-- Our model needs to change --
--
-- We won't have the data automatically,
-- we'll now have to send a server request
-- and build our model from external data.
--
-- If there's a problem, display an error message.
--
-- : 1) We're still loading pictures (initial state)
-- : 2) There's been a server error (display error)
-- : 3) Data successfully loaded. (grab photos, display one)

type Status
  = Loading
  | Loaded (List Photo) String
  | Errored String

-- This represents all possibilities of state.
--
-- : We could've also used a _list zipper_ data structure.
--   That's like a `List` that has exactly one of it's elements
--   marked as selected.
--
-- : We could replace `Loaded (List Photo) String with a `Loaded`
--   variant that contains a single value, a list zipper.
--
--   @ List zippers (Learn you an Elm — difficult) http://tinyurl.com/ycxyy7kt
--   @ Elm Package: http://tinyurl.com/elm-lang-list-zippers
