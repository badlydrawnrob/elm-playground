port module LargerApps.WebSocket exposing (listen, receive)

{- WebSockets
   ----------

   This is a ports version of the `elm-lang/websocket` package,
   which is still waiting to be updated to the latest Elm version.

-}

port listen : String -> Cmd msg

{- This takes a function which holds a `String` and returns a `msg` -}
port receive : (String -> msg) -> Sub msg
--             ^^^^^^^^^^^^^^^
