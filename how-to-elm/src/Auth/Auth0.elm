module Auth.Auth0
    exposing
        ( auth0AuthorizeURL
        , Auth0Config
        , Endpoint
        , getAuthedUserProfile
        , IdToken -- #! Deprecate this? Is it _still_ an `idToken`?
        , logoutUrl
        , ProfileBasic
        , ProfileFull
        , decoderBasic
        , decoderFull
        , updateUserMetaData -- #! Deprecate this?
        , UserID
        )

{-| This library provides data types and helper functions for [Auth0](https://auth0.com)

> I've found Auth0 documentation hard to get through: confusing to know how to
> do things the right way that work reliably. It's great for light use as an
> authentication method, but we're a bit limited what we can do in Elm. For more
> advanced needs, you'd be better off with Auth0.js, the SDKs, or another framework.

This package uses the "Implicit Flow". You could alternatively use `/oauth/token`
endpoint, or the SDK provided by Auth0; that will involve using Ports however.
Previous releases used `id_token`, but (I think) this is now not recommended.

By default, when the user logs in, you'll get a prompt that "app is requesting
access to your account" which they'll have to accept. To skip user consent for
the implicit flow, you go to `Applications -> APIs -> (select the api) -> Settings -> Access Settings`
and turn on "Allow Skipping User Consent".

It currently has limitations, as `user_metadata` cannot (or shouldn't) be allowed
to be changed by the client (a logged in user). Perhaps set a backend cron job
for this, or do it manually.

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


{-| The idToken returns from Auth0 authenticated result, it is usually in JSON
Web Token ([JWT](https://jwt.io)) format.
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
       - Not `"user_metadata"`
       - Anything other than `null` ...
       - Or not `userMetaData` (your custom decoder type)

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

> - @ [Authorize (implicit flow)](https://auth0.com/docs/api/authentication/implicit-flow/authorize)
> - @ [Universal login](https://auth0.com/docs/authenticate/login/auth0-universal-login#implement-universal-login)
> - @ [Test your JWT](https://jwt.io/)


```elm
auth0AuthorizeURL
    (Auth0Config "https://my-app.auth0.com" "aBcD1234")
    "token"
    "https://my-app/"
    [ "openid", "name", "email" ]
    Nothing -- e.g: `(Just "google-oauth2")`
    Nothing -- e.g: `(Just "https://dev-yourid.uk.auth0.com/api/v2/")
```

The scope `["openid", "name", "email"]` will return basic information when
posting to `getAuthedUserProfile` (`ProfileBasic`); replacing `"name"` with `"profile"` will return
will return more information (`ProfileFull`). You can add more scopes to your
`accessToken` for more permissions for Auth0 API calls. By default, `user_metadata`
is not rendered — see `getAuthedUserProfile` for the code to render this.

- @ [Scopes and use-cases](https://auth0.com/docs/get-started/apis/scopes/sample-use-cases-scopes-and-claims)

For a JWT Payload with an EXPIRY VALUE, set a `maybeAud` parameter to your authorize
url. It's not particularly useful, but will give you a little more context. Go to
`Application -> APIs -> (select the api) -> Settings -> Identifier` to find your
audience value.

- @ [Opaque -vs- JWT tokens](https://community.auth0.com/t/opaque-versus-jwt-access-token/31028)

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

> This used to be represented by an `IdToken` (and the js below actually
> references it), but you now post an `accessToken` to retrieve profile json.

- @ [Get user info](https://auth0.com/docs/api/authentication/user-profile/get-user-info)
- @ [Get user meta (thread)](https://community.auth0.com/t/how-to-get-user-meta-from-userinfo-endpoint/106000)

The return value depends on what scope you used in your `auth0AuthorizeURL`
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

This has changed from `Decoder String` to `Decoder a` to allow for our custom
`ProfileBasic` or `ProfileFull` decoders. For the `msg` type, you can add your
`GotProfile` message like below:

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
    Endpoint
    -> AccessToken
    -> (Result Error a -> msg)
    -> Decoder a
    -> Cmd msg
getAuthedUserProfile auth0Endpoint accessToken msg pDecoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = auth0Endpoint ++ "/userinfo" -- #! Changed from `/tokeninfo`
        , body =
            Http.jsonBody <|
                Encode.object [ ( "access_token", Encode.string accessToken ) ] -- #! Was `/id_token`
        , expect = Http.expectJson msg pDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Logout of your app (with redirect)

> - @ [Logout docs](https://auth0.com/docs/authenticate/login/logout)

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

> ⚠️ "Auth0 does not recommend putting Management API Tokens on the frontend that
> allow users to change user metadata." This function might be worth deprecating.

This is quite hard to understand from the documentation: you'll need to use the
Management API to update the `user_metadata` (or other profile fields). You'll also
need to set the correct scopes in your `/authorize` endpoint (probably
`update:current_user_metadata`). It's easier to just set this within your Auth0
dashboard instead (or do it as an admin).

- @ [API scopes](https://auth0.com/docs/get-started/apis/scopes/api-scopes)
- @ [Management API for SPA apps](https://auth0.com/docs/secure/tokens/access-tokens/management-api-access-tokens/get-management-api-tokens-for-single-page-applications)
- @ [SPA security vulnerabilities](https://community.auth0.com/t/confusion-about-management-api-token-limitation/86136)

It also seems preferable to handle this on the backend (not on the client), for
security purposes.

-}
updateUserMetaData :
    Endpoint
    -> IdToken
    -> UserID
    -> (Result Error String -> msg)
    -> Encode.Value
    -> Decoder String
    -> Cmd msg
updateUserMetaData auth0Endpoint idToken userID msg userMeta pDecoder =
    Http.request
        { method = "PATCH"
        , headers = [ Http.header "Authorization" ("Bearer " ++ idToken) ]
        , url = auth0Endpoint ++ "/api/v2/users/" ++ userID
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "user_metadata", userMeta ) ]
        , expect = Http.expectJson msg pDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
