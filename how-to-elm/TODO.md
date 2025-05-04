# TO DO

> This how to series is kind of messy right now.
> The goal is to code as LITTLE as possible.
> The goal is to create as SIMPLE code as possible.

For example, the `/CustomTypes` section has some bad habits:

1. Show a `Result.mapX` (this only shows the `Err` that's first)
2. Use @rtfeldman's `List ValidFields` with `List String` of errors.
3. Remove all versions where a `UserInput` is used. Store a `String` only.
4. Aim to simplify the `Album` and `Song` version, where you can edit:
    - An `Album`s fields (but not it's `ID`)
    - An `Album`s `List Song` (one at a time)
5. Make `Optional` and `Nullable` the defacto way to do things (delete others)

Also go through the notes, have some concrete examples at hand, and tidy some things up so you have `BestPractice.elm` for each folder. Mention the _bad_ practices to avoid, but you don't have to code _them_ up.

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

## Other

1. `SingleFieldNotes.elm` is incomplete. Better as a README?
2. Check `ToDoSimple.elm` works properly. Consolidate learning.
