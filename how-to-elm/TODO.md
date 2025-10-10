# TO DO

> This how to series is kind of messy right now.
> The goal is to code as LITTLE as possible.
> The goal is to create as SIMPLE code as possible.

Books like Programming Elm, later stages of Elm in Action, and (haven't read it but) Practical Elm all make learning harder than it has to be with jargon and overly logical writing. Some things are very difficult to explain however, in statically typed functional languages.

Write a little about over-using custom types, or certain situations when they make sense.
Write a little about complicated UI state and better to heavily paper prototype first (+ Tally).
Write about the tradeoffs between developer ease and fancy user-experience.
Write about your learning frame (and not doing things like `Passport` text processing)
Write about the time it takes to do proper programming ...
      and the fact that it's all moot if your fucking marketing doesn't work ...
      so code as little as possible and validate your ideas in the easiest, fastest, way!
Write about hiding behind research and practicing and not getting s* done ...
      learn "just enough" and "just in time"

1. Always pick the option that seems "simplest" and easy to read
    - The `Films` setup is a bit mad in retrospect!
        - BASICALLY AVOID FORMS UNTIL YOU KNOW EXACTLY WHAT WORKS (and what doesn't)
            - Figure out the paper prototyping for a good while with Tally forms
        - Sharing form fields is a bad idea (sharing a form view is ok)
        - Lots of form state (and multi-forms) on a page gets complicated and hard to read?
        - Thinking about types and complexity upfront is really essential.
        - Reducing potential bugs by planning out data conflicts is helpful.
        - Reducing state-per-page is a (poorer?) user experience but better developer one.
    - The 5 finger rule (do I understand enough of it?)
    - The read it later rule (future stupid self)
    - @rtfeldman [forms](https://github.com/rtfeldman/elm-spa-example/blob/cb32acd73c3d346d0064e7923049867d8ce67193/src/Page/Settings.elm#L370) -vs- @dwayne [elm-form](https://package.elm-lang.org/packages/dwayne/elm-form/latest/)
        - I find the former's design easier to understand (without tutorial) than the latter (less "magic" too)
    - Easiest to hardest in top-to-bottom order (if in the same file)
    - Never sacrifice readability for the sake of DRY (and abstractions)
        - See the `SaladBuilder` example in Programming `type_ "radio"` button abstraction
2. Always have a learning frame in mind
3. Go through the files with this learning frame ...
4. Cherry pick what's IN and what's OUT
    - E.g: I'm NEVER going to write a file reader (like `Form.Passport`)
5. Rearrange your `/how-to-elm` to reflect this new approach
6. Aim for ONE learning point per package (at least in future)
    - E.g: `Films.elm` could be around app architecture (multiple forms, -vs- one form per page)
    - E.g: `Songs.elm` focuses on custom types, and so on.
7. Action the learning in a REAL project quickly!



## Bugs

1. A recurring error is html or js caching, so new changes don't show.
    - Use `elm-watch` or flush the cache (#! what about end-user's browser?)
    - [Force clear cache with js](https://locall.host/force-clear-browser-cache-javascript)


## Some changes

For example, the `/CustomTypes` section has some bad habits:

1. Show a `Result.mapX` (this only shows the `Err` that's first)
2. Use @rtfeldman's `List ValidFields` with `List String` of errors.
3. Make `Optional` and `Nullable` the defacto way to do things (delete others)

Also go through the notes, have some concrete examples at hand, and tidy some things up so you have `BestPractice.elm` for each folder. Mention the _bad_ practices to avoid, but you don't have to code _them_ up.

## Films

1. The TimeStamp problem could be avoided by change in UI
2. The `Success films` branch could avoid having any `model.fields` within it?
    - It's natural to have a form field _within_ the `viewFilm` function for reviews ... but it means having to pass the whole `Model` in.
    - You could narrow the types with a `model.reviewForm` so you pass in less of the model
    - Or you could have the review form OUTSIDE of the `Success films` branch

## URL

1. **[Lydells](https://package.elm-lang.org/packages/lydell/elm-app-url/latest/) app url type** (simpler than Url package)
2. Elm Land url (look up some examples)

## Elm Land

Have a little go with a different repository.

## Books and Recipes

> Perhaps these ones are good, or abstract them into similar.

1. Search for an ISBN number and populate the fields if correct!
2. Add a book to a `Group` type (and add `Thema` codes) — shelves.
3. Create a `Recipe` for `@out` and `@in` (similar but NOT the same )
    - https://elm-radio.com/episode/life-of-a-file/
4. User profile details (do we have `Model` on same page or different?)
    - For now our `List Book` and `User Deets` are in the same `json` file.
5. Uploading an image (it can wait for now, as we'll use Tally forms)
    - This might be useful for covers, as they're not always available.
6. [Set the storage](https://github.com/evancz/elm-todomvc/blob/f236e7e56941c7705aba6e42cb020ff515fe3290/src/Main.elm#L36C19-L36C35) so our model can always be up-to-date and shared between pages

## Other

1. `SingleFieldNotes.elm` is incomplete. Better as a README?
2. Check `ToDoSimple.elm` works properly. Consolidate learning.


