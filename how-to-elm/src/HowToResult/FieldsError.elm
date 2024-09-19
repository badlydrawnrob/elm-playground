module HowToResult.FieldsError exposing (..)

{-| Multiple Fields Error
    =====================

    > TL;DR: There's many ways to do it. Focus on the simplest route possible
    > for now, and as you gain more experience tackle more difficult styles.


    Helpful links and guides
    ------------------------
    You can see the Elm Guide on error handling here. `Result` is the main one
    we're concerned about:

        @ https://guide.elm-lang.org/error_handling/
        @ https://guide.elm-lang.org/error_handling/maybe
        @ https://guide.elm-lang.org/error_handling/result

    The examples tend to be basic. They may contain multiple errors, but ONLY
    ONE ERROR would be shown to the user at a time. Some other ideas are below:

        @ https://tinyurl.com/elm-validate-form-fields (my original question)
        @ https://tinyurl.com/elm-form-validation-errors-eg
        @ https://tinyurl.com/elm-form-validate-simple-eg (simple hardcoded)
        @ https://package.elm-lang.org/packages/rtfeldman/elm-validate/4.0.2/
        @ https://package.elm-lang.org/packages/iodevs/elm-validate/latest/


    Gotchas and problems: a module may not be the answer
    ----------------------------------------------------
    Should we ALWAYS create a unique error checking function for our programs
    form, or can we create a shared module? Richard Feldman advised against
    using any frameworks:

        @ https://tinyurl.com/elm-validate-form-fields

    Even for a single field, there's a few problems that make life difficult. And
    with a real form, you'd likely want to check more than one field at once.
    So, if we're using this as a module, we need to be aware of:

    ⚠️ We need to know more about our program, rather than a "catch all":

        - What kind of data is the original input?
        - What kind of error checks are we wanting to put it through?
        - Is a certain field optional? Do we need to error-check it or not?
        - We need to know these things ahead of time.

    Have we got ALL the error checks we need? How do we pass them through to a
    module? Should we even be doing this?

    ⚠️ How do we combine multiple error checks for multiple fields?

        - How do we know which fields need which error checks?

    You'd need some kind of separate record for each form field, possibly with
    an ID, some text, etc, so you can log this against the actual field that's
    going to be posted. Or, you'd need multiple `Results`.


    Forms get complicated quickly
    -----------------------------

    Forms can get complicated quickly, and having a module that can cater for
    different types of forms (even for quite similar ones) might make our module
    complicated. It's probably not a wise thing to do.


    Using `.map` and `.andThen`
    ---------------------------

    `.map` allows us to use up to 5 elements to use against a function, but may
    not help us solve the multiple fields problem.


    Multiple errors should be a `NonEmptyList` ...
    ----------------------------------------------
    If you're listing all errors, you shouldn't have an `Err []` as that
    DOESN'T CONTAIN ANY ERRORS! You'd want it to be full or nothing.
-}
