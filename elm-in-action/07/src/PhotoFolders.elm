module PhotoFolders exposing (main)

import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Dict exposing (Dict)


-- Model -----------------------------------------------------------------------

-- #1: Instead of a `List Photo` or an `Array Photo`, we're using a `Dict`.
--     A `Dict` must have a `comparable` as it's Key. It's Value can be anything.
--     This make our `Photo`s much quicker to find/search.
--
--     As our `init` won't have access to the server's `Photo`s, we'll need to
--     start off with an empty dictionary: `Dict.empty`
--
-- #2: We're getting data from the server right away, by sending a `Cmd`
-- #3: For now, use a hardcoded dictionary
--
-- #4: We're adding a Recursive Custom Type called `Folder`, that represents our
--     folder structure. It also contains a `name` and a `List String` of our
--     `photoUrls`. See notes on recursive structures.

type Folder =
  Folder   -- #4
    { name : String
    , photoUrls : List String
    , subfolders : List Folder  -- #4
  }

type alias Model =
  { selectedPhotoUrl : Maybe String
  , photos : Dict String Photo  -- #1
  , root : Folder -- #4
  }

initialModel : Model
initialModel =
  { selectedPhotoUrl = Nothing
  , photos = Dict.empty  -- #1
  , root = Folder { name = "", photoUrls = [], subfolders = [] }
  }

init : () -> ( Model, Cmd Msg )
init _ =
  ( initialModel
  , Http.get  -- #2
      { url = "http://elm-in-action.com/folders/list"
      , expect = Http.expectJson GotInitialModel modelDecoder
      }
  )

modelDecoder : Decoder Model
modelDecoder =
  Decode.succeed
    { selectedPhotoUrl = Just "trevi"
    , photos = Dict.fromList
        [ ( "trevi"
          , { title = "Trevi"
            , relatedUrls = [ "coli", "fresco" ]
            , size = 34
            , url = "trevi"
            }
          )
        , ( "fresco"
            , { title = "Fresco"
            , relatedUrls = [ "trevi" ]
            , size = 46
            , url = "fresco"
            }
          )
        , ( "coli"
          , { title = "Coliseum"
            , relatedUrls = [ "trevi", "fresco" ]
            , size = 36
            , url = "coli"
            }
          )
        ]
    , root =
        Folder
          { name = "Photos", photoUrls = []
          , subfolders =
              [ Folder
                  { name = "2016", photoUrls = [ "trevi", "coli" ]
                  , subfolders =
                    [ Folder
                      { name = "outdoors", photoUrls = []
                      , subfolders = []
                      }
                    , Folder
                      { name = "indoors", photoUrls = [ "fresco" ]
                      , subfolders = []
                      }]
                  }
                , Folder
                  { name = "2017", photoUrls = []
                  , subfolders =
                      [ Folder
                        { name = "outdoors", photoUrls = []
                        , subfolders = []
                        }
                      , Folder
                        { name = "indoors", photoUrls = []
                        , subfolders = []
                        }
                      ]
                  }
              ]
          }
      }


-- Update ----------------------------------------------------------------------

-- #1: Accepts the new model we recieved from the server
-- #2: We'll ignore page load errors for now.

type Msg
  = ClickedPhoto String
  | GotInitialModel (Result Http.Error Model)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ClickedPhoto url ->
      ( { model | selectedPhotoUrl = Just url }, Cmd.none )

    GotInitialModel (Ok newModel) ->
      ( newModel, Cmd.none )    -- #1

    GotInitialModel (Err _) ->  -- #2
      ( model, Cmd.none )


-- View ------------------------------------------------------------------------

-- #1: I think this is the correct way to do this. Remember that in this
--     scenario a `msg` isn't returned. In other scenarios `msg` is a type variable,
--     or else it'd be a `Msg`.
--     @ https://tinyurl.com/elm-lang-html-attr-src
--
-- #2: Here we cycle through a list of urls (Strings) and generate our thumbs
--
-- #3: This is a little complex. We need to check:
--
--     a) Does `selectedPhotoUrl` contain a `String`?
--     b) If so, use this value for `Dict.get` function. If the`comparable`
--       value (a `String`) has a matching `Key` in our Dictionary, grab it's
--       value (a `Photo`).
--     c) If we have both a `String` value in `selectedPhotoUrl`, AND it's also
--        matching our `Dict.get` Key in our `Dict`ionary — return it's Value.
--        Pass that value to call our `viewSelectedPhoto` function to build the image.
--     d) If there is no `selectedPhotoUrl`, return `Nothing`. If there is no
--        match in `Dict`ionary, return `Nothing`. (Share the `Nothing` case)
--
-- #4: Here we access the `Folder` type we are using in our `model.root`:
--
--     a) This uses a shorthand for accessing `Folder` content, which is a record.
--        In fact, there's a bunch of records that are nested inside `subfolders`
--        so `Folder { record }` has a few children.
--
--        `(Folder folder)` could also be seen as `(Folder record)` or
--        `(Folder content)` — See the `Folder` type above.
--
--      b) This is the first recursive `view` function I've seen.
--         `List.map` is going to loop through all nested `(Folder record)`
--        entries from `model.root` and use the `viewFolder` to render them.
--
--

type alias Photo =
  { title : String
  , size : Int
  , relatedUrls : List String
  , url : String
  }


view : Model -> Html Msg
view model =
  let
    photoByUrl : String -> Maybe Photo
    photoByUrl url =
      Dict.get url model.photos

    selectedPhoto : Html Msg
    selectedPhoto =
      case Maybe.andThen photoByUrl model.selectedPhotoUrl of  -- #3b, #3a
          Just photo ->
            viewSelectedPhoto photo                            -- #3c

          Nothing ->
            text ""                                            -- #3c
    in
      div [ class "content" ]
        [ h1 [] [ text "The Grooviest Folders the World Has Ever Seen" ]
        , div [ class "folders"]
            [ h1 [] [ text "Folders" ]
            , viewFolder model.root
            ]
        , div [ class "selected-photo" ] [ selectedPhoto ]
        ]



urlPrefix =
  "http://elm-in-action.com/"

imgSource : String -> String -> Attribute msg  -- #1
imgSource url size =
  src (urlPrefix ++ "photos/" ++ url ++ size)

viewSelectedPhoto : Photo -> Html Msg
viewSelectedPhoto photo =
  div
    [ class "selected-photo" ]
    [ h2 [] [ text photo.title ]
    , img [ (imgSource photo.url "/full") ] []
    , span [] [ text (String.fromInt photo.size ++ "KB") ]
    , h3 [] [ text "Related" ]
    , div [ class "related-photos" ]
        (List.map viewRelatedPhoto photo.relatedUrls)  -- #2
    ]

viewRelatedPhoto : String -> Html Msg
viewRelatedPhoto url =
  img
    [ class "related-photo"
    , onClick (ClickedPhoto url)
    , (imgSource url "/thumb")
    ]
    []

viewFolder : Folder -> Html Msg
viewFolder (Folder folder) =  -- #4a
  let
    subfolders =
      List.map viewFolder folder.subfolders  -- #4b
  in
    div [ class "folder" ]
      [ label [] [ text folder.name ]
      , div [ class "subfolders" ] subfolders
      ]


-- Main ------------------------------------------------------------------------

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
