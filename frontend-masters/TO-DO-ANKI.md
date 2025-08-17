# Anki learning points

1. Revisit the nice `validatedFields` setup:
    - `/part5` in `Pages/Register.elm`
2. **Non-empty strings:** See `/part6` file `Avatar.elm` line 60
    - Is it necessary to case for an empty string here?
    - We can enforce a non-empty string when the user is creating the asset.
3. The `hardcoded` option in `Json.Decode.Pipeline` can come in handy
4. **Timestamp decoder**: `|> required "createdAt" Timestamp.iso8601Decoder`
5. **INTERMEDIATE structures**, such as `JsonUser` that need further "decoding"
    - Similar to OpenLibrary messy structures, we can either:
        - Create special (complicated) decoders to render as a `Book`
        - Create an intermediate `JsonBook` that we can convert to a `Book`
        - This would be great for chaining `Http.get` requests too
6. **Familiarise yourself with `Http.post` and `Http.request` examples.**
    - Especially using the Vanguard API to login and create a session

