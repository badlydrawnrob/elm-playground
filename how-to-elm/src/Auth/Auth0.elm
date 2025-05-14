module Auth.Auth0
    exposing
        ( auth0AuthorizeURL
        , Auth0Config
        , Endpoint
        , getAuthedUserProfile
        , logoutUrl
        , ProfileBasic
        , ProfileFull
        , decoderBasic
        , decoderFull
        , updateUserMetaData
        , updateProfileBasic
        , updateProfileFull
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
messages.



# Auth0 Basis

@docs Endpoint, IdToken, accessToken, UserID, Auth0Config


# User Profile

@docs ProfileBasic, ProfileFull, decoderBasic, decoderFull


# Helpers

@docs auth0AuthorizeURL, getAuthedUserProfile, updateUserMetaData, logoutUrl

-}

import Http exposing (..)
import Iso8601
import Json.Decode as Decode exposing (Decoder, nullable, string, bool, field)
import Json.Encode as Encode
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
> they are disabled in the new tenants. Use `/userinfo` instead ...

It's probably best to set your own `Profile` and `profileDecoder`; there's a lot
of variety (are you using social ids? etc). The examples are using basic auth
with email and password (you can add social ids if you like, but you'll need to
enable them in Auth0 admin)

- To return a basic profile use scopes: `["openid", "name", "email"]` and
- To return a full profile use scopes: `["openid", "profile", "email"]`.

The `user_metadata` and `app_metadata` vary in different applications. You
should define your own `user_metadata` and `app_metadata` records. The `/userinfo`
endpoint doesn't return these values by default. You'll have to add an Action
(post-login trigger). See `getAuthedUserProfile` below for more information.

Here's a basic profile example with basic profile scopes, and a post-login trigger
created (add your own `*_metadata` decoders):

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
-}
type alias ProfileBasic userMetaData appMetaData =
    { email : String
    , email_verified : Bool
    , sub : UserID
    , user_metadata : Maybe userMetaData
    , app_metadata : Maybe appMetaData
    }


