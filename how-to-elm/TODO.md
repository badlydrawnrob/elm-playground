# TO DO

> This how to series is kind of messy right now.
> The goal is to code as LITTLE as possible.
> The goal is to create as SIMPLE code as possible.

For example, the `/CustomTypes` section has some bad habits:

1. Show a `Result.mapX` (this only shows the `Err` that's first)
2. Use @rtfeldman's `List ValidFields` with `List String` of errors.
3. Make `Optional` and `Nullable` the defacto way to do things (delete others)

Also go through the notes, have some concrete examples at hand, and tidy some things up so you have `BestPractice.elm` for each folder. Mention the _bad_ practices to avoid, but you don't have to code _them_ up.


## Simplify the problem

> Use the Tesla method to simplify the scope and processes
> Do this before you try and automate anything (for efficiency)
> Make the scope less dumb. YAGNI?

1. Start with the simplest thing that could possibly work.
2. What don't we need? How much can be cut?
3. Research various ways other APIs do it. What are benefits? Trade-offs?
4. What overly-complex processes can be simplified or removed?
5. Prefer a flat model with no nested records where possible.
6. Narrow the types and group data types and functions in their own module
7. Prefer speedy loading and fast server calls
    - Smaller data packets and more frequent?
    - Ping the server as little as possible?

Reduce state example:

> ⚠️ Stupid (data) decisions upfront have HORRID artifacts ...
> If there's LOTS OF STATE potential — FUCKING CHANGE IT!!!

The "2:00" problem (list all possible states to handle)
- @ https://tinyurl.com/songs-v1-possible-states (commit c25d389)


## The sentence method

> Write about this and store it someplace

> Using the sentence method to break down the problem!

1. Write out your program in plain English with a single sentence.
2. Any clauses (commas, and, then) should be split into it's own sentence.
3. Repeat the process until you have a list of single sentences.
4. Convert these into HTDP style headers (wishlist); watch out for state!
    - Which functions have ZERO state? Which have some state?

|   Our video van man can create a new film by entering it's details in a
|   form. He can also enter a `List Review`s for any film. Each film can be
|   edited, and each film's review list can be edited. These films can be
|   pulled/pushed to the server.


## App architecture

The customer journey

> Where do you start? Sketch out the user story.

There's A LOT to consider about how we allow the user to interact with our
program. Each route will have it's pros and cons. Sketch out some potential
routes and discover the complexity and tradeoffs.

- how do Discourse comments work?
- how do Stackoverflow comments work?

For example, Goodreads has `/lists` and each user's book shelf is accessible by
this endpoint. Discourse has a `/ThreadId/CommentId` structure. StackOverflow has
a link `https://stackoverflow.com/a/1801150` -> `/questions/1800783/title/1801150#1801150` answer ID but comments to answers have no public endpoint.


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
