module File.ImageResponse exposing (..)

{-| An example response from https://freeimage.host/
    ------------------------------------------------
    ⚠️ I think Elm doesn't like modules and package name clashes (like `File`)

    You can test the server with an API key and Curl:

        @ https://linuxize.com/post/curl-post-request/
        @ https://www.browserling.com/tools/strip-slashes

    You can use `-d` with a long `'key=...&source=...'` or split them
    into separate `-d`s like so:

    curl -d 'key=[YOUR-API-KEY]'
         -d 'source=[IMAGE-URL]'
         -d 'format=json' https://freeimage.host/api/1/upload

    Any image will do:

        https://www.boredpanda.com/blog/wp-content/uploads/2021/02/602e5c7474580_dipqm35gir161__700.jpg


    Things I learned
    ----------------

    1. Take care of naming conflicts, like `elm/file` and naming your module
       `File.Whatever` — throws an error (thinks you're importing `elm/file`)


    Questions
    ---------
    1. Initially I had `ImageUrl` was a `String` ... but `decodeImage`
       will complain. How do you `map` a decoder to a type alias?

-}

import Json.Decode as D exposing (at, decodeString, Decoder, Error, string)
import File exposing (File)
import File.ImageModel exposing (..)
import Http


exampleResponse : String
exampleResponse =
    """
    {
        "status_code": 200,
        "success": {
            "message": "image uploaded",
            "code": 200
        },
        "image": {
            "name": "602e5c7474580 dipqm35gir161 700",
            "extension": "jpg",
            "width": 700,
            "height": 698,
            "size": 146802,
            "time": 1727874343,
            "expiration": 0,
            "likes": 0,
            "description": null,
            "original_filename": "602e5c7474580_dipqm35gir161__700.jpg",
            "is_animated": 0,
            "nsfw": 0,
            "id_encoded": "dDUV9d7",
            "size_formatted": "146.8 KB",
            "filename": "dDUV9d7.jpg",
            "url": "https://iili.io/dDUV9d7.jpg",
            "url_short": "https://freeimage.host/",
            "url_seo": "https://freeimage.host/i/602e5c7474580-dipqm35gir161-700.dDUV9d7",
            "url_viewer": "https://freeimage.host/i/dDUV9d7",
            "url_viewer_preview": "https://freeimage.host/i/dDUV9d7",
            "url_viewer_thumb": "https://freeimage.host/i/dDUV9d7",
            "image": {
            "filename": "dDUV9d7.jpg",
            "name": "dDUV9d7",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://iili.io/dDUV9d7.jpg",
            "size": 146802
            },
            "thumb": {
            "filename": "dDUV9d7.th.jpg",
            "name": "dDUV9d7.th",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://iili.io/dDUV9d7.th.jpg"
            },
            "medium": {
            "filename": "dDUV9d7.md.jpg",
            "name": "dDUV9d7.md",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://iili.io/dDUV9d7.md.jpg"
            },
            "display_url": "https://iili.io/dDUV9d7.md.jpg",
            "display_width": 700,
            "display_height": 698,
            "views_label": "views",
            "likes_label": "likes",
            "how_long_ago": "1 second ago",
            "date_fixed_peer": "2024-10-02 13:05:43",
            "title": "602e5c7474580 dipqm35gir161 700",
            "title_truncated": "602e5c7474580 dipqm35gir1...",
            "title_truncated_html": "602e5c7474580 dipqm35gir1...",
            "is_use_loader": false
        },
        "status_txt": "OK"
    }
    """

{- This definitely works (without a trailing slash) — if you upload the same
image url twice, it's the same URL in the `json` response! -}
testImageUrl : String
testImageUrl =
    "https://freeimage.host/api/1/upload?key=6d207e02198a847aa98d0a2a901485a5&source=https://cdsassets.apple.com/live/7WUAS350/images/macos/sonoma/macos-sonoma-recovery-disk-utility.png&format=json"

freeImageUrl : String
freeImageUrl =
    "https://freeimage.host/api/1/upload?key="  -- I don't think trailing slash `/` is required?

decodeImage : Decoder String
decodeImage =
    (D.at ["image", "url"] D.string)

{- Helpful for testing in `elm repl` -}
grabImage : String -> Result Error String
grabImage json =
    decodeString decodeImage json

postImage : String -> String -> Cmd Msg
postImage key file =
    Http.post
        { url = freeImageUrl ++ key ++ "&source=" ++ file ++ "&format=json"
        , body = Http.emptyBody
        , expect = Http.expectJson SentImage decodeImage
        }

-- postImage : String -> String -> Cmd Msg
-- postImage key file =
--     Http.get
--         { url = freeImageUrl ++ key ++ "&source=" ++ file ++ "&format=json"
--         , expect = Http.expectJson SentImage decodeImage
--         }

