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

> Auth0 documentation is hard to get through; I'd suggest keeping your auth
> setup simple. We're a little limited with a SPA (without using Auth0.js or the
SDKs which would require ports). For more advanced needs, I'd suggest finding
> a different (simpler) framework.

This package uses the "Implicit Flow". Previous releases used `IdToken`, but now
`AccessToken` is used (the id token simply shows permissions if the `/audience`
parameter is set).

Logging users in prompts "app is requesting access to your account" can be removed
by setting `Applications -> APIs -> (select the api) -> Settings -> Access Settings`
to "Allow Skipping User Consent". `localhost:8000` will always prompt users.

Limitations:

1. Less secure than an SDK: NEVER store the `AccessKey` or any sensitive data.
    - It's client-side, so could potentially be visible to ANYONE.
2. Auth0 don't recommend changing `user_metadata` with a client-side app:
    - If you do, make sure the logged-in user can only work with _their own_
      data; see (1).
    - For more advanced needs, consider using the SDK on the back-end. It's safer.
3. The free plan comes with rate limits on the API
    - @ [See rate limits](https://auth0.com/docs/troubleshoot/customer-support/operational-policies/rate-limit-policy/rate-limit-configurations/free-public)

We're now using the message type `(Result Error a -> msg)` and returning a `Cmd msg`
for allowing you to set your own `Msg` and `userMetaData` / `appMetaData` decoders.
These are generally named `a` and `b` in our functions.

Curl calls for testing:

```
curl -v --request POST \
--url <YOUR_ENDPOINT>/userinfo \
--header 'content-type: application/json' \
--data '{"access_token": "<YOUR_ACCESS_TOKEN>"}'
```

```
curl --request PATCH \
  --url '<YOUR_ENDPOINT>/api/v2/users/<USER_ID>' \
  --header 'authorization: Bearer <YOUR_ACCESS_TOKEN_WITH_SCOPE_PERMISSIONS>' \
  --header 'content-type: application/json' \
  --data '{"user_metadata": {"example": ["data", "to", "update"]}'
```


# Auth0 Basis

@docs Endpoint, IdToken, accessToken, UserID, Auth0Config


# User Profile

@docs Profile, decoder, updateProfile


# Helpers

@docs auth0AuthorizeURL, getAuthedUserProfile, updateUserMetaData, logoutUrl

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

> ⚠️ `/tokeninfo` endpoint is part of the legacy authentication flows and
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


## Scopes `["openid", "name", "email"]`

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
    "nickname":"johnny",
    "name":"johnny@mail.com",
    "picture":"http://some-avatar.com/image.jpg",
    "updated_at":"2025-05-10T14:34:31.128Z",
    "email":"johnny@mail.com",
    "email_verified":false,
    "user_metadata":{
        "secret":"kBaCSd10",
        "prefs":["one","two","three"]
    },
    "app_metadata":null
}
```

Logged in with gmail account:

```json
{
    "sub":"google-oauth2|109543812167723561932",
    "given_name":"Johnny",
    "nickname":"johnny",
    "name":"Johnny",
    "picture":"https://lh3.googleusercontent.com/a/image.jpg",
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

1. There's ONE `Profile`, regardless if your scope is `name` or `profile`. It's
   using `Json.Decode.Pipeline.optional` which renders a `Maybe x_metadata`. If
   the key is missing, it'll return a `Nothing`. It will fail if:
    - `user_metadata` is available and not `null` (`{}` will error)
    - `user_metadata` is available and `json` is malformed (the decoder)
2. We're now using `nullable` for our `x_metadata` which is safer than `maybe`.
   This will error if `"user_metadata"` is:
    - Not available (the key is not present)
    - Not called `"user_metadata"`
    - Not `null` or your custom `userMetaData` type


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
        = GotProfile (Result Http.Error (Profile a b))

Where `a` and `b` are your own `userMetaData` and `appMetaData` decoders. You
can pass in your `GotProfile` message into the `getAuthedUserProfile` function.

-}
type Msg
    = SetupYourOwnMessageType


