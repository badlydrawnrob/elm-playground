{-|
    Rules:
      Design Guidelines: https://package.elm-lang.org/help/design-guidelines
      Styleguide: https://elm-lang.org/docs/style-guide
      Other styleguides: https://github.com/NoRedInk/elm-style-guide
                         https://gist.github.com/laszlopandy/c3bf56b6f87f71303c9f
                         https://github.com/ohanhi/elm-style-guide

      1. All View functions should be prepended with `view`?
      2. Helper functions seem to ignore this, so ...
      3. Perhaps it's all functions that return `Html` start with `view`?
      4. The `()` type (known as unit) is both a type and a value.
         `function () = ...` only accepts the value `()`.
      5. The type `Program () Model Msg` refers to an Elm Program with no flags,
         whose model type is `Model` and whose message type is `Msg`.

    Earlier versions:
      1. Chapter 02: http://tinyurl.com/elm-in-action-chapter-02-done
      2. Update with `if`: http://tinyurl.com/elm-in-action-update-if
      3. Update with `case`: http://tinyurl.com/elm-in-action-update-case
      4. Chapter 03: http://tinyurl.com/elm-in-action-chapter-03-done
-}
