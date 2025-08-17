# Auth0

> The Auth0 documentation is a friggin' nightmare, but it's useful
> for simple login, with minimal user data. Seems GDPR compliant (UK).

You can use `--data` or `--header 'Authorization: Bearer <ACCESS_CODE>` and get the same results. Add the `--verbose` flag after `curl` for full details.

```terminal
curl -v --request POST \
  --url https://dev-ne2fnlv85ucpfobc.uk.auth0.com/userinfo \
  --header 'content-type: application/json' \
  --data '{"access_token": "<TOKEN>"}'
```

## Refresh token

> I haven't managed to get this to work yet.

Not so straight forward. For my type of app, you can remove the `client_secret` code ... it might be easier to simply extend the lifetime of the original token, then login again.

- [Refresh tokens](https://auth0.com/blog/refresh-tokens-what-are-they-and-when-to-use-them/) and when to use them.
- [Refresh token endpoint](https://auth0.com/docs/secure/tokens/refresh-tokens/get-refresh-tokens)

