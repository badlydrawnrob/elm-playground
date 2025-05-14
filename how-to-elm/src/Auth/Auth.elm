module Auth.Auth exposing (..)

{-| ----------------------------------------------------------------------------
    Testing the auth0 elm library
    ============================================================================
    > The auth0 documentation is hard to get through: it's confusing to know how
    > to do things the right way that work reliably.

    However, I've revamped the Auth0 Elm package and it's currently working for
    the `/authorize`, `/userinfo`, and `/api/v2` endpoints. To be frank, it'd be
    easier to build the damn thing in Python, as it's taken 3 days of testing
    and figuring out how to make the Auth0 API work. It's handy for prototyping
    though, so hopefully their docs won't change much now.

    Right now I've separated concerns in the app, to show the functionality, but
    in live production you'll likely want to:

    1. Throwaway the `access_token` once you're done with it (for security)
    2. Use the `Auth0.updateProfile` function to update `Profile UserMeta _`


    Bugs
    ----
    1. There's no refresh function, as it seems like a hassle.
        - Notify the user they'll have to login again.
    2. `AccessToken` is NOT invalidated when user clicks the `logoutUrl`
        - Have a short expiry time and DO NOT STORE IT.
    3. Elm caches the js, so sometimes changing a line doesn't work.
        - Set the browser to no-cache mode?
    4. `Decoder a` and `(Result Http.Error a)` make things a wee bit confusing,
       but much easier to extend the package.
    5. Session management and documentation is a bit of a shit show. Lots of
       different APIs and usecases:
        - @ https://auth0.com/blog/application-session-management-best-practices/
        - @ https://community.auth0.com/t/confusion-around-authorization/78981/2


    Wishlist
    --------
    > First check your code for errors!
    > https://jwt.io/ to check the access token.

    1. Extract the `access_token` from the URL and split out the necessary parts.
        - Have all messages working in a single `elm reactor` session.
    2. Add an `expiry` counter that saves to `localStorage` (which will work with
       any API endpoint, such as my Python one.
    3. Ping the `/userinfo` endpoint or update `Profile UserMeta _` after the
       `user_metadata` has been updated.
    4. Figure out how to extract `IdToken` and if it's worth doing.
    5. See if any other functions could be useful for the `Auth0` package
        - extract functions?
    6. `URL` in Elm lang is a headache. Try out Elm Land.
        - You could check the url with javascript, then pass it in a temporary
          variable to Elm.
        - `URL` requires `Browser.application`, which takes control of the whole
          page.
    7. Have Mike, or someone you trust look over the code for security issues.


    The API
    -------
    > @ https://auth0.com/docs/api/authentication
    > @ https://jwt.io/ (Test the JWT token)

    The default time for the token is 7200 seconds (2 hours). This can be
    extended. I'm going to leave profile editing out of scope (you can update the
    `user_metadata`) as it uses the Auth0 Management API (I don't think this is
    free).
-}

import Auth.Auth0 as Auth0 exposing (Profile, Auth0Config)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Json.Encode as E
import Json.Decode as D exposing (Decoder)

import Debug


-- Example return url ----------------------------------------------------------

returnUrl =
    "http://localhost:8000/index.html" ++
    "#access_token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwiaXNzIjoiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vIn0..-R1F7wflD5Afl_XA.-wvnb48v80rd4vKDTjX3_gFO0l53uKtV3s4t3oF_dvNPcCz8nynIfNUj9u30myrxSCF4ERNFN0Y4VVgpDoYVttnXvSntJVLIoNdzgt2RXWDNxsckbzy-38MBL7GDYSiB2BY55Y4qqhUr4R-67jTKUvqLgVT1vcdE_HIr_bbuy_4IFfrid-ekHla78FcSzuPPKZK51nEG1IAIJ8aQkD-VJZfiInfp2YOPzBwYymj2oz3RCK-uM_gnmiB0a9gWLxDcovdBf7HxlsfxPWlo23uEeaRaWj4Xluo60bqwy7WepfDUm2yFlhfxhyZNvJVmgEn79hZ6UnDt6KoVoZ_by4ua.TTUwmDWIA74XMLGtJAiB4A" ++
    "&scope=openid%20email" ++
    "&expires_in=7200" ++ -- default expiry time
    "&token_type=Bearer"