{-| Fuller profile info with full profile scopes: first basic auth (email), second
logged in with gmail account:

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
type alias ProfileFull userMetaData appMetaData =
    { email : String
    , email_verified : Bool
    , nickname : String
    , name : String
    , picture : String
    , sub : UserID
    , updated_at : Time.Posix
    , user_metadata : Maybe userMetaData
    , app_metadata : Maybe appMetaData
    }


{-| Auth0 unified user profile decoder

> Renamed these to `decoderX` as they're the only ones we're using (and the
> `decoderDate` isn't exposed)

The `user_metatdata` and `app_metadata` varies in different application.
You should define your own `user_metadata` and `app_metadata` decoders.

1. We're now using `nullable` which is safer than `maybe`. This will error if
   the `"user_metadata"` is:
    - Not available
    - Not called `"user_metadata"`
    - Not `null` or a `userMetaData` type (custom)
2. Because we're using `Json.Decode.nullable` NOT `Json.Decode.maybe`, we
   can't simply have a single profile decoder (`nullable` requires a field to be
   present and `null`).
    - For that reason we have a `ProfileFull` and `ProfileBasic` decoder.

In order for our `nullable` decoder to work, we need to set a post-login trigger
in the Auth0 dashboard. See the `getAuthedUserProfile` function for the javascript
to add to your Actions.

-}
decoderBasic : Decoder a -> Decoder b -> Decoder (ProfileBasic a b)
decoderBasic a b =
    Decode.map5 ProfileBasic
        (field "email" string)
        (field "email_verified" bool)
        (field "sub" string)
        (field "user_metadata" (nullable a)) -- #! (1)
        (field "app_metadata" (nullable b)) -- #! (1)

decoderFull : Decoder a -> Decoder b -> Decoder (ProfileFull a b)
decoderFull a b =
    Decode.map2
        (<|)
        (Decode.map8 ProfileFull
            (field "email" string)
            (field "email_verified" bool)
            (field "nickname" string)
            (field "name" string)
            (field "picture" string)
            (field "sub" string)
            (field "updated_at" decoderDate)
            (field "user_metadata" (nullable a))) -- #! (1)
        (field "app_metadata" (nullable b)) -- #! (1)


decoderDate : Decoder Time.Posix
decoderDate =
    let
        dateStringDecode dateString =
            case Iso8601.toTime dateString of
                Result.Ok date ->
                    Decode.succeed date

                Err errorMessage ->
                    Decode.fail (Parser.deadEndsToString errorMessage)
    in
        Decode.string |> Decode.andThen dateStringDecode



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

- `["openid", "name", "email"]` scopes return basic information (`ProfileBasic`)
- `["openid", "profile", "email"]` scopes return more information (`ProfileFull`)


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
our custom `ProfileBasic` or `ProfileFull` decoders. For the `msg` type, you can
add your `GotProfile` message like below:

```elm
getProfile =
    getAuthedUserProfile
        "https://YOUR-API-URL.auth0.com"
        "access_token"
        GotProfile
        (profileDecoderFull ... ...)
```

Where `...` are your own `userMetaData` and `appMetaData` decoders.

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
                Encode.object [ ( "access_token", Encode.string accessToken ) ] -- #! Was `/id_token`
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

> Take care with security! Auth0 doesn't advise doing this, but make sure that
> you're only allowing the user to update _their own_ data. It's not as secure
> client-side as it would be on the backend.

This function will only return the updated user's metadata. You'll have to use
the `getAuthedUserProfile` function again to return the full user profile.

- You can setup APIs, scopes, and user permissions.
- When you ping the `/authorize` endpoint, permissions are added to the `AccessToken`.
- You can use this `AccessToken` to update your user's metadata

> ⚠️ "Auth0 does not recommend putting Management API Tokens on the frontend that
> allow users to change user metadata."

- @ [API scopes](https://auth0.com/docs/get-started/apis/scopes/api-scopes)
- @ [Update user metadata](https://auth0.com/docs/manage-users/user-accounts/metadata/manage-metadata-api)
- @ [Manage user metadata](https://auth0.com/docs/manage-users/user-accounts/metadata/manage-metadata-api)
- @ [Patch users by ID](https://auth0.com/docs/api/management/v2/users/patch-users-by-id)
- @ [Management API for SPA apps](https://auth0.com/docs/secure/tokens/access-tokens/management-api-access-tokens/get-management-api-tokens-for-single-page-applications)

That said, here's how you can change your `user_metadata` with the Management API.

1. Make sure your `Auth0 Management API` is enabled in `Applications -> APIs`
2. Select the API and get the `Identifier` unique ID.
3. Add this to your `/audience` parameter in the `auth0AuthorizeURL` function.
4. Add `update:current_user_metadata` to your scopes in the `auth0AuthorizeURL` function.

The user may be prompted to grant permissions. You can setup multiple APIs (for
different resources) each with their own custom permissions. I'd suggest
keeping things simple and just use ONE (the Management API) for now.

- @ [APIs](https://auth0.com/docs/get-started/apis)


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
    -> Encode.Value
    -> Cmd msg
updateUserMetaData auth0Config accessToken msg pDecoder userID userMeta =
    Http.request
        { method = "PATCH"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , url = auth0Config.endpoint ++ "/api/v2/users/" ++ userID
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "user_metadata", userMeta ) ]
        , expect = Http.expectJson msg pDecoder
        , timeout = Nothing
        , tracker = Nothing
        }




---- These might be better as extensible records. I'm only going to updating one
---- of two fields in `Profile`. So it could serve both `ProfileBasic` AND `ProfileFull`
---- because they both share same fields.

-- Should this be left to APP code?
--
-- 1. What if `app_metadata` is a `Nothing` value?
-- 2. What if `user_metadata` is a `Nothing` value?
-- 3. Could we use extensible records instead of these update functions?
-- 4. Do we add the `(Just ..)` or `Nothing` as values to the functions?
--    - Rather than setting them as `Just` in the body function.



{-| Update the `ProfileBasic` metadata

> These values will be custom depending on your app. You'll probably be
> using a `Maybe Profile` in your model, so make sure it exists first!

A helper function to update `user_metadata` or `app_metadata`.
-}
updateProfileBasic : a -> b -> ProfileBasic a b -> ProfileBasic a b
updateProfileBasic userMetaData appMetaData profile =
    { profile
        | user_metadata = Just userMetaData
        , app_metadata = Just appMetaData
    }

{-| Update the `ProfileFull` metadata

> These values will be custom depending on your app. You'll probably be
> using a `Maybe Profile` in your model, so make sure it exists first!

A helper function to update `user_metadata` or `app_metadata`.
-}
updateProfileFull : a -> b -> ProfileFull a b -> ProfileFull a b
updateProfileFull userMetaData appMetaData profile =
    { profile
        | user_metadata = Just userMetaData
        , app_metadata = Just appMetaData
    }