{-| The OAuth2 identity of the unified user profile.

> ⚠️ This has been removed, as it involves quite a bit of manual setup.

I wouldn't advise using the unified (linked) user profile unless absolutely
necessary as it involves a manual setup. Auth0 provides a mechanism to link two
accounts (two social logins, for example) and store them in the `identities`
array. Auth0 does not merge these by default.

- @ [User profiles](https://auth0.com/docs/manage-users/user-accounts/user-profiles#account-linking)
- @ [Account linking](https://auth0.com/docs/manage-users/user-accounts/user-account-linking/link-user-accounts)

You'd need to setup Actions or an account linking function. The Auth0.js library
or SDKs offer this; I'd suggest sticking with ONE login profile per user. Keep
things simple!

-}
oAuth2IdentityDecoder =
    "This will be deprecated"


{-| Create the URL to the login page

> You should use a short lifetime for the `AccessToken`s expiry date; the session
> can be refreshed, but with Auth0 that's a bit of a hassle. For security reasons,
> NEVER store it client-side; use it for what you need then discard it. You can
> always ping the `/authorize` endpoint to get another token.

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

1. To get a helpful JWT `IdToken` with permissions and `AccessToken` expiry date
2. To allow use of a specific API (for example, the Management API)
3. To allow extra scopes, specific to the API (eg: `update:current_user_metadata`)

The user may have to grant access to specific permissions when logging in. You
can "skip user consent" to avoid this.

## Scopes

> Take care that you're using the correct API `/audience` for the scopes.

- @ [Scopes and use-cases](https://auth0.com/docs/get-started/apis/scopes/sample-use-cases-scopes-and-claims)

You can add more scopes to your access token for more permissions. See the
`updateUserMetaData` for an example. For now, all you need to know is that by
adding an `/audience` parameter (such as Auth0 Management API) you get back a
JWT with information such as expiry date, and any permissions granted the user.

## Opaque tokens

One more thing to note is that the `AccessToken` is [opaque](https://community.auth0.com/t/opaque-versus-jwt-access-token/31028)
(I guess not inspectable). You'll need to hit the `/userinfo` endpoint for
useful information.

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
your own custom `Profile` decoder. For the `msg` type, you can add a `GotProfile`
message; a `UserMeta` decoder; and a `AppMeta` decoder if needed. See below:

```elm
type alias UserMeta =
    { secret : String, prefs : List String }

type alias AppMeta =
    String

decoderUserMeta : Decoder UserMeta
decoderUserMeta =
    D.map2 (\a b -> { secret = a, prefs = b })
        (D.field "json" D.string)
        (D.field "prefs" (D.list D.string))

decoderAppMeta : Decoder String
decoderAppMeta =
    D.succeed "Not used (nullable)"

getProfile =
    Auth0.getAuthedUserProfile
        "https://YOUR-API-URL.auth0.com"
        "access_token"
        GotProfile
        (Auth0.decoder decoderUserMeta decoderAppMeta)
```
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

> Make sure your `AccessToken` has a short expiry value (lifetime). It's easier
> (but not as user-friendly) to have them login again after the token expires.

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

> Be secure and only allow user to update _their own_ data. It's also best to not
> store anything private (GDPR) in `user_metadata`. Auth0 doesn't advise allowing
> updating this client-side at all (back-end is more secure), but it should be
> fine for user settings and so on.

- You can setup APIs, scopes, and user permissions.
- When you ping the `/authorize` endpoint, permissions are added to the `AccessToken`.
- You can use this `AccessToken` to update your user's metadata

## Documentation

- @ [API scopes](https://auth0.com/docs/get-started/apis/scopes/api-scopes)
- @ [Manage user metadata](https://auth0.com/docs/manage-users/user-accounts/metadata/manage-metadata-api)
- @ [Patch users by ID](https://auth0.com/docs/api/management/v2/users/patch-users-by-id)
- @ [Management API for SPA apps](https://auth0.com/docs/secure/tokens/access-tokens/management-api-access-tokens/get-management-api-tokens-for-single-page-applications)

## The Management API

> The `access_token` is NOT the same as a Management API key ...

Using the access token grants fewer privaleges than the Management API, which is
better for our SPA example as a security measure:

- @ [Difference between Management key and Access token](https://community.auth0.com/t/how-to-return-full-profile-when-updating-user-metadata/186604/5)

1. Make sure your `Auth0 Management API` is enabled in `Applications -> APIs`
2. Select the API and get the `Identifier` unique ID.
3. Add this to your `/audience` parameter in the `auth0AuthorizeURL` function.
4. Add `update:current_user_metadata` to your scopes in the `auth0AuthorizeURL` function.

The user may be prompted to grant permissions on login. I'd suggest to keep things
simple and only use ONE API (the Management API).

- @ [APIs](https://auth0.com/docs/get-started/apis)


## Return values

> This function only returns a `"user_metadata" record, not the full profile.
> Update your `Profile.user_metadata` (manually) within your update function.

```
GotMeta (Ok meta) ->
    ( { model | profile = updateProfileWithMeta meta model.profile }
    , Cmd.none
    )
```

⚠️ Otherwise, you'll have to ping the `/userinfo` endpoint again. Our `AccessToken`
caches the old values, so won't display updated `user_metadata`! You'd have to
get a new `AccessToken` with the login url.


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


{-| Update the `Profile` metadata

> Only use this function if you know you've already got a `Profile`, otherwise
> it'll fail (if `model.profile == Nothing`).

A helper function to update `user_metadata` or `app_metadata`. It doesn't seem
like we can use extensible records here unfortunately, as we can't predict the
types of our `user_metadata` (which are custom per application).

- [Extensible records](https://tinyurl.com/adv-types-extensible-records) (require proper typing?)

Instead we'll use simpler, more flexible type signatures.

## Permissions

You must have set the `/audience` to the Management API identifier and set the
permissions (e.g: `update:current_user_metadata`) in scopes!

-}
updateProfile : Profile a b -> a -> b -> Profile a b
updateProfile profile userMetaData appMetaData  =
    { profile
        | user_metadata = Just userMetaData
        , app_metadata = Just appMetaData
    }
