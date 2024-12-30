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
