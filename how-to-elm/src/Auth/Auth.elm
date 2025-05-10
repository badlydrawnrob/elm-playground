module Auth.Auth exposing (..)

{-| ----------------------------------------------------------------------------
    Testing the auth0 elm library
    ============================================================================
    To be honest, the auth0 documentation is hard to get through: it's confusing
    to know how to do things the right way that work reliably. It's currently
    working for the `/authorize` and `/userinfo` endpoints. I feel it'd be way
    easier just building the damn thing with Python though, it's taken 2 days of
    sifting through the fucking documentation.


    Just use Ai
    -----------
    > Wherever possible, remove the amount of code you're writing.
    > Could you just use a Tally form or v0 to mock up the functionality?

    You can always "make it perfect" later, but time is of the essence.


    Wishlist
    --------
    > First check your code for errors!

    1. Extract the token from the url
    2. Can other functions be added to the `Auth0` package?
        - Any `extractX` functions? (like the `ProfileFull` and `ProfileBasic`)
        - Should `extractProfile` be in the `Auth` package? Or per app?
    3. Set an `Auth0Config` and extract it into `getProfile`.
    4. Make the thing work all in the same `elm reactor` session.
    5. See if you can get the refresh token to work.
    6. Using `URL` with stock Elm is a bit of a headache ...
        - I think it might be easier to use something like Elm Land!
        - However this will use `Browser.application` and take control of the
          whole page.
        - Alternatively you could grab the URL with js and use Ports.


    2. Does it work properly within our app? Before it wasn't!
    3. Is profile information easily changeable (as well as `user_metadata`)?
    4. The `Decoder a` and `(Result Http.Error a)` etc make things a little bit
       confusing, is it better to just set them to hard values?
        - `user_metadata` can't really be hardcoded if it's a public package.


    The API
    -------
    > @ https://auth0.com/docs/api/authentication
    > @ https://jwt.io/ (Test the JWT token)

    The default time for the token is 7200 seconds (2 hours). This can be
    extended. I'm going to leave profile editing out of scope (you can update the
    `user_metadata`) as it uses the Auth0 Management API (I don't think this is
    free).

    Notes and problems:
    -------------------

    1. `Decoder a` and `(Result Http.Error a)` make things a wee bit confusing,
       but much easier to extend the package.
    2. I think `#access_token=` is an opaque token, but you can add `/audience`
       for some useful JWT (the middle bit) info.
        - Alternatively use the `/oauth/token` endpoint or the SDK.
    3. Is there any other profile information we can pull out with an Action?
        - @ https://auth0.com/docs/manage-users/user-accounts/user-profiles#access-user-profiles-from-the-management-api
        - @ https://auth0.com/docs/user-profile/user-profile-structure
    4. Session management and documentation is a bit of a shit show. Lots of
       different APIs and usecases:
        - @ https://auth0.com/blog/application-session-management-best-practices/
        - @ https://community.auth0.com/t/confusion-around-authorization/78981/2
    5. To update the user you need to set the correct scopes in your `/authorize`
       endpoint.

-}

import Auth.Auth0 as Auth0 exposing (ProfileFull, Auth0Config)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D

import Debug


-- Login link ------------------------------------------------------------------
-- Including an example `auth0AuthorizeUrl` return url

exampleUrl =
    "http://localhost:8000/index.html" ++
    "#access_token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwiaXNzIjoiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vIn0..-R1F7wflD5Afl_XA.-wvnb48v80rd4vKDTjX3_gFO0l53uKtV3s4t3oF_dvNPcCz8nynIfNUj9u30myrxSCF4ERNFN0Y4VVgpDoYVttnXvSntJVLIoNdzgt2RXWDNxsckbzy-38MBL7GDYSiB2BY55Y4qqhUr4R-67jTKUvqLgVT1vcdE_HIr_bbuy_4IFfrid-ekHla78FcSzuPPKZK51nEG1IAIJ8aQkD-VJZfiInfp2YOPzBwYymj2oz3RCK-uM_gnmiB0a9gWLxDcovdBf7HxlsfxPWlo23uEeaRaWj4Xluo60bqwy7WepfDUm2yFlhfxhyZNvJVmgEn79hZ6UnDt6KoVoZ_by4ua.TTUwmDWIA74XMLGtJAiB4A" ++
    "&scope=openid%20email" ++
    "&expires_in=7200" ++ -- default expiry time
    "&token_type=Bearer"

