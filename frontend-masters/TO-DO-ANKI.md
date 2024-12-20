# Anki learning points

1. Revisit the nice `validatedFields` setup:
    - `/part5` in `Pages/Register.elm`
2. Non-empty strings: See `/part6` file `Avatar.elm` line 60
    - Is it necessary to case for an empty string here?
    - We can enforce a non-empty string when the user is creating the asset.
3. The `hardcoded` option in `Json.Decode.Pipeline` can come in handy
4. Timestamp decoder such as: `|> required "createdAt" Timestamp.iso8601Decoder`

