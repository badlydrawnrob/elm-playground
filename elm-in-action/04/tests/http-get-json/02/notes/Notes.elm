module Notes exposing (..)
import Http exposing (Header)

-- Concatenating a table list --------------------------------------------------

-- This won't work -------------------------------------------------------------

table []
  [ viewTable Header
  , List.map viewPost posts
  ]


-- This will work --------------------------------------------------------------

viewPosts : List Post -> Html Msg
viewPosts posts =
  table []
    ([ viewTableHeader ] ++ List.map viewPost posts)
--   ^^^^^^^^^^^^^^^^^^^  a list
--                          ^^^^^^^^ another list


type alias Post =
  { id : Int
  , title : String
  , author: String
  }

posts : List Post
posts =
  [
    { id = 1
    , title = "Title 1"
    , author = "Bob"
    }
  , { id = 2
    , title = "Title 2"
    , author = "Helen"
    }
  ]

-- Outputs tr []
--           [ th [] [], ...]

viewTableHeader : Html Msg
viewTableHeader =
  tr []
    (List.map viewTableHeaderItem ["ID", "Title", "Author"])

viewTableHeaderItem : String -> Html Msg
viewTableHeaderItem header =
    th [] [ text header ]


-- Outputs tr []
--           [ td [] [], ...]

viewPost : Post -> Html Msg
viewPost post =
  tr []
    [ td []
        [ text (String.fromInt post.id) ]
    , td []
        [ text post.title ]
    , td []
        [ text post.author ]
    ]


-- This will output --
-- Because we're ++ concatonating the two together
-- it'll output something like this:


table []
  [ tr []
    [ th []
        [ text "ID" ]
    , th []
        [ text "Title" ]
    , th []
        [ text "Author" ]
    ]
  , tr []
    [ td []
        [ text "1" ]
    , td []
        [ text "json-server" ]
    , td []
        [ text "typicode" ]
    ]
  , tr []
    [ td []
        [ text "2" ]
    , td []
        [ text "http-server" ]
    , td []
        [ text "indexzero" ]
    ]
  ]


-- `Decode.succed` tests -------------------------------------------------------

import Json.Decode exposing (..)

decodeString (succed 42) "1"
-- Ok 42 : Result Error number
decodeString (succed 42) "true"
-- Ok 42 : Result Error number


-- `Json.Decode.Pipeline` --

-- Makes clever use of `succeed` to turn the
-- JSON decoding process into a pipeline operation.

postDecoder : Decoder Post
postDecoder =
  Decode.succeed Post
    |> required "id" int
    |> required "title" string
    |> required "author" string
