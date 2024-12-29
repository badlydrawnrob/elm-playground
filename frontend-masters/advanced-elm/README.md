# Introduction to Elm

> Minimal notes for the parts I'm new to. Other useful books:
> - [Elm in Action](https://www.manning.com/books/elm-in-action)
> - [Programming Elm](https://pragprog.com/titles/jfelm/programming-elm/)
>
> ⚠️ **See [#common-complaints] for dependency hell.** Our lesson is 5 years old and there's so many broken dependencies, it might not last long.

[Advanced Elm](https://frontendmasters.com/courses/intro-elm/), using Elm version `0.19`. It's a little pricy to join Frontend Masters ($39 per month), but you can do this course in a month. For students, there's [a good deal](https://frontendmasters.com/welcome/github-student-developers/) at time of writing.

You can find the repository and tutorial files [here](https://github.com/rtfeldman/elm-0.19-workshop). You can also see notes in local at `Documents/Library/code/elm`.

## My goals

> ⭐ Only learn essentials. No wasteful learning.
> ⭐ Where I don't need to code, DON'T. Focus on more important tasks.

What would a `json` API for intermediate students look like?

- What would you leave out?
- What materials are best for light, flexible, prototyping?
- What technologies can you leave out?
- What's evergreen and long-lasting?

## Coding for founders

> Not everyone wants to be a gigging programmer;
> some of us are founders, dabblers, dipping our toes in ...

Coding is not for everyone. It can take a few years to learn if it's something you want to pursue as a career, and many years to become great at. I've already spent 10 years at it and I'm never going to be a good programmer. I want to learn only the things I need to prototype and business-test, learn quickly, stay agile, reduce the amount of time spent coding, and fail fast. Niche and deep knowledge of programming is NOT for me.

There's marketing to do, sales to get, people to manage, stuff to learn, and only so much one person can do.

## Not my business

1. I'm not a _serious_ programmer.[^1]
2. I prefer _simplicity_ wherever possible.
3. I need to create a simple `json` API.[^2]
4. The goal is business validation, not purity.
5. It's likely to change often, without forward-planning.[^3]
6. I should be able to explain high-level concepts to others.[^4]
7. Complex architecture is not my job.
8. Large programs are not my job.

## Learning overhead

> **To not waste too much of your life in the process, that's the goal.**
> Learning knew programming languages or advanced concepts (in Elm or otherwise) has a massive overhead and days, weeks, months can drift by before you've got any real work done.

The goal is to **make money from your art**, and to do that you need to `build -> test -> build -> sell`, and **figure out if your idea is worth pursuing**. Developers are expensive, which is the main reason I've had to learn this stuff.


## Positives

> **It's an interesting way to teach:**
> 1. Introduce concepts (he compares to `.js`)
> 2. Scaffolding knowledge with finger exercises
> 3. Gradually increase complexity[^5]

1. Talk about `Html` structures with increasing difficulty
2. "To Do" tasks based on what we've talked about
3. `H1` and `p` with simple variables ...
4. To `classList` and `List.map` and other useful functions
5. Silent features/knowledge is introduced also, whereby you can familiarise yourself to new concepts.
6. These silent features are needed to make the "to do" tasks possible (such as `import Html` etc).


## Common complaints

> **Dependency Hell: packages and dependencies are too old.**
> Vulnerabilities or things that stop working, depending on versions.

1. We have **LOTS of dependencies** for our server.
2. There are **117 warnings** (things get outdated quickly).
3. The Node/npm ecosystem is a **hotspot for dependency hell**.
4. [Building servers](https://moleculer.services/docs/0.14/runner.html) and backend systems is **not my job**.[^6]


[^1]: Eventually I will hire and others will have the responsibility of architecture and build, but I'll need to be able to communicate my ideas with them.

[^2]: Static or lightly dynamic is fine with me. I may have to worry about data normalisation, as REST APIs often have `uuid`s that require `Http.get` chaining. Better to use simple tools wherever possible. JSON:API, Postman, and other solutions feel too confusing and advanced for my purposes.

[^3]: I don't want to over optimise or suffer from "you ain't gonna need it" problems, but it's great to be nimble and allow for change without breaking things too badly.

[^4]: Again, getting stakeholders and colleagues on board with ideas, and being able to at least visualise and mind-map at a higher level helps keep the team on track.

[^5]: Each task has a small framework of "silent" Elm features which are required but not essential to understand right now. It's quite a smart way to gradually expose the learner. You could also introduce bugs to fix, and refactoring code "the Elm way", such as helper functions.

[^6]: It's at this point I bow out. I'm up for running SQL queries, simple `Http` with `json`, and light UI for prototyping, but I'm not in the habit of doing database admin, complicated setup, or "proper" heavier weight programming.
