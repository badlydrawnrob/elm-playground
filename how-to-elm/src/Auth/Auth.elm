module Auth.Auth exposing (..)

{-| ----------------------------------------------------------------------------
    Testing the auth0 elm library
    ============================================================================
    To be honest, the auth0 documentation is hard to get through: it's confusing
    to know how to do things the right way that work reliably. It's currently
    working for the `/authorize` and `/userinfo` endpoints. I feel it'd be way
    easier just building the damn thing with Python though, it's taken 2 days of
    sifting through the fucking documentation.

    Bugs
    ----
    1. Updating the metadata doesn't return a full profile. Options:
        - Update the profile with Elm (`updateProfilMeta` function)
        - Ping the database again with `getProfile` function.
    2. `AccessToken` is NOT invalidated when user clicks the `logoutUrl`
        - So it's better to have a short expiry time and not store it.
    3. Elm caches the js, so sometimes changing a line doesn't work.
        - Set the browser to no-cache mode?


    Just use Ai
    -----------
    > Wherever possible, remove the amount of code you're writing.
    > Could you just use a Tally form or v0 to mock up the functionality?

    You can always "make it perfect" later, but time is of the essence.


    Wishlist
    --------
    > First check your code for errors!
    > https://jwt.io/ to check the access token.

    1. Add the `/audience` option to the authenticate url
        - User the `ProfileFull` instead of basic.
    2. Extract the token from the url
        - For now, just use a local storage value.
    3. Can you update `user_metadata` with `updateUserMetadata` funtion?
        - It suggests not to do this client-side in the API docs.
    4. Can other functions be added to the `Auth0` package?
        - Any `extractX` functions? (like the `ProfileFull` and `ProfileBasic`)
        - Should `extractProfile` be in the `Auth` package? Or per app?
    5. Set an `Auth0Config` and extract it into `getProfile`.
    6. Make the thing work all in the same `elm reactor` session.
    7. See if you can get the refresh token to work.
    8. Using `URL` with stock Elm is a bit of a headache ...
        - I think it might be easier to use something like Elm Land!
        - However this will use `Browser.application` and take control of the
          whole page.
        - Alternatively you could grab the URL with js and use Ports.
    9. Get Mike to check over the code.


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
    2. Is there any other profile information we can pull out with an Action?
        - @ https://auth0.com/docs/manage-users/user-accounts/user-profiles#access-user-profiles-from-the-management-api
        - @ https://auth0.com/docs/user-profile/user-profile-structure
    3. Session management and documentation is a bit of a shit show. Lots of
       different APIs and usecases:
        - @ https://auth0.com/blog/application-session-management-best-practices/
        - @ https://community.auth0.com/t/confusion-around-authorization/78981/2
    4. To update the user you need to set the correct scopes in your `/authorize`
       endpoint.

-}

import Auth.Auth0 as Auth0 exposing (ProfileBasic, Auth0Config)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Json.Encode as E
import Json.Decode as D exposing (Decoder)

import Debug


-- Login link ------------------------------------------------------------------
-- Including an example `auth0AuthorizeUrl` return url

returnUrl =
    "http://localhost:8000/index.html" ++
    "#access_token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwiaXNzIjoiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vIn0..-R1F7wflD5Afl_XA.-wvnb48v80rd4vKDTjX3_gFO0l53uKtV3s4t3oF_dvNPcCz8nynIfNUj9u30myrxSCF4ERNFN0Y4VVgpDoYVttnXvSntJVLIoNdzgt2RXWDNxsckbzy-38MBL7GDYSiB2BY55Y4qqhUr4R-67jTKUvqLgVT1vcdE_HIr_bbuy_4IFfrid-ekHla78FcSzuPPKZK51nEG1IAIJ8aQkD-VJZfiInfp2YOPzBwYymj2oz3RCK-uM_gnmiB0a9gWLxDcovdBf7HxlsfxPWlo23uEeaRaWj4Xluo60bqwy7WepfDUm2yFlhfxhyZNvJVmgEn79hZ6UnDt6KoVoZ_by4ua.TTUwmDWIA74XMLGtJAiB4A" ++
    "&scope=openid%20email" ++
    "&expires_in=7200" ++ -- default expiry time
    "&token_type=Bearer"

authConfig =
    (Auth0Config "https://dev-ne2fnlv85ucpfobc.uk.auth0.com" "YzMHtC6TCNbMhvFB5AyqFdwfreDmaXAW")

url : String
url =
    Auth0.auth0AuthorizeURL
        authConfig
        "token"
        "http://localhost:8000/09-auth0.html" -- was https
        [ "openid", "name", "email" ]
        Nothing -- social login param
        (Just "cool-api") -- Nothing (audience param)

getToken : String
getToken =
    Debug.todo """List.intersperse ":" and String.split on `.`"""


-- User Profile -----------------------------------------------------------------

type alias UserMeta =
    { json : String, prefs : List String }

encodeUserMeta : E.Value
encodeUserMeta =
    E.object
        [ ( "json", E.string "esYNFY" )
        , ( "prefs", E.list E.string ["a","b", "c"] )
        ]

decoderUserMetadata : Decoder UserMeta
decoderUserMetadata =
    D.map2 (\a b -> { json = a, prefs = b })
        (D.field "json" D.string)
        (D.field "prefs" (D.list D.string))

decoderAppMetadata : Decoder String
decoderAppMetadata =
    D.succeed "That"

