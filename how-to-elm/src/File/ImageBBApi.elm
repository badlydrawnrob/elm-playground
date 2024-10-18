module File.ImageBBApi exposing (..)

{-| ----------------------------------------------------------------------------
    ImgBB.com API
    ============================================================================
    ⚠️ Fine for demos an early MVP but how's customer service?
    ⚠️ Remember that json needs to be escaped!

    See @ issue #43 for notes on `base64`, Curl examples, and CORS errors.
    `imgbb.com` allows origin with different domain.

    Curl ONLY works when sent as a form:

        curl --location
             --request POST "https://api.imgbb.com/1/upload?expiration=600&key=[YOUR-API-KEY]"
             --form "image=[DATA-STRING|HTTP-IMAGE-URL]"

    Any image will do:

        @ https://cdsassets.apple.com/live/7WUAS350/images/macos/sonoma/macos-sonoma-recovery-disk-utility.png

    See this example by @passiomatic for ideas:

        @ https://github.com/passiomatic/elm-designer/blob/master/src/Imgbb.elm

    StackOverflow "how to configure http request with `--form` Elm"

        @ https://tinyurl.com/elm-http-request-with-form

-}


exampleResponse : String
exampleResponse =
    """
    {
        "data": {
            "id": "GcrbjRd",
            "title": "602e5c7474580-dipqm35gir161-700",
            "url_viewer": "https://ibb.co/GcrbjRd",
            "url": "https://i.ibb.co/2gpfBdF/602e5c7474580-dipqm35gir161-700.jpg",
            "display_url": "https://i.ibb.co/5BJfVL1/602e5c7474580-dipqm35gir161-700.jpg",
            "width": 700,
            "height": 698,
            "size": 98898,
            "time": 1729271123,
            "expiration": 800,
            "image": {
            "filename": "602e5c7474580-dipqm35gir161-700.jpg",
            "name": "602e5c7474580-dipqm35gir161-700",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://i.ibb.co/2gpfBdF/602e5c7474580-dipqm35gir161-700.jpg"
            },
            "thumb": {
            "filename": "602e5c7474580-dipqm35gir161-700.jpg",
            "name": "602e5c7474580-dipqm35gir161-700",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://i.ibb.co/GcrbjRd/602e5c7474580-dipqm35gir161-700.jpg"
            },
            "medium": {
            "filename": "602e5c7474580-dipqm35gir161-700.jpg",
            "name": "602e5c7474580-dipqm35gir161-700",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://i.ibb.co/5BJfVL1/602e5c7474580-dipqm35gir161-700.jpg"
            },
            "delete_url": "https://ibb.co/GcrbjRd/9556d9e20d20bfe8ed532b961646f631"
        },
        "success": true,
        "status": 200
    }
    """
