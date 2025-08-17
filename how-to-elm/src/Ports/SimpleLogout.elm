module Ports.SimpleLogout exposing (..)

{-| ----------------------------------------------------------------------------
    From the example in Slack
    ============================================================================
    Here we have everything contained in the one file, unlike our `LocalStorage.elm`
    example. We start with a flag that may be `Nothing` and we've got two functions
    that set login/logout. Unlike `LocalStorage.elm`, our update function is simple
    and doesn't attempt to `Cmd.batch` our commands. It's one `Cmd` to login, and
    one to logout.

    Pushing our changes The JS side would look like:

    ```js
    const localStorageAuthKey = "my-app-auth";
    const auth = localStorage.getItem(localStorageAuthKey);
    const app = Elm.Main.init(someNode, {auth});

    app.ports.persistLogin.subscribe((auth) => localStorage.setItem(localStorageAuthKey,auth));
    app.ports.persistLogout.subscribe(() => localStorage.removeItem(localStorageAuthKey));
    ```

    You might also like to check if the function exists as Ryan Haskell suggests.
    If it doesn't exist, you can use a default value or do nothing ...
    @ https://www.youtube.com/watch?v=YfS5BJ4IXcQ

    ```js
    if (app.ports?.persistLogin?.subscribe) {
      app.ports.persistLogin.subscribe((auth) => localStorage.setItem
    }
    ```
-}

port persistLogin : String -> Cmd msg
port persistLogout : () -> Cmd msg

type alias Flags =
  { auth : Maybe String }

type alias Model =
  { auth : Maybe String }

type Msg
  = LogIn String
  | LogOut

init : Flags -> (Model, Cmd Msg)
init flags =
  ( { auth = flags.auth }
  , Cmd.none
  )

update msg model =
  case msg of
    LogIn auth -> ({ model | auth = Just auth }, persistLogin auth)
    LogOut     -> ({ model | auth = Nothing },   persistLogout ())
