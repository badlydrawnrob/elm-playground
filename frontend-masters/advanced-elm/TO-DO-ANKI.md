# Anki learning points

> Stick to the "essential" stuff to learn for now

1. Be aware that `elm-spa` uses _opaque types_ a lot ...
    - And uses `as Viewer` or `as Cred` and ...
    - Gets values with `Viewer.cred` ...
    - Which is accessing a record field (from a custom type `Internals`)
    - Be careful of GETTERS. The whole point of opaque types is to hide implementation details. Read only.
2. Open records -vs- extensible types
    - Give two simple examples
    - Give a more convoluted example in `Article Internals (Full (Body String))`
    - Write a simple reason _why_ we're using that and `Article Internals Preview`
    - Why is this "better' than using open records? When are open records best?
3. Create a couple of examples of `Task.perform` and `Task.attempt`, understanding how `/Page/Article.elm` in the Elm Spa example works, and why the updated version [doesn't make use of `Task.attempt`](https://tinyurl.com/elm-spa-example-article-task).
    - It uses `Cmd.batch`, but everything in the list must be of same type!
    - It also uses `Article.fetch` which grabs from `Api.Endpoint`
    - So create a simplified version of the above:
        - Take a look at `Article`, `Page/Article`, etc.
        - Bear in mind he's using `Http.send` which is deprecated
        - See: https://sporto.github.io/elm-workshop/05-effects/04-tasks.html
