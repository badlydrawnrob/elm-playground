# The Van Man

> We have an empty van and need to fill it with movies ...
> This isn't a simple problem and holds a lot of state!


## The customer journey

> Draft out the UI first with paper prototypes.
> Consider the implications of each design.
> ⚠️ Where do you start? Sketch out the user story.
> 🔍 What app architecture decisions did other apps choose? (Rotten Tomatoes)

Start with the end-user's experience in mind. Is it performing as they
would expect? Do they _really_ need this feature?

1. Are our endpoints public, private or non-existant? (e.g: reviews have no public url)
2. Is there one obvious way to do it? User intent == obvious UI/UX?
3. Does a user need to be logged in to perform an action? (Yes!)
4. What are we allowing the user to do? (add, edit, order, delete)
5. Do they have the correct permissions do do this? (only their films)
6. Are there restrictions in place (e.g: only ONE review per user)? (No)
7. Are we displaying errors right away, or on SAVE?

### 🤔 Example: Our "Add Review" from an API state

> What's the expected behaviour? What's easier for the user?

Right now we're directly saving the `Review` to the review form.
This makes things quicker, but not necessarily easier ...

"What if the user already has some data in the review form?"
"What if they want to add a review to a film that doesn't exist?"
"What if the film isn't what they wanted. How do they rectify that?"

-Film state:-
Would we have a short description for `List Film` and then full details for
`Film`? Or would we just have a single `Film` type with all the details?
Are we deleting our `Film`s one-by-one or all at once?

-Review state:-
In @rtfeldman's Elm Spa a comment can be `Editing ""` (empty), `Editing str`,
or `Sending str`. The server must respond with an `Ok` (or `Err`) before
another comment is allowed. In our version, we're saving a `Review` locally
first, then `updateFilm` to send to server. We also need to make sure a `Film`
already exists to create a review.

-Loading state:-
> A single `Status` for our `List Film` is enough.
Elm Spa also has a `Status` type with `Loaded a` states for both comments and
articles. This is overkill for our purposes (we don't ping the server right
away for comments).

    @ https://realworld-docs.netlify.app/
    @ https://tinyurl.com/elm-spa-article-status-type


### The data

> The life of a file (decisions and tradeoffs)
> Prefer minimal data wherever possible

1. Imagine that we've already created our http server!
2. What's the minimal amount of data do we need to store? (e.g: film, reviews)
3. Are we pulling from a single endpoint, or multiple? (e.g: get all reviews)
4. What does our SQL schema look like? (e.g: film, reviews by film ID)
5. How do our endpoint functions work? (e.g: `film/:id` -> implicit `List Review` w/ full text)
6. What is our resulting json structure? (e.g: film with full-text reviews)
7. How can we make life easier? (same `.jpg` file format, `[ID]` -> `ID`)

```
Film                        Review
| ID | Title      | ... |   | Timestamp  | Film ID | Name | Stars | Review |
|----|------------|-----|   |------------|---------|------|-------|--------|
| 1  | The Matrix | ... |   | 2023-10-01 | 1       | ...  | 5     | ...    |
```

I've simplified the `Review` type similar to how @rtfeldman deals with his
`Comment` type in Elm Spa example, and I've removed the `ID` field (which might
not be best practice for SQL):

    @ https://tinyurl.com/clickedPostComment-Article (line 404)
    @ https://tinyurl.com/spa-ArticleComment-post (`Http.send` is deprecated)

Another thing to note is that some ORMs return `List (Film, Review)` tuples,
so you can grab both film and review without having to make a second API call.

### Translating to Elm data structures
> How are we're going to translate this into Elm data structures?

1. What's READ ONLY data? What do we expose fully with our Elm types? (e.g: IDs)
2. Where are custom types useful? Where are they not giving any benefit?


### Error handling
> In this program, we're checking errors on SAVE event only.