url : String
url =
    Auth0.auth0AuthorizeURL
        (Auth0Config "https://dev-ne2fnlv85ucpfobc.uk.auth0.com" "YzMHtC6TCNbMhvFB5AyqFdwfreDmaXAW")
        "token"
        "http://localhost:8000/09-auth0.html" -- was https
        [ "openid", "name", "email" ]
        Nothing

getToken : String
getToken =
    Debug.todo """List.intersperse ":" and String.split on `.`"""


-- User Profile -----------------------------------------------------------------

getProfile =
    Auth0.getAuthedUserProfile
        "https://dev-ne2fnlv85ucpfobc.uk.auth0.com"
        "eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwiaXNzIjoiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vIn0..ED5prUI801ERbBVw._XBLmKEXxEwzjUQmHLPRIahLPeKUbZWY7eqdwGEhyLGtpU11bEAZaKUdzrV-YgAAN9xDsJPFy8bPF16C1-aZ4n8ATR-Z4pl9fNkUYj_H0UvEQedKgXzJkxaKPLv0Cay7H_ER3Rk6BAMBLpZg_6d8fO30l_rBvAkOSgmvrx6rxAZPAg2Dff5btXng8UMynOOMfkQQlDGU4YZGuc6gxGaGLAiWFWZ0D20qb60NaAwknoScXfnVGvNtQnjWQThyGhxr5qJbpb-GiaUeCmWMeVf_nIa3ItJkx9azYOiX-gijygiKGC_q9iydTnSAJLpNU8IsPYfMVm9FslHHrkujV5Oc2ir39kyDGb0.7jEUeh2NkncpFwtNkxDfoQ"
        GotProfile
        (Auth0.decoderFull decoderUserMetadata decoderAppMetadata) -- #! Fix

decoderUserMetadata =
    D.succeed "This"

decoderAppMetadata =
    D.succeed "That"


-- Logout ----------------------------------------------------------------------

{- "federated" should force logout for openid providers -}
logout =
    Auth0.logoutUrl
        (Auth0Config "https://dev-ne2fnlv85ucpfobc.uk.auth0.com" "YzMHtC6TCNbMhvFB5AyqFdwfreDmaXAW")
        True -- I'm not using any social logins though
        "http://localhost:8000/09-auth0.html" -- The return url



-- Msg -------------------------------------------------------------------------

type Msg
  = ClickedGetProfile
  | GotProfile (Result Http.Error (ProfileFull String String)) -- #! Moved from Auth0.elm to `Main.Msg`


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case Debug.log "The Msg: " msg of
        ClickedGetProfile ->
            ( model
            , getProfile -- #! New version of Auth package
            )

        GotProfile (Ok profile) ->
            ( { model | profile = Just profile }, Cmd.none )

        GotProfile (Err _) ->
            ( { model | error = "Something went wrong with profile" }
            , Cmd.none
            )


-- View ------------------------------------------------------------------------

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Auth0 Example" ]
        , a [ href url ] [ text "Login with Auth0" ]
        , viewProfile model.profile
        , button [ onClick ClickedGetProfile ] [ text "Get Profile" ]
        , a [ href logout ] [ text "Logout" ] -- Returns to root url
        ]

viewProfile : Maybe (ProfileFull String String) -> Html Msg
viewProfile profile =
    case profile of
        Nothing ->
            p [] [ text "No profile" ]

        Just prof ->
            p [] [ text (Debug.toString prof) ]


-- Model -----------------------------------------------------------------------

type alias Model
    = { name : String
      , profile : Maybe (ProfileFull String String)
      , error : String
    }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model "" Nothing "", Cmd.none)


-- Main ------------------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none

main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

