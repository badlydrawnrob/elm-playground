# Articles to write?

Code should be simple to write and read.
It's going to be read later; write for your stupid future self.

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


## Write out the routes

> Write out your options (Draw!).
> Consider their implications.
> Write the function headers and types.
> What can be simplified?

Data structures:

1. What data structure options do we have?
2. What are the benefits and trade-offs of each?
3. What's read-only? What's exposed? (Opaque types etc)

Data flow:

1. How might the program look given these decisions?
2. How complicated is it likely to get?
3. Do we have any unecessary or complex types? (Custom types etc)
4. What guarantees do we need? (Stringly typed -vs- `Name String` etc)
5. Is our app littered with nested `Result`s and `Maybe`s?
    - Type signatures should be simple
    - `Result`s should be unpacked in the `Msg` (or update)

Unecessary state:

> Look at the steps the user needs to take to achieve a goal.
> These should be reduced and complicated logic removed.

1. Our data decisions have artifacts (the "2:00" problem)
2. How much state can be removed to get the desired result?
3. Can we simplify our app architecture and decouple code?
    - A good example is "journey of a meal" ...
    - Better to have a dedicated page for this?