getProfile : Cmd Msg
getProfile =
    Auth0.getAuthedUserProfile
        authConfig -- extracts the endpoint
        "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlQnhDcVpNOFhpRGtiZHZaX2xlWCJ9.eyJpc3MiOiJodHRwczovL2Rldi1uZTJmbmx2ODV1Y3Bmb2JjLnVrLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2ODFjZTNjNjMzOTE1MmY4N2E1ODNmNGMiLCJhdWQiOlsiY29vbC1hcGkiLCJodHRwczovL2Rldi1uZTJmbmx2ODV1Y3Bmb2JjLnVrLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE3NDcwNTg4MTUsImV4cCI6MTc0NzA2NjAxNSwic2NvcGUiOiJvcGVuaWQgZW1haWwiLCJhenAiOiJZek1IdEM2VENOYk1odkZCNUF5cUZkd2ZyZURtYVhBVyJ9.rOIx9e6lBQciNM3E4d0B3SAjLGBCBf95yX5L4GywtBgI6BGw6OL1BMauSvNJxsfNi0F0edOdEiKN3QygF1kj7bqKuHxJkW2MpT1fCZrEsJZCg3U7H30i-_G-XJduCW1kr2tuUO1cQ4nsYl7ogwWQ8XL3vw9PWUSTbPdFMD6c5oBMR-JlEOkk258oCTYibMUwjL6FslKdDC0TCxOGng3xwyRWtw1qvrwCieGuCCcmdl1DGoiktX0L_uouBnB8z63FwdBCwNCeCk8vjOziCDaxt8btFbQEDN9ESDua38xzC4MqzGb8fnwfYn2Ql4x0UStXybWTe_xoWye9ltX6obvXRQ"
        GotProfile
        (Auth0.decoderBasic decoderUserMetadata decoderAppMetadata) -- #! Fix


{- #! Only returns the `user_metadata` not the full profile -}
updateProfile : Cmd Msg
updateProfile =
    Auth0.updateUserMetaData
        authConfig
        "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlQnhDcVpNOFhpRGtiZHZaX2xlWCJ9.eyJpc3MiOiJodHRwczovL2Rldi1uZTJmbmx2ODV1Y3Bmb2JjLnVrLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2ODFjZTNjNjMzOTE1MmY4N2E1ODNmNGMiLCJhdWQiOlsiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vYXBpL3YyLyIsImh0dHBzOi8vZGV2LW5lMmZubHY4NXVjcGZvYmMudWsuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTc0NzA1OTE1NywiZXhwIjoxNzQ3MDY2MzU3LCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIHVwZGF0ZTpjdXJyZW50X3VzZXJfbWV0YWRhdGEiLCJhenAiOiJZek1IdEM2VENOYk1odkZCNUF5cUZkd2ZyZURtYVhBVyJ9.X3sYhFK0T_TjwOHFonzF5lbI9XnlLyFUMF7-8Y6heICOISKBujfKCTYz2sPBk_5RK9fxq-1FD6JGJ06rcuqNZKFkEG1cKn1hjJ3iTfJHRCWa_464ED2y9bgPF20kZ20xGv7Yc-ueGO5Nap80eMG8A4xtfcYHgnPTfwaRpekEvtz6qH_YOsD6vK_4v5p5HjRChonw_AzZB4IZW6Y2Yq_pyacyGCmnDHYhc9EBeC_b8ITiBb1k36xoXtZQNo1RL6kMaZQZqMmafj0Q-uN92WhqYwWSKgXEAvjREkeq03OhpO0dcF1iRdU9-an4_KiQcdtyuye9FOSJ9bAVFDhTAH8wdA"
        GotMeta
        (D.at ["user_metadata"] decoderUserMetadata) -- #! Could this return `GotProfile`?
        "auth0|681ce3c6339152f87a583f4c" -- userID
        encodeUserMeta -- user metadata


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
  | ClickedUpdateProfile
  | GotMeta (Result Http.Error UserMeta) -- #! Can this return the FULL profile?
  | GotProfile (Result Http.Error (ProfileBasic UserMeta String)) -- #! Moved from Auth0.elm to `Main.Msg`


-- Update ----------------------------------------------------------------------

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case Debug.log "The Msg: " msg of
        ClickedGetProfile ->
            ( model
            , getProfile -- #! New version of Auth package
            )

        ClickedUpdateProfile ->
            ( model
            , updateProfile
            )

        GotMeta (Ok meta) ->
            ( { model | meta = meta }
            , Cmd.none
            )

        GotMeta (Err _) ->
            ( { model | error = "Something went wrong with metadata update" }
            , Cmd.none
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
        , button [ onClick ClickedUpdateProfile ] [ text "Update Profile Metadata" ]
        , a [ href logout ] [ text "Logout" ] -- Returns to root url
        ]

viewProfile : Maybe (ProfileBasic UserMeta String) -> Html Msg
viewProfile profile =
    case profile of
        Nothing ->
            p [] [ text "No profile" ]

        Just prof ->
            p [] [ text (Debug.toString prof) ]


-- Model -----------------------------------------------------------------------

type alias Model
    = { name : String
      , profile : Maybe (ProfileBasic UserMeta String)
      , meta : UserMeta -- #! This needs to be updated in PROFILE
      , error : String
    }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model "" Nothing (UserMeta "" [""]) "", Cmd.none)


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

