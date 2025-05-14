module Auth.Auth0
    exposing
        ( auth0AuthorizeURL
        , Auth0Config
        , Endpoint
        , getAuthedUserProfile
        , IdToken
        , logoutUrl
        , Profile
        , decoder
        , updateUserMetaData
        , updateProfile
        , UserID
        )

{-| This library provides data types and helper functions for [Auth0](https://auth0.com)

> Auth0 documentation is hard to get through, but this package is useful for a
> simple authentication setup. We're a little limited what we can do with a SPA
> (without using Auth0.js or the SDKs). For more advanced needs, I'd consider a
> different framework.

This package uses the "Implicit Flow". You could alternatively use `/oauth/token`
endpoint, or the SDK provided by Auth0; that will involve using Ports however.
Previous releases used `id_token`, but (I think) this is now not recommended.

By default, when the user logs in, you'll get a prompt that "app is requesting
access to your account" which they'll have to accept. You can skip user consent:
go to `Applications -> APIs -> (select the api) -> Settings -> Access Settings`
and turn on "Allow Skipping User Consent".

Limitations:

1. It's less secure than an SDK: don't store the `AccessKey` or any sensitive data.
    - It can be potentially viewed by anyone, as it's client-side.
2. The `user_metadata` is not recommended to be changed by a client-side app:
    - Technically it's only the logged-in user that's making changes, but see (1);
      it's less secure. You _could_ use the Management API on the frontend.
    - You can edit the `user_metadata` manually or on the back-end.
3. The free plan comes with rate limits on the API
    - @ [See rate limits](https://auth0.com/docs/troubleshoot/customer-support/operational-policies/rate-limit-policy/rate-limit-configurations/free-public)

We're now using `(Result Error a -> msg)` and `Cmd msg` so you can set your own
messages and `UserMetaData` / `AppMetaData` decoders. These are generally named
`a` and `b` in the functions below.

# Auth0 Basis

@docs Endpoint, IdToken, accessToken, UserID, Auth0Config


# User Profile

@docs Profile, decoder, updateProfile


# Helpers

@docs auth0AuthorizeURL, getAuthedUserProfile, updateUserMetaData, logoutUrl


## Curl examples

```
curl -v --request POST \
--url <YOUR_URL>/userinfo \
--header 'content-type: application/json' \
--data '{"access_token": "<YOUR_ACCESS_TOKEN>"}'
```

```
curl --request PATCH \
  --url '<YOUR_URL>/api/v2/users/<USER_ID>' \
  --header 'authorization: Bearer <YOUR_ACCESS_TOKEN_WITH_SCOPE_PERMISSIONS>' \
  --header 'content-type: application/json' \
  --data '{"user_metadata": {"example": ["data", "to", "update"]}'
```

-}

import Http exposing (..)
import Iso8601
import Json.Decode as D exposing (Decoder, string, bool, field)
import Json.Decode.Pipeline as DP
import Json.Encode as E
import Parser
import Time
import Url


{-| Auth0 Endpoint of Authentication API and Management API

e.g. <https://your-auth0-app.auth0.com>

-}
type alias Endpoint =
    String


{-| The accessToken returns from Auth0 `/authorize` endpoint. It is usually in
JSON Web Token ([JWT](https://jwt.io)) format (is it opaque?).
-}
type alias AccessToken =
    String


{-| The idToken returns from Auth0 authenticated result, but only if you've got
an `/audience` parameter in your request url. It contains information such as
the token expiry data, and any permissions the user is authorized for. It is
usually in JSON Web Token ([JWT](https://jwt.io)) format.
-}
type alias IdToken =
    String


{-| Represent the Auth0 unified user ID
-}
type alias UserID =
    String


{-| A config record of Auth0
-}
type alias Auth0Config =
    { endpoint : Endpoint
    , clientId : String
    }


{-| Auth0 unified user profile

> `/tokeninfo` endpoint is part of the legacy authentication flows and
> disabled for new tenants. Now uses the `/userinfo` endpoint ...

If your `Profile` is setup differently, it's wise to use your own profile decoder.
There's quite a lot of variety with setup, but this `Profile` uses the defaults on
a free account. You can choose your scopes and return either a `"name"` or a
full `"profile"`.

The `user_metadata` and `app_metadata` vary in different applications. You
should define your own `user_metadata` and `app_metadata` records. The `/userinfo`
endpoint doesn't return these values by default. You'll have to add an Action
(post-login trigger). See `getAuthedUserProfile` below for more information.

Our `Profile` assumes you've setup a post-login trigger, and that you've set up
your own `*_metadata` decoders.


## Scopes ["openid", "name", "email"]

Logged in with regular email and password, and `user_metadata` setup:

```json
{
    "sub":"auth0|681ce3c6339152f87a583f4c",
    "email":"johnny@mail.com",
    "email_verified":false,
    "user_metadata":{
        "secret":"kBaCSd10",
        "prefs":["one","two","three"]
    }
}
```

## Scopes `["openid", "profile", "email"]`

Logged in with regular email and password:

```json
{
    "sub":"auth0|681ce3c6339152f87a583f4c",
    "nickname":"waterproof-rob",
    "name":"waterproof-rob@outlook.com",
    "picture":"https://s.gravatar.com/avatar/395e9068d232bb28eef989b6e60d6c96?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fwa.png",
    "updated_at":"2025-05-10T14:34:31.128Z",
    "email":"waterproof-rob@outlook.com",
    "email_verified":false,
    "user_metadata":{"json":"kBaCSd10","prefs":["one","two","three"]},
    "app_metadata":{}
}
```

Logged in with gmail account:

```json
{
    "sub":"google-oauth2|109543812167723561932",
    "given_name":"Johnny",
    "nickname":"johnnysanders",
    "name":"Johnny",
    "picture":"https://lh3.googleusercontent.com/a/<some_id>",
    "updated_at":"2025-05-10T15:22:28.814Z",
    "email":"johnny@gmail.com",
    "email_verified":true,
    "user_metadata":{},"app_metadata":{}
}
```
-}
type alias Profile userMetaData appMetaData =
    { email : String
    , email_verified : Bool
    , nickname : Maybe String
    , name : Maybe String
    , picture : Maybe String
    , sub : UserID
    , updated_at : Maybe Time.Posix
    , user_metadata : Maybe userMetaData
    , app_metadata : Maybe appMetaData
    }


{-| Auth0 unified user profile decoder

> There's a lot of `Maybe` types here! It gives some flexibility if you don't
> require a lot of user info for your application. I've renamed to `Auth0.decoder`
> as it's the only one we're currently exposing.

The `user_metatdata` and `app_metadata` varies in different applications.
You should define your own `user_metadata` and `app_metadata` decoders.

1. There's ONE `Profile`, regardless of if your scope is `name` or `profile`. It's
   using `.optional` which will render a `Maybe x_metadata`. If the key is
   missing, it'll return a `Nothing`. It will fail if:
    - `user_metadata` is available and not `null` (`{}` will error)
    - `user_metadata` is available and `json` is malformed (the decoder)
2. We're now using `nullable` for our `x_metadata` which is safer than `maybe`.
   This will error if `"user_metadata"` is:
    - Not available (the key is not present)
    - Not called `"user_metadata"`
    - Not `null` or a `userMetaData` type (custom)


In order for our `nullable` decoder to work, we need to set a post-login trigger
in the Auth0 dashboard. See the `getAuthedUserProfile` function for the javascript
to add to your Actions.

-}

decoder : Decoder a -> Decoder b -> Decoder (Profile a b)
decoder a b =
    D.succeed Profile
        |> DP.required "email" D.string
        |> DP.required "email_verified" D.bool
        |> DP.optional "nickname" (D.map Just string) Nothing -- (1)
        |> DP.optional "name" (D.map Just string) Nothing
        |> DP.optional "picture" (D.map Just string) Nothing
        |> DP.required "sub" string
        |> DP.optional "updated_at" (D.map Just decoderDate) Nothing
        |> DP.required "user_metadata" (D.nullable a) -- (2)
        |> DP.required "app_metadata" (D.nullable b)


decoderDate : Decoder Time.Posix
decoderDate =
    let
        dateStringDecode dateString =
            case Iso8601.toTime dateString of
                Result.Ok date ->
                    D.succeed date

                Err errorMessage ->
                    D.fail (Parser.deadEndsToString errorMessage)
    in
        D.string |> D.andThen dateStringDecode



{-| The `Msg` for `GotProfile`

> ⚠️ This should be handled by your application, you can use the `profileDecoderX`
> or roll your own, depending on your application.

It should look something like this:

    type Msg
        = GotProfile (Result Http.Error (ProfileFull ... ...))

Where `...` are your own `userMetaData` and `appMetaData` decoders. You can pass
in your `GotProfile` message into the `getAuthedUserProfile` function.

-}
type NoMessage
    = SetupInYourOwnApp


{-| The OAuth2 identity of the unified user profile.

> ⚠️ This has been removed, as it involves quite a bit of manual setup.

This usually tell the social account or database account linked with the unified user profile. I've
removed this, as although Auth0 provides a mechanism to link two accounts and
store them in the `identities` array, by default Auth0 does not merge user profile
attributes from multiple providers. It sources the **core** user profile
attributes from the first provider used.

- @ [User profiles](https://auth0.com/docs/manage-users/user-accounts/user-profiles#account-linking)
- @ [Account linking](https://auth0.com/docs/manage-users/user-accounts/user-account-linking/link-user-accounts)

It involves manually setting up Actions or client-sidde account linking, or with
the Auth0.js library (or perhaps one of the SDKs). I'd suggest sticking with ONE
login per user, and keep things simple.

-}
oAuth2IdentityDecoder =
    "Likely to be deprecated"


{-| Create the URL to the login page

> You should use a short lifetime for the `AccessToken`s expiry date; it can
> be refreshed, but with Auth0 that's a bit of a hassle. For security reasons,
> it's better to not store the `AccessToken` in local storage.

- @ [Authorize (implicit flow)](https://auth0.com/docs/api/authentication/implicit-flow/authorize)
- @ [Universal login](https://auth0.com/docs/authenticate/login/auth0-universal-login#implement-universal-login)
- @ [Test your JWT](https://jwt.io/)

```elm
auth0AuthorizeURL
    (Auth0Config "https://my-app.auth0.com" "aBcD1234")
    "token"
    "https://my-app/"
    [ "openid", "name", "email" ]
    Nothing -- e.g: `(Just "google-oauth2")`
    Nothing -- e.g: `(Just "https://dev-yourid.uk.auth0.com/api/v2/")
```

Once you've got your `AccessToken` you can use the `getAuthedUserProfile` function:

- `["openid", "name", "email"]` scopes return basic information
- `["openid", "profile", "email"]` scopes return more information


## Optional parameters

To get the value for our `maybeAud`ience parameter, go to `Applications -> APIs`
and (for basic setup) select the `Auth0 Management API`. You'll find an `Identifier`
value. This is our `/audience` value.

The `/audience` parameter is required for two things:

1. To get a helpful JWT token with permissions and token expiry date
2. To allow use of a specific API (for example, the Management API)
3. To allow extra scopes, specific to the API (eg: `update:current_user_metadata`)

The user may have to grant access to specific permissions when logging in. You
can "skip user consent" to avoid this.

## Scopes

> Take care that you're using the correct API `/audience` for the scopes.
> - @ [Scopes and use-cases](https://auth0.com/docs/get-started/apis/scopes/sample-use-cases-scopes-and-claims)

You can add more scopes to your access token for more permissions. See the
`updateUserMetaData` for an example. For now, all you need to know is that by
adding an `/audience` parameter (such as Auth0 Management API) you get back a
JWT with information such as expiry date, and any permissions granted the user.

## Opaque tokens

One more thing to note is that the `accessToken` is [opaque](https://community.auth0.com/t/opaque-versus-jwt-access-token/31028)
(not a JWT). You'll need to hit the `/userinfo` endpoint for useful information.

-}
auth0AuthorizeURL :
    Auth0Config
    -> String
    -> String
    -> List String
    -> Maybe String -- Social login (if any)
    -> Maybe String -- `accessToken` with expiry data (audience)
    -> String
auth0AuthorizeURL auth0Config responseType redirectURL scopes maybeConn maybeAud =
    let
        mapParam key =
            Maybe.map ((++) key) >> Maybe.withDefault ""

        connectionParam =
            mapParam "&connection=" maybeConn

        audienceParam =
            mapParam "&audience=" maybeAud

        scopeParam =
            scopes |> String.join " " |> Url.percentEncode
    in
        auth0Config.endpoint
            ++ "/authorize"
            ++ ("?response_type=" ++ responseType)
            ++ ("&client_id=" ++ auth0Config.clientId)
            ++ connectionParam
            ++ ("&redirect_uri=" ++ redirectURL)
            ++ ("&scope=" ++ scopeParam)
            ++ audienceParam


{-| Get the Auth0 user profile from an `accessToken`

> Once you have an `AccessToken`, you can use this function to retrieve profile
> json. Only store the data your application needs; be mindful of privacy as this
> is stored on the client-side. Potentially anyone can see this data.

- @ [Get user info](https://auth0.com/docs/api/authentication/user-profile/get-user-info)
- @ [Get user meta (thread)](https://community.auth0.com/t/how-to-get-user-meta-from-userinfo-endpoint/106000)

The return value depends on what scopes you used in your `auth0AuthorizeURL`
function call. The `user_metadata` and `app_metadata` are not returned by default,
so you'll need to set a post-login trigger (this slows down the response time a
little).

Go to `Actions -> Triggers -> Post Login -> Add Action -> Custom`. The thread
advises writing a custom trigger like this:

```js
exports.onExecutePostLogin = async (event, api) => {
  const isEmpty = (metadata) => Object.keys(metadata).length === 0;

  if (event.authorization) {
    api.idToken.setCustomClaim(
      `user_metadata`,
      (isEmpty(event.user.user_metadata) ? null : event.user.user_metadata)
    );
    api.idToken.setCustomClaim(
      `app_metadata`,
      (isEmpty(event.user.app_metadata) ? null : event.user.app_metadata)
    );
  }
};
```

The type signature has changed from `Decoder String` to `Decoder a` to allow for
our custom `Profile` decoder. For the `msg` type, you can add your `GotProfile`
message like below:

```elm
getProfile =
    Auth0.getAuthedUserProfile
        "https://YOUR-API-URL.auth0.com"
        "access_token"
        GotProfile
        (Auth0.decoder a b)
```

Where `a` and `b` are your own `userMetaData` and `appMetaData` decoders.

-}
getAuthedUserProfile :
    Auth0Config
    -> AccessToken
    -> (Result Error a -> msg)
    -> Decoder a
    -> Cmd msg
getAuthedUserProfile auth0Config accessToken msg pDecoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = auth0Config.endpoint ++ "/userinfo" -- #! Changed from `/tokeninfo`
        , body =
            Http.jsonBody <|
                E.object [ ( "access_token", E.string accessToken ) ] -- #! Was `/id_token`
        , expect = Http.expectJson msg pDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Logout of your app (with redirect)

> Our `AccessToken` doesn't invalidate on `logoutUrl`. For that reason give it a
> short lifetime (the expiry value), and don't store it (for security reasons).
> You can always ping the `/authorize` url to get the token (or a new one).

- @ [Logout docs](https://auth0.com/docs/authenticate/login/logout)
- @ [Invalidating an access token](https://community.auth0.com/t/invalidating-an-access-token-when-user-logs-out/48365/7) when a user logs out (thread)

1. `clientId` is required for `returnTo` to URL to work.
2. `Bool` is `True` to force any social logins to logout.

-}
logoutUrl : Auth0Config -> Bool -> String -> String
logoutUrl auth0Config federated returnTo =
    let
        forceSocialLogout =
            if federated then
                "/v2/logout?federated"
            else
                "/v2/logout?"
    in
    auth0Config.endpoint
        ++ forceSocialLogout
        ++ "&returnTo=" ++ returnTo
        ++ "&client_id=" ++ auth0Config.clientId -- (1)


{-| Update the `user_metadata` in the Auth0 unified user profile

> Security: make sure you allow the user to only update _their own_ data! Auth0
> doesn't advise allowing updates to `user_metadata`; client-side is not as
> secure as doing this on the back-end.

- You can setup APIs, scopes, and user permissions.
- When you ping the `/authorize` endpoint, permissions are added to the `AccessToken`.
- You can use this `AccessToken` to update your user's metadata

Documentation:

- @ [API scopes](https://auth0.com/docs/get-started/apis/scopes/api-scopes)
- @ [Update user metadata](https://auth0.com/docs/manage-users/user-accounts/metadata/manage-metadata-api)
- @ [Manage user metadata](https://auth0.com/docs/manage-users/user-accounts/metadata/manage-metadata-api)
- @ [Patch users by ID](https://auth0.com/docs/api/management/v2/users/patch-users-by-id)
- @ [Management API for SPA apps](https://auth0.com/docs/secure/tokens/access-tokens/management-api-access-tokens/get-management-api-tokens-for-single-page-applications)

Steps to change your `user_metadata` with the Management API:

> The `a` value is your own custom `UserMeta` decoder

1. Make sure your `Auth0 Management API` is enabled in `Applications -> APIs`
2. Select the API and get the `Identifier` unique ID.
3. Add this to your `/audience` parameter in the `auth0AuthorizeURL` function.
4. Add `update:current_user_metadata` to your scopes in the `auth0AuthorizeURL` function.

The user may be prompted to grant permissions on login. I'd suggest to keep things
simple and only use ONE API (the Management API).

- @ [APIs](https://auth0.com/docs/get-started/apis)


## Return values

> ⚠️ The return value is correct, but our old `AccessToken` caches the old version,
> without our newly updated `user_metadata` values. Better to update your
`model.profile.user_metadata` manually, or get a new AccessToken`!

This function only returns a `"user_metadata" record, not the full profile. You'll
have to ping the `/userinfo` endpoint again, or update your `Profile.user_metadata`
value within your update function.


## Security

It's better safe then sorry, so be careful with SPA apps and the Management API.
Only allow the user to update their own account, nothing more. It might be safer
to do this on the backend (not the client), or manually in the Auth0 GUI.

- @ [SPA security vulnerabilities](https://community.auth0.com/t/confusion-about-management-api-token-limitation/86136)

-}
updateUserMetaData :
    Auth0Config
    -> AccessToken
    -> (Result Error a -> msg)
    -> Decoder a
    -> UserID
    -> E.Value
    -> Cmd msg
updateUserMetaData auth0Config accessToken msg metaDecoder userID userMeta =
    Http.request
        { method = "PATCH"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , url = auth0Config.endpoint ++ "/api/v2/users/" ++ userID
        , body =
            Http.jsonBody <|
                E.object
                    [ ( "user_metadata", userMeta ) ]
        , expect = Http.expectJson msg metaDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Update the `ProfileBasic` metadata

> Only use this function if you know you've already got a `Profile`, otherwise
> it'll fail (if `model.profile == Nothing`).

A helper function to update `user_metadata` or `app_metadata`. It doesn't seem
like we can use extensible records here, unfortunately, as we can't predict the
type of our `user_metadata` (which is custom per application).

- [Extensible records](https://tinyurl.com/adv-types-extensible-records) (require proper typing?)

Instead we'll use simpler, more flexible type signatures.

## Permissions

You must have set the `/audience` to the Management API identifier and set the
permissions `update:current_user_metadata` in scopes!

-}
updateProfile : Profile a b -> a -> b -> Profile a b
updateProfile profile userMetaData appMetaData  =
    { profile
        | user_metadata = Just userMetaData
        , app_metadata = Just appMetaData
    }