1. Is our error checking simple or complex? (e.g: only check for non-empty string)
2. Which error handling method? (e.g: @rtfeldman's `List Validated` -vs- `Result.andMap`)
    - I'll use both methods to show what's possible!
3. Be strict with your `Int` types for `Stars` ...
    - Avoid the `"2:00"` problem (too many potential states)


### Our server assumptions

1. We perform an SQL join to get individual `Film`s reviews.
2. Our server endpoint `/films` returns the full film and all it's reviews
    - No need to ping a separate review API endpoint (or batch `Cmd`s)
    - No need for an `Article Preview`-style type.
3. We use the `ID` of the `Film` (rather than Elm Spa's `article-slug`)
    - @ https://realworld-docs.netlify.app/specifications/backend/api-response-format/#single-article


### Review custom type (changed to a record)

> TL;DR: Both methods are possible, but using a record type is simpler.
> If I'm regularly accessing every field, is a custom type the best choice?

We started with a `Review` custom type, which is very handy if you're wanting
to put boundaries on how your type is created and consumed (for example, only
allow it to be generated from a server call). However. It turns out we need to
decode into a `Review` in a couple of places:

- When we get a review from the `/reviews/:id` API endpoint
- When we decode from a `List Film` and want to access the reviews

The first one demands one of two routes:

- Our previous custom type requires all fields to be unpacked within the
      `Msg` (we're not saving to the model): e.g: `(Review timestamp _ _)`
- Or, we use a record type, which is quicker and easier to access. Our
      "getter" functions are ready-made for us: `review.timestamp`.

What are records useful for?

Records are useful for different fields with the same type, or lots of
values to be stored/accessed publically. Otherwise, consider using a
custom type. A custom type also allows you to AVOID nested records.

### The `Article` example from Elm Spa

In this package we're accessing our review fields in two places, and storing
them in one place (each `Film.reviews` record) in our update function. It's
important to be aware of the guarantees you're looking to create with a
custom type, and not just set "getters" (and especially not "setters") for
every single field.

The `src/Article.elm` example below is only created from a server call, and
(I think) the `src/Page/Article/Editor.elm` only displays the form data (in
new or edit mode) and we don't create an `Article a` directly. Ever. @rtfeldman
has this to say about "getters" and "setters":

    - @ ⚠️ [Beware of "getters"](https://github.com/rtfeldman/elm-spa-example/blob/cb32acd73c3d346d0064e7923049867d8ce67193/src/Article.elm#L66)

#### Notes

(1) We'll utilize `rtfeldman/elm-iso8601-date-strings` to convert times
    - @ https://timestampgenerator.com/
(2) Stars can only ever be a number between 1-5. See "Cardinality":
    - @ https://guide.elm-lang.org/appendix/types_as_sets#cardinality
    - We don't allow `.5` decimal points, and round up if a review has them.




## Narrowing the types

> Avoiding the boolean identity crisis

flat model with extensible record type signatures:
https://github.com/badlydrawnrob/elm-playground/commit/fc9dad39e490c13beeec60ec177498965cc669a9

Creating guarantees:
Only allow the `Article` to be generated from a server call. Avoid getters and setters:

- @ ⚠️ [Beware of "getters"](https://github.com/rtfeldman/elm-spa-example/blob/cb32acd73c3d346d0064e7923049867d8ce67193/src/Article.elm#L66)

Consider whether you're pulling from `/films` or `/films/:id`. The Elm Spa by
@rtfeldman pulls in the articles feed on the `Home.elm` page (I'm not 100%
sure how but uses `Article.previewDecoder`) with a `List (Article Preview)`.
The individual `Article.elm` outputs an `Article Full` type.

Both `Article`s have an `Internals` record (`Article.internalsDecoder`). It
contains a `Slug` type which is generated from the `/articles` server endpoint,
or from the `/articles/slug` url with `Url.Parser.custom` (from `Json.Decode.Pipeline`).
The `Slug` is likely the SQL string ID within the database.

@ https://web.archive.org/web/20190714180457/https://elm-spa-example.netlify.com/
@ https://realworld-docs.netlify.app/specifications/frontend/routing/

Article is always read-only and only created by the server https://tinyurl.com/elm-spa-article-internals


## Deciding on a UI route

> From all the options to a good option.
> You might want to read "Paper prototyping" book


## How many endpoints?


## When do we ping the server?

> Atomic CRUD -vs- local first

The Elm Spa `/Page/Article/Editor.elm` example updates the server at all times. It goes through the `Loaded Slug`


## Dealing with state

> It might be wise to start with paper prototypes,
> then build some 3rd-party forms,
> then (and only then) refine into your own code base.

Is our error checking simple or complex? (e.g: only check for non-empty string)
- Errors are displayed on SAVE (not automatically)
- Errors use @rtfeldman's `List Validated` type
- Errors are simple (`isEmpty`). Everything is required.
- We can implement `Result.andMap` to check for `null` values.
Which error handling method? (e.g: @rtfeldman's `List Validated` -vs- `Result.andMap`)
        - I'll use both methods to show what's possible!

In Elm Spa all state is held within the custom type (here's comments example)

@ https://tinyurl.com/clickedPostComment-Article (line 404)
@ https://tinyurl.com/spa-ArticleComment-post (`Http.send` is deprecated)

⚠️ There is one other route, which is to change the `Film` type to hold
it's own form data as well: `Film Internals (Maybe (List Review)) Form`
but there's a couple of problems with this (although in some ways it
makes our `viewFilms` functions A LOT nicer due to narrow types):

1. Elm Spa example `/Page/Article/Editor.elm` is where I got this idea
    from, similar to it's `Status` type (which holds all the state).
    That view is a lot more simple than ours however. It's just a form.
    The form has different states (new, edit, so on). The `Status` type
    looks like `Editing Slug _ Form`. The `Article` is not in the view.
2. The Elm Spa example also has it's own route (which is something like)
    `/article/new` or `/article/slug` and is therefore only interested in
    updating ONE single article.
3. This package has a `List Form`, so we're updating MULTIPLE films on
    the same page — a VERY DIFFERENT UI DECISION to Elm Spa — and we've
    also decided two things:
    - We're keeping server updates to a minimum, editing locally, then
    hitting a "save to the server" button (this might not be great UX).
    - We're keeping the `List Form` in the view at all times. This means
    our program design decisions are different to the Elm Spa example.

```elm
-- It's easier to deal with editing this data AFTER it's been added ...
-- Then we don't have to deal with a potential `TimeStamp` bug.
viewReviewForm : FilmID -> ReviewForm -> Html Msg
viewReviewForm filmID form =
    div []
        [ viewInput "text" InputName "Name" form.name
        , viewInput "text" InputReview "Review" form.review
        , viewInput "text" InputRating "Rating" form.rating
        , input
            [ type_ "hidden"
            , placeholder "TimeStamp"
            , value form.timestamp
            , onInput InputTimeStamp
            ] []
        ]
```
