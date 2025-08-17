# Anki learning points

> Stick to the "essential" stuff to learn for now

1. Use a mock example of an Opaque Type, using `Viewer` and `Cred` as examples:
    - Create a record field similar to `Internals`
    - Try to hook it up to Vanguard Auth
    - **Be careful of GETTERS. The whole point of opaque types is to hide implementation details. Read only.**
2. Open records -vs- extensible types
    - Note the open records from my `/how-to` examples
    - Use the `Article Internals (Full (Body String))` example
    - Write a simple reason _why_ we're using that and `Article Internals Preview`
    - Why is this "better' than using open records? When are open records best?
        - I have a feeling open records are only really for type annotations
        - It seems @rtfeldman prefers to use extensible types
        - **Rewatch the videos on this segment**
3. Create an example of `Task.attempt` (as well as the simpler `Task.perform`)
    - Add it to `/how-to-elm/Task/`
    - Everything in the list must be of the same type (`Cmd.batch` -> `Cmd Msg`)
    - It uses `Cmd.batch`, but everything in the list must be of same type!
    - The tutorial version is a bit different than the current `elm-spa` app.
        - That uses `Article.fetch` which grabs from `Api.Endpoint`
        - https://tinyurl.com/elm-spa-article-fetch-endpoint
        - It doesn't seem to use any `Task.attempt` at all
    - `Http.send` is deprecated, so use `Http.post` or `Http.request` instead.
    - Other tasks? https://sporto.github.io/elm-workshop/05-effects/04-tasks.html