-- Login to account-------------------------------------------------------------
-- 1. If you have an `/audience` parameter, you can add more scopes
-- 2. Such as `update:current_user_metadata`.
--    - Careful! This could be a bit of a security risk. Only allow the user the
--      permissions for _their_ account.
-- 3. The default time for the token is 7200 seconds (2 hours).

baseUrl =
    "http://localhost:8000"

authConfig =
    (Auth0Config "https://dev-ne2fnlv85ucpfobc.uk.auth0.com" "YzMHtC6TCNbMhvFB5AyqFdwfreDmaXAW")

url : String
url =
    Auth0.auth0AuthorizeURL
        authConfig
        "token"
        (baseUrl ++ "/09-auth0.html") -- #! https for live
        [ "openid", "name", "email", "update:current_user_metadata" ] -- #! (2)
        Nothing -- social login param
        (Just "https://dev-ne2fnlv85ucpfobc.uk.auth0.com/api/v2/") -- (1) or `Nothing`

getToken : String
getToken =
    Debug.todo """List.intersperse ":" and String.split on `.`""" -- #! (3)


-- User Profile -----------------------------------------------------------------

type alias UserMeta =
    { json : String, prefs : List String }

type alias AppMeta =
    String

encodeUserMeta : E.Value
encodeUserMeta =
    E.object
        [ ( "json", E.string "esYNFY" )
        , ( "prefs", E.list E.string ["b","c", "d"] )
        ]

decoderUserMetadata : Decoder UserMeta
decoderUserMetadata =
    D.map2 (\a b -> { json = a, prefs = b })
        (D.field "json" D.string)
        (D.field "prefs" (D.list D.string))

decoderAppMetadata : Decoder String
decoderAppMetadata =
    D.succeed "Currently an empty object" -- #! Fix this: do we need app data?

getProfile : Cmd Msg
getProfile =
    Auth0.getAuthedUserProfile
        authConfig -- extracts the endpoint
        "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlQnhDcVpNOFhpRGtiZHZaX2xlWCJ9.eyJpc3MiOiJodHRwczovL2Rldi1uZTJmbmx2ODV1Y3Bmb2JjLnVrLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2ODFjZTNjNjMzOTE1MmY4N2E1ODNmNGMiLCJhdWQiOlsiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vYXBpL3YyLyIsImh0dHBzOi8vZGV2LW5lMmZubHY4NXVjcGZvYmMudWsuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTc0NzI0MzEyOCwiZXhwIjoxNzQ3MjUwMzI4LCJzY29wZSI6Im9wZW5pZCBlbWFpbCB1cGRhdGU6Y3VycmVudF91c2VyX21ldGFkYXRhIiwiYXpwIjoiWXpNSHRDNlRDTmJNaHZGQjVBeXFGZHdmcmVEbWFYQVcifQ.GrJOsBvTeseUziZDdHRqVLrsb5YTVoAIsbpJdfodtTBLTJO_e4NRndcofJUvHQZ01_9Q7aI478ZemWI_CFk90u8xQBz4HPw-7Fb8ryMA_paT5_eQXkhFVtkdrYkKL66T5SLW-T73Xs1Ak7H19xZH0l9uPpvSfmWI_IdDg1olA2LkcmzgGi4lyHjxRQMwyrJp8gwUljWhCMHAHXecIpvETV0FOAf8kX92vlrRNvQSCbOI559tR1bBZtYih6O45roxlk8qhyLH3pDlFE1YB6IvNGBXyE7lv6LoM_-aBKFqDmprizY12vEVLDxCs7MhBz7vawMhZ3p0mNCdG2SNXzMi8w"
        GotProfile
        (Auth0.decoder decoderUserMetadata decoderAppMetadata)


