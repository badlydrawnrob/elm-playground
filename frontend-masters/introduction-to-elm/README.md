# Introduction to Elm

> A speedy run-through with minimal notes.
> I've read _[Elm in Action](https://www.manning.com/books/elm-in-action)_ and _[Programming Elm](https://pragprog.com/titles/jfelm/programming-elm/)_
> Others who are just starting, better to slow down.

An [Introduction to Elm](https://frontendmasters.com/courses/intro-elm/), v2. It's a little pricy to join Frontend Masters ($39 per month), but you can do this in a month. For students, there's [a good deal](https://frontendmasters.com/welcome/github-student-developers/) at time of writing.

## My goals

> Design a `json`/REST API for intermediate students.
> What would that look like? What's in? What's out?
> What materials are great for light and flexible prototyping?

Not everyone wants to be a gigging programmer; some of us are founders, dabblers, learners figuring out if this thing called coding is right for us. Essentially I want to learn quickly, stay agile, reduce time spent coding, and avoid getting into the weeds with deep or niche knowledge. There's marketing to do, sales to get, people to manage, stuff to learn, and only so much one person can do.

1. I'm not a _serious_ programmer.[^1]
2. I prefer _simplicity_ wherever possible.
3. I need to create a simple `json` API.[^2]
4. The goal is business validation, not purity.
5. It's likely to change often, without forward-planning.[^3]
6. I should be able to explain high-level concepts to others.[^4]

One more thing to note is that learning knew programming languages or advanced concepts (in Elm or otherwise) has a massive overhead and days, weeks, months can drift by before you've got any real work done. The goal is to make money from your art, and to do that you need to build -> test -> build -> sell, and figure out if your idea is worth pursuing. Developers are expensive, which is the main reason I'm learning this stuff.

To not waste too much of your life in the process, that's the goal.


[^1]: Eventually I will hire and others will have the responsibility of architecture and build, but I'll need to be able to communicate my ideas with them.

[^2]: Static or lightly dynamic is fine with me. I may have to worry about data normalisation, as REST APIs often have `uuid`s that require `Http.get` chaining. Better to use simple tools wherever possible. JSON:API, Postman, and other solutions feel too confusing and advanced for my purposes.

[^3]: I don't want to over optimise or suffer from "you ain't gonna need it" problems, but it's great to be nimble and allow for change without breaking things too badly.

[^4]: Again, getting stakeholders and colleagues on board with ideas, and being able to at least visualise and mind-map at a higher level helps keep the team on track.