-- Profile updates --------------------------------------------------------------
-- This function will only return the `user_metadata`, not the full profile.
--
-- 1. ⚠️ Make sure `UserId` in the `AccessToken` matches the profile to be accessed.
-- 2. ⚠️ Our old `AccessToken` (which you should've destroyed) caches the old
--    profile metadata, so our updates won't show up ...
--    - Better to update `profile.user_metadata` manually, or get a new `AccessToken`!

updateUserMeta : Cmd Msg
updateUserMeta =
    Auth0.updateUserMetaData
        authConfig
        "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlQnhDcVpNOFhpRGtiZHZaX2xlWCJ9.eyJpc3MiOiJodHRwczovL2Rldi1uZTJmbmx2ODV1Y3Bmb2JjLnVrLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2ODFjZTNjNjMzOTE1MmY4N2E1ODNmNGMiLCJhdWQiOlsiaHR0cHM6Ly9kZXYtbmUyZm5sdjg1dWNwZm9iYy51ay5hdXRoMC5jb20vYXBpL3YyLyIsImh0dHBzOi8vZGV2LW5lMmZubHY4NXVjcGZvYmMudWsuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTc0NzI0MzEyOCwiZXhwIjoxNzQ3MjUwMzI4LCJzY29wZSI6Im9wZW5pZCBlbWFpbCB1cGRhdGU6Y3VycmVudF91c2VyX21ldGFkYXRhIiwiYXpwIjoiWXpNSHRDNlRDTmJNaHZGQjVBeXFGZHdmcmVEbWFYQVcifQ.GrJOsBvTeseUziZDdHRqVLrsb5YTVoAIsbpJdfodtTBLTJO_e4NRndcofJUvHQZ01_9Q7aI478ZemWI_CFk90u8xQBz4HPw-7Fb8ryMA_paT5_eQXkhFVtkdrYkKL66T5SLW-T73Xs1Ak7H19xZH0l9uPpvSfmWI_IdDg1olA2LkcmzgGi4lyHjxRQMwyrJp8gwUljWhCMHAHXecIpvETV0FOAf8kX92vlrRNvQSCbOI559tR1bBZtYih6O45roxlk8qhyLH3pDlFE1YB6IvNGBXyE7lv6LoM_-aBKFqDmprizY12vEVLDxCs7MhBz7vawMhZ3p0mNCdG2SNXzMi8w"
        GotMeta -- #! Fix this: add to `Profile UserMeta _`
        (D.at ["user_metadata"] decoderUserMetadata)
        "auth0|681ce3c6339152f87a583f4c" -- #! (1)
        encodeUserMeta -- The data to be updated!

updateProfileUserMeta :
    -> Profile UserMeta String
    -> UserMeta
    -> AppMeta -- #! This will be rarely used.
    -> Profile UserMeta String -- #! The `Maybe` types are added in the function
updateProfileUserMeta profile userMeta appMeta =
    Auth0.updateProfile profile userMeta appMeta


-- Logout ----------------------------------------------------------------------

{- "federated" should force logout for openid providers -}
logout =
    Auth0.logoutUrl
        (Auth0Config "https://dev-ne2fnlv85ucpfobc.uk.auth0.com" "YzMHtC6TCNbMhvFB5AyqFdwfreDmaXAW")
        True -- Do you want to force logout of social login? (if any)
        (baseUrl ++ "/09-auth0.html") -- Redirect url


-- Msg -------------------------------------------------------------------------

type Msg
  = ClickedGetProfile
  | ClickedUpdateProfile
  | GotMeta (Result Http.Error UserMeta) -- #! Can this return the FULL profile?
  | GotProfile (Result Http.Error (Profile UserMeta String)) -- #! Moved from Auth0.elm to `Main.Msg`


-- Update ----------------------------------------------------------------------
-- 1. You'd want to use the

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case Debug.log "The Msg: " msg of
        ClickedGetProfile ->
            ( model
            , getProfile
            )

        ClickedUpdateProfile ->
            ( model
            , updateUserMeta
            )

        GotProfile (Ok profile) ->
            ( { model | profile = Just profile }, Cmd.none )

        GotProfile (Err _) ->
            ( { model | error = "Something went wrong getting the profile" }
            , Cmd.none
            )

        GotMeta (Ok meta) ->
            ( { model | meta = meta } -- (1)
            , Cmd.none
            )

        GotMeta (Err err) ->
            case err of
                Http.BadStatus 401 ->
                    ( { model | error = "You're not authorised to do this" }
                    , Cmd.none
                    )

                Http.BadStatus 403 ->
                    ( { model | error = "You've probably got the wrong user id" }
                    , Cmd.none
                    )

                _ ->
                    ( { model | error = "Something went wrong with the profile update" }
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

viewProfile : Maybe (Profile UserMeta String) -> Html Msg
viewProfile profile =
    case profile of
        Nothing ->
            p [] [ text "No profile" ]

        Just prof ->
            p [] [ text (Debug.toString prof) ]


-- Model -----------------------------------------------------------------------

type alias Model
    = { name : String
      , profile : Maybe (Profile UserMeta String)
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

